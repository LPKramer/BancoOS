"""Fluxo da API com um lote sintético (banco temporário)."""
from __future__ import annotations

from conftest import OS_A, intervencao, montar_base, passo, vinculada
from fastapi.testclient import TestClient

from osanalise import servicos
from osanalise.llm.provedor import RespostaLLM


class ProvedorFalso:
    nome = "falso"
    modelo = "falso-1"

    def completar(self, sistema, usuario):
        assert "OS" in sistema and "[telefone]" in usuario or "63912345678" not in usuario
        return RespostaLLM(conteudo={
            "veredito": "errada", "confianca": 0.9, "resumo": "clientes vazio no 1º passo",
            "problemas": [{"regra_id": "intev_0_ucs_inter", "descricao": "sem clientes", "evidencia": "QTD vazia"}],
            "correcoes": [{"tipo": "ajustar_ucs", "campo": "QTD_UN_CONS_PNB", "alvo": "1", "valor_atual": None,
                           "valor_novo": "12", "justificativa": "BDGD"}]}, texto="{}", modelo="falso-1")


def test_fluxo_completo(banco_temporario):
    base = montar_base([intervencao(DES_INTV_MNB="cliente 63912345678 sem energia")], [passo(qtd=None)],
                       [vinculada()])
    lote = servicos.importar_base(base, "critica", "TESTE")
    from osanalise.api.app import app

    c = TestClient(app)
    h = {"X-Usuario": "TESTE"}
    fila = c.get(f"/api/lotes/{lote.id}/fila").json()
    assert fila["total"] == 1
    item = fila["itens"][0]
    assert item["os"] == OS_A and "intev_0_ucs_inter" in item["regras"]

    d = c.get(f"/api/os/{item['id']}").json()
    assert d["resumo"]["os"] == OS_A and len(d["passos"]) == 1 and len(d["vinculadas"]) == 1

    assert c.patch(f"/api/os/{item['id']}", json={"status": "em_analise"}, headers=h).json()["status"] == "em_analise"
    assert c.patch(f"/api/os/{item['id']}", json={"status": "xyz"}, headers=h).status_code == 400

    from osanalise.llm.analisador import analisar_os

    r = analisar_os(item["id"], ProvedorFalso(), usuario="TESTE")
    assert r.veredito == "errada" and not r.erro
    assert analisar_os(item["id"], ProvedorFalso()).reaproveitada

    correcoes = c.get("/api/correcoes", params={"lote_id": lote.id}).json()
    assert len(correcoes) == 1 and correcoes[0]["status"] == "proposta" and correcoes[0]["origem"] == "llm"
    assert c.post(f"/api/correcoes/{correcoes[0]['id']}/decisao", json={"aprovar": True}).status_code == 400  # sem analista
    ok = c.post(f"/api/correcoes/{correcoes[0]['id']}/decisao", json={"aprovar": True, "valor_novo": "15"}, headers=h).json()
    assert ok["status"] == "aprovada" and ok["valor_novo"] == "15" and ok["decidido_por"] == "TESTE"

    painel = c.get(f"/api/lotes/{lote.id}/painel").json()
    assert painel["total"] == 1 and painel["correcoes"]["aprovada"] == 1
    assert c.get(f"/api/lotes/{lote.id}/exportar").status_code == 200
    acoes = [a["acao"] for a in c.get("/api/auditoria").json()]
    assert {"importar_lote", "atualizar_os", "analise_llm", "aprovar_correcao"} <= set(acoes)


def test_decisao_com_categorias(banco_temporario):
    lote = servicos.importar_base(montar_base([intervencao()], [passo(qtd=None)], [vinculada()]), "critica", "TESTE")
    from osanalise.api.app import app

    c = TestClient(app)
    h = {"X-Usuario": "TESTE"}
    os_id = c.get(f"/api/lotes/{lote.id}/fila").json()["itens"][0]["id"]
    assert "classificacao" in c.get("/api/config").json()["categorias_correcao"].values()

    def atualizacoes():
        return sum(a["acao"] == "atualizar_os" for a in c.get("/api/auditoria").json())

    # o formulário manda texto vazio nos campos não preenchidos: grava vazio (None), não ""
    corpo = {"status": "errada", "responsavel": "", "observacao": "", "categorias_correcao": ["passo_manobra", "classificacao", "classificacao"]}
    r = c.patch(f"/api/os/{os_id}", json=corpo, headers=h).json()
    assert r["status"] == "errada" and r["categorias_correcao"] == ["classificacao", "passo_manobra"]
    assert r["responsavel"] is None and r["observacao"] is None
    antes = atualizacoes()
    c.patch(f"/api/os/{os_id}", json=corpo, headers=h)  # salvar de novo sem mudar nada não audita
    assert atualizacoes() == antes

    assert c.patch(f"/api/os/{os_id}", json={"categorias_correcao": ["xyz"]}, headers=h).status_code == 400
    assert c.patch(f"/api/os/{os_id}", json={"categorias_correcao": []}, headers=h).json()["categorias_correcao"] is None
    assert c.get(f"/api/os/{os_id}").json()["resumo"]["status"] == "errada"  # campo ausente não muda
