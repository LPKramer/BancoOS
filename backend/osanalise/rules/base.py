"""Infraestrutura das regras: definição, registro e cálculos compartilhados (passos, reclamações).

Os cálculos reproduzem as consultas do Banco de Análise, inclusive os detalhes de nulos do
Access: comparação com campo vazio é "falsa", Min/Max ignoram vazios e textos são comparados
sem diferenciar maiúsculas.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from functools import cached_property
from typing import Callable

import numpy as np
import pandas as pd

from ..dados import BaseOS

COL_OS = "os"
CANCELADO = "PASSO CANCELADO"


@dataclass(frozen=True)
class Regra:
    id: str
    nome: str
    descricao: str
    tipo_os: str  # "intervencao" | "individual"
    funcao: Callable[["Contexto"], pd.DataFrame] = field(repr=False, compare=False)
    sozinha_basta: bool = True  # False: se for a única flag da OS, ela não entra na fila (filtro do Access)
    coluna_access: str | None = None  # coluna da tabela de resultado do Access (paridade)
    correcao_tipica: str | None = None
    divergencia_access: str | None = None
    consulta_access: str | None = None


REGISTRO: dict[str, Regra] = {}


def regra(**kwargs):
    """Decorador: registra a função como regra."""

    def decorar(func):
        r = Regra(funcao=func, **kwargs)
        if r.id in REGISTRO:
            raise ValueError(f"regra duplicada: {r.id}")
        REGISTRO[r.id] = r
        return func

    return decorar


def up(serie: pd.Series) -> pd.Series:
    """Texto em maiúsculas para comparar como o Access (vazio continua vazio)."""
    return serie.astype("string").str.strip().str.upper()


def resultado(os_: pd.Series, valor, evidencia: list[dict] | None = None) -> pd.DataFrame:
    df = pd.DataFrame({COL_OS: os_.astype(str).values})
    df["valor"] = valor if not isinstance(valor, pd.Series) else valor.astype(str).values
    df["evidencia"] = evidencia if evidencia is not None else [{} for _ in range(len(df))]
    return df.drop_duplicates(subset=[COL_OS, "valor"]).reset_index(drop=True)


def _registros(df: pd.DataFrame, colunas: list[str]) -> list[dict]:
    out = []
    for linha in df[colunas].itertuples(index=False):
        d = {}
        for c, v in zip(colunas, linha):
            if isinstance(v, pd.Timestamp):
                d[c] = v.strftime("%d/%m/%Y %H:%M")
            elif v is None or (isinstance(v, float) and np.isnan(v)) or v is pd.NaT:
                d[c] = None
            elif isinstance(v, (np.floating, float)):
                d[c] = float(v)
            elif isinstance(v, (np.integer,)):
                d[c] = int(v)
            else:
                d[c] = str(v)
        out.append(d)
    return out


def evidencias(df: pd.DataFrame, colunas: list[str]) -> list[dict]:
    return _registros(df, [c for c in colunas if c in df.columns])


class Contexto:
    """Base de um lote + cálculos intermediários reaproveitados pelas regras."""

    def __init__(self, base: BaseOS):
        self.base = base

    # ------------------------------------------------------------- intervenções
    @cached_property
    def intervencao(self) -> pd.DataFrame:
        df = self.base.intervencao.copy()
        df[COL_OS] = df["NUM_SEQ_OPER_OS_MNB"].astype(str)
        return df

    @cached_property
    def manobra(self) -> pd.DataFrame:
        df = self.base.manobra.copy()
        df[COL_OS] = df["NUM_SEQ_OPER_OS_PNB"].astype(str)
        df["_OPER"] = up(df["COD_OPER_PNB"])
        df["_STATUS"] = up(df["STA_EXEC_PNB"])
        if "QTD_UN_CONS_PNB" not in df:
            df["QTD_UN_CONS_PNB"] = np.nan
        return df

    @cached_property
    def vinculada(self) -> pd.DataFrame:
        df = self.base.vinculada.copy()
        df[COL_OS] = df["NUM_SEQ_OPER_INTER_CNR"].astype(str)
        return df

    def _passo_extremo(self, operacoes: tuple[str, ...], usar_max: bool) -> pd.DataFrame:
        """Primeiro (ou último) passo válido de cada intervenção.

        Consultas x_0..x_6: passos das operações dadas e não cancelados; menor (maior) data;
        entre os passos dessa data, o de menor NUM_SEQ_PNB; o passo é então buscado na tabela
        inteira de manobra pela data + sequência.
        """
        m = self.manobra
        validos = m[m["_OPER"].isin(operacoes) & m["_STATUS"].notna() & (m["_STATUS"] != CANCELADO)
                    & m["DTA_PASSO_PNB"].notna()]
        agg = "max" if usar_max else "min"
        datas = validos.groupby(COL_OS)["DTA_PASSO_PNB"].agg(agg).rename("_DATA").reset_index()
        cand = validos.merge(datas, left_on=[COL_OS, "DTA_PASSO_PNB"], right_on=[COL_OS, "_DATA"])
        seq = cand.groupby([COL_OS, "DTA_PASSO_PNB"])["NUM_SEQ_PNB"].min().rename("_SEQ").reset_index()
        passos = m.merge(seq, on=[COL_OS, "DTA_PASSO_PNB"])
        passos = passos[passos["NUM_SEQ_PNB"] == passos["_SEQ"]]
        colunas = [COL_OS, "COD_OPER_PNB", "_OPER", "DTA_PASSO_PNB", "NUM_SEQ_PNB", "QTD_UN_CONS_PNB",
                   "COD_INS_SEC_INS", "DES_PASSO_PNB"]
        return passos[[c for c in colunas if c in passos.columns]].drop_duplicates(
            subset=[COL_OS, "_OPER", "DTA_PASSO_PNB", "NUM_SEQ_PNB", "QTD_UN_CONS_PNB"]).reset_index(drop=True)

    @cached_property
    def primeiro_passo(self) -> pd.DataFrame:
        return self._passo_extremo(("INTERR", "ABRIR"), usar_max=False)

    @cached_property
    def ultimo_passo(self) -> pd.DataFrame:
        return self._passo_extremo(("FECHAR", "REESTAB"), usar_max=True)

    @cached_property
    def primeira_reclamacao(self) -> pd.DataFrame:
        """0_0/0_1: OS vinculada com a menor data de reclamação (empate: menor número)."""
        v = self.vinculada[self.vinculada["DTA_RECL_CNR"].notna()]
        datas = v.groupby(COL_OS)["DTA_RECL_CNR"].min().rename("_DATA").reset_index()
        cand = v.merge(datas, left_on=[COL_OS, "DTA_RECL_CNR"], right_on=[COL_OS, "_DATA"])
        return (cand.groupby([COL_OS, "DTA_RECL_CNR"])["NUM_SEQ_OPER_CNR"].min().reset_index())

    @cached_property
    def segunda_reclamacao(self) -> pd.DataFrame:
        """0_2/0_3: menor data entre as demais OS vinculadas (sem a primeira)."""
        prim = self.primeira_reclamacao[[COL_OS, "NUM_SEQ_OPER_CNR"]].assign(_PRIM=1)
        v = self.vinculada.merge(prim, on=[COL_OS, "NUM_SEQ_OPER_CNR"], how="left")
        v = v[v["_PRIM"].isna() & v["DTA_RECL_CNR"].notna()]
        datas = v.groupby(COL_OS)["DTA_RECL_CNR"].min().rename("_DATA").reset_index()
        cand = v.merge(datas, left_on=[COL_OS, "DTA_RECL_CNR"], right_on=[COL_OS, "_DATA"])
        return cand.groupby([COL_OS, "DTA_RECL_CNR"])["NUM_SEQ_OPER_CNR"].min().reset_index()

    @cached_property
    def ultima_reclamacao(self) -> pd.DataFrame:
        """11_7/11_8: maior data de reclamação; entre as OS dessa data, as que não são Vinc.contab."""
        v = self.vinculada[self.vinculada["DTA_RECL_CNR"].notna()]
        datas = v.groupby(COL_OS)["DTA_RECL_CNR"].max().rename("_DATA").reset_index()
        cand = v.merge(datas, left_on=[COL_OS, "DTA_RECL_CNR"], right_on=[COL_OS, "_DATA"])
        tipo = up(cand["TIPO_VINC"])
        cand = cand[tipo.notna() & (tipo != "VINC.CONTAB.")]
        return cand.groupby([COL_OS, "DTA_RECL_CNR", "TIPO_VINC"])["NUM_SEQ_OPER_CNR"].max().reset_index()

    @cached_property
    def qtd_vinculadas(self) -> pd.Series:
        return self.vinculada.groupby(COL_OS)["NUM_SEQ_OPER_CNR"].count()

    @cached_property
    def elementos_particulares(self) -> pd.Series:
        """10_0..10_2: nº de elementos particulares manobrados (AGRUP) por intervenção."""
        m = self.manobra
        cod = m["COD_INS_SEC_INS"].astype("string").str.strip()
        tipo = cod.str[:2]
        ele = up(m["COD_ELE_PNB"])
        filtro = (tipo.isin(["67", "22", "02", "56"]) & ele.isin(["TR", "CH"]) & m["_STATUS"].notna()
                  & (m["_STATUS"] != CANCELADO))
        sel = m[filtro].assign(_TIPO=tipo[filtro], _ELE=ele[filtro], _COD=cod[filtro])
        disjuntor = sel["_COD"].str[3:4].str.upper() == "R"
        sel = sel[~disjuntor.fillna(False)]
        conta = (sel["_TIPO"] != "56") | (sel["_ELE"] == "TR")
        sel = sel[conta]
        return sel.groupby(COL_OS)["_COD"].nunique()

    @cached_property
    def compensacao(self) -> pd.DataFrame:
        c = self.base.compensacao
        if c.empty or "NUM_SEQ_OPER_INIC_INTER_VDI" not in c:
            return pd.DataFrame(columns=[COL_OS, "MULTA_OS"])
        c = c[["NUM_SEQ_OPER_INIC_INTER_VDI", "MULTA_OS"]].copy()
        c[COL_OS] = c["NUM_SEQ_OPER_INIC_INTER_VDI"].astype(str)
        return c

    @cached_property
    def multa_por_os(self) -> pd.Series:
        return self.compensacao.groupby(COL_OS)["MULTA_OS"].max()

    @cached_property
    def intervencoes_retiradas(self) -> set[str]:
        """14_x: intervenções sem nenhum passo executado e sem OS vinculada (ficam fora da fila)."""
        m = self.manobra
        executados = set(m.loc[m["_STATUS"].notna() & (m["_STATUS"] != CANCELADO), COL_OS])
        com_vinculo = set(self.vinculada[COL_OS])
        return {o for o in self.intervencao[COL_OS] if o not in executados and o not in com_vinculo}
