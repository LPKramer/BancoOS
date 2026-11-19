import { useCallback, useEffect, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { api, consulta } from "../api";
import { Aviso, Botao, Carregando, EtiquetaCorrecao, Selecao, Vazio } from "../componentes/ui";
import { useEstado } from "../estado";
import { NOMES_CORRECAO_STATUS, dataHora } from "../formatos";
import type { Correcao } from "../tipos";

export default function Correcoes() {
  const { lote, tiposCorrecao, usuario } = useEstado();
  const [params, setParams] = useSearchParams();
  const status = params.get("status") ?? "proposta,aprovada";
  const tipo = params.get("tipo") ?? "";
  const [lista, setLista] = useState<Correcao[] | null>(null);
  const [selecao, setSelecao] = useState<Set<number>>(new Set());
  const [erro, setErro] = useState("");
  const [ok, setOk] = useState("");
  const [ocupado, setOcupado] = useState(false);

  const carregar = useCallback(() => {
    if (!lote) return;
    api
      .get<Correcao[]>(`/api/correcoes${consulta({ lote_id: lote.id, status, tipo })}`)
      .then((l) => {
        setLista(l);
        setSelecao(new Set());
      })
      .catch((e) => setErro(e.message));
  }, [lote, status, tipo]);
  useEffect(carregar, [carregar]);

  function definir(chave: string, valor: string) {
    const p = new URLSearchParams(params);
    if (valor) p.set(chave, valor);
    else p.delete(chave);
    setParams(p, { replace: true });
  }

  async function decidirLote(aprovar: boolean) {
    setOcupado(true);
    setErro("");
    setOk("");
    let feitas = 0;
    try {
      for (const id of selecao) {
        await api.post(`/api/correcoes/${id}/decisao`, { aprovar });
        feitas++;
      }
      setOk(`${feitas} correção(ões) ${aprovar ? "aprovada(s)" : "rejeitada(s)"}.`);
    } catch (e) {
      setErro(`${(e as Error).message} (${feitas} feitas antes do erro)`);
    } finally {
      setOcupado(false);
      carregar();
    }
  }

  if (!lote) return <Vazio>Nenhum lote importado.</Vazio>;

  const decidiveis = (lista ?? []).filter((c) => ["proposta", "rejeitada", "erro"].includes(c.status) || c.status === "aprovada");
  const todas = decidiveis.length > 0 && decidiveis.every((c) => selecao.has(c.id));

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-end gap-3">
        <Selecao rotulo="Status" value={status} onChange={(e) => definir("status", e.target.value)}>
          <option value="proposta,aprovada">propostas e aprovadas</option>
          {Object.entries(NOMES_CORRECAO_STATUS).map(([k, n]) => (
            <option key={k} value={k}>
              {n}
            </option>
          ))}
          <option value="proposta,aprovada,rejeitada,em_execucao,executada,erro">todas</option>
        </Selecao>
        <Selecao rotulo="Tipo" value={tipo} onChange={(e) => definir("tipo", e.target.value)} className="max-w-80">
          <option value="">todos</option>
          {Object.entries(tiposCorrecao).map(([k, t]) => (
            <option key={k} value={k}>
              {t.nome}
            </option>
          ))}
        </Selecao>
        <div className="ml-auto flex gap-2">
          <Botao variante="primario" disabled={!selecao.size || !usuario} carregando={ocupado} onClick={() => decidirLote(true)}>
            Aprovar {selecao.size || ""}
          </Botao>
          <Botao variante="perigo" disabled={!selecao.size || !usuario} carregando={ocupado} onClick={() => decidirLote(false)}>
            Rejeitar {selecao.size || ""}
          </Botao>
          <Link to="/robo" className="inline-flex h-8 items-center rounded-md border border-borda bg-secundaria px-3 text-sm hover:bg-borda">
            Executar no TS
          </Link>
        </div>
      </div>
      {!usuario && <Aviso tipo="info">Escolha o analista no topo da página para aprovar ou rejeitar.</Aviso>}
      <Aviso>{erro}</Aviso>
      {ok && <Aviso tipo="ok">{ok}</Aviso>}

      <div className="rounded-lg border border-borda bg-cartao">
        {!lista ? (
          <Carregando />
        ) : lista.length === 0 ? (
          <Vazio>Nenhuma correção com esse filtro.</Vazio>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-borda text-left text-xs text-texto-suave">
                  <th className="px-2 py-1.5">
                    <input
                      type="checkbox"
                      aria-label="Selecionar todas"
                      checked={todas}
                      onChange={() => setSelecao(todas ? new Set() : new Set(decidiveis.map((c) => c.id)))}
                    />
                  </th>
                  <th className="px-2 py-1.5 font-medium">OS</th>
                  <th className="px-2 py-1.5 font-medium">Tipo</th>
                  <th className="px-2 py-1.5 font-medium">Campo · alvo</th>
                  <th className="px-2 py-1.5 font-medium">De → para</th>
                  <th className="px-2 py-1.5 font-medium">Por quê</th>
                  <th className="px-2 py-1.5 font-medium" title="Texto padrão escolhido na OS; vai no campo Justificativa do TS">
                    Justificativa no TS
                  </th>
                  <th className="px-2 py-1.5 font-medium">Origem</th>
                  <th className="px-2 py-1.5 font-medium">Status</th>
                  <th className="px-2 py-1.5 font-medium">Robô</th>
                </tr>
              </thead>
              <tbody>
                {lista.map((c) => (
                  <tr key={c.id} className="border-b border-borda/50 align-top hover:bg-suave">
                    <td className="px-2 py-1.5">
                      <input
                        type="checkbox"
                        aria-label={`Selecionar correção ${c.id}`}
                        checked={selecao.has(c.id)}
                        onChange={() => {
                          const s = new Set(selecao);
                          if (s.has(c.id)) s.delete(c.id);
                          else s.add(c.id);
                          setSelecao(s);
                        }}
                      />
                    </td>
                    <td className="num whitespace-nowrap px-2 py-1.5">
                      <Link className="hover:underline" to={`/os/${c.os_fila_id}`}>
                        {c.os}
                      </Link>
                      <div className="text-xs text-texto-suave">{c.localidade}</div>
                    </td>
                    <td className="px-2 py-1.5">{tiposCorrecao[c.tipo]?.nome ?? c.tipo}</td>
                    <td className="num px-2 py-1.5">
                      {c.campo ?? "—"}
                      {c.alvo && <span className="text-texto-suave"> · {c.alvo}</span>}
                    </td>
                    <td className="num whitespace-nowrap px-2 py-1.5">
                      {c.valor_atual ?? "—"} → {c.valor_novo ?? "—"}
                    </td>
                    <td className="max-w-sm px-2 py-1.5 text-xs text-texto-suave">{c.justificativa}</td>
                    <td className="max-w-xs px-2 py-1.5 text-xs">
                      {c.justificativa_ts ? (
                        <span className="line-clamp-3" title={c.justificativa_ts}>
                          {c.justificativa_ts}
                        </span>
                      ) : (
                        <Link className="text-pendente-texto hover:underline" to={`/os/${c.os_fila_id}`}>
                          falta escolher
                        </Link>
                      )}
                    </td>
                    <td className="px-2 py-1.5 text-xs">{c.origem === "llm" ? "LLM" : "Analista"}</td>
                    <td className="px-2 py-1.5">
                      <EtiquetaCorrecao status={c.status} />
                      {c.decidido_por && <div className="text-xs text-texto-suave">{c.decidido_por} · {dataHora(c.decidido_em)}</div>}
                    </td>
                    <td className="max-w-xs px-2 py-1.5 text-xs">{c.resultado_robo ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
