"""Leitura de bancos Access (.accdb/.mdb) sem Access nem driver ACE instalados.

Usa a biblioteca `access-parser` (Python puro). Ela falha ao montar o catálogo de alguns
arquivos por causa de um campo memo com "overflow" dentro de MSysObjects; o contorno abaixo
devolve vazio só para esse campo e conta as ocorrências, para que a importação possa
recusar uma tabela de dados em que algum memo (ex.: DES_INTV_MNB) não tenha sido lido.
"""
from __future__ import annotations

import logging
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import pandas as pd
import access_parser.access_parser as _ap

# Objetos do MSysObjects (coluna Type)
TIPO_TABELA = 1
TIPO_CONSULTA = 5
TIPO_FORMULARIO = -32768

# Atributos do MSysQueries (mesmo layout usado pelo Jackcess)
A_TIPO = 1
A_PARAMETRO = 2
A_FLAGS = 3
A_TABELA = 5
A_COLUNA = 6
A_JOIN = 7
A_WHERE = 8
A_GROUP_BY = 9
A_HAVING = 10
A_ORDER_BY = 11

TIPOS_CONSULTA = {
    1: "SELECT",
    2: "MAKE TABLE",
    3: "APPEND",
    4: "UPDATE",
    5: "DELETE",
    6: "CROSSTAB",
    7: "DDL",
    8: "PASSTHROUGH",
    9: "UNION",
}
JOINS = {1: "INNER JOIN", 2: "LEFT JOIN", 3: "RIGHT JOIN"}

logging.getLogger("access_parser").setLevel(logging.CRITICAL)
logging.getLogger("access_parser.access_parser").setLevel(logging.CRITICAL)

_falhas_memo: dict[str, int] = defaultdict(int)
_tabela_atual: list[str] = [""]
_parse_memo_original = _ap.AccessTable._parse_memo


def _parse_memo_tolerante(self, *args, **kwargs):
    try:
        return _parse_memo_original(self, *args, **kwargs)
    except Exception:  # noqa: BLE001 - registro de overflow ilegível
        _falhas_memo[_tabela_atual[0]] += 1
        return b"" if kwargs.get("return_raw") else ""


_ap.AccessTable._parse_memo = _parse_memo_tolerante


class MemoIlegivel(RuntimeError):
    """Algum campo memo de uma tabela de dados não pôde ser lido."""


@dataclass
class Consulta:
    nome: str
    tipo: str
    sql: str
    tabelas: list[str] = field(default_factory=list)


def _limpar(nome: str | None) -> str:
    return (nome or "").strip()


def _ref(nome: str) -> str:
    """Nome de tabela entre colchetes quando precisa (espaços, acentos, sinais)."""
    if nome.replace("_", "").isalnum() and nome.isascii():
        return nome
    return f"[{nome}]"


class AccessDB:
    def __init__(self, caminho: str | Path):
        self.caminho = Path(caminho)
        _tabela_atual[0] = "MSysObjects"
        self._db = _ap.AccessParser(str(self.caminho))
        self._objetos = self._ler_bruto("MSysObjects")
        self._ids = {n: i for n, i in zip(self._objetos["Name"], self._objetos["Id"])}
        self._linhas_consultas: dict[int, list[tuple]] | None = None

    # ------------------------------------------------------------------ tabelas
    def _ler_bruto(self, nome: str) -> dict:
        if nome not in self._db.catalog and nome in getattr(self, "_ids", {}):
            self._db.catalog[nome] = self._ids[nome]
        _tabela_atual[0] = nome
        return self._db.parse_table(nome) or {}

    def objetos(self, tipo: int) -> list[str]:
        return sorted(n for n, t in zip(self._objetos["Name"], self._objetos["Type"]) if t == tipo)

    def tabelas(self, incluir_sistema: bool = False) -> list[str]:
        nomes = self.objetos(TIPO_TABELA)
        if incluir_sistema:
            return nomes
        return [n for n in nomes if not n.startswith(("MSys", "~", "f_")) and "ImportarError" not in n]

    def ler_tabela(self, nome: str, exigir_memos: bool = True) -> pd.DataFrame:
        _falhas_memo[nome] = 0
        bruto = self._ler_bruto(nome)
        if exigir_memos and _falhas_memo[nome]:
            raise MemoIlegivel(f"{_falhas_memo[nome]} campo(s) memo ilegível(is) na tabela {nome!r}")
        if not bruto:
            return pd.DataFrame()
        if not all(isinstance(v, list) for v in bruto.values()):
            # tabela sem nenhuma linha: o parser devolve só a definição das colunas
            return pd.DataFrame(columns=list(bruto.keys()))
        return pd.DataFrame(bruto)

    def falhas_memo(self, nome: str) -> int:
        return _falhas_memo.get(nome, 0)

    # ---------------------------------------------------------------- consultas
    def _consultas_brutas(self) -> dict[int, list[tuple]]:
        if self._linhas_consultas is None:
            q = self._ler_bruto("MSysQueries")
            por_objeto: dict[int, list[tuple]] = defaultdict(list)
            for oid, attr, flag, n1, n2, expr, ordem in zip(
                q["ObjectId"], q["Attribute"], q["Flag"], q["Name1"], q["Name2"], q["Expression"], q["Order"]
            ):
                por_objeto[oid].append((attr, flag, _limpar(n1), _limpar(n2), expr or "", bytes(ordem or b"")))
            for linhas in por_objeto.values():
                linhas.sort(key=lambda r: (r[0], r[5]))
            self._linhas_consultas = por_objeto
        return self._linhas_consultas

    def consultas(self) -> list[Consulta]:
        return [self.consulta(n) for n in self.objetos(TIPO_CONSULTA)]

    def consulta(self, nome: str) -> Consulta:
        linhas = self._consultas_brutas().get(self._ids[nome], [])
        return reconstruir_sql(nome, linhas)


def reconstruir_sql(nome: str, linhas: list[tuple]) -> Consulta:
    """Monta um SQL legível a partir das linhas do MSysQueries de uma consulta.

    O objetivo é documentar a lógica (expressões, filtros, joins) para portar as regras;
    a sintaxe de joins aninhados do Access é simplificada para uma sequência linear.
    """
    def por_attr(a: int) -> list[tuple]:
        return [r for r in linhas if r[0] == a]

    tipo_linha = por_attr(A_TIPO)
    tipo_cod = tipo_linha[0][1] if tipo_linha else 1
    tipo = TIPOS_CONSULTA.get(tipo_cod, f"TIPO {tipo_cod}")
    alvo = tipo_linha[0][2] if tipo_linha else ""
    flags = (por_attr(A_FLAGS) or [(0, 0)])[0][1] or 0

    tabelas = por_attr(A_TABELA)
    nomes_tabelas = [t[2] for t in tabelas if t[2]]

    if tipo == "UNION":
        partes = [t[4] for t in tabelas if t[4]]
        sql = "\nUNION\n".join(partes) if partes else ""
        return Consulta(nome, tipo, sql, nomes_tabelas)
    if tipo in ("PASSTHROUGH", "DDL"):
        return Consulta(nome, tipo, tipo_linha[0][4] if tipo_linha else "", nomes_tabelas)

    colunas = []
    destinos = []
    for _, _, n1, n2, expr, _ in por_attr(A_COLUNA):
        if tipo == "UPDATE":
            colunas.append(f"{n2 or n1} = {expr}")
            continue
        item = expr
        if n1:
            item += f" AS [{n1}]"
        colunas.append(item)
        destinos.append(n2)

    # FROM com joins: linhas do mesmo par de tabelas são uma só ligação (condições com AND)
    pares: dict[tuple[str, str], tuple[int, list[str]]] = {}
    for _, flag, esq, dir_, expr, _ in por_attr(A_JOIN):
        chave = (esq, dir_)
        if chave in pares:
            pares[chave][1].append(expr)
        else:
            pares[chave] = (flag, [expr])
    usadas: list[str] = []
    origem = ""
    for (esq, dir_), (flag, exprs) in pares.items():
        tipo_join = JOINS.get(flag, "JOIN")
        if not origem:
            origem = _ref(esq)
            usadas.append(esq)
        novo = dir_ if dir_ not in usadas else esq
        origem += f"\n  {tipo_join} {_ref(novo)} ON " + " AND ".join(exprs)
        usadas.append(novo)
    restantes = []
    for _, _, n1, n2, expr, _ in tabelas:
        if n1 and n1 not in usadas:
            restantes.append(_ref(n1) + (f" AS {_ref(n2)}" if n2 else ""))
        elif not n1 and expr:  # subconsulta
            restantes.append(f"({expr})" + (f" AS {_ref(n2)}" if n2 else ""))
    origem = ", ".join([o for o in [origem] if o] + restantes)

    where = [r[4] for r in por_attr(A_WHERE) if r[4]]
    group = [r[4] for r in por_attr(A_GROUP_BY) if r[4]]
    having = [r[4] for r in por_attr(A_HAVING) if r[4]]
    order = [r[4] + (" DESC" if r[2].upper() == "D" else "") for r in por_attr(A_ORDER_BY) if r[4]]
    params = [f"{r[2]}" for r in por_attr(A_PARAMETRO) if r[2]]

    distinto = "DISTINCT " if flags & 0x2 else ""
    partes = []
    if params:
        partes.append("PARAMETERS " + ", ".join(params) + ";")
    if tipo == "DELETE":
        partes.append(f"DELETE {', '.join(colunas)}")
        partes.append(f"FROM {origem}")
    elif tipo == "UPDATE":
        partes.append(f"UPDATE {origem}")
        partes.append("SET " + ",\n    ".join(colunas))
    else:
        if tipo == "APPEND":
            alvo_cols = ", ".join(d for d in destinos if d)
            partes.append(f"INSERT INTO {_ref(alvo)}" + (f" ({alvo_cols})" if alvo_cols else ""))
        partes.append(f"SELECT {distinto}" + ",\n       ".join(colunas))
        if tipo == "MAKE TABLE":
            partes.append(f"INTO {_ref(alvo)}")
        partes.append(f"FROM {origem}")
    if where:
        partes.append("WHERE " + " AND ".join(where))
    if group:
        partes.append("GROUP BY " + ", ".join(group))
    if having:
        partes.append("HAVING " + " AND ".join(having))
    if order:
        partes.append("ORDER BY " + ", ".join(order))
    return Consulta(nome, tipo, "\n".join(partes) + ";", nomes_tabelas)
