"""Índice da BDGD em SQLite: lido uma vez dos shapefiles e reaproveitado em todas as consultas.

Fontes (pasta configurada em OSA_BDGD_AUX / OSA_BDGD):
  BD*/CTMT, SSDMT, UNSEMT, UNREMT, UNTRMT, UCBT, UCMT, SUB   (BDGD)
  FIS_*TRANSFORMADORES*.csv   código operativo do TS -> UNTRMT.COD_ID
  uc_equivalencia.xlsx        UC do TS -> UC da BDGD (UCBT.COD_ID)
  clientes_TS.csv             UC do TS -> trafo do TS e alimentador
"""
from __future__ import annotations

import csv
import glob
import sqlite3
import threading
import time
from collections import Counter
from datetime import datetime
from pathlib import Path

from ..config import CONFIG
from .leitor import Shp, iter_dbf

VERSAO_INDICE = 2
TIPOS_PROTECAO = {"22": "Chave fusível", "23": "Chave fusível", "27": "Chave fusível", "46": "Chave fusível",
                  "32": "Religador", "29": "Disjuntor"}

ESTADO = {"situacao": "parado", "etapa": "", "inicio": None, "fim": None, "erro": None}
_trava = threading.Lock()

ESQUEMA = """
CREATE TABLE meta (chave TEXT PRIMARY KEY, valor TEXT);
CREATE TABLE ctmt (cod_id TEXT PRIMARY KEY, nome TEXT, pac_ini TEXT, sub TEXT, ten_nom TEXT);
CREATE TABLE seg (idx INTEGER PRIMARY KEY, ctmt TEXT, pac1 TEXT, pac2 TEXT);
CREATE TABLE chave (idx INTEGER PRIMARY KEY, cod_id TEXT, pac1 TEXT, pac2 TEXT, tip_unid TEXT, p_n_ope TEXT,
                    cap_elo TEXT, ctmt1 TEXT, ctmt2 TEXT, lat REAL, lon REAL);
CREATE TABLE regulador (cod_id TEXT, pac1 TEXT, pac2 TEXT, ctmt TEXT);
CREATE TABLE trafo (idx INTEGER PRIMARY KEY, cod_id TEXT, pac1 TEXT, ctmt TEXT, pot REAL, lat REAL, lon REAL,
                    n_ucs INTEGER);
CREATE TABLE ucmt (cod_id TEXT, pac TEXT, ctmt TEXT, lat REAL, lon REAL);
CREATE TABLE ucbt (cod_id TEXT PRIMARY KEY, tr TEXT, ativa INTEGER, lat REAL, lon REAL);
CREATE TABLE fis (numero_operativo TEXT PRIMARY KEY, id_instalacao TEXT, circuito TEXT, lat REAL, lon REAL);
CREATE TABLE uc_equiv (uc_ts TEXT PRIMARY KEY, uc_siate TEXT);
CREATE TABLE cli_ts (uc TEXT PRIMARY KEY, codtrafo TEXT, alimentador TEXT);
"""
INDICES = """
CREATE INDEX ix_seg_ctmt ON seg (ctmt);
CREATE INDEX ix_chave_c1 ON chave (ctmt1);
CREATE INDEX ix_chave_c2 ON chave (ctmt2);
CREATE INDEX ix_chave_cod ON chave (cod_id);
CREATE INDEX ix_trafo_ctmt ON trafo (ctmt);
CREATE INDEX ix_trafo_cod ON trafo (cod_id);
CREATE INDEX ix_ucbt_tr ON ucbt (tr);
CREATE INDEX ix_ctmt_nome ON ctmt (nome);
CREATE INDEX ix_reg_ctmt ON regulador (ctmt);
CREATE INDEX ix_ucmt_ctmt ON ucmt (ctmt);
"""


def _arquivo_indice(pasta_bdgd: Path) -> Path:
    return CONFIG.pasta_dados / "bdgd" / f"{pasta_bdgd.name}.db"


def _assinatura(pasta: Path) -> str:
    return str(int(max(p.stat().st_mtime for p in pasta.iterdir())))


def caminho_indice() -> Path | None:
    """Índice pronto e atualizado para a BDGD configurada, ou None."""
    pasta = CONFIG.bdgd
    if pasta is None:
        return None
    arq = _arquivo_indice(pasta)
    if not arq.exists():
        return None
    try:
        with sqlite3.connect(arq) as con:
            meta = dict(con.execute("SELECT chave, valor FROM meta"))
    except sqlite3.Error:
        return None
    if meta.get("versao") != str(VERSAO_INDICE) or meta.get("assinatura") != _assinatura(pasta):
        return None
    return arq


def conectar() -> sqlite3.Connection:
    arq = caminho_indice()
    if arq is None:
        raise FileNotFoundError("Índice da BDGD não construído")
    con = sqlite3.connect(arq, check_same_thread=False)
    con.row_factory = sqlite3.Row
    return con


def status() -> dict:
    pasta = CONFIG.bdgd
    arq = caminho_indice()
    info = {"pasta_bdgd": str(pasta) if pasta else None, "pronto": arq is not None, **ESTADO}
    if arq:
        with sqlite3.connect(arq) as con:
            info["meta"] = dict(con.execute("SELECT chave, valor FROM meta"))
    return info


def _etapa(texto: str) -> None:
    ESTADO["etapa"] = texto


def construir(forcar: bool = False) -> Path:
    pasta = CONFIG.bdgd
    if pasta is None:
        raise FileNotFoundError("Pasta da BDGD não encontrada (configure OSA_BDGD ou OSA_BDGD_AUX)")
    if not forcar and caminho_indice():
        return caminho_indice()
    aux = CONFIG.pasta_bdgd_aux
    destino = _arquivo_indice(pasta)
    destino.parent.mkdir(parents=True, exist_ok=True)
    temp = destino.with_suffix(".tmp")
    temp.unlink(missing_ok=True)
    con = sqlite3.connect(temp)
    con.executescript(ESQUEMA)
    P = lambda n: pasta / n  # noqa: E731
    t0 = time.time()
    try:
        _etapa("alimentadores e subestações")
        sub = {r["COD_ID"]: r["NOME"] for _, r in iter_dbf(P("SUB.dbf"), ["COD_ID", "NOME"])}
        con.executemany("INSERT INTO ctmt VALUES (?,?,?,?,?)", [
            (r["COD_ID"], r["NOME"], r["PAC_INI"], sub.get(r["SUB"]) or r["DESCR"] or "", r["TEN_NOM"])
            for _, r in iter_dbf(P("CTMT.dbf"), ["COD_ID", "NOME", "PAC_INI", "SUB", "DESCR", "TEN_NOM"])])

        _etapa("trechos de média tensão (SSDMT)")
        pac_ctmt: dict[str, str] = {}
        lote = []
        for i, r in iter_dbf(P("SSDMT.dbf"), ["CTMT", "PAC_1", "PAC_2"]):
            lote.append((i, r["CTMT"], r["PAC_1"], r["PAC_2"]))
            pac_ctmt.setdefault(r["PAC_1"], r["CTMT"])
            pac_ctmt.setdefault(r["PAC_2"], r["CTMT"])
            if len(lote) >= 50000:
                con.executemany("INSERT INTO seg VALUES (?,?,?,?)", lote)
                lote.clear()
        con.executemany("INSERT INTO seg VALUES (?,?,?,?)", lote)

        _etapa("chaves (UNSEMT) e reguladores")
        trafos_brutos = list(iter_dbf(P("UNTRMT.dbf"), ["COD_ID", "PAC_1", "CTMT", "POT_NOM"]))
        for _, r in trafos_brutos:
            if r["CTMT"]:
                pac_ctmt.setdefault(r["PAC_1"], r["CTMT"])
        for _, r in iter_dbf(P("UCMT.dbf"), ["PAC", "CTMT"]):
            if r["CTMT"]:
                pac_ctmt.setdefault(r["PAC"], r["CTMT"])
        chaves_brutas = list(iter_dbf(P("UNSEMT.dbf"), ["COD_ID", "PAC_1", "PAC_2", "TIP_UNID", "P_N_OPE", "CAP_ELO"]))
        reguladores = [r for _, r in iter_dbf(P("UNREMT.dbf"), ["COD_ID", "PAC_1", "PAC_2", "CTMT"])]
        for r in reguladores:
            if r["CTMT"]:
                pac_ctmt.setdefault(r["PAC_1"], r["CTMT"])
                pac_ctmt.setdefault(r["PAC_2"], r["CTMT"])
        # chaves em cadeia (trecho -> chave -> nó -> chave do trafo) herdam o alimentador do vizinho
        pendentes = [r for _, r in chaves_brutas]
        for _ in range(20):
            mudou = False
            restantes = []
            for r in pendentes:
                a, b = pac_ctmt.get(r["PAC_1"]), pac_ctmt.get(r["PAC_2"])
                if a and not b:
                    pac_ctmt[r["PAC_2"]] = a
                    mudou = True
                elif b and not a:
                    pac_ctmt[r["PAC_1"]] = b
                    mudou = True
                elif not a and not b:
                    restantes.append(r)
            pendentes = restantes
            if not mudou:
                break
        pontos = Shp(P("UNSEMT")).todos_pontos()
        linhas = []
        for i, r in chaves_brutas:
            c1, c2 = pac_ctmt.get(r["PAC_1"]), pac_ctmt.get(r["PAC_2"])
            pt = pontos[i] if i < len(pontos) else None
            linhas.append((i, r["COD_ID"], r["PAC_1"], r["PAC_2"], r["TIP_UNID"], r["P_N_OPE"], r["CAP_ELO"],
                           c1 or c2, c2 if c2 and c2 != c1 else None, pt[0] if pt else None, pt[1] if pt else None))
        con.executemany("INSERT INTO chave VALUES (?,?,?,?,?,?,?,?,?,?,?)", linhas)
        con.executemany("INSERT INTO regulador VALUES (?,?,?,?)", [
            (r["COD_ID"], r["PAC_1"], r["PAC_2"], r["CTMT"] or pac_ctmt.get(r["PAC_1"])) for r in reguladores])
        del pac_ctmt, chaves_brutas

        _etapa("unidades consumidoras de baixa tensão (UCBT)")
        pontos = Shp(P("UCBT")).todos_pontos()
        ucs_tr: Counter = Counter()
        vistos: set[str] = set()
        lote = []
        for i, r in iter_dbf(P("UCBT.dbf"), ["COD_ID", "UNI_TR_MT", "SIT_ATIV"]):
            ativa = r["SIT_ATIV"] == "AT"
            if ativa:
                ucs_tr[r["UNI_TR_MT"]] += 1
            if r["COD_ID"] in vistos:
                continue
            vistos.add(r["COD_ID"])
            pt = pontos[i] if i < len(pontos) else None
            lote.append((r["COD_ID"], r["UNI_TR_MT"], int(ativa), pt[0] if pt else None, pt[1] if pt else None))
            if len(lote) >= 50000:
                con.executemany("INSERT OR IGNORE INTO ucbt VALUES (?,?,?,?,?)", lote)
                lote.clear()
        con.executemany("INSERT OR IGNORE INTO ucbt VALUES (?,?,?,?,?)", lote)
        del vistos, pontos

        _etapa("transformadores (UNTRMT) e UCs de média tensão")
        pontos = Shp(P("UNTRMT")).todos_pontos()
        con.executemany("INSERT INTO trafo VALUES (?,?,?,?,?,?,?,?)", [
            (i, r["COD_ID"], r["PAC_1"], r["CTMT"], _num(r["POT_NOM"]),
             pontos[i][0] if pontos[i] else None, pontos[i][1] if pontos[i] else None, ucs_tr.get(r["COD_ID"], 0))
            for i, r in trafos_brutos])
        del trafos_brutos
        pontos = Shp(P("UCMT")).todos_pontos()
        con.executemany("INSERT INTO ucmt VALUES (?,?,?,?,?)", [
            (r["COD_ID"], r["PAC"], r["CTMT"], pontos[i][0] if pontos[i] else None,
             pontos[i][1] if pontos[i] else None)
            for i, r in iter_dbf(P("UCMT.dbf"), ["COD_ID", "PAC", "CTMT", "SIT_ATIV"]) if r["SIT_ATIV"] == "AT"])

        _etapa("FIS (código operativo dos trafos)")
        fis = next(iter(glob.glob(str(aux / "FIS_*TRANSFORMADORES*.csv"))), None)
        if fis:
            with open(fis, encoding="latin1") as f:
                con.executemany("INSERT OR IGNORE INTO fis VALUES (?,?,?,?,?)", [
                    (r["NUMERO_OPERATIVO"], r["ID_INSTALACAO"], r.get("CIRCUITO"), _num(r.get("LAT")),
                     _num(r.get("LONG"))) for r in csv.DictReader(f, delimiter=";") if r.get("NUMERO_OPERATIVO")])

        _etapa("equivalência de UCs e clientes do TS")
        eq = aux / "uc_equivalencia.xlsx"
        if eq.exists():
            import openpyxl

            wb = openpyxl.load_workbook(eq, read_only=True)
            lote = []
            for i, row in enumerate(wb.worksheets[0].iter_rows(values_only=True)):
                if i and row[0] is not None and row[1] is not None:
                    lote.append((str(row[1]).strip(), str(row[0]).strip()))
            con.executemany("INSERT OR IGNORE INTO uc_equiv VALUES (?,?)", lote)
        cli = aux / "clientes_TS.csv"
        if cli.exists():
            with open(cli, encoding="utf-8-sig") as f:
                con.executemany("INSERT OR IGNORE INTO cli_ts VALUES (?,?,?)", [
                    (r["UC"], r["CODTRAFO"], r.get("ALIMENTADOR")) for r in csv.DictReader(f)])

        _etapa("índices")
        con.executescript(INDICES)
        contagens = {t: con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
                     for t in ("ctmt", "seg", "chave", "trafo", "ucbt", "ucmt", "fis", "uc_equiv", "cli_ts")}
        con.executemany("INSERT INTO meta VALUES (?,?)", [
            ("versao", str(VERSAO_INDICE)), ("assinatura", _assinatura(pasta)), ("pasta", str(pasta)),
            ("construido_em", datetime.now().isoformat(timespec="seconds")),
            ("segundos", f"{time.time() - t0:.0f}"), ("contagens", str(contagens))])
        con.commit()
    finally:
        con.close()
    destino.unlink(missing_ok=True)
    temp.rename(destino)
    return destino


def construir_em_segundo_plano(forcar: bool = False) -> dict:
    with _trava:
        if ESTADO["situacao"] == "construindo":
            return status()
        ESTADO.update(situacao="construindo", etapa="iniciando", inicio=datetime.now().isoformat(timespec="seconds"),
                      fim=None, erro=None)

    def rodar():
        try:
            construir(forcar)
            ESTADO.update(situacao="pronto", etapa="")
        except Exception as e:  # noqa: BLE001
            ESTADO.update(situacao="erro", erro=f"{type(e).__name__}: {e}")
        finally:
            ESTADO["fim"] = datetime.now().isoformat(timespec="seconds")

    threading.Thread(target=rodar, daemon=True, name="indice-bdgd").start()
    return status()


def _num(v) -> float | None:
    try:
        return float(str(v).replace(",", "."))
    except (TypeError, ValueError):
        return None
