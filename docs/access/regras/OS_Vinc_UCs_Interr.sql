-- Regra OS_Vinc_UCs_Interr: consulta raiz [9_9_1 Análise OS > UCs Interr Filtro] (11 consultas na cadeia)

-- ===== 9_0 Base Mano Filt Aber Inter  (SELECT)
SELECT [1 Tabela_Manobra].TIPO_OS,
       [1 Tabela_Manobra].TIPO,
       [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Manobra].COD_ELE_PNB,
       [1 Tabela_Manobra].COD_INS_SEC_INS,
       [1 Tabela_Manobra].TIPO_CHAVE,
       [1 Tabela_Manobra].COD_OPER_PNB,
       [1 Tabela_Manobra].DTA_PASSO_PNB,
       [1 Tabela_Manobra].DTA_PREV_PASSO_PNB,
       [1 Tabela_Manobra].QTD_UN_CONS_VIP_PNB,
       [1 Tabela_Manobra].['],
       [1 Tabela_Manobra].QTD_KVAS_PNB,
       [1 Tabela_Manobra].COD_TIPO_MANO_PNB,
       [1 Tabela_Manobra]![NUM_SEQ_PNB]*1 AS [NUM_SEQ_PNB],
       [1 Tabela_Manobra].NUM_PASSO_PNB,
       [1 Tabela_Manobra].STA_EXEC_PNB,
       [1 Tabela_Manobra].STA_VIN_OS_PNB,
       [1 Tabela_Manobra].NUM_RET_MANO_PNB,
       [1 Tabela_Manobra].DES_PASSO_PNB
FROM [1 Tabela_Manobra]
WHERE ((([1 Tabela_Manobra].COD_OPER_PNB) In ("INTERR","ABRIR")) AND (([1 Tabela_Manobra].STA_EXEC_PNB)<>"Passo Cancelado"))
ORDER BY [1 Tabela_Manobra].DTA_PASSO_PNB;

-- ===== 9_1 Dt Menor Passo  (SELECT)
SELECT [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       Min([9_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [9_0 Base Mano Filt Aber Inter]
GROUP BY [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 9_2 Cruz Dt Menor Passo x Num Passo  (SELECT)
SELECT [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [9_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [9_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
FROM [9_1 Dt Menor Passo]
  INNER JOIN [9_0 Base Mano Filt Aber Inter] ON [9_1 Dt Menor Passo].NUM_SEQ_OPER_OS_PNB = [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [9_1 Dt Menor Passo].DTA_PASSO_PNB = [9_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB
GROUP BY [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [9_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB, [9_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
ORDER BY [9_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [9_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB;

-- ===== 9_3 Filtro Menor Passo  (SELECT)
SELECT [9_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [9_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB,
       First([9_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [9_2 Cruz Dt Menor Passo x Num Passo]
GROUP BY [9_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [9_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 9_4 Base Mano Filt Aber Inter  (SELECT)
SELECT [1 Tabela_Manobra].TIPO_OS,
       [1 Tabela_Manobra].TIPO,
       [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Manobra].COD_ELE_PNB,
       [1 Tabela_Manobra].COD_INS_SEC_INS,
       [1 Tabela_Manobra].TIPO_CHAVE,
       [1 Tabela_Manobra].COD_OPER_PNB,
       [1 Tabela_Manobra].DTA_PASSO_PNB,
       [1 Tabela_Manobra].DTA_PREV_PASSO_PNB,
       [1 Tabela_Manobra].QTD_UN_CONS_VIP_PNB,
       [1 Tabela_Manobra].['],
       [1 Tabela_Manobra].QTD_KVAS_PNB,
       [1 Tabela_Manobra].COD_TIPO_MANO_PNB,
       [1 Tabela_Manobra]![NUM_SEQ_PNB]*1 AS [NUM_SEQ_PNB],
       [1 Tabela_Manobra].NUM_PASSO_PNB,
       [1 Tabela_Manobra].STA_EXEC_PNB,
       [1 Tabela_Manobra].STA_VIN_OS_PNB,
       [1 Tabela_Manobra].NUM_RET_MANO_PNB,
       [1 Tabela_Manobra].DES_PASSO_PNB
FROM [1 Tabela_Manobra]
ORDER BY [1 Tabela_Manobra].DTA_PASSO_PNB;

-- ===== 9_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [9_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [9_4 Base Mano Filt Aber Inter].COD_OPER_PNB,
       [9_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [9_4 Base Mano Filt Aber Inter].NUM_SEQ_PNB,
       [9_3 Filtro Menor Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([9_4 Base Mano Filt Aber Inter]![NUM_SEQ_PNB]=[9_3 Filtro Menor Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro],
       [9_4 Base Mano Filt Aber Inter].[']
FROM [9_3 Filtro Menor Passo]
  INNER JOIN [9_4 Base Mano Filt Aber Inter] ON [9_3 Filtro Menor Passo].DTA_PASSO_PNB = [9_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB AND [9_3 Filtro Menor Passo].NUM_SEQ_OPER_OS_PNB = [9_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 9_6 Filtro Passo Válido  (SELECT)
SELECT [9_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [9_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [9_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [9_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB],
       [9_5 Cruzamento Passo Corret x Base].[']
FROM [9_5 Cruzamento Passo Corret x Base]
WHERE ((([9_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [9_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [9_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [9_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [9_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO, [9_5 Cruzamento Passo Corret x Base].['];

-- ===== 9_7 Cont OS Vinculada  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Count([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [OS]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR, [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR
HAVING ((([1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR)<>"AN"));

-- ===== 9_8 Cruzamento OS x Ocorrências  (SELECT)
SELECT [9_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [9_6 Filtro Passo Válido].COD_OPER_PNB,
       [9_6 Filtro Passo Válido].DTA_PASSO_PNB,
       [9_6 Filtro Passo Válido].NUM_SEQ_PNB,
       [9_7 Cont OS Vinculada].OS,
       ([9_6 Filtro Passo Válido]!['])*1 AS [QTD_UN_CONS_PNB]
FROM [9_6 Filtro Passo Válido]
  INNER JOIN [9_7 Cont OS Vinculada] ON [9_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB = [9_7 Cont OS Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 9_9 Análise OS > UCs Interr  (SELECT)
SELECT [9_8 Cruzamento OS x Ocorrências].NUM_SEQ_OPER_OS_PNB,
       [9_8 Cruzamento OS x Ocorrências].COD_OPER_PNB,
       [9_8 Cruzamento OS x Ocorrências].DTA_PASSO_PNB,
       [9_8 Cruzamento OS x Ocorrências].NUM_SEQ_PNB,
       [9_8 Cruzamento OS x Ocorrências].OS,
       [9_8 Cruzamento OS x Ocorrências].QTD_UN_CONS_PNB,
       IIf([9_8 Cruzamento OS x Ocorrências]![QTD_UN_CONS_PNB]<[9_8 Cruzamento OS x Ocorrências]![OS],"Verificar","") AS [Análise]
FROM [9_8 Cruzamento OS x Ocorrências];

-- ===== 9_9_1 Análise OS > UCs Interr Filtro  (SELECT)
SELECT [9_9 Análise OS > UCs Interr].NUM_SEQ_OPER_OS_PNB,
       [9_9 Análise OS > UCs Interr].COD_OPER_PNB,
       [9_9 Análise OS > UCs Interr].DTA_PASSO_PNB,
       [9_9 Análise OS > UCs Interr].NUM_SEQ_PNB,
       [9_9 Análise OS > UCs Interr].OS,
       [9_9 Análise OS > UCs Interr].QTD_UN_CONS_PNB,
       [9_9 Análise OS > UCs Interr].Análise
FROM [9_9 Análise OS > UCs Interr]
WHERE ((([9_9 Análise OS > UCs Interr].Análise)="vERIFICAR"));
