"""A interface vai compilada no repositório (o PC da rede corporativa não tem Node)."""
from __future__ import annotations

import re

from fastapi.testclient import TestClient

from osanalise.api.app import PASTA_FRONT, app


def test_interface_compilada():
    index = PASTA_FRONT / "index.html"
    assert index.is_file(), "falta frontend/dist: rode npm run build em frontend e mande o dist no commit"
    referencias = re.findall(r'(?:src|href)="/(assets/[^"]+)"', index.read_text(encoding="utf-8"))
    assert any(r.endswith(".js") for r in referencias) and any(r.endswith(".css") for r in referencias)
    for r in referencias:
        assert (PASTA_FRONT / r).is_file(), f"index.html aponta {r}, que não está em frontend/dist"

    c = TestClient(app)
    assert '<div id="raiz">' in c.get("/fila").text  # rota do React cai no index.html
    js = next(r for r in referencias if r.endswith(".js"))
    assert c.get(f"/{js}").status_code == 200
