"""Rotas das bases apontadas na tela Importar e dos textos padrões de justificativa."""
from __future__ import annotations

import shutil
import tempfile
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, Header, HTTPException, UploadFile
from pydantic import BaseModel

from .. import fontes, servicos, textos_padrao
from ..config import CONFIG

router = APIRouter()


def _usuario(x_usuario: str | None = Header(default=None)) -> str:
    return (x_usuario or "").strip()[:80]


# ------------------------------------------------------------------ bases apontadas
@router.get("/api/fontes")
def listar_fontes():
    return {t: fontes.situacao(t) for t in fontes.TIPOS}


class Apontar(BaseModel):
    caminho: str


@router.put("/api/fontes/{tipo}")
def apontar(tipo: str, dados: Apontar, usuario: str = Depends(_usuario)):
    """Confere o arquivo e, se estiver certo, grava o caminho para as próximas importações."""
    if tipo not in fontes.TIPOS:
        raise HTTPException(404, "Base desconhecida")
    v = fontes.verificar(tipo, dados.caminho)
    if v["ok"]:
        fontes.salvar_caminho(tipo, v["caminho"], usuario)
    return {**fontes.situacao(tipo), "verificacao": v} if v["ok"] else {
        "tipo": tipo, "nome": fontes.TIPOS[tipo]["nome"], "caminho": dados.caminho, "salvo": False, "verificacao": v}


async def _receber(arquivo: UploadFile, pasta: Path) -> Path:
    nome = Path(arquivo.filename or "arquivo").name
    if Path(nome).suffix.lower() not in fontes.EXTENSOES:
        raise HTTPException(400, f"Tipo de arquivo não aceito: {nome}")
    destino = pasta / nome
    with destino.open("wb") as f:
        while bloco := await arquivo.read(1024 * 1024):
            f.write(bloco)
    return destino


@router.post("/api/lotes/importar-bases")
async def importar_bases(
    critica_arquivo: UploadFile | None = File(None),
    critica_caminho: str | None = Form(None),
    ocorrencias_arquivo: UploadFile | None = File(None),
    ocorrencias_caminho: str | None = Form(None),
    usuario: str = Depends(_usuario),
):
    """Importa a crítica + ocorrências. Cada base vem como arquivo enviado ou caminho no servidor;
    sem nenhum dos dois, usa o caminho apontado antes."""
    from .app import _iniciar_importacao

    pasta = None
    arquivos: dict[str, Path] = {}
    try:
        for tipo, enviado, caminho in (("critica", critica_arquivo, critica_caminho),
                                       ("ocorrencias", ocorrencias_arquivo, ocorrencias_caminho)):
            if enviado is not None and enviado.filename:
                if pasta is None:
                    CONFIG.pasta_uploads.mkdir(parents=True, exist_ok=True)
                    pasta = Path(tempfile.mkdtemp(dir=CONFIG.pasta_uploads))
                arq, do_servidor = await _receber(enviado, pasta), False
            else:
                alvo = (caminho or "").strip() or fontes.caminho_salvo(tipo)
                if not alvo:
                    raise HTTPException(400, f"Aponte a base {fontes.TIPOS[tipo]['nome']}.")
                arq, do_servidor = fontes.limpar_caminho(alvo), True
            v = fontes.verificar(tipo, arq)
            if not v["ok"]:
                raise HTTPException(400, f"{fontes.TIPOS[tipo]['nome']} ({arq.name}): {v['mensagem']}")
            if do_servidor:
                fontes.salvar_caminho(tipo, str(arq), usuario)
            arquivos[tipo] = arq
    except HTTPException:
        if pasta:
            shutil.rmtree(pasta, ignore_errors=True)
        raise
    if arquivos["critica"].resolve() == arquivos["ocorrencias"].resolve():
        raise HTTPException(400, "A crítica e as ocorrências apontam para o mesmo arquivo.")
    critica, ocorrencias = arquivos["critica"], arquivos["ocorrencias"]
    return _iniciar_importacao([critica, ocorrencias], usuario, pasta,
                               executar=lambda: servicos.importar_bases(critica, ocorrencias, usuario))


# ------------------------------------------------------------------ textos padrões
@router.get("/api/textos-padrao")
def listar_textos():
    return {"textos": textos_padrao.listar(), "fonte": fontes.situacao("textos")}


@router.post("/api/textos-padrao/carregar")
async def carregar_textos(arquivo: UploadFile | None = File(None), caminho: str | None = Form(None),
                          usuario: str = Depends(_usuario)):
    """Carrega (ou recarrega) a planilha de textos: enviada agora, pelo caminho dado ou pelo apontado."""
    pasta = None
    try:
        if arquivo is not None and arquivo.filename:
            CONFIG.pasta_uploads.mkdir(parents=True, exist_ok=True)
            pasta = Path(tempfile.mkdtemp(dir=CONFIG.pasta_uploads))
            arq = await _receber(arquivo, pasta)
        else:
            alvo = (caminho or "").strip() or fontes.caminho_salvo("textos") or fontes.sugerido("textos")
            if not alvo:
                raise HTTPException(400, "Aponte a planilha de textos padrões.")
            arq = fontes.limpar_caminho(alvo)
        v = fontes.verificar("textos", arq)
        if not v["ok"]:
            raise HTTPException(400, f"{arq.name}: {v['mensagem']}")
        resumo = textos_padrao.importar(arq, usuario)
        if pasta is None:
            fontes.salvar_caminho("textos", str(arq), usuario)
    finally:
        if pasta:
            shutil.rmtree(pasta, ignore_errors=True)
    return {"resumo": resumo, "textos": textos_padrao.listar(), "fonte": fontes.situacao("textos")}


class EditarTexto(BaseModel):
    categorias: list[str] | None = None
    ativo: bool | None = None


@router.patch("/api/textos-padrao/{texto_id}")
def editar_texto(texto_id: int, dados: EditarTexto, usuario: str = Depends(_usuario)):
    try:
        return textos_padrao.atualizar(texto_id, usuario, dados.categorias, dados.ativo)
    except KeyError:
        raise HTTPException(404, "Texto não encontrado")
    except ValueError as e:
        raise HTTPException(400, str(e))
