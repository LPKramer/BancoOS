-- Regra _tma_tratado: consulta raiz [99 Intev Unificar Filtros - TMA Tratado] (109 consultas na cadeia)

-- ===== 10_0 Base_Manobra_Elemento  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Manobra].COD_INS_SEC_INS,
       Left([COD_INS_SEC_INS],2) AS [TIPO],
       IIf(Right(Left([COD_INS_SEC_INS],4),1)="R","SIM","") AS [DJ],
       [1 Tabela_Manobra].COD_ELE_PNB,
       IIf([TIPO]="56",IIf([COD_ELE_PNB]="TR","Sim","")) AS [ANÁLISE],
       IIf([TIPO]<>"56","Sim",[ANÁLISE]) AS [ANALISE_FIM],
       [1 Tabela_Manobra].STA_EXEC_PNB
FROM [1 Tabela_Manobra]
WHERE (((Left([COD_INS_SEC_INS],2)) In ('67','22','02','56')) AND (([1 Tabela_Manobra].COD_ELE_PNB) In ('TR','CH')) AND (([1 Tabela_Manobra].STA_EXEC_PNB)<>"Passo Cancelado"));

-- ===== 10_1 Base_Manobra_Elemento_Remove_DJ  (SELECT)
SELECT [10_0 Base_Manobra_Elemento].NUM_SEQ_OPER_OS_PNB,
       [10_0 Base_Manobra_Elemento].COD_INS_SEC_INS,
       [10_0 Base_Manobra_Elemento].TIPO,
       [10_0 Base_Manobra_Elemento].ANALISE_FIM
FROM [10_0 Base_Manobra_Elemento]
WHERE ((([10_0 Base_Manobra_Elemento].DJ)=""))
GROUP BY [10_0 Base_Manobra_Elemento].NUM_SEQ_OPER_OS_PNB, [10_0 Base_Manobra_Elemento].COD_INS_SEC_INS, [10_0 Base_Manobra_Elemento].TIPO, [10_0 Base_Manobra_Elemento].ANALISE_FIM;

-- ===== 10_2 Base_Manobra_Elemento_Remove_DJ_Agrup  (SELECT)
SELECT [10_1 Base_Manobra_Elemento_Remove_DJ].NUM_SEQ_OPER_OS_PNB,
       Count([10_1 Base_Manobra_Elemento_Remove_DJ].COD_INS_SEC_INS) AS [AGRUP]
FROM [10_1 Base_Manobra_Elemento_Remove_DJ]
WHERE ((([10_1 Base_Manobra_Elemento_Remove_DJ].ANALISE_FIM)="Sim"))
GROUP BY [10_1 Base_Manobra_Elemento_Remove_DJ].NUM_SEQ_OPER_OS_PNB;

-- ===== 10_3 Man Com Elem Partic  (SELECT)
SELECT [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].NUM_SEQ_OPER_OS_PNB,
       [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].AGRUP,
       IIf([AGRUP]>0,"Verificar","") AS [ANÁLISE],
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS
FROM [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup]
  INNER JOIN [1 Tabela_Intervenção] ON [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].NUM_SEQ_OPER_OS_PNB = [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB
WHERE ((([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));

-- ===== 11_0 Base Mano Filt Fech Reest  (SELECT)
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
WHERE ((([1 Tabela_Manobra].COD_OPER_PNB) In ("FECHAR","REESTAB")) AND (([1 Tabela_Manobra].STA_EXEC_PNB)<>"Passo Cancelado"))
ORDER BY [1 Tabela_Manobra].DTA_PASSO_PNB;

-- ===== 11_1 Dt Maior Passo  (SELECT)
SELECT [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB,
       Max([11_0 Base Mano Filt Fech Reest].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [11_0 Base Mano Filt Fech Reest]
GROUP BY [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB;

-- ===== 11_2 Cruz Dt Maior Passo x Num Passo  (SELECT)
SELECT [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB,
       [11_0 Base Mano Filt Fech Reest].DTA_PASSO_PNB,
       [11_0 Base Mano Filt Fech Reest].NUM_SEQ_PNB
FROM [11_1 Dt Maior Passo]
  INNER JOIN [11_0 Base Mano Filt Fech Reest] ON [11_1 Dt Maior Passo].NUM_SEQ_OPER_OS_PNB = [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB AND [11_1 Dt Maior Passo].DTA_PASSO_PNB = [11_0 Base Mano Filt Fech Reest].DTA_PASSO_PNB
GROUP BY [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB, [11_0 Base Mano Filt Fech Reest].DTA_PASSO_PNB, [11_0 Base Mano Filt Fech Reest].NUM_SEQ_PNB
ORDER BY [11_0 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB, [11_0 Base Mano Filt Fech Reest].NUM_SEQ_PNB;

-- ===== 11_3 Filtro Maior Passo  (SELECT)
SELECT [11_2 Cruz Dt Maior Passo x Num Passo].NUM_SEQ_OPER_OS_PNB,
       [11_2 Cruz Dt Maior Passo x Num Passo].DTA_PASSO_PNB,
       First([11_2 Cruz Dt Maior Passo x Num Passo].NUM_SEQ_PNB) AS [NUM_SEQ_PNB]
FROM [11_2 Cruz Dt Maior Passo x Num Passo]
GROUP BY [11_2 Cruz Dt Maior Passo x Num Passo].NUM_SEQ_OPER_OS_PNB, [11_2 Cruz Dt Maior Passo x Num Passo].DTA_PASSO_PNB;

-- ===== 11_4 Base Mano Filt Fech Reest  (SELECT)
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

-- ===== 11_5 Cruzamento Passo Corret x Base  (SELECT)
SELECT [11_4 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB,
       [11_4 Base Mano Filt Fech Reest].COD_OPER_PNB,
       [11_4 Base Mano Filt Fech Reest].DTA_PASSO_PNB,
       [11_4 Base Mano Filt Fech Reest].NUM_SEQ_PNB,
       [11_3 Filtro Maior Passo].NUM_SEQ_PNB AS [NUM_SEQ_PNB_CORRETO],
       IIf([11_4 Base Mano Filt Fech Reest]![NUM_SEQ_PNB]=[11_3 Filtro Maior Passo]![NUM_SEQ_PNB],"SIM",Null) AS [Filtro],
       [11_4 Base Mano Filt Fech Reest].[']
FROM [11_4 Base Mano Filt Fech Reest]
  INNER JOIN [11_3 Filtro Maior Passo] ON [11_4 Base Mano Filt Fech Reest].DTA_PASSO_PNB = [11_3 Filtro Maior Passo].DTA_PASSO_PNB AND [11_4 Base Mano Filt Fech Reest].NUM_SEQ_OPER_OS_PNB = [11_3 Filtro Maior Passo].NUM_SEQ_OPER_OS_PNB;

-- ===== 11_6 Filtro Passo Válido  (SELECT)
SELECT [11_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [11_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [11_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [11_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB],
       [11_5 Cruzamento Passo Corret x Base].[']
FROM [11_5 Cruzamento Passo Corret x Base]
WHERE ((([11_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [11_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [11_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [11_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [11_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO, [11_5 Cruzamento Passo Corret x Base].['];

-- ===== 11_7 Maior Data  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Max([1 Tabela_Individual_Vinculada].DTA_RECL_CNR) AS [DTA_RECL_CNR]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 11_8 Base Última Reclamação  (SELECT)
SELECT [11_7 Maior Data].NUM_SEQ_OPER_INTER_CNR,
       Max([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [NUM_SEQ_OPER_CNR],
       [11_7 Maior Data].DTA_RECL_CNR
FROM [11_7 Maior Data]
  INNER JOIN [1 Tabela_Individual_Vinculada] ON [11_7 Maior Data].NUM_SEQ_OPER_INTER_CNR = [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR AND [11_7 Maior Data].DTA_RECL_CNR = [1 Tabela_Individual_Vinculada].DTA_RECL_CNR
GROUP BY [11_7 Maior Data].NUM_SEQ_OPER_INTER_CNR, [11_7 Maior Data].DTA_RECL_CNR, [1 Tabela_Individual_Vinculada].TIPO_VINC
HAVING ((([1 Tabela_Individual_Vinculada].TIPO_VINC)<>"Vinc.contab."));

-- ===== 11_9 Cruzamento Último Passo x Última OS  (SELECT)
SELECT [11_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB,
       [11_6 Filtro Passo Válido].COD_OPER_PNB,
       [11_6 Filtro Passo Válido].DTA_PASSO_PNB,
       [11_8 Base Última Reclamação].NUM_SEQ_OPER_CNR,
       [11_8 Base Última Reclamação].DTA_RECL_CNR,
       IIf([DTA_RECL_CNR]>[DTA_PASSO_PNB],"Verificar","") AS [ANÁLISE]
FROM [11_6 Filtro Passo Válido]
  INNER JOIN [11_8 Base Última Reclamação] ON [11_6 Filtro Passo Válido].NUM_SEQ_OPER_OS_PNB = [11_8 Base Última Reclamação].NUM_SEQ_OPER_INTER_CNR;

-- ===== 11_10 Cruzamento Último Passo x Última OS - Filtro  (SELECT)
SELECT [11_9 Cruzamento Último Passo x Última OS].NUM_SEQ_OPER_OS_PNB,
       [11_9 Cruzamento Último Passo x Última OS].COD_OPER_PNB,
       [11_9 Cruzamento Último Passo x Última OS].DTA_PASSO_PNB,
       [11_9 Cruzamento Último Passo x Última OS].NUM_SEQ_OPER_CNR,
       [11_9 Cruzamento Último Passo x Última OS].DTA_RECL_CNR,
       [11_9 Cruzamento Último Passo x Última OS].ANÁLISE
FROM [11_9 Cruzamento Último Passo x Última OS]
WHERE ((([11_9 Cruzamento Último Passo x Última OS].ANÁLISE)<>""));

-- ===== 12_0 Ocorrência Sem GA - Impro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].AGRUP,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([AGRUP] Is Null,IIf([COD_TIPO_CONCL_COS]="004","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
  LEFT JOIN [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].NUM_SEQ_OPER_OS_PNB
WHERE ((([10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].AGRUP) Is Null) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="004"));

-- ===== 15_0_1 UC_Acessante  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COELBA,
       IIf([1 Tabela_Intervenção]![COELBA] Is Null,Null,"Verificar") AS [OS_Acessante]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COELBA) Is Not Null));

-- ===== 16_0_1 Int_Classi_Externo  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_TIPO_ORIG_INTV_MNB,
       IIf([1 Tabela_Intervenção]![COD_TIPO_ORIG_INTV_MNB] Is Null,Null,"Verificar") AS [OS_Externa]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_TIPO_ORIG_INTV_MNB)="EX"));

-- ===== 17_1 Intv_Origem_TR_Zona  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_ELE_MNB,
       [1 Tabela_Intervenção].ZONA
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_ELE_MNB)="TR"));

-- ===== 17_2 Cruz_Zona_UC_x_Zona_TR  (SELECT)
SELECT [17_1 Intv_Origem_TR_Zona].NUM_SEQ_OPER_OS_MNB,
       [17_1 Intv_Origem_TR_Zona].COD_ELE_MNB,
       [17_1 Intv_Origem_TR_Zona].ZONA AS [ZONA_TR],
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       IIf([1 Tabela_Individual_Vinculada]![DES_BAI_CNR]="RURAL","RR",[1 Tabela_Individual_Vinculada]![ZONA]) AS [ZONA_UC]
FROM [17_1 Intv_Origem_TR_Zona]
  INNER JOIN [1 Tabela_Individual_Vinculada] ON [17_1 Intv_Origem_TR_Zona].NUM_SEQ_OPER_OS_MNB = [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 17_3 Análise_Diverg_Zonas  (SELECT)
SELECT [17_2 Cruz_Zona_UC_x_Zona_TR].NUM_SEQ_OPER_OS_MNB,
       [17_2 Cruz_Zona_UC_x_Zona_TR].ZONA_TR,
       [17_2 Cruz_Zona_UC_x_Zona_TR].ZONA_UC,
       IIf([17_2 Cruz_Zona_UC_x_Zona_TR]![ZONA_TR]=[17_2 Cruz_Zona_UC_x_Zona_TR]![ZONA_UC],Null,"Verificar") AS [Intv_TR_Zona_Div_UC]
FROM [17_2 Cruz_Zona_UC_x_Zona_TR];

-- ===== 17_4 Filtro_Verificar  (SELECT)
SELECT [17_3 Análise_Diverg_Zonas].NUM_SEQ_OPER_OS_MNB,
       [17_3 Análise_Diverg_Zonas].Intv_TR_Zona_Div_UC
FROM [17_3 Análise_Diverg_Zonas]
WHERE ((([17_3 Análise_Diverg_Zonas].Intv_TR_Zona_Div_UC)="Verificar"));

-- ===== 17_5 Zona_TR_Dif_Zona_UC_Final  (SELECT)
SELECT [17_4 Filtro_Verificar].NUM_SEQ_OPER_OS_MNB,
       [17_4 Filtro_Verificar].Intv_TR_Zona_Div_UC
FROM [17_4 Filtro_Verificar]
GROUP BY [17_4 Filtro_Verificar].NUM_SEQ_OPER_OS_MNB, [17_4 Filtro_Verificar].Intv_TR_Zona_Div_UC;

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

-- ===== 1_10 Filtro Passo Válido Interr  (SELECT)
SELECT [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB,
       [1_5 Cruzamento Passo Corret x Base].COD_OPER_PNB,
       [1_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB,
       [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO AS [NUM_SEQ_PNB]
FROM [1_5 Cruzamento Passo Corret x Base]
WHERE ((([1_5 Cruzamento Passo Corret x Base].Filtro) Is Not Null))
GROUP BY [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_OPER_OS_PNB, [1_5 Cruzamento Passo Corret x Base].COD_OPER_PNB, [1_5 Cruzamento Passo Corret x Base].DTA_PASSO_PNB, [1_5 Cruzamento Passo Corret x Base].NUM_SEQ_PNB_CORRETO
HAVING ((([1_5 Cruzamento Passo Corret x Base].COD_OPER_PNB)="INTERR"));

-- ===== 1_11 Cruz 1º Manobra Interr x 1º OS Vinc  (SELECT)
SELECT [1_10 Filtro Passo Válido Interr].NUM_SEQ_OPER_OS_PNB,
       [1_10 Filtro Passo Válido Interr].COD_OPER_PNB,
       [1_10 Filtro Passo Válido Interr].DTA_PASSO_PNB,
       [1_10 Filtro Passo Válido Interr].NUM_SEQ_PNB,
       [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_CNR,
       [0_1 Base 1ª Reclamação].DTA_RECL_CNR
FROM [1_10 Filtro Passo Válido Interr]
  INNER JOIN [0_1 Base 1ª Reclamação] ON [1_10 Filtro Passo Válido Interr].NUM_SEQ_OPER_OS_PNB = [0_1 Base 1ª Reclamação].NUM_SEQ_OPER_INTER_CNR;

-- ===== 1_12 Cruzamento Datas  (SELECT)
SELECT [1_11 Cruz 1º Manobra Interr x 1º OS Vinc].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Intervenção].DTA_INIC_MNB,
       [1_11 Cruz 1º Manobra Interr x 1º OS Vinc].DTA_PASSO_PNB,
       [1_11 Cruz 1º Manobra Interr x 1º OS Vinc].DTA_RECL_CNR
FROM [1_11 Cruz 1º Manobra Interr x 1º OS Vinc]
  INNER JOIN [1 Tabela_Intervenção] ON [1_11 Cruz 1º Manobra Interr x 1º OS Vinc].NUM_SEQ_OPER_OS_PNB = [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB;

-- ===== 1_13 Análise Datas  (SELECT)
SELECT [1_12 Cruzamento Datas].NUM_SEQ_OPER_OS_PNB,
       [1_12 Cruzamento Datas].DTA_INIC_MNB,
       [1_12 Cruzamento Datas].DTA_PASSO_PNB,
       [1_12 Cruzamento Datas].DTA_RECL_CNR,
       IIf([DTA_INIC_MNB]=[DTA_PASSO_PNB],IIf([DTA_PASSO_PNB]=[DTA_RECL_CNR],Null,"Verificar"),"Verificar") AS [ANÁLISE]
FROM [1_12 Cruzamento Datas]
WHERE (((IIf([DTA_INIC_MNB]=[DTA_PASSO_PNB],IIf([DTA_PASSO_PNB]=[DTA_RECL_CNR],Null,"Verificar"),"Verificar")) Is Not Null));

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

-- ===== 5_8 Dif Hr Inicio x 1º Passo Atv = 1 min  (SELECT)
SELECT [5_7 Hr Menor Passo x Hr Início].NUM_SEQ_OPER_OS_PNB,
       [5_7 Hr Menor Passo x Hr Início].DTA_INIC_MNB,
       [5_7 Hr Menor Passo x Hr Início].DTA_PASSO_PNB,
       Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440) AS [DIFERENÇA]
FROM [5_7 Hr Menor Passo x Hr Início]
WHERE (((Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440))=1))
GROUP BY [5_7 Hr Menor Passo x Hr Início].NUM_SEQ_OPER_OS_PNB, [5_7 Hr Menor Passo x Hr Início].DTA_INIC_MNB, [5_7 Hr Menor Passo x Hr Início].DTA_PASSO_PNB, Round(([5_7 Hr Menor Passo x Hr Início]![DTA_PASSO_PNB]-[5_7 Hr Menor Passo x Hr Início]![DTA_INIC_MNB])*1440);

-- ===== 5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro  (SELECT)
SELECT [5_8 Dif Hr Inicio x 1º Passo Atv = 1 min].NUM_SEQ_OPER_OS_PNB,
       [5_8 Dif Hr Inicio x 1º Passo Atv = 1 min].DTA_INIC_MNB,
       [5_8 Dif Hr Inicio x 1º Passo Atv = 1 min].DTA_PASSO_PNB,
       [5_8 Dif Hr Inicio x 1º Passo Atv = 1 min].DIFERENÇA,
       IIf([DIFERENÇA]=1,"Verificar","") AS [Análise]
FROM [5_8 Dif Hr Inicio x 1º Passo Atv = 1 min];

-- ===== 1_14 Análise Datas Retirar = 1 min  (SELECT)
SELECT [1_13 Análise Datas].NUM_SEQ_OPER_OS_PNB,
       [1_13 Análise Datas].DTA_INIC_MNB,
       [1_13 Análise Datas].DTA_PASSO_PNB,
       [1_13 Análise Datas].DTA_RECL_CNR,
       [1_13 Análise Datas].ANÁLISE
FROM [1_13 Análise Datas]
  LEFT JOIN [5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro] ON [1_13 Análise Datas].NUM_SEQ_OPER_OS_PNB = [5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro].NUM_SEQ_OPER_OS_PNB
WHERE ((([5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro].NUM_SEQ_OPER_OS_PNB) Is Null))
GROUP BY [1_13 Análise Datas].NUM_SEQ_OPER_OS_PNB, [1_13 Análise Datas].DTA_INIC_MNB, [1_13 Análise Datas].DTA_PASSO_PNB, [1_13 Análise Datas].DTA_RECL_CNR, [1_13 Análise Datas].ANÁLISE;

-- ===== 1_15 Análise Datas Retirar entre 2h  (SELECT)
SELECT [1_14 Análise Datas Retirar = 1 min].NUM_SEQ_OPER_OS_PNB,
       [1_14 Análise Datas Retirar = 1 min].DTA_INIC_MNB,
       [1_14 Análise Datas Retirar = 1 min].DTA_PASSO_PNB,
       [1_14 Análise Datas Retirar = 1 min].DTA_RECL_CNR,
       [1_14 Análise Datas Retirar = 1 min].ANÁLISE,
       ([DTA_RECL_CNR]-[DTA_INIC_MNB])*1440 AS [DIF_HR_INIC],
       ([DTA_RECL_CNR]-[DTA_PASSO_PNB])*1440 AS [DIF_PASSO_INIC]
FROM [1_14 Análise Datas Retirar = 1 min];

-- ===== 1_16 Análise Datas Retirar entre 2h - Filtro  (SELECT)
SELECT [1_15 Análise Datas Retirar entre 2h].NUM_SEQ_OPER_OS_PNB,
       [1_15 Análise Datas Retirar entre 2h].DTA_INIC_MNB,
       [1_15 Análise Datas Retirar entre 2h].DTA_PASSO_PNB,
       [1_15 Análise Datas Retirar entre 2h].DTA_RECL_CNR,
       [1_15 Análise Datas Retirar entre 2h].ANÁLISE,
       [1_15 Análise Datas Retirar entre 2h].DIF_HR_INIC,
       [1_15 Análise Datas Retirar entre 2h].DIF_PASSO_INIC,
       IIf([DTA_INIC_MNB]<>[DTA_PASSO_PNB],"Dif Man e Pass","") AS [DIF_PASS_MAN],
       IIf([DIF_PASS_MAN]="",IIf([DIF_PASSO_INIC]<-120,"Dif Pass OS",IIf([DIF_PASSO_INIC]>120,"Dif Passo OS",""))) AS [DIF_PASSO_INIC_A],
       IIf([DIF_PASSO_INIC_A]="",IIf([DIF_HR_INIC]<-120,"Dif Inic OS",IIf([DIF_HR_INIC]>120,"Dif Inic OS",""))) AS [DIF_HR_INIC_A]
FROM [1_15 Análise Datas Retirar entre 2h];

-- ===== 1_17 Análise Datas Retirar entre 2h - Filtro Remove  (SELECT)
SELECT [1_16 Análise Datas Retirar entre 2h - Filtro].NUM_SEQ_OPER_OS_PNB,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DTA_INIC_MNB,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DTA_PASSO_PNB,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DTA_RECL_CNR,
       [1_16 Análise Datas Retirar entre 2h - Filtro].ANÁLISE,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DIF_HR_INIC,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DIF_PASSO_INIC,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DIF_PASS_MAN,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DIF_PASSO_INIC_A,
       [1_16 Análise Datas Retirar entre 2h - Filtro].DIF_HR_INIC_A,
       IIf([DIF_PASS_MAN]<>"",[DIF_PASS_MAN],IIf([DIF_PASSO_INIC_A]<>"",[DIF_PASSO_INIC_A],[DIF_HR_INIC_A])) AS [ANÁLISE_F]
FROM [1_16 Análise Datas Retirar entre 2h - Filtro];

-- ===== 1_17 Análise Datas Retirar entre 2h - Final  (SELECT)
SELECT [1_17 Análise Datas Retirar entre 2h - Filtro Remove].NUM_SEQ_OPER_OS_PNB,
       [1_17 Análise Datas Retirar entre 2h - Filtro Remove].ANÁLISE_F AS [ANÁLISE]
FROM [1_17 Análise Datas Retirar entre 2h - Filtro Remove]
WHERE ((([1_17 Análise Datas Retirar entre 2h - Filtro Remove].ANÁLISE_F)<>"" & "" & ""));

-- ===== 3_0 TMA  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].TMA,
       IIf([TMA]>1440,"Verificar",Null) AS [STATUS],
       [1 Tabela_Intervenção]![DES_CAUSA_INTER_CAU] & "-" & [1 Tabela_Intervenção]![DES_SUB_CAUSA_INTER_SCR] AS [CAUSA]
FROM [1 Tabela_Intervenção];

-- ===== 3_0 TMA Filtro > 1440  (SELECT)
SELECT [3_0 TMA].NUM_SEQ_OPER_OS_MNB,
       [3_0 TMA].TMA,
       [3_0 TMA].STATUS
FROM [3_0 TMA]
WHERE ((([3_0 TMA].STATUS)="Verificar") AND (([3_0 TMA].CAUSA) Not In ("TRANSFORMADOR-QUEIMADO POR SOBRECARGA","TRANSFORMADOR-QUEIMADO POR DESCARGA ATMOSFERICA","TRANSFORMADOR-QUEIMADO POR PASSARO/ANIMAL","TRANSFORMADOR-QUEIMADO POR CURTO NA RD","TRANSFORMADOR-QUEIMADO POR CAUSA NAO IDENTIFICADA")));

-- ===== 3_0 TMA Filtro > 1440 - Mais de 1 Filtro  (SELECT)
SELECT [3_0 TMA Filtro > 1440].NUM_SEQ_OPER_OS_MNB,
       [3_0 TMA Filtro > 1440].STATUS
FROM [3_0 TMA Filtro > 1440];

-- ===== 3_0 TMA Filtro > 1440 - Mais de 1 Filtro - Filtrado  (SELECT)
SELECT [3_0 TMA Filtro > 1440 - Mais de 1 Filtro].NUM_SEQ_OPER_OS_MNB,
       [3_0 TMA Filtro > 1440 - Mais de 1 Filtro].STATUS
FROM [3_0 TMA Filtro > 1440 - Mais de 1 Filtro];

-- ===== 0_0 Soma Clientes Interr  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       Sum([1 Tabela_Manobra].[']) AS [SomaDeQTD_UN_CONS_PNB]
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].COD_OPER_PNB
HAVING ((([1 Tabela_Manobra].COD_OPER_PNB) In ("ABRIR","INTERR")));

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

-- ===== 2_0 TR Próprio Intv Proced  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].TIPO_TR,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([1 Tabela_Intervenção]![TIPO_TR]="PRÓPRIO","Verificar","") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].TIPO_TR)="PRÓPRIO") AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));

-- ===== 2_1 Intev Impro Causa Pro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([COD_CAUSA_MNB]<>"IM",IIf([COD_TIPO_CONCL_COS]="004","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_SUB_CAUSA_MNB) Not In ("MV","EY","CB","KI","KG","KF","KK","KH","KE","KJ")) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="004"));

-- ===== 2_2 Intev Pro Causa Impro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([COD_CAUSA_MNB]="IM",IIf([COD_TIPO_CONCL_COS]="000","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_SUB_CAUSA_MNB) In ("MV","EY","CB","KI","KG","KF","KK","KH","KE","KJ")) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));

-- ===== 2_3 dec >= 0,001  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].DEC,
       IIf([1 Tabela_Intervenção]![DEC]>="0,001","Verificar","") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].DEC)>="0,001"));

-- ===== 2_4 TMD = 0  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].DTA_VERI_EQP_MNB,
       [1 Tabela_Intervenção].DTA_DLCT_EQP_MNB,
       [1 Tabela_Intervenção]![DTA_DLCT_EQP_MNB]-[1 Tabela_Intervenção]![DTA_VERI_EQP_MNB] AS [TMD],
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS
FROM [1 Tabela_Intervenção]
GROUP BY [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB, [1 Tabela_Intervenção].DTA_VERI_EQP_MNB, [1 Tabela_Intervenção].DTA_DLCT_EQP_MNB, [1 Tabela_Intervenção]![DTA_DLCT_EQP_MNB]-[1 Tabela_Intervenção]![DTA_VERI_EQP_MNB], [1 Tabela_Intervenção].COD_TIPO_CONCL_COS
HAVING ((([1 Tabela_Intervenção]!DTA_DLCT_EQP_MNB-[1 Tabela_Intervenção]!DTA_VERI_EQP_MNB)=0) And (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));

-- ===== 2_5 TMD = 0 Análise  (SELECT)
SELECT [2_4 TMD = 0].NUM_SEQ_OPER_OS_MNB,
       [2_4 TMD = 0].DTA_VERI_EQP_MNB,
       [2_4 TMD = 0].DTA_DLCT_EQP_MNB,
       [2_4 TMD = 0].TMD,
       [2_4 TMD = 0].COD_TIPO_CONCL_COS,
       IIf([2_4 TMD = 0]![TMD]=0,IIf([2_4 TMD = 0]![COD_TIPO_CONCL_COS]="000","Verificar",""),"") AS [Análise]
FROM [2_4 TMD = 0];

-- ===== 2_6 Comp > R$ 1000  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       Comp_Ocorrências.MULTA_OS
FROM [1 Tabela_Intervenção]
  INNER JOIN [Comp_Ocorrências] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI
WHERE (((Comp_Ocorrências.MULTA_OS)>=1000));

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

-- ===== 4_9 Filtro OS > 80 UCs  (SELECT)
SELECT [4_8 Cruzamento OS x Ocorrências].NUM_SEQ_OPER_OS_PNB,
       [4_8 Cruzamento OS x Ocorrências].COD_OPER_PNB,
       [4_8 Cruzamento OS x Ocorrências].DTA_PASSO_PNB,
       [4_8 Cruzamento OS x Ocorrências].NUM_SEQ_PNB,
       [4_8 Cruzamento OS x Ocorrências].OS,
       [4_8 Cruzamento OS x Ocorrências].QTD_UN_CONS_PNB
FROM [4_8 Cruzamento OS x Ocorrências]
WHERE ((([4_8 Cruzamento OS x Ocorrências].QTD_UN_CONS_PNB)>40));

-- ===== 4_9_1 Intev < 3 OS Vinc > 80 UCs  (SELECT)
SELECT [4_9 Filtro OS > 80 UCs].NUM_SEQ_OPER_OS_PNB,
       [4_9 Filtro OS > 80 UCs].COD_OPER_PNB,
       [4_9 Filtro OS > 80 UCs].DTA_PASSO_PNB,
       [4_9 Filtro OS > 80 UCs].NUM_SEQ_PNB,
       [4_9 Filtro OS > 80 UCs].OS,
       [4_9 Filtro OS > 80 UCs].QTD_UN_CONS_PNB,
       IIf([OS]<3,"Verificar","") AS [Análise]
FROM [4_9 Filtro OS > 80 UCs]
WHERE ((([4_9 Filtro OS > 80 UCs].OS)<=2));

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

-- ===== 99 Intev Unificar Filtros  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB AS [NUM_SEQ_OPER_OS],
       [0_7 Calc Diferença Tempo OS Filtro]![Análise] AS [DIF_1ª_2ª_RCM_1h],
       [1_8 1º Manobra x 1º OS Vinc Filtro]![Análise] AS [DIF_1ª_Man_1ª_OS_Vinc_2h],
       [2_0 TR Próprio Intv Proced]![Análise] AS [TR_Próprio_OS_Proc],
       [2_1 Intev Impro Causa Pro]![Análise] AS [Intev_Impro_Causa_Proc],
       [2_2 Intev Pro Causa Impro]![Análise] AS [Intev_Proc_Causa_Impro],
       [2_3 dec >= 0,001]![Análise] AS [DEC_>_0,001],
       [2_5 TMD = 0 Análise]![Análise] AS [TMD_0],
       [3_0 TMA]![STATUS] AS [TMA_>_1440],
       [4_9_1 Intev < 3 OS Vinc > 80 UCs]![Análise] AS [Intev_<_3_OS_Vinc_>_50_UCs],
       [4_9_3 Intev S OS Vinc > 80 UCs Filtro]![Análise] AS [Intev_S_OS_Vinc],
       [5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro]![Análise] AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro]![Análise] AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [9_9_1 Análise OS > UCs Interr Filtro]![Análise] AS [OS_Vinc_UCs_Interr],
       IIf([8_7 Filtro Passo Válido Filtro]![NUM_SEQ_OPER_OS_PNB] Is Not Null,"Verificar","") AS [Intev_0_UCs_Inter],
       IIf([2_6 Comp > R$ 1000]![MULTA_OS]>500,"Verificar","") AS [Comp_>_500]
FROM [1 Tabela_Intervenção]
  LEFT JOIN [0_7 Calc Diferença Tempo OS Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [0_7 Calc Diferença Tempo OS Filtro].NUM_SEQ_OPER_INTER_CNR
  LEFT JOIN [1_8 1º Manobra x 1º OS Vinc Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [1_8 1º Manobra x 1º OS Vinc Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [2_0 TR Próprio Intv Proced] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_0 TR Próprio Intv Proced].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [2_1 Intev Impro Causa Pro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_1 Intev Impro Causa Pro].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [2_2 Intev Pro Causa Impro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_2 Intev Pro Causa Impro].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [2_3 dec >= 0,001] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_3 dec >= 0,001].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [2_5 TMD = 0 Análise] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_5 TMD = 0 Análise].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [3_0 TMA] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [3_0 TMA].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [4_9_1 Intev < 3 OS Vinc > 80 UCs] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [4_9_1 Intev < 3 OS Vinc > 80 UCs].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [4_9_3 Intev S OS Vinc > 80 UCs Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [4_9_3 Intev S OS Vinc > 80 UCs Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [5_9 Dif Hr Inicio x 1º Passo Atv = 1 min Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [5_9_1 Dif Hr Inicio x 1º Passo Atv > 6 h Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [9_9_1 Análise OS > UCs Interr Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [9_9_1 Análise OS > UCs Interr Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [8_7 Filtro Passo Válido Filtro] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [8_7 Filtro Passo Válido Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [2_6 Comp > R$ 1000] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [2_6 Comp > R$ 1000].NUM_SEQ_OPER_OS_MNB;

-- ===== 99 Intev Unificar Filtros - TMA Tratado  (SELECT)
SELECT [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS,
       [99 Intev Unificar Filtros].DIF_1ª_2ª_RCM_1h,
       [99 Intev Unificar Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Intev Unificar Filtros].TR_Próprio_OS_Proc,
       [99 Intev Unificar Filtros].Intev_Impro_Causa_Proc,
       [99 Intev Unificar Filtros].Intev_Proc_Causa_Impro,
       [99 Intev Unificar Filtros].[DEC_>_0,001],
       [99 Intev Unificar Filtros].TMD_0,
       [3_0 TMA Filtro > 1440 - Mais de 1 Filtro - Filtrado]![STATUS] AS [TMA_>_1440],
       [99 Intev Unificar Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Intev Unificar Filtros].Intev_S_OS_Vinc,
       [99 Intev Unificar Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Intev Unificar Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Intev Unificar Filtros].OS_Vinc_UCs_Interr,
       [99 Intev Unificar Filtros].Intev_0_UCs_Inter,
       [99 Intev Unificar Filtros].[Comp_>_500],
       [1_17 Análise Datas Retirar entre 2h - Final]![ANÁLISE] AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio],
       [10_3 Man Com Elem Partic]![ANÁLISE] AS [OS_Elemen_Particular_Proc],
       [11_10 Cruzamento Último Passo x Última OS - Filtro]![ANÁLISE] AS [OS_Vinc_Hr_>_Ult_Passo],
       [12_0 Ocorrência Sem GA - Impro]![Análise] AS [OS_Impro_Sem_Elem_Partic],
       [17_5 Zona_TR_Dif_Zona_UC_Final].Intv_TR_Zona_Div_UC,
       [16_0_1 Int_Classi_Externo].OS_Externa,
       [15_0_1 UC_Acessante].OS_Acessante
FROM [99 Intev Unificar Filtros]
  LEFT JOIN [3_0 TMA Filtro > 1440 - Mais de 1 Filtro - Filtrado] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [3_0 TMA Filtro > 1440 - Mais de 1 Filtro - Filtrado].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [1_17 Análise Datas Retirar entre 2h - Final] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [1_17 Análise Datas Retirar entre 2h - Final].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [10_3 Man Com Elem Partic] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [10_3 Man Com Elem Partic].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [11_10 Cruzamento Último Passo x Última OS - Filtro] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [11_10 Cruzamento Último Passo x Última OS - Filtro].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [12_0 Ocorrência Sem GA - Impro] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [12_0 Ocorrência Sem GA - Impro].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [17_5 Zona_TR_Dif_Zona_UC_Final] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [17_5 Zona_TR_Dif_Zona_UC_Final].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [16_0_1 Int_Classi_Externo] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [16_0_1 Int_Classi_Externo].NUM_SEQ_OPER_OS_MNB
  LEFT JOIN [15_0_1 UC_Acessante] ON [99 Intev Unificar Filtros].NUM_SEQ_OPER_OS = [15_0_1 UC_Acessante].NUM_SEQ_OPER_OS_MNB;
