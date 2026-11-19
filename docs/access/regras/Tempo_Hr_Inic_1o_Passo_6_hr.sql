-- Regra Tempo_Hr_Inic_1o_Passo_6_hr: consulta raiz [5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro] (10 consultas na cadeia)

-- ===== 5_0 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 5_1 Dt Menor Passo  (SELECT)
SELECT [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       Min([5_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [5_0 Base Mano Filt Aber Inter]
GROUP BY [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 5_2 Cruz Dt Menor Passo x Num Passo  (SELECT)
SELECT [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [5_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [5_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
FROM [5_1 Dt Menor Passo]
  INNER JOIN [5_0 Base Mano Filt Aber Inter] ON [5_1 Dt Menor Passo].NUM_SEQ_OPER_OS_PNB = [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [5_1 Dt Menor Passo].DTA_PASSO_PNB = [5_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB
GROUP BY [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [5_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB, [5_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
ORDER BY [5_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [5_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB;

-- ===== 5_3 Filtro Menor Passo  (SELECT)
SELECT [5_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [5_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB,
       First([5_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [5_2 Cruz Dt Menor Passo x Num Passo]
GROUP BY [5_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [5_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 5_4 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 5_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [5_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [5_4 Base Mano Filt Aber Inter].COD_OPER_PNB,
       [5_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [5_4 Base Mano Filt Aber Inter].NUM_SEQ_PNB,
       [5_3 Filtro Menor Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([5_4 Base Mano Filt Aber Inter]![NUM_SEQ_PNB]=[5_3 Filtro Menor Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro],
       [5_4 Base Mano Filt Aber Inter].QTD_UN_CONS_PNB
FROM [5_3 Filtro Menor Passo]
  INNER JOIN [5_4 Base Mano Filt Aber Inter] ON [5_3 Filtro Menor Passo].NUM_SEQ_OPER_OS_PNB = [5_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [5_3 Filtro Menor Passo].DTA_PASSO_PNB = [5_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB;

-- ===== 5_6 Filtro Passo Válido  (SELECT)
SELECT [5_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [5_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [5_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [5_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB],
       [5_5 Cruzamento Passo Corret x Base].QTD_UN_CONS_PNB
FROM [5_5 Cruzamento Passo Corret x Base]
WHERE ((([5_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [5_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [5_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [5_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [5_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO, [5_5 Cruzamento Passo Corret x Base].QTD_UN_CONS_PNB;

-- ===== 5_7 Hr Menor Passo x Hr Início  (SELECT)
SELECT [5_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [5_6 Filtro Passo Válido].NUM_SEQ_PNB,
       [1 Tabela_Intervenção].DTA_INIC_MNB,
       [5_6 Filtro Passo Válido].DTA_PASSO_PNB
FROM [5_6 Filtro Passo Válido]
  INNER JOIN [1 Tabela_Intervenção] ON [5_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB = [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB;

-- ===== 5_9 Dif Hr Inicio x 1º Passo Atv > 6 h  (SELECT)
SELECT [5_7 Hr Menor Passo x Hr Início].NUM_SEQ_OPER_OS_PNB,
       [5_7 Hr Menor Passo x Hr Início].DTA_INIC_MNB,
       [5_7 Hr Menor Passo x Hr Início].DTA_PASSO_PNB,
       Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440) AS [DIFERENÇA]
FROM [5_7 Hr Menor Passo x Hr Início]
WHERE (((Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440))>360))
GROUP BY [5_7 Hr Menor Passo x Hr Início].NUM_SEQ_OPER_OS_PNB, [5_7 Hr Menor Passo x Hr Início].DTA_INIC_MNB, [5_7 Hr Menor Passo x Hr Início].DTA_PASSO_PNB, Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440);

-- ===== 5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro  (SELECT)
SELECT [5_9 Dif Hr Inicio x 1º Passo Atv > 6 h].NUM_SEQ_OPER_OS_PNB,
       [5_9 Dif Hr Inicio x 1º Passo Atv > 6 h].DTA_INIC_MNB,
       [5_9 Dif Hr Inicio x 1º Passo Atv > 6 h].DTA_PASSO_PNB,
       [5_9 Dif Hr Inicio x 1º Passo Atv > 6 h].DIFERENÇA,
       IIf([DIFERENÇA]>360,"Verificar","") AS [Análise]
FROM [5_9 Dif Hr Inicio x 1º Passo Atv > 6 h];
