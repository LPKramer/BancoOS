"""Verificação do ambiente do robô (KB_TS/01_acesso_java_access_bridge.md)."""
from __future__ import annotations

import ctypes
import glob
import os
from ctypes import wintypes
from pathlib import Path

from ..config import CONFIG

ARQ_ACESSIBILIDADE = Path(os.environ.get("USERPROFILE", str(Path.home()))) / ".accessibility.properties"
CONTEUDO_ACESSIBILIDADE = ("assistive_technologies=com.sun.java.accessibility.AccessBridge\n"
                           "screen_magnifier_present=true\n")
SERVICO_COFRE_TS = "osanalise_ts"


def localizar_dll() -> str | None:
    if CONFIG.jab_dll and Path(CONFIG.jab_dll).is_file():
        return CONFIG.jab_dll
    candidatos = [r"C:\Windows\System32\WindowsAccessBridge-64.dll"]
    for padrao in (r"C:\Program Files\Java\*\bin\WindowsAccessBridge-64.dll",
                   r"C:\Program Files\OpenWebStart\jre\bin\WindowsAccessBridge-64.dll",
                   r"C:\Program Files\Eclipse Adoptium\*\bin\WindowsAccessBridge-64.dll",
                   str(Path.home() / ".jdks" / "*" / "bin" / "WindowsAccessBridge-64.dll")):
        candidatos += glob.glob(padrao)
    return next((c for c in candidatos if Path(c).is_file()), None)


def acessibilidade_ativa() -> bool:
    try:
        return "com.sun.java.accessibility.AccessBridge" in ARQ_ACESSIBILIDADE.read_text(encoding="utf-8",
                                                                                         errors="ignore")
    except OSError:
        return False


def ativar_acessibilidade() -> None:
    """Liga a acessibilidade do Java para o usuário (vale para TS abertos depois disso)."""
    atual = ARQ_ACESSIBILIDADE.read_text(encoding="utf-8", errors="ignore") if ARQ_ACESSIBILIDADE.exists() else ""
    if "com.sun.java.accessibility.AccessBridge" not in atual:
        ARQ_ACESSIBILIDADE.write_text(atual + ("\n" if atual and not atual.endswith("\n") else "")
                                      + CONTEUDO_ACESSIBILIDADE, encoding="utf-8")


def janelas_ts(prefixo: str = "Sonda") -> list[dict]:
    """Janelas de topo cujo título começa com 'Sonda' (TS), com PID."""
    user32 = ctypes.windll.user32
    achadas: list[dict] = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cada(hwnd, _):
        if not user32.IsWindowVisible(hwnd):
            return True
        n = user32.GetWindowTextLengthW(hwnd)
        if n:
            buf = ctypes.create_unicode_buffer(n + 1)
            user32.GetWindowTextW(hwnd, buf, n + 1)
            if buf.value.startswith(prefixo):
                pid = wintypes.DWORD()
                user32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
                achadas.append({"hwnd": int(hwnd), "titulo": buf.value, "pid": int(pid.value)})
        return True

    user32.EnumWindows(cada, 0)
    return achadas


def credencial_ts() -> tuple[str, str] | None:
    try:
        import keyring

        usuario = keyring.get_password(SERVICO_COFRE_TS, "usuario")
        senha = keyring.get_password(SERVICO_COFRE_TS, usuario) if usuario else None
        return (usuario, senha) if usuario and senha else None
    except Exception:  # noqa: BLE001
        return None


def jabwrapper_instalado() -> bool:
    try:
        import importlib.util

        return importlib.util.find_spec("JABWrapper") is not None
    except Exception:  # noqa: BLE001
        return False


def verificar() -> dict:
    return {
        "dll": localizar_dll(),
        "acessibilidade_java": acessibilidade_ativa(),
        "biblioteca_jab": jabwrapper_instalado(),
        "jnlp": CONFIG.jnlp_ts if Path(CONFIG.jnlp_ts).is_file() else None,
        "credencial_ts": credencial_ts() is not None,
        "janelas_ts": janelas_ts(),
    }
