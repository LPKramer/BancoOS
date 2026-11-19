# Análise de OS

App web para encontrar OS erradas: importa as bases do mês, aplica as regras do Banco de Análise
(Access), analisa o texto da OS com LLM (DeepSeek), confere a manobra na BDGD e prepara as correções
para o robô do TS (fase 2).

## Rodar

O servidor só precisa do **Python 3.11 ou mais novo**. A interface já vem compilada em `frontend/dist`,
então o PC da rede corporativa não precisa de Node.

Primeira vez (no PC que será o servidor), na pasta do projeto: `instalar.bat`, ou à mão:

```powershell
python -m venv backend\.venv
backend\.venv\Scripts\python.exe -m pip install -e "backend[dev]"
```

Subir o servidor: `iniciar.bat` (ou `.\iniciar.ps1`). Abrir `http://localhost:8780` (nos outros PCs da
rede: `http://<nome-ou-ip-do-servidor>:8780`).

## Mudar a interface

Só quem altera `frontend/src` precisa de Node, num PC fora da rede corporativa. Depois de alterar,
compile e mande o `frontend/dist` junto no commit (o teste `test_interface_compilada` confere que ele
está completo):

```powershell
cd frontend; npm install; npm run build; cd ..
```

## Configuração

Variáveis de ambiente ou arquivo `backend/.env`:

| Variável | Padrão | Uso |
|---|---|---|
| `OSA_PORTA` | 8780 | porta do servidor |
| `OSA_PASTA_DADOS` | `dados_app` | banco do app, uploads, índice da BDGD |
| `OSA_LLM_MODELO` | `deepseek-chat` | modelo do LLM |
| `OSA_LLM_MASCARAR` | 1 | mascara telefone, UC, CPF e e-mail antes de enviar ao LLM |
| `OSA_BDGD_AUX` | `Visualizador OS aberta/Visualizador OS aberta` | pasta com a BDGD (`BD*`), o FIS, `uc_equivalencia.xlsx` e `clientes_TS.csv` |
| `OSA_BDGD` | primeira pasta `BD*` dentro de `OSA_BDGD_AUX` | pasta dos shapefiles da BDGD |

Chave da DeepSeek (fica no Cofre de Credenciais do Windows, nunca em arquivo):

```powershell
backend\.venv\Scripts\python.exe -m osanalise.config definir-chave
```

## Uso mensal

1. **Importar**: aponte as duas bases do mês, cada uma no seu campo: a **crítica** (`base-critica DD-MM.xlsx`,
   aba `Exportar Planilha`) e as **ocorrências** (`9 C_Ocorrências_Base_Imp…xlsx`, compensação por OS). Cada
   uma pode ser um caminho no servidor (o botão Conferir lê só o cabeçalho, mostra linhas e competência e
   guarda o caminho para o mês seguinte) ou um arquivo enviado pelo navegador. Arquivo no campo errado é
   recusado antes de importar. O app separa a crítica por `TIPO_OS` do mesmo jeito que as consultas
   `0 Tabela *` do Access. O `.accdb` do Banco de Análise continua aceito (traz o histórico de correções).
   Os caminhos ficam na tabela `configuracao` do banco do app.
2. **Painel**: OS na fila por regra, COEC e andamento. Com `.accdb`, mostra também a conferência com o
   resultado do Access.
3. **Fila / Detalhe**: o analista abre a OS, vê as regras com a evidência, os passos, as OS vinculadas, a
   manobra na BDGD e a análise do LLM, e decide (correta / errada / ignorar, responsável, observação).
4. **Correções**: sugestões do LLM ou do analista. Só as aprovadas vão para o robô.

## Textos padrões (justificativa no TS)

A tela **Textos** aponta a planilha `TEXTOS PADRÕES PARA CORREÇÕES…xlsx` (coluna `JUSTIFICATIVA CORREÇÃO`,
em qualquer aba) e lista os textos com as categorias de correção do Banco de Análise (classificação, OS
vinculada, passo de manobra, horário, elemento de origem). As categorias saem de palavras-chave e podem ser
acertadas na tela; o acerto vale nas próximas cargas. Recarregar a planilha acrescenta os textos novos e
marca como "fora da planilha" os que sumiram.

Na OS, o painel de decisão sugere os textos pelas categorias marcadas e pelas correções propostas; o LLM
também escolhe um (marcado "LLM"). O analista escolhe e completa o que faltar (o número depois de
`VIDE INT.` ou no lugar do `X`). O texto fica na OS (`justificativa_ts`), sai na exportação e é o que o robô
escreve no campo "Justificativa" do SMANUTOS: sem ele o robô não executa as correções daquela OS.
Sem nada carregado, o app carrega sozinho a planilha que estiver na pasta do projeto.

## Regras

As 22 regras de intervenção e a regra de OS individual foram portadas das consultas do Access
(`docs/access/consultas.sql`, cadeias por regra em `docs/access/regras/`). Conferência com o Access
de outubro/2026: 20 regras idênticas e fila do Access inteira contida na do app.

Diferenças conhecidas em relação ao Access:

- `Intev_<_3_OS_Vinc_>_50_UCs` e `Intev_S_OS_Vinc` **nunca marcam no Access**: as consultas `4_4`/`5_4`
  leem a coluna `QTD_UN_CONS_PNB`, que na tabela `1 Tabela_Manobra` foi renomeada para `'`. No app elas
  funcionam (43 e 66 OS a mais na fila em outubro).
- `Comp_>_500` filtra compensação **≥ R$ 1.000** (consulta `2_6`); `DIF_1ª_2ª_RCM_1h` usa **180 min**.
- O app reproduz a aritmética de datas do Access: reclamação exatamente 120 min antes do passo entra
  em "< −120".
- Filtro final: a OS sai da fila se tiver só uma das regras fracas (1ª x 2ª reclamação, início x 1º passo
  = 1 min, > 6 h, início x 1º passo x 1ª OS).

Conferir de novo com um `.accdb`:

```powershell
backend\.venv\Scripts\python.exe -m osanalise.rules.paridade "Banco de Análise -Base - nova.accdb"
```

## Manobra na BDGD

No detalhe da OS de intervenção, **Abrir visualizador** desenha a rede de média tensão dos
alimentadores envolvidos e reproduz os passos de ABRIR/INTERR/FECHAR/REESTAB:

- **Calculado**: UCs ativas da BDGD que o elemento isola (abrir) ou religa (fechar) na configuração do
  momento. A marca "difere" aponta diferença relevante para o número registrado no passo.
- **Desligadas**: UCs sem energia depois do passo (estado simulado).
- OS vinculadas fora da área desligada e OS individuais da área, no período, sem vínculo.

Como os elementos do TS são localizados: trafo pelo FIS; UC pela `uc_equivalencia`; chave/religador
pela coordenada do elemento na base de compensação (a chave da BDGD mais próxima, até 50 m). Essa
equivalência é aprendida a cada lote importado, então a cobertura dos passos cresce mês a mês
(outubro/2026: 56% dos passos de abrir/fechar). Disjuntor de saída equivale ao alimentador inteiro.

O índice da BDGD é montado uma vez (cerca de 30 s) pelo botão **Preparar BDGD** e refeito quando a pasta
da BDGD muda.

## Piloto do LLM

Mede o LLM contra o histórico do Access (OS com "Correção Realizada"): sorteia metade de OS corrigidas
(variando as categorias) e metade não corrigidas, analisa pelo app e grava o relatório em
`dados_app/relatorios/`. Use outra `--semente` para uma amostra nova (controle).

```powershell
backend\.venv\Scripts\python.exe -m osanalise.llm.piloto --lote 1 --n 50 --semente 11
```

Resultado em 18/11/2026 (deepseek-chat, prompt 2026-11-18.5, amostra de controle): 84% das OS corrigidas
no Access foram acusadas como erradas, 71% com o tipo de correção da mesma categoria, e 2 de 25 OS não
corrigidas foram acusadas. As não corrigidas não têm gabarito (podem estar certas ou só não analisadas).

## Robô do TS (fase 2)

Pronto: verificação do ambiente (Java Access Bridge, acessibilidade do Java, jnlp, credencial), abrir o
TS, login, SMANUTOS, pesquisa da OS, tratamento das mensagens, modo teste e diagnóstico da árvore de
componentes. Falta mapear as telas de cada correção (passos de manobra, conclusão, OS vinculadas,
datas): com o TS aberto na tela, use **Robô > Diagnóstico do TS** e acrescente os componentes em
`backend/osanalise/robot/locators.json`. Até lá, cada correção volta com "tela não mapeada" e nada é
alterado.

Credencial do TS (Cofre do Windows): `backend\.venv\Scripts\python.exe -m osanalise.robot.credencial`.
Biblioteca do robô: `backend\.venv\Scripts\python.exe -m pip install -e "backend[robo]"`.

## Testes

```powershell
cd backend; .venv\Scripts\python.exe -m pytest
```
