import { useCallback, useEffect, useState } from "react";
import { api } from "../api";
import { Aviso, Botao, Cartao, Carregando, Etiqueta } from "../componentes/ui";
import { useEstado } from "../estado";
import type { EstadoRobo } from "../tipos";

function Item({ ok, rotulo, detalhe, acao }: { ok: boolean; rotulo: string; detalhe?: string | null; acao?: React.ReactNode }) {
  return (
    <li className="flex flex-wrap items-center gap-2 py-1.5">
      <Etiqueta cor={ok ? "verde" : "ambar"}>{ok ? "ok" : "falta"}</Etiqueta>
      <span className="text-sm">{rotulo}</span>
      {detalhe && <span className="num truncate text-xs text-texto-suave">{detalhe}</span>}
      {acao && <span className="ml-auto">{acao}</span>}
    </li>
  );
}

export default function Robo() {
  const { usuario } = useEstado();
  const [estado, setEstado] = useState<EstadoRobo | null>(null);
  const [erro, setErro] = useState("");
  const [diag, setDiag] = useState<string>("");
  const [modoTeste, setModoTeste] = useState(true);
  const [ocupado, setOcupado] = useState(false);

  const carregar = useCallback(() => {
    api.get<EstadoRobo>("/api/robo/status").then(setEstado).catch((e) => setErro(e.message));
  }, []);
  useEffect(carregar, [carregar]);
  useEffect(() => {
    if (!estado?.execucao.rodando) return;
    const t = setInterval(carregar, 1500);
    return () => clearInterval(t);
  }, [estado?.execucao.rodando, carregar]);

  async function acao(fn: () => Promise<unknown>) {
    setErro("");
    setOcupado(true);
    try {
      await fn();
      carregar();
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setOcupado(false);
    }
  }

  if (!estado) return erro ? <Aviso>{erro}</Aviso> : <Carregando />;
  const a = estado.ambiente;
  const e = estado.execucao;
  const pronto = Boolean(a.dll && a.acessibilidade_java && a.biblioteca_jab && a.jnlp && a.credencial_ts);

  return (
    <div className="grid gap-4 xl:grid-cols-3">
      <Cartao titulo="Ambiente do TS">
        <ul className="divide-y divide-borda/60">
          <Item ok={Boolean(a.dll)} rotulo="Java Access Bridge (dll 64 bits)" detalhe={a.dll} />
          <Item
            ok={a.acessibilidade_java}
            rotulo="Acessibilidade do Java ligada"
            acao={
              !a.acessibilidade_java && (
                <Botao
                  carregando={ocupado}
                  onClick={() => confirm("Ligar a acessibilidade do Java para este usuário do Windows? Vale para TS abertos depois disso.") && acao(() => api.post("/api/robo/ativar-acessibilidade"))}
                >
                  Ligar
                </Botao>
              )
            }
          />
          <Item ok={a.biblioteca_jab} rotulo="Biblioteca java-access-bridge-wrapper" detalhe={a.biblioteca_jab ? null : "pip install java-access-bridge-wrapper"} />
          <Item ok={Boolean(a.jnlp)} rotulo="Atalho do TS (jnlp)" detalhe={a.jnlp} />
          <Item ok={a.credencial_ts} rotulo="Usuário e senha do TS no Cofre do Windows" detalhe={a.credencial_ts ? null : "python -m osanalise.robot.credencial"} />
          <Item ok={a.janelas_ts.length > 0} rotulo="TS aberto" detalhe={a.janelas_ts.map((j) => `${j.titulo} (pid ${j.pid})`).join("; ") || null} />
        </ul>
        <div className="mt-3 flex gap-2">
          <Botao variante="discreto" onClick={carregar}>
            Verificar de novo
          </Botao>
          <Botao
            disabled={!a.janelas_ts.length || !a.biblioteca_jab}
            carregando={ocupado}
            title="Grava a árvore de componentes da tela aberta no TS, para mapear telas novas"
            onClick={() =>
              acao(async () => {
                const r = await api.post<{ arquivo: string; linhas: number }>("/api/robo/diagnostico");
                setDiag(`${r.linhas} linhas gravadas em ${r.arquivo}`);
              })
            }
          >
            Diagnóstico do TS
          </Botao>
        </div>
        {diag && (
          <p role="status" className="mt-2 text-xs text-texto-suave">
            {diag}
          </p>
        )}
      </Cartao>

      <Cartao titulo="Executar correções aprovadas" className="xl:col-span-2">
        <div className="flex flex-col gap-3">
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={modoTeste} onChange={(ev) => setModoTeste(ev.target.checked)} />
            Modo teste: abre o TS, pesquisa cada OS e confere os dados, sem salvar
          </label>
          <div className="flex flex-wrap items-center gap-2">
            <Botao
              variante={modoTeste ? "secundario" : "primario"}
              disabled={!pronto || e.rodando || !usuario}
              carregando={ocupado}
              onClick={() =>
                (modoTeste || confirm("Rodar de verdade? O robô vai alterar e salvar as OS no TS.")) &&
                acao(() => api.post("/api/robo/executar", { modo_teste: modoTeste }))
              }
            >
              {modoTeste ? "Rodar teste" : "Executar no TS"}
            </Botao>
            {e.rodando && (
              <Botao variante="perigo" onClick={() => acao(() => api.post("/api/robo/parar"))}>
                Parar
              </Botao>
            )}
            {!pronto && <span className="text-xs text-pendente-texto">Complete o ambiente ao lado para liberar.</span>}
            {pronto && !usuario && <span className="text-xs text-pendente-texto">Escolha o analista no topo da página.</span>}
          </div>
          <Aviso>{erro}</Aviso>
          <div className="text-sm">
            <span className="num">
              {e.feitas}/{e.total}
            </span>{" "}
            feitas · <span className="num">{e.erros}</span> com erro
            {e.rodando && e.atual && (
              <span>
                {" "}
                · agora: OS <span className="num">{e.atual.os}</span> ({e.atual.tipo})
              </span>
            )}
            {e.modo_teste && e.total > 0 && <span className="text-texto-suave"> · modo teste</span>}
          </div>
          <pre className="num max-h-96 overflow-auto rounded-md border border-borda bg-fundo p-2 text-xs leading-relaxed text-texto-suave" aria-live="polite">
            {e.log.length ? e.log.join("\n") : "Sem execuções nesta sessão do servidor."}
          </pre>
          <p className="text-xs text-texto-suave">
            Prontos: abrir o TS, login, SMANUTOS e pesquisa da OS. Cada tipo de correção só é executado depois que a tela correspondente
            do TS for mapeada pelo Diagnóstico; até lá o item volta com "tela não mapeada" e nada é alterado.
          </p>
        </div>
      </Cartao>
    </div>
  );
}
