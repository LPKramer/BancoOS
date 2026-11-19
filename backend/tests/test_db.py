"""Migração automática do banco quando várias conexões sobem juntas."""
from __future__ import annotations

import threading

from sqlalchemy import inspect, text

from osanalise import db


def test_migracao_concorrente(tmp_path):
    arq = tmp_path / "antigo.db"
    eng = db.criar_engine(arq)
    with eng.begin() as con:  # simula um banco de versão anterior, sem a coluna nova
        con.execute(text("ALTER TABLE os_fila DROP COLUMN justificativa_ts"))
    eng.dispose()

    erros = []

    def subir():
        try:
            db.criar_engine(arq).dispose()
        except Exception as e:  # noqa: BLE001
            erros.append(e)

    ts = [threading.Thread(target=subir) for _ in range(6)]
    for t in ts:
        t.start()
    for t in ts:
        t.join()
    assert not erros
    colunas = {c["name"] for c in inspect(db.criar_engine(arq)).get_columns("os_fila")}
    assert "justificativa_ts" in colunas
