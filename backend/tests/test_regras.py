"""Semântica das regras portadas do Access (com dados sintéticos)."""
from __future__ import annotations

from conftest import OS_A, OS_B, intervencao, montar_base, passo, vinculada

from osanalise.rules.base import Contexto
from osanalise.rules.motor import executar


def regras_de(base, os_=OS_A) -> set[str]:
    r = executar(base)
    return set(r.flags.loc[r.flags["os"] == os_, "regra_id"])


def test_primeiro_passo_ignora_cancelado_e_desempata_pela_sequencia():
    base = montar_base([intervencao()], [
        passo(data="2026-10-10 09:00:00", seq=1, status="Passo Cancelado", qtd=1),
        passo(data="2026-10-10 10:00:00", seq=5, oper="ABRIR", qtd=7),
        passo(data="2026-10-10 10:00:00", seq=3, oper="INTERR", qtd=9),
        passo(data="2026-10-10 11:00:00", seq=2, oper="FECHAR", qtd=None),
    ])
    p = Contexto(base).primeiro_passo
    assert len(p) == 1
    assert p.iloc[0]["NUM_SEQ_PNB"] == 3 and p.iloc[0]["QTD_UN_CONS_PNB"] == 9


def test_clientes_vazio_no_primeiro_passo():
    base = montar_base([intervencao()], [passo(qtd=None)], [vinculada()])
    assert "intev_0_ucs_inter" in regras_de(base)
    base_ok = montar_base([intervencao()], [passo(qtd=5)], [vinculada()])
    assert "intev_0_ucs_inter" not in regras_de(base_ok)


def test_reclamacao_120_min_antes_do_interr_marca_como_no_access():
    """No Access ([R]-[P])*1440 em ponto flutuante dá -120,0000000035 e entra em '< -120'."""
    base = montar_base([intervencao()], [passo(data="2026-10-10 15:52:00")],
                       [vinculada(recl="2026-10-10 13:52:00")])
    assert "dif_1a_man_1a_os_vinc" in regras_de(base)
    base_119 = montar_base([intervencao()], [passo(data="2026-10-10 15:51:00")],
                           [vinculada(recl="2026-10-10 13:52:00")])
    assert "dif_1a_man_1a_os_vinc" not in regras_de(base_119)


def test_abrir_com_reclamacao_anterior():
    base = montar_base([intervencao()], [passo(oper="ABRIR", data="2026-10-10 10:00:00")],
                       [vinculada(recl="2026-10-10 09:59:00")])
    r = executar(base)
    v = r.flags[(r.flags["os"] == OS_A) & (r.flags["regra_id"] == "dif_1a_man_1a_os_vinc")]["valor"].tolist()
    assert v == ["Verificar Abrir"]


def test_conclusao_e_causa():
    proc_impro = intervencao(COD_CAUSA_MNB="IM", COD_SUB_CAUSA_MNB="CB", COD_TIPO_CONCL_COS="000")
    impro_proc = intervencao(NUM_SEQ_OPER_OS_MNB=OS_B, COD_CAUSA_MNB="CE", COD_SUB_CAUSA_MNB="MP",
                             COD_TIPO_CONCL_COS="004")
    base = montar_base([proc_impro, impro_proc], [passo(), passo(os_=OS_B)], [vinculada(), vinculada(os_inter=OS_B)])
    assert "intev_proc_causa_impro" in regras_de(base, OS_A)
    assert "intev_impro_causa_proc" in regras_de(base, OS_B)


def test_tr_proprio_tma_dec_e_comp():
    base = montar_base([intervencao(TIPO_TR="PRÓPRIO", TMA=1500, DEC="0,002")], [passo()], [vinculada()],
                       comp=[{"NUM_SEQ_OPER_INIC_INTER_VDI": OS_A, "MULTA_OS": 999.0}])
    regras = regras_de(base)
    assert {"tr_proprio_os_proc", "tma_maior_1440", "dec_maior_0001"} <= regras
    assert "comp_maior_500" not in regras  # a consulta do Access exige MULTA_OS >= 1000
    base2 = montar_base([intervencao()], [passo()], [vinculada()],
                        comp=[{"NUM_SEQ_OPER_INIC_INTER_VDI": OS_A, "MULTA_OS": 1000.0}])
    assert "comp_maior_500" in regras_de(base2)


def test_tma_de_trafo_queimado_nao_marca():
    base = montar_base([intervencao(TMA=2000, DES_CAUSA_INTER_CAU="TRANSFORMADOR",
                                    DES_SUB_CAUSA_INTER_SCR="QUEIMADO POR SOBRECARGA")], [passo()], [vinculada()])
    assert "tma_maior_1440" not in regras_de(base)


def test_fila_exclui_quem_so_tem_uma_regra_fraca():
    # Tempo início x 1º passo = 1 min é "sinal fraco": sozinho não entra na fila
    base = montar_base([intervencao(DTA_INIC_MNB="2026-10-10 09:59:00")], [passo()], [vinculada()])
    r = executar(base)
    assert set(r.flags["regra_id"]) == {"tempo_inicio_1o_passo_1min"}
    assert r.fila.empty


def test_fila_inclui_duas_regras_fracas():
    # 1 min entre início e 1º passo + 1ª e 2ª reclamação a 210 min (com 10 clientes): duas regras fracas
    base = montar_base([intervencao(DTA_INIC_MNB="2026-10-10 09:59:00")],
                       [passo(data="2026-10-10 10:00:00")],
                       [vinculada(recl="2026-10-10 10:30:00"), vinculada(os_ind="20260000000102",
                                                                         recl="2026-10-10 14:00:00")])
    r = executar(base)
    assert set(r.flags["regra_id"]) == {"tempo_inicio_1o_passo_1min", "dif_1a_2a_rcm"}
    assert len(r.fila) == 1


def test_dif_1o_passo_nao_marca_quando_ja_tem_1_min():
    """Consulta 1_14: a regra exclui as OS já marcadas por 'Início x 1º passo = 1 min'."""
    base = montar_base([intervencao(DTA_INIC_MNB="2026-10-10 09:59:00")], [passo(data="2026-10-10 10:00:00")],
                       [vinculada(recl="2026-10-10 13:00:00")])
    assert "dif_1o_passo_1a_os_inicio" not in regras_de(base)
    base2 = montar_base([intervencao(DTA_INIC_MNB="2026-10-10 09:00:00")], [passo(data="2026-10-10 10:00:00")],
                        [vinculada(recl="2026-10-10 13:00:00")])
    v = executar(base2).flags.query("regra_id == 'dif_1o_passo_1a_os_inicio'")["valor"].tolist()
    assert v == ["Dif Man e Pass"]


def test_intervencao_sem_passo_executado_e_sem_vinculo_fica_fora():
    base = montar_base([intervencao(TIPO_TR="PRÓPRIO")], [passo(status="Passo Cancelado")], [])
    r = executar(base)
    assert "tr_proprio_os_proc" in set(r.flags["regra_id"])
    assert r.fila.empty
