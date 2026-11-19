import { useEffect, useMemo, useRef } from "react";
import { int } from "../formatos";
import { calculado, curta, diverge, paraData } from "../manobraUtil";
import type { DetalheOS, Manobra, PassoManobra, Registro } from "../tipos";
import { Etiqueta } from "./ui";

type Evento =
  | { tipo: "os"; t: number; data: string; rotulo: string; fim: boolean }
  | { tipo: "passo"; t: number; data: string; passo: PassoManobra | null; bruto: Registro }
  | { tipo: "reclamacao"; t: number; data: string; v: Registro; naArea: boolean | null }
  | { tipo: "sem_vinculo"; t: number; data: string; c: Manobra["candidatas"][number] };

const MARCOS_OS: [string, string][] = [
  ["DTA_INIC_MNB", "Início da intervenção"],
  ["DTA_AVI_EQP_MNB", "Aviso à equipe"],
  ["DTA_DLCT_EQP_MNB", "Deslocamento"],
  ["DTA_VERI_EQP_MNB", "Verificação"],
  ["DTA_SERV_EQP_MNB", "Serviço"],
  ["DTA_FIM_MNB", "Fim da intervenção"],
];
const ORDEM_TIPO = { os: 0, passo: 1, reclamacao: 2, sem_vinculo: 3 };

export default function LinhaDoTempo({
  detalhe,
  manobra,
  ordemPasso,
  destaqueOS,
  aoPasso,
  aoOS,
}: {
  detalhe: DetalheOS;
  manobra: Manobra | null;
  ordemPasso: number | null;
  destaqueOS: string | null;
  aoPasso: (ordem: number | null) => void;
  aoOS: (os: string | null) => void;
}) {
  const eventos = useMemo(() => {
    const ev: Evento[] = [];
    for (const [campo, rotulo] of MARCOS_OS) {
      const v = detalhe.registro[campo];
      if (typeof v === "string") ev.push({ tipo: "os", t: paraData(v), data: v, rotulo, fim: campo === "DTA_FIM_MNB" });
    }
    if (manobra?.disponivel) {
      for (const p of manobra.passos) ev.push({ tipo: "passo", t: paraData(p.data), data: p.data ?? "", passo: p, bruto: {} });
    } else {
      for (const p of detalhe.passos) {
        const d = String(p.DTA_PASSO_PNB ?? "");
        ev.push({ tipo: "passo", t: paraData(d), data: d, passo: null, bruto: p });
      }
    }
    const naArea = new Map(manobra?.disponivel ? manobra.vinculadas.map((v) => [v.os, v.na_area]) : []);
    for (const v of detalhe.vinculadas) {
      const d = String(v.DTA_RECL_CNR ?? "");
      ev.push({ tipo: "reclamacao", t: paraData(d), data: d, v, naArea: naArea.get(String(v.NUM_SEQ_OPER_CNR)) ?? null });
    }
    for (const c of manobra?.disponivel ? manobra.candidatas : []) {
      ev.push({ tipo: "sem_vinculo", t: paraData(c.recl), data: c.recl ?? "", c });
    }
    const tempo = (e: Evento) => (Number.isNaN(e.t) ? Number.POSITIVE_INFINITY : e.t); // sem data vai para o fim
    const ordem = (e: Evento) => (e.tipo === "os" && e.fim ? 9 : ORDEM_TIPO[e.tipo]); // o fim vem depois dos passos do mesmo minuto
    return ev.sort((a, b) => tempo(a) - tempo(b) || ordem(a) - ordem(b) || seq(a) - seq(b));
  }, [detalhe, manobra]);

  // a linha escolhida no mapa ou nos achados fica visível (rola só esta caixa, não a página)
  const caixa = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const c = caixa.current;
    const linha = c?.querySelector<HTMLTableRowElement>('tr[data-sel="1"]');
    if (!c || !linha) return;
    const rc = c.getBoundingClientRect();
    const rl = linha.getBoundingClientRect();
    const cab = c.querySelector("thead")?.getBoundingClientRect().height ?? 0;
    if (rl.top < rc.top + cab) c.scrollTop -= rc.top + cab - rl.top;
    else if (rl.bottom > rc.bottom) c.scrollTop += rl.bottom - rc.bottom;
  }, [ordemPasso, destaqueOS, eventos]);

  return (
    <div ref={caixa} className="min-h-0 flex-1 overflow-auto">
      <table className="w-full table-fixed text-sm">
        <colgroup>
          <col className="w-[96px]" />
          <col />
          <col className="w-[60px]" />
          <col className="w-[104px]" />
          <col className="w-[84px]" />
        </colgroup>
        <thead className="sticky top-0 z-[1] bg-cartao">
          <tr className="border-b border-borda text-left text-xs text-texto-suave">
            <th className="px-2 py-1.5 font-medium">Data</th>
            <th className="px-2 py-1.5 font-medium">Evento</th>
            <th className="px-2 py-1.5 text-right font-medium" title="Clientes registrados no passo do TS">
              TS
            </th>
            <th
              className="px-2 py-1.5 text-right font-medium"
              title="UCs ativas da BDGD que o elemento isola (abrir) ou religa (fechar) na configuração do momento"
            >
              BDGD
            </th>
            <th className="px-2 py-1.5 text-right font-medium" title="UCs sem energia depois do passo (simulação)">
              Sem energia
            </th>
          </tr>
        </thead>
        <tbody>
          {eventos.map((e, i) => (
            <Linha key={i} e={e} ordemPasso={ordemPasso} destaqueOS={destaqueOS} aoPasso={aoPasso} aoOS={aoOS} />
          ))}
        </tbody>
      </table>
    </div>
  );
}

function seq(e: Evento): number {
  if (e.tipo !== "passo") return 0;
  return Number(e.passo?.seq ?? e.bruto.NUM_SEQ_PNB ?? 0);
}

function Linha({
  e,
  ordemPasso,
  destaqueOS,
  aoPasso,
  aoOS,
}: {
  e: Evento;
  ordemPasso: number | null;
  destaqueOS: string | null;
  aoPasso: (o: number | null) => void;
  aoOS: (os: string | null) => void;
}) {
  const data = <td className="num whitespace-nowrap px-2 py-1 text-texto-suave">{curta(e.data)}</td>;
  if (e.tipo === "os") {
    return (
      <tr className="border-b border-borda/40 bg-suave/40">
        {data}
        <td className="px-2 py-1 text-texto-suave" colSpan={4}>
          {e.rotulo}
        </td>
      </tr>
    );
  }
  if (e.tipo === "passo") {
    const p = e.passo;
    const oper = p ? p.oper : String(e.bruto.COD_OPER_PNB ?? "");
    const cancelado = p ? p.efeito === "cancelado" : String(e.bruto.STA_EXEC_PNB ?? "").toUpperCase() === "PASSO CANCELADO";
    const clicavel = p && (p.efeito === "abre" || p.efeito === "fecha");
    const sel = p && p.ordem === ordemPasso;
    const calc = p ? calculado(p) : null;
    const registrado = p ? p.qtd_registrada : (e.bruto.QTD_UN_CONS_PNB as number | null);
    return (
      <tr
        data-sel={sel ? "1" : undefined}
        onClick={() => clicavel && aoPasso(sel ? null : p!.ordem)}
        className={`border-b border-borda/40 ${clicavel ? "cursor-pointer hover:bg-suave" : ""} ${sel ? "bg-secundaria" : ""} ${cancelado ? "text-texto-suave line-through" : ""}`}
      >
        {data}
        <td className="truncate px-2 py-1">
          <span className="font-medium">{oper || "—"}</span>{" "}
          <span className="num text-texto-suave">
            {p ? `${p.elemento ?? ""} ${p.cod_ts}` : `${e.bruto.COD_ELE_PNB ?? ""} ${e.bruto.COD_INS_SEC_INS ?? ""}`}
          </span>
          {p?.efeito === "nao_localizado" && <span className="ml-1 text-xs text-texto-suave">sem equivalência na BDGD</span>}
        </td>
        <td className="num px-2 py-1 text-right">{registrado != null ? int(Number(registrado)) : "—"}</td>
        <td className="num px-2 py-1 text-right">
          {calc != null ? int(calc) : "—"}
          {p && diverge(p) && (
            <span className="ml-1">
              <Etiqueta cor="ambar" titulo="Diferença relevante entre o TS e a BDGD">
                difere
              </Etiqueta>
            </span>
          )}
        </td>
        <td className="num px-2 py-1 text-right">{p?.ucs_desligadas != null ? int(p.ucs_desligadas) : "—"}</td>
      </tr>
    );
  }
  if (e.tipo === "reclamacao") {
    const os = String(e.v.NUM_SEQ_OPER_CNR ?? "");
    const sel = os === destaqueOS;
    return (
      <tr data-sel={sel ? "1" : undefined} onClick={() => aoOS(sel ? null : os)} className={`cursor-pointer border-b border-borda/40 hover:bg-suave ${sel ? "bg-secundaria" : ""}`}>
        {data}
        <td className="truncate px-2 py-1" colSpan={4}>
          <span className="text-[#c4b5fd]">Reclamação</span> <span className="num">{os}</span>{" "}
          <span className="text-texto-suave">
            {[e.v.COD_TIPO_OS_CNR, e.v.COD_SUB_TIPO_OS_CNR].filter(Boolean).join("/")} · fim {curta(e.v.DTA_FIM_CNR as string | null)}
          </span>
          {e.naArea === false && (
            <span className="ml-1">
              <Etiqueta cor="vermelho" titulo="O trafo desta OS não ficou sem energia na simulação">
                fora da área
              </Etiqueta>
            </span>
          )}
          {e.v.DES_OBS_EXEC_SERV_CNR && <div className="truncate text-xs text-texto-suave">{String(e.v.DES_OBS_EXEC_SERV_CNR)}</div>}
        </td>
      </tr>
    );
  }
  const sel = e.c.os === destaqueOS;
  return (
    <tr data-sel={sel ? "1" : undefined} onClick={() => aoOS(sel ? null : e.c.os)} className={`cursor-pointer border-b border-borda/40 hover:bg-suave ${sel ? "bg-secundaria" : ""}`}>
      {data}
      <td className="truncate px-2 py-1" colSpan={4}>
        <span className="text-[#fdba74]">Reclamação sem vínculo</span> <span className="num">{e.c.os}</span>{" "}
        <span className="text-texto-suave">
          {e.c.tipo} · trafo {e.c.trafo_ts} · {e.c.causa}
        </span>
      </td>
    </tr>
  );
}
