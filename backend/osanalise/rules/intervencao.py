"""Regras das OS de intervenção, portadas das consultas do Banco de Análise.

Cada função devolve as OS marcadas (coluna `os`), o valor da marcação (como no Access:
"Verificar", "Verificar Abrir", "Dif Man e Pass"...) e a evidência usada.
"""
from __future__ import annotations

import numpy as np
import pandas as pd

from .base import COL_OS, Contexto, evidencias, regra, resultado, up

SUBCAUSAS_IMPROCEDENTES = ["MV", "EY", "CB", "KI", "KG", "KF", "KK", "KH", "KE", "KJ"]
CAUSAS_TRAFO_QUEIMADO = [
    "TRANSFORMADOR-QUEIMADO POR SOBRECARGA",
    "TRANSFORMADOR-QUEIMADO POR DESCARGA ATMOSFERICA",
    "TRANSFORMADOR-QUEIMADO POR PASSARO/ANIMAL",
    "TRANSFORMADOR-QUEIMADO POR CURTO NA RD",
    "TRANSFORMADOR-QUEIMADO POR CAUSA NAO IDENTIFICADA",
]
EV_INTERV = ["COD_CAUSA_MNB", "DES_CAUSA_INTER_CAU", "COD_SUB_CAUSA_MNB", "DES_SUB_CAUSA_INTER_SCR",
             "COD_TIPO_CONCL_COS"]


_EPOCA_ACCESS = pd.Timestamp("1899-12-30")


def _dias_access(s: pd.Series) -> pd.Series:
    """Data como o Access guarda: nº de dias desde 30/12/1899 em ponto flutuante (double)."""
    dias = (s.dt.normalize() - _EPOCA_ACCESS).dt.days.astype(float)
    fracao = (s - s.dt.normalize()).dt.total_seconds() / 86400.0
    return dias + fracao


def _minutos(a: pd.Series, b: pd.Series) -> pd.Series:
    """([a]-[b])*1440 com a mesma aritmética de ponto flutuante do Access.

    Importa nos limites: 120 min exatos viram -120,0000000035 e entram em "< -120", como lá.
    """
    return (_dias_access(a) - _dias_access(b)) * 1440.0


# ------------------------------------------------------------------ cadastro
@regra(id="tr_proprio_os_proc", nome="TR próprio com OS procedente",
       descricao="Intervenção em transformador próprio (TIPO_TR = PRÓPRIO) concluída como procedente (000).",
       tipo_os="intervencao", coluna_access="TR_Próprio_OS_Proc", correcao_tipica="alterar_conclusao",
       consulta_access="2_0 TR Próprio Intv Proced")
def tr_proprio_os_proc(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sel = i[(up(i["TIPO_TR"]) == "PRÓPRIO") & (i["COD_TIPO_CONCL_COS"] == "000")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["TIPO_TR", "COD_TIPO_CONCL_COS"]))


@regra(id="intev_impro_causa_proc", nome="OS improcedente com causa procedente",
       descricao="Conclusão 004 (improcedente), causa diferente de IM e subcausa fora da lista de improcedentes.",
       tipo_os="intervencao", coluna_access="Intev_Impro_Causa_Proc", correcao_tipica="alterar_conclusao",
       consulta_access="2_1 Intev Impro Causa Pro")
def intev_impro_causa_proc(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sub, causa = up(i["COD_SUB_CAUSA_MNB"]), up(i["COD_CAUSA_MNB"])
    sel = i[sub.notna() & ~sub.isin(SUBCAUSAS_IMPROCEDENTES) & (i["COD_TIPO_CONCL_COS"] == "004")
            & causa.notna() & (causa != "IM")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, EV_INTERV))


@regra(id="intev_proc_causa_impro", nome="OS procedente com causa improcedente",
       descricao="Conclusão 000 (procedente), causa IM e subcausa da lista de improcedentes.",
       tipo_os="intervencao", coluna_access="Intev_Proc_Causa_Impro", correcao_tipica="alterar_conclusao",
       consulta_access="2_2 Intev Pro Causa Impro")
def intev_proc_causa_impro(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sub, causa = up(i["COD_SUB_CAUSA_MNB"]), up(i["COD_CAUSA_MNB"])
    sel = i[sub.isin(SUBCAUSAS_IMPROCEDENTES) & (i["COD_TIPO_CONCL_COS"] == "000") & (causa == "IM")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, EV_INTERV))


@regra(id="dec_maior_0001", nome="DEC ≥ 0,001",
       descricao="Intervenção com DEC maior ou igual a 0,001.",
       tipo_os="intervencao", coluna_access="DEC_>_0,001", consulta_access="2_3 dec >= 0,001")
def dec_maior_0001(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sel = i[i["DEC"] >= 0.001]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DEC", "FEC"]))


@regra(id="tmd_0", nome="OS procedente com TMD = 0",
       descricao="Data de deslocamento igual à data de verificação, com conclusão 000.",
       tipo_os="intervencao", coluna_access="TMD_0", correcao_tipica="ajustar_data_hora",
       consulta_access="2_5 TMD = 0 Análise")
def tmd_0(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sel = i[(i["DTA_DLCT_EQP_MNB"] == i["DTA_VERI_EQP_MNB"]) & i["DTA_DLCT_EQP_MNB"].notna()
            & (i["COD_TIPO_CONCL_COS"] == "000")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_DLCT_EQP_MNB", "DTA_VERI_EQP_MNB"]))


@regra(id="tma_maior_1440", nome="TMA > 1.440",
       descricao="TMA acima de 1.440 minutos, exceto causas de transformador queimado.",
       tipo_os="intervencao", coluna_access="TMA_>_1440", correcao_tipica="ajustar_data_hora",
       consulta_access="3_0 TMA Filtro > 1440")
def tma_maior_1440(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    causa = up(i["DES_CAUSA_INTER_CAU"]).fillna("") + "-" + up(i["DES_SUB_CAUSA_INTER_SCR"]).fillna("")
    sel = i[(i["TMA"] > 1440) & ~causa.isin(CAUSAS_TRAFO_QUEIMADO)]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["TMA", "DTA_INIC_MNB", "DTA_FIM_MNB",
                                                                 "DES_CAUSA_INTER_CAU", "DES_SUB_CAUSA_INTER_SCR"]))


@regra(id="comp_maior_500", nome="Compensação alta",
       descricao="Compensação da ocorrência (MULTA_OS) de R$ 1.000 ou mais. O nome no Access é "
                 "'Comp > 500', mas a consulta filtra MULTA_OS ≥ 1.000.",
       tipo_os="intervencao", coluna_access="Comp_>_500", consulta_access="2_6 Comp > R$ 1000")
def comp_maior_500(ctx: Contexto) -> pd.DataFrame:
    c = ctx.compensacao
    sel = c[c["MULTA_OS"] >= 1000]
    sel = sel[sel[COL_OS].isin(set(ctx.intervencao[COL_OS]))]
    sel = sel.sort_values("MULTA_OS", ascending=False).drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["MULTA_OS"]))


@regra(id="dif_1a_2a_rcm", nome="1ª e 2ª reclamação distantes",
       descricao="Mais de 180 min entre a 1ª e a 2ª OS vinculadas, em intervenção com 10 ou mais clientes "
                 "nos passos de abrir/interromper. O nome no Access fala em 1 h, mas a consulta usa 180 min.",
       tipo_os="intervencao", coluna_access="DIF_1ª_2ª_RCM_1h", sozinha_basta=False,
       correcao_tipica="vincular_os", consulta_access="0_7 Calc Diferença Tempo OS Filtro")
def dif_1a_2a_rcm(ctx: Contexto) -> pd.DataFrame:
    m = ctx.manobra
    soma = (m[m["_OPER"].isin(["ABRIR", "INTERR"])].groupby([COL_OS, "_OPER"])["QTD_UN_CONS_PNB"]
            .sum(min_count=1).reset_index())
    com_clientes = set(soma.loc[soma["QTD_UN_CONS_PNB"] >= 10, COL_OS])
    p1 = ctx.primeira_reclamacao.rename(columns={"DTA_RECL_CNR": "DTA_1", "NUM_SEQ_OPER_CNR": "OS_1"})
    p2 = ctx.segunda_reclamacao.rename(columns={"DTA_RECL_CNR": "DTA_2", "NUM_SEQ_OPER_CNR": "OS_2"})
    cruz = p1.merge(p2, on=COL_OS, how="left")
    cruz = cruz[cruz[COL_OS].isin(com_clientes)]
    cruz["TEMPO_MIN"] = _minutos(cruz["DTA_2"], cruz["DTA_1"])
    sel = cruz[cruz["TEMPO_MIN"] > 180]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["OS_1", "DTA_1", "OS_2", "DTA_2", "TEMPO_MIN"]))


@regra(id="dif_1a_man_1a_os_vinc", nome="1º passo x 1ª OS vinculada",
       descricao="1º passo é ABRIR e a 1ª reclamação é anterior a ele, ou é INTERR e a 1ª reclamação "
                 "veio mais de 2 h antes.",
       tipo_os="intervencao", coluna_access="DIF_1ª_Man_1ª_OS_Vinc_2h", correcao_tipica="alterar_status_passo",
       consulta_access="1_8 1º Manobra x 1º OS Vinc Filtro")
def dif_1a_man_1a_os_vinc(ctx: Contexto) -> pd.DataFrame:
    p = ctx.primeiro_passo.merge(ctx.primeira_reclamacao, on=COL_OS)
    tempo = _minutos(p["DTA_RECL_CNR"], p["DTA_PASSO_PNB"])
    abrir = p["_OPER"] == "ABRIR"
    tempo = tempo.where(abrir | ~(p["DTA_RECL_CNR"] > p["DTA_PASSO_PNB"]), 0.0)
    p = p.assign(TEMPO_MIN=tempo)
    valor = np.where(abrir & (tempo < 0), "Verificar Abrir",
                     np.where(~abrir & (tempo < -120), "Verificar Interr", ""))
    p = p.assign(_V=valor)
    sel = p[p["_V"] != ""].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], sel["_V"], evidencias(sel, ["COD_OPER_PNB", "DTA_PASSO_PNB", "QTD_UN_CONS_PNB",
                                                               "NUM_SEQ_OPER_CNR", "DTA_RECL_CNR", "TEMPO_MIN"]))


def _primeiro_passo_x_inicio(ctx: Contexto) -> pd.DataFrame:
    p = ctx.primeiro_passo.merge(ctx.intervencao[[COL_OS, "DTA_INIC_MNB"]], on=COL_OS)
    dif = _minutos(p["DTA_PASSO_PNB"], p["DTA_INIC_MNB"])
    return p.assign(DIFERENCA_MIN=np.round(dif))


@regra(id="tempo_inicio_1o_passo_1min", nome="Início x 1º passo = 1 min",
       descricao="1º passo de abrir/interromper exatamente 1 min depois da data de início da intervenção.",
       tipo_os="intervencao", coluna_access="Tempo_Hr_Inic_Hr_1º_Passo_=_1_min", sozinha_basta=False,
       correcao_tipica="ajustar_data_hora", consulta_access="5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro")
def tempo_inicio_1o_passo_1min(ctx: Contexto) -> pd.DataFrame:
    p = _primeiro_passo_x_inicio(ctx)
    sel = p[p["DIFERENCA_MIN"] == 1].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_INIC_MNB", "DTA_PASSO_PNB", "DIFERENCA_MIN"]))


@regra(id="tempo_inicio_1o_passo_6h", nome="Início x 1º passo > 6 h",
       descricao="1º passo de abrir/interromper mais de 6 h depois da data de início da intervenção.",
       tipo_os="intervencao", coluna_access="Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr", sozinha_basta=False,
       correcao_tipica="ajustar_data_hora", consulta_access="5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro")
def tempo_inicio_1o_passo_6h(ctx: Contexto) -> pd.DataFrame:
    p = _primeiro_passo_x_inicio(ctx)
    sel = p[p["DIFERENCA_MIN"] > 360].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_INIC_MNB", "DTA_PASSO_PNB", "DIFERENCA_MIN"]))


@regra(id="dif_1o_passo_1a_os_inicio", nome="Início x 1º passo x 1ª OS",
       descricao="1º passo é INTERR e início da intervenção, 1º passo e 1ª reclamação não coincidem: "
                 "início diferente do passo (Dif Man e Pass) ou reclamação a mais de 2 h do passo.",
       tipo_os="intervencao", coluna_access="Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio", sozinha_basta=False,
       correcao_tipica="ajustar_data_hora", consulta_access="1_17 Análise Datas Retirar entre 2h - Final")
def dif_1o_passo_1a_os_inicio(ctx: Contexto) -> pd.DataFrame:
    p = ctx.primeiro_passo[ctx.primeiro_passo["_OPER"] == "INTERR"]
    p = p.merge(ctx.primeira_reclamacao, on=COL_OS).merge(ctx.intervencao[[COL_OS, "DTA_INIC_MNB"]], on=COL_OS)
    iguais = (p["DTA_INIC_MNB"] == p["DTA_PASSO_PNB"]) & (p["DTA_PASSO_PNB"] == p["DTA_RECL_CNR"])
    p = p[~iguais]
    um_min = set(tempo_inicio_1o_passo_1min(ctx)[COL_OS])
    p = p[~p[COL_OS].isin(um_min)]
    dif_passo = _minutos(p["DTA_RECL_CNR"], p["DTA_PASSO_PNB"])
    valor = np.where(p["DTA_INIC_MNB"] != p["DTA_PASSO_PNB"], "Dif Man e Pass",
                     np.where(dif_passo < -120, "Dif Pass OS", np.where(dif_passo > 120, "Dif Passo OS", "")))
    p = p.assign(_V=valor, DIF_RECL_PASSO_MIN=dif_passo)
    sel = p[p["_V"] != ""].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], sel["_V"], evidencias(sel, ["DTA_INIC_MNB", "DTA_PASSO_PNB", "DTA_RECL_CNR",
                                                               "DIF_RECL_PASSO_MIN"]))


@regra(id="intev_0_ucs_inter", nome="Clientes interrompidos vazio",
       descricao="1º passo de abrir/interromper sem quantidade de clientes (UCs) interrompidos.",
       tipo_os="intervencao", coluna_access="Intev_0_UCs_Inter", correcao_tipica="alterar_status_passo",
       consulta_access="8_7 Filtro Passo Válido Filtro")
def intev_0_ucs_inter(ctx: Contexto) -> pd.DataFrame:
    p = ctx.primeiro_passo
    sel = p[p["QTD_UN_CONS_PNB"].isna()].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["COD_OPER_PNB", "DTA_PASSO_PNB", "NUM_SEQ_PNB",
                                                                 "COD_INS_SEC_INS"]))


@regra(id="os_vinc_ucs_interr", nome="Clientes interrompidos < OSs vinculadas",
       descricao="Quantidade de clientes do 1º passo menor que o nº de OS vinculadas de um mesmo tipo (exceto AN).",
       tipo_os="intervencao", coluna_access="OS_Vinc_UCs_Interr", correcao_tipica="vincular_os",
       consulta_access="9_9_1 Análise OS > UCs Interr Filtro")
def os_vinc_ucs_interr(ctx: Contexto) -> pd.DataFrame:
    v = ctx.vinculada
    tipo = up(v["COD_TIPO_OS_CNR"])
    contagem = (v[tipo.notna() & (tipo != "AN")].groupby([COL_OS, "COD_TIPO_OS_CNR"])["NUM_SEQ_OPER_CNR"]
                .count().rename("QTD_OS_VINC").reset_index())
    p = ctx.primeiro_passo.merge(contagem, on=COL_OS)
    sel = p[p["QTD_UN_CONS_PNB"] < p["QTD_OS_VINC"]].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_PASSO_PNB", "QTD_UN_CONS_PNB",
                                                                 "COD_TIPO_OS_CNR", "QTD_OS_VINC"]))


def _primeiro_passo_interr_com_vinculadas(ctx: Contexto) -> pd.DataFrame:
    p = ctx.primeiro_passo[ctx.primeiro_passo["_OPER"] == "INTERR"]
    return p.merge(ctx.qtd_vinculadas.rename("QTD_OS_VINC"), left_on=COL_OS, right_index=True, how="left")


@regra(id="intev_menos_3_os_vinc_mais_50_ucs", nome="> 40 clientes e < 3 OS vinculadas",
       descricao="1º passo INTERR com mais de 40 clientes e no máximo 2 OS vinculadas.",
       tipo_os="intervencao", coluna_access="Intev_<_3_OS_Vinc_>_50_UCs", correcao_tipica="vincular_os",
       consulta_access="4_9_1 Intev < 3 OS Vinc > 80 UCs",
       divergencia_access="No Access a consulta 4_4 lê a coluna QTD_UN_CONS_PNB, que foi renomeada na "
                          "tabela 1 Tabela_Manobra; a quantidade fica vazia e a regra nunca marca nada.")
def intev_menos_3_os_vinc_mais_50_ucs(ctx: Contexto) -> pd.DataFrame:
    p = _primeiro_passo_interr_com_vinculadas(ctx)
    sel = p[(p["QTD_UN_CONS_PNB"] > 40) & (p["QTD_OS_VINC"] <= 2)].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_PASSO_PNB", "QTD_UN_CONS_PNB", "QTD_OS_VINC"]))


@regra(id="intev_sem_os_vinc", nome="Intervenção sem OS vinculada",
       descricao="1º passo INTERR com clientes interrompidos e nenhuma OS vinculada.",
       tipo_os="intervencao", coluna_access="Intev_S_OS_Vinc", correcao_tipica="vincular_os",
       consulta_access="4_9_3 Intev S OS Vinc > 80 UCs Filtro",
       divergencia_access="Mesma falha da regra anterior no Access (coluna QTD_UN_CONS_PNB renomeada): "
                          "nunca marca nada lá.")
def intev_sem_os_vinc(ctx: Contexto) -> pd.DataFrame:
    p = _primeiro_passo_interr_com_vinculadas(ctx)
    sel = p[(p["QTD_UN_CONS_PNB"] > 0) & p["QTD_OS_VINC"].isna()].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["DTA_PASSO_PNB", "QTD_UN_CONS_PNB"]))


@regra(id="os_elemen_particular_proc", nome="Manobra em elemento particular com OS procedente",
       descricao="Manobra em elemento particular (instalação 67, 22, 02 ou 56 em TR/CH, sem disjuntor) "
                 "e conclusão 000.",
       tipo_os="intervencao", coluna_access="OS_Elemen_Particular_Proc", correcao_tipica="alterar_conclusao",
       consulta_access="10_3 Man Com Elem Partic")
def os_elemen_particular_proc(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao.merge(ctx.elementos_particulares.rename("ELEMENTOS_PARTICULARES"),
                              left_on=COL_OS, right_index=True)
    sel = i[(i["ELEMENTOS_PARTICULARES"] > 0) & (i["COD_TIPO_CONCL_COS"] == "000")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["ELEMENTOS_PARTICULARES", "COD_TIPO_CONCL_COS"]))


@regra(id="os_impro_sem_elem_partic", nome="OS improcedente sem elemento particular",
       descricao="Conclusão 004 sem nenhuma manobra em elemento particular.",
       tipo_os="intervencao", coluna_access="OS_Impro_Sem_Elem_Partic", correcao_tipica="alterar_conclusao",
       consulta_access="12_0 Ocorrência Sem GA - Impro")
def os_impro_sem_elem_partic(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sem = ~i[COL_OS].isin(set(ctx.elementos_particulares.index))
    sel = i[sem & (i["COD_TIPO_CONCL_COS"] == "004")]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, EV_INTERV))


@regra(id="os_vinc_hr_maior_ult_passo", nome="Última OS depois do último passo",
       descricao="Última reclamação vinculada (exceto Vinc.contab.) posterior ao último passo de "
                 "fechar/reestabelecer.",
       tipo_os="intervencao", coluna_access="OS_Vinc_Hr_>_Ult_Passo", correcao_tipica="vincular_os",
       consulta_access="11_10 Cruzamento Último Passo x Última OS - Filtro")
def os_vinc_hr_maior_ult_passo(ctx: Contexto) -> pd.DataFrame:
    p = ctx.ultimo_passo.merge(ctx.ultima_reclamacao, on=COL_OS)
    sel = p[p["DTA_RECL_CNR"] > p["DTA_PASSO_PNB"]].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["COD_OPER_PNB", "DTA_PASSO_PNB",
                                                                 "NUM_SEQ_OPER_CNR", "DTA_RECL_CNR", "TIPO_VINC"]))


@regra(id="intv_tr_zona_div_uc", nome="Zona do TR diferente da zona da UC",
       descricao="Intervenção em TR cuja zona (urbana/rural) difere da zona de alguma OS vinculada.",
       tipo_os="intervencao", coluna_access="Intv_TR_Zona_Div_UC", correcao_tipica="vincular_os",
       consulta_access="17_5 Zona_TR_Dif_Zona_UC_Final")
def intv_tr_zona_div_uc(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    tr = i[up(i["COD_ELE_MNB"]) == "TR"][[COL_OS, "ZONA"]].rename(columns={"ZONA": "ZONA_TR"})
    v = ctx.vinculada
    zona_uc = np.where(up(v["DES_BAI_CNR"]) == "RURAL", "RR", v["ZONA"].astype(object))
    v = v.assign(ZONA_UC=zona_uc)[[COL_OS, "NUM_SEQ_OPER_CNR", "ZONA_UC", "DES_BAI_CNR"]]
    cruz = tr.merge(v, on=COL_OS)
    a, b = up(cruz["ZONA_TR"]), up(cruz["ZONA_UC"])
    diverge = ~((a == b).fillna(False))
    sel = cruz[diverge].drop_duplicates(COL_OS)
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["ZONA_TR", "NUM_SEQ_OPER_CNR", "ZONA_UC"]))


@regra(id="os_externa", nome="Intervenção de origem externa",
       descricao="Tipo de origem da intervenção = EX (externa).",
       tipo_os="intervencao", coluna_access="OS_Externa", correcao_tipica="alterar_conclusao",
       consulta_access="16_0_1 Int_Classi_Externo")
def os_externa(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    sel = i[up(i["COD_TIPO_ORIG_INTV_MNB"]) == "EX"]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, ["COD_TIPO_ORIG_INTV_MNB", "DES_ORIG_OGE"]))


@regra(id="os_acessante", nome="UC acessante",
       descricao="Intervenção com o campo de acessante preenchido (coluna INTERV da crítica).",
       tipo_os="intervencao", coluna_access="OS_Acessante", consulta_access="15_0_1 UC_Acessante")
def os_acessante(ctx: Contexto) -> pd.DataFrame:
    i = ctx.intervencao
    col = "COELBA" if "COELBA" in i else None
    if col is None:
        return resultado(pd.Series([], dtype=str), "Verificar")
    sel = i[i[col].notna()]
    return resultado(sel[COL_OS], "Verificar", evidencias(sel, [col]))
