import { useState } from "react";
import { NavLink, Outlet } from "react-router-dom";
import { api } from "../api";
import { useEstado } from "../estado";

const LINKS = [
  { para: "/", texto: "Painel" },
  { para: "/fila", texto: "Fila" },
  { para: "/correcoes", texto: "Correções" },
  { para: "/robo", texto: "Robô" },
  { para: "/textos", texto: "Textos" },
  { para: "/importar", texto: "Importar" },
];

export default function Layout() {
  const { lotes, lote, escolherLote, usuario, definirUsuario, analistas, recarregarAnalistas } = useEstado();
  const [novo, setNovo] = useState(false);
  const [nome, setNome] = useState("");

  async function adicionar() {
    const n = nome.trim();
    if (!n) return;
    const r = await api.post<{ nome: string }>("/api/analistas", { nome: n });
    recarregarAnalistas();
    definirUsuario(r.nome);
    setNovo(false);
    setNome("");
  }

  return (
    <div className="min-h-screen">
      <a href="#conteudo" className="sr-only focus:not-sr-only focus:absolute focus:left-2 focus:top-2 focus:rounded focus:bg-cartao focus:px-3 focus:py-2">
        Ir para o conteúdo
      </a>
      <header className="sticky top-0 z-10 border-b border-borda bg-fundo/95 backdrop-blur">
        <div className="mx-auto flex max-w-[1600px] flex-wrap items-center gap-x-6 gap-y-2 px-4 py-2">
          <span className="font-mono text-sm font-medium">Análise de OS</span>
          <nav aria-label="Principal" className="flex flex-wrap gap-1">
            {LINKS.map((l) => (
              <NavLink
                key={l.para}
                to={l.para}
                end={l.para === "/"}
                className={({ isActive }) =>
                  `rounded-md px-2.5 py-1 text-sm transition-colors duration-150 ${isActive ? "bg-secundaria text-texto" : "text-texto-suave hover:bg-suave hover:text-texto"}`
                }
              >
                {l.texto}
              </NavLink>
            ))}
          </nav>
          <div className="ml-auto flex flex-wrap items-center gap-3 text-sm">
            <label className="flex items-center gap-2 text-texto-suave">
              Lote
              <select
                className="h-8 max-w-64 rounded-md border border-borda bg-cartao px-2 text-texto"
                value={lote?.id ?? ""}
                onChange={(e) => escolherLote(Number(e.target.value))}
              >
                {lotes.length === 0 && <option value="">nenhum</option>}
                {lotes.map((l) => (
                  <option key={l.id} value={l.id}>
                    {l.id} · {l.competencia ?? "?"} · {l.fila ?? 0} OS
                  </option>
                ))}
              </select>
            </label>
            {novo ? (
              <span className="flex items-center gap-1">
                <input
                  autoFocus
                  aria-label="Nome do analista"
                  className="h-8 w-36 rounded-md border border-borda bg-cartao px-2 text-texto"
                  value={nome}
                  onChange={(e) => setNome(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && adicionar()}
                />
                <button className="rounded-md px-2 py-1 text-acao hover:bg-suave" onClick={adicionar}>
                  Salvar
                </button>
                <button className="rounded-md px-2 py-1 text-texto-suave hover:bg-suave" onClick={() => setNovo(false)}>
                  Cancelar
                </button>
              </span>
            ) : (
              <label className="flex items-center gap-2 text-texto-suave">
                Analista
                <select
                  className={`h-8 rounded-md border bg-cartao px-2 text-texto ${usuario ? "border-borda" : "border-pendente"}`}
                  value={usuario}
                  onChange={(e) => (e.target.value === "__novo" ? setNovo(true) : definirUsuario(e.target.value))}
                >
                  <option value="">escolha</option>
                  {analistas.map((a) => (
                    <option key={a} value={a}>
                      {a}
                    </option>
                  ))}
                  <option value="__novo">Outro…</option>
                </select>
              </label>
            )}
          </div>
        </div>
      </header>
      <main id="conteudo" className="mx-auto max-w-[1600px] px-4 py-4">
        <Outlet />
      </main>
    </div>
  );
}
