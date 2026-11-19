"""Textos padrões de justificativa das correções no TS.

Vêm da planilha "TEXTOS PADRÕES PARA CORREÇÕES" (coluna JUSTIFICATIVA CORREÇÃO): é o texto que o analista,
e depois o robô, escreve no campo de justificativa do SMANUTOS ("Informe o motivo da ação") ao salvar a
correção. Uma justificativa vale para o conjunto de alterações da OS, por isso é escolhida por OS.

Cada texto recebe as categorias de correção do Banco de Análise (as mesmas de "O que foi corrigido"),
por palavras-chave; o analista pode acertar as categorias na tela Textos, e o acerto sobrevive a uma
nova carga da planilha.
"""
from __future__ import annotations

import logging
import re
import threading
import unicodedata
from pathlib import Path

from sqlalchemy import select

from . import db
from .db import TextoPadrao, agora

COLUNA_TEXTO = "JUSTIFICATIVA CORRECAO"
COLUNA_ERRO = "ERRO ENCONTRADO"

# categoria -> padrão (sobre o texto em maiúsculas, sem acento). A ordem não importa.
PADROES_CATEGORIA = {
    "classificacao": r"CLASSIFICA|UC NORMAL|^ATENDIMENTO|PROGRAMACAO EMERGENCIAL|DESLIGAMENTO EMERGENCIAL"
                     r"|^INTERVENCAO CANCELADA",
    "os_vinculada": r"DESVINCULAD|\bO\.?S\.? VINCULADA|VINCULADA MANUAL|VINCULACAO|ABRANGENCIA|SEM INTERACAO"
                    r"|ATENDID[OA] (POR|PELA|NA|CONFORME)",
    "passo_manobra": r"PASSO|MANOBRA|ELEMENTO (INTERROMPIDO|RESTABELECIDO|MANOBRADO|VALIDADO)",
    "horario": r"\bHORA|\bTEMPO|\bTMD\b|RETROAG",
    "elemento_origem": r"ELEMENTO ORIGEM|^INTERVENCAO GERADA NO ELEMENTO ERRADO",
}


def sem_acento(texto: str) -> str:
    return unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode().upper()


def limpar(texto) -> str:
    return re.sub(r"\s+", " ", str(texto)).strip()


def categorias_do_texto(texto: str) -> list[str]:
    t = sem_acento(limpar(texto))
    return sorted(c for c, padrao in PADROES_CATEGORIA.items() if re.search(padrao, t))


def ler_planilha(caminho: str | Path) -> list[dict]:
    """Lê a coluna JUSTIFICATIVA CORREÇÃO (em qualquer aba) e a ERRO ENCONTRADO, se houver."""
    import openpyxl

    wb = openpyxl.load_workbook(caminho, read_only=True, data_only=True)
    try:
        for ws in wb.worksheets:
            linhas = ws.iter_rows(values_only=True)
            for n_linha, linha in enumerate(linhas, start=1):
                cab = [sem_acento(limpar(c)) if c is not None else "" for c in linha]
                if COLUNA_TEXTO not in cab:
                    if n_linha >= 20:
                        break
                    continue
                i_texto = cab.index(COLUNA_TEXTO)
                i_erro = cab.index(COLUNA_ERRO) if COLUNA_ERRO in cab else None
                textos, vistos = [], set()
                for ordem, l in enumerate(linhas, start=1):
                    bruto = l[i_texto] if i_texto < len(l) else None
                    t = limpar(bruto) if bruto is not None else ""
                    if not t or t.upper() in vistos:
                        continue
                    vistos.add(t.upper())
                    erro = l[i_erro] if i_erro is not None and i_erro < len(l) else None
                    textos.append({"texto": t, "erro": limpar(erro) if erro else None, "ordem": ordem})
                return textos
    finally:
        wb.close()
    raise ValueError('planilha sem a coluna "JUSTIFICATIVA CORREÇÃO"')


def importar(caminho: str | Path, usuario: str = "") -> dict:
    """Carrega a planilha: textos novos entram, os que sumiram ficam inativos (não são apagados)."""
    from .servicos import auditar

    lidos = ler_planilha(caminho)
    if not lidos:
        raise ValueError("nenhum texto na coluna JUSTIFICATIVA CORREÇÃO")
    novos = atualizados = desativados = 0
    with db.sessao() as s:
        existentes = {t.texto.upper(): t for t in s.scalars(select(TextoPadrao))}
        vistos = set()
        for item in lidos:
            chave = item["texto"].upper()
            vistos.add(chave)
            t = existentes.get(chave)
            if t is None:
                s.add(TextoPadrao(texto=item["texto"], erro=item["erro"], ordem=item["ordem"],
                                  categorias=categorias_do_texto(item["texto"])))
                novos += 1
                continue
            mudou = (t.ordem, t.erro, t.ativo) != (item["ordem"], item["erro"], True)
            t.ordem, t.erro, t.ativo = item["ordem"], item["erro"], True
            if not t.categorias_manuais:
                cats = categorias_do_texto(t.texto)
                mudou = mudou or cats != t.categorias
                t.categorias = cats
            if mudou:
                t.atualizado_em = agora()
                atualizados += 1
        for chave, t in existentes.items():
            if chave not in vistos and t.ativo:
                t.ativo, t.atualizado_em = False, agora()
                desativados += 1
        resumo = {"total": len(lidos), "novos": novos, "atualizados": atualizados, "desativados": desativados,
                  "arquivo": Path(caminho).name}
        auditar(s, usuario, "carregar_textos_padrao", Path(caminho).name, **resumo)
        s.commit()
    with _trava:
        _versao[0] += 1
    return resumo


def _dict(t: TextoPadrao) -> dict:
    return {c.name: getattr(t, c.name) for c in TextoPadrao.__table__.columns}


def listar(incluir_inativos: bool = True) -> list[dict]:
    carregar_se_vazio()
    with db.sessao() as s:
        q = select(TextoPadrao).order_by(TextoPadrao.ativo.desc(), TextoPadrao.ordem, TextoPadrao.id)
        if not incluir_inativos:
            q = q.where(TextoPadrao.ativo.is_(True))
        return [_dict(t) for t in s.scalars(q)]


def ativos() -> list[tuple[int, str]]:
    """(id, texto) dos textos em uso, na ordem da planilha (para o prompt do LLM)."""
    return [(t["id"], t["texto"]) for t in listar(incluir_inativos=False)]


def atualizar(texto_id: int, usuario: str = "", categorias: list[str] | None = None,
              ativo: bool | None = None) -> dict:
    from .servicos import CATEGORIAS_ACCESS, auditar

    with db.sessao() as s:
        t = s.get(TextoPadrao, texto_id)
        if t is None:
            raise KeyError(texto_id)
        mudou = {}
        if categorias is not None:
            invalidas = set(categorias) - set(CATEGORIAS_ACCESS.values())
            if invalidas:
                raise ValueError(f"categoria inválida: {', '.join(sorted(invalidas))}")
            novas = sorted(set(categorias))
            if novas != t.categorias:
                mudou["categorias"] = [t.categorias, novas]
                t.categorias, t.categorias_manuais = novas, True
        if ativo is not None and ativo != t.ativo:
            mudou["ativo"] = [t.ativo, ativo]
            t.ativo = ativo
        if mudou:
            t.atualizado_em = agora()
            auditar(s, usuario, "editar_texto_padrao", str(t.id), **mudou)
            s.commit()
            with _trava:
                _versao[0] += 1
        return _dict(t)


# carga automática: na primeira consulta, se o banco não tem textos e o arquivo apontado (ou o da pasta
# do projeto) existe, carrega-o. Assim o LLM e a tela já têm os textos sem passo manual.
_trava = threading.Lock()
_versao = [0]
_tentou_carga = [False]


_trava_carga = threading.Lock()


def carregar_se_vazio() -> None:
    if _tentou_carga[0]:
        return
    with _trava_carga:  # uma requisição carrega; as que chegam juntas esperam e já veem os textos
        if _tentou_carga[0]:
            return
        try:
            with db.sessao() as s:
                vazio = s.scalar(select(TextoPadrao.id).limit(1)) is None
            if vazio:
                from . import fontes

                caminho = fontes.caminho_salvo("textos") or fontes.sugerido("textos")
                if caminho and Path(caminho).is_file():
                    importar(caminho, "carga automática")
            _tentou_carga[0] = True
        except Exception:  # noqa: BLE001 - tenta de novo na próxima consulta; a tela permite carregar à mão
            logging.getLogger(__name__).exception("carga automática dos textos padrões falhou")
