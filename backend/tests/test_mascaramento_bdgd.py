from __future__ import annotations

import sqlite3

from osanalise.bdgd.leitor import codificar_linhas, distancia_m, utm_para_latlon
from osanalise.bdgd.rede import Rede
from osanalise.llm.mascaramento import mascarar


def test_mascara_telefone_uc_cpf_e_mantem_codigos_tecnicos():
    # valores fictícios
    t = mascarar("63912345678 FALTA DE ENERGIA UC: 40700000001; fone (63) 3300-1234 religador 7905501059 "
                 "OS 20265064416221 cpf 123.456.789-09 email a.b@x.com")
    assert "63912345678" not in t and "40700000001" not in t and "3300-1234" not in t
    assert "123.456.789-09" not in t and "a.b@x.com" not in t
    assert "7905501059" in t and "20265064416221" in t


def test_utm_22s():
    lat, lon = utm_para_latlon(792976.550, 8873186.360)
    assert distancia_m((lat, lon), (-10.182627, -48.326156)) < 1.0


def test_codificar_linhas_junta_segmentos():
    linhas = [[(-10.0, -48.0), (-10.0001, -48.0)], [(-10.0001, -48.0), (-10.0002, -48.0001)]]
    cod = codificar_linhas(linhas)
    assert len(cod) == 1 and len(cod[0]) == 6


def _rede_minima() -> Rede:
    """Fonte S -- seg -- A --[chave C1 fechada]-- B -- seg -- T(trafo 10 UCs);  A --[chave NA]-- X (outro alimentador)."""
    con = sqlite3.connect(":memory:")
    con.row_factory = sqlite3.Row
    from osanalise.bdgd.indice import ESQUEMA

    con.executescript(ESQUEMA)
    con.execute("INSERT INTO ctmt VALUES ('1','AL1','S','SE','13')")
    con.execute("INSERT INTO ctmt VALUES ('2','AL2','Y','SE','13')")
    con.executemany("INSERT INTO seg VALUES (?,?,?,?)", [(0, "1", "S", "A"), (1, "1", "B", "T"), (2, "2", "Y", "X")])
    con.executemany("INSERT INTO chave VALUES (?,?,?,?,?,?,?,?,?,?,?)", [
        (0, "C1", "A", "B", "22", "F", "1H", "1", None, -10.0, -48.0),
        (1, "NA1", "A", "X", "19", "A", "", "1", "2", -10.0, -48.1),
    ])
    con.execute("INSERT INTO trafo VALUES (0,'TR1','T','1',15.0,-10.0,-48.0,10)")
    return Rede.carregar(con, ["1"])


def test_rede_estado_normal_e_abertura():
    r = _rede_minima()
    nos = r.energizados({})
    assert {"S", "A", "B", "T"} <= nos  # X é o lado do outro alimentador (fonte externa, sempre energizada)
    assert r.trafos_energizados(nos) == {0}
    aberto = r.energizados({"C1": False})
    assert "T" not in aberto and r.trafos_energizados(aberto) == set()
    # disjuntor da saída aberto: nada energizado
    assert r.trafos_energizados(r.energizados({}, {"1"})) == set()


def test_rede_transferencia_pela_na():
    r = _rede_minima()
    # saída desligada, mas fechando a NA o outro alimentador (fonte externa X) alimenta a carga
    nos = r.energizados({"NA1": True}, {"1"})
    assert r.trafos_energizados(nos) == {0}
