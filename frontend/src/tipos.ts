export type StatusOS = "pendente" | "em_analise" | "correta" | "errada" | "corrigida" | "ignorada";
export type Veredito = "errada" | "correta" | "duvidosa";

export interface Config {
  llm_provedor: string;
  llm_modelo: string;
  llm_configurado: boolean;
  llm_mascarar: boolean;
  status_os: StatusOS[];
  responsaveis: string[];
  categorias_correcao: Record<string, string>;
}

export interface Regra {
  id: string;
  nome: string;
  descricao: string;
  tipo_os: string;
  sozinha_basta: boolean;
  coluna_access: string | null;
  consulta_access: string | null;
  correcao_tipica: string | null;
  divergencia_access: string | null;
}

export interface TipoCorrecao {
  nome: string;
  campos: string[];
  alvo?: string;
  valores?: Record<string, string>;
  formato?: string;
  categoria_access: string;
}

export interface Lote {
  id: number;
  competencia: string | null;
  origem: string;
  nome_origem: string;
  tipo_origem: string;
  criado_em: string;
  criado_por: string;
  contagens: Record<string, number>;
  contagem_regras: Record<string, number>;
  erros_regras: Record<string, string>;
  paridade: Paridade | null;
  fila?: number;
}

export interface Paridade {
  regras: { regra_id: string; app: number; access: number; so_app: number; so_access: number; ok: boolean; divergencia: string | null }[];
  resumo: Record<string, number>;
}

export interface OSFila {
  id: number;
  lote_id: number;
  os: string;
  tipo_os: string;
  regras: string[];
  n_regras: number;
  competencia: string | null;
  cod_causa: string | null;
  causa: string | null;
  cod_subcausa: string | null;
  subcausa: string | null;
  conclusao: string | null;
  tma: number | null;
  dec: number | null;
  inicio: string | null;
  fim: string | null;
  elemento: string | null;
  instalacao: string | null;
  localidade: string | null;
  coec: string | null;
  qtd_vinculadas: number;
  multa: number | null;
  status: StatusOS;
  analista: string | null;
  responsavel: string | null;
  observacao: string | null;
  atualizado_em: string | null;
  veredito_llm: Veredito | null;
  confianca_llm: number | null;
  access_corrigida: boolean | null;
  access_categorias: string[] | null;
  categorias_correcao: string[] | null;
  justificativa_ts: string | null;
}

export interface TextoPadrao {
  id: number;
  texto: string;
  categorias: string[];
  categorias_manuais: boolean;
  erro: string | null;
  ordem: number;
  ativo: boolean;
}

export interface VerificacaoFonte {
  ok: boolean;
  mensagem: string;
  caminho?: string;
  nome?: string;
  tamanho?: number;
  modificado?: string;
  aba?: string;
  linhas?: number | null;
  competencia?: string | null;
}

export interface Fonte {
  tipo: "critica" | "ocorrencias" | "textos";
  nome: string;
  caminho: string | null;
  salvo: boolean;
  verificacao: VerificacaoFonte | null;
}

export interface PaginaFila {
  total: number;
  pagina: number;
  tamanho: number;
  itens: OSFila[];
}

export interface Painel {
  total: number;
  multa_total: number;
  por_status: Record<string, number>;
  por_coec: { coec: string; os: number; multa: number }[];
  por_regra: { regra_id: string; nome: string; os: number; multa: number; sozinha_basta: boolean }[];
  por_veredito: Record<string, number>;
  correcoes: Record<string, number>;
  por_tipo: Record<string, number>;
}

export type Registro = Record<string, string | number | null>;

export interface FlagDetalhe {
  regra_id: string;
  valor: string;
  evidencia: Registro;
  nome: string;
  descricao: string;
  correcao_tipica: string | null;
}

export interface AnaliseLLM {
  id: number;
  criado_em: string;
  modelo: string;
  veredito: Veredito | null;
  confianca: number | null;
  erro: string | null;
  resposta: {
    veredito?: Veredito;
    confianca?: number;
    resumo?: string;
    problemas?: { regra_id: string | null; descricao: string; evidencia: string | null }[];
    regras_falso_positivo?: string[];
    correcoes?: unknown[];
    justificativa_padrao?: number | null;
    justificativa_padrao_texto?: string | null;
  };
}

export interface Correcao {
  id: number;
  os_fila_id: number;
  criado_em: string;
  origem: "llm" | "analista";
  tipo: string;
  campo: string | null;
  alvo: string | null;
  valor_atual: string | null;
  valor_novo: string | null;
  justificativa: string | null;
  status: "proposta" | "aprovada" | "rejeitada" | "em_execucao" | "executada" | "erro";
  decidido_por: string | null;
  decidido_em: string | null;
  executado_em: string | null;
  resultado_robo: string | null;
  tentativas: number;
  os?: string;
  lote_id?: number;
  localidade?: string | null;
  justificativa_ts?: string | null;
}

export interface DetalheOS {
  resumo: OSFila;
  registro: Registro;
  passos: Registro[];
  vinculadas: Registro[];
  equipe: Registro[];
  compensacao: Registro[];
  flags: FlagDetalhe[];
  analises: AnaliseLLM[];
  correcoes: Correcao[];
}

export interface Tarefa {
  id: string;
  total: number;
  feitas: number;
  erros: number;
  reaproveitadas: number;
  situacao: "rodando" | "concluida" | "cancelada" | "erro";
  mensagem: string;
  vereditos: Record<string, number>;
}

export interface Importacao {
  id: string;
  situacao: "rodando" | "concluida" | "erro";
  arquivos: string[];
  inicio: string;
  lote_id?: number;
  mensagem?: string;
}

export interface PassoManobra {
  ordem: number;
  seq: number | null;
  data: string | null;
  oper: string;
  elemento: string | null;
  cod_ts: string;
  status: string | null;
  qtd_registrada: number | null;
  localizado: "chave" | "trafo" | "alimentador" | "fora" | null;
  cod_bdgd: string | null;
  distancia_m?: number;
  efeito: "abre" | "fecha" | "nao_localizado" | "sem_efeito" | "cancelado" | null;
  ucs_elemento: number | null;
  ucs_desligadas: number | null;
  variacao: number | null;
  trafos_off: number[];
  secoes_off: number[];
}

export interface CandidatoArea {
  cod_id: string;
  tipo: string;
  elo: string;
  lat: number | null;
  lon: number | null;
  ucs_jusante: number | null;
  motivo: string;
}

export interface Manobra {
  disponivel: boolean;
  motivo?: string;
  resumo: {
    alimentadores: { cod_id: string; nome: string; subestacao: string }[];
    ucs_alimentadores: number;
    passos_total: number;
    passos_localizados: number;
    passos_com_efeito: number;
    pico_ucs: number | null;
    qtd_primeiro_passo: number | null;
    area_origem: string | null;
    area_ucs: number | null;
    area_trafos: number;
    vinculadas_total: number;
    vinculadas_localizadas: number;
    vinculadas_fora_area: number;
    candidatas_vincular: number;
  };
  candidatos: Record<string, CandidatoArea>;
  avisos: string[];
  ocorrencia: { lat: number; lon: number } | null;
  secoes: Record<string, number[][]>;
  secoes_area: number[];
  chaves: { cod_id: string; lat: number; lon: number; tipo: string; elo: string; normal: "F" | "A"; passos: number[] }[];
  trafos: { i: number; cod_id: string; ts: string | null; lat: number; lon: number; ucs: number; kva: number | null; vinc: number; ligado: boolean }[];
  trafos_area: number[];
  passos: PassoManobra[];
  vinculadas: { os: string; recl: string | null; tipo: string | null; trafo_ts: string | null; trafo: number | null; lat: number | null; lon: number | null; na_area: boolean | null }[];
  candidatas: {
    os: string;
    recl: string | null;
    tipo: string | null;
    trafo_ts: string | null;
    causa: string | null;
    conclusao: string | null;
    trafo: number | null;
    lat: number | null;
    lon: number | null;
  }[];
  inicio: string | null;
  fim: string | null;
}

export interface EstadoBDGD {
  pasta_bdgd: string | null;
  pronto: boolean;
  situacao: string;
  etapa: string;
  erro: string | null;
  equivalencias_chave: number;
  meta?: Record<string, string>;
}

export interface EstadoRobo {
  ambiente: {
    dll: string | null;
    acessibilidade_java: boolean;
    biblioteca_jab: boolean;
    jnlp: string | null;
    credencial_ts: boolean;
    janelas_ts: { hwnd: number; titulo: string; pid: number }[];
  };
  execucao: {
    rodando: boolean;
    modo_teste: boolean;
    atual: { correcao: number; os: string; tipo: string } | null;
    passo: string;
    feitas: number;
    total: number;
    erros: number;
    log: string[];
    inicio: string | null;
    fim: string | null;
  };
}
