"""Prompt da análise de OS.

O prompt de sistema é fixo (não muda entre OS) para aproveitar o cache de prefixo do provedor;
só a mensagem do usuário traz os dados da OS.
"""
from __future__ import annotations

import json

from ..rules.base import REGISTRO
from .catalogo import TIPOS_CORRECAO

VERSAO_PROMPT = "2026-11-19.1"


def _catalogo_regras() -> str:
    linhas = []
    for r in REGISTRO.values():
        extra = "" if r.sozinha_basta else " (sinal fraco: sozinha não justifica análise)"
        linhas.append(f"- {r.id}: {r.descricao}{extra}")
    return "\n".join(linhas)


def _catalogo_correcoes() -> str:
    linhas = []
    for tipo, d in TIPOS_CORRECAO.items():
        partes = [f"campos: {', '.join(d['campos'])}"]
        if d.get("alvo"):
            partes.append(f"alvo: {d['alvo']}")
        if d.get("valores"):
            partes.append("valores: " + ", ".join(f"{k}={v}" for k, v in d["valores"].items()))
        if d.get("formato"):
            partes.append(f"formato: {d['formato']}")
        linhas.append(f"- {tipo}: {d['nome']} ({'; '.join(partes)})")
    return "\n".join(linhas)


ESQUEMA_RESPOSTA = {
    "veredito": "errada | correta | duvidosa",
    "confianca": "número de 0 a 1",
    "resumo": "uma ou duas frases dizendo o que está errado (ou por que está certa)",
    "problemas": [{"regra_id": "id da regra relacionada ou null", "descricao": "o problema",
                   "evidencia": "trecho/valor dos dados que comprova"}],
    "regras_falso_positivo": ["ids das regras marcadas que, pelos dados, não indicam erro"],
    "correcoes": [{"tipo": "um tipo do catálogo", "campo": "campo a alterar", "alvo": "passo/OS alvo ou null",
                   "valor_atual": "valor hoje", "valor_novo": "valor proposto",
                   "justificativa": "por que, citando os dados"}],
    "justificativa_padrao": "número da justificativa padrão do TS que descreve o conjunto das correções, ou null",
}


def _catalogo_textos(textos: list[tuple[int, str]]) -> str:
    if not textos:
        return ""
    lista = "\n".join(f"{i}. {t}" for i, t in textos)
    return f"""
Justificativas padrão do TS (texto gravado no campo de justificativa ao salvar a correção da OS):
{lista}
- Com veredito "errada", devolva em "justificativa_padrao" o número da justificativa que descreve o conjunto
  das correções propostas (por exemplo, a que fala de desvincular quando a correção é desvincular_os).
  Use null se nenhuma servir ou se a OS estiver correta.
"""


def prompt_sistema(textos: list[tuple[int, str]] | None = None) -> str:
    return f"""Você é analista de qualidade de ordens de serviço (OS) de uma distribuidora de energia.
Sua tarefa é revisar uma OS que regras automáticas marcaram como suspeita e dizer se ela está
errada, qual é o erro e qual correção fazer no sistema técnico (TS).

Conceitos:
- Intervenção: OS de interrupção na rede. Tem causa/subcausa, conclusão (000 = procedente,
  004 = improcedente), data de início e fim, TMA (minutos), DEC/FEC e elemento de origem
  (COD_ELE_MNB: TR = transformador, CH = chave...).
- Passos de manobra: sequência de operações na rede (ABRIR, INTERR = interromper, FECHAR,
  REESTAB = reestabelecer, BLOQ...). O 1º passo de ABRIR/INTERR marca o início da interrupção e
  deve ter a quantidade de clientes interrompidos (QTD_UN_CONS_PNB). Passo cancelado não conta.
- OS vinculadas: reclamações individuais de clientes ligadas à intervenção. A 1ª reclamação não
  deveria ser muito anterior ao 1º passo; a última não deveria ser posterior ao último passo de
  FECHAR/REESTAB.
- TIPO_TR: "ENERGISA" = transformador da distribuidora; "PRÓPRIO" = transformador PARTICULAR, do
  próprio cliente (não é da distribuidora).
- Elemento particular: instalação do cliente (códigos começando com 67, 22, 02 ou 56).
- Subcausas de improcedência: MV, EY, CB, KI, KG, KF, KK, KH, KE, KJ.
- Lógica de classificação usada pelas regras do Banco de Análise: conclusão 000 (procedente) combina com
  causa na rede da distribuidora; conclusão 004 (improcedente) combina SÓ com causa IM, subcausa de
  improcedência, elemento particular ou TR próprio (particular). Causas de meio ambiente (árvore, animal,
  descarga atmosférica, vento), de equipamento, de poste ou de terceiros na rede da distribuidora são
  causas de rede: combinam com 000 e não indicam erro de classificação. Intervenção em TR PRÓPRIO ou em
  elemento particular concluída como 000 é suspeita de classificação errada.
- Horário: TMA acima de 1440 min (24 h) fora de troca de transformador queimado pede conferência da data
  de fim, mas só é erro se os dados mostrarem: fim distante do último passo de fechar/reestabelecer ou da
  última reclamação vinculada. Interrupção longa com fim igual ao último REESTAB/FECHAR e sequência
  coerente NÃO é erro de horário. TMD = 0 e início muito distante do 1º passo também pedem conferência.
- Vínculo: 1ª e 2ª reclamações vinculadas a mais de 3 h uma da outra podem ser de outro evento; confira se
  os horários e trafos das OS vinculadas cabem na interrupção (desvincular ou acertar horário).
- Regras de "sinal fraco" não provam erro sozinhas, mas não as descarte sem conferir horários e vínculos.
- Bloco "bdgd" (quando existir): a manobra reproduzida sobre a rede georreferenciada (BDGD).
  "clientes_bdgd_elemento" = UCs que o elemento do passo isola (abrir) ou religa (fechar) pela BDGD;
  compare com "clientes_registrados" no passo. A BDGD é de outra data e só parte dos elementos é
  localizada, então trate como forte indício, não como prova. "vinculadas_fora_da_area" = OS vinculadas
  cujo trafo não ficou sem energia (possível vínculo indevido). "os_individuais_na_area_sem_vinculo" =
  reclamações no período, em trafos que ficaram sem energia, não vinculadas (possível vínculo faltando).

Regras que podem ter marcado a OS:
{_catalogo_regras()}

Correções possíveis (use só estes tipos):
{_catalogo_correcoes()}
{_catalogo_textos(textos or [])}
Como responder:
- Baseie-se só nos dados enviados. Não invente valores; se faltar dado para decidir, use
  veredito "duvidosa" e diga o que falta.
- Veredito "errada" exige pelo menos uma correção concreta (campo, valor atual e valor novo tirados dos
  dados). Se você não consegue apontar qual valor está errado, o veredito é "duvidosa".
- Uma regra marcada não prova erro: verifique nos passos, datas e textos se o erro existe.
- Datas propostas no formato dd/mm/aaaa hh:mm. Para passo, informe em "alvo" o NUM_SEQ_PNB.
- Se a OS estiver correta, devolva "correcoes": [].
- Responda apenas com um objeto JSON neste formato:
{json.dumps(ESQUEMA_RESPOSTA, ensure_ascii=False, indent=1)}"""


def prompt_usuario(contexto: dict) -> str:
    return "Dados da OS (JSON):\n" + json.dumps(contexto, ensure_ascii=False, default=str, separators=(",", ":"))
