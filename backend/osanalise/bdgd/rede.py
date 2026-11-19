"""Topologia de média tensão de alguns alimentadores, a partir do índice da BDGD.

A rede é dividida em seções (trechos ligados sem passar por chave). Uma seção está toda
energizada ou toda desligada, então a simulação da manobra só precisa dizer o estado de cada
seção e de cada trafo a cada passo.
"""
from __future__ import annotations

import sqlite3
from collections import defaultdict, deque
from dataclasses import dataclass, field

from .indice import TIPOS_PROTECAO
from .leitor import Shp, codificar_linhas

FECHADA = "F"


@dataclass
class Chave:
    cod_id: str
    pac1: str
    pac2: str
    tip_unid: str
    normal_fechada: bool
    cap_elo: str
    lat: float | None
    lon: float | None
    ctmt1: str | None
    ctmt2: str | None

    @property
    def tipo(self) -> str:
        return TIPOS_PROTECAO.get(self.tip_unid, "Chave")

    @property
    def protecao(self) -> bool:
        # chave do próprio trafo ("...CT") e chave com lâmina não delimitam zona de proteção
        return self.tip_unid in TIPOS_PROTECAO and not self.cod_id.endswith("CT") and self.cap_elo != "LAM"


@dataclass
class Trafo:
    i: int
    cod_id: str
    pac1: str
    ctmt: str
    pot: float | None
    lat: float | None
    lon: float | None
    n_ucs: int


@dataclass
class Rede:
    ctmts: list[dict]
    adj: dict = field(default_factory=lambda: defaultdict(list))  # nó -> [(vizinho, tipo, id)]
    segs: dict = field(default_factory=dict)  # idx -> (pac1, pac2)
    chaves: dict = field(default_factory=dict)  # cod_id -> Chave
    trafos: list = field(default_factory=list)
    fontes: set = field(default_factory=set)
    secao_do_no: dict = field(default_factory=dict)
    secoes_segs: dict = field(default_factory=lambda: defaultdict(list))

    # ------------------------------------------------------------ montagem
    @classmethod
    def carregar(cls, con: sqlite3.Connection, ctmts: list[str]) -> "Rede":
        marcas = ",".join("?" * len(ctmts))
        info = [dict(r) for r in con.execute(f"SELECT * FROM ctmt WHERE cod_id IN ({marcas})", ctmts)]
        rede = cls(ctmts=info)
        conjunto = set(ctmts)
        for r in con.execute(f"SELECT idx, pac1, pac2 FROM seg WHERE ctmt IN ({marcas})", ctmts):
            rede.segs[r["idx"]] = (r["pac1"], r["pac2"])
            rede.adj[r["pac1"]].append((r["pac2"], "S", r["idx"]))
            rede.adj[r["pac2"]].append((r["pac1"], "S", r["idx"]))
        for r in con.execute(f"SELECT * FROM chave WHERE ctmt1 IN ({marcas}) OR ctmt2 IN ({marcas})", ctmts + ctmts):
            c = Chave(r["cod_id"], r["pac1"], r["pac2"], r["tip_unid"], r["p_n_ope"] == FECHADA, r["cap_elo"] or "",
                      r["lat"], r["lon"], r["ctmt1"], r["ctmt2"])
            rede.chaves[c.cod_id] = c
            rede.adj[c.pac1].append((c.pac2, "C", c.cod_id))
            rede.adj[c.pac2].append((c.pac1, "C", c.cod_id))
            # lado da chave que pertence a outro alimentador (não carregado): tratado como fonte energizada
            for pac, ct in ((c.pac1, r["ctmt1"]), (c.pac2, r["ctmt2"])):
                if ct and ct not in conjunto and pac not in rede.adj_seg_conhecido(pac):
                    rede.fontes.add(pac)
        for r in con.execute(f"SELECT cod_id, pac1, pac2 FROM regulador WHERE ctmt IN ({marcas})", ctmts):
            rede.adj[r["pac1"]].append((r["pac2"], "R", r["cod_id"]))
            rede.adj[r["pac2"]].append((r["pac1"], "R", r["cod_id"]))
        for r in con.execute(f"SELECT * FROM trafo WHERE ctmt IN ({marcas})", ctmts):
            rede.trafos.append(Trafo(len(rede.trafos), r["cod_id"], r["pac1"], r["ctmt"], r["pot"], r["lat"],
                                     r["lon"], r["n_ucs"] or 0))
        rede.fontes |= {c["pac_ini"] for c in info if c["pac_ini"]}
        rede._secionar()
        return rede

    def adj_seg_conhecido(self, pac: str) -> set:
        return {pac} if any(t == "S" for _, t, _ in self.adj.get(pac, ())) else set()

    def _secionar(self) -> None:
        """Seções = componentes ligados por trechos e reguladores (sem chaves)."""
        sec = 0
        for inicio in list(self.adj):
            if inicio in self.secao_do_no:
                continue
            pilha = [inicio]
            self.secao_do_no[inicio] = sec
            while pilha:
                n = pilha.pop()
                for m, t, eid in self.adj[n]:
                    if t == "S":
                        self.secoes_segs[sec].append(eid)
                    if t in ("S", "R") and m not in self.secao_do_no:
                        self.secao_do_no[m] = sec
                        pilha.append(m)
            sec += 1
        for s in self.secoes_segs:
            self.secoes_segs[s] = sorted(set(self.secoes_segs[s]))

    # ------------------------------------------------------------ estado
    def energizados(self, chaves_fechadas: dict[str, bool], alimentadores_desligados: set[str] | None = None) -> set:
        """Nós energizados a partir das fontes, com o estado de chaves dado (padrão: estado normal).

        `alimentadores_desligados`: alimentadores com o disjuntor de saída aberto (a saída deixa de ser fonte).
        """
        desligadas = {c["pac_ini"] for c in self.ctmts if c["cod_id"] in (alimentadores_desligados or ())}
        vistos = set(f for f in self.fontes if (f in self.adj or f in self.secao_do_no) and f not in desligadas)
        fila = deque(vistos)
        while fila:
            n = fila.popleft()
            for m, t, eid in self.adj[n]:
                if m in vistos:
                    continue
                if t == "C" and not chaves_fechadas.get(eid, self.chaves[eid].normal_fechada):
                    continue
                vistos.add(m)
                fila.append(m)
        return vistos

    def trafos_energizados(self, nos: set, trafos_abertos: set[str] | None = None) -> set[int]:
        abertos = trafos_abertos or set()
        return {t.i for t in self.trafos if t.pac1 in nos and t.cod_id not in abertos}

    # ------------------------------------------------------------ árvore normal
    def arvore(self) -> tuple[dict, dict]:
        """BFS no estado normal: pai de cada nó e a aresta usada (tipo, id)."""
        pai, aresta = {}, {}
        fila = deque()
        for f in self.fontes:
            if f in self.adj:
                pai[f] = None
                fila.append(f)
        while fila:
            n = fila.popleft()
            for m, t, eid in self.adj[n]:
                if m in pai or (t == "C" and not self.chaves[eid].normal_fechada):
                    continue
                pai[m], aresta[m] = n, (t, eid)
                fila.append(m)
        return pai, aresta

    # ------------------------------------------------------------ desenho
    def geometria_secoes(self, pasta_bdgd) -> dict[int, list[list[int]]]:
        shp = Shp(pasta_bdgd / "SSDMT")
        try:
            saida = {}
            for sec, idxs in self.secoes_segs.items():
                linhas = [ln for ln in (shp.linha(i) for i in idxs) if ln]
                if linhas:
                    saida[sec] = codificar_linhas(linhas)
            return saida
        finally:
            shp.fechar()
