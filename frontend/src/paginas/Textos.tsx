import { useEffect, useMemo, useState } from "react";
import { api } from "../api";
import CampoFonte from "../componentes/CampoFonte";
import { Aviso, Botao, Cartao, Etiqueta, Selecao, Vazio } from "../componentes/ui";
import { useEstado } from "../estado";
import { CATEGORIAS, NOMES_CATEGORIA, int } from "../formatos";
import { semAcento } from "../justificativas";
import type { Fonte, TextoPadrao } from "../tipos";

interface Resumo {
  total: number;
  novos: number;
  atualizados: number;
  desativados: number;
  arquivo: string;
}

export default function Textos() {
  const { textosPadrao, definirTextos, usuario } = useEstado();
  const [fonte, setFonte] = useState<Fonte | null>(null);
  const [caminho, setCaminho] = useState("");
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [conferindo, setConferindo] = useState(false);
  const [carregando, setCarregando] = useState(false);
  const [resumo, setResumo] = useState<Resumo | null>(null);
  const [erro, setErro] = useState("");
  const [filtro, setFiltro] = useState("");
  const [busca, setBusca] = useState("");

  useEffect(() => {
    api
      .get<{ textos: TextoPadrao[]; fonte: Fonte }>("/api/textos-padrao")
      .then((r) => {
        definirTextos(r.textos);
        setFonte(r.fonte);
        setCaminho(r.fonte.caminho ?? "");
      })
      .catch((e) => setErro(e.message));
  }, [definirTextos]);

  async function conferir() {
    setErro("");
    setConferindo(true);
    try {
      setFonte(await api.put<Fonte>("/api/fontes/textos", { caminho }));
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setConferindo(false);
    }
  }

  async function carregar() {
    setErro("");
    setCarregando(true);
    try {
      const fd = new FormData();
      if (arquivo) fd.append("arquivo", arquivo);
      else fd.append("caminho", caminho.trim());
      const r = await api.post<{ resumo: Resumo; textos: TextoPadrao[]; fonte: Fonte }>("/api/textos-padrao/carregar", fd);
      definirTextos(r.textos);
      setFonte(r.fonte);
      setResumo(r.resumo);
      setArquivo(null);
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setCarregando(false);
    }
  }

  async function alternar(t: TextoPadrao, cat: string) {
    setErro("");
    const categorias = t.categorias.includes(cat) ? t.categorias.filter((c) => c !== cat) : [...t.categorias, cat];
    try {
      const novo = await api.patch<TextoPadrao>(`/api/textos-padrao/${t.id}`, { categorias });
      definirTextos(textosPadrao.map((x) => (x.id === novo.id ? novo : x)));
    } catch (e) {
      setErro((e as Error).message);
    }
  }

  const contagem = useMemo(() => {
    const c: Record<string, number> = { "": 0, sem: 0, inativos: 0 };
    for (const t of textosPadrao) {
      if (!t.ativo) {
        c.inativos++;
        continue;
      }
      c[""]++;
      if (!t.categorias.length) c.sem++;
      for (const cat of t.categorias) c[cat] = (c[cat] ?? 0) + 1;
    }
    return c;
  }, [textosPadrao]);

  const visiveis = useMemo(() => {
    const termo = semAcento(busca.trim());
    return textosPadrao.filter((t) => {
      if (filtro === "inativos" ? t.ativo : !t.ativo) return false;
      if (filtro === "sem" && t.categorias.length) return false;
      if (filtro && !["sem", "inativos"].includes(filtro) && !t.categorias.includes(filtro)) return false;
      return !termo || semAcento(t.texto).includes(termo);
    });
  }, [textosPadrao, filtro, busca]);

  return (
    <div className="flex flex-col gap-4">
      <Cartao titulo="Planilha de textos padrões">
        <div className="flex flex-col gap-3">
          <CampoFonte
            titulo="Textos padrões para correções"
            fonte={fonte}
            caminho={caminho}
            aoCaminho={setCaminho}
            arquivo={arquivo}
            aoArquivo={setArquivo}
            aoConferir={conferir}
            conferindo={conferindo}
            aceita=".xlsx,.xlsm"
            exemplo="C:\Bases\TEXTOS PADRÕES PARA CORREÇÕES AJUSTADO.xlsx"
          />
          <div className="flex flex-wrap items-center gap-3">
            <Botao variante="primario" disabled={!arquivo && !caminho.trim()} carregando={carregando} onClick={carregar}>
              {textosPadrao.length ? "Recarregar textos" : "Carregar textos"}
            </Botao>
            {resumo && (
              <span role="status" className="text-xs text-ok-texto">
                {resumo.total} textos de {resumo.arquivo}: {resumo.novos} novos, {resumo.atualizados} alterados, {resumo.desativados} fora da planilha
              </span>
            )}
          </div>
          <Aviso>{erro}</Aviso>
        </div>
      </Cartao>

      <Cartao
        titulo={`Textos em uso (${int(contagem[""])})`}
        acoes={
          <>
            <Selecao rotulo="Categoria" value={filtro} onChange={(e) => setFiltro(e.target.value)}>
              <option value="">todas ({contagem[""]})</option>
              {CATEGORIAS.map((c) => (
                <option key={c} value={c}>
                  {NOMES_CATEGORIA[c]} ({contagem[c] ?? 0})
                </option>
              ))}
              <option value="sem">sem categoria ({contagem.sem})</option>
              {contagem.inativos > 0 && <option value="inativos">fora da planilha ({contagem.inativos})</option>}
            </Selecao>
            <label className="flex flex-col gap-1 text-xs text-texto-suave">
              Buscar
              <input
                className="h-8 w-56 rounded-md border border-borda bg-cartao px-2 text-sm text-texto hover:border-texto-suave"
                value={busca}
                onChange={(e) => setBusca(e.target.value)}
              />
            </label>
          </>
        }
      >
        {!textosPadrao.length ? (
          <Vazio>Nenhum texto carregado.</Vazio>
        ) : !visiveis.length ? (
          <Vazio>Nenhum texto com esse filtro.</Vazio>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-borda text-left text-xs text-texto-suave">
                  <th className="w-10 px-2 py-1.5 text-right font-medium">Nº</th>
                  <th className="px-2 py-1.5 font-medium">Justificativa no TS</th>
                  <th className="px-2 py-1.5 font-medium xl:w-[470px]" title="Clique para ligar ou desligar. As categorias decidem quais textos a OS sugere.">
                    Categorias
                  </th>
                </tr>
              </thead>
              <tbody>
                {visiveis.map((t) => (
                  <tr key={t.id} className="border-b border-borda/50 align-top">
                    <td className="num px-2 py-1.5 text-right text-texto-suave">{t.ordem}</td>
                    <td className="px-2 py-1.5">
                      {t.texto}
                      {t.erro && <div className="text-xs text-texto-suave">Erro encontrado: {t.erro}</div>}
                    </td>
                    <td className="px-2 py-1.5">
                      <div className="flex flex-wrap gap-1 xl:flex-nowrap">
                        {CATEGORIAS.map((c) => {
                          const ativo = t.categorias.includes(c);
                          return (
                            <button
                              key={c}
                              type="button"
                              aria-pressed={ativo}
                              disabled={!usuario}
                              title={usuario ? undefined : "Escolha o analista no topo da página"}
                              onClick={() => alternar(t, c)}
                              className={`rounded border px-1.5 py-0.5 text-xs transition-colors duration-150 disabled:cursor-not-allowed ${ativo ? "border-acao bg-acao/20 text-ok-texto" : "border-borda text-texto-suave/70 hover:text-texto"}`}
                            >
                              {NOMES_CATEGORIA[c]}
                            </button>
                          );
                        })}
                        {t.categorias_manuais && <Etiqueta titulo="Categorias acertadas por um analista">manual</Etiqueta>}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Cartao>
    </div>
  );
}
