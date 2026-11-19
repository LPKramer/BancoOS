"""Fluxos do robô no TS (KB_TS/03_fluxos.md).

Prontos (mapeados na KB): abrir o TS, login, abrir SMANUTOS, pesquisar OS, voltar ao início.
Correções: cada tipo do catálogo precisa da tela correspondente mapeada (Diagnóstico do TS).
Enquanto não estiver mapeada, o fluxo levanta `NaoMapeado` e nada é alterado.
"""
from __future__ import annotations

import os
import re
import time

from ..config import CONFIG
from .ambiente import credencial_ts, janelas_ts
from .jab import TS, ErroTS
from .mensagens import BOTAO_NAO, BOTAO_SIM, classificar


class NaoMapeado(ErroTS):
    def __init__(self, tela: str):
        super().__init__("tela-nao-mapeada", f"{tela}: rode o Diagnóstico do TS com o TS nessa tela e "
                                             "acrescente os componentes em robot/locators.json")


# ------------------------------------------------------------- sessão do TS
def abrir_ts(timeout: float = 240.0) -> int:
    """Fluxo A: abre o TS do robô pelo jnlp e devolve o PID da janela nova."""
    antes = {j["pid"] for j in janelas_ts()}
    os.startfile(CONFIG.jnlp_ts)  # noqa: S606 - abre o jnlp como um duplo clique
    fim = time.time() + timeout
    while time.time() < fim:
        time.sleep(3)
        _responder_avisos_java()
        novas = [j for j in janelas_ts() if j["pid"] not in antes]
        if novas:
            return novas[0]["pid"]
    raise ErroTS("timeout-abrir-ts")


def _responder_avisos_java() -> None:
    try:
        from .jab import iniciar_jab, arvore

        w = iniciar_jab()
        for j in w.get_windows():
            titulo = j.title or ""
            if re.search(r"update|atualiza", titulo, re.I):
                alvo = re.compile(r"^(Mais tarde|Later|Não|Cancel)", re.I)
            elif re.search(r"informa|seguran|security|aviso|warning", titulo, re.I):
                alvo = re.compile(r"^(Executar|Run|OK|Sim|Continuar)", re.I)
            else:
                continue
            vm, ctx = w.get_accessible_context_from_hwnd(j.hwnd)
            w._vmID = vm
            for n in arvore(w, ctx):
                if n.role == "push button" and alvo.search(n.name):
                    TS(pid=j.pid, prefixo=titulo).clicar(n)
                    break
    except Exception:  # noqa: BLE001 - avisos são opcionais
        pass


def login(ts: TS) -> None:
    """Fluxo B. Usuário e senha vêm do Cofre do Windows (python -m osanalise.robot.credencial)."""
    cred = credencial_ts()
    if not cred:
        raise ErroTS("sem-credencial", "rode: python -m osanalise.robot.credencial")
    raiz = ts.raiz()
    if ts.achar("atalho", raiz):
        return  # já logado
    campos = list(raiz)
    senha = next((n for n in campos if n.role == "password text" and n.visivel), None)
    if senha is None:
        raise ErroTS("timeout-login_senha")
    idx = campos.index(senha)
    usuario = next((n for n in reversed(campos[:idx]) if n.role == "text" and n.visivel), None)
    if usuario is None or not ts.escrever(usuario, cred[0]):
        raise ErroTS("login-usuario-nao-gravou")
    ts.w.set_text_contents(senha.ctx, cred[1])
    entrar = ts.achar("login_entrar", raiz)
    if entrar is None:
        raise ErroTS("timeout-login_entrar")
    ts.clicar(entrar)
    fim = time.time() + 40
    while time.time() < fim:
        time.sleep(1)
        msg = ts.mensagem_aberta()
        if msg:
            raise ErroTS("login-recusado", msg[0])
        if ts.achar("atalho"):
            return
    raise ErroTS("timeout-login")


def abrir_smanutos(ts: TS) -> None:
    """Fluxo C."""
    atalho = ts.esperar("atalho")
    ts.escrever(atalho, "SMANUTOS")
    ts.clicar(ts.esperar("atalho_executa"))
    ts.esperar("os_numero", timeout=90)


def fechar_mensagens(ts: TS) -> None:
    for _ in range(5):
        msg = ts.mensagem_aberta()
        if not msg:
            return
        _, botoes = msg
        alvo = next((b for b in botoes if BOTAO_NAO.match(b.name)), None) or \
            next((b for b in botoes if BOTAO_SIM.match(b.name)), None)
        if alvo is None:
            return
        ts.clicar(alvo)
        time.sleep(0.5)


def voltar_inicio(ts: TS) -> None:
    """Fluxo I: fecha mensagens e clica Nova Pesquisa (responde Não se perguntar se quer salvar)."""
    fechar_mensagens(ts)
    nova = ts.achar("nova_pesquisa")
    if nova is not None:
        ts.clicar(nova)
        time.sleep(0.8)
        fechar_mensagens(ts)


def pesquisar_os(ts: TS, numero: str, tipo: str = "05", seq: str = "1") -> dict:
    """Fluxo D: carrega a OS e devolve os dados do cabeçalho."""
    voltar_inicio(ts)
    for chave, valor in (("os_tipo", tipo), ("os_numero", numero), ("os_seq", seq)):
        campo = ts.esperar(chave)
        if not ts.escrever(campo, valor):
            raise ErroTS(f"nao-gravou-{chave}")
    ts.clicar(ts.esperar("botao_pesquisa_os"))
    fim = time.time() + 40
    while time.time() < fim:
        time.sleep(1)
        raiz = ts.raiz()
        msg = ts.mensagem_aberta(raiz)
        if msg:
            raise ErroTS("erro-os-nao-encontrada-ts", msg[0])
        alterar = ts.achar("alterar_dados", raiz)
        origem = ts.achar("data_origem", raiz)
        if alterar is not None and alterar.habilitado and origem is not None and ts.ler(origem).strip():
            comp = ts.achar("competencia_os", raiz)
            return {"data_origem": ts.ler(origem).strip(), "competencia": ts.ler(comp).strip() if comp else None}
    raise ErroTS("timeout-pesquisa-os")


def salvar(ts: TS, timeout: float = 60.0) -> str:
    """Fluxo F.7: clica Salvar e trata as mensagens até sucesso ou erro."""
    ts.clicar(ts.esperar("salvar"))
    fim = time.time() + timeout
    desabilitado_seguidas = 0
    while time.time() < fim:
        time.sleep(1)
        raiz = ts.raiz()
        msg = ts.mensagem_aberta(raiz)
        if msg:
            texto, botoes = msg
            c = classificar(texto)
            botao = next((b for b in botoes if BOTAO_SIM.match(b.name)), None)
            if botao is not None:
                ts.clicar(botao)
            if c["acao"] == "sucesso":
                return "ok"
            if c["acao"] in ("erro", "desconhecida"):
                raise ErroTS(c["status"], texto)
            continue
        if "frm-" in ts.status_bar(raiz).lower() and not re.search(r"frm-4040[01]", ts.status_bar(raiz).lower()):
            raise ErroTS("erro-oracle-forms", ts.status_bar(raiz))
        botao_salvar = ts.achar("salvar", raiz)
        desabilitado_seguidas = desabilitado_seguidas + 1 if botao_salvar is not None and not botao_salvar.habilitado else 0
        if desabilitado_seguidas >= 2:
            return "ok"
    raise ErroTS("erro-sem-confirmacao")


# ------------------------------------------------------------ correções
def _conferir_valor(lido: str | None, esperado: str | None, campo: str) -> None:
    """Trava de segurança: só altera se o TS mostra o valor que a análise viu."""
    if esperado is None:
        return
    norm = lambda v: re.sub(r"\s+", " ", (v or "").strip().upper().replace("-", "/"))  # noqa: E731
    if norm(lido) != norm(esperado):
        raise ErroTS("valor-atual-diferente", f"{campo}: TS mostra {lido!r}, esperado {esperado!r}")


def corrigir_nao_mapeado(tela: str):
    """Fluxo de correção ainda sem tela mapeada. Todo fluxo recebe a justificativa da OS (texto padrão
    escolhido pelo analista), que vai no campo "Justificativa – informe o motivo da ação" antes de salvar."""
    def fluxo(ts: TS, correcao, modo_teste: bool, justificativa: str) -> str:
        raise NaoMapeado(tela)

    return fluxo


FLUXOS = {
    "alterar_conclusao": corrigir_nao_mapeado("campo de conclusão da OS (000/004)"),
    "alterar_causa_subcausa": corrigir_nao_mapeado("campos de causa/subcausa da OS"),
    "alterar_status_passo": corrigir_nao_mapeado("tela de passos de manobra"),
    "ajustar_ucs": corrigir_nao_mapeado("tela de passos de manobra (clientes interrompidos)"),
    "vincular_os": corrigir_nao_mapeado("tela de OS vinculadas"),
    "desvincular_os": corrigir_nao_mapeado("tela de OS vinculadas"),
    "ajustar_data_hora": corrigir_nao_mapeado("campos de data/hora da OS"),
    "alterar_elemento_origem": corrigir_nao_mapeado("campos de elemento de origem"),
}
