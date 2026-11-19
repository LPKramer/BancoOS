import { useRef } from "react";
import { dataHora, mb } from "../formatos";
import type { Fonte } from "../tipos";
import { Botao } from "./ui";

/** Uma base apontada: caminho no servidor (conferido e lembrado) ou arquivo enviado pelo navegador. */
export default function CampoFonte({
  titulo,
  fonte,
  caminho,
  aoCaminho,
  arquivo,
  aoArquivo,
  aoConferir,
  conferindo,
  aceita = ".xlsx,.xlsm,.csv,.txt",
  exemplo,
}: {
  titulo: string;
  fonte: Fonte | null;
  caminho: string;
  aoCaminho: (v: string) => void;
  arquivo: File | null;
  aoArquivo: (f: File | null) => void;
  aoConferir: () => void;
  conferindo: boolean;
  aceita?: string;
  exemplo?: string;
}) {
  const entrada = useRef<HTMLInputElement>(null);
  // a conferência mostrada vale para o caminho que está no campo
  const v = fonte?.verificacao && (fonte.verificacao.caminho ?? fonte.caminho) === caminho.trim().replace(/^"|"$/g, "") ? fonte.verificacao : null;
  const id = `fonte-${titulo.replace(/\W+/g, "-").toLowerCase()}`;

  return (
    <div className="flex flex-col gap-1.5 rounded-md border border-borda p-3">
      <div className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1">
        <label htmlFor={id} className="text-sm font-medium">
          {titulo}
        </label>
        {arquivo ? (
          <span className="text-xs text-texto-suave">conferido ao importar</span>
        ) : v ? (
          <span role="status" className={`text-xs ${v.ok ? "text-ok-texto" : "text-erro-texto"}`}>
            {v.mensagem}
          </span>
        ) : caminho.trim() ? (
          <span className="text-xs text-texto-suave">não conferido</span>
        ) : null}
      </div>

      {arquivo ? (
        <div className="flex items-center gap-2 text-sm">
          <span className="num min-w-0 flex-1 truncate" title={arquivo.name}>
            {arquivo.name} · {mb(arquivo.size)}
          </span>
          <Botao
            variante="discreto"
            onClick={() => {
              aoArquivo(null);
              if (entrada.current) entrada.current.value = "";
            }}
          >
            Usar caminho
          </Botao>
        </div>
      ) : (
        <div className="flex flex-wrap gap-2">
          <input
            id={id}
            className="num h-8 min-w-0 flex-1 basis-72 rounded-md border border-borda bg-cartao px-2 text-sm text-texto placeholder:text-texto-suave/60 hover:border-texto-suave"
            value={caminho}
            placeholder={exemplo}
            spellCheck={false}
            onChange={(e) => aoCaminho(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && caminho.trim() && aoConferir()}
          />
          <Botao disabled={!caminho.trim()} carregando={conferindo} onClick={aoConferir}>
            Conferir
          </Botao>
          <Botao variante="discreto" onClick={() => entrada.current?.click()}>
            Enviar arquivo
          </Botao>
        </div>
      )}
      <input
        ref={entrada}
        type="file"
        accept={aceita}
        className="sr-only"
        tabIndex={-1}
        aria-label={`Arquivo: ${titulo}`}
        onChange={(e) => aoArquivo(e.target.files?.[0] ?? null)}
      />

      {!arquivo && v?.modificado && (
        <div className="num text-xs text-texto-suave">
          {v.nome} · {mb(v.tamanho)} · modificado {dataHora(v.modificado)}
          {fonte && !fonte.salvo && v.ok ? " · encontrado na pasta do app" : ""}
        </div>
      )}
    </div>
  );
}
