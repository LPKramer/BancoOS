"""Diagnóstico do TS: grava a árvore de componentes (KB_TS/07_rastreio.md) para mapear telas novas.

Deixe o TS na tela exata que quer mapear (ex.: passos de manobra, conclusão, OS vinculadas) e rode.
"""
from __future__ import annotations

from datetime import datetime
from pathlib import Path

from ..config import CONFIG
from .ambiente import janelas_ts, localizar_dll
from .jab import arvore, iniciar_jab


def gerar() -> tuple[Path, int]:
    w = iniciar_jab()
    pasta = CONFIG.pasta_dados / "diagnostico"
    pasta.mkdir(parents=True, exist_ok=True)
    destino = pasta / f"arvore_ts_{datetime.now():%Y%m%d_%H%M%S}.txt"
    linhas: list[str] = []
    for j in w.get_windows():
        if not (j.title or "").startswith("Sonda"):
            continue
        linhas.append(f"===== JANELA: {j.title}  (hwnd {j.hwnd}, pid {j.pid})")
        vm, ctx = w.get_accessible_context_from_hwnd(j.hwnd)
        w._vmID = vm
        raiz = arvore(w, ctx, so_visiveis=False)

        def escrever(n, prof=0):
            texto = ""
            if n.tem_texto:
                try:
                    q = w.get_context_text_info(n.ctx, 0, 0).charCount
                    texto = w.get_accessible_text_range(n.ctx, 0, max(q - 1, 0), q + 1) if q else ""
                except Exception:  # noqa: BLE001
                    texto = "?"
            linhas.append(f"{'  ' * prof}{n.role} | name='{n.name}' | states={n.states}"
                          + (f" | texto='{texto}'" if n.tem_texto else ""))
            for f in n.filhos:
                escrever(f, prof + 1)

        escrever(raiz)
    linhas.append(f"===== DLL: {localizar_dll()}")
    linhas.append("===== janelas vistas: " + "; ".join(f"{j['titulo']} (pid {j['pid']})" for j in janelas_ts()))
    destino.write_text("\n".join(linhas), encoding="utf-8")
    return destino, len(linhas)
