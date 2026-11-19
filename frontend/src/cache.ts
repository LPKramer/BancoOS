import { api } from "./api";
import type { DetalheOS, Manobra } from "./tipos";

/** Cache em memória do detalhe e da manobra, para abrir a próxima OS sem espera. */
const detalhes = new Map<number, Promise<DetalheOS>>();
const manobras = new Map<number, Promise<Manobra>>();
const LIMITE = 40;

function guardar<T>(mapa: Map<number, Promise<T>>, id: number, p: Promise<T>): Promise<T> {
  mapa.set(id, p);
  p.catch(() => mapa.delete(id)); // erro não fica no cache
  if (mapa.size > LIMITE) mapa.delete(mapa.keys().next().value as number);
  return p;
}

export function buscarDetalhe(id: number, forcar = false): Promise<DetalheOS> {
  if (!forcar && detalhes.has(id)) return detalhes.get(id)!;
  return guardar(detalhes, id, api.get<DetalheOS>(`/api/os/${id}`));
}

export function buscarManobra(id: number, forcar = false): Promise<Manobra> {
  if (!forcar && manobras.has(id)) return manobras.get(id)!;
  return guardar(manobras, id, api.get<Manobra>(`/api/os/${id}/manobra`));
}

export function preCarregar(id: number | null | undefined, comManobra: boolean) {
  if (!id) return;
  buscarDetalhe(id).catch(() => {});
  if (comManobra) buscarManobra(id).catch(() => {});
}

export function esquecerDetalhe(id: number) {
  detalhes.delete(id);
}
