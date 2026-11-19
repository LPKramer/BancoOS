import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api, consulta } from "../api";
import { Aviso, Cartao, Carregando, Etiqueta, Indicador, Vazio } from "../componentes/ui";
import { useEstado } from "../estado";
import { NOMES_CORRECAO_STATUS, NOMES_STATUS, NOMES_VEREDITO, int, pct, rs } from "../formatos";
import type { Painel as TPainel } from "../tipos";

interface Avaliacao {
  avaliadas: number;
  vp: number;
  fp: number;
  vn: number;
  fn: number;
  duvidosa: number;
  precisao: number | null;
  recall: number | null;
}

export default function Painel() {
  const { lote, regras } = useEstado();
  const [painel, setPainel] = useState<TPainel | null>(null);
  const [avaliacao, setAvaliacao] = useState<Avaliacao | null>(null);
  const [erro, setErro] = useState("");

  useEffect(() => {
    if (!lote) return;
    setPainel(null);
    setErro("");
    api.get<TPainel>(`/api/lotes/${lote.id}/painel`).then(setPainel).catch((e) => setErro(e.message));
    api.get<Avaliacao>(`/api/lotes/${lote.id}/avaliacao-llm`).then(setAvaliacao).catch(() => setAvaliacao(null));
  }, [lote]);

  if (!lote) {
    return (
      <Vazio>
        Nenhum lote importado. <Link className="underline" to="/importar">Importar bases</Link>
      </Vazio>
    );
  }
  if (erro) return <Aviso>{erro}</Aviso>;
  if (!painel) return <Carregando />;

  const fila = (params: Record<string, string>) => `/fila${consulta(params)}`;
  const pendentes = painel.por_status.pendente ?? 0;
  const erradas = (painel.por_status.errada ?? 0) + (painel.por_status.corrigida ?? 0);
  const paridade = lote.paridade;

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
        <h1 className="text-lg font-semibold">Competência {lote.competencia ?? "—"}</h1>
        <span className="text-sm text-texto-suave">
          lote {lote.id} · {lote.nome_origem}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-6">
        <Indicador rotulo="OS na fila" valor={int(painel.total)} />
        <Indicador rotulo="Compensação em jogo" valor={rs(painel.multa_total)} />
        <Indicador rotulo="Pendentes" valor={int(pendentes)} destaque="pendente" />
        <Indicador rotulo="Erradas ou corrigidas" valor={int(erradas)} destaque="erro" />
        <Indicador rotulo="Correções aprovadas" valor={int(painel.correcoes.aprovada ?? 0)} />
        <Indicador rotulo="Executadas no TS" valor={int(painel.correcoes.executada ?? 0)} destaque="ok" />
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Cartao titulo="Por regra" className="xl:col-span-2">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-borda text-left text-xs text-texto-suave">
                  <th className="px-2 py-1.5 font-medium">Regra</th>
                  <th className="px-2 py-1.5 text-right font-medium">OS</th>
                  <th className="px-2 py-1.5 text-right font-medium">Compensação</th>
                  <th className="px-2 py-1.5 font-medium" />
                </tr>
              </thead>
              <tbody>
                {painel.por_regra.map((r) => (
                  <tr key={r.regra_id} className="border-b border-borda/50 hover:bg-suave">
                    <td className="px-2 py-1.5">
                      <Link className="hover:underline" to={fila({ regra: r.regra_id })} title={regras[r.regra_id]?.descricao}>
                        {r.nome}
                      </Link>
                    </td>
                    <td className="num px-2 py-1.5 text-right">{int(r.os)}</td>
                    <td className="num px-2 py-1.5 text-right">{rs(r.multa)}</td>
                    <td className="px-2 py-1.5 text-right">
                      {!r.sozinha_basta && (
                        <Etiqueta titulo="Sozinha, esta regra não coloca a OS na fila">sinal fraco</Etiqueta>
                      )}
                      {regras[r.regra_id]?.divergencia_access && (
                        <Etiqueta cor="ambar" titulo={regras[r.regra_id]?.divergencia_access ?? ""}>
                          não marca no Access
                        </Etiqueta>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Cartao>

        <div className="flex flex-col gap-4">
          <Cartao titulo="Andamento">
            <ul className="flex flex-col gap-1 text-sm">
              {Object.entries(NOMES_STATUS).map(([k, nome]) => (
                <li key={k} className="flex justify-between">
                  <Link className="hover:underline" to={fila({ status: k })}>
                    {nome}
                  </Link>
                  <span className="num">{int(painel.por_status[k] ?? 0)}</span>
                </li>
              ))}
            </ul>
          </Cartao>
          <Cartao titulo="Análise do LLM">
            <ul className="flex flex-col gap-1 text-sm">
              {["errada", "duvidosa", "correta", "sem_analise"].map((k) => (
                <li key={k} className="flex justify-between">
                  <Link className="hover:underline" to={fila({ veredito: k })}>
                    {NOMES_VEREDITO[k]}
                  </Link>
                  <span className="num">{int(painel.por_veredito[k] ?? 0)}</span>
                </li>
              ))}
            </ul>
            {avaliacao && avaliacao.avaliadas > 0 && (
              <div className="mt-3 border-t border-borda pt-2 text-sm">
                <div className="mb-1 text-xs text-texto-suave">Contra o histórico do Access ({int(avaliacao.avaliadas)} OS)</div>
                <div className="flex justify-between">
                  <span>Precisão</span>
                  <span className="num">{pct(avaliacao.precisao)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Cobertura</span>
                  <span className="num">{pct(avaliacao.recall)}</span>
                </div>
              </div>
            )}
          </Cartao>
          <Cartao titulo="Correções">
            <ul className="flex flex-col gap-1 text-sm">
              {Object.entries(NOMES_CORRECAO_STATUS).map(([k, nome]) => (
                <li key={k} className="flex justify-between">
                  <Link className="hover:underline" to={`/correcoes${consulta({ status: k })}`}>
                    {nome}
                  </Link>
                  <span className="num">{int(painel.correcoes[k] ?? 0)}</span>
                </li>
              ))}
            </ul>
          </Cartao>
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Cartao titulo="Por COEC">
          <table className="w-full text-sm">
            <tbody>
              {painel.por_coec.map((c) => (
                <tr key={c.coec} className="border-b border-borda/50 hover:bg-suave">
                  <td className="px-2 py-1.5">
                    <Link className="hover:underline" to={fila(c.coec === "-" ? {} : { coec: c.coec })}>
                      {c.coec}
                    </Link>
                  </td>
                  <td className="num px-2 py-1.5 text-right">{int(c.os)}</td>
                  <td className="num px-2 py-1.5 text-right">{rs(c.multa)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Cartao>

        {paridade && (
          <Cartao titulo="Conferência com o Access" className="xl:col-span-2">
            <p className="mb-2 text-sm text-texto-suave">
              Fila do app {int(paridade.resumo.fila_app)} · fila do Access {int(paridade.resumo.fila_access)} · em comum{" "}
              {int(paridade.resumo.fila_comum)} · só no Access {int(paridade.resumo.so_fila_access)} · só no app{" "}
              {int(paridade.resumo.so_fila_app)} ({int(paridade.resumo.so_fila_app_explicadas)} pelas regras que não marcam no Access)
            </p>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-borda text-left text-xs text-texto-suave">
                    <th className="px-2 py-1.5 font-medium">Regra</th>
                    <th className="px-2 py-1.5 text-right font-medium">App</th>
                    <th className="px-2 py-1.5 text-right font-medium">Access</th>
                    <th className="px-2 py-1.5 font-medium">Resultado</th>
                  </tr>
                </thead>
                <tbody>
                  {paridade.regras.map((r) => (
                    <tr key={r.regra_id} className="border-b border-borda/50">
                      <td className="px-2 py-1.5">{regras[r.regra_id]?.nome ?? r.regra_id}</td>
                      <td className="num px-2 py-1.5 text-right">{int(r.app)}</td>
                      <td className="num px-2 py-1.5 text-right">{int(r.access)}</td>
                      <td className="px-2 py-1.5">
                        {r.ok ? (
                          <Etiqueta cor="verde">igual</Etiqueta>
                        ) : r.divergencia ? (
                          <Etiqueta cor="ambar" titulo={r.divergencia}>
                            diferença conhecida
                          </Etiqueta>
                        ) : (
                          <Etiqueta cor="vermelho">
                            diferente ({r.so_app} só app, {r.so_access} só Access)
                          </Etiqueta>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Cartao>
        )}
      </div>
    </div>
  );
}
