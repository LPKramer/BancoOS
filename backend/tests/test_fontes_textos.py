"""Bases apontadas na tela Importar e textos padrões de justificativa do TS."""
from __future__ import annotations

import openpyxl
import pytest
from conftest import intervencao, montar_base, passo, vinculada
from fastapi.testclient import TestClient

from osanalise import fontes, servicos, textos_padrao
from osanalise.llm.provedor import RespostaLLM

H = {"X-Usuario": "TESTE"}


def _planilha(caminho, abas: dict[str, list[list]]):
    wb = openpyxl.Workbook()
    wb.remove(wb.active)
    for nome, linhas in abas.items():
        ws = wb.create_sheet(nome)
        for linha in linhas:
            ws.append(linha)
    wb.save(caminho)
    return caminho


@pytest.fixture
def pasta(banco_temporario, monkeypatch):
    """Banco temporário e pasta do projeto vazia (sem sugerir os arquivos reais)."""
    monkeypatch.setattr(fontes, "PASTA_PROJETO", banco_temporario)
    monkeypatch.setattr(textos_padrao, "_tentou_carga", [True])
    fontes._cache.clear()
    return banco_temporario


def _critica(pasta):
    return _planilha(pasta / "base-critica.xlsx", {"SQL": [["x"]], "Exportar Planilha": [
        ["DTA_CMPT_MNB", "TIPO_OS", "NUM_SEQ_OPER_OS_MNB"], ["01/10/2026", "INTERVENÇÃO", "1"], ["01/10/2026", "PASSO_MANOBRA", "1"]]})


def _ocorrencias(pasta):
    return _planilha(pasta / "9 C_Ocorrências.xlsx", {"Base": [
        ["DTA_CMPT_VDI", "NUM_SEQ_OPER_INIC_INTER_VDI", "MULTA_OS"], ["01/10/2026", "1", 600.5]]})


def _textos(pasta):
    linhas = [["ERRO ENCONTRADO", "JUSTIFICATIVA CORREÇÃO"],
              [None, "DESVINCULADA, NÃO FAZ PARTE DA ABRANGENCIA DNA OPERADOR"],
              [None, "CORREÇÃO HORA INICIO  DNA OPERADOR"],
              [None, "CORREÇÃO HORA INICIO DNA OPERADOR"],  # repetido (espaço duplo) entra uma vez
              ["passo errado", "CANCELADO PASSO INTERROMPER E CORRIGIDO CLASSIFICAÇÃO DNA OPERADOR"],
              [None, None]]
    return _planilha(pasta / "TEXTOS PADRÕES.xlsx", {"Textos correções": linhas, "Planilha1": []})


def test_verificar_bases(pasta):
    crit, ocorr = _critica(pasta), _ocorrencias(pasta)
    v = fontes.verificar("critica", crit)
    assert v["ok"] and v["linhas"] == 2 and v["competencia"] == "10/2026"
    assert fontes.verificar("ocorrencias", ocorr)["ok"]
    # arquivo no papel errado é recusado com motivo
    assert not fontes.verificar("critica", ocorr)["ok"]
    assert "MULTA_OS" in fontes.verificar("ocorrencias", crit)["mensagem"]
    assert fontes.verificar("critica", pasta / "nao_existe.xlsx")["mensagem"].startswith("Arquivo não encontrado")
    # sem caminho gravado, sugere o arquivo da pasta do projeto; o gravado tem prioridade
    assert fontes.situacao("critica")["caminho"] == str(crit) and not fontes.situacao("critica")["salvo"]


def test_apontar_e_importar_bases(pasta, monkeypatch):
    from osanalise.api.app import app

    c = TestClient(app)
    crit, ocorr = _critica(pasta), _ocorrencias(pasta)
    r = c.put("/api/fontes/critica", json={"caminho": f'"{crit}"'}, headers=H).json()
    assert r["salvo"] and r["verificacao"]["ok"]
    r = c.put("/api/fontes/ocorrencias", json={"caminho": str(crit)}, headers=H).json()
    assert not r["salvo"] and not r["verificacao"]["ok"]  # crítica no lugar das ocorrências não grava
    assert c.get("/api/fontes").json()["ocorrencias"]["salvo"] is False

    chamadas = []

    def falso(critica, ocorrencias, usuario=""):
        chamadas.append((critica.name, ocorrencias.name))
        return servicos.importar_base(montar_base([intervencao()], [passo(qtd=None)], [vinculada()]), "critica", usuario)

    monkeypatch.setattr(servicos, "importar_bases", falso)
    # papéis trocados: erro antes de importar
    assert c.post("/api/lotes/importar-bases", data={"critica_caminho": str(ocorr), "ocorrencias_caminho": str(crit)},
                  headers=H).status_code == 400
    # crítica pelo caminho já apontado, ocorrências enviada como arquivo
    with open(ocorr, "rb") as f:
        imp = c.post("/api/lotes/importar-bases", files={"ocorrencias_arquivo": (ocorr.name, f)}, headers=H).json()
    import time

    for _ in range(50):
        st = c.get(f"/api/importacoes/{imp['id']}").json()
        if st["situacao"] != "rodando":
            break
        time.sleep(0.1)
    assert st["situacao"] == "concluida", st
    assert chamadas == [(crit.name, ocorr.name)]


def test_textos_padrao(pasta):
    arq = _textos(pasta)
    r = textos_padrao.importar(arq, "TESTE")
    assert r["novos"] == 3
    textos = {t["texto"]: t for t in textos_padrao.listar()}
    assert textos["DESVINCULADA, NÃO FAZ PARTE DA ABRANGENCIA DNA OPERADOR"]["categorias"] == ["os_vinculada"]
    assert textos["CORREÇÃO HORA INICIO DNA OPERADOR"]["categorias"] == ["horario"]
    cancelado = textos["CANCELADO PASSO INTERROMPER E CORRIGIDO CLASSIFICAÇÃO DNA OPERADOR"]
    assert cancelado["categorias"] == ["classificacao", "passo_manobra"] and cancelado["erro"] == "passo errado"

    # acerto manual das categorias sobrevive a uma nova carga; texto que saiu da planilha fica inativo
    textos_padrao.atualizar(cancelado["id"], "TESTE", categorias=["passo_manobra"])
    arq2 =_planilha(pasta / "TEXTOS PADRÕES.xlsx", {"Textos correções": [
        ["JUSTIFICATIVA CORREÇÃO"], ["CANCELADO PASSO INTERROMPER E CORRIGIDO CLASSIFICAÇÃO DNA OPERADOR"],
        ["OS VINCULADA DNA OPERADOR"]]})
    r = textos_padrao.importar(arq2, "TESTE")
    assert (r["novos"], r["desativados"]) == (1, 2)
    textos = {t["texto"]: t for t in textos_padrao.listar()}
    assert textos["CANCELADO PASSO INTERROMPER E CORRIGIDO CLASSIFICAÇÃO DNA OPERADOR"]["categorias"] == ["passo_manobra"]
    assert not textos["CORREÇÃO HORA INICIO DNA OPERADOR"]["ativo"]
    assert len(textos_padrao.ativos()) == 2
    with pytest.raises(ValueError):
        textos_padrao.atualizar(cancelado["id"], "TESTE", categorias=["xyz"])


def test_textos_pela_api_e_justificativa_da_os(pasta):
    from osanalise.api.app import app

    c = TestClient(app)
    assert c.post("/api/textos-padrao/carregar", data={"caminho": str(_critica(pasta))}, headers=H).status_code == 400
    r = c.post("/api/textos-padrao/carregar", data={"caminho": str(_textos(pasta))}, headers=H).json()
    assert r["resumo"]["total"] == 3 and r["fonte"]["salvo"]
    tid = r["textos"][0]["id"]
    assert c.patch(f"/api/textos-padrao/{tid}", json={"categorias": ["horario"]}, headers=H).json()["categorias_manuais"]

    lote = servicos.importar_base(montar_base([intervencao()], [passo(qtd=None)], [vinculada()]), "critica", "TESTE")
    os_id = c.get(f"/api/lotes/{lote.id}/fila").json()["itens"][0]["id"]
    texto = "DESVINCULADA, NÃO FAZ PARTE DA ABRANGENCIA DNA OPERADOR"
    assert c.patch(f"/api/os/{os_id}", json={"justificativa_ts": f"  {texto} "}, headers=H).json()["justificativa_ts"] == texto
    assert c.get(f"/api/os/{os_id}").json()["resumo"]["justificativa_ts"] == texto


class ProvedorTextos:
    nome = "falso"
    modelo = "falso-1"

    def __init__(self, escolha):
        self.escolha = escolha
        self.sistema = ""

    def completar(self, sistema, usuario):
        self.sistema = sistema
        return RespostaLLM(conteudo={
            "veredito": "errada", "confianca": 0.8, "resumo": "vinculada fora da área",
            "correcoes": [{"tipo": "desvincular_os", "campo": "NUM_SEQ_OPER_INTER_CNR", "alvo": "1",
                           "valor_atual": "x", "valor_novo": None, "justificativa": "trafo não desligou"}],
            "justificativa_padrao": self.escolha}, texto="{}", modelo="falso-1")


def test_llm_escolhe_justificativa(pasta):
    from osanalise.llm.analisador import analisar_os

    textos_padrao.importar(_textos(pasta), "TESTE")
    alvo = next(i for i, t in textos_padrao.ativos() if t.startswith("DESVINCULADA"))
    lote = servicos.importar_base(montar_base([intervencao()], [passo(qtd=None)], [vinculada()]), "critica", "TESTE")
    from osanalise import db
    from osanalise.db import AnaliseLLM, OSFila

    with db.sessao() as s:
        os_id = s.query(OSFila.id).filter(OSFila.lote_id == lote.id).scalar()

    p = ProvedorTextos(f"{alvo}. DESVINCULADA...")
    analisar_os(os_id, p)
    assert f"{alvo}. DESVINCULADA, NÃO FAZ PARTE DA ABRANGENCIA" in p.sistema  # lista numerada vai no prompt
    with db.sessao() as s:
        a = s.query(AnaliseLLM).filter(AnaliseLLM.os_fila_id == os_id).order_by(AnaliseLLM.id.desc()).first()
        assert a.resposta["justificativa_padrao"] == alvo
        assert a.resposta["justificativa_padrao_texto"].startswith("DESVINCULADA")
        assert s.get(OSFila, os_id).justificativa_ts is None  # a sugestão não grava sozinha na OS

    # número que não é de um texto enviado vira None; mudar os textos muda o prompt e invalida o cache
    analisar_os(os_id, ProvedorTextos(999), forcar=True)
    with db.sessao() as s:
        a = s.query(AnaliseLLM).filter(AnaliseLLM.os_fila_id == os_id).order_by(AnaliseLLM.id.desc()).first()
        assert a.resposta["justificativa_padrao"] is None and a.resposta["justificativa_padrao_texto"] is None
    assert analisar_os(os_id, ProvedorTextos(alvo)).reaproveitada
    textos_padrao.atualizar(alvo, "TESTE", ativo=False)
    assert not analisar_os(os_id, ProvedorTextos(None)).reaproveitada
