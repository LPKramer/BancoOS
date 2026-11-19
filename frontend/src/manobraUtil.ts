import type { PassoManobra } from "./tipos";

/** Clientes que o elemento isola (abrir) ou religa (fechar) pela BDGD, comparável ao registrado no TS. */
export function calculado(p: PassoManobra): number | null {
  if (p.ucs_elemento != null) return p.ucs_elemento;
  if (p.variacao == null) return null;
  return p.efeito === "abre" ? p.variacao : -p.variacao;
}

/** Diferença relevante entre o registrado no passo e o calculado na BDGD. */
export function diverge(p: PassoManobra): boolean {
  const c = calculado(p);
  if (p.qtd_registrada == null || c == null) return false;
  const dif = Math.abs(p.qtd_registrada - c);
  return dif > Math.max(5, 0.2 * Math.max(p.qtd_registrada, Math.abs(c)));
}

/** "dd/mm/aaaa hh:mm" -> "dd/mm hh:mm" */
export function curta(v: string | null | undefined): string {
  if (!v) return "—";
  const m = v.match(/^(\d{2}\/\d{2})\/\d{4} (\d{2}:\d{2})/);
  return m ? `${m[1]} ${m[2]}` : v;
}

export function paraData(v: unknown): number {
  if (typeof v !== "string") return NaN;
  const m = v.match(/^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/);
  return m ? new Date(+m[3], +m[2] - 1, +m[1], +m[4], +m[5]).getTime() : NaN;
}
