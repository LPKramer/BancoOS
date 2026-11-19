"""Exporta a estrutura de um .accdb para documentação: tabelas, colunas, SQL das consultas.

Uso:
    python -m osanalise.importers.schema_dump "<arquivo.accdb>" "<pasta de saída>"
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from .access import TIPO_FORMULARIO, AccessDB

TABELAS_PEQUENAS = 300  # tabelas com até N linhas têm o conteúdo exportado (domínios)


def exportar(caminho_accdb: str | Path, saida: str | Path) -> None:
    saida = Path(saida)
    saida.mkdir(parents=True, exist_ok=True)
    db = AccessDB(caminho_accdb)

    resumo = ["# Tabelas", "", "| Tabela | Linhas | Colunas | Memos ilegíveis |", "|---|---:|---:|---:|"]
    colunas_md = ["# Colunas por tabela", ""]
    dominios_md = ["# Conteúdo das tabelas pequenas", ""]
    for nome in db.tabelas():
        df = db.ler_tabela(nome, exigir_memos=False)
        resumo.append(f"| {nome} | {len(df)} | {len(df.columns)} | {db.falhas_memo(nome)} |")
        colunas_md += [f"## {nome}", "", "| Coluna | Tipo | Preenchida | Exemplo |", "|---|---|---:|---|"]
        for col in df.columns:
            serie = df[col]
            preenchida = serie.notna() & (serie.astype(str).str.strip() != "")
            exemplo = serie[preenchida].iloc[0] if preenchida.any() else ""
            exemplo = str(exemplo).replace("\n", " ").replace("|", "/")[:60]
            tipo = type(serie[preenchida].iloc[0]).__name__ if preenchida.any() else "-"
            colunas_md.append(f"| {col} | {tipo} | {preenchida.mean():.0%} | {exemplo} |")
        colunas_md.append("")
        if 0 < len(df) <= TABELAS_PEQUENAS and len(df.columns) <= 10:
            dominios_md += [f"## {nome}", "", df.to_markdown(index=False), ""]

    (saida / "tabelas.md").write_text("\n".join(resumo) + "\n", encoding="utf-8")
    (saida / "colunas.md").write_text("\n".join(colunas_md) + "\n", encoding="utf-8")
    (saida / "dominios.md").write_text("\n".join(dominios_md) + "\n", encoding="utf-8")

    consultas = db.consultas()
    blocos = []
    for c in consultas:
        blocos.append(f"-- ===== {c.nome}  ({c.tipo})\n{c.sql}\n")
    (saida / "consultas.sql").write_text("\n".join(blocos), encoding="utf-8")
    (saida / "consultas.json").write_text(
        json.dumps([c.__dict__ for c in consultas], ensure_ascii=False, indent=1), encoding="utf-8"
    )
    formularios = db.objetos(TIPO_FORMULARIO)
    (saida / "formularios.txt").write_text("\n".join(formularios) + "\n", encoding="utf-8")
    print(f"{len(db.tabelas())} tabelas, {len(consultas)} consultas, {len(formularios)} formulários -> {saida}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    exportar(sys.argv[1], sys.argv[2])
