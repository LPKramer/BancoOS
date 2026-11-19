import { Component, type ErrorInfo, type ReactNode } from "react";
import { isRouteErrorResponse, useRouteError } from "react-router-dom";

/** Isola falhas de um componente (ex.: o mapa) sem derrubar a página inteira. */
export class LimiteErro extends Component<{ children: ReactNode; titulo?: string }, { erro: Error | null }> {
  state = { erro: null as Error | null };

  static getDerivedStateFromError(erro: Error) {
    return { erro };
  }

  componentDidCatch(erro: Error, info: ErrorInfo) {
    console.error(erro, info.componentStack);
  }

  render() {
    if (this.state.erro) {
      return (
        <div role="alert" className="rounded-md border border-erro/50 bg-erro/10 px-3 py-2 text-sm text-erro-texto">
          {this.props.titulo ?? "Falha ao mostrar este bloco"}: {this.state.erro.message}
          <button className="ml-3 underline" onClick={() => this.setState({ erro: null })}>
            Tentar de novo
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

/** Erro de rota (ex.: falha inesperada numa página). */
export function ErroRota() {
  const erro = useRouteError();
  const texto = isRouteErrorResponse(erro) ? `${erro.status} ${erro.statusText}` : erro instanceof Error ? erro.message : String(erro);
  return (
    <div className="mx-auto max-w-3xl px-4 py-10">
      <div role="alert" className="rounded-md border border-erro/50 bg-erro/10 px-3 py-2 text-sm text-erro-texto">
        Erro inesperado: {texto}
      </div>
      <a className="mt-3 inline-block text-sm underline" href="/">
        Voltar ao painel
      </a>
    </div>
  );
}
