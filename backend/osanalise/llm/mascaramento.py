"""Remove dados pessoais antes de enviar o texto da OS para um LLM externo.

Mascara telefones, CPF, e-mail e números de UC citados no texto. Nomes de cliente e
endereços nem chegam aqui: os campos NOM_CLI_CNR, DES_ENDE_UN_CONS_CNR e NUM_FONE_CNR não
são enviados (ver analisador.CAMPOS_NUNCA_ENVIAR). Códigos de instalação (10 dígitos) e
números de OS (14 dígitos) são mantidos porque fazem parte da análise.
"""
from __future__ import annotations

import re

_CPF = re.compile(r"(?<!\d)\d{3}\.?\d{3}\.?\d{3}-?\d{2}(?!\d)")
_EMAIL = re.compile(r"[\w.+-]+@[\w-]+\.[\w.]+")
# celular com DDD: 2 dígitos + 9 + 8 dígitos, com ou sem separadores
_CELULAR = re.compile(r"(?<!\d)(?:\+?55[\s-]?)?\(?0?[1-9]\d\)?[\s-]?9\d{4}[\s-]?\d{4}(?!\d)")
# fixo só quando vem depois de palavra que indica telefone
_FIXO = re.compile(r"(?i)\b(fone|tel(?:efone)?|cel(?:ular)?|contato|whats(?:app)?|ligar)\b\D{0,5}\(?\d{2}\)?[\s-]?\d{4}[\s-]?\d{4}")
_UC = re.compile(r"(?i)\b(UC|unidade consumidora|conta contrato)\b\s*[:nº°.#-]*\s*\d{5,}")


def mascarar(texto: str | None) -> str | None:
    if not texto:
        return texto
    t = _EMAIL.sub("[email]", texto)
    t = _UC.sub(lambda m: f"{m.group(1)} [uc]", t)
    t = _FIXO.sub(lambda m: f"{m.group(1)} [telefone]", t)
    t = _CELULAR.sub("[telefone]", t)
    t = _CPF.sub("[cpf]", t)
    t = t.replace("_x000D_", " ")
    return re.sub(r"[ \t]{2,}", " ", t).strip()
