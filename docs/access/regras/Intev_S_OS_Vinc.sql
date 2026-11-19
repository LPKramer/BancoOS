-- Regra Intev_S_OS_Vinc: consulta raiz [4_9_3 Intev S OS Vinc > 80 UCs Filtro] (13 consultas na cadeia)

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

-- ===== 4_3 Filtro Menor Passo  (SELECT)
SELECT [4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [4_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB,
       First([4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [4_2 Cruz Dt Menor Passo x Num Passo]
GROUP BY [4_2 Cruz Dt Menor Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [4_2 Cruz Dt Menor Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 4_4 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 4_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [4_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [4_4 Base Mano Filt Aber Inter].COD_OPER_PNB,
       [4_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [4_4 Base Mano Filt Aber Inter].NUM_SEQ_PNB,
       [4_3 Filtro Menor Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([4_4 Base Mano Filt Aber Inter]![NUM_SEQ_PNB]=[4_3 Filtro Menor Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro],
       [4_4 Base Mano Filt Aber Inter].QTD_UN_CONS_PNB
FROM [4_4 Base Mano Filt Aber Inter]
  INNER JOIN [4_3 Filtro Menor Passo] ON [4_4 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB = [4_3 Filtro Menor Passo].NUM_SEQ_OPER_OS_PNB AND [4_4 Base Mano Filt Aber Inter].DTA_PASSO_PNB = [4_3 Filtro Menor Passo].DTA_PASSO_PNB;

-- ===== 4_6 Filtro Passo Válido  (SELECT)
SELECT [4_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [4_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [4_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [4_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB],
       [4_5 Cruzamento Passo Corret x Base].QTD_UN_CONS_PNB
FROM [4_5 Cruzamento Passo Corret x Base]
WHERE ((([4_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [4_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [4_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [4_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [4_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO, [4_5 Cruzamento Passo Corret x Base].QTD_UN_CONS_PNB;

-- ===== 4_6 Filtro Passo Válido Interr  (SELECT)
SELECT [4_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [4_6 Filtro Passo Válido].COD_OPER_PNB,
       [4_6 Filtro Passo Válido].DTA_PASSO_PNB,
       [4_6 Filtro Passo Válido].NUM_SEQ_PNB,
       [4_6 Filtro Passo Válido].QTD_UN_CONS_PNB
FROM [4_6 Filtro Passo Válido]
WHERE ((([4_6 Filtro Passo Válido].COD_OPER_PNB)="INTERR"));

-- ===== 4_7 Cont OS Vinculada  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Count([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [OS]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 4_8 Cruzamento OS x Ocorrências  (SELECT)
SELECT [4_6 Filtro Passo Válido Interr].NUM_SEQ_OPER_OS_PNB,
       [4_6 Filtro Passo Válido Interr].COD_OPER_PNB,
       [4_6 Filtro Passo Válido Interr].DTA_PASSO_PNB,
       [4_6 Filtro Passo Válido Interr].NUM_SEQ_PNB,
       [4_7 Cont OS Vinculada].OS,
       ([4_6 Filtro Passo Válido Interr]![QTD_UN_CONS_PNB])*1 AS [QTD_UN_CONS_PNB]
FROM [4_6 Filtro Passo Válido Interr]
  LEFT JOIN [4_7 Cont OS Vinculada] ON [4_6 Filtro Passo Válido Interr].NUM_SEQ_OPER_OS_PNB = [4_7 Cont OS Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 4_9_2 Filtro OS > 80 UCs  (SELECT)
SELECT [4_8 Cruzamento OS x Ocorrências].NUM_SEQ_OPER_OS_PNB,
       [4_8 Cruzamento OS x Ocorrências].COD_OPER_PNB,
       [4_8 Cruzamento OS x Ocorrências].DTA_PASSO_PNB,
       [4_8 Cruzamento OS x Ocorrências].NUM_SEQ_PNB,
       [4_8 Cruzamento OS x Ocorrências].OS,
       [4_8 Cruzamento OS x Ocorrências].QTD_UN_CONS_PNB
FROM [4_8 Cruzamento OS x Ocorrências]
WHERE ((([4_8 Cruzamento OS x Ocorrências].QTD_UN_CONS_PNB)>0));

-- ===== 4_9_2 Intev S OS Vinc > 80 UCs  (SELECT)
SELECT [4_9_2 Filtro OS > 80 UCs].NUM_SEQ_OPER_OS_PNB,
       [4_9_2 Filtro OS > 80 UCs].COD_OPER_PNB,
       [4_9_2 Filtro OS > 80 UCs].DTA_PASSO_PNB,
       [4_9_2 Filtro OS > 80 UCs].NUM_SEQ_PNB,
       [4_9_2 Filtro OS > 80 UCs].OS,
       [4_9_2 Filtro OS > 80 UCs].QTD_UN_CONS_PNB,
       IIf([4_9_2 Filtro OS > 80 UCs]![OS] Is Null,"Verificar","") AS [FILTRO]
FROM [4_9_2 Filtro OS > 80 UCs];

-- ===== 4_9_3 Intev S OS Vinc > 80 UCs Filtro  (SELECT)
SELECT [4_9_2 Intev S OS Vinc > 80 UCs].NUM_SEQ_OPER_OS_PNB,
       [4_9_2 Intev S OS Vinc > 80 UCs].COD_OPER_PNB,
       [4_9_2 Intev S OS Vinc > 80 UCs].DTA_PASSO_PNB,
       [4_9_2 Intev S OS Vinc > 80 UCs].NUM_SEQ_PNB,
       [4_9_2 Intev S OS Vinc > 80 UCs].OS,
       [4_9_2 Intev S OS Vinc > 80 UCs].QTD_UN_CONS_PNB,
       IIf([4_9_2 Intev S OS Vinc > 80 UCs]![OS] Is Null,"Verificar",Null) AS [Análise]
FROM [4_9_2 Intev S OS Vinc > 80 UCs]
GROUP BY [4_9_2 Intev S OS Vinc > 80 UCs].NUM_SEQ_OPER_OS_PNB, [4_9_2 Intev S OS Vinc > 80 UCs].COD_OPER_PNB, [4_9_2 Intev S OS Vinc > 80 UCs].DTA_PASSO_PNB, [4_9_2 Intev S OS Vinc > 80 UCs].NUM_SEQ_PNB, [4_9_2 Intev S OS Vinc > 80 UCs].OS, [4_9_2 Intev S OS Vinc > 80 UCs].QTD_UN_CONS_PNB, IIf([4_9_2 Intev S OS Vinc > 80 UCs]![OS] Is Null,"Verificar",Null), [4_9_2 Intev S OS Vinc > 80 UCs].FILTRO
HAVING (((IIf([4_9_2 Intev S OS Vinc > 80 UCs]![OS] Is Null,"Verificar",Null))="Verificar"));
