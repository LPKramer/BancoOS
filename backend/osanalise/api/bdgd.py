"""Rotas da BDGD: índice e visualizador da manobra."""
from __future__ import annotations

from fastapi import APIRouter, HTTPException
from sqlalchemy import func, select

from .. import db, servicos

router = APIRouter()


@router.get("/api/bdgd/status")
def status():
    from ..bdgd import indice

    info = indice.status()
    with db.sessao() as s:
        info["equivalencias_chave"] = s.scalar(select(func.count()).select_from(db.EquivChave))
    return info


@router.post("/api/bdgd/indexar")
def indexar(forcar: bool = False):
    from ..bdgd import indice

    return indice.construir_em_segundo_plano(forcar)


@router.post("/api/bdgd/aprender/{lote_id}")
def aprender(lote_id: int):
    base = servicos.carregar_base_lote(lote_id)
    r = servicos.aprender_equivalencias(base.compensacao)
    if r is None:
        raise HTTPException(409, "Índice da BDGD ainda não construído")
    return r


@router.get("/api/os/{os_fila_id}/manobra")
def manobra(os_fila_id: int):
    from ..bdgd import manobra as m

    try:
        return m.analisar(os_fila_id)
    except KeyError:
        raise HTTPException(404, "OS não encontrada")
    except m.SemBDGD as e:
        raise HTTPException(409, str(e))
    except ValueError as e:
        raise HTTPException(400, str(e))
