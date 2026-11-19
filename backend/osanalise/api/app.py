"""API HTTP do app + entrega do frontend (frontend/dist)."""
from __future__ import annotations

import io
import shutil
import tempfile
import threading
import uuid
from datetime import datetime
from pathlib import Path

import pandas as pd
from fastapi import Depends, FastAPI, File, Header, HTTPException, Query, UploadFile
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy import func, or_, select

from .. import db, servicos
from ..config import CONFIG, PASTA_PROJETO, chave_deepseek
from ..db import Analista, AnaliseLLM, Auditoria, Correcao, Flag, Lote, OSFila
from ..llm.catalogo import TIPOS_CORRECAO
from ..rules.base import REGISTRO

app = FastAPI(title="Análise de OS", version="0.1.0")
PASTA_FRONT = PASTA_PROJETO / "frontend" / "dist"


def usuario_atual(x_usuario: str | None = Header(default=None)) -> str:
    return (x_usuario or "").strip()[:80]


# ------------------------------------------------------------------ geral
@app.get("/api/saude")
def saude():
    return {"ok": True, "hora": datetime.now().isoformat(timespec="seconds")}


@app.get("/api/config")
def config():
    return {"llm_provedor": CONFIG.llm_provedor, "llm_modelo": CONFIG.llm_modelo,
            "llm_configurado": bool(chave_deepseek()), "llm_mascarar": CONFIG.llm_mascarar,
            "status_os": servicos.STATUS_OS, "responsaveis": servicos.RESPONSAVEIS,
            "categorias_correcao": servicos.CATEGORIAS_ACCESS}


@app.get("/api/regras")
def regras():
    return [{"id": r.id, "nome": r.nome, "descricao": r.descricao, "tipo_os": r.tipo_os,
             "sozinha_basta": r.sozinha_basta, "coluna_access": r.coluna_access, "consulta_access": r.consulta_access,
             "correcao_tipica": r.correcao_tipica, "divergencia_access": r.divergencia_access}
            for r in REGISTRO.values()]


@app.get("/api/tipos-correcao")
def tipos_correcao():
    return TIPOS_CORRECAO


@app.get("/api/analistas")
def analistas():
    with db.sessao() as s:
        return [a.nome for a in s.scalars(select(Analista).where(Analista.ativo.is_(True)).order_by(Analista.nome))]


class NovoAnalista(BaseModel):
    nome: str


@app.post("/api/analistas")
def criar_analista(dados: NovoAnalista, usuario: str = Depends(usuario_atual)):
    nome = dados.nome.strip().upper()[:80]
    if not nome:
        raise HTTPException(400, "Informe o nome")
    with db.sessao() as s:
        a = s.get(Analista, nome) or Analista(nome=nome)
        a.ativo = True
        s.merge(a)
        servicos.auditar(s, usuario, "criar_analista", nome)
        s.commit()
    return {"nome": nome}


# ------------------------------------------------------------------ lotes
IMPORTACOES: dict[str, dict] = {}


def _lote_dict(l: Lote, fila: int | None = None) -> dict:
    d = {c.name: getattr(l, c.name) for c in Lote.__table__.columns}
    d["nome_origem"] = " + ".join(Path(p.strip()).name for p in (l.origem or "").split(" + "))
    if fila is not None:
        d["fila"] = fila
    return d


@app.get("/api/lotes")
def listar_lotes():
    with db.sessao() as s:
        contagem = dict(s.execute(select(OSFila.lote_id, func.count()).group_by(OSFila.lote_id)).all())
        return [_lote_dict(l, contagem.get(l.id, 0)) for l in s.scalars(select(Lote).order_by(Lote.id.desc()))]


@app.get("/api/lotes/{lote_id}")
def obter_lote(lote_id: int):
    with db.sessao() as s:
        l = s.get(Lote, lote_id)
        if not l:
            raise HTTPException(404, "Lote não encontrado")
        n = s.scalar(select(func.count()).select_from(OSFila).where(OSFila.lote_id == lote_id))
        return _lote_dict(l, n)


@app.delete("/api/lotes/{lote_id}")
def excluir_lote(lote_id: int, usuario: str = Depends(usuario_atual)):
    servicos.excluir_lote(lote_id, usuario)
    return {"ok": True}


def _importar_em_segundo_plano(chave: str, executar, pasta_temp: Path | None):
    try:
        lote = executar()
        IMPORTACOES[chave].update(situacao="concluida", lote_id=lote.id)
    except Exception as e:  # noqa: BLE001
        IMPORTACOES[chave].update(situacao="erro", mensagem=f"{type(e).__name__}: {e}")
    finally:
        if pasta_temp:
            shutil.rmtree(pasta_temp, ignore_errors=True)


@app.post("/api/lotes/upload")
async def importar_upload(arquivos: list[UploadFile] = File(...), usuario: str = Depends(usuario_atual)):
    CONFIG.pasta_uploads.mkdir(parents=True, exist_ok=True)
    pasta = Path(tempfile.mkdtemp(dir=CONFIG.pasta_uploads))
    caminhos = []
    for arq in arquivos:
        nome = Path(arq.filename or "arquivo").name
        if Path(nome).suffix.lower() not in (".accdb", ".mdb", ".xlsx", ".xlsm", ".xls", ".csv", ".txt"):
            raise HTTPException(400, f"Tipo de arquivo não aceito: {nome}")
        destino = pasta / nome
        with destino.open("wb") as f:
            while bloco := await arq.read(1024 * 1024):
                f.write(bloco)
        caminhos.append(destino)
    return _iniciar_importacao(caminhos, usuario, pasta)


class ImportarCaminho(BaseModel):
    caminhos: list[str]


@app.post("/api/lotes/caminho")
def importar_caminho(dados: ImportarCaminho, usuario: str = Depends(usuario_atual)):
    caminhos = [Path(c.strip().strip('"')) for c in dados.caminhos if c.strip()]
    faltando = [str(c) for c in caminhos if not c.is_file()]
    if not caminhos or faltando:
        raise HTTPException(400, f"Arquivo não encontrado no servidor: {', '.join(faltando) or '(nenhum)'}")
    return _iniciar_importacao(caminhos, usuario, None)


def _iniciar_importacao(caminhos: list[Path], usuario: str, pasta_temp: Path | None, executar=None) -> dict:
    """Roda a importação numa thread; `executar` escolhe o importador (padrão: decide pela extensão)."""
    executar = executar or (lambda: servicos.importar_arquivos(caminhos, usuario))
    chave = uuid.uuid4().hex[:12]
    IMPORTACOES[chave] = {"id": chave, "situacao": "rodando", "arquivos": [c.name for c in caminhos],
                          "inicio": datetime.now().isoformat(timespec="seconds")}
    threading.Thread(target=_importar_em_segundo_plano, args=(chave, executar, pasta_temp), daemon=True).start()
    return IMPORTACOES[chave]


@app.get("/api/importacoes/{chave}")
def situacao_importacao(chave: str):
    if chave not in IMPORTACOES:
        raise HTTPException(404, "Importação não encontrada")
    return IMPORTACOES[chave]


@app.get("/api/lotes/{lote_id}/painel")
def painel(lote_id: int):
    with db.sessao() as s:
        base = select(OSFila).where(OSFila.lote_id == lote_id)
        por_status = dict(s.execute(select(OSFila.status, func.count()).where(OSFila.lote_id == lote_id)
                                    .group_by(OSFila.status)).all())
        por_coec = [{"coec": c or "-", "os": n, "multa": m or 0} for c, n, m in s.execute(
            select(OSFila.coec, func.count(), func.sum(OSFila.multa)).where(OSFila.lote_id == lote_id)
            .group_by(OSFila.coec).order_by(func.count().desc())).all()]
        por_veredito = dict(s.execute(select(OSFila.veredito_llm, func.count()).where(OSFila.lote_id == lote_id)
                                      .group_by(OSFila.veredito_llm)).all())
        por_regra = []
        for regra_id, n, multa in s.execute(
                select(Flag.regra_id, func.count(func.distinct(OSFila.id)), func.sum(OSFila.multa))
                .join(OSFila, Flag.os_fila_id == OSFila.id).where(OSFila.lote_id == lote_id)
                .group_by(Flag.regra_id)).all():
            r = REGISTRO.get(regra_id)
            por_regra.append({"regra_id": regra_id, "nome": r.nome if r else regra_id, "os": n, "multa": multa or 0,
                              "sozinha_basta": r.sozinha_basta if r else True})
        por_regra.sort(key=lambda x: -x["os"])
        total = s.scalar(select(func.count()).select_from(base.subquery()))
        multa_total = s.scalar(select(func.sum(OSFila.multa)).where(OSFila.lote_id == lote_id)) or 0
        correcoes = dict(s.execute(select(Correcao.status, func.count()).join(OSFila, Correcao.os_fila_id == OSFila.id)
                                   .where(OSFila.lote_id == lote_id).group_by(Correcao.status)).all())
        tipos = dict(s.execute(select(OSFila.tipo_os, func.count()).where(OSFila.lote_id == lote_id)
                               .group_by(OSFila.tipo_os)).all())
    return {"total": total, "multa_total": multa_total, "por_status": por_status, "por_coec": por_coec,
            "por_regra": por_regra, "por_veredito": {k or "sem_analise": v for k, v in por_veredito.items()},
            "correcoes": correcoes, "por_tipo": tipos}


ORDENS = {
    "multa": OSFila.multa.desc().nulls_last(),
    "regras": OSFila.n_regras.desc(),
    "os": OSFila.os,
    "tma": OSFila.tma.desc().nulls_last(),
    "dec": OSFila.dec.desc().nulls_last(),
    "atualizado": OSFila.atualizado_em.desc().nulls_last(),
    "confianca": OSFila.confianca_llm.desc().nulls_last(),
}


def _filtro_fila(lote_id: int, status: str | None, regra: str | None, coec: str | None, busca: str | None,
                 veredito: str | None, tipo_os: str | None, analista: str | None):
    q = select(OSFila).where(OSFila.lote_id == lote_id)
    if status:
        q = q.where(OSFila.status.in_(status.split(",")))
    if coec:
        q = q.where(OSFila.coec.in_(coec.split(",")))
    if tipo_os:
        q = q.where(OSFila.tipo_os == tipo_os)
    if analista:
        q = q.where(OSFila.analista == analista)
    if veredito:
        valores = veredito.split(",")
        cond = [OSFila.veredito_llm.in_([v for v in valores if v != "sem_analise"])]
        if "sem_analise" in valores:
            cond.append(OSFila.veredito_llm.is_(None))
        q = q.where(or_(*cond))
    if regra:
        sub = select(Flag.os_fila_id).where(Flag.regra_id.in_(regra.split(",")))
        q = q.where(OSFila.id.in_(sub))
    if busca:
        termo = f"%{busca.strip()}%"
        q = q.where(or_(OSFila.os.like(termo), OSFila.localidade.like(termo), OSFila.causa.like(termo),
                        OSFila.subcausa.like(termo)))
    return q


@app.get("/api/lotes/{lote_id}/fila")
def fila(lote_id: int, status: str | None = None, regra: str | None = None, coec: str | None = None,
         busca: str | None = None, veredito: str | None = None, tipo_os: str | None = None,
         analista: str | None = None, ordem: str = "multa", pagina: int = Query(1, ge=1),
         tamanho: int = Query(50, ge=1, le=500)):
    q = _filtro_fila(lote_id, status, regra, coec, busca, veredito, tipo_os, analista)
    with db.sessao() as s:
        total = s.scalar(select(func.count()).select_from(q.subquery()))
        q = q.order_by(ORDENS.get(ordem, ORDENS["multa"]), OSFila.id).offset((pagina - 1) * tamanho).limit(tamanho)
        itens = []
        for o in s.scalars(q):
            d = {c.name: getattr(o, c.name) for c in OSFila.__table__.columns}
            itens.append(d)
    return {"total": total, "pagina": pagina, "tamanho": tamanho, "itens": itens}


@app.get("/api/lotes/{lote_id}/exportar")
def exportar(lote_id: int, status: str | None = None, regra: str | None = None, coec: str | None = None,
             busca: str | None = None, veredito: str | None = None, tipo_os: str | None = None,
             analista: str | None = None):
    q = _filtro_fila(lote_id, status, regra, coec, busca, veredito, tipo_os, analista).order_by(OSFila.multa.desc())
    with db.sessao() as s:
        linhas = []
        for o in s.scalars(q):
            linhas.append({"OS": o.os, "Tipo": o.tipo_os, "Localidade": o.localidade, "COEC": o.coec,
                           "Compensação (R$)": o.multa, "Regras": ", ".join(o.regras or []), "Causa": o.causa,
                           "Subcausa": o.subcausa, "Conclusão": o.conclusao, "TMA": o.tma, "DEC": o.dec,
                           "Status": o.status, "Analista": o.analista, "Responsável": o.responsavel,
                           "Categorias da correção": ", ".join(o.categorias_correcao or []),
                           "Justificativa no TS": o.justificativa_ts,
                           "Observação": o.observacao, "Veredito LLM": o.veredito_llm,
                           "Confiança LLM": o.confianca_llm})
    buf = io.BytesIO()
    pd.DataFrame(linhas).to_excel(buf, index=False, sheet_name="Fila")
    buf.seek(0)
    nome = f"fila_lote_{lote_id}.xlsx"
    return StreamingResponse(buf, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                             headers={"Content-Disposition": f'attachment; filename="{nome}"'})


# ------------------------------------------------------------------ OS
@app.get("/api/os/{os_fila_id}")
def detalhe(os_fila_id: int):
    d = servicos.detalhe_os(os_fila_id)
    if d is None:
        raise HTTPException(404, "OS não encontrada")
    return d


class AtualizarOS(BaseModel):
    status: str | None = None
    analista: str | None = None
    responsavel: str | None = None
    observacao: str | None = None
    categorias_correcao: list[str] | None = None
    justificativa_ts: str | None = None


@app.patch("/api/os/{os_fila_id}")
def atualizar(os_fila_id: int, dados: AtualizarOS, usuario: str = Depends(usuario_atual)):
    try:
        item = servicos.atualizar_os(os_fila_id, usuario, **dados.model_dump())
    except KeyError:
        raise HTTPException(404, "OS não encontrada")
    except ValueError as e:
        raise HTTPException(400, str(e))
    return {c.name: getattr(item, c.name) for c in OSFila.__table__.columns}


@app.get("/api/os/{os_fila_id}/vizinhas")
def vizinhas(os_fila_id: int, status: str | None = None, regra: str | None = None, coec: str | None = None,
             busca: str | None = None, veredito: str | None = None, tipo_os: str | None = None,
             analista: str | None = None, ordem: str = "multa"):
    """Anterior/próxima OS na mesma fila filtrada (para navegar sem voltar à lista)."""
    with db.sessao() as s:
        item = s.get(OSFila, os_fila_id)
        if not item:
            raise HTTPException(404, "OS não encontrada")
        q = _filtro_fila(item.lote_id, status, regra, coec, busca, veredito, tipo_os, analista)
        ids = list(s.scalars(q.with_only_columns(OSFila.id).order_by(ORDENS.get(ordem, ORDENS["multa"]), OSFila.id)))
    if os_fila_id not in ids:
        return {"anterior": None, "proxima": None, "posicao": None, "total": len(ids)}
    i = ids.index(os_fila_id)
    return {"anterior": ids[i - 1] if i > 0 else None, "proxima": ids[i + 1] if i + 1 < len(ids) else None,
            "posicao": i + 1, "total": len(ids)}


# ------------------------------------------------------------------ LLM
def _provedor():
    from ..llm.provedor import ErroLLM, criar_provedor

    try:
        return criar_provedor()
    except ErroLLM as e:
        raise HTTPException(400, str(e))


@app.post("/api/os/{os_fila_id}/analisar")
def analisar(os_fila_id: int, forcar: bool = False, usuario: str = Depends(usuario_atual)):
    from ..llm.analisador import analisar_os

    r = analisar_os(os_fila_id, _provedor(), forcar=forcar, usuario=usuario)
    if r.erro:
        raise HTTPException(502, r.erro)
    return r.__dict__


class AnalisarLote(BaseModel):
    status: str | None = "pendente"
    regra: str | None = None
    coec: str | None = None
    veredito: str | None = "sem_analise"
    tipo_os: str | None = None
    limite: int = 50
    forcar: bool = False


@app.post("/api/lotes/{lote_id}/analisar")
def analisar_lote(lote_id: int, dados: AnalisarLote, usuario: str = Depends(usuario_atual)):
    from ..llm.analisador import iniciar_analise_lote

    q = _filtro_fila(lote_id, dados.status, dados.regra, dados.coec, None, dados.veredito, dados.tipo_os, None)
    with db.sessao() as s:
        ids = list(s.scalars(q.with_only_columns(OSFila.id).order_by(OSFila.multa.desc().nulls_last())
                             .limit(max(1, min(dados.limite, 5000)))))
    if not ids:
        raise HTTPException(400, "Nenhuma OS no filtro")
    t = iniciar_analise_lote(ids, usuario, dados.forcar, _provedor())
    return t.__dict__


@app.get("/api/tarefas/{tarefa_id}")
def tarefa(tarefa_id: str):
    from ..llm.analisador import TAREFAS

    t = TAREFAS.get(tarefa_id)
    if not t:
        raise HTTPException(404, "Tarefa não encontrada")
    return t.__dict__


@app.post("/api/tarefas/{tarefa_id}/cancelar")
def cancelar_tarefa(tarefa_id: str):
    from ..llm.analisador import TAREFAS

    t = TAREFAS.get(tarefa_id)
    if not t:
        raise HTTPException(404, "Tarefa não encontrada")
    t.cancelar = True
    return t.__dict__


@app.get("/api/lotes/{lote_id}/avaliacao-llm")
def avaliacao_llm(lote_id: int):
    """Acerto do LLM contra o histórico do Access (Correção Realizada) nas OS já analisadas pelos dois."""
    with db.sessao() as s:
        itens = s.scalars(select(OSFila).where(OSFila.lote_id == lote_id, OSFila.veredito_llm.is_not(None),
                                               OSFila.access_corrigida.is_not(None))).all()
    m = {"vp": 0, "fp": 0, "vn": 0, "fn": 0, "duvidosa": 0}
    for o in itens:
        if o.veredito_llm == "duvidosa":
            m["duvidosa"] += 1
            continue
        llm_errada = o.veredito_llm == "errada"
        if llm_errada and o.access_corrigida:
            m["vp"] += 1
        elif llm_errada:
            m["fp"] += 1
        elif o.access_corrigida:
            m["fn"] += 1
        else:
            m["vn"] += 1
    precisao = m["vp"] / (m["vp"] + m["fp"]) if m["vp"] + m["fp"] else None
    recall = m["vp"] / (m["vp"] + m["fn"]) if m["vp"] + m["fn"] else None
    return {"avaliadas": len(itens), **m, "precisao": precisao, "recall": recall}


# ------------------------------------------------------------------ correções
@app.get("/api/correcoes")
def listar_correcoes(lote_id: int | None = None, status: str | None = None, tipo: str | None = None,
                     limite: int = Query(500, le=5000)):
    q = select(Correcao, OSFila.os, OSFila.lote_id, OSFila.localidade, OSFila.justificativa_ts).join(
        OSFila, Correcao.os_fila_id == OSFila.id)
    if lote_id:
        q = q.where(OSFila.lote_id == lote_id)
    if status:
        q = q.where(Correcao.status.in_(status.split(",")))
    if tipo:
        q = q.where(Correcao.tipo == tipo)
    with db.sessao() as s:
        saida = []
        for c, os_, lote, local, just_ts in s.execute(q.order_by(Correcao.id.desc()).limit(limite)):
            d = servicos._correcao_dict(c)
            d.update(os=os_, lote_id=lote, localidade=local, justificativa_ts=just_ts)
            saida.append(d)
    return saida


class NovaCorrecao(BaseModel):
    tipo: str
    campo: str | None = None
    alvo: str | None = None
    valor_atual: str | None = None
    valor_novo: str | None = None
    justificativa: str | None = None
    aprovar: bool = True


@app.post("/api/os/{os_fila_id}/correcoes")
def criar_correcao(os_fila_id: int, dados: NovaCorrecao, usuario: str = Depends(usuario_atual)):
    if dados.tipo not in TIPOS_CORRECAO:
        raise HTTPException(400, "Tipo de correção desconhecido")
    c = servicos.criar_correcao(os_fila_id, usuario, "analista", dados.tipo, dados.campo, dados.alvo,
                                dados.valor_atual, dados.valor_novo, dados.justificativa,
                                "aprovada" if dados.aprovar else "proposta")
    return servicos._correcao_dict(c)


class Decisao(BaseModel):
    aprovar: bool
    campo: str | None = None
    alvo: str | None = None
    valor_atual: str | None = None
    valor_novo: str | None = None
    justificativa: str | None = None


@app.post("/api/correcoes/{correcao_id}/decisao")
def decidir(correcao_id: int, dados: Decisao, usuario: str = Depends(usuario_atual)):
    if not usuario:
        raise HTTPException(400, "Escolha o analista antes de aprovar ou rejeitar")
    try:
        c = servicos.decidir_correcao(correcao_id, usuario, dados.aprovar,
                                      **dados.model_dump(exclude={"aprovar"}))
    except KeyError:
        raise HTTPException(404, "Correção não encontrada")
    except ValueError as e:
        raise HTTPException(400, str(e))
    return servicos._correcao_dict(c)


@app.get("/api/auditoria")
def auditoria(limite: int = Query(200, le=2000)):
    with db.sessao() as s:
        return [{c.name: getattr(a, c.name) for c in Auditoria.__table__.columns}
                for a in s.scalars(select(Auditoria).order_by(Auditoria.id.desc()).limit(limite))]


# ------------------------------------------------------------------ robô (fase 2) e BDGD
from fastapi.middleware.gzip import GZipMiddleware  # noqa: E402

from .bdgd import router as router_bdgd  # noqa: E402
from .fontes import router as router_fontes  # noqa: E402
from .robo import router as router_robo  # noqa: E402

app.include_router(router_robo)
app.include_router(router_bdgd)
app.include_router(router_fontes)
app.add_middleware(GZipMiddleware, minimum_size=2000)


# ------------------------------------------------------------------ frontend
if PASTA_FRONT.exists():
    app.mount("/assets", StaticFiles(directory=PASTA_FRONT / "assets"), name="assets")

    @app.get("/{caminho:path}", include_in_schema=False)
    def spa(caminho: str):
        arquivo = PASTA_FRONT / caminho
        if caminho and arquivo.is_file():
            return FileResponse(arquivo)
        return FileResponse(PASTA_FRONT / "index.html")
