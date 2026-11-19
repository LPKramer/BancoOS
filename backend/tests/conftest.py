from __future__ import annotations

import pandas as pd
import pytest

from osanalise.dados import BaseOS, normalizar

OS_A = "20260000000001"
OS_B = "20260000000002"


def intervencao(**extra):
    linha = {
        "DTA_CMPT_MNB": "2026-10-01 00:00:00", "DTA_INIC_MNB": "2026-10-10 10:00:00",
        "DTA_AVI_EQP_MNB": "2026-10-10 10:00:00", "DTA_DLCT_EQP_MNB": "2026-10-10 10:10:00",
        "DTA_VERI_EQP_MNB": "2026-10-10 10:20:00", "DTA_SERV_EQP_MNB": "2026-10-10 10:30:00",
        "DTA_FIM_MNB": "2026-10-10 12:00:00", "TMA": 100, "TIPO_OS": "INTERVENÇÃO", "COD_CPU_OS_MNB": "05",
        "NUM_SEQ_OPER_OS_MNB": OS_A, "COD_TIPO_ORIG_INTV_MNB": "PR", "COD_CAUSA_MNB": "CE",
        "DES_CAUSA_INTER_CAU": "DISTRIBUICAO PROGRAMADA", "COD_SUB_CAUSA_MNB": "MP",
        "DES_SUB_CAUSA_INTER_SCR": "MANUTENCAO", "DES_INTV_MNB": "teste", "COD_ELE_MNB": "CH",
        "COD_INS_SEC_INS": "8800000001", "COD_TIPO_CONCL_COS": "000", "TIPO_TR": "ENERGISA", "DEC": "0,0001",
        "FEC": "0", "COD_LOC_COS": "0233", "LOCALIDADE": "ABREULANDIA", "ZONA": "UB", "COELBA": None,
    }
    linha.update(extra)
    return linha


def passo(os_=OS_A, data="2026-10-10 10:00:00", seq=1, oper="INTERR", qtd=10.0, status="Executado", **extra):
    linha = {"DTA_PASSO_PNB": data, "NUM_SEQ_OPER_OS_PNB": os_, "NUM_SEQ_PNB": seq, "NUM_PASSO_PNB": seq,
             "COD_OPER_PNB": oper, "STA_EXEC_PNB": status, "QTD_UN_CONS_PNB": qtd, "COD_ELE_PNB": "CH",
             "COD_INS_SEC_INS": "8800000001", "TIPO_OS": "PASSO_MANOBRA", "DES_PASSO_PNB": ""}
    linha.update(extra)
    return linha


def vinculada(os_inter=OS_A, os_ind="20260000000101", recl="2026-10-10 10:00:00", tipo="QF", **extra):
    linha = {"NUM_SEQ_OPER_INTER_CNR": os_inter, "NUM_SEQ_OPER_CNR": os_ind, "DTA_RECL_CNR": recl,
             "COD_TIPO_OS_CNR": tipo, "TIPO_VINC": "Vinc.interv.", "DES_BAI_CNR": "CENTRO", "ZONA": "UB",
             "COD_INS_TRF_INT": "5700000001", "DTA_FIM_CNR": "2026-10-10 12:00:00"}
    linha.update(extra)
    return linha


def montar_base(interv: list[dict], passos: list[dict] | None = None, vinc: list[dict] | None = None,
                comp: list[dict] | None = None) -> BaseOS:
    def df(linhas, colunas=None):
        return pd.DataFrame(linhas) if linhas else pd.DataFrame(columns=colunas or [])

    return BaseOS(
        intervencao=normalizar("intervencao", df(interv)),
        manobra=normalizar("manobra", df(passos or [], ["NUM_SEQ_OPER_OS_PNB", "DTA_PASSO_PNB", "NUM_SEQ_PNB",
                                                         "COD_OPER_PNB", "STA_EXEC_PNB", "QTD_UN_CONS_PNB",
                                                         "COD_INS_SEC_INS", "COD_ELE_PNB"])),
        vinculada=normalizar("vinculada", df(vinc or [], ["NUM_SEQ_OPER_INTER_CNR", "NUM_SEQ_OPER_CNR",
                                                          "DTA_RECL_CNR", "COD_TIPO_OS_CNR", "TIPO_VINC",
                                                          "DES_BAI_CNR", "ZONA"])),
        equipe=normalizar("equipe", df([], ["NUM_SEQ_OPER_OS_MNB"])),
        individual=normalizar("individual", df([], ["NUM_SEQ_OPER_CNR", "COD_SUB_TIPO_OS_CNR",
                                                    "COD_TIPO_CONCL_CNR", "COD_GRU_TENS_FAT_UEE", "DES_LOC_CNR"])),
        compensacao=normalizar("compensacao", df(comp or [], ["NUM_SEQ_OPER_INIC_INTER_VDI", "MULTA_OS"])),
        localidade=normalizar("localidade", pd.DataFrame([{"Cod Localidade": "0233", "Local": "ABREULANDIA",
                                                           "COEC": "CENTRO"}])),
        competencia="2026-10",
    )


@pytest.fixture
def banco_temporario(tmp_path):
    from osanalise import db

    db.configurar(tmp_path / "teste.db")
    yield tmp_path
