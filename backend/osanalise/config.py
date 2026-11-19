"""Configuração do app.

Valores vêm de variáveis de ambiente (ou de um arquivo `.env` na pasta backend/).
A chave da DeepSeek fica no Cofre de Credenciais do Windows (keyring), nunca em arquivo:

    python -m osanalise.config definir-chave      # pede a chave sem mostrá-la
    python -m osanalise.config remover-chave
"""
from __future__ import annotations

import getpass
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path

PASTA_BACKEND = Path(__file__).resolve().parent.parent
PASTA_PROJETO = PASTA_BACKEND.parent
SERVICO_COFRE = "osanalise"
USUARIO_COFRE_DEEPSEEK = "deepseek_api_key"


def _carregar_env() -> None:
    arq = PASTA_BACKEND / ".env"
    if not arq.exists():
        return
    for linha in arq.read_text(encoding="utf-8").splitlines():
        linha = linha.strip()
        if not linha or linha.startswith("#") or "=" not in linha:
            continue
        chave, valor = linha.split("=", 1)
        os.environ.setdefault(chave.strip(), valor.strip().strip('"'))


_carregar_env()


def _env(nome: str, padrao: str) -> str:
    return os.environ.get(nome, padrao)


@dataclass(frozen=True)
class Config:
    pasta_dados: Path = field(default_factory=lambda: Path(_env("OSA_PASTA_DADOS", str(PASTA_PROJETO / "dados_app"))))
    host: str = field(default_factory=lambda: _env("OSA_HOST", "0.0.0.0"))
    porta: int = field(default_factory=lambda: int(_env("OSA_PORTA", "8780")))
    # LLM
    llm_provedor: str = field(default_factory=lambda: _env("OSA_LLM_PROVEDOR", "deepseek"))
    llm_modelo: str = field(default_factory=lambda: _env("OSA_LLM_MODELO", "deepseek-chat"))
    llm_base_url: str = field(default_factory=lambda: _env("OSA_LLM_BASE_URL", "https://api.deepseek.com"))
    llm_paralelo: int = field(default_factory=lambda: int(_env("OSA_LLM_PARALELO", "4")))
    llm_mascarar: bool = field(default_factory=lambda: _env("OSA_LLM_MASCARAR", "1") != "0")
    # Robô (fase 2)
    jnlp_ts: str = field(default_factory=lambda: _env("OSA_JNLP_TS", str(PASTA_PROJETO / "frmservlet 1.jnlp")))
    jab_dll: str = field(default_factory=lambda: _env("OSA_JAB_DLL", ""))
    # BDGD (visualizador da manobra)
    pasta_bdgd_aux: Path = field(default_factory=lambda: Path(_env(
        "OSA_BDGD_AUX", str(PASTA_PROJETO / "Visualizador OS aberta" / "Visualizador OS aberta"))))
    pasta_bdgd: Path = field(default_factory=lambda: Path(_env("OSA_BDGD", "")) if _env("OSA_BDGD", "") else None)

    @property
    def bdgd(self) -> Path | None:
        """Pasta dos shapefiles da BDGD: OSA_BDGD ou a primeira pasta BD* dentro de OSA_BDGD_AUX."""
        if self.pasta_bdgd:
            return self.pasta_bdgd
        if self.pasta_bdgd_aux.is_dir():
            for p in sorted(self.pasta_bdgd_aux.iterdir(), reverse=True):
                if p.is_dir() and p.name.upper().startswith("BD") and (p / "CTMT.dbf").exists():
                    return p
        return None

    @property
    def arquivo_banco(self) -> Path:
        return self.pasta_dados / "osanalise.db"

    @property
    def pasta_uploads(self) -> Path:
        return self.pasta_dados / "uploads"


CONFIG = Config()


def chave_deepseek() -> str | None:
    """Chave da API: variável de ambiente (testes/servidor) ou Cofre do Windows."""
    if os.environ.get("DEEPSEEK_API_KEY"):
        return os.environ["DEEPSEEK_API_KEY"]
    try:
        import keyring

        return keyring.get_password(SERVICO_COFRE, USUARIO_COFRE_DEEPSEEK)
    except Exception:  # noqa: BLE001 - cofre indisponível
        return None


def _cli() -> None:
    import keyring

    comando = sys.argv[1] if len(sys.argv) > 1 else ""
    if comando == "definir-chave":
        chave = getpass.getpass("Chave da API DeepSeek (não aparece ao digitar): ").strip()
        if not chave:
            print("Nada gravado.")
            return
        keyring.set_password(SERVICO_COFRE, USUARIO_COFRE_DEEPSEEK, chave)
        print("Chave gravada no Cofre de Credenciais do Windows.")
    elif comando == "remover-chave":
        try:
            keyring.delete_password(SERVICO_COFRE, USUARIO_COFRE_DEEPSEEK)
            print("Chave removida.")
        except keyring.errors.PasswordDeleteError:
            print("Não havia chave gravada.")
    elif comando == "status":
        print("Chave DeepSeek:", "configurada" if chave_deepseek() else "não configurada")
        print("Banco:", CONFIG.arquivo_banco)
    else:
        print(__doc__)


if __name__ == "__main__":
    _cli()
