"""Execução das correções aprovadas no TS, uma por vez, com status por item (KB_TS/09).

Modo teste: abre o TS, pesquisa cada OS e confere os dados, mas não salva nem muda o status da
correção (o resultado vai para `resultado_robo`).
"""
from __future__ import annotations

import threading
import time
from datetime import datetime

from sqlalchemy import select

from .. import db, servicos
from ..db import Correcao, OSFila, agora

MAX_TENTATIVAS = 2


class Robo:
    def __init__(self):
        self._thread: threading.Thread | None = None
        self._parar = threading.Event()
        self._estado = {"rodando": False, "modo_teste": True, "atual": None, "passo": "", "feitas": 0,
                        "total": 0, "erros": 0, "log": [], "inicio": None, "fim": None}

    def estado(self) -> dict:
        e = dict(self._estado)
        e["log"] = list(self._estado["log"][-200:])
        return e

    def _log(self, texto: str) -> None:
        self._estado["log"].append(f"{datetime.now():%H:%M:%S} {texto}")
        self._estado["passo"] = texto

    def parar(self) -> None:
        self._parar.set()

    def iniciar(self, ids: list[int] | None, modo_teste: bool, usuario: str) -> dict:
        if self._thread and self._thread.is_alive():
            raise RuntimeError("O robô já está rodando")
        with db.sessao() as s:
            q = select(Correcao.id).where(Correcao.status == "aprovada")
            if ids:
                q = q.where(Correcao.id.in_(ids))
            fila = list(s.scalars(q.order_by(Correcao.id)))
        if not fila:
            raise RuntimeError("Nenhuma correção aprovada para executar")
        self._parar.clear()
        self._estado.update(rodando=True, modo_teste=modo_teste, atual=None, feitas=0, total=len(fila), erros=0,
                            log=[], inicio=datetime.now().isoformat(timespec="seconds"), fim=None)
        self._thread = threading.Thread(target=self._rodar, args=(fila, modo_teste, usuario), daemon=True,
                                        name="robo-ts")
        self._thread.start()
        return self.estado()

    def _rodar(self, fila: list[int], modo_teste: bool, usuario: str) -> None:
        from .fluxos import FLUXOS, abrir_smanutos, abrir_ts, login, pesquisar_os, voltar_inicio
        from .jab import TS, ErroTS

        ts = None
        try:
            self._log("Abrindo o TS do robô")
            ts = TS(pid=abrir_ts())
            self._log("Login")
            login(ts)
            self._log("Abrindo SMANUTOS")
            abrir_smanutos(ts)
            for cid in fila:
                if self._parar.is_set():
                    self._log("Parado pelo usuário")
                    break
                with db.sessao() as s:
                    c = s.get(Correcao, cid)
                    item = s.get(OSFila, c.os_fila_id)
                    if c.status != "aprovada":
                        continue
                    justificativa = (item.justificativa_ts or "").strip()
                    if not justificativa and not modo_teste:
                        # o TS exige a justificativa: sem o texto padrão escolhido na OS, não mexe
                        c.resultado_robo = "Aguardando a justificativa do TS (escolha o texto padrão na OS)."
                        s.commit()
                        self._log(f"OS {item.os}: sem justificativa escolhida, correção {cid} não executada")
                        continue
                    if not modo_teste:
                        c.status, c.tentativas = "em_execucao", c.tentativas + 1
                        s.commit()
                self._estado["atual"] = {"correcao": cid, "os": item.os, "tipo": c.tipo}
                resultado, status_final = "", None
                try:
                    self._log(f"OS {item.os}: pesquisando")
                    cab = pesquisar_os(ts, item.os)
                    self._log(f"OS {item.os}: carregada (origem {cab['data_origem']})")
                    if not justificativa:
                        self._log(f"OS {item.os}: [teste] sem justificativa escolhida; na execução real não seria feita")
                    resultado = FLUXOS[c.tipo](ts, c, modo_teste, justificativa)
                    status_final = "executada"
                except ErroTS as e:
                    resultado = str(e)
                    status_final = "erro"
                    self._estado["erros"] += 1
                    self._log(f"OS {item.os}: {e}")
                finally:
                    try:
                        voltar_inicio(ts)
                    except ErroTS:
                        pass
                with db.sessao() as s:
                    c = s.get(Correcao, cid)
                    prefixo = "[teste] " if modo_teste else ""
                    c.resultado_robo = f"{prefixo}{resultado}"[:2000]
                    if not modo_teste:
                        if status_final == "erro" and c.tentativas < MAX_TENTATIVAS:
                            c.status = "aprovada"  # volta para a fila; nova tentativa na próxima rodada
                        else:
                            c.status = status_final
                        if status_final == "executada":
                            c.executado_em = agora()
                            servicos.atualizar_os(c.os_fila_id, usuario, status="corrigida")
                    servicos.auditar(s, usuario, "robo_ts", str(cid), modo_teste=modo_teste, resultado=c.resultado_robo)
                    s.commit()
                self._estado["feitas"] += 1
                time.sleep(0.5)
        except Exception as e:  # noqa: BLE001
            self._log(f"Robô interrompido: {type(e).__name__}: {e}")
        finally:
            self._estado.update(rodando=False, atual=None, fim=datetime.now().isoformat(timespec="seconds"))


ROBO = Robo()
