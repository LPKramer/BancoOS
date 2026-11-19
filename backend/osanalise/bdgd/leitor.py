"""Leitura da BDGD em shapefile (DBF + SHP) sem dependências externas, e utilidades geográficas.

Adaptado de "Visualizador OS aberta/gerar_visualizador.py" (iter_dbf, Shp, encode_lines).
"""
from __future__ import annotations

import math
import struct
from collections import defaultdict
from pathlib import Path


def campos_dbf(caminho: str | Path) -> list[str]:
    with open(caminho, "rb") as f:
        f.read(32)
        nomes = []
        while True:
            d = f.read(32)
            if d[0] == 0x0D:
                break
            nomes.append(d[:11].split(b"\0")[0].decode("latin1"))
    return nomes


def iter_dbf(caminho: str | Path, colunas: list[str] | None = None):
    """Gera (índice do registro, dict) — o índice é o mesmo da geometria no .shp."""
    with open(caminho, "rb") as f:
        h = f.read(32)
        nrec, hlen, rlen = struct.unpack("<IHH", h[4:12])
        campos, pos = [], 1
        while True:
            d = f.read(32)
            if d[0] == 0x0D:
                break
            campos.append((d[:11].split(b"\0")[0].decode("latin1"), pos, d[16]))
            pos += d[16]
        sel = [c for c in campos if colunas is None or c[0] in colunas]
        f.seek(hlen)
        idx, faltam = 0, nrec
        while faltam > 0:
            k = min(20000, faltam)
            buf = f.read(rlen * k)
            faltam -= k
            for i in range(k):
                r = buf[i * rlen:(i + 1) * rlen]
                if r[:1] != b"*":
                    yield idx, {n: r[p:p + l].replace(b"\x00", b"").decode("latin1").strip() for n, p, l in sel}
                idx += 1


class Shp:
    """Acesso aleatório às geometrias de um shapefile pelo índice do registro."""

    def __init__(self, base: str | Path):
        base = str(base)
        self.f = open(base + ".shp", "rb")
        shx = open(base + ".shx", "rb").read()
        n = (len(shx) - 100) // 8
        self.off = struct.unpack(">" + "ii" * n, shx[100:100 + 8 * n])[0::2]

    def ponto(self, i: int) -> tuple[float, float] | None:
        """(lat, lon)"""
        self.f.seek(self.off[i] * 2 + 8)
        t, x, y = struct.unpack("<idd", self.f.read(20))
        return None if t == 0 else (y, x)

    def linha(self, i: int) -> list[tuple[float, float]] | None:
        self.f.seek(self.off[i] * 2 + 8)
        hdr = self.f.read(44)
        if struct.unpack("<i", hdr[:4])[0] == 0:
            return None
        nparts, npts = struct.unpack("<ii", hdr[36:44])
        self.f.read(4 * nparts)
        pts = struct.unpack("<" + "d" * 2 * npts, self.f.read(16 * npts))
        return [(pts[j + 1], pts[j]) for j in range(0, 2 * npts, 2)]

    def todos_pontos(self) -> list[tuple[float, float] | None]:
        """Lê todos os pontos de uma vez (mais rápido que um seek por registro)."""
        self.f.seek(0)
        buf = self.f.read()
        saida = []
        for o in self.off:
            p = o * 2 + 8
            t = struct.unpack_from("<i", buf, p)[0]
            if t == 0:
                saida.append(None)
            else:
                x, y = struct.unpack_from("<dd", buf, p + 4)
                saida.append((y, x))
        return saida

    def fechar(self):
        self.f.close()


def codificar_linhas(linhas: list[list[tuple[float, float]]]) -> list[list[int]]:
    """Junta segmentos em polilinhas e codifica como [lat0, lon0, dlat1, dlon1, ...] em 1e-5 grau."""
    k = lambda p: (round(p[0] * 1e5), round(p[1] * 1e5))  # noqa: E731
    arestas, pontas = [], defaultdict(list)
    for ln in linhas:
        pts = []
        for p in ln:
            q = k(p)
            if not pts or pts[-1] != q:
                pts.append(q)
        if len(pts) < 2:
            continue
        pontas[pts[0]].append(len(arestas))
        pontas[pts[-1]].append(len(arestas))
        arestas.append(pts)
    usada = [False] * len(arestas)

    def andar(cadeia):
        while True:
            fim = cadeia[-1]
            if len(pontas[fim]) != 2:
                return cadeia
            prox = [e for e in pontas[fim] if not usada[e]]
            if not prox:
                return cadeia
            usada[prox[0]] = True
            pts = arestas[prox[0]]
            cadeia.extend(pts[1:] if pts[0] == fim else pts[-2::-1])

    saida = []
    for i, pts in enumerate(arestas):
        if usada[i]:
            continue
        usada[i] = True
        cadeia = andar(list(pts))
        cadeia.reverse()
        cadeia = andar(cadeia)
        plano = [cadeia[0][0], cadeia[0][1]]
        for a, b in zip(cadeia, cadeia[1:]):
            plano += [b[0] - a[0], b[1] - a[1]]
        saida.append(plano)
    return saida


def utm_para_latlon(x: float, y: float, zona: int = 22, sul: bool = True) -> tuple[float, float]:
    """UTM (SIRGAS 2000 ≈ WGS84) para (lat, lon). As coordenadas da ETO usam o fuso 22S."""
    a, f = 6378137.0, 1 / 298.257222101
    e2 = f * (2 - f)
    ep2 = e2 / (1 - e2)
    k0 = 0.9996
    x -= 500000.0
    if sul:
        y -= 10000000.0
    m = y / k0
    mu = m / (a * (1 - e2 / 4 - 3 * e2 ** 2 / 64 - 5 * e2 ** 3 / 256))
    e1 = (1 - math.sqrt(1 - e2)) / (1 + math.sqrt(1 - e2))
    fi1 = (mu + (3 * e1 / 2 - 27 * e1 ** 3 / 32) * math.sin(2 * mu)
           + (21 * e1 ** 2 / 16 - 55 * e1 ** 4 / 32) * math.sin(4 * mu)
           + (151 * e1 ** 3 / 96) * math.sin(6 * mu) + (1097 * e1 ** 4 / 512) * math.sin(8 * mu))
    c1 = ep2 * math.cos(fi1) ** 2
    t1 = math.tan(fi1) ** 2
    n1 = a / math.sqrt(1 - e2 * math.sin(fi1) ** 2)
    r1 = a * (1 - e2) / (1 - e2 * math.sin(fi1) ** 2) ** 1.5
    d = x / (n1 * k0)
    lat = fi1 - (n1 * math.tan(fi1) / r1) * (
        d ** 2 / 2 - (5 + 3 * t1 + 10 * c1 - 4 * c1 ** 2 - 9 * ep2) * d ** 4 / 24
        + (61 + 90 * t1 + 298 * c1 + 45 * t1 ** 2 - 252 * ep2 - 3 * c1 ** 2) * d ** 6 / 720)
    lon = (d - (1 + 2 * t1 + c1) * d ** 3 / 6
           + (5 - 2 * c1 + 28 * t1 - 3 * c1 ** 2 + 8 * ep2 + 24 * t1 ** 2) * d ** 5 / 120) / math.cos(fi1)
    meridiano = math.radians(zona * 6 - 183)
    return math.degrees(lat), math.degrees(lon + meridiano)


def distancia_m(a: tuple[float, float], b: tuple[float, float]) -> float:
    """Distância aproximada em metros entre (lat, lon)."""
    dlat = math.radians(b[0] - a[0])
    dlon = math.radians(b[1] - a[1]) * math.cos(math.radians((a[0] + b[0]) / 2))
    return 6371000.0 * math.hypot(dlat, dlon)
