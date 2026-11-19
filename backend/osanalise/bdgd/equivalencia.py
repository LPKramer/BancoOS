"""Equivalência entre códigos do TS e elementos da BDGD.

- Trafo: FIS (NUMERO_OPERATIVO -> UNTRMT.COD_ID).
- UC: uc_equivalencia (UC do TS -> UCBT.COD_ID).
- Chave/disjuntor: a BDGD não guarda o código do TS. O app aprende pela coordenada UTM do
  elemento interrompido na base de compensação (Comp_Ocorrências): a chave da BDGD mais
  próxima, até RAIO_M, vira a equivalente. A tabela cresce a cada lote importado.
"""
from __future__ import annotations

import math
import sqlite3
from collections import defaultdict

import pandas as pd

from .. import db
from ..db import EquivChave, agora
from .leitor import distancia_m, utm_para_latlon

RAIO_M = 50.0  # as coordenadas da compensação vêm do mesmo cadastro da BDGD (distância mediana 0 m)
CELULA = 0.002  # ~220 m
PREFIXO_ALIMENTADOR = "CTMT:"  # disjuntor do TS equivale à saída do alimentador
TIPOS_DISJUNTOR = {"29", "32"}


def eh_disjuntor(tipo_ts: str | None, codigo: str) -> bool:
    import re

    return (tipo_ts or "").upper() == "DJ" or re.fullmatch(r"\d{3}R\d{3}", codigo or "") is not None


class GradeChaves:
    def __init__(self, con: sqlite3.Connection):
        self.grade = defaultdict(list)
        for r in con.execute("SELECT cod_id, lat, lon, tip_unid FROM chave WHERE lat IS NOT NULL"):
            self.grade[(int(r[1] // CELULA), int(r[2] // CELULA))].append((r[0], r[1], r[2], r[3]))

    def mais_proxima(self, lat: float, lon: float, raio_m: float = RAIO_M, tipo_ts: str | None = None,
                     so_tipos: set[str] | None = None) -> tuple[str, float] | None:
        """Chave mais próxima; em empate de distância (mesmo poste), evita a chave do trafo ("...CT")."""
        gx, gy = int(lat // CELULA), int(lon // CELULA)
        candidatas = []
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for cod, la, lo, tip in self.grade.get((gx + dx, gy + dy), ()):
                    if so_tipos and tip not in so_tipos:
                        continue
                    d = distancia_m((lat, lon), (la, lo))
                    if d <= raio_m:
                        candidatas.append((d, cod, tip))
        if not candidatas:
            return None
        menor = min(c[0] for c in candidatas)
        empatadas = [c for c in candidatas if c[0] <= menor + 1.0]

        def preferencia(c):
            d, cod, tip = c
            return (cod.endswith("CT"), (tipo_ts or "").upper() == "DJ" and tip not in TIPOS_DISJUNTOR, d)

        d, cod, _ = min(empatadas, key=preferencia)
        return cod, d


def aprender(con: sqlite3.Connection, compensacao: pd.DataFrame, grade: GradeChaves | None = None) -> dict:
    """Registra equivalências a partir das coordenadas dos elementos (exceto trafos e UCs)."""
    if compensacao is None or compensacao.empty or "ELEMENTO" not in compensacao:
        return {"lidas": 0, "novas": 0, "atualizadas": 0}
    grade = grade or GradeChaves(con)
    alimentadores = {r[0]: r[1] for r in con.execute("SELECT nome, cod_id FROM ctmt")}
    linhas = compensacao.dropna(subset=["ELEMENTO"])
    linhas = linhas[~linhas["TIPO"].astype(str).str.upper().isin(["TR", "UC"])]
    novas = atualizadas = 0
    with db.sessao() as s:
        for _, r in linhas.iterrows():
            cod_ts = str(r["ELEMENTO"]).strip()
            tipo_ts = str(r.get("TIPO") or "").upper()
            p = ponto_utm(r.get("NUM_COORX_INT"), r.get("NUM_COORY_INT"))
            if eh_disjuntor(tipo_ts, cod_ts):
                # religador/disjuntor na rede (BDGD 29/32) perto da coordenada; senão é o disjuntor da saída
                achada = grade.mais_proxima(p[0], p[1], so_tipos=TIPOS_DISJUNTOR) if p else None
                if not achada:
                    ct = alimentadores.get(str(r.get("COD_ALIM_ALN") or "").strip())
                    achada = (PREFIXO_ALIMENTADOR + ct, 0.0) if ct else None
            else:
                achada = grade.mais_proxima(p[0], p[1], tipo_ts=tipo_ts) if p else None
            if not achada:
                continue
            atual = s.get(EquivChave, cod_ts)
            if atual is None:
                s.add(EquivChave(cod_ts=cod_ts, cod_bdgd=achada[0], distancia_m=round(achada[1], 1),
                                 tipo_ts=str(r.get("TIPO") or "")[:5], n_obs=1))
                novas += 1
            else:
                atual.n_obs += 1
                if achada[1] < atual.distancia_m:
                    atual.cod_bdgd, atual.distancia_m = achada[0], round(achada[1], 1)
                atual.atualizado_em = agora()
                atualizadas += 1
        s.commit()
    return {"lidas": int(len(linhas)), "novas": novas, "atualizadas": atualizadas}


def chaves_equivalentes(codigos: list[str]) -> dict[str, tuple[str, float]]:
    if not codigos:
        return {}
    with db.sessao() as s:
        return {e.cod_ts: (e.cod_bdgd, e.distancia_m)
                for e in s.query(EquivChave).filter(EquivChave.cod_ts.in_(list(set(codigos)))).all()}


def trafos_por_codigo_ts(con: sqlite3.Connection, codigos: list[str]) -> dict[str, sqlite3.Row]:
    """Código operativo do TS -> linha de `trafo` da BDGD (via FIS)."""
    codigos = [c for c in set(codigos) if c]
    if not codigos:
        return {}
    saida = {}
    for i in range(0, len(codigos), 900):
        parte = codigos[i:i + 900]
        marcas = ",".join("?" * len(parte))
        for r in con.execute(f"""SELECT f.numero_operativo AS ts, t.* FROM fis f JOIN trafo t ON t.cod_id = f.id_instalacao
                                 WHERE f.numero_operativo IN ({marcas})""", parte):
            saida[r["ts"]] = r
    return saida


def codigos_ts_dos_trafos(con: sqlite3.Connection, cod_ids: list[str]) -> dict[str, str]:
    """UNTRMT.COD_ID -> código operativo do TS."""
    saida = {}
    cod_ids = list(set(cod_ids))
    for i in range(0, len(cod_ids), 900):
        parte = cod_ids[i:i + 900]
        marcas = ",".join("?" * len(parte))
        for r in con.execute(f"SELECT id_instalacao, numero_operativo FROM fis WHERE id_instalacao IN ({marcas})", parte):
            saida[r[0]] = r[1]
    return saida


def ucs_bdgd(con: sqlite3.Connection, ucs_ts: list[str]) -> dict[str, sqlite3.Row]:
    """UC do TS -> linha de `ucbt` (ponto e trafo) pela equivalência de UCs."""
    ucs_ts = [u for u in set(ucs_ts) if u]
    if not ucs_ts:
        return {}
    saida = {}
    for i in range(0, len(ucs_ts), 900):
        parte = ucs_ts[i:i + 900]
        marcas = ",".join("?" * len(parte))
        for r in con.execute(f"""SELECT e.uc_ts, u.* FROM uc_equiv e JOIN ucbt u ON u.cod_id = e.uc_siate
                                 WHERE e.uc_ts IN ({marcas})""", parte):
            saida[r["uc_ts"]] = r
    return saida


def ponto_utm(x, y) -> tuple[float, float] | None:
    try:
        x, y = float(x), float(y)
    except (TypeError, ValueError):
        return None
    if math.isnan(x) or math.isnan(y) or not (100000 < x < 1500000 and 7000000 < y < 10000000):
        return None
    return utm_para_latlon(x, y)
