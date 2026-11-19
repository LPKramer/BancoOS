@echo off
rem Sobe o servidor do app (porta em OSA_PORTA, padrao 8780).
cd /d "%~dp0"
backend\.venv\Scripts\python.exe -m osanalise
