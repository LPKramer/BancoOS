const CHAVE_USUARIO = "osa.usuario";

export function usuarioSalvo(): string {
  try {
    return localStorage.getItem(CHAVE_USUARIO) ?? "";
  } catch {
    return "";
  }
}

export function salvarUsuario(nome: string) {
  try {
    localStorage.setItem(CHAVE_USUARIO, nome);
  } catch {
    /* navegador sem armazenamento: segue sem lembrar */
  }
}

export class ErroApi extends Error {
  status: number;
  constructor(status: number, mensagem: string) {
    super(mensagem);
    this.status = status;
  }
}

async function requisitar<T>(metodo: string, caminho: string, corpo?: unknown): Promise<T> {
  const cabecalhos: Record<string, string> = { "X-Usuario": usuarioSalvo() };
  let body: BodyInit | undefined;
  if (corpo instanceof FormData) {
    body = corpo;
  } else if (corpo !== undefined) {
    cabecalhos["Content-Type"] = "application/json";
    body = JSON.stringify(corpo);
  }
  const resp = await fetch(caminho, { method: metodo, headers: cabecalhos, body });
  if (!resp.ok) {
    let mensagem = `Erro ${resp.status}`;
    try {
      const dados = await resp.json();
      if (typeof dados.detail === "string") mensagem = dados.detail;
      else if (Array.isArray(dados.detail)) mensagem = dados.detail.map((d: { msg: string }) => d.msg).join("; ");
    } catch {
      /* resposta sem JSON */
    }
    throw new ErroApi(resp.status, mensagem);
  }
  return resp.status === 204 ? (undefined as T) : ((await resp.json()) as T);
}

export const api = {
  get: <T,>(caminho: string) => requisitar<T>("GET", caminho),
  post: <T,>(caminho: string, corpo?: unknown) => requisitar<T>("POST", caminho, corpo ?? {}),
  patch: <T,>(caminho: string, corpo: unknown) => requisitar<T>("PATCH", caminho, corpo),
  put: <T,>(caminho: string, corpo: unknown) => requisitar<T>("PUT", caminho, corpo),
  delete: <T,>(caminho: string) => requisitar<T>("DELETE", caminho),
};

export function consulta(params: Record<string, string | number | undefined | null>): string {
  const p = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== null && v !== "") p.set(k, String(v));
  }
  const s = p.toString();
  return s ? `?${s}` : "";
}
