-- Regra Intev_0_UCs_Inter: consulta raiz [8_7 Filtro Passo Válido Filtro] (9 consultas na cadeia)

-- ===== 4_0 Base Mano Filt Aber Inter  (SELECT)
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
       [1 Tabela_Manobra].QTD_UN_CONS_PNB,
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

-- ===== 4_1 Dt Menor Passo  (SELECT)
SELECT [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       Min([4_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [4_0 Base Mano Filt Aber Inter]
GROUP BY [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 4_2 Cruz Dt Menor Passo x Num Passo  (SELECT)
SELECT [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [4_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [4_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
FROM [4_1 Dt Menor Passo]
  INNER JOIN [4_0 Base Mano Filt Aber Inter] ON [4_1 Dt Menor Passo].NUM_SEQ_OPER_OS_PNB = [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [4_1 Dt Menor Passo].DTA_PASSO_PNB = [4_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB
GROUP BY [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [4_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB, [4_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
ORDER BY [4_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [4_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB;

-- ===== 8_3 Filtro Menor Passo  (SELECT)
SELECT [4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [4_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB,
       First([4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [4_2 Cruz Dt Menor Passo x Num Passo]
GROUP BY [4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [4_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 8_4 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 8_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [8_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [8_4 Base Mano Filt Aber Inter].COD_OPER_PNB,
       [8_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [8_4 Base Mano Filt Aber Inter].NUM_SEQ_PNB,
       [8_3 Filtro Menor Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([8_4 Base Mano Filt Aber Inter]![NUM_SEQ_PNB]=[8_3 Filtro Menor Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro],
       [8_4 Base Mano Filt Aber Inter].[']
FROM [8_3 Filtro Menor Passo]
  INNER JOIN [8_4 Base Mano Filt Aber Inter] ON [8_3 Filtro Menor Passo].DTA_PASSO_PNB = [8_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB AND [8_3 Filtro Menor Passo].NUM_SEQ_OPER_OS_PNB = [8_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 8_6 Filtro Passo Válido  (SELECT)
SELECT [8_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [8_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [8_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [8_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB],
       [8_5 Cruzamento Passo Corret x Base].[']
FROM [8_5 Cruzamento Passo Corret x Base]
WHERE ((([8_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [8_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [8_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [8_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [8_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO, [8_5 Cruzamento Passo Corret x Base].['];

-- ===== 8_6 Filtro Passo Válido Interr  (SELECT)
SELECT [8_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [8_6 Filtro Passo Válido].COD_OPER_PNB,
       [8_6 Filtro Passo Válido].DTA_PASSO_PNB,
       [8_6 Filtro Passo Válido].NUM_SEQ_PNB,
       IIf([8_6 Filtro Passo Válido]!['] Is Null,"-",[8_6 Filtro Passo Válido]![']) AS [QTD_UN_CONS_PNB],
       IIf([8_6 Filtro Passo Válido]!['] Is Null,"Verificar","") AS [Análise]
FROM [8_6 Filtro Passo Válido];

-- ===== 8_7 Filtro Passo Válido Filtro  (SELECT)
SELECT [8_6 Filtro Passo Válido Interr].NUM_SEQ_OPER_OS_PNB,
       [8_6 Filtro Passo Válido Interr].COD_OPER_PNB,
       [8_6 Filtro Passo Válido Interr].DTA_PASSO_PNB,
       [8_6 Filtro Passo Válido Interr].NUM_SEQ_PNB,
       [8_6 Filtro Passo Válido Interr].QTD_UN_CONS_PNB,
       [8_6 Filtro Passo Válido Interr].Análise
FROM [8_6 Filtro Passo Válido Interr]
WHERE ((([8_6 Filtro Passo Válido Interr].QTD_UN_CONS_PNB)="-"));
