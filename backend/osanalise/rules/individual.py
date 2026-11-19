"""Regras das OS individuais (consulta "99 Individual Unificar Filtros")."""
from __future__ import annotations

import pandas as pd

from .base import COL_OS, Contexto, evidencias, regra, resultado, up


@regra(id="individual_grupo_a_ou_interv", nome="Individual procedente em cliente A ou com interrupção",
       descricao="OS individual procedente (000), subtipo diferente de INS, ainda sem correção, de cliente do "
                 "grupo A ou com o campo INTERV preenchido.",
       tipo_os="individual", coluna_access="Análise", correcao_tipica="alterar_conclusao",
       consulta_access="99 Individual Unificar Filtros")
def individual_grupo_a_ou_interv(ctx: Contexto) -> pd.DataFrame:
    ind = ctx.base.individual.copy()
    if ind.empty:
        return resultado(pd.Series([], dtype=str), "Verificar")
    ind[COL_OS] = ind["NUM_SEQ_OPER_CNR"].astype(str)
    subtipo = up(ind["COD_SUB_TIPO_OS_CNR"])
    sem_valor = pd.Series(False, index=ind.index)
    corrigida = ind["Correção Realizada"].notna() if "Correção Realizada" in ind else sem_valor
    base = ind[subtipo.notna() & (subtipo != "INS") & (ind["COD_TIPO_CONCL_CNR"] == "000") & ~corrigida]
    interv = base["INTERV"].notna() if "INTERV" in base else sem_valor.loc[base.index]
    marca = (up(base["COD_GRU_TENS_FAT_UEE"]) == "A") | interv
    sel = base[marca]
    locais = set(up(ctx.base.localidade["Local"]).dropna()) if "Local" in ctx.base.localidade else set()
    sel = sel[up(sel["DES_LOC_CNR"]).isin(locais)]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["COD_GRU_TENS_FAT_UEE", "INTERV", "COD_TIPO_CONCL_CNR",
                                                                 "DES_CAUSA_INTER_CAU", "DES_SUB_CAUSA_INTER_SCR"]))
