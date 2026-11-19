import L from "leaflet";
import "leaflet/dist/leaflet.css";
import { useEffect, useRef, useState } from "react";
import { int } from "../formatos";
import type { Manobra, PassoManobra } from "../tipos";

export const COR = {
  rede: "#64748b",
  desligada: "#ef4444",
  area: "#f59e0b",
  trafo: "#94a3b8",
  vinculada: "#a78bfa",
  fora: "#f87171",
  candidata: "#fb923c",
  operada: "#fde047",
  na: "#f59e0b",
  fusivel: "#e2e8f0",
  religador: "#38bdf8",
  disjuntor: "#4ade80",
};
const COR_CHAVE: Record<string, string> = { "Chave fusível": COR.fusivel, Religador: COR.religador, Disjuntor: COR.disjuntor };
const CHAVE_FUNDO = "osa.mapaFundo";

function decodificar(plano: number[]): L.LatLngTuple[] {
  let la = plano[0];
  let lo = plano[1];
  const pts: L.LatLngTuple[] = [[la / 1e5, lo / 1e5]];
  for (let i = 2; i < plano.length; i += 2) {
    la += plano[i];
    lo += plano[i + 1];
    pts.push([la / 1e5, lo / 1e5]);
  }
  return pts;
}

export default function Mapa({
  dados,
  passo,
  destaqueOS,
  className = "h-[520px]",
}: {
  dados: Manobra;
  passo: PassoManobra | null;
  destaqueOS: string | null;
  className?: string;
}) {
  const div = useRef<HTMLDivElement>(null);
  const mapa = useRef<L.Map | null>(null);
  const secoes = useRef(new Map<number, L.Polyline>());
  const trafos = useRef(new Map<number, L.CircleMarker>());
  const chaves = useRef(new Map<string, L.CircleMarker>());
  const pontosOS = useRef(new Map<string, L.CircleMarker>());
  const fundo = useRef<L.TileLayer | null>(null);
  const [comFundo, setComFundo] = useState(() => {
    try {
      return localStorage.getItem(CHAVE_FUNDO) === "1";
    } catch {
      return false;
    }
  });

  useEffect(() => {
    if (!div.current) return;
    const m = L.map(div.current, { preferCanvas: true, zoomControl: true, attributionControl: true });
    m.setView([-10.2, -48.3], 8); // o Leaflet precisa de uma vista antes de receber camadas
    m.attributionControl.setPrefix(false);
    mapa.current = m;
    const limites = L.latLngBounds([]);
    const grupoRede = L.layerGroup().addTo(m);
    for (const [id, partes] of Object.entries(dados.secoes)) {
      const linhas = partes.map(decodificar);
      const pl = L.polyline(linhas, { color: COR.rede, weight: 1.5, opacity: 0.9, interactive: false }).addTo(grupoRede);
      secoes.current.set(Number(id), pl);
      linhas.forEach((l) => l.forEach((pt) => limites.extend(pt)));
    }
    // sempre visíveis: o que importa para a manobra; o restante aparece ao aproximar
    const trafosImportantes = new Set<number>([...dados.trafos_area, ...dados.passos.flatMap((p) => p.trafos_off)]);
    const chavesImportantes = new Set<string>(Object.values(dados.candidatos).map((c) => c.cod_id));
    const grupoTr = L.layerGroup().addTo(m);
    const grupoTrDetalhe = L.layerGroup();
    for (const t of dados.trafos) {
      const importante = t.vinc > 0 || trafosImportantes.has(t.i);
      const cm = L.circleMarker([t.lat, t.lon], { radius: t.vinc ? 5 : 2.5, color: t.vinc ? COR.vinculada : COR.trafo, weight: t.vinc ? 2 : 1, fillColor: COR.trafo, fillOpacity: 0.9 })
        .bindTooltip(`Trafo ${t.ts ?? "?"} · BDGD ${t.cod_id}<br>${int(t.ucs)} UCs${t.kva ? ` · ${t.kva} kVA` : ""}${t.vinc ? `<br>${t.vinc} OS vinculada(s)` : ""}`)
        .addTo(importante ? grupoTr : grupoTrDetalhe);
      trafos.current.set(t.i, cm);
    }
    const grupoCh = L.layerGroup().addTo(m);
    const grupoChDetalhe = L.layerGroup();
    for (const c of dados.chaves) {
      const operada = c.passos.length > 0;
      const importante = operada || c.normal === "A" || chavesImportantes.has(c.cod_id);
      const cm = L.circleMarker([c.lat, c.lon], {
        radius: operada ? 6 : 3.5,
        color: operada ? COR.operada : c.normal === "A" ? COR.na : (COR_CHAVE[c.tipo] ?? "#cbd5e1"),
        weight: operada ? 2.5 : 1.5,
        fillColor: COR_CHAVE[c.tipo] ?? "#cbd5e1",
        fillOpacity: c.normal === "A" ? 0 : 0.9,
      })
        .bindTooltip(`${c.tipo} ${c.cod_id}${c.elo ? ` · elo ${c.elo}` : ""}<br>${c.normal === "A" ? "normalmente aberta" : "normalmente fechada"}${operada ? `<br>operada nos passos ${c.passos.map((p) => p + 1).join(", ")}` : ""}`)
        .addTo(importante ? grupoCh : grupoChDetalhe);
      chaves.current.set(c.cod_id, cm);
    }
    const grupoOS = L.layerGroup().addTo(m);
    for (const v of dados.vinculadas) {
      if (v.lat == null || v.lon == null) continue;
      const cm = L.circleMarker([v.lat, v.lon], { radius: 4, color: v.na_area === false ? COR.fora : COR.vinculada, weight: v.na_area === false ? 2.5 : 1, fillColor: COR.vinculada, fillOpacity: 0.85 })
        .bindTooltip(`OS vinculada ${v.os}<br>reclamação ${v.recl ?? "—"}${v.na_area === false ? "<br>fora da área desligada" : ""}`)
        .addTo(grupoOS);
      pontosOS.current.set(v.os, cm);
      limites.extend([v.lat, v.lon]);
    }
    for (const c of dados.candidatas) {
      if (c.lat == null || c.lon == null) continue;
      const cm = L.circleMarker([c.lat, c.lon], { radius: 5, color: COR.candidata, weight: 2, fillColor: COR.candidata, fillOpacity: 0.35 })
        .bindTooltip(`OS ${c.os} sem vínculo<br>reclamação ${c.recl ?? "—"} · trafo ${c.trafo_ts ?? "?"}`)
        .addTo(grupoOS);
      pontosOS.current.set(c.os, cm);
    }
    if (dados.ocorrencia) {
      L.circleMarker([dados.ocorrencia.lat, dados.ocorrencia.lon], { radius: 10, color: "#ffffff", weight: 2, dashArray: "4 3", fill: false })
        .bindTooltip("Coordenada do elemento na compensação")
        .addTo(m);
    }
    const detalhe = () => {
      const z = m.getZoom();
      if (z >= 15) grupoTrDetalhe.addTo(m);
      else grupoTrDetalhe.remove();
      if (z >= 14) grupoChDetalhe.addTo(m);
      else grupoChDetalhe.remove();
    };
    m.on("zoomend", detalhe);
    if (limites.isValid()) m.fitBounds(limites.pad(0.05));
    detalhe();
    // o contêiner pode mudar de tamanho com o layout (colunas): reajusta o mapa
    const obs = new ResizeObserver(() => m.invalidateSize());
    obs.observe(div.current);
    return () => {
      obs.disconnect();
      m.remove();
      mapa.current = null;
      secoes.current.clear();
      trafos.current.clear();
      chaves.current.clear();
      pontosOS.current.clear();
      fundo.current = null;
    };
  }, [dados]);

  useEffect(() => {
    const m = mapa.current;
    if (!m) return;
    if (comFundo && !fundo.current) {
      fundo.current = L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", { maxZoom: 19, opacity: 0.35, attribution: "© OpenStreetMap" }).addTo(m);
      fundo.current.bringToBack();
    } else if (!comFundo && fundo.current) {
      fundo.current.remove();
      fundo.current = null;
    }
    try {
      localStorage.setItem(CHAVE_FUNDO, comFundo ? "1" : "0");
    } catch {
      /* sem armazenamento */
    }
  }, [comFundo, dados]);

  // estado da rede no passo escolhido
  useEffect(() => {
    const off = new Set(passo ? passo.secoes_off : []);
    const area = new Set(passo ? [] : dados.secoes_area);
    secoes.current.forEach((pl, id) => {
      if (off.has(id)) pl.setStyle({ color: COR.desligada, weight: 3 });
      else if (area.has(id)) pl.setStyle({ color: COR.area, weight: 2.5 });
      else pl.setStyle({ color: COR.rede, weight: 1.5 });
    });
    const trOff = new Set(passo ? passo.trafos_off : dados.trafos_area);
    trafos.current.forEach((cm, i) => cm.setStyle({ fillColor: trOff.has(i) ? COR.desligada : COR.trafo }));
    chaves.current.forEach((cm, cod) => {
      const alvo = passo && passo.cod_bdgd === cod;
      cm.setStyle({ weight: alvo ? 4 : cm.options.radius && cm.options.radius > 5 ? 2.5 : 1.5 });
      if (alvo) {
        cm.bringToFront();
        mapa.current?.panTo(cm.getLatLng(), { animate: false });
      }
    });
  }, [passo, dados]);

  // OS escolhida na linha do tempo
  useEffect(() => {
    pontosOS.current.forEach((cm, os) => {
      const alvo = os === destaqueOS;
      cm.setRadius(alvo ? 9 : cm.options.color === COR.candidata ? 5 : 4);
      if (alvo) {
        cm.bringToFront();
        mapa.current?.panTo(cm.getLatLng(), { animate: false });
      }
    });
  }, [destaqueOS, dados]);

  return (
    <div className="flex h-full flex-col gap-1.5">
      <div ref={div} className={`w-full rounded-md border border-borda ${className}`} role="img" aria-label="Mapa da rede de média tensão e da manobra" />
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-texto-suave">
        <Legenda cor={COR.desligada} texto="desligada no passo" linha />
        <Legenda cor={COR.area} texto="área provável" linha />
        <Legenda cor={COR.operada} texto="chave operada" />
        <Legenda cor={COR.na} texto="chave NA" vazado />
        <Legenda cor={COR.vinculada} texto="OS vinculada" />
        <Legenda cor={COR.fora} texto="fora da área" vazado />
        <Legenda cor={COR.candidata} texto="OS sem vínculo" vazado />
        <label className="ml-auto flex items-center gap-1.5">
          <input type="checkbox" checked={comFundo} onChange={(e) => setComFundo(e.target.checked)} />
          Mapa de fundo
        </label>
      </div>
    </div>
  );
}

function Legenda({ cor, texto, linha, vazado }: { cor: string; texto: string; linha?: boolean; vazado?: boolean }) {
  return (
    <span className="flex items-center gap-1.5">
      <span aria-hidden className={linha ? "h-0.5 w-4" : "h-2.5 w-2.5 rounded-full"} style={vazado ? { border: `2px solid ${cor}` } : { background: cor }} />
      {texto}
    </span>
  );
}
