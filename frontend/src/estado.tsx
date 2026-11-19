import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { api, salvarUsuario, usuarioSalvo } from "./api";
import type { Config, Lote, Regra, TextoPadrao, TipoCorrecao } from "./tipos";

interface Estado {
  usuario: string;
  definirUsuario: (nome: string) => void;
  analistas: string[];
  recarregarAnalistas: () => void;
  lotes: Lote[];
  lote: Lote | null;
  escolherLote: (id: number) => void;
  recarregarLotes: () => Promise<Lote[]>;
  config: Config | null;
  regras: Record<string, Regra>;
  tiposCorrecao: Record<string, TipoCorrecao>;
  textosPadrao: TextoPadrao[];
  definirTextos: (t: TextoPadrao[]) => void;
}

const Contexto = createContext<Estado | null>(null);
const CHAVE_LOTE = "osa.lote";

export function ProvedorEstado({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState(usuarioSalvo());
  const [analistas, setAnalistas] = useState<string[]>([]);
  const [lotes, setLotes] = useState<Lote[]>([]);
  const [loteId, setLoteId] = useState<number | null>(() => {
    try {
      const v = localStorage.getItem(CHAVE_LOTE);
      return v ? Number(v) : null;
    } catch {
      return null;
    }
  });
  const [config, setConfig] = useState<Config | null>(null);
  const [regras, setRegras] = useState<Record<string, Regra>>({});
  const [tiposCorrecao, setTipos] = useState<Record<string, TipoCorrecao>>({});
  const [textosPadrao, setTextos] = useState<TextoPadrao[]>([]);

  const recarregarLotes = useCallback(async () => {
    const l = await api.get<Lote[]>("/api/lotes");
    setLotes(l);
    return l;
  }, []);
  const recarregarAnalistas = useCallback(() => {
    api.get<string[]>("/api/analistas").then(setAnalistas).catch(() => setAnalistas([]));
  }, []);

  useEffect(() => {
    recarregarLotes().catch(() => setLotes([]));
    recarregarAnalistas();
    api.get<Config>("/api/config").then(setConfig).catch(() => setConfig(null));
    api.get<Regra[]>("/api/regras").then((rs) => setRegras(Object.fromEntries(rs.map((r) => [r.id, r])))).catch(() => {});
    api.get<Record<string, TipoCorrecao>>("/api/tipos-correcao").then(setTipos).catch(() => {});
    api.get<{ textos: TextoPadrao[] }>("/api/textos-padrao").then((r) => setTextos(r.textos)).catch(() => {});
  }, [recarregarLotes, recarregarAnalistas]);

  const lote = useMemo(() => lotes.find((l) => l.id === loteId) ?? lotes[0] ?? null, [lotes, loteId]);

  const valor: Estado = {
    usuario,
    definirUsuario: (nome) => {
      salvarUsuario(nome);
      setUsuario(nome);
    },
    analistas,
    recarregarAnalistas,
    lotes,
    lote,
    escolherLote: (id) => {
      try {
        localStorage.setItem(CHAVE_LOTE, String(id));
      } catch {
        /* sem armazenamento */
      }
      setLoteId(id);
    },
    recarregarLotes,
    config,
    regras,
    tiposCorrecao,
    textosPadrao,
    definirTextos: setTextos,
  };
  return <Contexto.Provider value={valor}>{children}</Contexto.Provider>;
}

export function useEstado(): Estado {
  const c = useContext(Contexto);
  if (!c) throw new Error("useEstado fora do ProvedorEstado");
  return c;
}
