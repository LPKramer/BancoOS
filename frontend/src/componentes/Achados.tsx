import type { ReactNode } from "react";
import { useEstado } from "../estado";
import { dataHora, int, valor } from "../formatos";
import { calculado, curta, diverge } from "../manobraUtil";
import type { DetalheOS, Manobra } from "../tipos";
import { Aviso, Botao, Etiqueta, EtiquetaVeredito } from "./ui";

const GRADE_PASSO = "num grid grid-cols-[76px_minmax(0,1fr)_44px_44px] gap-x-1.5 px-1 py-0.5 text-xs";

function Bloco({ titulo, acoes, children }: { titulo: string; acoes?: ReactNode; children: ReactNode }) {
  return (
    <section className="border-b border-borda px-3 py-2.5 last:border-b-0">
      <div className="mb-1.5 flex items-center justify-between gap-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-texto-suave">{titulo}</h2>
        {acoes}
      </div>
      {children}
    </section>
  );
}

export default function Achados({
  detalhe,
  manobra,
  estadoManobra,
  analisando,
  erroLLM,
  ordemPasso,
  aoAnalisar,
  aoPasso,
  aoOS,
}: {
  detalhe: DetalheOS;
  manobra: Manobra | null;
  estadoManobra: "carregando" | "ok" | "sem_indice" | "erro" | "nao_se_aplica";
  analisando: boolean;
  erroLLM: string;
  ordemPasso: number | null;
  aoAnalisar: (forcar: boolean) => void;
  aoPasso: (ordem: number) => void;
  aoOS: (os: string) => void;
}) {
  const { regras, config } = useEstado();
  const analise = detalhe.analises[0];
  const m = manobra?.disponivel ? manobra : null;
  const diferem = m ? m.passos.filter(diverge) : [];
  const fora = m ? m.vinculadas.filter((v) => v.na_area === false) : [];

  return (
    <div className="flex flex-col">
      <Bloco titulo={`Regras (${detalhe.flags.length})`}>
        <ul className="flex flex-col gap-1.5">
          {detalhe.flags.map((f) => (
            <li key={f.regra_id} title={f.descricao}>
              <div className="flex flex-wrap items-center gap-1.5 text-sm">
                <span className="font-medium">{f.nome}</span>
                {f.valor !== "Verificar" && <Etiqueta cor="ambar">{f.valor}</Etiqueta>}
                {regras[f.regra_id] && !regras[f.regra_id].sozinha_basta && <Etiqueta>fraca</Etiqueta>}
              </div>
              {Object.keys(f.evidencia ?? {}).length > 0 && (
                <div className="flex flex-wrap gap-x-3 text-xs text-texto-suave">
                  {Object.entries(f.evidencia).map(([k, v]) => (
                    <span key={k}>
                      {k} <span className="num text-texto">{valor(v)}</span>
                    </span>
                  ))}
                </div>
              )}
            </li>
          ))}
        </ul>
      </Bloco>

      <Bloco titulo="BDGD">
        {estadoManobra === "carregando" && <p className="text-sm text-texto-suave">Simulando a manobra…</p>}
        {estadoManobra === "nao_se_aplica" && <p className="text-sm text-texto-suave">OS individual: sem manobra.</p>}
        {estadoManobra === "sem_indice" && <p className="text-sm text-texto-suave">BDGD não preparada neste servidor.</p>}
        {estadoManobra === "erro" && <p className="text-sm text-erro-texto">Falha ao simular a manobra.</p>}
        {manobra && !manobra.disponivel && <p className="text-sm text-texto-suave">{manobra.motivo}</p>}
        {m && (
          <div className="flex flex-col gap-2 text-sm">
            <div className="grid grid-cols-2 gap-x-3 gap-y-1">
              <span className="text-texto-suave">Passos localizados</span>
              <span className="num text-right">
                {m.resumo.passos_localizados} de {m.resumo.passos_total}
              </span>
              <span className="text-texto-suave">Maior desligamento</span>
              <span className="num text-right">{m.resumo.pico_ucs != null ? `${int(m.resumo.pico_ucs)} UCs` : "—"}</span>
              <span className="text-texto-suave">1º passo registra</span>
              <span className="num text-right">{m.resumo.qtd_primeiro_passo != null ? `${int(m.resumo.qtd_primeiro_passo)} UCs` : "—"}</span>
            </div>
            {diferem.length > 0 && (
              <div>
                <div className="text-xs text-pendente-texto">Passos em que TS e BDGD diferem ({diferem.length})</div>
                <div className={`${GRADE_PASSO} text-texto-suave`} aria-hidden>
                  <span>Data</span>
                  <span>Passo</span>
                  <span className="text-right">TS</span>
                  <span className="text-right">BDGD</span>
                </div>
                <ul>
                  {diferem.map((p) => (
                    <li key={p.ordem}>
                      <button
                        aria-pressed={p.ordem === ordemPasso}
                        className={`${GRADE_PASSO} w-full rounded text-left hover:bg-suave ${p.ordem === ordemPasso ? "bg-secundaria" : ""}`}
                        onClick={() => aoPasso(p.ordem)}
                      >
                        <span className="text-texto-suave">{curta(p.data)}</span>
                        <span className="truncate">
                          {p.oper} {p.cod_ts}
                        </span>
                        <span className="text-right">{int(p.qtd_registrada)}</span>
                        <span className="text-right text-pendente-texto">{int(calculado(p))}</span>
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            )}
            {fora.length > 0 && (
              <div>
                <div className="text-xs text-erro-texto">
                  Vinculadas fora da área ({fora.length} de {m.resumo.vinculadas_localizadas} localizadas)
                </div>
                <div className="flex flex-wrap gap-x-2">
                  {fora.map((v) => (
                    <button key={v.os} className="num rounded px-1 py-0.5 text-xs hover:bg-suave" onClick={() => aoOS(v.os)}>
                      {v.os}
                    </button>
                  ))}
                </div>
              </div>
            )}
            {m.candidatas.length > 0 && (
              <div>
                <div className="text-xs text-[#fdba74]">Reclamações na área sem vínculo ({m.candidatas.length})</div>
                <div className="flex flex-wrap gap-x-2">
                  {m.candidatas.map((c) => (
                    <button key={c.os} className="num rounded px-1 py-0.5 text-xs hover:bg-suave" onClick={() => aoOS(c.os)}>
                      {c.os}
                    </button>
                  ))}
                </div>
              </div>
            )}
            {Object.values(m.candidatos).map((c) => (
              <div key={c.cod_id} className="text-xs text-texto-suave">
                Ponto provável: <span className="num text-texto">{c.tipo} {c.cod_id}</span>
                {c.ucs_jusante != null && ` · ${int(c.ucs_jusante)} UCs a jusante`}
              </div>
            ))}
            {m.avisos.map((a) => (
              <p key={a} className="text-xs text-texto-suave">
                {a}
              </p>
            ))}
          </div>
        )}
      </Bloco>

      <Bloco
        titulo="LLM"
        acoes={
          <Botao
            variante="discreto"
            className="h-7 px-2"
            carregando={analisando}
            disabled={!config?.llm_configurado}
            title={config?.llm_configurado ? undefined : "Chave do LLM não configurada no servidor"}
            onClick={() => aoAnalisar(Boolean(analise))}
          >
            {analise ? "Reanalisar" : "Analisar"}
          </Botao>
        }
      >
        <Aviso>{erroLLM}</Aviso>
        {!analise ? (
          <p className="text-sm text-texto-suave">Sem análise.</p>
        ) : analise.erro ? (
          <Aviso>{analise.erro}</Aviso>
        ) : (
          <div className="flex flex-col gap-1.5 text-sm">
            <div className="flex items-center gap-2">
              <EtiquetaVeredito veredito={analise.veredito} confianca={analise.confianca} />
              <span className="text-xs text-texto-suave">{dataHora(analise.criado_em)}</span>
            </div>
            {analise.resposta.resumo && <p>{analise.resposta.resumo}</p>}
            {analise.resposta.problemas?.map((p, i) => (
              <div key={i} className="border-l-2 border-erro/60 pl-2">
                <div>{p.descricao}</div>
                {p.evidencia && <div className="text-xs text-texto-suave">{p.evidencia}</div>}
              </div>
            ))}
            {!!analise.resposta.regras_falso_positivo?.length && (
              <p className="text-xs text-texto-suave">
                Falso positivo: {analise.resposta.regras_falso_positivo.map((x) => regras[x]?.nome ?? x).join(", ")}
              </p>
            )}
          </div>
        )}
      </Bloco>
    </div>
  );
}
