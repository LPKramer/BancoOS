"""Análise de OS com LLM: monta o contexto (mascarado), chama o provedor, valida e grava."""
from __future__ import annotations

import hashlib
import json
import threading
import uuid
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from typing import Literal

from pydantic import BaseModel, Field, ValidationError, field_validator
from sqlalchemy import select

from .. import db, servicos
from ..config import CONFIG
from ..db import AnaliseLLM, Correcao, OSFila
from .catalogo import TIPOS_CORRECAO
from .mascaramento import mascarar
from .prompts import VERSAO_PROMPT, prompt_sistema, prompt_usuario
from .provedor import ErroLLM, ProvedorLLM, criar_provedor

CAMPOS_NUNCA_ENVIAR = {"NOM_CLI_CNR", "DES_ENDE_UN_CONS_CNR", "NUM_FONE_CNR", "COD_UN_CONS_CNR",
                       "NOM_TEC_RESP_CUR", "NOM_USU_EXEC_MNB", "NOM_USU_PROGM_MNB", "NOM_USU_CFER_MNB",
                       "USU_VINC"}
CAMPOS_TEXTO = {"DES_INTV_MNB", "DES_PASSO_PNB", "DES_OBS_EXEC_SERV_CNR", "DES_PTO_REF_CNR"}
MAX_PASSOS = 60
MAX_VINCULADAS = 40

CAMPOS_PASSO = ["NUM_SEQ_PNB", "NUM_PASSO_PNB", "DTA_PASSO_PNB", "COD_OPER_PNB", "STA_EXEC_PNB", "COD_ELE_PNB",
                "COD_INS_SEC_INS", "TIPO_CHAVE", "QTD_UN_CONS_PNB", "TIPO", "DES_PASSO_PNB"]
CAMPOS_VINCULADA = ["NUM_SEQ_OPER_CNR", "DTA_RECL_CNR", "DTA_FIM_CNR", "COD_TIPO_OS_CNR", "COD_SUB_TIPO_OS_CNR",
                    "TIPO_VINC", "ZONA", "DES_BAI_CNR", "COD_INS_TRF_INT", "DES_OBS_EXEC_SERV_CNR"]


def _texto(v):
    """O modelo às vezes devolve objeto/lista onde o esquema pede texto: vira texto compacto."""
    if v is None or isinstance(v, str):
        return v
    if isinstance(v, (dict, list)):
        return json.dumps(v, ensure_ascii=False, separators=(", ", ": "))
    return str(v)


class Problema(BaseModel):
    regra_id: str | None = None
    descricao: str
    evidencia: str | None = None

    @field_validator("regra_id", "descricao", "evidencia", mode="before")
    @classmethod
    def texto(cls, v):
        return _texto(v)


class CorrecaoSugerida(BaseModel):
    tipo: str
    campo: str | None = None
    alvo: str | None = None
    valor_atual: str | None = None
    valor_novo: str | None = None
    justificativa: str | None = None

    @field_validator("tipo")
    @classmethod
    def tipo_valido(cls, v: str) -> str:
        if v not in TIPOS_CORRECAO:
            raise ValueError(f"tipo de correção fora do catálogo: {v}")
        return v

    @field_validator("campo", "alvo", "valor_atual", "valor_novo", "justificativa", mode="before")
    @classmethod
    def texto(cls, v):
        return _texto(v)


class RespostaAnalise(BaseModel):
    veredito: Literal["errada", "correta", "duvidosa"]
    confianca: float = Field(ge=0, le=1)
    resumo: str
    problemas: list[Problema] = []
    regras_falso_positivo: list[str] = []
    correcoes: list[CorrecaoSugerida] = []
    justificativa_padrao: int | None = None  # número (id) do texto padrão escolhido pelo modelo
    justificativa_padrao_texto: str | None = None  # preenchido aqui a partir do número, não pelo modelo

    @field_validator("justificativa_padrao", mode="before")
    @classmethod
    def numero_texto(cls, v):
        """Aceita 12, "12" ou "12. TEXTO..."; qualquer outra coisa vira None (a sugestão é opcional)."""
        if isinstance(v, bool) or v is None:
            return None
        if isinstance(v, (int, float)):
            return int(v)
        if isinstance(v, str):
            import re

            m = re.match(r"\s*(\d+)", v)
            return int(m.group(1)) if m else None
        return None

    @field_validator("veredito", mode="before")
    @classmethod
    def minusculo(cls, v):
        return v.strip().lower() if isinstance(v, str) else v

    @field_validator("resumo", mode="before")
    @classmethod
    def resumo_texto(cls, v):
        return _texto(v) or ""

    @field_validator("regras_falso_positivo", mode="before")
    @classmethod
    def lista_texto(cls, v):
        return [_texto(x) for x in v] if isinstance(v, list) else []


def _limpar_registro(reg: dict, campos: list[str] | None, mascara: bool) -> dict:
    saida = {}
    for k, v in reg.items():
        if k in CAMPOS_NUNCA_ENVIAR or v is None or v == "":
            continue
        if campos is not None and k not in campos:
            continue
        if k in CAMPOS_TEXTO and mascara:
            v = mascarar(str(v))
        saida[k] = v
    return saida


def resumo_bdgd(m: dict | None) -> dict | None:
    """Evidência da simulação da manobra na BDGD, compacta, para o LLM (sem dados pessoais)."""
    if not m or not m.get("disponivel"):
        return None
    r = m["resumo"]
    passos = [{"data": p["data"], "oper": p["oper"], "elemento_ts": p["cod_ts"], "localizado_bdgd": p["localizado"],
               "clientes_registrados": p["qtd_registrada"], "clientes_bdgd_elemento": p["ucs_elemento"],
               "clientes_sem_energia_apos": p["ucs_desligadas"]}
              for p in m["passos"] if p["efeito"] in ("abre", "fecha")]
    return {
        "alimentadores": [a["nome"] for a in r["alimentadores"]],
        "passos_localizados": f"{r['passos_localizados']} de {r['passos_total']}",
        "maior_desligamento_bdgd": r["pico_ucs"],
        "passos_simulados": passos[:40],
        "vinculadas_fora_da_area": [v["os"] for v in m["vinculadas"] if v["na_area"] is False][:30],
        "os_individuais_na_area_sem_vinculo": [{"os": c["os"], "reclamacao": c["recl"]} for c in m["candidatas"][:15]],
        "ponto_interrupcao_provavel": [{k: c[k] for k in ("tipo", "cod_id", "ucs_jusante", "motivo")}
                                       for c in m["candidatos"].values()],
    }


def _manobra_bdgd(detalhe: dict) -> dict | None:
    if detalhe["resumo"]["tipo_os"] != "intervencao":
        return None
    try:
        from ..bdgd import indice, manobra

        if indice.caminho_indice() is None:
            return None
        return manobra.analisar(detalhe["resumo"]["id"])
    except Exception:  # noqa: BLE001 - a análise segue sem a BDGD
        return None


def montar_contexto(detalhe: dict, mascara: bool = True, manobra: dict | None = None) -> dict:
    r = detalhe["resumo"]
    passos = detalhe["passos"]
    vinc = detalhe["vinculadas"]
    ctx = {
        "os": r["os"],
        "tipo_os": r["tipo_os"],
        "registro": _limpar_registro(detalhe["registro"], None, mascara),
        "regras_marcadas": [{"regra_id": f["regra_id"], "valor": f["valor"], "evidencia": f["evidencia"]}
                            for f in detalhe["flags"]],
        "compensacao_rs": r.get("multa"),
        "qtd_vinculadas": len(vinc),
        "passos_manobra": [_limpar_registro(p, CAMPOS_PASSO, mascara) for p in passos[:MAX_PASSOS]],
        "os_vinculadas": [_limpar_registro(v, CAMPOS_VINCULADA, mascara) for v in vinc[:MAX_VINCULADAS]],
    }
    if len(passos) > MAX_PASSOS:
        ctx["passos_omitidos"] = len(passos) - MAX_PASSOS
    if len(vinc) > MAX_VINCULADAS:
        ctx["vinculadas_omitidas"] = len(vinc) - MAX_VINCULADAS
    bdgd = resumo_bdgd(manobra)
    if bdgd:
        ctx["bdgd"] = bdgd
    return ctx


def _hash(contexto: dict, modelo: str, sistema: str = "") -> str:
    """Mesma OS, mesmo modelo e mesmo prompt de sistema (que inclui os textos padrões) = reaproveita."""
    bruto = json.dumps({"c": contexto, "m": modelo, "v": VERSAO_PROMPT,
                        "s": hashlib.sha256(sistema.encode("utf-8")).hexdigest()},
                       sort_keys=True, ensure_ascii=False, default=str)
    return hashlib.sha256(bruto.encode("utf-8")).hexdigest()


def _textos_padrao() -> list[tuple[int, str]]:
    try:
        from .. import textos_padrao

        return textos_padrao.ativos()
    except Exception:  # noqa: BLE001 - sem textos a análise segue, só não sugere justificativa
        return []


@dataclass
class ResultadoAnalise:
    os_fila_id: int
    analise_id: int | None
    veredito: str | None
    reaproveitada: bool = False
    erro: str | None = None


def _preparar(os_fila_id: int, modelo: str, textos: list[tuple[int, str]] | None = None
              ) -> tuple[dict, str, AnaliseLLM | None]:
    detalhe = servicos.detalhe_os(os_fila_id)
    if detalhe is None:
        raise KeyError(os_fila_id)
    contexto = montar_contexto(detalhe, CONFIG.llm_mascarar, _manobra_bdgd(detalhe))
    h = _hash(contexto, modelo, prompt_sistema(textos))
    with db.sessao() as s:
        existente = s.scalars(select(AnaliseLLM).where(AnaliseLLM.os_fila_id == os_fila_id, AnaliseLLM.hash_entrada == h,
                                                       AnaliseLLM.erro.is_(None))).first()
    return contexto, h, existente


def _gravar(os_fila_id: int, provedor: ProvedorLLM, h: str, resposta, erro: str | None, usuario: str) -> int:
    with db.sessao() as s:
        a = AnaliseLLM(os_fila_id=os_fila_id, provedor=provedor.nome, modelo=provedor.modelo, hash_entrada=h, erro=erro)
        item = s.get(OSFila, os_fila_id)
        if resposta is not None:
            parsed, bruto = resposta
            a.veredito, a.confianca, a.resposta = parsed.veredito, parsed.confianca, parsed.model_dump()
            a.tokens_entrada, a.tokens_saida, a.tokens_cache = bruto.tokens_entrada, bruto.tokens_saida, bruto.tokens_cache
            item.veredito_llm, item.confianca_llm = parsed.veredito, parsed.confianca
            # sugestões antigas do LLM ainda não decididas são substituídas pelas novas
            for antiga in s.scalars(select(Correcao).where(Correcao.os_fila_id == os_fila_id, Correcao.origem == "llm",
                                                           Correcao.status == "proposta")):
                s.delete(antiga)
            if parsed.veredito == "errada":
                for c in parsed.correcoes:
                    s.add(Correcao(os_fila_id=os_fila_id, origem="llm", tipo=c.tipo, campo=c.campo, alvo=c.alvo,
                                   valor_atual=c.valor_atual, valor_novo=c.valor_novo, justificativa=c.justificativa))
        s.add(a)
        s.flush()
        servicos.auditar(s, usuario, "analise_llm", item.os, veredito=a.veredito, erro=erro)
        s.commit()
        return a.id


def _chamar(provedor: ProvedorLLM, contexto: dict, textos: list[tuple[int, str]] | None = None):
    bruto = provedor.completar(prompt_sistema(textos), prompt_usuario(contexto))
    try:
        parsed = RespostaAnalise.model_validate(bruto.conteudo)
    except ValidationError as e:
        raise ErroLLM(f"Resposta fora do formato esperado: {e.errors()[:3]}") from e
    # o número só vale se for de um texto enviado e a OS estiver errada
    por_id = dict(textos or [])
    if parsed.veredito != "errada" or parsed.justificativa_padrao not in por_id:
        parsed.justificativa_padrao = None
    parsed.justificativa_padrao_texto = por_id.get(parsed.justificativa_padrao)
    return parsed, bruto


def analisar_os(os_fila_id: int, provedor: ProvedorLLM | None = None, forcar: bool = False,
                usuario: str = "") -> ResultadoAnalise:
    provedor = provedor or criar_provedor()
    textos = _textos_padrao()
    contexto, h, existente = _preparar(os_fila_id, provedor.modelo, textos)
    if existente and not forcar:
        return ResultadoAnalise(os_fila_id, existente.id, existente.veredito, reaproveitada=True)
    try:
        resposta = _chamar(provedor, contexto, textos)
    except ErroLLM as e:
        aid = _gravar(os_fila_id, provedor, h, None, str(e), usuario)
        return ResultadoAnalise(os_fila_id, aid, None, erro=str(e))
    aid = _gravar(os_fila_id, provedor, h, resposta, None, usuario)
    return ResultadoAnalise(os_fila_id, aid, resposta[0].veredito)


# ------------------------------------------------------------ análise em lote
@dataclass
class Tarefa:
    id: str
    total: int
    feitas: int = 0
    erros: int = 0
    reaproveitadas: int = 0
    situacao: str = "rodando"  # rodando | concluida | cancelada | erro
    mensagem: str = ""
    cancelar: bool = False
    vereditos: dict = field(default_factory=dict)


TAREFAS: dict[str, Tarefa] = {}


def iniciar_analise_lote(ids: list[int], usuario: str = "", forcar: bool = False,
                         provedor: ProvedorLLM | None = None) -> Tarefa:
    provedor = provedor or criar_provedor()
    tarefa = Tarefa(id=uuid.uuid4().hex[:12], total=len(ids))
    TAREFAS[tarefa.id] = tarefa

    def rodar():
        try:
            with ThreadPoolExecutor(max_workers=max(1, CONFIG.llm_paralelo)) as ex:
                futuros = {}
                for i in ids:
                    if tarefa.cancelar:
                        break
                    futuros[ex.submit(analisar_os, i, provedor, forcar, usuario)] = i
                for f in as_completed(futuros):
                    r = f.result()
                    tarefa.feitas += 1
                    tarefa.erros += 1 if r.erro else 0
                    tarefa.reaproveitadas += 1 if r.reaproveitada else 0
                    if r.veredito:
                        tarefa.vereditos[r.veredito] = tarefa.vereditos.get(r.veredito, 0) + 1
                    if tarefa.cancelar:
                        for outro in futuros:
                            outro.cancel()
            tarefa.situacao = "cancelada" if tarefa.cancelar else "concluida"
        except Exception as e:  # noqa: BLE001
            tarefa.situacao, tarefa.mensagem = "erro", f"{type(e).__name__}: {e}"

    threading.Thread(target=rodar, daemon=True, name=f"llm-{tarefa.id}").start()
    return tarefa
