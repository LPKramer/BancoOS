"""Modelo canônico das bases (mesmos nomes de coluna do Access) e normalização de tipos.

Qualquer importador (Access, planilha da crítica) entrega um `BaseOS` com estes DataFrames:
datas como datetime, números como float (vazio = NaN) e textos sem espaços nas pontas
(texto vazio = NaN, como o Access trata campo sem valor).
"""
from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd

# entidade -> (tabela no Access, colunas de data, colunas numéricas)
ENTIDADES: dict[str, tuple[str, list[str], list[str]]] = {
    "intervencao": (
        "1 Tabela_Intervenção",
        ["DTA_CMPT_MNB", "DTA_INIC_MNB", "DTA_AVI_EQP_MNB", "DTA_DLCT_EQP_MNB", "DTA_VERI_EQP_MNB",
         "DTA_SERV_EQP_MNB", "DTA_FIM_MNB"],
        ["TMA", "DEC", "FEC"],
    ),
    "manobra": (
        "1 Tabela_Manobra",
        ["DTA_PASSO_PNB", "DTA_PREV_PASSO_PNB"],
        ["QTD_UN_CONS_VIP_PNB", "QTD_UN_CONS_PNB", "QTD_KVAS_PNB", "NUM_SEQ_PNB", "NUM_PASSO_PNB"],
    ),
    "vinculada": (
        "1 Tabela_Individual_Vinculada",
        ["DTA_CMPT_MNB", "DTA_RECL_CNR", "DTA_COMU_CNR", "DTA_DLCT_CNR", "DTA_VERI_CNR", "DTA_SERV_CNR",
         "DTA_FIM_CNR"],
        [],
    ),
    "equipe": ("1 Tabela_Equipe", ["DTA_CMPT_MNB"], ["QUANTIDADE"]),
    "individual": (
        "1 Tabela Ocorrência_Individual",
        ["DTA_CMPT_MNB", "DTA_RECL_CNR", "DTA_COMU_CNR", "DTA_DLCT_CNR", "DTA_VERI_CNR", "DTA_SERV_CNR",
         "DTA_FIM_CNR"],
        ["TMA", "DEC", "FEC"],
    ),
    "compensacao": (
        "Comp_Ocorrências",
        ["DTA_CMPT_VDI", "DTA_RECL_CNR", "DTA_FIM_CNR"],
        ["QTD_UCS", "MULTA_OS", "TMA", "DEC"],
    ),
    "localidade": ("Segmentação_Lógica", [], []),
}

# Chave da OS em cada entidade
CHAVE_OS = {
    "intervencao": "NUM_SEQ_OPER_OS_MNB",
    "manobra": "NUM_SEQ_OPER_OS_PNB",
    "vinculada": "NUM_SEQ_OPER_INTER_CNR",
    "equipe": "NUM_SEQ_OPER_OS_MNB",
    "individual": "NUM_SEQ_OPER_CNR",
    "compensacao": "NUM_SEQ_OPER_INIC_INTER_VDI",
}

# Colunas de texto livre (vão para o LLM, depois de mascaradas)
TEXTO_LIVRE = {
    "intervencao": ["DES_INTV_MNB"],
    "manobra": ["DES_PASSO_PNB"],
    "vinculada": ["DES_OBS_EXEC_SERV_CNR", "DES_PTO_REF_CNR"],
    "individual": ["DES_OBS_EXEC_SERV_CNR", "DES_PTO_REF_CNR"],
}


@dataclass
class BaseOS:
    intervencao: pd.DataFrame
    manobra: pd.DataFrame
    vinculada: pd.DataFrame
    equipe: pd.DataFrame
    individual: pd.DataFrame
    compensacao: pd.DataFrame
    localidade: pd.DataFrame
    competencia: str | None = None
    origem: str = ""
    extras: dict[str, pd.DataFrame] = field(default_factory=dict)

    def contagens(self) -> dict[str, int]:
        return {nome: int(len(getattr(self, nome))) for nome in ENTIDADES}


def para_data(serie: pd.Series) -> pd.Series:
    """Aceita '2026-10-13 12:30:00' (Access), '02/10/2026 11:30' (crítica) e datetime."""
    if pd.api.types.is_datetime64_any_dtype(serie):
        return serie
    texto = serie.astype("string").str.strip()
    texto = texto.mask(texto == "")
    iso = pd.to_datetime(texto, format="ISO8601", errors="coerce")
    falta = iso.isna() & texto.notna()
    if falta.any():
        br = pd.to_datetime(texto[falta], dayfirst=True, errors="coerce", format="mixed")
        iso = iso.copy()
        iso[falta] = br
    return iso


def para_numero(serie: pd.Series) -> pd.Series:
    """Números com vírgula decimal ('0,0001'), texto vazio vira NaN."""
    if pd.api.types.is_numeric_dtype(serie):
        return serie.astype(float)
    texto = serie.astype("string").str.strip().str.replace(".", "", regex=False).str.replace(",", ".", regex=False)
    # valores já com ponto decimal (ex.: '12.0' vindo do Excel) não podem perder o ponto
    original = serie.astype("string").str.strip()
    com_ponto = original.str.contains(r"^\-?\d+\.\d+$", regex=True, na=False)
    texto = texto.where(~com_ponto, original)
    return pd.to_numeric(texto.mask(texto == ""), errors="coerce")


def normalizar(entidade: str, df: pd.DataFrame) -> pd.DataFrame:
    _, datas, numeros = ENTIDADES[entidade]
    df = df.copy()
    if entidade == "manobra" and "'" in df.columns:  # nome real da coluna no Access
        df = df.rename(columns={"'": "QTD_UN_CONS_PNB"})
    for col in df.columns:
        if col in datas:
            df[col] = para_data(df[col])
        elif col in numeros:
            df[col] = para_numero(df[col])
        elif df[col].dtype == object or pd.api.types.is_string_dtype(df[col]):
            s = df[col].astype("string").str.strip()
            df[col] = s.mask(s == "").astype(object).where(s.notna() & (s != ""), np.nan)
    chave = CHAVE_OS.get(entidade)
    if chave and chave in df.columns:
        df[chave] = df[chave].astype("string").str.strip().astype(object)
    return df.reset_index(drop=True)


def competencia_de(base: BaseOS) -> str | None:
    """Mês de competência mais frequente nas intervenções (AAAA-MM)."""
    if "DTA_CMPT_MNB" not in base.intervencao or base.intervencao.empty:
        return None
    moda = base.intervencao["DTA_CMPT_MNB"].dropna().dt.strftime("%Y-%m").mode()
    return None if moda.empty else str(moda.iloc[0])
