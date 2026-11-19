"""Banco do app (SQLite + SQLAlchemy).

Tabelas de trabalho (lotes, fila, flags, análises do LLM, correções, auditoria) usam o ORM.
As bases importadas de cada lote ficam em tabelas `base_<entidade>` gravadas pelo pandas,
com a coluna `lote_id`, para o detalhe da OS e para reprocessar regras.
"""
from __future__ import annotations

import json
import threading
from datetime import datetime
from pathlib import Path

from sqlalchemy import (JSON, Boolean, DateTime, Float, ForeignKey, Integer, String, Text, UniqueConstraint,
                        create_engine, event)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, sessionmaker

from .config import CONFIG


class Base(DeclarativeBase):
    type_annotation_map = {dict: JSON, list: JSON}


def agora() -> datetime:
    return datetime.now().replace(microsecond=0)


class Lote(Base):
    __tablename__ = "lote"
    id: Mapped[int] = mapped_column(primary_key=True)
    competencia: Mapped[str | None] = mapped_column(String(7))
    origem: Mapped[str] = mapped_column(Text)
    tipo_origem: Mapped[str] = mapped_column(String(20))  # access | critica
    criado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)
    criado_por: Mapped[str] = mapped_column(String(80), default="")
    contagens: Mapped[dict] = mapped_column(default=dict)
    contagem_regras: Mapped[dict] = mapped_column(default=dict)
    erros_regras: Mapped[dict] = mapped_column(default=dict)
    paridade: Mapped[dict | None] = mapped_column(default=None)
    ativo: Mapped[bool] = mapped_column(Boolean, default=True)


class OSFila(Base):
    """Uma OS que entrou na fila de análise de um lote."""
    __tablename__ = "os_fila"
    __table_args__ = (UniqueConstraint("lote_id", "os", "tipo_os"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    lote_id: Mapped[int] = mapped_column(ForeignKey("lote.id", ondelete="CASCADE"), index=True)
    os: Mapped[str] = mapped_column(String(20), index=True)
    tipo_os: Mapped[str] = mapped_column(String(20))
    regras: Mapped[list] = mapped_column(default=list)
    n_regras: Mapped[int] = mapped_column(Integer, default=0)
    competencia: Mapped[str | None] = mapped_column(String(20))
    cod_causa: Mapped[str | None] = mapped_column(String(10))
    causa: Mapped[str | None] = mapped_column(String(120))
    cod_subcausa: Mapped[str | None] = mapped_column(String(10))
    subcausa: Mapped[str | None] = mapped_column(String(160))
    conclusao: Mapped[str | None] = mapped_column(String(5))
    tma: Mapped[float | None] = mapped_column(Float)
    dec: Mapped[float | None] = mapped_column(Float)
    inicio: Mapped[str | None] = mapped_column(String(20))
    fim: Mapped[str | None] = mapped_column(String(20))
    elemento: Mapped[str | None] = mapped_column(String(10))
    instalacao: Mapped[str | None] = mapped_column(String(20))
    localidade: Mapped[str | None] = mapped_column(String(80))
    coec: Mapped[str | None] = mapped_column(String(20))
    qtd_vinculadas: Mapped[int] = mapped_column(Integer, default=0)
    multa: Mapped[float | None] = mapped_column(Float)
    # andamento da análise
    status: Mapped[str] = mapped_column(String(20), default="pendente", index=True)
    # pendente | em_analise | correta | errada | corrigida | ignorada
    analista: Mapped[str | None] = mapped_column(String(80))
    responsavel: Mapped[str | None] = mapped_column(String(40))  # COI, SUPERVISOR, EQUIPE... (T_Status_OS)
    observacao: Mapped[str | None] = mapped_column(Text)
    atualizado_em: Mapped[datetime | None] = mapped_column(DateTime)
    veredito_llm: Mapped[str | None] = mapped_column(String(20))
    confianca_llm: Mapped[float | None] = mapped_column(Float)
    # histórico vindo do Access (gabarito)
    access_corrigida: Mapped[bool | None] = mapped_column(Boolean)
    access_categorias: Mapped[list | None] = mapped_column(default=None)
    # categorias da correção marcadas pelo analista (as mesmas do Access: C_Classificação, C_OS Vinculada...)
    categorias_correcao: Mapped[list | None] = mapped_column(default=None)
    # texto escrito no campo "Justificativa" do TS ao salvar a correção (um dos textos padrões, completado)
    justificativa_ts: Mapped[str | None] = mapped_column(Text)

    flags: Mapped[list["Flag"]] = relationship(back_populates="os_fila", cascade="all, delete-orphan")


class Flag(Base):
    __tablename__ = "flag"
    id: Mapped[int] = mapped_column(primary_key=True)
    os_fila_id: Mapped[int] = mapped_column(ForeignKey("os_fila.id", ondelete="CASCADE"), index=True)
    regra_id: Mapped[str] = mapped_column(String(60), index=True)
    valor: Mapped[str] = mapped_column(String(60))
    evidencia: Mapped[dict] = mapped_column(default=dict)
    os_fila: Mapped[OSFila] = relationship(back_populates="flags")


class AnaliseLLM(Base):
    __tablename__ = "analise_llm"
    id: Mapped[int] = mapped_column(primary_key=True)
    os_fila_id: Mapped[int] = mapped_column(ForeignKey("os_fila.id", ondelete="CASCADE"), index=True)
    criado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)
    provedor: Mapped[str] = mapped_column(String(30))
    modelo: Mapped[str] = mapped_column(String(60))
    hash_entrada: Mapped[str] = mapped_column(String(64), index=True)
    veredito: Mapped[str | None] = mapped_column(String(20))
    confianca: Mapped[float | None] = mapped_column(Float)
    resposta: Mapped[dict] = mapped_column(default=dict)
    erro: Mapped[str | None] = mapped_column(Text)
    tokens_entrada: Mapped[int | None] = mapped_column(Integer)
    tokens_saida: Mapped[int | None] = mapped_column(Integer)
    tokens_cache: Mapped[int | None] = mapped_column(Integer)


class Correcao(Base):
    """Correção proposta (LLM ou analista) que, aprovada, vai para o robô do TS."""
    __tablename__ = "correcao"
    id: Mapped[int] = mapped_column(primary_key=True)
    os_fila_id: Mapped[int] = mapped_column(ForeignKey("os_fila.id", ondelete="CASCADE"), index=True)
    criado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)
    origem: Mapped[str] = mapped_column(String(20))  # llm | analista
    tipo: Mapped[str] = mapped_column(String(40))  # catálogo em llm/catalogo.py
    campo: Mapped[str | None] = mapped_column(String(80))
    alvo: Mapped[str | None] = mapped_column(String(80))  # ex.: nº do passo, nº da OS vinculada
    valor_atual: Mapped[str | None] = mapped_column(Text)
    valor_novo: Mapped[str | None] = mapped_column(Text)
    justificativa: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(20), default="proposta", index=True)
    # proposta | aprovada | rejeitada | em_execucao | executada | erro
    decidido_por: Mapped[str | None] = mapped_column(String(80))
    decidido_em: Mapped[datetime | None] = mapped_column(DateTime)
    executado_em: Mapped[datetime | None] = mapped_column(DateTime)
    resultado_robo: Mapped[str | None] = mapped_column(Text)
    tentativas: Mapped[int] = mapped_column(Integer, default=0)


class Auditoria(Base):
    __tablename__ = "auditoria"
    id: Mapped[int] = mapped_column(primary_key=True)
    quando: Mapped[datetime] = mapped_column(DateTime, default=agora, index=True)
    usuario: Mapped[str] = mapped_column(String(80), default="")
    acao: Mapped[str] = mapped_column(String(60))
    alvo: Mapped[str | None] = mapped_column(String(120))
    detalhes: Mapped[dict] = mapped_column(default=dict)


class EquivChave(Base):
    """Chave do TS -> chave da BDGD, aprendida pela coordenada do elemento na base de compensação."""
    __tablename__ = "bdgd_equiv_chave"
    cod_ts: Mapped[str] = mapped_column(String(20), primary_key=True)
    cod_bdgd: Mapped[str] = mapped_column(String(30))
    distancia_m: Mapped[float] = mapped_column(Float)
    tipo_ts: Mapped[str | None] = mapped_column(String(5))
    n_obs: Mapped[int] = mapped_column(Integer, default=1)
    atualizado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)


class Analista(Base):
    __tablename__ = "analista"
    nome: Mapped[str] = mapped_column(String(80), primary_key=True)
    ativo: Mapped[bool] = mapped_column(Boolean, default=True)


class Configuracao(Base):
    """Preferências guardadas pelo app (ex.: caminho de cada base apontada na tela Importar)."""
    __tablename__ = "configuracao"
    chave: Mapped[str] = mapped_column(String(60), primary_key=True)
    valor: Mapped[str | None] = mapped_column(Text)
    atualizado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)
    atualizado_por: Mapped[str] = mapped_column(String(80), default="")


class TextoPadrao(Base):
    """Justificativa padrão do TS (planilha TEXTOS PADRÕES PARA CORREÇÕES, coluna JUSTIFICATIVA CORREÇÃO)."""
    __tablename__ = "texto_padrao"
    id: Mapped[int] = mapped_column(primary_key=True)
    texto: Mapped[str] = mapped_column(Text, unique=True)
    categorias: Mapped[list] = mapped_column(default=list)  # mesmas categorias do Access (classificacao...)
    categorias_manuais: Mapped[bool] = mapped_column(Boolean, default=False)  # acertadas pelo analista
    erro: Mapped[str | None] = mapped_column(Text)  # coluna ERRO ENCONTRADO, quando preenchida
    ordem: Mapped[int] = mapped_column(Integer, default=0)  # linha na planilha
    ativo: Mapped[bool] = mapped_column(Boolean, default=True)  # False = saiu da planilha
    atualizado_em: Mapped[datetime] = mapped_column(DateTime, default=agora)


def criar_engine(caminho: Path | None = None):
    caminho = caminho or CONFIG.arquivo_banco
    caminho.parent.mkdir(parents=True, exist_ok=True)
    engine = create_engine(f"sqlite:///{caminho}", future=True,
                           json_serializer=lambda o: json.dumps(o, ensure_ascii=False, default=str),
                           connect_args={"check_same_thread": False, "timeout": 30})

    @event.listens_for(engine, "connect")
    def _pragma(conexao, _):
        cur = conexao.cursor()
        cur.execute("PRAGMA journal_mode=WAL")
        cur.execute("PRAGMA foreign_keys=ON")
        cur.close()

    Base.metadata.create_all(engine)
    _migrar(engine)
    return engine


def _migrar(engine) -> None:
    """Acrescenta colunas novas em bancos criados por versões anteriores (SQLite não altera sozinho)."""
    from sqlalchemy import inspect, text

    from sqlalchemy.exc import OperationalError

    insp = inspect(engine)
    for tabela in Base.metadata.sorted_tables:
        if not insp.has_table(tabela.name):
            continue
        existentes = {c["name"] for c in insp.get_columns(tabela.name)}
        for coluna in tabela.columns:
            if coluna.name in existentes:
                continue
            tipo = coluna.type.compile(dialect=engine.dialect)
            try:
                with engine.begin() as con:
                    con.execute(text(f'ALTER TABLE {tabela.name} ADD COLUMN "{coluna.name}" {tipo}'))
            except OperationalError as e:
                # outro processo (script, segunda instância) já acrescentou a coluna
                if "duplicate column" not in str(e).lower():
                    raise


_engine = None
_Sessao = None
_trava_engine = threading.Lock()


def engine_padrao():
    """Cria o engine uma vez só, mesmo com várias requisições chegando juntas na subida do servidor."""
    global _engine, _Sessao
    if _engine is None:
        with _trava_engine:
            if _engine is None:
                engine = criar_engine()
                _Sessao = sessionmaker(bind=engine, expire_on_commit=False)
                _engine = engine
    return _engine


def sessao():
    engine_padrao()
    return _Sessao()


def configurar(caminho: Path):
    """Aponta o app para outro arquivo de banco (testes)."""
    global _engine, _Sessao
    _engine = criar_engine(caminho)
    _Sessao = sessionmaker(bind=_engine, expire_on_commit=False)
    return _engine
