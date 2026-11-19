"""Provedores de LLM. Hoje: DeepSeek (API compatível com o SDK `openai`).

Para trocar de provedor, crie outra classe com o método `completar` e registre em `criar_provedor`.
"""
from __future__ import annotations

import json
import time
from dataclasses import dataclass, field
from typing import Protocol

from ..config import CONFIG, chave_deepseek


class ErroLLM(RuntimeError):
    pass


@dataclass
class RespostaLLM:
    conteudo: dict
    texto: str
    modelo: str
    tokens_entrada: int | None = None
    tokens_saida: int | None = None
    tokens_cache: int | None = None
    extras: dict = field(default_factory=dict)


class ProvedorLLM(Protocol):
    nome: str
    modelo: str

    def completar(self, sistema: str, usuario: str) -> RespostaLLM: ...


class DeepSeek:
    nome = "deepseek"

    def __init__(self, modelo: str | None = None, base_url: str | None = None, chave: str | None = None,
                 timeout: float = 120.0, tentativas: int = 3):
        chave = chave or chave_deepseek()
        if not chave:
            raise ErroLLM("Chave da DeepSeek não configurada. Rode: python -m osanalise.config definir-chave")
        from openai import OpenAI

        self.modelo = modelo or CONFIG.llm_modelo
        self._cliente = OpenAI(api_key=chave, base_url=base_url or CONFIG.llm_base_url, timeout=timeout,
                               max_retries=tentativas)

    def completar(self, sistema: str, usuario: str, max_tokens: int = 3000) -> RespostaLLM:
        from openai import APIConnectionError, APIStatusError, RateLimitError

        for tentativa in range(3):
            try:
                r = self._cliente.chat.completions.create(
                    model=self.modelo,
                    messages=[{"role": "system", "content": sistema}, {"role": "user", "content": usuario}],
                    response_format={"type": "json_object"},
                    temperature=0,
                    max_tokens=max_tokens,
                )
                break
            except RateLimitError:
                time.sleep(5 * (tentativa + 1))
            except APIConnectionError as e:
                if tentativa == 2:
                    raise ErroLLM(f"Sem conexão com a DeepSeek: {e}") from e
                time.sleep(3)
            except APIStatusError as e:
                raise ErroLLM(f"DeepSeek respondeu {e.status_code}: {e.message}") from e
        else:
            raise ErroLLM("DeepSeek: limite de requisições")
        texto = r.choices[0].message.content or ""
        try:
            conteudo = json.loads(texto)
        except json.JSONDecodeError as e:
            if r.choices[0].finish_reason == "length" and max_tokens < 8000:
                return self.completar(sistema, usuario, max_tokens * 2)  # resposta cortada: tenta com mais espaço
            raise ErroLLM(f"Resposta não é JSON válido: {texto[:200]}") from e
        uso = r.usage
        cache = getattr(uso, "prompt_cache_hit_tokens", None) if uso else None
        return RespostaLLM(conteudo=conteudo, texto=texto, modelo=r.model or self.modelo,
                           tokens_entrada=getattr(uso, "prompt_tokens", None),
                           tokens_saida=getattr(uso, "completion_tokens", None), tokens_cache=cache)


def criar_provedor(nome: str | None = None) -> ProvedorLLM:
    nome = (nome or CONFIG.llm_provedor).lower()
    if nome == "deepseek":
        return DeepSeek()
    raise ErroLLM(f"Provedor de LLM desconhecido: {nome}")
