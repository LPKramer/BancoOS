-- Regra DIF_1a_Man_1a_OS_Vinc_2h: consulta raiz [1_8 1º Manobra x 1º OS Vinc Filtro] (12 consultas na cadeia)

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

-- ===== 1_0 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 1_1 Dt Menor Passo  (SELECT)
SELECT [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       Min([1_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [1_0 Base Mano Filt Aber Inter]
GROUP BY [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 1_2 Cruz Dt Menor Passo x Num Passo  (SELECT)
SELECT [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [1_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [1_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
FROM [1_1 Dt Menor Passo]
  INNER JOIN [1_0 Base Mano Filt Aber Inter] ON [1_1 Dt Menor Passo].NUM_SEQ_OPER_OS_PNB = [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [1_1 Dt Menor Passo].DTA_PASSO_PNB = [1_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB
GROUP BY [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [1_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB, [1_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
ORDER BY [1_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [1_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB;

-- ===== 1_3 Filtro Menor Passo  (SELECT)
SELECT [1_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [1_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB,
       First([1_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [1_2 Cruz Dt Menor Passo x Num Passo]
GROUP BY [1_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [1_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 1_4 Base Mano Filt Aber Inter  (SELECT)
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
ORDER BY [1 Tabela_Manobra].DTA_PASSO_PNB;

-- ===== 1_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [1_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [1_4 Base Mano Filt Aber Inter].COD_OPER_PNB,
       [1_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [1_4 Base Mano Filt Aber Inter].NUM_SEQ_PNB,
       [1_3 Filtro Menor Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([1_4 Base Mano Filt Aber Inter]![NUM_SEQ_PNB]=[1_3 Filtro Menor Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro]
FROM [1_4 Base Mano Filt Aber Inter]
  INNER JOIN [1_3 Filtro Menor Passo] ON [1_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB = [1_3 Filtro Menor Passo].NUM_SEQ_OPER_OS_PNB AND [1_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB = [1_3 Filtro Menor Passo].DTA_PASSO_PNB;

-- ===== 1_6 Filtro Passo Válido  (SELECT)
SELECT [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [1_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [1_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB]
FROM [1_5 Cruzamento Passo Corret x Base]
WHERE ((([1_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [1_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [1_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO;

-- ===== 1_7 Cruz 1º Manobra x 1º OS Vinc  (SELECT)
SELECT [1_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [1_6 Filtro Passo Válido].COD_OPER_PNB,
       [1_6 Filtro Passo Válido].DTA_PASSO_PNB,
       [1_6 Filtro Passo Válido].NUM_SEQ_PNB,
       [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_CNR,
       [0_1 Base 1ª Reclamação].DTA_RECL_CNR
FROM [1_6 Filtro Passo Válido]
  INNER JOIN [0_1 Base 1ª Reclamação] ON [1_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB = [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR;

-- ===== 1_7 Cruz 1º Manobra x 1º OS Vinc Análise  (SELECT)
SELECT [1_7 Cruz 1º Manobra x 1º OS Vinc].NUM_SEQ_OPER_OS_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc].COD_OPER_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc].DTA_PASSO_PNB AS [DTA_1º_PASSO],
       [1_7 Cruz 1º Manobra x 1º OS Vinc].NUM_SEQ_OPER_CNR,
       [1_7 Cruz 1º Manobra x 1º OS Vinc].DTA_RECL_CNR AS [DTA_1º_OS],
       IIf([DTA_1º_OS] Is Null,"",IIf([COD_OPER_PNB]="ABRIR",([DTA_1º_OS]-[DTA_1º_PASSO])*1440,IIf([DTA_1º_OS]>[DTA_1º_PASSO],0,([DTA_1º_OS]-[DTA_1º_PASSO])*1440))) AS [TEMPO],
       IIf([DTA_1º_OS] Is Null,"",IIf([COD_OPER_PNB]="ABRIR",IIf([TEMPO]<0,"Verificar Abrir",""),IIf([TEMPO]<-120,"Verificar Interr",""))) AS [Análise]
FROM [1_7 Cruz 1º Manobra x 1º OS Vinc];

-- ===== 1_8 1º Manobra x 1º OS Vinc Filtro  (SELECT)
SELECT [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].NUM_SEQ_OPER_OS_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].COD_OPER_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].DTA_1º_PASSO,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].NUM_SEQ_OPER_CNR,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].DTA_1º_OS,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].TEMPO,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].Análise
FROM [1_7 Cruz 1º Manobra x 1º OS Vinc Análise]
WHERE ((([1_7 Cruz 1º Manobra x 1º OS Vinc Análise].Análise)<>""));
