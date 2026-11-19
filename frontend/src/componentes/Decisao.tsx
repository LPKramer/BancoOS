import { useMemo, useState } from "react";
import { api } from "../api";
import { useEstado } from "../estado";
import { NOMES_STATUS, dataHora } from "../formatos";
import { buscar, pendencias, sugerir } from "../justificativas";
import type { Correcao, DetalheOS, TextoPadrao } from "../tipos";
import { Aviso, Botao, CampoTexto, Etiqueta, EtiquetaCorrecao, Selecao } from "./ui";

const CHAVE_AVANCAR = "osa.avancar";

export interface CamposDecisao {
  status?: string;
  responsavel?: string;
  observacao?: string;
  categorias_correcao?: string[];
  justificativa_ts?: string;
}

export default function Decisao({
  detalhe,
  aoSalvar,
  aoMudarCorrecoes,
}: {
  detalhe: DetalheOS;
  aoSalvar: (campos: CamposDecisao, avancar: boolean) => Promise<void>;
  aoMudarCorrecoes: () => void;
}) {
  const { usuario, config, tiposCorrecao } = useEstado();
  const r = detalhe.resumo;
  const [form, setForm] = useState({
    status: r.status,
    responsavel: r.responsavel ?? "",
    observacao: r.observacao ?? "",
    categorias: r.categorias_correcao ?? [],
    justificativa: r.justificativa_ts ?? "",
  });
  const [avancar, setAvancar] = useState(() => {
    try {
      return localStorage.getItem(CHAVE_AVANCAR) !== "0";
    } catch {
      return true;
    }
  });
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");
  const [ok, setOk] = useState("");
  const categorias = config?.categorias_correcao ?? {};

  async function salvar(status?: string, seguir = false) {
    setSalvando(true);
    setErro("");
    setOk("");
    try {
      await aoSalvar(
        {
          status: status ?? form.status,
          responsavel: form.responsavel,
          observacao: form.observacao,
          categorias_correcao: form.categorias,
          justificativa_ts: form.justificativa,
        },
        seguir,
      );
      if (!seguir) {
        // o painel não é recriado ao salvar: o formulário passa a refletir o que foi gravado
        setForm((f) => ({ ...f, status: (status ?? f.status) as typeof f.status }));
        setOk(`Salvo às ${new Date().toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}.`);
      }
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setSalvando(false);
    }
  }

  function alternarCategoria(c: string) {
    setForm((f) => ({ ...f, categorias: f.categorias.includes(c) ? f.categorias.filter((x) => x !== c) : [...f.categorias, c] }));
  }

  async function decidir(c: Correcao, aprovar: boolean, ajustes: Partial<Correcao> = {}) {
    setErro("");
    try {
      await api.post(`/api/correcoes/${c.id}/decisao`, { aprovar, ...ajustes });
      aoMudarCorrecoes();
    } catch (e) {
      setErro((e as Error).message);
    }
  }

  return (
    <div className="flex flex-col">
      <section className="border-b border-borda px-3 py-2.5">
        <h2 className="mb-2 text-xs font-semibold uppercase tracking-wide text-texto-suave">Decisão</h2>
        <div className="flex flex-col gap-2.5">
          <div className="grid grid-cols-3 gap-2">
            <Botao variante="perigo" carregando={salvando} title="Marca como errada" onClick={() => salvar("errada", avancar)}>
              Errada
            </Botao>
            <Botao carregando={salvando} title="Marca como correta" onClick={() => salvar("correta", avancar)}>
              Correta
            </Botao>
            <Botao variante="discreto" carregando={salvando} title="Tira da análise" onClick={() => salvar("ignorada", avancar)}>
              Ignorar
            </Botao>
          </div>
          <label className="flex items-center gap-2 text-xs text-texto-suave">
            <input
              type="checkbox"
              checked={avancar}
              onChange={(e) => {
                setAvancar(e.target.checked);
                try {
                  localStorage.setItem(CHAVE_AVANCAR, e.target.checked ? "1" : "0");
                } catch {
                  /* sem armazenamento */
                }
              }}
            />
            Abrir a próxima OS ao decidir
          </label>
          <div>
            <div className="mb-1 text-xs text-texto-suave">O que foi corrigido</div>
            <div className="flex flex-wrap gap-1.5">
              {Object.entries(categorias).map(([coluna, id]) => {
                const ativo = form.categorias.includes(id);
                return (
                  <button
                    key={id}
                    type="button"
                    aria-pressed={ativo}
                    onClick={() => alternarCategoria(id)}
                    className={`rounded-md border px-2 py-1 text-xs transition-colors duration-150 ${ativo ? "border-acao bg-acao/20 text-ok-texto" : "border-borda text-texto-suave hover:text-texto"}`}
                  >
                    {coluna.replace(/^C_/, "")}
                  </button>
                );
              })}
            </div>
          </div>
          <Justificativa
            detalhe={detalhe}
            categorias={form.categorias}
            valor={form.justificativa}
            aoMudar={(v) => setForm((f) => ({ ...f, justificativa: v }))}
          />
          <div className="grid grid-cols-2 gap-2">
            <Selecao rotulo="Status" value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value as typeof form.status })}>
              {(config?.status_os ?? Object.keys(NOMES_STATUS)).map((s) => (
                <option key={s} value={s}>
                  {NOMES_STATUS[s]}
                </option>
              ))}
            </Selecao>
            <Selecao rotulo="Responsável" value={form.responsavel} onChange={(e) => setForm({ ...form, responsavel: e.target.value })}>
              <option value="">—</option>
              {(config?.responsaveis ?? []).map((s) => (
                <option key={s}>{s}</option>
              ))}
            </Selecao>
          </div>
          <CampoTexto rotulo="Observação" multilinha valor={form.observacao} aoMudar={(v) => setForm({ ...form, observacao: v })} />
          <div className="flex items-center gap-2">
            <Botao variante="primario" carregando={salvando} onClick={() => salvar()}>
              Salvar
            </Botao>
            <Botao carregando={salvando} onClick={() => salvar(undefined, true)}>
              Salvar e próxima
            </Botao>
          </div>
          {ok && (
            <span role="status" className="text-xs text-ok-texto">
              {ok}
            </span>
          )}
          {!usuario && <span className="text-xs text-pendente-texto">Escolha o analista no topo da página.</span>}
          <Aviso>{erro}</Aviso>
          {r.analista && (
            <p className="text-xs text-texto-suave">
              Última alteração: {r.analista} · {dataHora(r.atualizado_em)}
            </p>
          )}
        </div>
      </section>

      <section className="px-3 py-2.5">
        <h2 className="mb-2 text-xs font-semibold uppercase tracking-wide text-texto-suave">Correções ({detalhe.correcoes.length})</h2>
        <div className="flex flex-col gap-2">
          {detalhe.correcoes.map((c) => (
            <ItemCorrecao key={c.id} c={c} nomeTipo={tiposCorrecao[c.tipo]?.nome ?? c.tipo} aoDecidir={decidir} />
          ))}
          <NovaCorrecao osId={r.id} aoCriar={aoMudarCorrecoes} />
        </div>
      </section>
    </div>
  );
}

const SUGESTOES_VISIVEIS = 4;

/** Texto que vai no campo "Justificativa" do TS: sugerido pelas categorias marcadas, pelas correções
 * da OS e pelo LLM; o analista escolhe e completa (ex.: número da intervenção). */
function Justificativa({
  detalhe,
  categorias,
  valor,
  aoMudar,
}: {
  detalhe: DetalheOS;
  categorias: string[];
  valor: string;
  aoMudar: (v: string) => void;
}) {
  const { textosPadrao, tiposCorrecao } = useEstado();
  const [termo, setTermo] = useState("");
  const [todos, setTodos] = useState(false);
  const textoLLM = detalhe.analises[0]?.resposta?.justificativa_padrao_texto ?? null;

  const efetivas = useMemo(() => {
    // as categorias marcadas e as das correções ainda válidas da OS
    const s = new Set(categorias);
    for (const c of detalhe.correcoes) {
      const cat = tiposCorrecao[c.tipo]?.categoria_access;
      if (cat && c.status !== "rejeitada") s.add(cat);
    }
    return [...s];
  }, [categorias, detalhe.correcoes, tiposCorrecao]);

  const lista = useMemo(() => {
    const base = termo.trim() ? buscar(textosPadrao, termo) : sugerir(textosPadrao, efetivas);
    return textoLLM && !termo.trim() ? base.filter((t) => t.texto !== textoLLM) : base;
  }, [textosPadrao, termo, efetivas, textoLLM]);
  const visiveis = todos || termo.trim() ? lista : lista.slice(0, SUGESTOES_VISIVEIS);
  const falta = pendencias(valor);

  if (!textosPadrao.length) {
    return (
      <div className="text-xs text-texto-suave">
        Justificativa no TS: nenhum texto padrão carregado (tela Textos).
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor="justificativa-ts" className="text-xs text-texto-suave">
        Justificativa no TS
      </label>
      <textarea
        id="justificativa-ts"
        className="min-h-14 rounded-md border border-borda bg-cartao px-2 py-1.5 text-xs text-texto placeholder:text-texto-suave/60 hover:border-texto-suave"
        value={valor}
        placeholder="Escolha um texto padrão"
        onChange={(e) => aoMudar(e.target.value)}
      />
      {falta.length > 0 && <p className="text-xs text-pendente-texto">Complete {falta.join(" e ")}.</p>}
      <input
        aria-label="Buscar texto padrão"
        className="h-7 rounded-md border border-borda bg-cartao px-2 text-xs text-texto placeholder:text-texto-suave/60 hover:border-texto-suave"
        placeholder={efetivas.length ? "Buscar outro texto" : "Marque o que foi corrigido ou busque um texto"}
        value={termo}
        onChange={(e) => setTermo(e.target.value)}
      />
      <div className={`flex flex-col gap-1 ${todos || termo.trim() ? "max-h-64 overflow-auto pr-0.5" : ""}`}>
        {textoLLM && !termo.trim() && <OpcaoTexto texto={textoLLM} marca="LLM" escolhido={valor === textoLLM} aoEscolher={aoMudar} />}
        {visiveis.map((t: TextoPadrao) => (
          <OpcaoTexto key={t.id} texto={t.texto} escolhido={valor === t.texto} aoEscolher={aoMudar} />
        ))}
        {termo.trim() && !lista.length && <span className="text-xs text-texto-suave">Nenhum texto com essa busca.</span>}
      </div>
      {!termo.trim() && lista.length > SUGESTOES_VISIVEIS && (
        <button type="button" className="self-start text-xs text-texto-suave underline-offset-2 hover:text-texto hover:underline" onClick={() => setTodos(!todos)}>
          {todos ? "Mostrar menos" : `Mostrar os ${lista.length} textos dessas categorias`}
        </button>
      )}
    </div>
  );
}

function OpcaoTexto({ texto, marca, escolhido, aoEscolher }: { texto: string; marca?: string; escolhido: boolean; aoEscolher: (t: string) => void }) {
  return (
    <button
      type="button"
      title={texto}
      aria-pressed={escolhido}
      onClick={() => aoEscolher(texto)}
      className={`flex items-start gap-1.5 rounded-md border px-2 py-1 text-left text-xs transition-colors duration-150 ${escolhido ? "border-acao bg-acao/15 text-texto" : "border-borda text-texto-suave hover:border-texto-suave hover:text-texto"}`}
    >
      {marca && <Etiqueta cor="azul">{marca}</Etiqueta>}
      <span className="line-clamp-2">{texto}</span>
    </button>
  );
}

function ItemCorrecao({ c, nomeTipo, aoDecidir }: { c: Correcao; nomeTipo: string; aoDecidir: (c: Correcao, aprovar: boolean, ajustes?: Partial<Correcao>) => void }) {
  const [editando, setEditando] = useState(false);
  const [novo, setNovo] = useState(c.valor_novo ?? "");
  const editavel = ["proposta", "rejeitada", "erro"].includes(c.status);
  return (
    <div className="rounded-md border border-borda p-2 text-sm">
      <div className="flex flex-wrap items-center gap-2">
        <span className="font-medium">{nomeTipo}</span>
        <EtiquetaCorrecao status={c.status} />
        <span className="text-xs text-texto-suave">{c.origem === "llm" ? "LLM" : "analista"}</span>
      </div>
      <div className="num mt-1 text-xs">
        {c.campo}
        {c.alvo ? ` · ${c.alvo}` : ""}: {c.valor_atual ?? "—"} → {editando ? "…" : c.valor_novo ?? "—"}
      </div>
      {editando && (
        <div className="mt-2">
          <CampoTexto rotulo="Valor novo" valor={novo} aoMudar={setNovo} />
        </div>
      )}
      {c.justificativa && <p className="mt-1 text-xs text-texto-suave">{c.justificativa}</p>}
      {c.resultado_robo && <p className="mt-1 text-xs">Robô: {c.resultado_robo}</p>}
      {editavel && (
        <div className="mt-2 flex flex-wrap gap-2">
          <Botao variante="primario" className="h-7 px-2" onClick={() => aoDecidir(c, true, editando ? { valor_novo: novo } : {})}>
            Aprovar
          </Botao>
          {c.status !== "rejeitada" && (
            <Botao variante="perigo" className="h-7 px-2" onClick={() => aoDecidir(c, false)}>
              Rejeitar
            </Botao>
          )}
          <Botao variante="discreto" className="h-7 px-2" onClick={() => setEditando(!editando)}>
            {editando ? "Cancelar" : "Editar"}
          </Botao>
        </div>
      )}
    </div>
  );
}

function NovaCorrecao({ osId, aoCriar }: { osId: number; aoCriar: () => void }) {
  const { tiposCorrecao } = useEstado();
  const [aberta, setAberta] = useState(false);
  const [f, setF] = useState({ tipo: "", campo: "", alvo: "", valor_atual: "", valor_novo: "", justificativa: "" });
  const [erro, setErro] = useState("");
  const tipo = tiposCorrecao[f.tipo];

  async function criar() {
    setErro("");
    try {
      await api.post(`/api/os/${osId}/correcoes`, { ...f, campo: f.campo || tipo?.campos[0] || null, aprovar: true });
      setAberta(false);
      setF({ tipo: "", campo: "", alvo: "", valor_atual: "", valor_novo: "", justificativa: "" });
      aoCriar();
    } catch (e) {
      setErro((e as Error).message);
    }
  }

  if (!aberta) {
    return (
      <div>
        <Botao onClick={() => setAberta(true)}>Nova correção</Botao>
      </div>
    );
  }
  return (
    <div className="flex flex-col gap-2 rounded-md border border-borda p-2">
      <Selecao rotulo="Tipo" value={f.tipo} onChange={(e) => setF({ ...f, tipo: e.target.value, campo: "" })}>
        <option value="">escolha</option>
        {Object.entries(tiposCorrecao).map(([k, t]) => (
          <option key={k} value={k}>
            {t.nome}
          </option>
        ))}
      </Selecao>
      {tipo && (
        <>
          <Selecao rotulo="Campo" value={f.campo || tipo.campos[0]} onChange={(e) => setF({ ...f, campo: e.target.value })}>
            {tipo.campos.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </Selecao>
          {tipo.alvo && <CampoTexto rotulo={`Alvo (${tipo.alvo})`} valor={f.alvo} aoMudar={(v) => setF({ ...f, alvo: v })} />}
          <div className="grid grid-cols-2 gap-2">
            <CampoTexto rotulo="Valor atual" valor={f.valor_atual} aoMudar={(v) => setF({ ...f, valor_atual: v })} placeholder={tipo.formato} />
            <CampoTexto rotulo="Valor novo" valor={f.valor_novo} aoMudar={(v) => setF({ ...f, valor_novo: v })} placeholder={tipo.formato} />
          </div>
          <CampoTexto rotulo="Justificativa" multilinha valor={f.justificativa} aoMudar={(v) => setF({ ...f, justificativa: v })} />
        </>
      )}
      <Aviso>{erro}</Aviso>
      <div className="flex gap-2">
        <Botao variante="primario" disabled={!f.tipo} onClick={criar}>
          Criar e aprovar
        </Botao>
        <Botao variante="discreto" onClick={() => setAberta(false)}>
          Cancelar
        </Botao>
      </div>
    </div>
  );
}
