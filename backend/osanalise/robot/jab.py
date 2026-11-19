"""Acesso ao TS pelo Java Access Bridge, sem imagem nem coordenadas de mouse.

Baseado em KB_TS/exemplo_jab_minimo.py. Componentes são achados por locator
`role:<papel> and name:<nome>` ou `name:/<regex>/` (KB_TS/02_telas_e_componentes.md).
"""
from __future__ import annotations

import ctypes
import json
import os
import queue
import re
import threading
import time
from ctypes import wintypes
from dataclasses import dataclass, field
from importlib import resources

from .ambiente import localizar_dll

_wrapper = None
_trava = threading.Lock()


class ErroTS(RuntimeError):
    def __init__(self, status: str, mensagem: str = ""):
        super().__init__(f"{status}: {mensagem}" if mensagem else status)
        self.status = status


def locators() -> dict[str, str]:
    dados = json.loads(resources.files("osanalise.robot").joinpath("locators.json").read_text(encoding="utf-8"))
    return {c["chave"]: c["locator"] for c in dados["componentes"]}


def iniciar_jab():
    """O JAB precisa de uma thread com laço de mensagens do Windows (uma por processo)."""
    global _wrapper
    with _trava:
        if _wrapper is not None:
            return _wrapper
        dll = localizar_dll()
        if not dll:
            raise ErroTS("jab-sem-dll", "WindowsAccessBridge-64.dll não encontrada")
        os.environ["RC_JAVA_ACCESS_BRIDGE_DLL"] = dll
        from JABWrapper.jab_wrapper import JavaAccessBridgeWrapper

        canal: queue.Queue = queue.Queue()

        def bomba():
            try:
                w = JavaAccessBridgeWrapper(ignore_callbacks=True)
                canal.put(w)
                msg = ctypes.byref(wintypes.MSG())
                u = ctypes.windll.user32
                while u.GetMessageW(msg, 0, 0, 0) > 0:
                    u.TranslateMessage(msg)
                    u.DispatchMessageW(msg)
            except Exception as e:  # noqa: BLE001
                canal.put(e)

        threading.Thread(target=bomba, daemon=True, name="jab-bomba").start()
        r = canal.get(timeout=30)
        if isinstance(r, Exception):
            raise ErroTS("jab-falhou", str(r))
        time.sleep(0.3)
        _wrapper = r
        return r


def normalizar_nome(nome: str | None, role: str) -> str:
    nome = re.sub(r"\s+alt\s+\S$", "", (nome or "").strip(), flags=re.I)
    if role != "label":
        nome = re.sub(r"^.*?\btab page\s+", "", nome)
        nome = re.sub(r"\s+(Required|Multiline)$", "", nome)
    return nome.strip().rstrip(":").strip()


@dataclass
class No:
    ctx: object
    role: str
    name: str
    states: str
    n_filhos: int
    tem_texto: bool
    pai: "No | None" = None
    filhos: list["No"] = field(default_factory=list)

    def __iter__(self):
        yield self
        for f in self.filhos:
            yield from f

    @property
    def visivel(self) -> bool:
        return "showing" in self.states

    @property
    def habilitado(self) -> bool:
        return "enabled" in self.states


def _no(w, ctx, pai=None) -> No:
    info = w.get_context_info(ctx)
    role = info.role_en_US or info.role or ""
    return No(ctx=ctx, role=role, name=normalizar_nome(info.name, role),
              states=(info.states_en_US or info.states or "").lower(), n_filhos=info.childrenCount,
              tem_texto=bool(info.accessibleText), pai=pai)


def arvore(w, ctx, pai=None, prof=0, so_visiveis=True) -> No:
    n = _no(w, ctx, pai)
    if prof < 60 and (not so_visiveis or n.visivel or prof < 2):
        for i in range(min(n.n_filhos, 400)):
            try:
                c = w.get_child_context(ctx, i)
                if c:
                    n.filhos.append(arvore(w, c, n, prof + 1, so_visiveis))
            except Exception:  # noqa: BLE001
                pass
    return n


def _casa(locator: str, n: No) -> bool:
    partes = dict(p.split(":", 1) for p in re.split(r"\s+and\s+", locator.strip()) if ":" in p)
    if "role" in partes and n.role != partes["role"].strip():
        return False
    if "name" in partes:
        alvo = partes["name"].strip()
        if alvo.startswith("/") and alvo.endswith("/"):
            return re.search(alvo[1:-1], n.name, flags=re.I) is not None
        return n.name.lower() == normalizar_nome(alvo, n.role).lower()
    return True


class TS:
    """Uma janela do TS (identificada por PID)."""

    def __init__(self, pid: int | None = None, prefixo: str = "Sonda"):
        self.w = iniciar_jab()
        self.pid = pid
        self.prefixo = prefixo
        self.L = locators()

    def raiz(self) -> No:
        for j in self.w.get_windows():
            if (j.title or "").startswith(self.prefixo) and (self.pid is None or j.pid == self.pid):
                vm, ctx = self.w.get_accessible_context_from_hwnd(j.hwnd)
                self.w._vmID = vm
                return arvore(self.w, ctx)
        raise ErroTS("erro-ts-fechou", "janela do TS não encontrada")

    def achar(self, chave_ou_locator: str, raiz: No | None = None) -> No | None:
        loc = self.L.get(chave_ou_locator, chave_ou_locator)
        for n in (raiz or self.raiz()):
            if n.visivel and _casa(loc, n):
                return n
        return None

    def esperar(self, chave: str, timeout: float = 25.0) -> No:
        fim = time.time() + timeout
        while time.time() < fim:
            n = self.achar(chave)
            if n is not None:
                return n
            time.sleep(0.5)
        raise ErroTS(f"timeout-{chave}")

    def ler(self, n: No) -> str:
        if not n.tem_texto:
            return n.name
        q = self.w.get_context_text_info(n.ctx, 0, 0).charCount
        return self.w.get_accessible_text_range(n.ctx, 0, max(q - 1, 0), q + 1) if q else ""

    def escrever(self, n: No, valor: str) -> bool:
        self.w.set_text_contents(n.ctx, valor)
        time.sleep(0.2)
        lido = self.ler(n).strip().upper()
        if valor.strip().isdigit():
            return re.sub(r"\D", "", lido) == valor.strip()
        return lido == valor.strip().upper()

    def clicar(self, n: No) -> None:
        from JABWrapper.jab_types import AccessibleActionInfo, AccessibleActionsToDo

        if n.role == "page tab" and n.pai is not None:
            idx = [f for f in n.pai.filhos if f.role == "page tab"].index(n)
            self.w.clear_accessible_selection_from_context(n.pai.ctx)
            self.w.add_accessible_selection_from_context(n.pai.ctx, idx)
            return
        acoes = self.w.get_accessible_actions(n.ctx)
        nomes = [acoes.actionInfo[i].name for i in range(acoes.actionsCount)]
        acao = next((a for a in nomes if a.lower() in ("click", "clicar", "press", "toggle")),
                    nomes[0] if nomes else None)
        if acao is None:
            raise ErroTS("sem-acao", n.name)
        todo = AccessibleActionsToDo(actionsCount=1)
        todo.actions[0] = AccessibleActionInfo(acao)
        self.w.do_accessible_actions(n.ctx, todo)

    def mensagem_aberta(self, raiz: No | None = None) -> tuple[str, list[No]] | None:
        """Mensagens do TS são `option pane` dentro da tela (KB_TS/04)."""
        for n in (raiz or self.raiz()):
            if n.role in ("option pane", "dialog", "alert") and n.visivel:
                textos = [f.name for f in n if f.role in ("label", "text") and f.name]
                botoes = [f for f in n if f.role == "push button"]
                return " ".join(textos), botoes
        return None

    def status_bar(self, raiz: No | None = None) -> str:
        for n in (raiz or self.raiz()):
            if n.role == "status bar":
                return " ".join(f.name for f in n.filhos if f.name and not f.name.startswith("Record"))
        return ""
