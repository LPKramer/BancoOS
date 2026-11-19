@echo off
rem Instala o app neste PC. So precisa do Python 3.11 ou mais novo: a interface ja vem compilada
rem em frontend\dist, sem Node.
cd /d "%~dp0"
if not exist "frontend\dist\index.html" (echo Falta a interface compilada em frontend\dist. & exit /b 1)
if not exist "backend\.venv\Scripts\python.exe" (
  py -3 -m venv backend\.venv 2>nul || python -m venv backend\.venv
  if errorlevel 1 (echo Python 3.11 ou mais novo nao encontrado. & exit /b 1)
)
backend\.venv\Scripts\python.exe -c "import sys; sys.exit(sys.version_info < (3, 11))" || (echo O Python de backend\.venv e anterior ao 3.11. & exit /b 1)
backend\.venv\Scripts\python.exe -m pip install -e "backend[dev]" || (echo A instalacao dos pacotes Python falhou. & exit /b 1)
echo Instalado. Para subir o servidor: iniciar.bat
