"""Compara o resultado do app com a tabela de resultado do Banco de Análise (gabarito).

Uso:
    python -m osanalise.rules.paridade "<Banco de Análise.accdb>"
"""
from __future__ import annotations

import sys
from dataclasses import dataclass

import pandas as pd

from ..dados import BaseOS
from .base import COL_OS, REGISTRO
from .motor import ResultadoRegras, executar


@dataclass
class LinhaParidade:
    regra_id: str
    coluna_access: str
    app: int
    access: int
    so_app: list[str]
    so_access: list[str]
    divergencia_conhecida: str | None

    @property
    def ok(self) -> bool:
        return not self.so_app and not self.so_access


def _marcadas(df: pd.DataFrame, coluna: str) -> set[str]:
    if coluna not in df:
        return set()
    s = df[coluna].astype("string").str.strip()
    return set(df.loc[s.notna() & (s != "") & (s != "-"), "NUM_SEQ_OPER_OS_MNB"].astype(str))


def comparar(base: BaseOS, res: ResultadoRegras | None = None) -> tuple[list[LinhaParidade], dict]:
    res = res or executar(base)
    acc = base.extras.get("access_intervencao")
    if acc is None:
        raise ValueError("A base não tem a tabela de resultado do Access (importe de um .accdb)")
    fila_app = set(res.fila.loc[res.fila["tipo_os"] == "intervencao", "os"]) if len(res.fila) else set()
    fila_access = set(acc["NUM_SEQ_OPER_OS_MNB"].astype(str))
    comuns = fila_app & fila_access  # a lógica de cada regra é comparada nas OS que estão nas duas filas
    linhas = []
    for r in REGISTRO.values():
        if r.tipo_os != "intervencao" or not r.coluna_access:
            continue
        app = set(res.flags.loc[res.flags["regra_id"] == r.id, COL_OS]) & comuns
        access = _marcadas(acc, r.coluna_access) & comuns
        linhas.append(LinhaParidade(r.id, r.coluna_access, len(app), len(access),
                                    sorted(app - access), sorted(access - app), r.divergencia_access))

    # OS que só o app põe na fila: explicadas se, sem as regras com divergência conhecida, sairiam da fila
    divergentes = {r.id for r in REGISTRO.values() if r.divergencia_access}
    por_os = res.flags[res.flags["tipo_os"] == "intervencao"].groupby(COL_OS)["regra_id"].apply(set)
    so_app = sorted(fila_app - fila_access)
    explicadas = []
    for os_ in so_app:
        restantes = sorted(por_os.get(os_, set()) - divergentes)
        if not restantes or (len(restantes) == 1 and not REGISTRO[restantes[0]].sozinha_basta):
            explicadas.append(os_)
    resumo = {
        "fila_app": len(fila_app),
        "fila_access": len(fila_access),
        "fila_comum": len(comuns),
        "so_fila_app": so_app,
        "so_fila_app_explicadas": explicadas,
        "so_fila_access": sorted(fila_access - fila_app),
    }
    acc_ind = base.extras.get("access_individual")
    if acc_ind is not None and len(res.fila):
        ind_app = set(res.fila.loc[res.fila["tipo_os"] == "individual", "os"])
        ind_acc = set(acc_ind["NUM_SEQ_OPER_CNR"].astype(str))
        resumo.update(individual_app=len(ind_app), individual_access=len(ind_acc),
                      so_individual_app=sorted(ind_app - ind_acc), so_individual_access=sorted(ind_acc - ind_app))
    return linhas, resumo


def relatorio(linhas: list[LinhaParidade], resumo: dict) -> str:
    out = [f"Fila de intervenções: app {resumo['fila_app']} x Access {resumo['fila_access']} "
           f"(comuns {resumo['fila_comum']}, só app {len(resumo['so_fila_app'])} "
           f"[{len(resumo['so_fila_app_explicadas'])} explicadas pelas divergências conhecidas], "
           f"só Access {len(resumo['so_fila_access'])})"]
    if "individual_app" in resumo:
        out.append(f"Fila de individuais: app {resumo['individual_app']} x Access {resumo['individual_access']}")
    out.append("")
    out.append(f"{'regra':38s} {'app':>6s} {'access':>6s} {'só app':>7s} {'só acc':>7s}")
    for l in linhas:
        nota = "  ok" if l.ok else ("  divergência conhecida" if l.divergencia_conhecida else "  DIFERENTE")
        out.append(f"{l.regra_id:38s} {l.app:6d} {l.access:6d} {len(l.so_app):7d} {len(l.so_access):7d}{nota}")
    return "\n".join(out)


if __name__ == "__main__":
    from ..importers.base_access import carregar_de_access

    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    b = carregar_de_access(sys.argv[1])
    ls, rs = comparar(b)
    print(relatorio(ls, rs))
