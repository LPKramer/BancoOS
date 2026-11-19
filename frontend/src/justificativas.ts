import type { TextoPadrao } from "./tipos";

export const semAcento = (s: string) => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toUpperCase();

/** Textos padrões que combinam com as categorias da correção: mais categorias em comum primeiro
 * (penalizando as que sobram ou faltam), depois a ordem da planilha. */
export function sugerir(textos: TextoPadrao[], categorias: string[]): TextoPadrao[] {
  if (!categorias.length) return [];
  const alvo = new Set(categorias);
  return textos
    .filter((t) => t.ativo)
    .map((t) => {
      const comuns = t.categorias.filter((c) => alvo.has(c)).length;
      const sobra = t.categorias.length - comuns;
      const falta = alvo.size - comuns;
      return { t, comuns, nota: comuns * 2 - sobra - falta * 0.5 };
    })
    .filter((x) => x.comuns > 0)
    .sort((a, b) => b.nota - a.nota || a.t.ordem - b.t.ordem)
    .map((x) => x.t);
}

export function buscar(textos: TextoPadrao[], termo: string): TextoPadrao[] {
  const partes = semAcento(termo).split(/\s+/).filter(Boolean);
  return textos.filter((t) => t.ativo && partes.every((p) => semAcento(t.texto).includes(p)));
}

/** Trechos do texto padrão que o analista ainda precisa completar. */
export function pendencias(texto: string): string[] {
  const t = semAcento(texto);
  const p: string[] = [];
  if (/VIDE INT\.?(?!\s*\d)/.test(t)) p.push("o número da intervenção depois de VIDE INT.");
  if (/INTERVENCAO X\b/.test(t)) p.push("o número da intervenção no lugar do X");
  return p;
}
