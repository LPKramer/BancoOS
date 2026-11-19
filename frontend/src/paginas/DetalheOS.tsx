import { useCallback, useEffect, useMemo, useState, type ReactNode } from "react";
import { Link, useNavigate, useParams, useSearchParams } from "react-router-dom";
import { api, consulta, ErroApi } from "../api";
import { buscarDetalhe, buscarManobra, esquecerDetalhe, preCarregar } from "../cache";
import Achados from "../componentes/Achados";
import Decisao, { type CamposDecisao } from "../componentes/Decisao";
import LinhaDoTempo from "../componentes/LinhaDoTempo";
import { LimiteErro } from "../componentes/LimiteErro";
import Mapa from "../componentes/Mapa";
import { Aviso, Botao, Carregando, Etiqueta, EtiquetaStatus, TabelaRegistros } from "../componentes/ui";
import { useEstado } from "../estado";
import { NOMES_CATEGORIA, NOMES_CONCLUSAO, dataHora, dec, int, rs, valor } from "../formatos";
import { curta } from "../manobraUtil";
import type { DetalheOS as TDetalhe, EstadoBDGD, Manobra, PassoManobra } from "../tipos";
import { FILTROS } from "./Fila";

type EstadoManobra = "carregando" | "ok" | "sem_indice" | "erro" | "nao_se_aplica";

function picoDe(m: Manobra | null): number | null {
  if (!m?.disponivel) return null;
  const p = m.passos.reduce<PassoManobra | null>((a, x) => (x.ucs_desligadas != null && (!a || x.ucs_desligadas > (a.ucs_desligadas ?? 0)) ? x : a), null);
  return p ? p.ordem : null;
}

export default function DetalheOS() {
  const { id } = useParams();
  const osId = Number(id);
  const [params] = useSearchParams();
  const navegar = useNavigate();
  const { usuario } = useEstado();
  const [d, setD] = useState<TDetalhe | null>(null);
  const [erro, setErro] = useState("");
  const [manobra, setManobra] = useState<Manobra | null>(null);
  const [estadoManobra, setEstadoManobra] = useState<EstadoManobra>("carregando");
  const [bdgd, setBdgd] = useState<EstadoBDGD | null>(null);
  const [vizinhas, setVizinhas] = useState<{ anterior: number | null; proxima: number | null; posicao: number | null; total: number } | null>(null);
  const [ordemPasso, setOrdemPasso] = useState<number | null>(null);
  const [destaqueOS, setDestaqueOS] = useState<string | null>(null);
  const [analisando, setAnalisando] = useState(false);
  const [erroLLM, setErroLLM] = useState("");

  const filtros = useMemo(() => Object.fromEntries(FILTROS.map((f) => [f, params.get(f) ?? ""])), [params]);
  const qs = consulta(filtros);

  const carregarManobra = useCallback(async (id: number, forcar = false, vivo: () => boolean = () => true) => {
    setEstadoManobra("carregando");
    try {
      const m = await buscarManobra(id, forcar);
      if (!vivo()) return;
      setManobra(m);
      setOrdemPasso(picoDe(m));
      setEstadoManobra("ok");
    } catch (e) {
      if (!vivo()) return;
      if (e instanceof ErroApi && e.status === 400) setEstadoManobra("nao_se_aplica");
      else if (e instanceof ErroApi && e.status === 409) {
        setEstadoManobra("sem_indice");
        setBdgd(await api.get<EstadoBDGD>("/api/bdgd/status").catch(() => null));
      } else setEstadoManobra("erro");
    }
  }, []);

  const recarregar = useCallback(async () => {
    esquecerDetalhe(osId);
    const det = await buscarDetalhe(osId, true);
    setD(det);
    return det;
  }, [osId]);

  useEffect(() => {
    let vivo = true;
    setD(null);
    setManobra(null);
    setOrdemPasso(null);
    setDestaqueOS(null);
    setErro("");
    setErroLLM("");
    // detalhe e manobra em paralelo
    buscarDetalhe(osId)
      .then((det) => vivo && setD(det))
      .catch((e) => vivo && setErro(e.message));
    carregarManobra(osId, false, () => vivo);
    return () => {
      vivo = false;
    };
  }, [osId, carregarManobra]);

  useEffect(() => {
    api
      .get<typeof vizinhas>(`/api/os/${osId}/vizinhas${qs}`)
      .then((v) => {
        setVizinhas(v);
        preCarregar(v?.proxima, true); // a próxima já fica pronta (detalhe e mapa)
      })
      .catch(() => setVizinhas(null));
  }, [osId, qs]);

  // setas do teclado navegam entre as OS (fora de campos de texto)
  useEffect(() => {
    function tecla(e: KeyboardEvent) {
      const alvo = e.target as HTMLElement;
      if (["INPUT", "TEXTAREA", "SELECT"].includes(alvo.tagName) || alvo.isContentEditable || e.altKey || e.ctrlKey || e.metaKey) return;
      if (e.key === "ArrowRight" && vizinhas?.proxima) navegar(`/os/${vizinhas.proxima}${qs}`);
      if (e.key === "ArrowLeft" && vizinhas?.anterior) navegar(`/os/${vizinhas.anterior}${qs}`);
    }
    window.addEventListener("keydown", tecla);
    return () => window.removeEventListener("keydown", tecla);
  }, [vizinhas, qs, navegar]);

  useEffect(() => {
    if (estadoManobra !== "sem_indice" || bdgd?.situacao !== "construindo") return;
    const t = setInterval(async () => {
      const st = await api.get<EstadoBDGD>("/api/bdgd/status");
      setBdgd(st);
      if (st.pronto) carregarManobra(osId, true);
    }, 3000);
    return () => clearInterval(t);
  }, [estadoManobra, bdgd?.situacao, osId, carregarManobra]);

  async function salvar(campos: CamposDecisao, avancar: boolean) {
    await api.patch(`/api/os/${osId}`, { ...campos, analista: usuario || null });
    esquecerDetalhe(osId);
    if (avancar && vizinhas?.proxima) navegar(`/os/${vizinhas.proxima}${qs}`);
    else await recarregar();
  }

  async function analisar(forcar: boolean) {
    setAnalisando(true);
    setErroLLM("");
    try {
      await api.post(`/api/os/${osId}/analisar${forcar ? "?forcar=true" : ""}`);
      await recarregar();
    } catch (e) {
      setErroLLM((e as Error).message);
    } finally {
      setAnalisando(false);
    }
  }

  if (erro && !d) return <Aviso>{erro}</Aviso>;
  if (!d) return <Carregando />;

  const r = d.resumo;
  const reg = d.registro;
  const passo = manobra?.disponivel ? (manobra.passos.find((p) => p.ordem === ordemPasso) ?? null) : null;
  const selecionarPasso = (o: number | null) => {
    setOrdemPasso(o);
    setDestaqueOS(null);
  };

  return (
    <div className="flex flex-col gap-3">
      {/* Cabeçalho */}
      <div className="rounded-lg border border-borda bg-cartao px-3 py-2">
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
          <Link to={`/fila${qs}`} className="text-sm text-texto-suave hover:text-texto">
            Fila
          </Link>
          <h1 className="num text-base font-semibold">OS {r.os}</h1>
          <EtiquetaStatus status={r.status} />
          {r.tipo_os !== "intervencao" && <Etiqueta>individual</Etiqueta>}
          {r.access_corrigida && (
            <Etiqueta cor="azul" titulo="Marcada como corrigida no Banco de Análise (Access)">
              corrigida no Access{r.access_categorias?.length ? `: ${r.access_categorias.map((c) => NOMES_CATEGORIA[c] ?? c).join(", ")}` : ""}
            </Etiqueta>
          )}
          <div className="ml-auto flex items-center gap-1 text-sm text-texto-suave">
            {vizinhas?.posicao && (
              <span className="num mr-1">
                {vizinhas.posicao} de {vizinhas.total}
              </span>
            )}
            <Botao variante="discreto" disabled={!vizinhas?.anterior} title="Seta para a esquerda" onClick={() => navegar(`/os/${vizinhas!.anterior}${qs}`)}>
              Anterior
            </Botao>
            <Botao variante="discreto" disabled={!vizinhas?.proxima} title="Seta para a direita" onClick={() => navegar(`/os/${vizinhas!.proxima}${qs}`)}>
              Próxima
            </Botao>
          </div>
        </div>
        <dl className="mt-1.5 flex flex-wrap gap-x-5 gap-y-1 text-sm">
          <Fato rotulo="Local">
            {r.localidade ?? "—"}
            {r.coec ? ` · ${r.coec}` : ""}
          </Fato>
          <Fato rotulo="Compensação">
            <span className="num">{rs(r.multa)}</span>
          </Fato>
          <Fato rotulo="Conclusão">{r.conclusao ? (NOMES_CONCLUSAO[r.conclusao] ?? r.conclusao) : "—"}</Fato>
          <Fato rotulo="Causa">
            <span className="num text-texto-suave">{r.cod_causa}</span> {r.causa ?? "—"} /{" "}
            <span className="num text-texto-suave">{r.cod_subcausa}</span> {r.subcausa ?? "—"}
          </Fato>
          <Fato rotulo="Início · fim">
            <span className="num">
              {dataHora(r.inicio)} · {dataHora(r.fim)}
            </span>
          </Fato>
          <Fato rotulo="TMA · DEC">
            <span className="num">
              {int(r.tma)} · {dec(r.dec)}
            </span>
          </Fato>
          {r.tipo_os === "intervencao" && (
            <>
              <Fato rotulo="Elemento">
                <span className="num">
                  {valor(reg.COD_ELE_MNB)} {valor(reg.COD_INS_SEC_INS)}
                </span>
              </Fato>
              <Fato rotulo="TR">{valor(reg.TIPO_TR)}</Fato>
              <Fato rotulo="Vinculadas">
                <span className="num">{int(d.vinculadas.length)}</span>
              </Fato>
            </>
          )}
        </dl>
        {(reg.DES_INTV_MNB || reg.DES_OBS_EXEC_SERV_CNR) && (
          <p className="mt-1 line-clamp-2 text-xs text-texto-suave" title={String(reg.DES_INTV_MNB ?? reg.DES_OBS_EXEC_SERV_CNR)}>
            {String(reg.DES_INTV_MNB ?? reg.DES_OBS_EXEC_SERV_CNR)}
          </p>
        )}
      </div>

      {/* Área de trabalho: achados | mapa + linha do tempo | decisão */}
      <div className="grid gap-3 xl:h-[calc(100vh-190px)] xl:min-h-[640px] xl:grid-cols-[minmax(280px,340px)_minmax(0,1fr)_minmax(280px,330px)]">
        <aside className="order-2 overflow-auto rounded-lg border border-borda bg-cartao xl:order-1">
          <Achados
            detalhe={d}
            manobra={manobra}
            estadoManobra={estadoManobra}
            analisando={analisando}
            erroLLM={erroLLM}
            ordemPasso={ordemPasso}
            aoAnalisar={analisar}
            aoPasso={selecionarPasso}
            aoOS={(os) => {
              setDestaqueOS(os);
            }}
          />
        </aside>

        <main className="order-1 flex min-h-0 flex-col gap-3 xl:order-2">
          <div className="flex min-h-0 flex-col rounded-lg border border-borda bg-cartao p-2 xl:basis-[58%]">
            {estadoManobra === "ok" && manobra?.disponivel ? (
              <LimiteErro titulo="Falha ao desenhar o mapa">
                <Mapa dados={manobra} passo={passo} destaqueOS={destaqueOS} className="h-[420px] xl:h-auto xl:min-h-0 xl:flex-1" />
              </LimiteErro>
            ) : (
              <EstadoMapa estado={estadoManobra} manobra={manobra} bdgd={bdgd} aoPreparar={async () => setBdgd(await api.post<EstadoBDGD>("/api/bdgd/indexar"))} />
            )}
          </div>
          <div className="flex min-h-[260px] flex-col overflow-hidden rounded-lg border border-borda bg-cartao xl:min-h-0 xl:flex-1">
            <div className="flex items-center gap-2 border-b border-borda px-3 py-1.5 text-sm">
              <h2 className="text-xs font-semibold uppercase tracking-wide text-texto-suave">Linha do tempo</h2>
              <span role="status" className="ml-auto truncate text-xs text-texto-suave">
                {passo
                  ? `Mapa no passo ${curta(passo.data)} ${passo.oper} ${passo.cod_ts}: ${int(passo.ucs_desligadas)} UCs sem energia`
                  : manobra?.disponivel
                    ? "Mapa no estado normal"
                    : ""}
              </span>
              {passo && (
                <Botao variante="discreto" className="h-6 px-2 text-xs" onClick={() => selecionarPasso(null)}>
                  Estado normal
                </Botao>
              )}
            </div>
            <LinhaDoTempo detalhe={d} manobra={manobra} ordemPasso={ordemPasso} destaqueOS={destaqueOS} aoPasso={selecionarPasso} aoOS={setDestaqueOS} />
          </div>
        </main>

        <aside className="order-3 overflow-auto rounded-lg border border-borda bg-cartao">
          <Decisao key={r.id} detalhe={d} aoSalvar={salvar} aoMudarCorrecoes={recarregar} />
        </aside>
      </div>

      <details className="rounded-lg border border-borda bg-cartao">
        <summary className="px-3 py-2 text-sm text-texto-suave hover:text-texto">Dados completos da OS</summary>
        <div className="flex flex-col gap-3 px-3 pb-3">
          <dl className="grid grid-cols-2 gap-x-4 gap-y-1 text-xs md:grid-cols-4 xl:grid-cols-6">
            {Object.entries(reg).map(([k, v]) => (
              <div key={k} className="min-w-0">
                <dt className="truncate text-texto-suave">{k}</dt>
                <dd className="num truncate" title={v == null ? "" : String(v)}>
                  {valor(v)}
                </dd>
              </div>
            ))}
          </dl>
          {d.equipe.length > 0 && (
            <TabelaRegistros
              linhas={d.equipe}
              colunas={[
                { chave: "EQUIPE", titulo: "Equipe" },
                { chave: "COD_MATERIAL", titulo: "Material" },
                { chave: "DESCRIÇÃO", titulo: "Descrição" },
                { chave: "QUANTIDADE", titulo: "Qtd.", numero: true },
                { chave: "KM_INICIO", titulo: "Km início", numero: true },
                { chave: "KM_FIM", titulo: "Km fim", numero: true },
              ]}
            />
          )}
        </div>
      </details>
    </div>
  );
}

function Fato({ rotulo, children }: { rotulo: string; children: ReactNode }) {
  return (
    <div className="flex items-baseline gap-1.5">
      <dt className="text-xs text-texto-suave">{rotulo}</dt>
      <dd>{children}</dd>
    </div>
  );
}

function EstadoMapa({ estado, manobra, bdgd, aoPreparar }: { estado: EstadoManobra; manobra: Manobra | null; bdgd: EstadoBDGD | null; aoPreparar: () => void }) {
  return (
    <div className="flex h-[200px] flex-col items-center justify-center gap-2 text-sm text-texto-suave xl:h-full">
      {estado === "carregando" && <span role="status">Simulando a manobra na BDGD…</span>}
      {estado === "nao_se_aplica" && <span>OS individual: sem manobra para desenhar.</span>}
      {estado === "erro" && <span className="text-erro-texto">Falha ao simular a manobra.</span>}
      {estado === "ok" && manobra && !manobra.disponivel && <span>{manobra.motivo}</span>}
      {estado === "sem_indice" && (
        <>
          <span>BDGD não preparada neste servidor{bdgd?.pasta_bdgd ? ` (${bdgd.pasta_bdgd})` : ""}.</span>
          {bdgd?.situacao === "construindo" ? (
            <span role="status">Preparando: {bdgd.etapa}…</span>
          ) : (
            <Botao onClick={aoPreparar} disabled={!bdgd?.pasta_bdgd}>
              Preparar BDGD
            </Botao>
          )}
          {bdgd?.erro && <Aviso>{bdgd.erro}</Aviso>}
        </>
      )}
    </div>
  );
}
