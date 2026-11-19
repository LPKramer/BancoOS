"""Rotas do robô do TS (fase 2). O robô roda no mesmo PC do servidor, no TS que ele mesmo abre."""
from __future__ import annotations

from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/robo")


def _usuario(x_usuario: str | None = Header(default=None)) -> str:
    return (x_usuario or "").strip()[:80]


@router.get("/status")
def status():
    from ..robot import ambiente
    from ..robot.worker import ROBO

    return {"ambiente": ambiente.verificar(), "execucao": ROBO.estado()}


@router.post("/ativar-acessibilidade")
def ativar_acessibilidade(usuario: str = Depends(_usuario)):
    from .. import db, servicos
    from ..robot import ambiente

    ambiente.ativar_acessibilidade()
    with db.sessao() as s:
        servicos.auditar(s, usuario, "ativar_acessibilidade_java", str(ambiente.ARQ_ACESSIBILIDADE))
        s.commit()
    return ambiente.verificar()


@router.post("/diagnostico")
def diagnostico():
    from ..robot import diagnostico as diag

    try:
        caminho, linhas = diag.gerar()
    except Exception as e:  # noqa: BLE001
        raise HTTPException(400, f"{type(e).__name__}: {e}")
    return {"arquivo": str(caminho), "linhas": linhas}


class Executar(BaseModel):
    correcoes: list[int] | None = None  # vazio = todas as aprovadas
    modo_teste: bool = True


@router.post("/executar")
def executar(dados: Executar, usuario: str = Depends(_usuario)):
    from ..robot.worker import ROBO

    if not usuario:
        raise HTTPException(400, "Escolha o analista antes de rodar o robô")
    try:
        return ROBO.iniciar(dados.correcoes, dados.modo_teste, usuario)
    except RuntimeError as e:
        raise HTTPException(400, str(e))


@router.post("/parar")
def parar():
    from ..robot.worker import ROBO

    ROBO.parar()
    return ROBO.estado()
