"""Arquivos de entrada que o analista aponta na tela Importar.

- critica: planilha exportada da crítica (aba "Exportar Planilha": intervenções, passos, vinculadas...).
- ocorrencias: "9 C_Ocorrências" (compensação por OS: MULTA_OS, coordenadas do elemento).
- textos: "TEXTOS PADRÕES PARA CORREÇÕES" (justificativas usadas no TS).

O caminho escolhido fica gravado no banco (tabela configuracao). Sem caminho gravado, o app sugere o
arquivo mais recente da pasta do projeto que tenha o nome esperado. `verificar` abre só o cabeçalho
(openpyxl em modo leitura), então responde em poucos segundos mesmo com a crítica de 17 MB.
"""
from __future__ import annotations

import threading
from datetime import datetime
from pathlib import Path

from . import db
from .config import PASTA_PROJETO
from .db import Configuracao, agora

TIPOS: dict[str, dict] = {
    "critica": {"nome": "Crítica", "padrao": "*critica*.xls*",
                "colunas": {"TIPO_OS", "NUM_SEQ_OPER_OS_MNB", "DTA_CMPT_MNB"}, "competencia": "DTA_CMPT_MNB",
                "aba": "Exportar Planilha"},
    "ocorrencias": {"nome": "Ocorrências (compensação)", "padrao": "*Ocorr*.xls*",
                    "colunas": {"NUM_SEQ_OPER_INIC_INTER_VDI", "MULTA_OS"}, "competencia": "DTA_CMPT_VDI",
                    "aba": None},
    "textos": {"nome": "Textos padrões", "padrao": "TEXTOS PADR*.xls*", "colunas": set(), "competencia": None,
               "aba": None},
}
EXTENSOES = {".xlsx", ".xlsm", ".csv", ".txt"}

_cache: dict[tuple, dict] = {}
_trava = threading.Lock()


def _chave(tipo: str) -> str:
    return f"fonte.{tipo}"


def caminho_salvo(tipo: str) -> str | None:
    with db.sessao() as s:
        c = s.get(Configuracao, _chave(tipo))
        return c.valor if c and c.valor else None


def salvar_caminho(tipo: str, caminho: str, usuario: str = "") -> None:
    from .servicos import auditar

    with db.sessao() as s:
        c = s.get(Configuracao, _chave(tipo)) or Configuracao(chave=_chave(tipo))
        if c.valor == caminho:
            return
        anterior = c.valor
        c.valor, c.atualizado_em, c.atualizado_por = caminho, agora(), usuario
        s.merge(c)
        auditar(s, usuario, "apontar_base", tipo, anterior=anterior, caminho=caminho)
        s.commit()


def sugerido(tipo: str) -> str | None:
    """Arquivo mais recente da pasta do projeto com o nome esperado (ignora temporários do Excel)."""
    achados = [p for p in PASTA_PROJETO.glob(TIPOS[tipo]["padrao"]) if p.is_file() and not p.name.startswith("~$")]
    return str(max(achados, key=lambda p: p.stat().st_mtime)) if achados else None


def limpar_caminho(caminho: str) -> Path:
    return Path(caminho.strip().strip('"').strip("'"))


def _competencia(v) -> str | None:
    if v is None or v == "":
        return None
    if isinstance(v, datetime):
        return f"{v.month:02d}/{v.year}"
    t = str(v).strip()
    for fmt in ("%d/%m/%Y", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%d/%m/%Y %H:%M:%S", "%m/%Y"):
        try:
            d = datetime.strptime(t[:19], fmt)
            return f"{d.month:02d}/{d.year}"
        except ValueError:
            continue
    return t[:10]


def _cabecalho_planilha(arq: Path, aba: str | None) -> tuple[list[str], list, int | None, str]:
    """Cabeçalho, 1ª linha de dados, nº de linhas e nome da aba lida."""
    if arq.suffix.lower() in (".csv", ".txt"):
        import pandas as pd

        df = pd.read_csv(arq, sep=None, engine="python", dtype=str, encoding="latin-1", nrows=2)
        return [str(c).strip() for c in df.columns], list(df.iloc[0]) if len(df) else [], None, arq.name
    import openpyxl

    wb = openpyxl.load_workbook(arq, read_only=True, data_only=True)
    try:
        if aba is not None and aba not in wb.sheetnames:
            raise ValueError(f'não tem a aba "{aba}" (abas: {", ".join(wb.sheetnames[:6])})')
        ws = wb[aba] if aba else wb.worksheets[0]
        linhas = ws.iter_rows(min_row=1, max_row=2, values_only=True)
        cab = [str(c).strip() if c is not None else "" for c in next(linhas, ())]
        primeira = list(next(linhas, ()))
        n = ws.max_row - 1 if ws.max_row else None
        return cab, primeira, n, ws.title
    finally:
        wb.close()


def verificar(tipo: str, caminho: str | Path | None) -> dict:
    """Confere se o arquivo existe e tem o formato esperado para o papel dele."""
    if tipo not in TIPOS:
        raise KeyError(tipo)
    if not caminho:
        return {"ok": False, "mensagem": "Nenhum arquivo apontado."}
    arq = limpar_caminho(str(caminho))
    if not arq.is_file():
        return {"ok": False, "caminho": str(arq), "mensagem": "Arquivo não encontrado neste servidor."}
    st = arq.stat()
    base = {"caminho": str(arq), "nome": arq.name, "tamanho": st.st_size,
            "modificado": datetime.fromtimestamp(st.st_mtime).isoformat(timespec="seconds")}
    if arq.suffix.lower() not in EXTENSOES:
        return {**base, "ok": False, "mensagem": f"Extensão {arq.suffix} não aceita (use .xlsx ou .csv)."}
    chave = (tipo, str(arq), st.st_size, st.st_mtime)
    with _trava:
        if chave in _cache:
            return _cache[chave]
    resultado = {**base, **_conferir_conteudo(tipo, arq)}
    with _trava:
        _cache[chave] = resultado
    return resultado


def _conferir_conteudo(tipo: str, arq: Path) -> dict:
    d = TIPOS[tipo]
    try:
        if tipo == "textos":
            from .textos_padrao import ler_planilha

            textos = ler_planilha(arq)
            return {"ok": bool(textos), "linhas": len(textos),
                    "mensagem": f"{len(textos)} textos" if textos else "Nenhum texto na coluna JUSTIFICATIVA CORREÇÃO."}
        cab, primeira, n, aba = _cabecalho_planilha(arq, d["aba"])
    except ValueError as e:
        return {"ok": False, "mensagem": f"O arquivo {e}."}
    except Exception as e:  # noqa: BLE001 - arquivo corrompido, aberto no Excel etc.
        return {"ok": False, "mensagem": f"Não consegui ler: {type(e).__name__}: {e}"}
    faltam = sorted(d["colunas"] - set(cab))
    if faltam:
        return {"ok": False, "aba": aba, "mensagem": f"Faltam as colunas {', '.join(faltam)}; não parece ser a base {d['nome']}."}
    comp = None
    if d["competencia"] in cab and primeira:
        i = cab.index(d["competencia"])
        comp = _competencia(primeira[i]) if i < len(primeira) else None
    partes = [f"aba {aba}"] + ([f"{n:,} linhas".replace(",", ".")] if n else []) + ([f"competência {comp}"] if comp else [])
    return {"ok": True, "aba": aba, "linhas": n, "competencia": comp, "mensagem": " · ".join(partes)}


def situacao(tipo: str) -> dict:
    salvo = caminho_salvo(tipo)
    caminho = salvo or sugerido(tipo)
    return {"tipo": tipo, "nome": TIPOS[tipo]["nome"], "caminho": caminho, "salvo": bool(salvo),
            "verificacao": verificar(tipo, caminho) if caminho else None}
