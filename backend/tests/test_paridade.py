"""Paridade com o Banco de Análise real (pula se o .accdb não estiver na pasta do projeto)."""
from __future__ import annotations

from pathlib import Path

import pytest

ACCDB = Path(__file__).resolve().parents[2] / "Banco de Análise -Base - nova.accdb"


@pytest.mark.skipif(not ACCDB.exists(), reason="Banco de Análise não encontrado")
def test_regras_iguais_ao_access():
    from osanalise.importers.base_access import carregar_de_access
    from osanalise.rules.paridade import comparar

    base = carregar_de_access(ACCDB)
    linhas, resumo = comparar(base)
    diferentes = [l.regra_id for l in linhas if not l.ok and not l.divergencia_conhecida]
    assert diferentes == []
    assert resumo["so_fila_access"] == []
    assert len(resumo["so_fila_app"]) == len(resumo["so_fila_app_explicadas"])
    if "individual_app" in resumo:
        assert resumo["so_individual_app"] == [] and resumo["so_individual_access"] == []
