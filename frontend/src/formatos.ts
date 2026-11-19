const moeda = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });
const inteiro = new Intl.NumberFormat("pt-BR");
const decimal = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 4 });

export const rs = (v: number | null | undefined) => (v == null ? "—" : moeda.format(v));
export const int = (v: number | null | undefined) => (v == null ? "—" : inteiro.format(v));
export const dec = (v: number | null | undefined) => (v == null ? "—" : decimal.format(v));
export const pct = (v: number | null | undefined) => (v == null ? "—" : `${Math.round(v * 100)}%`);

export function dataHora(v: string | null | undefined): string {
  if (!v) return "—";
  if (/^\d{2}\/\d{2}\/\d{4}/.test(v)) return v;
  const d = new Date(v);
  return Number.isNaN(d.getTime())
    ? v
    : d.toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" });
}

export function valor(v: string | number | null | undefined): string {
  if (v == null || v === "") return "—";
  if (typeof v === "number") return Number.isInteger(v) ? inteiro.format(v) : decimal.format(v);
  return v;
}

export const NOMES_STATUS: Record<string, string> = {
  pendente: "Pendente",
  em_analise: "Em análise",
  correta: "Correta",
  errada: "Errada",
  corrigida: "Corrigida",
  ignorada: "Ignorada",
};

export const NOMES_VEREDITO: Record<string, string> = {
  errada: "Errada",
  correta: "Correta",
  duvidosa: "Duvidosa",
  sem_analise: "Sem análise",
};

export const NOMES_CORRECAO_STATUS: Record<string, string> = {
  proposta: "Proposta",
  aprovada: "Aprovada",
  rejeitada: "Rejeitada",
  em_execucao: "Executando",
  executada: "Executada",
  erro: "Erro",
};

export const NOMES_CONCLUSAO: Record<string, string> = { "000": "000 procedente", "004": "004 improcedente" };

/** Categorias de correção do Banco de Análise (C_Classificação, C_OS Vinculada...). */
export const NOMES_CATEGORIA: Record<string, string> = {
  classificacao: "Classificação",
  os_vinculada: "OS vinculada",
  passo_manobra: "Passo de manobra",
  horario: "Horário",
  elemento_origem: "Elemento de origem",
};
export const CATEGORIAS = Object.keys(NOMES_CATEGORIA);

export const mb = (bytes: number | null | undefined) =>
  bytes == null ? "—" : bytes < 1024 * 1024 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1024 / 1024).toFixed(1).replace(".", ",")} MB`;
