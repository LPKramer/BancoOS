"""Carrega as bases já separadas de um Banco de Análise (.accdb)."""
from __future__ import annotations

from pathlib import Path

import pandas as pd

from ..dados import ENTIDADES, BaseOS, competencia_de, normalizar
from .access import AccessDB

# Tabelas do Access úteis como referência (gabarito de paridade e histórico de correções)
TABELA_RESULTADO_INTERVENCAO = "2 Intervenção Unificada - Filtros"
TABELA_RESULTADO_INDIVIDUAL = "2 Individual Unificada - Filtros"


def carregar_de_access(caminho: str | Path, incluir_resultado_access: bool = True) -> BaseOS:
    db = AccessDB(caminho)
    tabelas = set(db.tabelas())
    dfs: dict[str, pd.DataFrame] = {}
    for entidade, (tabela, _, _) in ENTIDADES.items():
        if tabela not in tabelas:
            raise ValueError(f"Tabela {tabela!r} não existe em {Path(caminho).name}")
        dfs[entidade] = normalizar(entidade, db.ler_tabela(tabela))
    extras: dict[str, pd.DataFrame] = {}
    if incluir_resultado_access:
        for chave, tabela in (("access_intervencao", TABELA_RESULTADO_INTERVENCAO),
                              ("access_individual", TABELA_RESULTADO_INDIVIDUAL)):
            if tabela in tabelas:
                extras[chave] = db.ler_tabela(tabela)
        if "T_Analistas" in tabelas:
            extras["analistas"] = db.ler_tabela("T_Analistas")
    base = BaseOS(**dfs, origem=str(caminho), extras=extras)
    base.competencia = competencia_de(base)
    return base
