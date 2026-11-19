import { useCallback, useEffect, useMemo, useState } from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { api, consulta } from "../api";
import { Aviso, Botao, Busca, Carregando, EtiquetaStatus, EtiquetaVeredito, Paginacao, Selecao, Vazio } from "../componentes/ui";
import { useEstado } from "../estado";
import { NOMES_STATUS, NOMES_VEREDITO, dec, int, rs } from "../formatos";
import type { PaginaFila, Tarefa } from "../tipos";

export const FILTROS = ["status", "regra", "coec", "veredito", "tipo_os", "analista", "busca", "ordem"] as const;

const COLUNAS_ORDENAVEIS: Record<string, string> = { multa: "Compensação", regras: "Regras", tma: "TMA", dec: "DEC", confianca: "Veredito LLM", os: "OS" };

export default function Fila() {
  const { lote, regras, analistas, config } = useEstado();
  const [params, setParams] = useSearchParams();
  const [pagina, setPagina] = useState(1);
  const [dados, setDados] = useState<PaginaFila | null>(null);
  const [erro, setErro] = useState("");
  const [tarefa, setTarefa] = useState<Tarefa | null>(null);
  const [limite, setLimite] = useState("50");
  const navegar = useNavigate();

  const filtros = useMemo(() => Object.fromEntries(FILTROS.map((f) => [f, params.get(f) ?? ""])), [params]);
  const definir = useCallback(
    (chave: string, valor: string) => {
      const p = new URLSearchParams(params);
      if (valor) p.set(chave, valor);
      else p.delete(chave);
      setParams(p, { replace: true });
      setPagina(1);
    },
    [params, setParams],
  );

  const carregar = useCallback(() => {
    if (!lote) return;
    api
      .get<PaginaFila>(`/api/lotes/${lote.id}/fila${consulta({ ...filtros, pagina, tamanho: 50 })}`)
      .then((d) => {
        setDados(d);
        setErro("");
      })
      .catch((e) => setErro(e.message));
  }, [lote, filtros, pagina]);

  useEffect(carregar, [carregar]);

  useEffect(() => {
    if (!tarefa || tarefa.situacao !== "rodando") return;
    const t = setInterval(async () => {
      try {
        const st = await api.get<Tarefa>(`/api/tarefas/${tarefa.id}`);
        setTarefa(st);
        if (st.situacao !== "rodando") carregar();
      } catch {
        /* tenta de novo no próximo ciclo */
      }
    }, 2000);
    return () => clearInterval(t);
  }, [tarefa, carregar]);

  async function analisarFiltro() {
    if (!lote) return;
    setErro("");
    try {
      const t = await api.post<Tarefa>(`/api/lotes/${lote.id}/analisar`, {
        status: filtros.status || null,
        regra: filtros.regra || null,
        coec: filtros.coec || null,
        veredito: filtros.veredito || "sem_analise",
        tipo_os: filtros.tipo_os || null,
        limite: Number(limite) || 50,
      });
      setTarefa(t);
    } catch (e) {
      setErro((e as Error).message);
    }
  }

  if (!lote) return <Vazio>Nenhum lote importado.</Vazio>;

  const coecs = ["CENTRO", "NORTE", "SUL"];
  const listaRegras = Object.values(regras).sort((a, b) => a.nome.localeCompare(b.nome));
  const ordem = filtros.ordem || "multa";
  const qsDetalhe = consulta(filtros);

  function Cabecalho({ chave, titulo, numero }: { chave?: string; titulo: string; numero?: boolean }) {
    const ordenavel = chave && COLUNAS_ORDENAVEIS[chave];
    const ativo = chave === ordem;
    return (
      <th
        scope="col"
        aria-sort={ativo ? "descending" : undefined}
        className={`whitespace-nowrap px-2 py-1.5 font-medium ${numero ? "text-right" : ""}`}
      >
        {ordenavel ? (
          <button className={`hover:text-texto ${ativo ? "text-texto" : ""}`} onClick={() => definir("ordem", chave === "multa" ? "" : chave!)}>
            {titulo}
            {ativo ? " ↓" : ""}
          </button>
        ) : (
          titulo
        )}
      </th>
    );
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-end gap-3">
        <Busca rotulo="Buscar OS, localidade ou causa" valor={filtros.busca} aoMudar={(v) => definir("busca", v)} />
        <Selecao rotulo="Status" value={filtros.status} onChange={(e) => definir("status", e.target.value)}>
          <option value="">todos</option>
          {(config?.status_os ?? Object.keys(NOMES_STATUS)).map((s) => (
            <option key={s} value={s}>
              {NOMES_STATUS[s]}
            </option>
          ))}
        </Selecao>
        <Selecao rotulo="Regra" value={filtros.regra} onChange={(e) => definir("regra", e.target.value)} className="max-w-72">
          <option value="">todas</option>
          {listaRegras.map((r) => (
            <option key={r.id} value={r.id}>
              {r.nome}
            </option>
          ))}
        </Selecao>
        <Selecao rotulo="COEC" value={filtros.coec} onChange={(e) => definir("coec", e.target.value)}>
          <option value="">todos</option>
          {coecs.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </Selecao>
        <Selecao rotulo="Veredito LLM" value={filtros.veredito} onChange={(e) => definir("veredito", e.target.value)}>
          <option value="">todos</option>
          {Object.entries(NOMES_VEREDITO).map(([k, n]) => (
            <option key={k} value={k}>
              {n}
            </option>
          ))}
        </Selecao>
        <Selecao rotulo="Tipo" value={filtros.tipo_os} onChange={(e) => definir("tipo_os", e.target.value)}>
          <option value="">todos</option>
          <option value="intervencao">Intervenção</option>
          <option value="individual">Individual</option>
        </Selecao>
        <Selecao rotulo="Analista" value={filtros.analista} onChange={(e) => definir("analista", e.target.value)}>
          <option value="">todos</option>
          {analistas.map((a) => (
            <option key={a}>{a}</option>
          ))}
        </Selecao>
        {Object.values(filtros).some(Boolean) && (
          <Botao variante="discreto" onClick={() => setParams({}, { replace: true })}>
            Limpar filtros
          </Botao>
        )}
        <div className="ml-auto flex flex-wrap items-end gap-2">
          <label className="flex flex-col gap-1 text-xs text-texto-suave">
            Quantas OS
            <input
              className="num h-8 w-20 rounded-md border border-borda bg-cartao px-2 text-sm text-texto"
              inputMode="numeric"
              value={limite}
              onChange={(e) => setLimite(e.target.value.replace(/\D/g, ""))}
            />
          </label>
          <Botao
            variante="primario"
            disabled={!config?.llm_configurado || tarefa?.situacao === "rodando"}
            title={config?.llm_configurado ? "Analisa as OS do filtro ainda sem análise, por maior compensação" : "Chave do LLM não configurada no servidor"}
            onClick={analisarFiltro}
          >
            Analisar com LLM
          </Botao>
          <a
            className="inline-flex h-8 items-center rounded-md border border-borda bg-secundaria px-3 text-sm hover:bg-borda"
            href={`/api/lotes/${lote.id}/exportar${consulta({ ...filtros, ordem: undefined })}`}
          >
            Exportar Excel
          </a>
        </div>
      </div>

      <Aviso>{erro}</Aviso>
      {tarefa && (
        <Aviso tipo={tarefa.situacao === "erro" ? "erro" : tarefa.situacao === "rodando" ? "info" : "ok"}>
          {tarefa.situacao === "rodando" ? "Analisando" : tarefa.situacao === "cancelada" ? "Cancelada" : tarefa.situacao === "erro" ? "Erro" : "Concluída"}:{" "}
          <span className="num">
            {tarefa.feitas}/{tarefa.total}
          </span>{" "}
          OS · {Object.entries(tarefa.vereditos).map(([k, v]) => `${NOMES_VEREDITO[k] ?? k} ${v}`).join(" · ") || "sem vereditos ainda"}
          {tarefa.erros > 0 && ` · ${tarefa.erros} com erro`}
          {tarefa.mensagem && ` · ${tarefa.mensagem}`}
          {tarefa.situacao === "rodando" && (
            <button className="ml-3 underline" onClick={() => api.post(`/api/tarefas/${tarefa.id}/cancelar`).catch(() => {})}>
              Cancelar
            </button>
          )}
        </Aviso>
      )}

      <div className="rounded-lg border border-borda bg-cartao">
        {!dados ? (
          <Carregando />
        ) : dados.itens.length === 0 ? (
          <Vazio>Nenhuma OS com esses filtros.</Vazio>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-borda text-left text-xs text-texto-suave">
                  <Cabecalho chave="os" titulo="OS" />
                  <Cabecalho titulo="Localidade" />
                  <Cabecalho chave="multa" titulo="Compensação" numero />
                  <Cabecalho chave="regras" titulo="Regras" />
                  <Cabecalho titulo="Causa / subcausa" />
                  <Cabecalho titulo="Concl." />
                  <Cabecalho chave="tma" titulo="TMA" numero />
                  <Cabecalho chave="dec" titulo="DEC" numero />
                  <Cabecalho titulo="Status" />
                  <Cabecalho chave="confianca" titulo="Veredito LLM" />
                  <Cabecalho titulo="Analista" />
                </tr>
              </thead>
              <tbody>
                {dados.itens.map((o) => (
                  <tr
                    key={o.id}
                    className="cursor-pointer border-b border-borda/50 transition-colors duration-150 hover:bg-suave"
                    onClick={() => navegar(`/os/${o.id}${qsDetalhe}`)}
                  >
                    <td className="num whitespace-nowrap px-2 py-1.5">
                      <Link to={`/os/${o.id}${qsDetalhe}`} onClick={(e) => e.stopPropagation()} className="hover:underline">
                        {o.os}
                      </Link>
                      {o.tipo_os === "individual" && <span className="ml-1 text-xs text-texto-suave">ind.</span>}
                    </td>
                    <td className="whitespace-nowrap px-2 py-1.5">
                      {o.localidade ?? "—"}
                      {o.coec && <span className="ml-1 text-xs text-texto-suave">{o.coec}</span>}
                    </td>
                    <td className="num px-2 py-1.5 text-right">{rs(o.multa)}</td>
                    <td className="px-2 py-1.5">
                      <div className="w-56 truncate text-xs text-texto-suave" title={o.regras.map((r) => regras[r]?.nome ?? r).join("\n")}>
                        <span className="num text-texto">{o.n_regras}</span> {o.regras.map((r) => regras[r]?.nome ?? r).join(" · ")}
                      </div>
                    </td>
                    <td className="px-2 py-1.5">
                      <div className="w-56 truncate" title={`${o.causa ?? ""} / ${o.subcausa ?? ""}`}>
                        {o.causa ?? "—"}
                      </div>
                      <div className="w-56 truncate text-xs text-texto-suave">{o.subcausa}</div>
                    </td>
                    <td className="num px-2 py-1.5">{o.conclusao ?? "—"}</td>
                    <td className="num px-2 py-1.5 text-right">{int(o.tma)}</td>
                    <td className="num px-2 py-1.5 text-right">{dec(o.dec)}</td>
                    <td className="px-2 py-1.5">
                      <EtiquetaStatus status={o.status} />
                    </td>
                    <td className="px-2 py-1.5">
                      <EtiquetaVeredito veredito={o.veredito_llm} confianca={o.confianca_llm} />
                    </td>
                    <td className="px-2 py-1.5 text-texto-suave">{o.analista ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      {dados && <Paginacao pagina={pagina} tamanho={dados.tamanho} total={dados.total} aoMudar={setPagina} />}
    </div>
  );
}
