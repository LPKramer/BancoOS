"""Grava usuário e senha do TS no Cofre de Credenciais do Windows (nunca em arquivo).

    python -m osanalise.robot.credencial
"""
from __future__ import annotations

import getpass

import keyring

from .ambiente import SERVICO_COFRE_TS

if __name__ == "__main__":
    usuario = input("Usuário do TS: ").strip()
    senha = getpass.getpass("Senha do TS (não aparece ao digitar): ")
    if usuario and senha:
        keyring.set_password(SERVICO_COFRE_TS, "usuario", usuario)
        keyring.set_password(SERVICO_COFRE_TS, usuario, senha)
        print("Credencial do TS gravada no Cofre do Windows.")
    else:
        print("Nada gravado.")
