"""Visualizador da manobra: reproduz os passos de uma intervenção sobre a rede da BDGD.

Para cada passo de ABRIR/INTERR/FECHAR/REESTAB cujo elemento foi localizado na BDGD, aplica a
mudança de estado e calcula as UCs desligadas. Compara com a quantidade registrada no passo e
verifica se as OS vinculadas estão dentro da área desligada. Também lista OS individuais da
mesma janela de tempo, dentro da área, que não estão vinculadas.
"""
from __future__ import annotations

import threading
from collections import Counter, OrderedDict, defaultdict
from datetime import datetime, timedelta

import pandas as pd
from sqlalchemy import text

from .. import db, servicos
from ..config import CONFIG
from ..dados import para_data
from . import equivalencia as eq
from .indice import conectar
from .rede import Rede

ABRE = {"ABRIR", "INTERR"}
FECHA = {"FECHAR", "REESTAB"}
MAX_ALIMENTADORES = 4
JANELA_ANTES_MIN = 120


def _data(v) -> datetime | None:
    if not v:
        return None
    for fmt in ("%d/%m/%Y %H:%M", "%Y-%m-%d %H:%M:%S"):
        try:
            return datetime.strptime(str(v)[:19] if "-" in str(v) else str(v), fmt)
        except ValueError:
            continue
    return None


def _fmt(d: datetime | None) -> str | None:
    return d.strftime("%d/%m/%Y %H:%M") if d else None


class SemBDGD(RuntimeError):
    pass


_CACHE: "OrderedDict[tuple, dict]" = OrderedDict()
_CACHE_MAX = 32
_trava_cache = threading.Lock()


def analisar(os_fila_id: int) -> dict:
    """Simulação da manobra com cache: muda só quando a BDGD ou as equivalências de chave mudam."""
    from sqlalchemy import func, select

    from .indice import caminho_indice

    arq = caminho_indice()
    with db.sessao() as s:
        n_equiv = s.scalar(select(func.count()).select_from(db.EquivChave))
    chave = (os_fila_id, str(arq), n_equiv)
    with _trava_cache:
        if chave in _CACHE:
            _CACHE.move_to_end(chave)
            return _CACHE[chave]
    resultado = _analisar_os(os_fila_id)
    # a análise pode aprender equivalências novas (elemento da compensação): guarda com a contagem atual
    with db.sessao() as s:
        n_depois = s.scalar(select(func.count()).select_from(db.EquivChave))
    with _trava_cache:
        _CACHE[(os_fila_id, str(arq), n_depois)] = resultado
        while len(_CACHE) > _CACHE_MAX:
            _CACHE.popitem(last=False)
    return resultado


def _analisar_os(os_fila_id: int) -> dict:
    det = servicos.detalhe_os(os_fila_id)
    if det is None:
        raise KeyError(os_fila_id)
    if det["resumo"]["tipo_os"] != "intervencao":
        raise ValueError("O visualizador de manobra é para OS de intervenção")
    try:
        con = conectar()
    except FileNotFoundError as e:
        raise SemBDGD(str(e)) from e
    try:
        return _analisar(det, con)
    finally:
        con.close()


def _analisar(det: dict, con) -> dict:
    reg, passos, vinc = det["registro"], det["passos"], det["vinculadas"]
    avisos: list[str] = []

    # ------------------------------------------------ elemento da ocorrência (aprende equivalência)
    comp = pd.DataFrame(det["compensacao"])
    ponto_ocorrencia = None
    if not comp.empty:
        r0 = comp.iloc[0]
        ponto_ocorrencia = eq.ponto_utm(r0.get("NUM_COORX_INT"), r0.get("NUM_COORY_INT"))
        eq.aprender(con, comp)

    # ------------------------------------------------ localizar elementos dos passos
    passos_validos = [p for p in passos if str(p.get("STA_EXEC_PNB") or "").upper() != "PASSO CANCELADO"]
    cod_passos = [str(p.get("COD_INS_SEC_INS") or "") for p in passos_validos]
    trafos_ts = eq.trafos_por_codigo_ts(con, cod_passos + [str(v.get("COD_INS_TRF_INT") or "") for v in vinc])
    chaves_eq = eq.chaves_equivalentes([c for c in cod_passos if c not in trafos_ts])
    chaves_bdgd = {}
    cods_chave = [v[0] for v in chaves_eq.values() if not v[0].startswith(eq.PREFIXO_ALIMENTADOR)]
    if cods_chave:
        marcas = ",".join("?" * len(cods_chave))
        for r in con.execute(f"SELECT * FROM chave WHERE cod_id IN ({marcas})", cods_chave):
            chaves_bdgd[r["cod_id"]] = r

    # ------------------------------------------------ alimentadores envolvidos
    votos: Counter = Counter()
    nome_para_ct = {r["nome"]: r["cod_id"] for r in con.execute("SELECT cod_id, nome FROM ctmt")}
    if not comp.empty and comp.iloc[0].get("COD_ALIM_ALN") in nome_para_ct:
        votos[nome_para_ct[comp.iloc[0]["COD_ALIM_ALN"]]] += 5
    for v in vinc:
        t = trafos_ts.get(str(v.get("COD_INS_TRF_INT") or ""))
        if t is not None and t["ctmt"]:
            votos[t["ctmt"]] += 1
    for c in cod_passos:
        if c in trafos_ts and trafos_ts[c]["ctmt"]:
            votos[trafos_ts[c]["ctmt"]] += 2
        elif c in chaves_eq and chaves_eq[c][0].startswith(eq.PREFIXO_ALIMENTADOR):
            votos[chaves_eq[c][0][len(eq.PREFIXO_ALIMENTADOR):]] += 3
        elif c in chaves_eq and chaves_eq[c][0] in chaves_bdgd:
            ch = chaves_bdgd[chaves_eq[c][0]]
            for ct in (ch["ctmt1"], ch["ctmt2"]):
                if ct:
                    votos[ct] += 2
    if not votos:
        # diz o que foi procurado: o analista vê se é código novo, digitado errado ou falta de cadastro
        procurados = sorted({f"{p.get('COD_ELE_PNB') or ''} {c}".strip() for p, c in zip(passos_validos, cod_passos) if c})
        partes = []
        if procurados:
            partes.append("passos " + ", ".join(procurados[:6]) + ("…" if len(procurados) > 6 else ""))
        partes.append("sem compensação" if comp.empty else "alimentador da compensação não encontrado")
        if vinc:
            partes.append(f"trafo de nenhuma das {len(vinc)} OS vinculadas localizado")
        return {"disponivel": False, "motivo": "Nenhum elemento desta OS foi encontrado na BDGD: " + "; ".join(partes) + "."}
    alimentadores = [ct for ct, _ in votos.most_common(MAX_ALIMENTADORES)]
    rede = Rede.carregar(con, alimentadores)
    trafo_por_cod = {t.cod_id: t for t in rede.trafos}

    # ------------------------------------------------ estado normal e simulação
    nos0 = rede.energizados({})
    tr0 = rede.trafos_energizados(nos0)
    sec0 = {rede.secao_do_no[n] for n in nos0 if n in rede.secao_do_no}
    sem_ligacao = len(rede.trafos) - len(tr0)
    if sem_ligacao:
        avisos.append(f"{sem_ligacao} trafo(s) destes alimentadores não se ligam à saída na BDGD (lacunas da base); "
                      "ficam fora da contagem.")

    estado: dict[str, bool] = {}
    tr_abertos: set[str] = set()
    alim_desligados: set[str] = set()
    carregados = {c["cod_id"] for c in rede.ctmts}
    anterior_off: set[int] = set()
    linhas_passos = []
    pico = (0, set(), set())  # (ucs, trafos desligados, seções desligadas)
    operadas: dict[str, list[int]] = defaultdict(list)
    ordenados = sorted(enumerate(passos), key=lambda x: (_data(x[1].get("DTA_PASSO_PNB")) or datetime.max,
                                                         x[1].get("NUM_SEQ_PNB") or 0))
    for ordem, (_, p) in enumerate(ordenados):
        oper = str(p.get("COD_OPER_PNB") or "").upper()
        cod = str(p.get("COD_INS_SEC_INS") or "")
        cancelado = str(p.get("STA_EXEC_PNB") or "").upper() == "PASSO CANCELADO"
        linha = {"ordem": ordem, "seq": p.get("NUM_SEQ_PNB"), "data": p.get("DTA_PASSO_PNB"), "oper": oper,
                 "elemento": p.get("COD_ELE_PNB"), "cod_ts": cod, "status": p.get("STA_EXEC_PNB"),
                 "qtd_registrada": p.get("QTD_UN_CONS_PNB"), "localizado": None, "cod_bdgd": None,
                 "efeito": None, "ucs_elemento": None, "ucs_desligadas": None, "variacao": None,
                 "trafos_off": [], "secoes_off": []}
        alvo_chave = alvo_trafo = alvo_alim = None
        if cod in trafos_ts and trafos_ts[cod]["cod_id"] in trafo_por_cod:
            alvo_trafo = trafos_ts[cod]["cod_id"]
            linha.update(localizado="trafo", cod_bdgd=alvo_trafo)
        elif cod in chaves_eq and chaves_eq[cod][0].startswith(eq.PREFIXO_ALIMENTADOR):
            ct = chaves_eq[cod][0][len(eq.PREFIXO_ALIMENTADOR):]
            nome = next((c["nome"] for c in rede.ctmts if c["cod_id"] == ct), ct)
            if ct in carregados:
                alvo_alim = ct
                linha.update(localizado="alimentador", cod_bdgd=f"saída {nome}")
            else:
                linha.update(localizado="fora", cod_bdgd=f"saída {nome}")
        elif cod in chaves_eq and chaves_eq[cod][0] in rede.chaves:
            alvo_chave = chaves_eq[cod][0]
            linha.update(localizado="chave", cod_bdgd=alvo_chave, distancia_m=chaves_eq[cod][1])
        elif cod in chaves_eq:
            linha.update(localizado="fora", cod_bdgd=chaves_eq[cod][0])
        ucs_antes = None
        if not cancelado and (oper in ABRE or oper in FECHA) and (alvo_chave or alvo_trafo or alvo_alim):
            # clientes que o elemento isola/religa na configuração atual, com as saídas ligadas
            ucs_antes = _ucs_ligadas(rede, tr0, estado, set(), tr_abertos)
        if cancelado:
            linha["efeito"] = "cancelado"
        elif oper in ABRE or oper in FECHA:
            fechar = oper in FECHA
            if alvo_chave:
                estado[alvo_chave] = fechar
                operadas[alvo_chave].append(ordem)
                linha["efeito"] = "fecha" if fechar else "abre"
            elif alvo_trafo:
                (tr_abertos.discard if fechar else tr_abertos.add)(alvo_trafo)
                linha["efeito"] = "fecha" if fechar else "abre"
            elif alvo_alim:
                (alim_desligados.discard if fechar else alim_desligados.add)(alvo_alim)
                linha["efeito"] = "fecha" if fechar else "abre"
            else:
                linha["efeito"] = "nao_localizado"
        else:
            linha["efeito"] = "sem_efeito"
        if ucs_antes is not None and linha["efeito"] in ("abre", "fecha"):
            if alvo_alim:
                so_ela = _ucs_ligadas(rede, tr0, estado, {alvo_alim}, tr_abertos)
                linha["ucs_elemento"] = ucs_antes - so_ela
            else:
                depois = _ucs_ligadas(rede, tr0, estado, set(), tr_abertos)
                linha["ucs_elemento"] = (depois - ucs_antes) if linha["efeito"] == "fecha" else (ucs_antes - depois)
        if linha["efeito"] in ("abre", "fecha"):
            nos = rede.energizados(estado, alim_desligados)
            on = rede.trafos_energizados(nos, tr_abertos)
            off = tr0 - on
            sec_off = sec0 - {rede.secao_do_no[n] for n in nos if n in rede.secao_do_no}
            ucs = sum(rede.trafos[i].n_ucs for i in off)
            linha.update(ucs_desligadas=ucs, trafos_off=sorted(off), secoes_off=sorted(sec_off))
            linha["variacao"] = ucs - sum(rede.trafos[i].n_ucs for i in anterior_off)
            anterior_off = off
            if ucs > pico[0]:
                pico = (ucs, off, sec_off)
        linhas_passos.append(linha)

    # ------------------------------------------------ área provável pela topologia (estado normal)
    pai, aresta = rede.arvore()
    filhos = defaultdict(list)
    for n, p in pai.items():
        if p is not None:
            filhos[p].append(n)
    ucs_no = Counter()
    for t in rede.trafos:
        if t.i in tr0:
            ucs_no[t.pac1] += t.n_ucs
    ucs_sub: dict = {}
    for raiz in [n for n, p in pai.items() if p is None]:
        pilha, ordem_pos = [raiz], []
        while pilha:
            n = pilha.pop()
            ordem_pos.append(n)
            pilha.extend(filhos.get(n, ()))
        for n in reversed(ordem_pos):
            ucs_sub[n] = ucs_no.get(n, 0) + sum(ucs_sub[c] for c in filhos.get(n, ()))

    def chaves_acima(no) -> list[tuple[str, object]]:
        """Chaves no caminho até a fonte, de baixo para cima: (cod_id, nó a jusante)."""
        saida, guarda = [], 0
        while no is not None and guarda < 100000:
            a = aresta.get(no)
            if a and a[0] == "C":
                saida.append((a[1], no))
            no = pai.get(no)
            guarda += 1
        return saida

    trafos_vinc = {}
    for v in vinc:
        t = trafos_ts.get(str(v.get("COD_INS_TRF_INT") or ""))
        if t is not None and t["cod_id"] in trafo_por_cod:
            trafos_vinc[v["NUM_SEQ_OPER_CNR"]] = trafo_por_cod[t["cod_id"]]
    candidatos = {}
    if trafos_vinc:
        cobertura: Counter = Counter()
        profundidade = {}
        jusante = {}
        tr_unicos = {t.cod_id: t for t in trafos_vinc.values()}
        for t in tr_unicos.values():
            caminho = chaves_acima(t.pac1)
            for pos, (cod, no) in enumerate(caminho):
                if rede.chaves[cod].protecao or cod in operadas:
                    cobertura[cod] += 1
                    profundidade[cod] = len(caminho) - pos  # nº de chaves da saída do alimentador até ela
                    jusante[cod] = no
        alvo = max(1, int(0.8 * len(tr_unicos) + 0.999))
        cobre = [c for c, n in cobertura.items() if n >= alvo]
        if cobre:
            comum = max(cobre, key=lambda c: (profundidade[c], -ucs_sub.get(jusante[c], 0)))
            candidatos["protecao_comum"] = _cand(rede, comum, ucs_sub.get(jusante[comum], 0),
                                                 f"protege {cobertura[comum]} de {len(tr_unicos)} trafos das OS vinculadas")
            qtd = next((p.get("QTD_UN_CONS_PNB") for p in passos_validos
                        if str(p.get("COD_OPER_PNB") or "").upper() in ABRE and p.get("QTD_UN_CONS_PNB")), None)
            if qtd:
                caminho = chaves_acima(jusante[comum])
                melhor = min(caminho, key=lambda cn: abs(ucs_sub.get(cn[1], 0) - qtd)) if caminho else None
                if melhor:
                    candidatos["mais_proximo_qtd"] = _cand(rede, melhor[0], ucs_sub.get(melhor[1], 0),
                                                           f"UCs a jusante mais próximas de {int(qtd)} (1º passo)")
    elemento_comp = str(comp.iloc[0].get("ELEMENTO") or "") if not comp.empty else ""
    eq_comp = eq.chaves_equivalentes([elemento_comp]).get(elemento_comp) if elemento_comp else None
    if eq_comp and eq_comp[0].startswith(eq.PREFIXO_ALIMENTADOR):
        ct = eq_comp[0][len(eq.PREFIXO_ALIMENTADOR):]
        if ct in carregados:
            nos = rede.energizados({}, {ct})
            desl = tr0 - rede.trafos_energizados(nos)
            nome = next(c["nome"] for c in rede.ctmts if c["cod_id"] == ct)
            candidatos["elemento_ocorrencia"] = {
                "cod_id": f"saída {nome}", "tipo": "Disjuntor da saída", "elo": "", "lat": None, "lon": None,
                "ucs_jusante": sum(rede.trafos[i].n_ucs for i in desl),
                "motivo": f"elemento da compensação {elemento_comp} é o disjuntor do alimentador"}
    elif eq_comp and eq_comp[0] in rede.chaves:
        c = rede.chaves[eq_comp[0]]
        no_jus = next((n for n in (c.pac1, c.pac2) if aresta.get(n) == ("C", c.cod_id)), None)
        candidatos["elemento_ocorrencia"] = _cand(rede, c.cod_id, ucs_sub.get(no_jus, 0) if no_jus else None,
                                                  f"elemento da compensação {elemento_comp} ({eq_comp[1]:.0f} m)")
    elif ponto_ocorrencia:
        prox = min((c for c in rede.chaves.values() if c.lat is not None),
                   key=lambda c: (c.lat - ponto_ocorrencia[0]) ** 2 + (c.lon - ponto_ocorrencia[1]) ** 2, default=None)
        if prox is not None:
            no_jus = next((n for n in (prox.pac1, prox.pac2) if aresta.get(n) == ("C", prox.cod_id)), None)
            candidatos["elemento_ocorrencia"] = _cand(rede, prox.cod_id, ucs_sub.get(no_jus, 0) if no_jus else None,
                                                      "chave mais próxima da coordenada do elemento na compensação")

    # ------------------------------------------------ área para conferir vínculos
    if pico[0] > 0:
        area_trafos, area_secoes, origem_area = pico[1], pico[2], "simulação dos passos (maior desligamento)"
    else:
        cand = candidatos.get("elemento_ocorrencia") or candidatos.get("protecao_comum")
        area_trafos, area_secoes, origem_area = set(), set(), None
        if cand:
            if cand["tipo"] == "Disjuntor da saída":
                ct = next(c["cod_id"] for c in rede.ctmts if f"saída {c['nome']}" == cand["cod_id"])
                nos = rede.energizados({}, {ct})
            else:
                nos = rede.energizados({cand["cod_id"]: False})
            area_trafos = tr0 - rede.trafos_energizados(nos)
            area_secoes = sec0 - {rede.secao_do_no[n] for n in nos if n in rede.secao_do_no}
            origem_area = f"abertura de {cand['tipo'].lower()} {cand['cod_id']} ({cand['motivo']})"
    area_cods = {rede.trafos[i].cod_id for i in area_trafos}

    # ------------------------------------------------ OS vinculadas no mapa
    ucs_vinc = eq.ucs_bdgd(con, [str(v.get("COD_UN_CONS_CNR") or "") for v in vinc])
    vinculadas = []
    for v in vinc:
        t = trafos_vinc.get(v["NUM_SEQ_OPER_CNR"])
        uc = ucs_vinc.get(str(v.get("COD_UN_CONS_CNR") or ""))
        lat, lon = (uc["lat"], uc["lon"]) if uc is not None and uc["lat"] else ((t.lat, t.lon) if t else (None, None))
        vinculadas.append({"os": v["NUM_SEQ_OPER_CNR"], "recl": v.get("DTA_RECL_CNR"), "tipo": v.get("COD_TIPO_OS_CNR"),
                           "trafo_ts": v.get("COD_INS_TRF_INT"), "trafo": t.i if t else None,
                           "lat": lat, "lon": lon,
                           "na_area": (t.cod_id in area_cods) if (t and area_cods) else None})

    # ------------------------------------------------ OS individuais da janela dentro da área
    candidatas = _individuais_na_area(det, con, area_cods, {v["os"] for v in vinculadas})

    # ------------------------------------------------ desenho
    geo = rede.geometria_secoes(CONFIG.bdgd)
    chaves_mapa = []
    destaque = set(operadas) | {c["cod_id"] for c in candidatos.values()}
    for c in rede.chaves.values():
        if c.lat is None or not (c.protecao or not c.normal_fechada or c.cod_id in destaque):
            continue
        chaves_mapa.append({"cod_id": c.cod_id, "lat": round(c.lat, 6), "lon": round(c.lon, 6), "tipo": c.tipo,
                            "elo": c.cap_elo if c.cap_elo not in ("", "0") else "", "normal": "F" if c.normal_fechada else "A",
                            "passos": operadas.get(c.cod_id, [])})
    ts_dos_trafos = eq.codigos_ts_dos_trafos(con, [t.cod_id for t in rede.trafos])
    trafo_por_ts = {ts: trafo_por_cod[cod] for cod, ts in ts_dos_trafos.items() if cod in trafo_por_cod}
    for c in candidatas:
        t = trafo_por_ts.get(str(c.get("trafo_ts") or ""))
        c.update(trafo=t.i if t else None, lat=t.lat if t else None, lon=t.lon if t else None)
    n_vinc_tr = Counter(v["trafo"] for v in vinculadas if v["trafo"] is not None)
    trafos_mapa = [{"i": t.i, "cod_id": t.cod_id, "ts": ts_dos_trafos.get(t.cod_id), "lat": round(t.lat, 6),
                    "lon": round(t.lon, 6), "ucs": t.n_ucs, "kva": t.pot, "vinc": n_vinc_tr.get(t.i, 0),
                    "ligado": t.i in tr0}
                   for t in rede.trafos if t.lat is not None]

    abre_registrado = next((p for p in linhas_passos if p["oper"] in ABRE and p["efeito"] != "cancelado"), None)
    resumo = {
        "alimentadores": [{"cod_id": c["cod_id"], "nome": c["nome"], "subestacao": c["sub"]} for c in rede.ctmts],
        "ucs_alimentadores": sum(rede.trafos[i].n_ucs for i in tr0),
        "passos_total": len(linhas_passos),
        "passos_localizados": sum(1 for p in linhas_passos if p["localizado"] in ("chave", "trafo", "alimentador")),
        "passos_com_efeito": sum(1 for p in linhas_passos if p["efeito"] in ("abre", "fecha", "nao_localizado")),
        "pico_ucs": pico[0] or None,
        "qtd_primeiro_passo": abre_registrado["qtd_registrada"] if abre_registrado else None,
        "area_origem": origem_area,
        "area_ucs": sum(rede.trafos[i].n_ucs for i in area_trafos) if area_trafos else None,
        "area_trafos": len(area_trafos),
        "vinculadas_total": len(vinculadas),
        "vinculadas_localizadas": sum(1 for v in vinculadas if v["trafo"] is not None),
        "vinculadas_fora_area": sum(1 for v in vinculadas if v["na_area"] is False),
        "candidatas_vincular": len(candidatas),
    }
    return {"disponivel": True, "resumo": resumo, "candidatos": candidatos, "avisos": avisos,
            "ocorrencia": {"lat": ponto_ocorrencia[0], "lon": ponto_ocorrencia[1]} if ponto_ocorrencia else None,
            "secoes": {str(k): v for k, v in geo.items()}, "secoes_area": sorted(area_secoes),
            "chaves": chaves_mapa, "trafos": trafos_mapa, "trafos_area": sorted(area_trafos),
            "passos": linhas_passos, "vinculadas": vinculadas, "candidatas": candidatas,
            "inicio": reg.get("DTA_INIC_MNB"), "fim": reg.get("DTA_FIM_MNB")}


def _ucs_ligadas(rede: Rede, tr0: set[int], estado: dict, alim_off: set[str], tr_abertos: set[str]) -> int:
    nos = rede.energizados(estado, alim_off)
    return sum(rede.trafos[i].n_ucs for i in (rede.trafos_energizados(nos, tr_abertos) & tr0))


def _cand(rede: Rede, cod: str, ucs: int | None, motivo: str) -> dict:
    c = rede.chaves[cod]
    return {"cod_id": cod, "tipo": c.tipo, "elo": c.cap_elo if c.cap_elo not in ("", "0") else "",
            "lat": c.lat, "lon": c.lon, "ucs_jusante": ucs, "motivo": motivo}


def _individuais_na_area(det: dict, con, area_cods: set[str], ja_vinculadas: set[str]) -> list[dict]:
    if not area_cods:
        return []
    ts_area = eq.codigos_ts_dos_trafos(con, list(area_cods))
    if not ts_area:
        return []
    inicio = _data(det["registro"].get("DTA_INIC_MNB"))
    fim = _data(det["registro"].get("DTA_FIM_MNB"))
    if not inicio:
        return []
    fim = fim or inicio + timedelta(hours=24)
    lote_id = det["resumo"]["lote_id"]
    codigos = list(set(ts_area.values()))
    saida = []
    with db.engine_padrao().connect() as c:
        for i in range(0, len(codigos), 500):
            parte = codigos[i:i + 500]
            params = {f"c{j}": v for j, v in enumerate(parte)}
            marcas = ",".join(f":c{j}" for j in range(len(parte)))
            try:
                df = pd.read_sql(text(f'SELECT NUM_SEQ_OPER_CNR, DTA_RECL_CNR, DTA_FIM_CNR, COD_TIPO_OS_CNR, '
                                      f'COD_INS_TRF_INT, DES_CAUSA_INTER_CAU, COD_TIPO_CONCL_CNR FROM base_individual '
                                      f'WHERE lote_id = :l AND COD_INS_TRF_INT IN ({marcas})'),
                                 c, params={"l": lote_id, **params})
            except Exception:  # noqa: BLE001
                return []
            if df.empty:
                continue
            df["_recl"] = para_data(df["DTA_RECL_CNR"])
            janela = df[(df["_recl"] >= inicio - timedelta(minutes=JANELA_ANTES_MIN)) & (df["_recl"] <= fim)]
            for _, r in janela.iterrows():
                if r["NUM_SEQ_OPER_CNR"] in ja_vinculadas:
                    continue
                saida.append({"os": r["NUM_SEQ_OPER_CNR"], "recl": _fmt(r["_recl"].to_pydatetime()),
                              "tipo": r["COD_TIPO_OS_CNR"], "trafo_ts": r["COD_INS_TRF_INT"],
                              "causa": r["DES_CAUSA_INTER_CAU"], "conclusao": r["COD_TIPO_CONCL_CNR"]})
    return sorted(saida, key=lambda x: x["recl"] or "")
