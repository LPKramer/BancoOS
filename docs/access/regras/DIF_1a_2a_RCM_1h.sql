-- Regra DIF_1a_2a_RCM_1h: consulta raiz [0_7 Calc Diferença Tempo OS Filtro] (10 consultas na cadeia)

-- ===== 0_0 Soma Clientes Interr  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       Sum([1 Tabela_Manobra].[']) AS [SomaDeQTD_UN_CONS_PNB]
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].COD_OPER_PNB
HAVING ((([1 Tabela_Manobra].COD_OPER_PNB) In ("ABRIR","INTERR")));

-- ===== 0_0 Menor 1ª Data  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Min([1 Tabela_Individual_Vinculada].DTA_RECL_CNR) AS [DTA_RECL_CNR]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0_1 Base 1ª Reclamação  (SELECT)
SELECT [0_0 Menor 1ª Data].NUM_SEQ_OPER_INTER_CNR,
       Min([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [NUM_SEQ_OPER_CNR],
       [0_0 Menor 1ª Data].DTA_RECL_CNR
FROM [0_0 Menor 1ª Data]
  INNER JOIN [1 Tabela_Individual_Vinculada] ON [0_0 Menor 1ª Data].NUM_SEQ_OPER_INTER_CNR = [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR AND [0_0 Menor 1ª Data].DTA_RECL_CNR = [1 Tabela_Individual_Vinculada].DTA_RECL_CNR
GROUP BY [0_0 Menor 1ª Data].NUM_SEQ_OPER_INTER_CNR, [0_0 Menor 1ª Data].DTA_RECL_CNR;

-- ===== 0_2 Base S 1ª Reclamação  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR
FROM [1 Tabela_Individual_Vinculada]
  LEFT JOIN [0_1 Base 1ª Reclamação] ON [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR = [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR AND [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR = [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_CNR
WHERE ((([0_1 Base 1ª Reclamação].NUM_SEQ_OPER_CNR) Is Null))
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR, [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR, [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== 0_2 Menor 2ª Data  (SELECT)
SELECT [0_2 Base S 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR,
       Min([0_2 Base S 1ª Reclamação].DTA_RECL_CNR) AS [DTA_RECL_CNR]
FROM [0_2 Base S 1ª Reclamação]
GROUP BY [0_2 Base S 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0_3 Base 2ª Reclamação  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Min([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [NUM_SEQ_OPER_CNR],
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR
FROM [0_2 Menor 2ª Data]
  INNER JOIN [1 Tabela_Individual_Vinculada] ON [0_2 Menor 2ª Data].NUM_SEQ_OPER_INTER_CNR = [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR AND [0_2 Menor 2ª Data].DTA_RECL_CNR = [1 Tabela_Individual_Vinculada].DTA_RECL_CNR
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR, [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== 0_4 Base Intervenção  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0_5 Cruzamento 1ª e 2ª Reclamação  (SELECT)
SELECT [0_4 Base Intervenção].NUM_SEQ_OPER_INTER_CNR,
       [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_CNR AS [NUM_SEQ_OPER_1_OS],
       [0_1 Base 1ª Reclamação].DTA_RECL_CNR AS [DTA_RECL_1_OS],
       [0_3 Base 2ª Reclamação].NUM_SEQ_OPER_CNR AS [NUM_SEQ_OPER_2_OS],
       [0_3 Base 2ª Reclamação].DTA_RECL_CNR AS [DTA_RECL_2_OS]
FROM [0_4 Base Intervenção]
  INNER JOIN [0_1 Base 1ª Reclamação] ON [0_4 Base Intervenção].NUM_SEQ_OPER_INTER_CNR = [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR
  LEFT JOIN [0_3 Base 2ª Reclamação] ON [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR = [0_3 Base 2ª Reclamação].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0_6 Calc Diferença Temp OS  (SELECT)
SELECT [0_5 Cruzamento 1ª e 2ª Reclamação].NUM_SEQ_OPER_INTER_CNR,
       [0_5 Cruzamento 1ª e 2ª Reclamação].NUM_SEQ_OPER_1_OS,
       [0_5 Cruzamento 1ª e 2ª Reclamação].DTA_RECL_1_OS,
       [0_5 Cruzamento 1ª e 2ª Reclamação].NUM_SEQ_OPER_2_OS,
       [0_5 Cruzamento 1ª e 2ª Reclamação].DTA_RECL_2_OS,
       ([DTA_RECL_2_OS]-[DTA_RECL_1_OS])*1440 AS [TEMPO],
       IIf([TEMPO]>180,"Verificar","") AS [Análise]
FROM [0_5 Cruzamento 1ª e 2ª Reclamação]
  INNER JOIN [0_0 Soma Clientes Interr] ON [0_5 Cruzamento 1ª e 2ª Reclamação].NUM_SEQ_OPER_INTER_CNR = [0_0 Soma Clientes Interr].NUM_SEQ_OPER_OS_PNB
WHERE ((([0_0 Soma Clientes Interr].SomaDeQTD_UN_CONS_PNB)>=10));

-- ===== 0_7 Calc Diferença Tempo OS Filtro  (SELECT)
SELECT [0_6 Calc Diferença Temp OS].NUM_SEQ_OPER_INTER_CNR,
       [0_6 Calc Diferença Temp OS].NUM_SEQ_OPER_1_OS,
       [0_6 Calc Diferença Temp OS].DTA_RECL_1_OS,
       [0_6 Calc Diferença Temp OS].NUM_SEQ_OPER_2_OS,
       [0_6 Calc Diferença Temp OS].DTA_RECL_2_OS,
       [0_6 Calc Diferença Temp OS].TEMPO,
       [0_6 Calc Diferença Temp OS].Análise
FROM [0_6 Calc Diferença Temp OS]
WHERE ((([0_6 Calc Diferença Temp OS].Análise)="Verificar"));
