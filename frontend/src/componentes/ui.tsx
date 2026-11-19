import { useEffect, useState, type ButtonHTMLAttributes, type ReactNode, type SelectHTMLAttributes } from "react";
import { NOMES_CORRECAO_STATUS, NOMES_STATUS, NOMES_VEREDITO } from "../formatos";

type Variante = "primario" | "secundario" | "perigo" | "discreto";

const VARIANTES: Record<Variante, string> = {
  primario: "bg-acao text-white hover:bg-acao-forte border border-acao",
  secundario: "bg-secundaria text-texto hover:bg-borda border border-borda",
  perigo: "bg-transparent text-erro-texto hover:bg-erro/15 border border-erro/60",
  discreto: "bg-transparent text-texto-suave hover:text-texto hover:bg-suave border border-transparent",
};

export function Botao({
  variante = "secundario",
  carregando = false,
  className = "",
  children,
  disabled,
  ...resto
}: ButtonHTMLAttributes<HTMLButtonElement> & { variante?: Variante; carregando?: boolean }) {
  return (
    <button
      {...resto}
      disabled={disabled || carregando}
      aria-busy={carregando || undefined}
      className={`inline-flex h-8 items-center justify-center rounded-md px-3 text-sm font-medium transition-colors duration-150 disabled:opacity-50 ${VARIANTES[variante]} ${className}`}
    >
      {carregando ? "Aguarde…" : children}
    </button>
  );
}

export function Selecao({ rotulo, className = "", children, ...resto }: SelectHTMLAttributes<HTMLSelectElement> & { rotulo: string }) {
  return (
    <label className={`flex flex-col gap-1 text-xs text-texto-suave ${className}`}>
      {rotulo}
      <select
        {...resto}
        className="h-8 rounded-md border border-borda bg-cartao px-2 text-sm text-texto transition-colors duration-150 hover:border-texto-suave"
      >
        {children}
      </select>
    </label>
  );
}

export function CampoTexto({
  rotulo,
  valor,
  aoMudar,
  tipo = "text",
  placeholder,
  className = "",
  multilinha = false,
}: {
  rotulo: string;
  valor: string;
  aoMudar: (v: string) => void;
  tipo?: string;
  placeholder?: string;
  className?: string;
  multilinha?: boolean;
}) {
  const classe =
    "rounded-md border border-borda bg-cartao px-2 text-sm text-texto placeholder:text-texto-suave/60 transition-colors duration-150 hover:border-texto-suave";
  return (
    <label className={`flex flex-col gap-1 text-xs text-texto-suave ${className}`}>
      {rotulo}
      {multilinha ? (
        <textarea className={`${classe} min-h-16 py-1.5`} value={valor} placeholder={placeholder} onChange={(e) => aoMudar(e.target.value)} />
      ) : (
        <input className={`${classe} h-8`} type={tipo} value={valor} placeholder={placeholder} onChange={(e) => aoMudar(e.target.value)} />
      )}
    </label>
  );
}

/** Campo de busca com atraso, para não consultar a cada tecla. */
export function Busca({ rotulo, valor, aoMudar, placeholder }: { rotulo: string; valor: string; aoMudar: (v: string) => void; placeholder?: string }) {
  const [texto, setTexto] = useState(valor);
  useEffect(() => setTexto(valor), [valor]);
  useEffect(() => {
    const t = setTimeout(() => {
      if (texto !== valor) aoMudar(texto);
    }, 350);
    return () => clearTimeout(t);
  }, [texto, valor, aoMudar]);
  return <CampoTexto rotulo={rotulo} valor={texto} aoMudar={setTexto} placeholder={placeholder} />;
}

const CORES: Record<string, string> = {
  vermelho: "bg-erro/15 text-erro-texto border-erro/40",
  ambar: "bg-pendente/15 text-pendente-texto border-pendente/40",
  verde: "bg-acao/15 text-ok-texto border-acao/40",
  azul: "bg-sky-500/10 text-info-texto border-sky-400/30",
  neutro: "bg-suave text-texto-suave border-borda",
};

export function Etiqueta({ cor = "neutro", children, titulo }: { cor?: keyof typeof CORES; children: ReactNode; titulo?: string }) {
  return (
    <span title={titulo} className={`inline-flex items-center whitespace-nowrap rounded border px-1.5 py-0.5 text-xs font-medium ${CORES[cor]}`}>
      {children}
    </span>
  );
}

const COR_STATUS: Record<string, keyof typeof CORES> = {
  pendente: "ambar",
  em_analise: "azul",
  correta: "verde",
  errada: "vermelho",
  corrigida: "verde",
  ignorada: "neutro",
};
export const EtiquetaStatus = ({ status }: { status: string }) => <Etiqueta cor={COR_STATUS[status] ?? "neutro"}>{NOMES_STATUS[status] ?? status}</Etiqueta>;

const COR_VEREDITO: Record<string, keyof typeof CORES> = { errada: "vermelho", duvidosa: "ambar", correta: "verde" };
export function EtiquetaVeredito({ veredito, confianca }: { veredito: string | null; confianca?: number | null }) {
  if (!veredito) return <span className="text-texto-suave">—</span>;
  return (
    <Etiqueta cor={COR_VEREDITO[veredito] ?? "neutro"}>
      {NOMES_VEREDITO[veredito] ?? veredito}
      {confianca != null ? ` ${Math.round(confianca * 100)}%` : ""}
    </Etiqueta>
  );
}

const COR_CORRECAO: Record<string, keyof typeof CORES> = {
  proposta: "ambar",
  aprovada: "azul",
  rejeitada: "neutro",
  em_execucao: "azul",
  executada: "verde",
  erro: "vermelho",
};
export const EtiquetaCorrecao = ({ status }: { status: string }) => (
  <Etiqueta cor={COR_CORRECAO[status] ?? "neutro"}>{NOMES_CORRECAO_STATUS[status] ?? status}</Etiqueta>
);

export function Cartao({ titulo, acoes, children, className = "" }: { titulo?: string; acoes?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`rounded-lg border border-borda bg-cartao ${className}`}>
      {(titulo || acoes) && (
        <header className="flex items-center justify-between gap-2 border-b border-borda px-3 py-2">
          {titulo && <h2 className="text-sm font-semibold">{titulo}</h2>}
          {acoes && <div className="flex flex-wrap items-center gap-2">{acoes}</div>}
        </header>
      )}
      <div className="p-3">{children}</div>
    </section>
  );
}

export function Indicador({ rotulo, valor, destaque }: { rotulo: string; valor: ReactNode; destaque?: "erro" | "ok" | "pendente" }) {
  const cor = destaque === "erro" ? "text-erro-texto" : destaque === "ok" ? "text-ok-texto" : destaque === "pendente" ? "text-pendente-texto" : "text-texto";
  return (
    <div className="rounded-lg border border-borda bg-cartao px-3 py-2">
      <div className="text-xs text-texto-suave">{rotulo}</div>
      <div className={`num text-xl font-medium ${cor}`}>{valor}</div>
    </div>
  );
}

export function Aviso({ tipo = "erro", children }: { tipo?: "erro" | "ok" | "info"; children: ReactNode }) {
  if (!children) return null;
  const cor = tipo === "erro" ? "border-erro/50 bg-erro/10 text-erro-texto" : tipo === "ok" ? "border-acao/50 bg-acao/10 text-ok-texto" : "border-borda bg-suave text-texto";
  return (
    <div role={tipo === "erro" ? "alert" : "status"} className={`rounded-md border px-3 py-2 text-sm ${cor}`}>
      {children}
    </div>
  );
}

export function Carregando({ texto = "Carregando…" }: { texto?: string }) {
  return (
    <div role="status" className="px-3 py-6 text-center text-sm text-texto-suave">
      {texto}
    </div>
  );
}

export function Vazio({ children }: { children: ReactNode }) {
  return <div className="px-3 py-6 text-center text-sm text-texto-suave">{children}</div>;
}

export function Paginacao({ pagina, tamanho, total, aoMudar }: { pagina: number; tamanho: number; total: number; aoMudar: (p: number) => void }) {
  const paginas = Math.max(1, Math.ceil(total / tamanho));
  return (
    <div className="flex items-center justify-end gap-2 text-sm text-texto-suave">
      <span className="num">
        {total === 0 ? "0" : `${(pagina - 1) * tamanho + 1}–${Math.min(pagina * tamanho, total)}`} de {total.toLocaleString("pt-BR")}
      </span>
      <Botao variante="discreto" disabled={pagina <= 1} onClick={() => aoMudar(pagina - 1)}>
        Anterior
      </Botao>
      <Botao variante="discreto" disabled={pagina >= paginas} onClick={() => aoMudar(pagina + 1)}>
        Próxima
      </Botao>
    </div>
  );
}

/** Tabela simples a partir de uma lista de registros (detalhe da OS). */
export function TabelaRegistros({
  linhas,
  colunas,
  destacar,
  formatar,
}: {
  linhas: Record<string, unknown>[];
  colunas: { chave: string; titulo: string; numero?: boolean }[];
  destacar?: (linha: Record<string, unknown>) => string | undefined;
  formatar?: (chave: string, v: unknown) => ReactNode;
}) {
  if (!linhas.length) return <Vazio>Nenhum registro.</Vazio>;
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-borda text-left text-xs text-texto-suave">
            {colunas.map((c) => (
              <th key={c.chave} className={`whitespace-nowrap px-2 py-1.5 font-medium ${c.numero ? "text-right" : ""}`}>
                {c.titulo}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {linhas.map((l, i) => (
            <tr key={i} className={`border-b border-borda/50 align-top ${destacar?.(l) ?? ""}`}>
              {colunas.map((c) => {
                const v = l[c.chave];
                return (
                  <td key={c.chave} className={`px-2 py-1.5 ${c.numero ? "num text-right" : ""}`}>
                    {formatar ? formatar(c.chave, v) : v == null || v === "" ? "—" : String(v)}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
