"""Executa as regras sobre um lote e monta a fila de OS para análise."""
from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd

from ..dados import BaseOS
from . import individual, intervencao  # noqa: F401 - registram as regras
from .base import COL_OS, REGISTRO, Contexto, Regra, up

COLUNAS_RESUMO_INTERV = {
    "DTA_CMPT_MNB": "competencia",
    "COD_CAUSA_MNB": "cod_causa",
    "DES_CAUSA_INTER_CAU": "causa",
    "COD_SUB_CAUSA_MNB": "cod_subcausa",
    "DES_SUB_CAUSA_INTER_SCR": "subcausa",
    "COD_TIPO_CONCL_COS": "conclusao",
    "TMA": "tma",
    "DEC": "dec",
    "DTA_INIC_MNB": "inicio",
    "DTA_FIM_MNB": "fim",
    "COD_ELE_MNB": "elemento",
    "COD_INS_SEC_INS": "instalacao",
    "TIPO_TR": "tipo_tr",
    "COD_LOC_COS": "cod_localidade",
}
COLUNAS_RESUMO_IND = {
    "DTA_CMPT_MNB": "competencia",
    "COD_CAUSA_INTER_CNR": "cod_causa",
    "DES_CAUSA_INTER_CAU": "causa",
    "COD_SUB_CAUSA_INTER_CNR": "cod_subcausa",
    "DES_SUB_CAUSA_INTER_SCR": "subcausa",
    "COD_TIPO_CONCL_CNR": "conclusao",
    "TMA": "tma",
    "DEC": "dec",
    "DTA_RECL_CNR": "inicio",
    "DTA_FIM_CNR": "fim",
    "DES_LOC_CNR": "localidade",
}


@dataclass
class ResultadoRegras:
    flags: pd.DataFrame
    fila: pd.DataFrame
    erros: dict[str, str] = field(default_factory=dict)

    def contagem_por_regra(self) -> dict[str, int]:
        return self.flags.groupby("regra_id")[COL_OS].nunique().to_dict()


def executar(base: BaseOS, ids: list[str] | None = None) -> ResultadoRegras:
    ctx = Contexto(base)
    regras: list[Regra] = [r for r in REGISTRO.values() if ids is None or r.id in ids]
    partes, erros = [], {}
    for r in regras:
        try:
            df = r.funcao(ctx)
        except Exception as e:  # noqa: BLE001 - uma regra com erro não derruba as outras
            erros[r.id] = f"{type(e).__name__}: {e}"
            continue
        if len(df):
            partes.append(df.assign(regra_id=r.id, tipo_os=r.tipo_os))
    flags = (pd.concat(partes, ignore_index=True) if partes
             else pd.DataFrame(columns=[COL_OS, "valor", "evidencia", "regra_id", "tipo_os"]))
    return ResultadoRegras(flags=flags, fila=_montar_fila(ctx, flags), erros=erros)


def _entra_na_fila(regras_da_os: list[str]) -> bool:
    """Filtro final do Access: sai da fila quem não tem flag ou tem só uma flag "secundária"."""
    if not regras_da_os:
        return False
    if len(regras_da_os) >= 2:
        return True
    return REGISTRO[regras_da_os[0]].sozinha_basta


def _montar_fila(ctx: Contexto, flags: pd.DataFrame) -> pd.DataFrame:
    linhas = []
    loc = ctx.base.localidade
    mapa_local = dict(zip(loc.get("Cod Localidade", []), loc.get("Local", [])))
    mapa_coec = dict(zip(loc.get("Cod Localidade", []), loc.get("COEC", [])))
    mapa_coec_nome = dict(zip(up(loc["Local"]) if "Local" in loc else [], loc.get("COEC", [])))

    # Intervenções
    fi = flags[flags["tipo_os"] == "intervencao"]
    por_os = fi.groupby(COL_OS)["regra_id"].apply(lambda s: sorted(set(s))).to_dict()
    retiradas = ctx.intervencoes_retiradas
    interv = ctx.intervencao.drop_duplicates(COL_OS).set_index(COL_OS)
    vinc = ctx.qtd_vinculadas
    multa = ctx.multa_por_os
    for os_, regras_os in por_os.items():
        if os_ in retiradas or os_ not in interv.index or not _entra_na_fila(regras_os):
            continue
        linha = {"os": os_, "tipo_os": "intervencao", "regras": regras_os, "n_regras": len(regras_os)}
        reg = interv.loc[os_]
        for col, nome in COLUNAS_RESUMO_INTERV.items():
            linha[nome] = reg.get(col)
        linha["localidade"] = mapa_local.get(reg.get("COD_LOC_COS"), reg.get("LOCALIDADE"))
        linha["coec"] = mapa_coec.get(reg.get("COD_LOC_COS"))
        linha["qtd_vinculadas"] = int(vinc.get(os_, 0))
        linha["multa"] = multa.get(os_)
        linhas.append(linha)

    # Individuais
    fd = flags[flags["tipo_os"] == "individual"]
    if not fd.empty:
        ind = ctx.base.individual.copy()
        ind[COL_OS] = ind["NUM_SEQ_OPER_CNR"].astype(str)
        ind = ind.drop_duplicates(COL_OS).set_index(COL_OS)
        for os_, regras_os in fd.groupby(COL_OS)["regra_id"].apply(lambda s: sorted(set(s))).items():
            if os_ not in ind.index:
                continue
            reg = ind.loc[os_]
            linha = {"os": os_, "tipo_os": "individual", "regras": regras_os, "n_regras": len(regras_os)}
            for col, nome in COLUNAS_RESUMO_IND.items():
                linha[nome] = reg.get(col)
            linha["coec"] = mapa_coec_nome.get(str(reg.get("DES_LOC_CNR") or "").upper())
            linha["qtd_vinculadas"] = 0
            linha["multa"] = multa.get(os_)
            linhas.append(linha)

    fila = pd.DataFrame(linhas)
    if fila.empty:
        return fila
    for col in ("tma", "dec", "multa"):
        if col in fila:
            fila[col] = pd.to_numeric(fila[col], errors="coerce")
    fila = fila.replace({np.nan: None})
    return fila.sort_values(["multa", "n_regras"], ascending=[False, False], na_position="last").reset_index(drop=True)
