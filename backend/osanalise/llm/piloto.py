"""Piloto do LLM: amostra de OS com histórico do Access, roda a análise pelo app e mede o acerto.

    python -m osanalise.llm.piloto --lote 1 --n 50

Gabarito disponível: o Access só marca as OS CORRIGIDAS ("Correção Realizada", com categorias
Classificação / OS vinculada / Passo de manobra / Horário). Uma OS não corrigida pode estar certa
ou só não ter sido analisada, então nesse grupo o piloto mostra a distribuição dos vereditos,
sem chamar de acerto ou erro.
"""
from __future__ import annotations

import argparse
import csv
import random
import time
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime

from sqlalchemy import select

from .. import db
from ..config import CONFIG
from ..db import AnaliseLLM, OSFila
from .analisador import analisar_os
from .catalogo import TIPOS_CORRECAO
from .provedor import criar_provedor

NOMES_CATEGORIA = {"classificacao": "Classificação", "os_vinculada": "OS vinculada", "passo_manobra": "Passo de manobra",
                   "horario": "Horário", "elemento_origem": "Elemento de origem"}


def selecionar(lote_id: int, n: int, semente: int = 7) -> tuple[list[int], list[int]]:
    rnd = random.Random(semente)
    with db.sessao() as s:
        base = select(OSFila).where(OSFila.lote_id == lote_id, OSFila.tipo_os == "intervencao")
        corrigidas = list(s.scalars(base.where(OSFila.access_corrigida.is_(True))))
        outras = list(s.scalars(base.where(OSFila.access_corrigida.is_(False))))
    metade = n // 2
    # corrigidas com categoria, alternando as categorias para variar os tipos de erro
    por_cat: dict[str, list[OSFila]] = {}
    for o in corrigidas:
        for c in o.access_categorias or []:
            por_cat.setdefault(c, []).append(o)
    for lista in por_cat.values():
        rnd.shuffle(lista)
    escolhidas: list[int] = []
    while len(escolhidas) < metade and any(por_cat.values()):
        for c in sorted(por_cat):
            while por_cat[c] and por_cat[c][-1].id in escolhidas:
                por_cat[c].pop()
            if por_cat[c] and len(escolhidas) < metade:
                escolhidas.append(por_cat[c].pop().id)
    resto = [o.id for o in corrigidas if o.id not in escolhidas]
    rnd.shuffle(resto)
    escolhidas += resto[:metade - len(escolhidas)]
    nao = [o.id for o in outras]
    rnd.shuffle(nao)
    return escolhidas, nao[:n - len(escolhidas)]


def rodar(lote_id: int, n: int, forcar: bool = False, semente: int = 7) -> dict:
    corrigidas, nao_corrigidas = selecionar(lote_id, n, semente)
    provedor = criar_provedor()
    inicio = time.time()
    with ThreadPoolExecutor(max_workers=max(1, CONFIG.llm_paralelo)) as ex:
        resultados = list(ex.map(lambda i: analisar_os(i, provedor, forcar, "piloto LLM"), corrigidas + nao_corrigidas))
    segundos = time.time() - inicio
    ids_analise = [r.analise_id for r in resultados if r.analise_id]
    linhas = []
    with db.sessao() as s:
        analises = {a.id: a for a in s.scalars(select(AnaliseLLM).where(AnaliseLLM.id.in_(ids_analise)))}
        for r in resultados:
            o = s.get(OSFila, r.os_fila_id)
            a = analises.get(r.analise_id)
            sugeridas = [c["tipo"] for c in (a.resposta or {}).get("correcoes", [])] if a and a.resposta else []
            cats_llm = {TIPOS_CORRECAO[t]["categoria_access"] for t in sugeridas if t in TIPOS_CORRECAO}
            cats_access = set(o.access_categorias or [])
            linhas.append({
                "os": o.os, "grupo": "corrigida no Access" if o.access_corrigida else "não corrigida",
                "categorias_access": ", ".join(NOMES_CATEGORIA.get(c, c) for c in sorted(cats_access)),
                "regras": ", ".join(o.regras or []), "veredito": a.veredito if a else None,
                "confianca": a.confianca if a else None, "correcoes_llm": ", ".join(sugeridas),
                "categoria_bate": (bool(cats_llm & cats_access) if cats_access and a and a.veredito == "errada" else None),
                "resumo_llm": ((a.resposta or {}).get("resumo") if a else None) or "",
                "erro": r.erro or (a.erro if a else None), "reaproveitada": r.reaproveitada,
                "tokens_entrada": a.tokens_entrada if a else None, "tokens_saida": a.tokens_saida if a else None,
                "tokens_cache": a.tokens_cache if a else None,
            })
    return {"linhas": linhas, "segundos": segundos, "modelo": provedor.modelo, "semente": semente}


def resumir(res: dict) -> dict:
    linhas = res["linhas"]
    corr = [l for l in linhas if l["grupo"] == "corrigida no Access" and not l["erro"]]
    nao = [l for l in linhas if l["grupo"] == "não corrigida" and not l["erro"]]
    v_corr, v_nao = Counter(l["veredito"] for l in corr), Counter(l["veredito"] for l in nao)
    com_cat = [l for l in corr if l["categoria_bate"] is not None]
    soma = lambda k: sum(l[k] or 0 for l in linhas if not l["reaproveitada"])  # noqa: E731
    from .prompts import VERSAO_PROMPT

    return {
        "modelo": res["modelo"], "prompt": VERSAO_PROMPT, "semente": res.get("semente"),
        "segundos": round(res["segundos"]), "total": len(linhas),
        "erros": sum(1 for l in linhas if l["erro"]),
        "corrigidas": len(corr), "corrigidas_vereditos": dict(v_corr),
        "cobertura_errada": v_corr["errada"] / len(corr) if corr else None,
        "categoria_bate": sum(l["categoria_bate"] for l in com_cat) / len(com_cat) if com_cat else None,
        "categoria_avaliadas": len(com_cat),
        "nao_corrigidas": len(nao), "nao_corrigidas_vereditos": dict(v_nao),
        "tokens_entrada": soma("tokens_entrada"), "tokens_saida": soma("tokens_saida"), "tokens_cache": soma("tokens_cache"),
    }


def gravar(res: dict, resumo: dict) -> tuple[str, str]:
    pasta = CONFIG.pasta_dados / "relatorios"
    pasta.mkdir(parents=True, exist_ok=True)
    carimbo = datetime.now().strftime("%Y%m%d_%H%M%S")
    arq_csv = pasta / f"piloto_llm_{carimbo}.csv"
    with open(arq_csv, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=list(res["linhas"][0].keys()), delimiter=";")
        w.writeheader()
        w.writerows(res["linhas"])
    pct = lambda v: "—" if v is None else f"{v:.0%}"  # noqa: E731
    mil = lambda v: f"{v:,}".replace(",", ".")  # noqa: E731
    md = [f"# Piloto do LLM ({resumo['modelo']}, prompt {resumo['prompt']}, amostra {resumo['semente']}) — "
          f"{datetime.now():%d/%m/%Y %H:%M}", "",
          f"- OS analisadas: {resumo['total']} ({resumo['erros']} com erro de chamada), {resumo['segundos']} s",
          f"- Corrigidas no Access: {resumo['corrigidas']} — LLM disse errada em {pct(resumo['cobertura_errada'])} "
          f"{resumo['corrigidas_vereditos']}",
          f"- Tipo de correção bate com a categoria do Access: {pct(resumo['categoria_bate'])} "
          f"({resumo['categoria_avaliadas']} OS avaliadas)",
          f"- Não corrigidas (sem gabarito): {resumo['nao_corrigidas']} — {resumo['nao_corrigidas_vereditos']}",
          f"- Tokens: entrada {mil(resumo['tokens_entrada'])} (do cache {mil(resumo['tokens_cache'])}), "
          f"saída {mil(resumo['tokens_saida'])}", ""]
    arq_md = pasta / f"piloto_llm_{carimbo}.md"
    arq_md.write_text("\n".join(md), encoding="utf-8")
    return str(arq_csv), str(arq_md)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--lote", type=int, required=True)
    ap.add_argument("--n", type=int, default=50)
    ap.add_argument("--forcar", action="store_true", help="reanalisa mesmo se já houver análise igual")
    ap.add_argument("--semente", type=int, default=7, help="muda a amostra sorteada")
    a = ap.parse_args()
    res = rodar(a.lote, a.n, a.forcar, a.semente)
    resumo = resumir(res)
    csv_, md_ = gravar(res, resumo)
    print(open(md_, encoding="utf-8").read())
    print("Detalhe por OS:", csv_)
