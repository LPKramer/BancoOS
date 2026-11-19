"""Casos de uso: importar lote, montar fila, detalhar OS, registrar decisões do analista."""
from __future__ import annotations

import math
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd
from sqlalchemy import delete, select, text

from . import db
from .dados import CHAVE_OS, ENTIDADES, BaseOS
from .db import Analista, Auditoria, Correcao, Flag, Lote, OSFila, agora
from .rules.base import REGISTRO
from .rules.motor import ResultadoRegras, executar
from .rules.paridade import comparar

CATEGORIAS_ACCESS = {
    "C_Classificação": "classificacao",
    "C_OS Vinculada": "os_vinculada",
    "C_Passo de Manobra": "passo_manobra",
    "C_Horário": "horario",
    "C_Elemento Origem": "elemento_origem",
}
STATUS_OS = ["pendente", "em_analise", "correta", "errada", "corrigida", "ignorada"]
RESPONSAVEIS = ["COI", "SUPERVISOR", "EQUIPE", "ANÁLISE PÓS", "AGUARDANDO CHAMADO (SONDA)"]


def _limpo(v):
    if v is None:
        return None
    if isinstance(v, float) and math.isnan(v):
        return None
    if v is pd.NaT:
        return None
    if isinstance(v, (pd.Timestamp, datetime)):
        return v.strftime("%d/%m/%Y %H:%M")
    if isinstance(v, np.generic):
        return v.item()
    return v


def auditar(sessao, usuario: str, acao: str, alvo: str | None = None, **detalhes) -> None:
    sessao.add(Auditoria(usuario=usuario or "", acao=acao, alvo=alvo, detalhes=detalhes))


# ------------------------------------------------------------------ importação
def importar_base(base: BaseOS, tipo_origem: str, usuario: str = "") -> Lote:
    res = executar(base)
    paridade = None
    if "access_intervencao" in base.extras:
        linhas, resumo = comparar(base, res)
        paridade = {
            "regras": [{"regra_id": l.regra_id, "app": l.app, "access": l.access, "so_app": len(l.so_app),
                        "so_access": len(l.so_access), "ok": l.ok, "divergencia": l.divergencia_conhecida}
                       for l in linhas],
            "resumo": {k: (len(v) if isinstance(v, list) else v) for k, v in resumo.items()},
        }
    engine = db.engine_padrao()
    with db.sessao() as s:
        lote = Lote(competencia=base.competencia, origem=base.origem, tipo_origem=tipo_origem, criado_por=usuario,
                    contagens=base.contagens(), contagem_regras=res.contagem_por_regra(), erros_regras=res.erros,
                    paridade=paridade)
        s.add(lote)
        s.flush()
        _gravar_fila(s, lote.id, res, base)
        _gravar_analistas(s, base)
        auditar(s, usuario, "importar_lote", f"lote {lote.id}", origem=base.origem, fila=len(res.fila))
        s.commit()
        lote_id = lote.id
    _gravar_bases(engine, lote_id, base)
    aprender_equivalencias(base.compensacao)
    with db.sessao() as s:
        return s.get(Lote, lote_id)


def aprender_equivalencias(compensacao: pd.DataFrame) -> dict | None:
    """Aprende chave do TS -> chave da BDGD com as coordenadas da compensação (se o índice da BDGD existir)."""
    try:
        from .bdgd import equivalencia, indice

        if indice.caminho_indice() is None:
            return None
        con = indice.conectar()
        try:
            return equivalencia.aprender(con, compensacao)
        finally:
            con.close()
    except Exception:  # noqa: BLE001 - a importação não depende da BDGD
        return None


def importar_arquivos(arquivos: list[Path], usuario: str = "") -> Lote:
    """Decide o importador pela extensão: .accdb/.mdb = Banco de Análise; planilhas = crítica (+ compensação)."""
    from .importers.base_access import carregar_de_access
    from .importers.critica import carregar_de_critica

    access = [a for a in arquivos if a.suffix.lower() in (".accdb", ".mdb")]
    if access:
        return importar_base(carregar_de_access(access[0]), "access", usuario)
    planilhas = sorted(arquivos, key=lambda a: a.stat().st_size, reverse=True)
    critica = planilhas[0]  # a crítica é sempre a maior planilha
    comp = next((p for p in planilhas[1:] if "ocorr" in p.name.lower() or "comp" in p.name.lower()),
                planilhas[1] if len(planilhas) > 1 else None)
    return importar_base(carregar_de_critica(critica, comp), "critica", usuario)


def importar_bases(critica: Path, ocorrencias: Path | None, usuario: str = "") -> Lote:
    """As duas bases do mês com o papel de cada uma dito pelo analista (sem adivinhar pelo tamanho)."""
    from .importers.critica import carregar_de_critica

    return importar_base(carregar_de_critica(critica, ocorrencias), "critica", usuario)


def _historico_access(base: BaseOS) -> dict[str, dict]:
    acc = base.extras.get("access_intervencao")
    if acc is None:
        return {}
    hist = {}
    for _, linha in acc.iterrows():
        cats = [nome for col, nome in CATEGORIAS_ACCESS.items() if str(linha.get(col)) in ("-1", "True", "1")]
        hist[str(linha["NUM_SEQ_OPER_OS_MNB"])] = {
            "corrigida": str(linha.get("Correção Realizada")) in ("-1", "True", "1"),
            "categorias": cats,
        }
    return hist


def _gravar_fila(sessao, lote_id: int, res: ResultadoRegras, base: BaseOS) -> None:
    historico = _historico_access(base)
    flags_por_os = {k: g for k, g in res.flags.groupby(["os", "tipo_os"])}
    colunas = {c.name for c in OSFila.__table__.columns}
    for linha in res.fila.to_dict("records"):
        dados = {k: _limpo(v) for k, v in linha.items() if k in colunas}
        item = OSFila(lote_id=lote_id, **dados)
        h = historico.get(item.os)
        if h:
            item.access_corrigida = h["corrigida"]
            item.access_categorias = h["categorias"]
        for f in flags_por_os.get((item.os, item.tipo_os), pd.DataFrame()).to_dict("records"):
            item.flags.append(Flag(regra_id=f["regra_id"], valor=str(f["valor"]), evidencia=f["evidencia"] or {}))
        sessao.add(item)


def _gravar_analistas(sessao, base: BaseOS) -> None:
    an = base.extras.get("analistas")
    if an is None:
        return
    for nome in an["NOME"].dropna().astype(str).str.strip():
        if nome and nome.lower() != "nan" and not sessao.get(Analista, nome):
            sessao.add(Analista(nome=nome))


def _gravar_bases(engine, lote_id: int, base: BaseOS) -> None:
    for entidade in ENTIDADES:
        df = getattr(base, entidade).copy()
        df.insert(0, "lote_id", lote_id)
        tabela = f"base_{entidade}"
        df.to_sql(tabela, engine, if_exists="append", index=False, chunksize=2000)
        chave = CHAVE_OS.get(entidade)
        with engine.begin() as con:
            if chave:
                con.execute(text(f'CREATE INDEX IF NOT EXISTS ix_{tabela}_os ON {tabela} (lote_id, "{chave}")'))
            else:
                con.execute(text(f"CREATE INDEX IF NOT EXISTS ix_{tabela}_lote ON {tabela} (lote_id)"))


def carregar_base_lote(lote_id: int) -> BaseOS:
    from .dados import normalizar

    engine = db.engine_padrao()
    dfs = {}
    with engine.connect() as con:
        for entidade in ENTIDADES:
            df = pd.read_sql(text(f"SELECT * FROM base_{entidade} WHERE lote_id = :l"), con, params={"l": lote_id})
            dfs[entidade] = normalizar(entidade, df.drop(columns=["lote_id"]))
    with db.sessao() as s:
        lote = s.get(Lote, lote_id)
    return BaseOS(**dfs, competencia=lote.competencia, origem=lote.origem)


def excluir_lote(lote_id: int, usuario: str = "") -> None:
    engine = db.engine_padrao()
    with db.sessao() as s:
        s.execute(delete(Lote).where(Lote.id == lote_id))
        auditar(s, usuario, "excluir_lote", f"lote {lote_id}")
        s.commit()
    with engine.begin() as con:
        for entidade in ENTIDADES:
            con.execute(text(f"DELETE FROM base_{entidade} WHERE lote_id = :l"), {"l": lote_id})


# ----------------------------------------------------------------- consultas
def _data_ordem(valor: str | None) -> datetime:
    try:
        return datetime.strptime(valor, "%d/%m/%Y %H:%M") if valor else datetime.max
    except ValueError:
        return datetime.max


def _linhas(con, entidade: str, lote_id: int, os_: str, chave: str | None = None) -> list[dict]:
    chave = chave or CHAVE_OS[entidade]
    try:
        df = pd.read_sql(text(f'SELECT * FROM base_{entidade} WHERE lote_id = :l AND "{chave}" = :o'), con,
                         params={"l": lote_id, "o": os_})
    except Exception:  # noqa: BLE001 - tabela ainda não criada
        return []
    df = df.drop(columns=["lote_id"])
    from .dados import para_data

    for col in ENTIDADES[entidade][1]:
        if col in df:
            df[col] = para_data(df[col])
    return [{k: _limpo(v) for k, v in r.items()} for r in df.to_dict("records")]


def detalhe_os(os_fila_id: int) -> dict | None:
    with db.sessao() as s:
        item = s.get(OSFila, os_fila_id)
        if item is None:
            return None
        flags = [{"regra_id": f.regra_id, "valor": f.valor, "evidencia": f.evidencia,
                  "nome": REGISTRO[f.regra_id].nome if f.regra_id in REGISTRO else f.regra_id,
                  "descricao": REGISTRO[f.regra_id].descricao if f.regra_id in REGISTRO else "",
                  "correcao_tipica": REGISTRO[f.regra_id].correcao_tipica if f.regra_id in REGISTRO else None}
                 for f in item.flags]
        analises = [{"id": a.id, "criado_em": a.criado_em, "modelo": a.modelo, "veredito": a.veredito,
                     "confianca": a.confianca, "resposta": a.resposta, "erro": a.erro}
                    for a in s.scalars(select(db.AnaliseLLM).where(db.AnaliseLLM.os_fila_id == item.id)
                                       .order_by(db.AnaliseLLM.id.desc()))]
        correcoes = [_correcao_dict(c) for c in s.scalars(select(Correcao).where(Correcao.os_fila_id == item.id)
                                                            .order_by(Correcao.id))]
        resumo = {c.name: getattr(item, c.name) for c in OSFila.__table__.columns}
    with db.engine_padrao().connect() as con:
        if resumo["tipo_os"] == "intervencao":
            registro = _linhas(con, "intervencao", resumo["lote_id"], resumo["os"])
            passos = _linhas(con, "manobra", resumo["lote_id"], resumo["os"])
            passos.sort(key=lambda p: (_data_ordem(p.get("DTA_PASSO_PNB")), p.get("NUM_SEQ_PNB") or 0))
            vinculadas = _linhas(con, "vinculada", resumo["lote_id"], resumo["os"])
            vinculadas.sort(key=lambda v: _data_ordem(v.get("DTA_RECL_CNR")))
            equipe = _linhas(con, "equipe", resumo["lote_id"], resumo["os"])
        else:
            registro = _linhas(con, "individual", resumo["lote_id"], resumo["os"])
            passos, vinculadas, equipe = [], [], []
        compensacao = _linhas(con, "compensacao", resumo["lote_id"], resumo["os"])
    return {"resumo": resumo, "registro": registro[0] if registro else {}, "passos": passos,
            "vinculadas": vinculadas, "equipe": equipe, "compensacao": compensacao, "flags": flags,
            "analises": analises, "correcoes": correcoes}


def _correcao_dict(c: Correcao) -> dict:
    return {col.name: getattr(c, col.name) for col in Correcao.__table__.columns}


def _valor_campo_os(campo: str, v):
    """Forma gravada: texto vazio e lista vazia viram None, para não registrar mudança onde não houve."""
    if v is None:
        return None
    if campo == "categorias_correcao":
        return sorted(set(v)) or None
    if isinstance(v, str):
        return v.strip() or None
    return v


def atualizar_os(os_fila_id: int, usuario: str, **campos) -> OSFila:
    """Campos ausentes (None) ficam como estão; texto vazio ou lista vazia limpam o campo."""
    permitidos = {"status", "analista", "responsavel", "observacao", "categorias_correcao", "justificativa_ts"}
    with db.sessao() as s:
        item = s.get(OSFila, os_fila_id)
        if item is None:
            raise KeyError(os_fila_id)
        mudou = {}
        for k, v in campos.items():
            if k not in permitidos or v is None:
                continue
            if k == "status" and v not in STATUS_OS:
                raise ValueError(f"status inválido: {v}")
            if k == "categorias_correcao":
                invalidas = set(v) - set(CATEGORIAS_ACCESS.values())
                if invalidas:
                    raise ValueError(f"categoria inválida: {', '.join(sorted(invalidas))}")
            v = _valor_campo_os(k, v)
            atual = getattr(item, k)
            if _valor_campo_os(k, atual) != v:
                mudou[k] = [atual, v]
                setattr(item, k, v)
        if mudou:
            item.atualizado_em = agora()
            auditar(s, usuario, "atualizar_os", item.os, **mudou)
        s.commit()
        return item


def criar_correcao(os_fila_id: int, usuario: str, origem: str, tipo: str, campo: str | None = None,
                   alvo: str | None = None, valor_atual: str | None = None, valor_novo: str | None = None,
                   justificativa: str | None = None, status: str = "proposta") -> Correcao:
    with db.sessao() as s:
        c = Correcao(os_fila_id=os_fila_id, origem=origem, tipo=tipo, campo=campo, alvo=alvo,
                     valor_atual=valor_atual, valor_novo=valor_novo, justificativa=justificativa, status=status)
        if status == "aprovada":
            c.decidido_por, c.decidido_em = usuario, agora()
        s.add(c)
        s.flush()
        auditar(s, usuario, "criar_correcao", str(c.id), tipo=tipo, origem=origem, status=status)
        s.commit()
        return c


def decidir_correcao(correcao_id: int, usuario: str, aprovar: bool, **ajustes) -> Correcao:
    with db.sessao() as s:
        c = s.get(Correcao, correcao_id)
        if c is None:
            raise KeyError(correcao_id)
        if c.status not in ("proposta", "aprovada", "rejeitada", "erro"):
            raise ValueError(f"correção em {c.status} não pode ser alterada")
        for k in ("campo", "alvo", "valor_atual", "valor_novo", "justificativa", "tipo"):
            if ajustes.get(k) is not None:
                setattr(c, k, ajustes[k])
        c.status = "aprovada" if aprovar else "rejeitada"
        c.decidido_por, c.decidido_em = usuario, agora()
        auditar(s, usuario, "aprovar_correcao" if aprovar else "rejeitar_correcao", str(c.id))
        s.commit()
        return c
