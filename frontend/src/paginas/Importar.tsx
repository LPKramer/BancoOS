import { useCallback, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../api";
import CampoFonte from "../componentes/CampoFonte";
import { Aviso, Botao, Cartao, CampoTexto, Vazio } from "../componentes/ui";
import { useEstado } from "../estado";
import { dataHora, int } from "../formatos";
import type { Fonte, Importacao } from "../tipos";

type TipoBase = "critica" | "ocorrencias";
const BASES: { tipo: TipoBase; titulo: string; exemplo: string }[] = [
  { tipo: "critica", titulo: "Crítica (Exportar Planilha)", exemplo: "C:\\Bases\\base-critica 03-11.xlsx" },
  { tipo: "ocorrencias", titulo: "Ocorrências (compensação)", exemplo: "C:\\Bases\\9 C_Ocorrências_Base_Imp- 31-10.xlsx" },
];

export default function Importar() {
  const { lotes, recarregarLotes, escolherLote, lote, recarregarAnalistas } = useEstado();
  const [fontes, setFontes] = useState<Record<string, Fonte>>({});
  const [caminhos, setCaminhos] = useState<Record<TipoBase, string>>({ critica: "", ocorrencias: "" });
  const [arquivos, setArquivos] = useState<Record<TipoBase, File | null>>({ critica: null, ocorrencias: null });
  const [conferindo, setConferindo] = useState<TipoBase | null>(null);
  const [importacao, setImportacao] = useState<Importacao | null>(null);
  const [erro, setErro] = useState("");
  const [enviando, setEnviando] = useState(false);
  const navegar = useNavigate();

  useEffect(() => {
    api
      .get<Record<string, Fonte>>("/api/fontes")
      .then((f) => {
        setFontes(f);
        setCaminhos({ critica: f.critica?.caminho ?? "", ocorrencias: f.ocorrencias?.caminho ?? "" });
      })
      .catch((e) => setErro(e.message));
  }, []);

  useEffect(() => {
    if (!importacao || importacao.situacao !== "rodando") return;
    const t = setInterval(async () => {
      try {
        const st = await api.get<Importacao>(`/api/importacoes/${importacao.id}`);
        setImportacao(st);
        if (st.situacao === "concluida" && st.lote_id) {
          await recarregarLotes();
          escolherLote(st.lote_id);
          recarregarAnalistas();
        }
      } catch (e) {
        setErro((e as Error).message);
      }
    }, 2000);
    return () => clearInterval(t);
  }, [importacao, recarregarLotes, escolherLote, recarregarAnalistas]);

  async function conferir(tipo: TipoBase) {
    setErro("");
    setConferindo(tipo);
    try {
      const f = await api.put<Fonte>(`/api/fontes/${tipo}`, { caminho: caminhos[tipo] });
      setFontes((atual) => ({ ...atual, [tipo]: f }));
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setConferindo(null);
    }
  }

  async function importar() {
    setErro("");
    setEnviando(true);
    try {
      const fd = new FormData();
      for (const { tipo } of BASES) {
        const arq = arquivos[tipo];
        if (arq) fd.append(`${tipo}_arquivo`, arq);
        else fd.append(`${tipo}_caminho`, caminhos[tipo].trim());
      }
      setImportacao(await api.post<Importacao>("/api/lotes/importar-bases", fd));
      setArquivos({ critica: null, ocorrencias: null });
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setEnviando(false);
    }
  }

  async function excluir(id: number) {
    if (!confirm(`Excluir o lote ${id}? As análises e correções desse lote também serão apagadas.`)) return;
    try {
      await api.delete(`/api/lotes/${id}`);
      await recarregarLotes();
    } catch (e) {
      setErro((e as Error).message);
    }
  }

  const rodando = importacao?.situacao === "rodando";
  const pronta = (t: TipoBase) => Boolean(arquivos[t] || caminhos[t].trim());
  const verif = (t: TipoBase) => (!arquivos[t] && fontes[t]?.verificacao?.caminho === caminhos[t].trim() ? fontes[t].verificacao : null);
  const recusada = BASES.some(({ tipo }) => verif(tipo)?.ok === false);
  const compCritica = verif("critica")?.competencia;
  const compOcorr = verif("ocorrencias")?.competencia;

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <Cartao titulo="Bases do mês" className="lg:col-span-2">
        <div className="flex flex-col gap-3">
          <div className="grid gap-3 lg:grid-cols-2">
            {BASES.map(({ tipo, titulo, exemplo }) => (
              <CampoFonte
                key={tipo}
                titulo={titulo}
                fonte={fontes[tipo] ?? null}
                caminho={caminhos[tipo]}
                aoCaminho={(v) => setCaminhos((c) => ({ ...c, [tipo]: v }))}
                arquivo={arquivos[tipo]}
                aoArquivo={(f) => setArquivos((a) => ({ ...a, [tipo]: f }))}
                aoConferir={() => conferir(tipo)}
                conferindo={conferindo === tipo}
                exemplo={exemplo}
              />
            ))}
          </div>
          {compCritica && compOcorr && compCritica !== compOcorr && (
            <Aviso tipo="info">
              Competências diferentes: crítica {compCritica}, ocorrências {compOcorr}.
            </Aviso>
          )}
          <div className="flex items-center gap-3">
            <Botao
              variante="primario"
              disabled={!pronta("critica") || !pronta("ocorrencias") || recusada || rodando}
              carregando={enviando}
              onClick={importar}
            >
              Importar as duas bases
            </Botao>
            {(!pronta("critica") || !pronta("ocorrencias")) && <span className="text-xs text-texto-suave">Aponte a crítica e as ocorrências.</span>}
          </div>
        </div>
      </Cartao>

      <div className="flex flex-col gap-2 lg:col-span-2">
        <Aviso>{erro}</Aviso>
        {importacao && (
          <Aviso tipo={importacao.situacao === "erro" ? "erro" : importacao.situacao === "concluida" ? "ok" : "info"}>
            {importacao.situacao === "rodando" && `Importando ${importacao.arquivos.join(" + ")} e aplicando as regras…`}
            {importacao.situacao === "erro" && `Falha na importação: ${importacao.mensagem}`}
            {importacao.situacao === "concluida" && (
              <span>
                Lote {importacao.lote_id} importado.{" "}
                <button className="underline" onClick={() => navegar("/")}>
                  Abrir painel
                </button>
              </span>
            )}
          </Aviso>
        )}
      </div>

      <Cartao titulo="Lotes" className="lg:col-span-2">
        {lotes.length === 0 ? (
          <Vazio>Nenhum lote importado.</Vazio>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-borda text-left text-xs text-texto-suave">
                  <th className="px-2 py-1.5 font-medium">Lote</th>
                  <th className="px-2 py-1.5 font-medium">Competência</th>
                  <th className="px-2 py-1.5 font-medium">Origem</th>
                  <th className="px-2 py-1.5 text-right font-medium">Intervenções</th>
                  <th className="px-2 py-1.5 text-right font-medium">Na fila</th>
                  <th className="px-2 py-1.5 font-medium">Importado</th>
                  <th className="px-2 py-1.5" />
                </tr>
              </thead>
              <tbody>
                {lotes.map((l) => (
                  <tr key={l.id} className={`border-b border-borda/50 ${lote?.id === l.id ? "bg-suave" : ""}`}>
                    <td className="num px-2 py-1.5">{l.id}</td>
                    <td className="num px-2 py-1.5">{l.competencia ?? "—"}</td>
                    <td className="px-2 py-1.5" title={l.origem}>
                      {l.nome_origem}
                    </td>
                    <td className="num px-2 py-1.5 text-right">{int(l.contagens?.intervencao)}</td>
                    <td className="num px-2 py-1.5 text-right">{int(l.fila)}</td>
                    <td className="px-2 py-1.5">
                      {dataHora(l.criado_em)} {l.criado_por && `· ${l.criado_por}`}
                    </td>
                    <td className="px-2 py-1.5 text-right">
                      <div className="flex justify-end gap-2">
                        <Botao
                          variante="discreto"
                          onClick={() => {
                            escolherLote(l.id);
                            navegar("/");
                          }}
                        >
                          Usar
                        </Botao>
                        <Botao variante="perigo" onClick={() => excluir(l.id)}>
                          Excluir
                        </Botao>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Cartao>

      <BancoAccess rodando={rodando} aoIniciar={setImportacao} aoErro={setErro} />
    </div>
  );
}

/** Alternativa: o Banco de Análise do Access (traz o histórico de correções, usado como gabarito). */
function BancoAccess({ rodando, aoIniciar, aoErro }: { rodando: boolean; aoIniciar: (i: Importacao) => void; aoErro: (m: string) => void }) {
  const [caminho, setCaminho] = useState("");
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [enviando, setEnviando] = useState(false);
  const entrada = useRef<HTMLInputElement>(null);

  const importar = useCallback(async () => {
    aoErro("");
    setEnviando(true);
    try {
      if (arquivo) {
        const fd = new FormData();
        fd.append("arquivos", arquivo);
        aoIniciar(await api.post<Importacao>("/api/lotes/upload", fd));
        setArquivo(null);
        if (entrada.current) entrada.current.value = "";
      } else {
        aoIniciar(await api.post<Importacao>("/api/lotes/caminho", { caminhos: [caminho.trim()] }));
      }
    } catch (e) {
      aoErro((e as Error).message);
    } finally {
      setEnviando(false);
    }
  }, [arquivo, caminho, aoIniciar, aoErro]);

  return (
    <details className="rounded-lg border border-borda bg-cartao lg:col-span-2">
      <summary className="px-3 py-2 text-sm text-texto-suave hover:text-texto">Importar do Banco de Análise (Access)</summary>
      <div className="flex flex-wrap items-end gap-2 px-3 pb-3">
        {arquivo ? (
          <span className="num text-sm">{arquivo.name}</span>
        ) : (
          <CampoTexto className="min-w-0 flex-1 basis-72" rotulo="Caminho do .accdb no servidor" valor={caminho} aoMudar={setCaminho} />
        )}
        <Botao variante="discreto" onClick={() => entrada.current?.click()}>
          Enviar arquivo
        </Botao>
        <input
          ref={entrada}
          type="file"
          accept=".accdb,.mdb"
          className="sr-only"
          tabIndex={-1}
          aria-label="Arquivo do Banco de Análise"
          onChange={(e) => setArquivo(e.target.files?.[0] ?? null)}
        />
        <Botao variante="primario" disabled={(!arquivo && !caminho.trim()) || rodando} carregando={enviando} onClick={importar}>
          Importar
        </Botao>
      </div>
    </details>
  );
}
