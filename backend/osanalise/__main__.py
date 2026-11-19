"""Sobe o servidor: python -m osanalise  (endereço e porta em OSA_HOST / OSA_PORTA)."""
import uvicorn

from .config import CONFIG

if __name__ == "__main__":
    print(f"Análise de OS em http://{'localhost' if CONFIG.host == '0.0.0.0' else CONFIG.host}:{CONFIG.porta}")
    uvicorn.run("osanalise.api.app:app", host=CONFIG.host, port=CONFIG.porta, workers=1)
