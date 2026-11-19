"""Catálogo de correções que o app sabe propor e que o robô do TS vai executar (fase 2)."""
from __future__ import annotations

TIPOS_CORRECAO: dict[str, dict] = {
    "alterar_conclusao": {
        "nome": "Alterar conclusão (procedente/improcedente)",
        "campos": ["COD_TIPO_CONCL_COS"],
        "valores": {"000": "procedente", "004": "improcedente"},
        "categoria_access": "classificacao",
    },
    "alterar_causa_subcausa": {
        "nome": "Alterar causa/subcausa",
        "campos": ["COD_CAUSA_MNB", "COD_SUB_CAUSA_MNB"],
        "categoria_access": "classificacao",
    },
    "alterar_status_passo": {
        "nome": "Alterar operação do passo de manobra (ex.: ABRIR para INTERR)",
        "campos": ["COD_OPER_PNB"],
        "alvo": "NUM_SEQ_PNB do passo",
        "categoria_access": "passo_manobra",
    },
    "ajustar_ucs": {
        "nome": "Ajustar clientes interrompidos do passo",
        "campos": ["QTD_UN_CONS_PNB"],
        "alvo": "NUM_SEQ_PNB do passo",
        "categoria_access": "passo_manobra",
    },
    "vincular_os": {
        "nome": "Vincular OS individual à intervenção",
        "campos": ["NUM_SEQ_OPER_INTER_CNR"],
        "alvo": "número da OS individual",
        "categoria_access": "os_vinculada",
    },
    "desvincular_os": {
        "nome": "Desvincular OS individual da intervenção",
        "campos": ["NUM_SEQ_OPER_INTER_CNR"],
        "alvo": "número da OS individual",
        "categoria_access": "os_vinculada",
    },
    "ajustar_data_hora": {
        "nome": "Ajustar data/hora",
        "campos": ["DTA_INIC_MNB", "DTA_FIM_MNB", "DTA_DLCT_EQP_MNB", "DTA_VERI_EQP_MNB", "DTA_SERV_EQP_MNB",
                   "DTA_PASSO_PNB"],
        "formato": "dd/mm/aaaa hh:mm",
        "categoria_access": "horario",
    },
    "alterar_elemento_origem": {
        "nome": "Alterar elemento de origem",
        "campos": ["COD_ELE_MNB", "COD_INS_SEC_INS"],
        "categoria_access": "elemento_origem",
    },
}

CATEGORIA_PARA_TIPOS: dict[str, list[str]] = {}
for _tipo, _def in TIPOS_CORRECAO.items():
    CATEGORIA_PARA_TIPOS.setdefault(_def["categoria_access"], []).append(_tipo)
