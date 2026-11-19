# Sobe o servidor do app Análise de OS (porta em OSA_PORTA, padrão 8780).
Set-Location $PSScriptRoot
& "$PSScriptRoot\backend\.venv\Scripts\python.exe" -m osanalise
