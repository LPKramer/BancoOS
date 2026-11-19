"""Carrega as bases direto da planilha exportada da crítica, sem passar pelo Access.

A exportação junta todos os tipos de registro (INTERVENÇÃO, PASSO_MANOBRA, INDIV_VINCULADA,
EQUIPE, INDIVIDUAL) nas mesmas 42 colunas; o significado de cada coluna muda conforme TIPO_OS.
`dados/mapeamento_critica.json` reproduz as consultas "0 Tabela *" do Banco de Análise.
"""
from __future__ import annotations

import json
from importlib import resources
from pathlib import Path

import pandas as pd

from ..dados import BaseOS, competencia_de, normalizar

ABA_CRITICA = "Exportar Planilha"


def _mapeamento() -> dict:
    texto = resources.files("osanalise.recursos").joinpath("mapeamento_critica.json").read_text(encoding="utf-8")
    return json.loads(texto)


def localidades_padrao() -> pd.DataFrame:
    with resources.files("osanalise.recursos").joinpath("localidades.csv").open(encoding="utf-8") as f:
        return pd.read_csv(f, dtype=str)


def _ler_planilha(caminho: str | Path, aba: str | int | None) -> pd.DataFrame:
    caminho = Path(caminho)
    if caminho.suffix.lower() in (".csv", ".txt"):
        return pd.read_csv(caminho, sep=None, engine="python", dtype=str, encoding="latin-1")
    return pd.read_excel(caminho, sheet_name=aba if aba is not None else 0, dtype=str)


def separar_critica(bruta: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Aplica o mapeamento por TIPO_OS e devolve um DataFrame (ainda texto) por entidade."""
    bruta = bruta.copy()
    bruta.columns = [str(c).strip() for c in bruta.columns]
    tipo = bruta["TIPO_OS"].astype("string").str.strip()
    saida = {}
    for entidade, regra in _mapeamento().items():
        parte = bruta[tipo == regra["tipo_os"]]
        dados = {}
        for destino, origem in regra["colunas"]:
            if isinstance(origem, dict):
                dados[destino] = origem["constante"]
            else:
                dados[destino] = parte[origem].values if origem in parte else None
        df = pd.DataFrame(dados, index=range(len(parte)))
        if regra["deduplicar"]:
            df = df.drop_duplicates()
        saida[entidade] = df
    return saida


def carregar_de_critica(
    planilha_critica: str | Path,
    planilha_compensacao: str | Path | None = None,
    localidades: pd.DataFrame | None = None,
) -> BaseOS:
    bruta = _ler_planilha(planilha_critica, ABA_CRITICA if str(planilha_critica).lower().endswith(("xlsx", "xlsm", "xls")) else None)
    partes = separar_critica(bruta)
    if planilha_compensacao:
        comp = _ler_planilha(planilha_compensacao, 0)
        comp.columns = [str(c).strip() for c in comp.columns]
    else:
        comp = pd.DataFrame(columns=["NUM_SEQ_OPER_INIC_INTER_VDI", "MULTA_OS"])
    dfs = {ent: normalizar(ent, df) for ent, df in partes.items()}
    dfs["compensacao"] = normalizar("compensacao", comp)
    dfs["localidade"] = normalizar("localidade", localidades if localidades is not None else localidades_padrao())
    origem = str(planilha_critica) + (f" + {planilha_compensacao}" if planilha_compensacao else "")
    base = BaseOS(**dfs, origem=origem)
    base.competencia = competencia_de(base)
    return base
