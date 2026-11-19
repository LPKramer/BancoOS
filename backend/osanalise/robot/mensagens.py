"""Tratamento das mensagens do TS (KB_TS/04_mensagens_e_erros.md e locators.json)."""
from __future__ import annotations

import json
import re
from importlib import resources

BOTAO_SIM = re.compile(r"^(OK|Sim|Yes|Confirma)$", re.I)
BOTAO_NAO = re.compile(r"^(Não|Nao|No|Cancelar|Cancel)$", re.I)


def tabela() -> list[dict]:
    dados = json.loads(resources.files("osanalise.robot").joinpath("locators.json").read_text(encoding="utf-8"))
    return dados["mensagens"]


def classificar(texto: str) -> dict:
    """Devolve {'acao': confirmar|sucesso|erro|desconhecida, 'status': ...} para o texto da mensagem."""
    t = (texto or "").lower()
    for m in tabela():
        if m["trecho_minusculo"] in t:
            return {"acao": m["acao"], "status": m["status"]}
    return {"acao": "desconhecida", "status": "erro-msg-desconhecida"}
