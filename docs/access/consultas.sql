-- ===== 0 Apuração_Correção  (SELECT)
SELECT 
FROM [3 OS_Corrigida]
  INNER JOIN [0 Base_Crítica] ON [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB = [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB;

-- ===== 0 Base_OS_Corrigida_Compt_Atual  (SELECT)
SELECT [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB,
       [3 OS_Corrigida].DEC,
       [3 OS_Corrigida].FEC,
       [3 OS_Corrigida].TMA,
       [3 OS_Corrigida]![MULTA_OS]*1 AS [MULTA_OS]
FROM [3 OS_Corrigida]
  INNER JOIN [0 Competência_Atual] ON [3 OS_Corrigida].DTA_CMPT_MNB = [0 Competência_Atual].DTA_CMPT_MNB;

-- ===== 0 Base_OS_Interv_Multa  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].DEC AS [DEC_C],
       [1 Tabela_Intervenção].FEC AS [FEC_C],
       [1 Tabela_Intervenção]![TMA]*1 AS [TMA_C],
       Comp_Ocorrências.MULTA_OS AS [MULTA_OS_C]
FROM [1 Tabela_Intervenção]
  LEFT JOIN [Comp_Ocorrências] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI;

-- ===== 0 Competência_Atual  (SELECT)
SELECT Max([2 Intervenção Unificada - Filtros].DTA_CMPT_MNB) AS [DTA_CMPT_MNB]
FROM [2 Intervenção Unificada - Filtros];

-- ===== 0 Cruzamento_Bases  (SELECT)
SELECT [0 Base_OS_Corrigida_Compt_Atual].NUM_SEQ_OPER_OS_MNB,
       IIf([0 Base_OS_Corrigida_Compt_Atual]![DEC] Is Null,0,IIf([0 Base_OS_Corrigida_Compt_Atual]![DEC]="",0,[0 Base_OS_Corrigida_Compt_Atual]![DEC])*1) AS [DEC],
       IIf([0 Base_OS_Interv_Multa]![DEC_C] Is Null,0,[0 Base_OS_Interv_Multa]![DEC_C])*1 AS [DEC_C],
       IIf([0 Base_OS_Corrigida_Compt_Atual]![FEC] Is Null,0,IIf([0 Base_OS_Corrigida_Compt_Atual]![FEC]="",0,[0 Base_OS_Corrigida_Compt_Atual]![FEC])*1) AS [FEC],
       IIf(IIf([0 Base_OS_Interv_Multa]![FEC_C] Is Null,0,[0 Base_OS_Interv_Multa]![FEC_C]) Is Null,0,IIf([0 Base_OS_Interv_Multa]![FEC_C]="",0,[0 Base_OS_Interv_Multa]![FEC_C])) AS [FEC_C],
       IIf([0 Base_OS_Corrigida_Compt_Atual]![TMA] Is Null,0,[0 Base_OS_Corrigida_Compt_Atual]![TMA]) AS [TMA],
       IIf([0 Base_OS_Interv_Multa]![TMA_C] Is Null,0,[0 Base_OS_Interv_Multa]![TMA_C]) AS [TMA_C],
       IIf([0 Base_OS_Corrigida_Compt_Atual]![MULTA_OS] Is Null,0,[0 Base_OS_Corrigida_Compt_Atual]![MULTA_OS]) AS [MULTA_OS],
       IIf([0 Base_OS_Interv_Multa]![MULTA_OS_C] Is Null,0,[0 Base_OS_Interv_Multa]![MULTA_OS_C]) AS [MULTA_OS_C]
FROM [0 Base_OS_Corrigida_Compt_Atual]
  LEFT JOIN [0 Base_OS_Interv_Multa] ON [0 Base_OS_Corrigida_Compt_Atual].NUM_SEQ_OPER_OS_MNB = [0 Base_OS_Interv_Multa].NUM_SEQ_OPER_OS_MNB;

-- ===== 0 Intev Backup  (APPEND)
INSERT INTO [2 Intervenção Unificada - Filtros - Backup] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, MULTA_OS, FEC, COD_LOC_COS, LOCALIDADE, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, Intv_TR_Zona_Div_UC, OS_Externa, OS_Acessante)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros].TMA,
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros];

-- ===== 0 Limpar Intev Backup  (DELETE)
DELETE [2 Intervenção Unificada - Filtros - Backup].*
FROM [2 Intervenção Unificada - Filtros - Backup];

-- ===== 0 Limpar Tabela Crítica  (DELETE)
DELETE [0 Base_Crítica].*
FROM [0 Base_Crítica];

-- ===== 0 Limpar Tabela Equipe  (DELETE)
DELETE [1 Tabela_Equipe].*
FROM [1 Tabela_Equipe];

-- ===== 0 Limpar Tabela Individual Vinculada  (DELETE)
DELETE [1 Tabela_Individual_Vinculada].*
FROM [1 Tabela_Individual_Vinculada];

-- ===== 0 Limpar Tabela Intervenção  (DELETE)
DELETE [1 Tabela_Intervenção].*
FROM [1 Tabela_Intervenção];

-- ===== 0 Limpar Tabela Manobra  (DELETE)
DELETE [1 Tabela_Manobra].*
FROM [1 Tabela_Manobra];

-- ===== 0 OS Vinculadas Intervenção  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Count([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [OS]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0 Tabela Crítica  (APPEND)
INSERT INTO [0 Base_Crítica] (DTA_CMPT_MNB, TIPO_OS, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, QTD_KVAS_PNB, NUM_PASSO_PNB, NUM_RET_MANO_PNB, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, COD_TIPO_LOC_CNR, TIPO_LOC_CNR, DES_ENDE_UN_CONS_CNR, DES_OBS_EXEC_SERV_CNR, INTERV, FEC, COD_LOC_COS)
SELECT C_Base_Crítica.DTA_CMPT_MNB,
       C_Base_Crítica.TIPO_OS,
       C_Base_Crítica.COD_CPU_OS_MNB,
       C_Base_Crítica.NUM_SEQ_OPER_OS_MNB,
       C_Base_Crítica.NUM_SEQ_GER_OS_MNB,
       C_Base_Crítica.NOM_USU_PROGM_MNB,
       C_Base_Crítica.NOM_USU_CFER_MNB,
       C_Base_Crítica.NOM_USU_EXEC_MNB,
       C_Base_Crítica.COD_TIPO_ORIG_INTV_MNB,
       C_Base_Crítica.DES_ORIG_OGE,
       C_Base_Crítica.COD_ORIG_INTV_MNB,
       C_Base_Crítica.DES_ORIG_ORI,
       C_Base_Crítica.COD_CAUSA_MNB,
       C_Base_Crítica.DES_CAUSA_INTER_CAU,
       C_Base_Crítica.COD_SUB_CAUSA_MNB,
       C_Base_Crítica.DES_SUB_CAUSA_INTER_SCR,
       C_Base_Crítica.NUM_CAUSA_ANEEL_MNB,
       C_Base_Crítica.NUM_SUB_CAUSA_ANEEL_MNB,
       C_Base_Crítica.DES_INTV_MNB,
       C_Base_Crítica.DTA_INIC_MNB,
       C_Base_Crítica.DTA_AVI_EQP_MNB,
       C_Base_Crítica.DTA_DLCT_EQP_MNB,
       C_Base_Crítica.DTA_VERI_EQP_MNB,
       C_Base_Crítica.DTA_SERV_EQP_MNB,
       C_Base_Crítica.DTA_FIM_MNB,
       C_Base_Crítica.COD_ELE_MNB,
       C_Base_Crítica.COD_INS_SEC_INS,
       C_Base_Crítica.QTD_KVAS_PNB,
       C_Base_Crítica.NUM_PASSO_PNB,
       C_Base_Crítica.NUM_RET_MANO_PNB,
       C_Base_Crítica.COD_TIPO_CONCL_COS,
       C_Base_Crítica.COD_SUB_TIPO_OS_COS,
       C_Base_Crítica.TIPO_TR,
       C_Base_Crítica.TMA,
       C_Base_Crítica.DEC,
       C_Base_Crítica.COD_TIPO_LOC_CNR,
       C_Base_Crítica.TIPO_LOC_CNR,
       C_Base_Crítica.DES_ENDE_UN_CONS_CNR,
       C_Base_Crítica.DES_OBS_EXEC_SERV_CNR,
       C_Base_Crítica.INTERV,
       C_Base_Crítica.FEC,
       C_Base_Crítica.COD_LOC_COS
FROM [C_Base_Crítica];

-- ===== 0 Tabela Equipe  (APPEND)
INSERT INTO [1 Tabela_Equipe] (DTA_CMPT_MNB, TIPO_OS, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, COD_MATERIAL, QUANTIDADE, DESCRIÇÃO, EQUIPE, KM_INICIO, KM_FIM)
SELECT [0 Base_Crítica].DTA_CMPT_MNB,
       [0 Base_Crítica].TIPO_OS,
       [0 Base_Crítica].COD_CPU_OS_MNB,
       [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB,
       [0 Base_Crítica].NUM_SUB_CAUSA_ANEEL_MNB,
       [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB,
       [0 Base_Crítica].DES_INTV_MNB,
       [0 Base_Crítica].TIPO_TR,
       [0 Base_Crítica].TMA,
       [0 Base_Crítica].DEC
FROM [0 Base_Crítica]
GROUP BY [0 Base_Crítica].DTA_CMPT_MNB, [0 Base_Crítica].TIPO_OS, [0 Base_Crítica].COD_CPU_OS_MNB, [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB, [0 Base_Crítica].NUM_SUB_CAUSA_ANEEL_MNB, [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB, [0 Base_Crítica].DES_INTV_MNB, [0 Base_Crítica].TIPO_TR, [0 Base_Crítica].TMA, [0 Base_Crítica].DEC
HAVING ((([0 Base_Crítica].TIPO_OS)="EQUIPE"));

-- ===== 0 Tabela Individual Vinculada  (APPEND)
INSERT INTO [1 Tabela_Individual_Vinculada] (TIPO_OS, DTA_CMPT_MNB, NUM_SEQ_OPER_INTER_CNR, COD_CPU_CNR, NUM_SEQ_OPER_CNR, COD_MOTI_RECL_CNR, COD_TIPO_OS_CNR, COD_SUB_TIPO_OS_CNR, COD_UN_CONS_CNR, NUM_FONE_CNR, DES_BAI_CNR, DES_LOC_CNR, DES_ENDE_UN_CONS_CNR, DES_PTO_REF_CNR, DTA_RECL_CNR, DTA_COMU_CNR, DTA_DLCT_CNR, DTA_VERI_CNR, DTA_SERV_CNR, DTA_FIM_CNR, DES_OBS_EXEC_SERV_CNR, COD_INS_TRF_INT, NOM_TEC_RESP_CUR, COD_EQP_CUR, QTD_KM_INIC_CUR, QTD_KM_FIM_CUR, USU_VINC, TIPO_VINC, ZONA)
SELECT [0 Base_Crítica].TIPO_OS,
       [0 Base_Crítica].DTA_CMPT_MNB,
       [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB AS [NUM_SEQ_OPER_INTER_CNR],
       [0 Base_Crítica].COD_CPU_OS_MNB AS [COD_CPU_CNR],
       [0 Base_Crítica].NUM_SEQ_GER_OS_MNB AS [NUM_SEQ_OPER_CNR],
       "01" AS [COD_MOTI_RECL_CNR],
       [0 Base_Crítica].NOM_USU_PROGM_MNB AS [COD_TIPO_OS_CNR],
       [0 Base_Crítica].NOM_USU_CFER_MNB AS [COD_SUB_TIPO_OS_CNR],
       [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB AS [COD_UN_CONS_CNR],
       [0 Base_Crítica].NOM_USU_EXEC_MNB AS [NUM_FONE_CNR],
       [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB AS [DES_BAI_CNR],
       [0 Base_Crítica].DES_ORIG_OGE AS [DES_LOC_CNR],
       [0 Base_Crítica].COD_ORIG_INTV_MNB AS [DES_ENDE_UN_CONS_CNR],
       [0 Base_Crítica].DES_ORIG_ORI AS [DES_PTO_REF_CNR],
       [0 Base_Crítica].DTA_INIC_MNB AS [DTA_RECL_CNR],
       [0 Base_Crítica].DTA_AVI_EQP_MNB AS [DTA_COMU_CNR],
       [0 Base_Crítica].DTA_DLCT_EQP_MNB AS [DTA_DLCT_CNR],
       [0 Base_Crítica].DTA_VERI_EQP_MNB AS [DTA_VERI_CNR],
       [0 Base_Crítica].DTA_SERV_EQP_MNB AS [DTA_SERV_CNR],
       [0 Base_Crítica].DTA_FIM_MNB AS [DTA_FIM_CNR],
       [0 Base_Crítica].COD_CAUSA_MNB AS [DES_OBS_EXEC_SERV_CNR],
       [0 Base_Crítica].COD_INS_SEC_INS AS [COD_INS_TRF_INT],
       [0 Base_Crítica].DES_CAUSA_INTER_CAU AS [NOM_TEC_RESP_CUR],
       [0 Base_Crítica].COD_SUB_CAUSA_MNB AS [COD_EQP_CUR],
       [0 Base_Crítica].QTD_KVAS_PNB AS [QTD_KM_INIC_CUR],
       [0 Base_Crítica].NUM_PASSO_PNB AS [QTD_KM_FIM_CUR],
       [0 Base_Crítica].TIPO_TR,
       [0 Base_Crítica].DES_OBS_EXEC_SERV_CNR,
       [0 Base_Crítica].COD_TIPO_LOC_CNR
FROM [0 Base_Crítica]
GROUP BY [0 Base_Crítica].TIPO_OS, [0 Base_Crítica].DTA_CMPT_MNB, [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB, [0 Base_Crítica].COD_CPU_OS_MNB, [0 Base_Crítica].NUM_SEQ_GER_OS_MNB, "01", [0 Base_Crítica].NOM_USU_PROGM_MNB, [0 Base_Crítica].NOM_USU_CFER_MNB, [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB, [0 Base_Crítica].NOM_USU_EXEC_MNB, [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB, [0 Base_Crítica].DES_ORIG_OGE, [0 Base_Crítica].COD_ORIG_INTV_MNB, [0 Base_Crítica].DES_ORIG_ORI, [0 Base_Crítica].DTA_INIC_MNB, [0 Base_Crítica].DTA_AVI_EQP_MNB, [0 Base_Crítica].DTA_DLCT_EQP_MNB, [0 Base_Crítica].DTA_VERI_EQP_MNB, [0 Base_Crítica].DTA_SERV_EQP_MNB, [0 Base_Crítica].DTA_FIM_MNB, [0 Base_Crítica].COD_CAUSA_MNB, [0 Base_Crítica].COD_INS_SEC_INS, [0 Base_Crítica].DES_CAUSA_INTER_CAU, [0 Base_Crítica].COD_SUB_CAUSA_MNB, [0 Base_Crítica].QTD_KVAS_PNB, [0 Base_Crítica].NUM_PASSO_PNB, [0 Base_Crítica].TIPO_TR, [0 Base_Crítica].DES_OBS_EXEC_SERV_CNR, [0 Base_Crítica].COD_TIPO_LOC_CNR
HAVING ((([0 Base_Crítica].TIPO_OS)="INDIV_VINCULADA"));

-- ===== 0 Tabela Intervenção  (APPEND)
INSERT INTO [1 Tabela_Intervenção] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, FEC, COD_LOC_COS, ZONA, LOCALIDADE, COELBA)
SELECT [0 Base_Crítica].TIPO_OS,
       [0 Base_Crítica].DTA_CMPT_MNB,
       [0 Base_Crítica].COD_CPU_OS_MNB,
       [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB,
       [0 Base_Crítica].NUM_SEQ_GER_OS_MNB,
       [0 Base_Crítica].NOM_USU_PROGM_MNB,
       [0 Base_Crítica].NOM_USU_CFER_MNB,
       [0 Base_Crítica].NOM_USU_EXEC_MNB,
       [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB,
       [0 Base_Crítica].DES_ORIG_OGE,
       [0 Base_Crítica].COD_ORIG_INTV_MNB,
       [0 Base_Crítica].DES_ORIG_ORI,
       [0 Base_Crítica].COD_CAUSA_MNB,
       [0 Base_Crítica].DES_CAUSA_INTER_CAU,
       [0 Base_Crítica].COD_SUB_CAUSA_MNB,
       [0 Base_Crítica].DES_SUB_CAUSA_INTER_SCR,
       [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB,
       [0 Base_Crítica].NUM_SUB_CAUSA_ANEEL_MNB,
       [0 Base_Crítica].DES_INTV_MNB,
       [0 Base_Crítica].DTA_INIC_MNB,
       [0 Base_Crítica].DTA_AVI_EQP_MNB,
       [0 Base_Crítica].DTA_DLCT_EQP_MNB,
       [0 Base_Crítica].DTA_VERI_EQP_MNB,
       [0 Base_Crítica].DTA_SERV_EQP_MNB,
       [0 Base_Crítica].DTA_FIM_MNB,
       [0 Base_Crítica].COD_ELE_MNB,
       [0 Base_Crítica].COD_INS_SEC_INS,
       [0 Base_Crítica].COD_TIPO_CONCL_COS,
       [0 Base_Crítica].COD_SUB_TIPO_OS_COS,
       [0 Base_Crítica].TIPO_TR,
       [0 Base_Crítica].TMA,
       [0 Base_Crítica].DEC,
       [0 Base_Crítica].FEC,
       [0 Base_Crítica].COD_LOC_COS,
       [0 Base_Crítica].COD_TIPO_LOC_CNR,
       [0 Base_Crítica].TIPO_LOC_CNR,
       [0 Base_Crítica].INTERV
FROM [0 Base_Crítica]
WHERE ((([0 Base_Crítica].TIPO_OS)="INTERVENÇÃO"));

-- ===== 0 Tabela Manobra  (APPEND)
INSERT INTO [1 Tabela_Manobra] (TIPO_OS, TIPO, NUM_SEQ_OPER_OS_PNB, COD_ELE_PNB, COD_INS_SEC_INS, TIPO_CHAVE, COD_OPER_PNB, DTA_PASSO_PNB, DTA_PREV_PASSO_PNB, QTD_UN_CONS_VIP_PNB, ', QTD_KVAS_PNB, COD_TIPO_MANO_PNB, NUM_SEQ_PNB, NUM_PASSO_PNB, STA_EXEC_PNB, STA_VIN_OS_PNB, NUM_RET_MANO_PNB, DES_PASSO_PNB)
SELECT [0 Base_Crítica].TIPO_OS,
       [0 Base_Crítica].COD_CPU_OS_MNB AS [TIPO],
       [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB AS [NUM_SEQ_OPER_OS_PNB],
       [0 Base_Crítica].NOM_USU_PROGM_MNB AS [COD_ELE_PNB],
       [0 Base_Crítica].NOM_USU_CFER_MNB AS [COD_INS_SEC_INS],
       [0 Base_Crítica].NOM_USU_EXEC_MNB AS [TIPO_CHAVE],
       [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB AS [COD_OPER_PNB],
       [0 Base_Crítica].DTA_INIC_MNB AS [DTA_PASSO_PNB],
       [0 Base_Crítica].DTA_AVI_EQP_MNB AS [DTA_PREV_PASSO_PNB],
       [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB AS [QTD_UN_CONS_VIP_PNB],
       [0 Base_Crítica].NUM_SUB_CAUSA_ANEEL_MNB AS [QTD_UN_CONS_PNB],
       [0 Base_Crítica].QTD_KVAS_PNB,
       [0 Base_Crítica].DES_SUB_CAUSA_INTER_SCR AS [COD_TIPO_MANO_PNB],
       [0 Base_Crítica].NUM_SEQ_GER_OS_MNB AS [NUM_SEQ_PNB],
       [0 Base_Crítica].NUM_PASSO_PNB,
       [0 Base_Crítica].COD_SUB_CAUSA_MNB AS [STA_EXEC_PNB],
       [0 Base_Crítica].COD_ELE_MNB AS [STA_VIN_OS_PNB],
       [0 Base_Crítica].NUM_RET_MANO_PNB,
       [0 Base_Crítica].DES_INTV_MNB AS [DES_PASSO_PNB]
FROM [0 Base_Crítica]
WHERE ((([0 Base_Crítica].TIPO_OS)="PASSO_MANOBRA"));

-- ===== 0 Tabela Ocorrência_Individual  (APPEND)
INSERT INTO [1 Tabela Ocorrência_Individual] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_CNR, NUM_SEQ_OPER_CNR, COD_UN_CONS_CNR, COD_TIPO_OS_CNR, COD_SUB_TIPO_OS_CNR, COD_TIPO_ORIG_CNR, DES_ORIG_OGE, COD_ORIG_CNR, DES_ORIG_ORI, COD_CAUSA_INTER_CNR, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_INTER_CNR, DES_SUB_CAUSA_INTER_SCR, NOM_CLI_CNR, DES_BAI_CNR, DES_LOC_CNR, DES_ENDE_UN_CONS_CNR, DES_PTO_REF_CNR, DTA_RECL_CNR, DTA_COMU_CNR, DTA_DLCT_CNR, DTA_VERI_CNR, DTA_SERV_CNR, DTA_FIM_CNR, DES_OBS_EXEC_SERV_CNR, COD_TIPO_LOC_CNR, TIPO_LOC_CNR, COD_TIPO_CONCL_CNR, INTERV, COD_INS_TRF_INT, TIPO_TR, TMA, DEC, COD_GRU_TENS_FAT_UEE, FEC)
SELECT [0 Base_Crítica].TIPO_OS,
       [0 Base_Crítica].DTA_CMPT_MNB,
       [0 Base_Crítica].COD_CPU_OS_MNB AS [COD_CPU_CNR],
       [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB AS [NUM_SEQ_OPER_CNR],
       [0 Base_Crítica].NUM_SEQ_GER_OS_MNB AS [COD_UN_CONS_CNR],
       [0 Base_Crítica].NOM_USU_PROGM_MNB AS [COD_TIPO_OS_CNR],
       [0 Base_Crítica].NOM_USU_CFER_MNB AS [COD_SUB_TIPO_OS_CNR],
       [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB AS [COD_TIPO_ORIG_CNR],
       [0 Base_Crítica].DES_ORIG_OGE,
       [0 Base_Crítica].COD_ORIG_INTV_MNB AS [COD_ORIG_CNR],
       [0 Base_Crítica].DES_ORIG_ORI,
       [0 Base_Crítica].COD_CAUSA_MNB AS [COD_CAUSA_INTER_CNR],
       [0 Base_Crítica].DES_CAUSA_INTER_CAU,
       [0 Base_Crítica].COD_SUB_CAUSA_MNB AS [COD_SUB_CAUSA_INTER_CNR],
       [0 Base_Crítica].DES_SUB_CAUSA_INTER_SCR,
       [0 Base_Crítica].NOM_USU_EXEC_MNB AS [NOM_CLI_CNR],
       [0 Base_Crítica].COD_ELE_MNB AS [DES_BAI_CNR],
       [0 Base_Crítica].COD_SUB_TIPO_OS_COS AS [DES_LOC_CNR],
       [0 Base_Crítica].DES_ENDE_UN_CONS_CNR,
       [0 Base_Crítica].DES_INTV_MNB AS [DES_PTO_REF_CNR],
       [0 Base_Crítica].DTA_INIC_MNB AS [DTA_RECL_CNR],
       [0 Base_Crítica].DTA_AVI_EQP_MNB AS [DTA_COMU_CNR],
       [0 Base_Crítica].DTA_DLCT_EQP_MNB AS [DTA_DLCT_CNR],
       [0 Base_Crítica].DTA_VERI_EQP_MNB AS [DTA_VERI_CNR],
       [0 Base_Crítica].DTA_SERV_EQP_MNB AS [DTA_SERV_CNR],
       [0 Base_Crítica].DTA_FIM_MNB AS [DTA_FIM_CNR],
       [0 Base_Crítica].DES_OBS_EXEC_SERV_CNR,
       [0 Base_Crítica].COD_TIPO_LOC_CNR,
       [0 Base_Crítica].TIPO_LOC_CNR,
       [0 Base_Crítica].COD_TIPO_CONCL_COS AS [COD_TIPO_CONCL_CNR],
       [0 Base_Crítica].INTERV,
       [0 Base_Crítica].COD_INS_SEC_INS AS [COD_INS_TRF_INT],
       [0 Base_Crítica].TIPO_TR,
       [0 Base_Crítica].TMA,
       [0 Base_Crítica].DEC,
       [0 Base_Crítica].COD_LOC_COS AS [COD_GRU_TENS_FAT_UEE],
       [0 Base_Crítica].FEC
FROM [0 Base_Crítica]
WHERE ((([0 Base_Crítica].TIPO_OS)="INDIVIDUAL"));

-- ===== 00 Multa Ocorrência  (SELECT)
SELECT Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI,
       Comp_Ocorrências.MULTA_OS
FROM [Comp_Ocorrências]
GROUP BY Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI, Comp_Ocorrências.MULTA_OS;

-- ===== 0_0 Menor 1ª Data  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Min([1 Tabela_Individual_Vinculada].DTA_RECL_CNR) AS [DTA_RECL_CNR]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 0_0 Soma Clientes Interr  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       Sum([1 Tabela_Manobra].[']) AS [SomaDeQTD_UN_CONS_PNB]
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].COD_OPER_PNB
HAVING ((([1 Tabela_Manobra].COD_OPER_PNB) In ("ABRIR","INTERR")));

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

-- ===== 1 Base Intervenção Geral  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros]![TMA] AS [TMA],
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc,
       [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic,
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [DIF_1ª_2ª_RCM_1h] & [DIF_1ª_Man_1ª_OS_Vinc_2h] & [TR_Próprio_OS_Proc] & [Intev_Impro_Causa_Proc] & [Intev_Proc_Causa_Impro] & [DEC_>_0,001] & [TMD_0] & [TMA_>_1440] & [Intev_<_3_OS_Vinc_>_50_UCs] & [Intev_S_OS_Vinc] & [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min] & [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr] & [OS_Vinc_UCs_Interr] & [Intev_0_UCs_Inter] & [Correção Realizada] & [Comp_>_500] & [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio] & [OS_Elemen_Particular_Proc] & [OS_Vinc_Hr_>_Ult_Passo] & [OS_Impro_Sem_Elem_Partic] AS [CONCAT],
       IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada]) AS [Correção],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros];

-- ===== 1 Base Original Filtros  (SELECT)
SELECT [1 Base Intervenção Geral].TIPO_OS,
       [1 Base Intervenção Geral].DTA_CMPT_MNB,
       [1 Base Intervenção Geral].COD_CPU_OS_MNB,
       [1 Base Intervenção Geral].NUM_SEQ_OPER_OS_MNB,
       [1 Base Intervenção Geral].NUM_SEQ_GER_OS_MNB,
       [1 Base Intervenção Geral].NOM_USU_PROGM_MNB,
       [1 Base Intervenção Geral].NOM_USU_CFER_MNB,
       [1 Base Intervenção Geral].NOM_USU_EXEC_MNB,
       [1 Base Intervenção Geral].COD_TIPO_ORIG_INTV_MNB,
       [1 Base Intervenção Geral].DES_ORIG_OGE,
       [1 Base Intervenção Geral].COD_ORIG_INTV_MNB,
       [1 Base Intervenção Geral].DES_ORIG_ORI,
       [1 Base Intervenção Geral].COD_CAUSA_MNB,
       [1 Base Intervenção Geral].DES_CAUSA_INTER_CAU,
       [1 Base Intervenção Geral].COD_SUB_CAUSA_MNB,
       [1 Base Intervenção Geral].DES_SUB_CAUSA_INTER_SCR,
       [1 Base Intervenção Geral].NUM_CAUSA_ANEEL_MNB,
       [1 Base Intervenção Geral].NUM_SUB_CAUSA_ANEEL_MNB,
       [1 Base Intervenção Geral].DES_INTV_MNB,
       [1 Base Intervenção Geral].DTA_INIC_MNB,
       [1 Base Intervenção Geral].DTA_AVI_EQP_MNB,
       [1 Base Intervenção Geral].DTA_DLCT_EQP_MNB,
       [1 Base Intervenção Geral].DTA_VERI_EQP_MNB,
       [1 Base Intervenção Geral].DTA_SERV_EQP_MNB,
       [1 Base Intervenção Geral].DTA_FIM_MNB,
       [1 Base Intervenção Geral].COD_ELE_MNB,
       [1 Base Intervenção Geral].COD_INS_SEC_INS,
       [1 Base Intervenção Geral].COD_TIPO_CONCL_COS,
       [1 Base Intervenção Geral].COD_SUB_TIPO_OS_COS,
       [1 Base Intervenção Geral].TIPO_TR,
       [1 Base Intervenção Geral].TMA,
       [1 Base Intervenção Geral].DEC,
       [1 Base Intervenção Geral].DIF_1ª_2ª_RCM_1h,
       [1 Base Intervenção Geral].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [1 Base Intervenção Geral].TR_Próprio_OS_Proc,
       [1 Base Intervenção Geral].Intev_Impro_Causa_Proc,
       [1 Base Intervenção Geral].Intev_Proc_Causa_Impro,
       [1 Base Intervenção Geral].[DEC_>_0,001],
       [1 Base Intervenção Geral].TMD_0,
       [1 Base Intervenção Geral].[TMA_>_1440],
       [1 Base Intervenção Geral].[Intev_<_3_OS_Vinc_>_50_UCs],
       [1 Base Intervenção Geral].Intev_S_OS_Vinc,
       [1 Base Intervenção Geral].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [1 Base Intervenção Geral].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [1 Base Intervenção Geral].OS_Vinc_UCs_Interr,
       [1 Base Intervenção Geral].Intev_0_UCs_Inter,
       [1 Base Intervenção Geral].[Correção Realizada],
       [1 Base Intervenção Geral].[Comp_>_500],
       [1 Base Intervenção Geral].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [1 Base Intervenção Geral].OS_Elemen_Particular_Proc,
       [1 Base Intervenção Geral].[OS_Vinc_Hr_>_Ult_Passo],
       [1 Base Intervenção Geral].OS_Impro_Sem_Elem_Partic,
       [1 Base Intervenção Geral].FEC,
       [1 Base Intervenção Geral].COD_LOC_COS,
       [1 Base Intervenção Geral].LOCALIDADE,
       [1 Base Intervenção Geral].COEC,
       [1 Base Intervenção Geral].MULTA_OS,
       [1 Base Intervenção Geral].Concat,
       [1 Base Intervenção Geral].C_Classificação,
       [1 Base Intervenção Geral].[C_OS Vinculada],
       [1 Base Intervenção Geral].[C_Passo de Manobra],
       [1 Base Intervenção Geral].C_Horário,
       [1 Base Intervenção Geral].[C_Elemento Origem],
       [1 Base Intervenção Geral].USUÁRIO,
       [1 Base Intervenção Geral].OBSERVAÇÃO,
       [1 Base Intervenção Geral].STATUS,
       [1 Base Intervenção Geral].[DATA ANÁLISE],
       [1 Base Intervenção Geral].[DATA BAIXA],
       [1 Base Intervenção Geral].Intv_TR_Zona_Div_UC,
       [1 Base Intervenção Geral].OS_Externa,
       [1 Base Intervenção Geral].OS_Acessante
FROM [1 Base Intervenção Geral]
WHERE ((([1 Base Intervenção Geral].Concat)<>"" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & ""));

-- ===== 1 Cruzamento_Bases_Cálculo  (SELECT)
SELECT [0 Cruzamento_Bases].NUM_SEQ_OPER_OS_MNB,
       [0 Cruzamento_Bases].DEC,
       [0 Cruzamento_Bases].DEC_C,
       IIf([DEC]-[DEC_C] Is Null,0,[DEC]-[DEC_C]) AS [DEC_G],
       [0 Cruzamento_Bases].FEC,
       [0 Cruzamento_Bases].FEC_C,
       IIf([FEC]-[FEC_C] Is Null,0,[FEC]-[FEC_C]) AS [FEC_G],
       [0 Cruzamento_Bases].TMA,
       [0 Cruzamento_Bases].TMA_C,
       IIf([TMA]-[TMA_C] Is Null,0,[TMA]-[TMA_C]) AS [TMA_G],
       [0 Cruzamento_Bases].MULTA_OS,
       [0 Cruzamento_Bases].MULTA_OS_C,
       IIf([MULTA_OS]-[MULTA_OS_C] Is Null,0,[MULTA_OS]-[MULTA_OS_C]) AS [MULTA_OS_G]
FROM [0 Cruzamento_Bases];

-- ===== 1 Cruzamento_Bases_Cálculo_Ganho  (SELECT)
SELECT [1 Cruzamento_Bases_Cálculo].NUM_SEQ_OPER_OS_MNB,
       IIf([1 Cruzamento_Bases_Cálculo]![DEC_G]<0,0,[1 Cruzamento_Bases_Cálculo]![DEC_G]) AS [DEC_G],
       IIf([1 Cruzamento_Bases_Cálculo]![FEC_G]<0,0,[1 Cruzamento_Bases_Cálculo]![FEC_G]) AS [FEC_G],
       IIf([1 Cruzamento_Bases_Cálculo]![TMA_G]<0,0,[1 Cruzamento_Bases_Cálculo]![TMA_G]) AS [TMA_G],
       IIf([1 Cruzamento_Bases_Cálculo]![MULTA_OS_G]<0,0,[1 Cruzamento_Bases_Cálculo]![MULTA_OS_G]) AS [MULTA_OS_G],
       ([DEC_G]+[FEC_G]+[TMA_G]+[MULTA_OS_G])*1 AS [Filtro]
FROM [1 Cruzamento_Bases_Cálculo]
WHERE (((([DEC_G]+[FEC_G]+[TMA_G]+[MULTA_OS_G])*1)>0));

-- ===== 1 Cruzamento_Bases_Cálculo_Ganho_Correção  (SELECT)
SELECT [1 Cruzamento_Bases_Cálculo_Ganho].NUM_SEQ_OPER_OS_MNB,
       First([1 Cruzamento_Bases_Cálculo_Ganho].DEC_G) AS [DEC_G],
       First([1 Cruzamento_Bases_Cálculo_Ganho].FEC_G) AS [FEC_G],
       First([1 Cruzamento_Bases_Cálculo_Ganho].TMA_G) AS [TMA_G],
       First([1 Cruzamento_Bases_Cálculo_Ganho].MULTA_OS_G) AS [MULTA_OS_G]
FROM [1 Cruzamento_Bases_Cálculo_Ganho]
GROUP BY [1 Cruzamento_Bases_Cálculo_Ganho].NUM_SEQ_OPER_OS_MNB;

-- ===== 1 F_Comp_>_500  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[Comp_>_500]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[Comp_>_500])="Verificar"));

-- ===== 1 F_Comp_>_500 - Count  (SELECT)
SELECT [1 F_Comp_>_500].TIPO,
       Count([1 F_Comp_>_500].[Comp_>_500]) AS [Comp_>_500_O]
FROM [1 F_Comp_>_500]
GROUP BY [1 F_Comp_>_500].TIPO;

-- ===== 1 F_DEC_>_0,001  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[DEC_>_0,001]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[DEC_>_0,001])="Verificar"));

-- ===== 1 F_DEC_>_0,001 - Count  (SELECT)
SELECT [1 F_DEC_>_0,001].TIPO,
       Count([1 F_DEC_>_0,001].[DEC_>_0,001]) AS [DEC_>_0,001_O]
FROM [1 F_DEC_>_0,001]
GROUP BY [1 F_DEC_>_0,001].TIPO;

-- ===== 1 F_DIF_1ª_2ª_RCM_1h  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].DIF_1ª_2ª_RCM_1h AS [DIF_1ª_2ª_RCM_1h]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].DIF_1ª_2ª_RCM_1h)="Verificar"));

-- ===== 1 F_DIF_1ª_2ª_RCM_1h - Count  (SELECT)
SELECT [1 F_DIF_1ª_2ª_RCM_1h].TIPO,
       Count([1 F_DIF_1ª_2ª_RCM_1h].DIF_1ª_2ª_RCM_1h) AS [DIF_1ª_2ª_RCM_1h_O]
FROM [1 F_DIF_1ª_2ª_RCM_1h]
GROUP BY [1 F_DIF_1ª_2ª_RCM_1h].TIPO;

-- ===== 1 F_DIF_1ª_Man_1ª_OS_Vinc_2h  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].DIF_1ª_Man_1ª_OS_Vinc_2h
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].DIF_1ª_Man_1ª_OS_Vinc_2h) In ("Verificar Abrir","Verificar Interr")));

-- ===== 1 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count  (SELECT)
SELECT [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h].TIPO,
       Count([1 F_DIF_1ª_Man_1ª_OS_Vinc_2h].DIF_1ª_Man_1ª_OS_Vinc_2h) AS [DIF_1ª_Man_1ª_OS_Vinc_2h_O]
FROM [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h]
GROUP BY [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h].TIPO;

-- ===== 1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio)<>"" & "" & ""));

-- ===== 1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count  (SELECT)
SELECT [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio].TIPO,
       Count([1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio) AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio_O]
FROM [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]
GROUP BY [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio].TIPO;

-- ===== 1 F_Intev_0_UCs_Inter  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Intev_0_UCs_Inter
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Intev_0_UCs_Inter)="Verificar"));

-- ===== 1 F_Intev_0_UCs_Inter - Count  (SELECT)
SELECT [1 F_Intev_0_UCs_Inter].TIPO,
       Count([1 F_Intev_0_UCs_Inter].Intev_0_UCs_Inter) AS [Intev_0_UCs_Inter_O]
FROM [1 F_Intev_0_UCs_Inter]
GROUP BY [1 F_Intev_0_UCs_Inter].TIPO;

-- ===== 1 F_Intev_<_3_OS_Vinc_>_50_UCs  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[Intev_<_3_OS_Vinc_>_50_UCs]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[Intev_<_3_OS_Vinc_>_50_UCs])="Verificar"));

-- ===== 1 F_Intev_<_3_OS_Vinc_>_50_UCs - Count  (SELECT)
SELECT [1 F_Intev_<_3_OS_Vinc_>_50_UCs].TIPO,
       Count([1 F_Intev_<_3_OS_Vinc_>_50_UCs].[Intev_<_3_OS_Vinc_>_50_UCs]) AS [Intev_<_3_OS_Vinc_>_50_UCs_O]
FROM [1 F_Intev_<_3_OS_Vinc_>_50_UCs]
GROUP BY [1 F_Intev_<_3_OS_Vinc_>_50_UCs].TIPO;

-- ===== 1 F_Intev_Impro_Causa_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Intev_Impro_Causa_Proc
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Intev_Impro_Causa_Proc)="Verificar"));

-- ===== 1 F_Intev_Impro_Causa_Proc - Count  (SELECT)
SELECT [1 F_Intev_Impro_Causa_Proc].TIPO,
       Count([1 F_Intev_Impro_Causa_Proc].Intev_Impro_Causa_Proc) AS [Intev_Impro_Causa_Proc_O]
FROM [1 F_Intev_Impro_Causa_Proc]
GROUP BY [1 F_Intev_Impro_Causa_Proc].TIPO;

-- ===== 1 F_Intev_Proc_Causa_Impro  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Intev_Proc_Causa_Impro
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Intev_Proc_Causa_Impro)="Verificar"));

-- ===== 1 F_Intev_Proc_Causa_Impro - Count  (SELECT)
SELECT [1 F_Intev_Proc_Causa_Impro].TIPO,
       Count([1 F_Intev_Proc_Causa_Impro].Intev_Proc_Causa_Impro) AS [Intev_Proc_Causa_Impro_O]
FROM [1 F_Intev_Proc_Causa_Impro]
GROUP BY [1 F_Intev_Proc_Causa_Impro].TIPO;

-- ===== 1 F_Intev_S_OS_Vinc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Intev_S_OS_Vinc
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Intev_S_OS_Vinc)="Verificar"));

-- ===== 1 F_Intev_S_OS_Vinc - Count  (SELECT)
SELECT [1 F_Intev_S_OS_Vinc].TIPO,
       Count([1 F_Intev_S_OS_Vinc].Intev_S_OS_Vinc) AS [Intev_S_OS_Vinc_O]
FROM [1 F_Intev_S_OS_Vinc]
GROUP BY [1 F_Intev_S_OS_Vinc].TIPO;

-- ===== 1 F_Intv_TR_Zona_Div_UC  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].Intv_TR_Zona_Div_UC
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].Intv_TR_Zona_Div_UC)="Verificar"));

-- ===== 1 F_Intv_TR_Zona_Div_UC - Count  (SELECT)
SELECT [1 F_Intv_TR_Zona_Div_UC].TIPO,
       Count([1 F_Intv_TR_Zona_Div_UC].Intv_TR_Zona_Div_UC) AS [Intv_TR_Zona_Div_UC_O]
FROM [1 F_Intv_TR_Zona_Div_UC]
GROUP BY [1 F_Intv_TR_Zona_Div_UC].TIPO;

-- ===== 1 F_OS_Acessante  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].OS_Acessante
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].OS_Acessante)="Verificar"));

-- ===== 1 F_OS_Acessante - Count  (SELECT)
SELECT [1 F_OS_Acessante].TIPO,
       Count([1 F_OS_Acessante].OS_Acessante) AS [OS_Acessante_O]
FROM [1 F_OS_Acessante]
GROUP BY [1 F_OS_Acessante].TIPO;

-- ===== 1 F_OS_Elemen_Particular_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].OS_Elemen_Particular_Proc
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].OS_Elemen_Particular_Proc)="Verificar"));

-- ===== 1 F_OS_Elemen_Particular_Proc - Count  (SELECT)
SELECT "Pendente" AS [TIPO],
       Count([1 F_OS_Elemen_Particular_Proc].OS_Elemen_Particular_Proc) AS [OS_Elemen_Particular_Proc_O]
FROM [1 F_OS_Elemen_Particular_Proc]
GROUP BY "Pendente";

-- ===== 1 F_OS_Externa  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].OS_Externa
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].OS_Externa)="Verificar"));

-- ===== 1 F_OS_Externa - Count  (SELECT)
SELECT [1 F_OS_Externa].TIPO,
       Count([1 F_OS_Externa].OS_Externa) AS [OS_Externa_O]
FROM [1 F_OS_Externa]
GROUP BY [1 F_OS_Externa].TIPO;

-- ===== 1 F_OS_Impro_Sem_Elem_Partic  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].OS_Impro_Sem_Elem_Partic
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].OS_Impro_Sem_Elem_Partic)="Verificar"));

-- ===== 1 F_OS_Impro_Sem_Elem_Partic - Count  (SELECT)
SELECT [1 F_OS_Impro_Sem_Elem_Partic].TIPO,
       Count([1 F_OS_Impro_Sem_Elem_Partic].OS_Impro_Sem_Elem_Partic) AS [OS_Impro_Sem_Elem_Partic_O]
FROM [1 F_OS_Impro_Sem_Elem_Partic]
GROUP BY [1 F_OS_Impro_Sem_Elem_Partic].TIPO;

-- ===== 1 F_OS_Vinc_Hr_>_Ult_Passo  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[OS_Vinc_Hr_>_Ult_Passo]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[OS_Vinc_Hr_>_Ult_Passo])="Verificar"));

-- ===== 1 F_OS_Vinc_Hr_>_Ult_Passo - Count  (SELECT)
SELECT [1 F_OS_Vinc_Hr_>_Ult_Passo].TIPO,
       Count([1 F_OS_Vinc_Hr_>_Ult_Passo].[OS_Vinc_Hr_>_Ult_Passo]) AS [OS_Vinc_Hr_>_Ult_Passo_O]
FROM [1 F_OS_Vinc_Hr_>_Ult_Passo]
GROUP BY [1 F_OS_Vinc_Hr_>_Ult_Passo].TIPO;

-- ===== 1 F_OS_Vinc_UCs_Interr  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].OS_Vinc_UCs_Interr
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].OS_Vinc_UCs_Interr)="Verificar"));

-- ===== 1 F_OS_Vinc_UCs_Interr - Count  (SELECT)
SELECT [1 F_OS_Vinc_UCs_Interr].TIPO,
       Count([1 F_OS_Vinc_UCs_Interr].OS_Vinc_UCs_Interr) AS [OS_Vinc_UCs_Interr_O]
FROM [1 F_OS_Vinc_UCs_Interr]
GROUP BY [1 F_OS_Vinc_UCs_Interr].TIPO;

-- ===== 1 F_TMA_>_1440  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[TMA_>_1440]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[TMA_>_1440])="Verificar"));

-- ===== 1 F_TMA_>_1440 - Count  (SELECT)
SELECT [1 F_TMA_>_1440].TIPO,
       Count([1 F_TMA_>_1440].[TMA_>_1440]) AS [TMA_>_1440_O]
FROM [1 F_TMA_>_1440]
GROUP BY [1 F_TMA_>_1440].TIPO;

-- ===== 1 F_TMD_0  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].TMD_0
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].TMD_0)="Verificar"));

-- ===== 1 F_TMD_0 - Count  (SELECT)
SELECT [1 F_TMD_0].TIPO,
       Count([1 F_TMD_0].TMD_0) AS [TMD_0_O]
FROM [1 F_TMD_0]
GROUP BY [1 F_TMD_0].TIPO;

-- ===== 1 F_TR_Próprio_OS_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].TR_Próprio_OS_Proc
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].TR_Próprio_OS_Proc)="Verificar"));

-- ===== 1 F_TR_Próprio_OS_Proc - Count  (SELECT)
SELECT [1 F_TR_Próprio_OS_Proc].TIPO,
       Count([1 F_TR_Próprio_OS_Proc].TR_Próprio_OS_Proc) AS [TR_Próprio_OS_Proc_O]
FROM [1 F_TR_Próprio_OS_Proc]
GROUP BY [1 F_TR_Próprio_OS_Proc].TIPO;

-- ===== 1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min])="Verificar"));

-- ===== 1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count  (SELECT)
SELECT [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].TIPO,
       Count([1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]) AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min_O]
FROM [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]
GROUP BY [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].TIPO;

-- ===== 1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr  (SELECT)
SELECT "Pendente" AS [TIPO],
       [2 Base Original Ref Atual].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]
FROM [2 Base Original Ref Atual]
WHERE ((([2 Base Original Ref Atual].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr])="Verificar"));

-- ===== 1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count  (SELECT)
SELECT [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].TIPO,
       Count([1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]) AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr_O]
FROM [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]
GROUP BY [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].TIPO;

-- ===== 1 Limpar Tabela Individual Vinculada  (DELETE)
DELETE [1 Tabela Ocorrência_Individual].*
FROM [1 Tabela Ocorrência_Individual];

-- ===== 1 OS_Análisadas  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros].TMA,
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc,
       [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic,
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros]
WHERE ((([2 Intervenção Unificada - Filtros].[Correção Realizada])="-1"));

-- ===== 1 OS_Corrigidas  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros].TMA,
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc,
       [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic,
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros]
  INNER JOIN [99 Base Correções Não Arquivadas - Intev Corrig] ON [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB = [99 Base Correções Não Arquivadas - Intev Corrig].NUM_SEQ_OPER_OS_MNB;

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

-- ===== 11_10 Cruzamento Último Passo x Última OS - Filtro  (SELECT)
SELECT [11_9 Cruzamento Último Passo x Última OS].NUM_SEQ_OPER_OS_PNB,
       [11_9 Cruzamento Último Passo x Última OS].COD_OPER_PNB,
       [11_9 Cruzamento Último Passo x Última OS].DTA_PASSO_PNB,
       [11_9 Cruzamento Último Passo x Última OS].NUM_SEQ_OPER_CNR,
       [11_9 Cruzamento Último Passo x Última OS].DTA_RECL_CNR,
       [11_9 Cruzamento Último Passo x Última OS].ANÁLISE
FROM [11_9 Cruzamento Último Passo x Última OS]
WHERE ((([11_9 Cruzamento Último Passo x Última OS].ANÁLISE)<>""));

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

-- ===== 12_0 Ocorrência Sem GA - Impro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].AGRUP,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([AGRUP] Is Null,IIf([COD_TIPO_CONCL_COS]="004","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
  LEFT JOIN [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].NUM_SEQ_OPER_OS_PNB
WHERE ((([10_2 Base_Manobra_Elemento_Remove_DJ_Agrup].AGRUP) Is Null) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="004"));

-- ===== 14_0 Passos Cancelados OS  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Manobra].STA_EXEC_PNB,
       Count([1 Tabela_Manobra].COD_ELE_PNB) AS [ContarDeCOD_ELE_PNB]
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].STA_EXEC_PNB
HAVING ((([1 Tabela_Manobra].STA_EXEC_PNB)="Passo Cancelado"));

-- ===== 14_1 Passos Executados OS  (SELECT)
SELECT [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB,
       [1 Tabela_Manobra].STA_EXEC_PNB,
       Count([1 Tabela_Manobra].COD_ELE_PNB) AS [ContarDeCOD_ELE_PNB]
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].STA_EXEC_PNB
HAVING ((([1 Tabela_Manobra].STA_EXEC_PNB)<>"Passo Cancelado"));

-- ===== 14_2 Cruzamento Passos OS  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [14_0 Passos Cancelados OS].ContarDeCOD_ELE_PNB AS [Cancelados],
       [14_1 Passos Executados OS].ContarDeCOD_ELE_PNB AS [Executados]
FROM [1 Tabela_Intervenção]
  LEFT JOIN [14_0 Passos Cancelados OS] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [14_0 Passos Cancelados OS].NUM_SEQ_OPER_OS_PNB
  LEFT JOIN [14_1 Passos Executados OS] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [14_1 Passos Executados OS].NUM_SEQ_OPER_OS_PNB;

-- ===== 14_3 Cruzamento Passos OS - Filtro  (SELECT)
SELECT [14_2 Cruzamento Passos OS].NUM_SEQ_OPER_OS_MNB,
       [14_2 Cruzamento Passos OS].Cancelados,
       [14_2 Cruzamento Passos OS].Executados
FROM [14_2 Cruzamento Passos OS]
WHERE ((([14_2 Cruzamento Passos OS].Executados) Is Null));

-- ===== 14_4 OSs Vinculadas  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       Count([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR) AS [OS]
FROM [1 Tabela_Individual_Vinculada]
GROUP BY [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR;

-- ===== 14_5 Passo Cancelados com OSs Vinculadas  (SELECT)
SELECT [14_3 Cruzamento Passos OS - Filtro].NUM_SEQ_OPER_OS_MNB,
       [14_3 Cruzamento Passos OS - Filtro].Cancelados,
       [14_3 Cruzamento Passos OS - Filtro].Executados,
       [14_4 OSs Vinculadas].OS
FROM [14_3 Cruzamento Passos OS - Filtro]
  INNER JOIN [14_4 OSs Vinculadas] ON [14_3 Cruzamento Passos OS - Filtro].NUM_SEQ_OPER_OS_MNB = [14_4 OSs Vinculadas].NUM_SEQ_OPER_INTER_CNR;

-- ===== 14_6 Passo Cancelados Retirar  (SELECT)
SELECT [14_3 Cruzamento Passos OS - Filtro].NUM_SEQ_OPER_OS_MNB,
       [14_3 Cruzamento Passos OS - Filtro].Cancelados,
       [14_3 Cruzamento Passos OS - Filtro].Executados,
       [14_5 Passo Cancelados com OSs Vinculadas].OS
FROM [14_3 Cruzamento Passos OS - Filtro]
  LEFT JOIN [14_5 Passo Cancelados com OSs Vinculadas] ON [14_3 Cruzamento Passos OS - Filtro].NUM_SEQ_OPER_OS_MNB = [14_5 Passo Cancelados com OSs Vinculadas].NUM_SEQ_OPER_OS_MNB
WHERE ((([14_5 Passo Cancelados com OSs Vinculadas].OS) Is Null));

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

-- ===== 1_5 1º Manobra x 1º OS Vinc Filtro  (SELECT)
SELECT [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].NUM_SEQ_OPER_OS_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].COD_OPER_PNB,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].DTA_1º_PASSO,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].NUM_SEQ_OPER_CNR,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].DTA_1º_OS,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].TEMPO,
       [1_7 Cruz 1º Manobra x 1º OS Vinc Análise].Análise
FROM [1_7 Cruz 1º Manobra x 1º OS Vinc Análise]
WHERE ((([1_7 Cruz 1º Manobra x 1º OS Vinc Análise].Análise)<>""));

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

-- ===== 2 Base Original Ref Atual  (SELECT)
SELECT [4 Base_Original_Correções].DTA_CMPT_MNB,
       [4 Base_Original_Correções].TIPO_OS,
       [4 Base_Original_Correções].COD_CPU_OS_MNB,
       [4 Base_Original_Correções].NUM_SEQ_OPER_OS_MNB,
       [4 Base_Original_Correções].NUM_SEQ_GER_OS_MNB,
       [4 Base_Original_Correções].NOM_USU_PROGM_MNB,
       [4 Base_Original_Correções].NOM_USU_CFER_MNB,
       [4 Base_Original_Correções].NOM_USU_EXEC_MNB,
       [4 Base_Original_Correções].COD_TIPO_ORIG_INTV_MNB,
       [4 Base_Original_Correções].DES_ORIG_OGE,
       [4 Base_Original_Correções].COD_ORIG_INTV_MNB,
       [4 Base_Original_Correções].DES_ORIG_ORI,
       [4 Base_Original_Correções].COD_CAUSA_MNB,
       [4 Base_Original_Correções].DES_CAUSA_INTER_CAU,
       [4 Base_Original_Correções].COD_SUB_CAUSA_MNB,
       [4 Base_Original_Correções].DES_SUB_CAUSA_INTER_SCR,
       [4 Base_Original_Correções].NUM_CAUSA_ANEEL_MNB,
       [4 Base_Original_Correções].NUM_SUB_CAUSA_ANEEL_MNB,
       [4 Base_Original_Correções].DES_INTV_MNB,
       [4 Base_Original_Correções].DTA_INIC_MNB,
       [4 Base_Original_Correções].DTA_AVI_EQP_MNB,
       [4 Base_Original_Correções].DTA_DLCT_EQP_MNB,
       [4 Base_Original_Correções].DTA_VERI_EQP_MNB,
       [4 Base_Original_Correções].DTA_SERV_EQP_MNB,
       [4 Base_Original_Correções].DTA_FIM_MNB,
       [4 Base_Original_Correções].COD_ELE_MNB,
       [4 Base_Original_Correções].COD_INS_SEC_INS,
       [4 Base_Original_Correções].COD_TIPO_CONCL_COS,
       [4 Base_Original_Correções].COD_SUB_TIPO_OS_COS,
       [4 Base_Original_Correções].TIPO_TR,
       [4 Base_Original_Correções].TMA,
       [4 Base_Original_Correções].DEC,
       [4 Base_Original_Correções].DIF_1ª_2ª_RCM_1h,
       [4 Base_Original_Correções].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [4 Base_Original_Correções].TR_Próprio_OS_Proc,
       [4 Base_Original_Correções].Intev_Impro_Causa_Proc,
       [4 Base_Original_Correções].Intev_Proc_Causa_Impro,
       [4 Base_Original_Correções].[DEC_>_0,001],
       [4 Base_Original_Correções].TMD_0,
       [4 Base_Original_Correções].[TMA_>_1440],
       [4 Base_Original_Correções].[Intev_<_3_OS_Vinc_>_50_UCs],
       [4 Base_Original_Correções].Intev_S_OS_Vinc,
       [4 Base_Original_Correções].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [4 Base_Original_Correções].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [4 Base_Original_Correções].OS_Vinc_UCs_Interr,
       [4 Base_Original_Correções].Intev_0_UCs_Inter,
       [4 Base_Original_Correções].[Correção Realizada],
       [4 Base_Original_Correções].[Comp_>_500],
       [4 Base_Original_Correções].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [4 Base_Original_Correções].OS_Elemen_Particular_Proc,
       [4 Base_Original_Correções].[OS_Vinc_Hr_>_Ult_Passo],
       [4 Base_Original_Correções].OS_Impro_Sem_Elem_Partic,
       [4 Base_Original_Correções].FEC,
       [4 Base_Original_Correções].COD_LOC_COS,
       [4 Base_Original_Correções].LOCALIDADE,
       [4 Base_Original_Correções].COEC,
       [4 Base_Original_Correções].MULTA_OS,
       [4 Base_Original_Correções].Concat,
       [4 Base_Original_Correções].C_Classificação,
       [4 Base_Original_Correções].[C_OS Vinculada],
       [4 Base_Original_Correções].[C_Passo de Manobra],
       [4 Base_Original_Correções].C_Horário,
       [4 Base_Original_Correções].[C_Elemento Origem],
       [4 Base_Original_Correções].USUÁRIO,
       [4 Base_Original_Correções].OBSERVAÇÃO,
       [4 Base_Original_Correções].STATUS,
       [4 Base_Original_Correções].[DATA ANÁLISE],
       [4 Base_Original_Correções].[DATA BAIXA],
       [4 Base_Original_Correções].Intv_TR_Zona_Div_UC,
       [4 Base_Original_Correções].OS_Externa,
       [4 Base_Original_Correções].OS_Acessante
FROM [0 Competência_Atual]
  INNER JOIN [4 Base_Original_Correções] ON [0 Competência_Atual].DTA_CMPT_MNB = [4 Base_Original_Correções].DTA_CMPT_MNB;

-- ===== 2 Gravar_OS_Analisada  (APPEND)
INSERT INTO [3 T_OS_Analisada] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, MULTA_OS, FEC, COD_LOC_COS, LOCALIDADE, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, Intv_TR_Zona_Div_UC, OS_Externa, OS_Acessante)
SELECT [1 OS_Análisadas].TIPO_OS,
       [1 OS_Análisadas].DTA_CMPT_MNB,
       [1 OS_Análisadas].COD_CPU_OS_MNB,
       [1 OS_Análisadas].NUM_SEQ_OPER_OS_MNB,
       [1 OS_Análisadas].NUM_SEQ_GER_OS_MNB,
       [1 OS_Análisadas].NOM_USU_PROGM_MNB,
       [1 OS_Análisadas].NOM_USU_CFER_MNB,
       [1 OS_Análisadas].NOM_USU_EXEC_MNB,
       [1 OS_Análisadas].COD_TIPO_ORIG_INTV_MNB,
       [1 OS_Análisadas].DES_ORIG_OGE,
       [1 OS_Análisadas].COD_ORIG_INTV_MNB,
       [1 OS_Análisadas].DES_ORIG_ORI,
       [1 OS_Análisadas].COD_CAUSA_MNB,
       [1 OS_Análisadas].DES_CAUSA_INTER_CAU,
       [1 OS_Análisadas].COD_SUB_CAUSA_MNB,
       [1 OS_Análisadas].DES_SUB_CAUSA_INTER_SCR,
       [1 OS_Análisadas].NUM_CAUSA_ANEEL_MNB,
       [1 OS_Análisadas].NUM_SUB_CAUSA_ANEEL_MNB,
       [1 OS_Análisadas].DES_INTV_MNB,
       [1 OS_Análisadas].DTA_INIC_MNB,
       [1 OS_Análisadas].DTA_AVI_EQP_MNB,
       [1 OS_Análisadas].DTA_DLCT_EQP_MNB,
       [1 OS_Análisadas].DTA_VERI_EQP_MNB,
       [1 OS_Análisadas].DTA_SERV_EQP_MNB,
       [1 OS_Análisadas].DTA_FIM_MNB,
       [1 OS_Análisadas].COD_ELE_MNB,
       [1 OS_Análisadas].COD_INS_SEC_INS,
       [1 OS_Análisadas].COD_TIPO_CONCL_COS,
       [1 OS_Análisadas].COD_SUB_TIPO_OS_COS,
       [1 OS_Análisadas].TIPO_TR,
       [1 OS_Análisadas].TMA,
       [1 OS_Análisadas].DEC,
       [1 OS_Análisadas].DIF_1ª_2ª_RCM_1h,
       [1 OS_Análisadas].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [1 OS_Análisadas].TR_Próprio_OS_Proc,
       [1 OS_Análisadas].Intev_Impro_Causa_Proc,
       [1 OS_Análisadas].Intev_Proc_Causa_Impro,
       [1 OS_Análisadas].[DEC_>_0,001],
       [1 OS_Análisadas].TMD_0,
       [1 OS_Análisadas].[TMA_>_1440],
       [1 OS_Análisadas].[Intev_<_3_OS_Vinc_>_50_UCs],
       [1 OS_Análisadas].Intev_S_OS_Vinc,
       [1 OS_Análisadas].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [1 OS_Análisadas].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [1 OS_Análisadas].OS_Vinc_UCs_Interr,
       [1 OS_Análisadas].Intev_0_UCs_Inter,
       [1 OS_Análisadas].[Comp_>_500],
       [1 OS_Análisadas].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [1 OS_Análisadas].OS_Elemen_Particular_Proc,
       [1 OS_Análisadas].[OS_Vinc_Hr_>_Ult_Passo],
       [1 OS_Análisadas].OS_Impro_Sem_Elem_Partic,
       [1 OS_Análisadas].MULTA_OS,
       [1 OS_Análisadas].FEC,
       [1 OS_Análisadas].COD_LOC_COS,
       [1 OS_Análisadas].LOCALIDADE,
       [1 OS_Análisadas].COEC,
       [1 OS_Análisadas].[Correção Realizada],
       [1 OS_Análisadas].C_Classificação,
       [1 OS_Análisadas].[C_OS Vinculada],
       [1 OS_Análisadas].[C_Passo de Manobra],
       [1 OS_Análisadas].C_Horário,
       [1 OS_Análisadas].[C_Elemento Origem],
       [1 OS_Análisadas].USUÁRIO,
       [1 OS_Análisadas].OBSERVAÇÃO,
       [1 OS_Análisadas].STATUS,
       [1 OS_Análisadas].[DATA ANÁLISE],
       [1 OS_Análisadas].[DATA BAIXA],
       [1 OS_Análisadas].Intv_TR_Zona_Div_UC,
       [1 OS_Análisadas].OS_Externa,
       [1 OS_Análisadas].OS_Acessante
FROM [1 OS_Análisadas]
  LEFT JOIN [3 T_OS_Analisada] ON [1 OS_Análisadas].NUM_SEQ_OPER_OS_MNB = [3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB
WHERE ((([3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY [1 OS_Análisadas].TIPO_OS, [1 OS_Análisadas].DTA_CMPT_MNB, [1 OS_Análisadas].COD_CPU_OS_MNB, [1 OS_Análisadas].NUM_SEQ_OPER_OS_MNB, [1 OS_Análisadas].NUM_SEQ_GER_OS_MNB, [1 OS_Análisadas].NOM_USU_PROGM_MNB, [1 OS_Análisadas].NOM_USU_CFER_MNB, [1 OS_Análisadas].NOM_USU_EXEC_MNB, [1 OS_Análisadas].COD_TIPO_ORIG_INTV_MNB, [1 OS_Análisadas].DES_ORIG_OGE, [1 OS_Análisadas].COD_ORIG_INTV_MNB, [1 OS_Análisadas].DES_ORIG_ORI, [1 OS_Análisadas].COD_CAUSA_MNB, [1 OS_Análisadas].DES_CAUSA_INTER_CAU, [1 OS_Análisadas].COD_SUB_CAUSA_MNB, [1 OS_Análisadas].DES_SUB_CAUSA_INTER_SCR, [1 OS_Análisadas].NUM_CAUSA_ANEEL_MNB, [1 OS_Análisadas].NUM_SUB_CAUSA_ANEEL_MNB, [1 OS_Análisadas].DES_INTV_MNB, [1 OS_Análisadas].DTA_INIC_MNB, [1 OS_Análisadas].DTA_AVI_EQP_MNB, [1 OS_Análisadas].DTA_DLCT_EQP_MNB, [1 OS_Análisadas].DTA_VERI_EQP_MNB, [1 OS_Análisadas].DTA_SERV_EQP_MNB, [1 OS_Análisadas].DTA_FIM_MNB, [1 OS_Análisadas].COD_ELE_MNB, [1 OS_Análisadas].COD_INS_SEC_INS, [1 OS_Análisadas].COD_TIPO_CONCL_COS, [1 OS_Análisadas].COD_SUB_TIPO_OS_COS, [1 OS_Análisadas].TIPO_TR, [1 OS_Análisadas].TMA, [1 OS_Análisadas].DEC, [1 OS_Análisadas].DIF_1ª_2ª_RCM_1h, [1 OS_Análisadas].DIF_1ª_Man_1ª_OS_Vinc_2h, [1 OS_Análisadas].TR_Próprio_OS_Proc, [1 OS_Análisadas].Intev_Impro_Causa_Proc, [1 OS_Análisadas].Intev_Proc_Causa_Impro, [1 OS_Análisadas].[DEC_>_0,001], [1 OS_Análisadas].TMD_0, [1 OS_Análisadas].[TMA_>_1440], [1 OS_Análisadas].[Intev_<_3_OS_Vinc_>_50_UCs], [1 OS_Análisadas].Intev_S_OS_Vinc, [1 OS_Análisadas].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [1 OS_Análisadas].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [1 OS_Análisadas].OS_Vinc_UCs_Interr, [1 OS_Análisadas].Intev_0_UCs_Inter, [1 OS_Análisadas].[Comp_>_500], [1 OS_Análisadas].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [1 OS_Análisadas].OS_Elemen_Particular_Proc, [1 OS_Análisadas].[OS_Vinc_Hr_>_Ult_Passo], [1 OS_Análisadas].OS_Impro_Sem_Elem_Partic, [1 OS_Análisadas].MULTA_OS, [1 OS_Análisadas].FEC, [1 OS_Análisadas].COD_LOC_COS, [1 OS_Análisadas].LOCALIDADE, [1 OS_Análisadas].COEC, [1 OS_Análisadas].[Correção Realizada], [1 OS_Análisadas].C_Classificação, [1 OS_Análisadas].[C_OS Vinculada], [1 OS_Análisadas].[C_Passo de Manobra], [1 OS_Análisadas].C_Horário, [1 OS_Análisadas].[C_Elemento Origem], [1 OS_Análisadas].USUÁRIO, [1 OS_Análisadas].OBSERVAÇÃO, [1 OS_Análisadas].STATUS, [1 OS_Análisadas].[DATA ANÁLISE], [1 OS_Análisadas].[DATA BAIXA], [1 OS_Análisadas].Intv_TR_Zona_Div_UC, [1 OS_Análisadas].OS_Externa, [1 OS_Análisadas].OS_Acessante;

-- ===== 2 Gravar_OS_Corrigida  (APPEND)
INSERT INTO [3 OS_Corrigida] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, MULTA_OS, FEC, COD_LOC_COS, LOCALIDADE, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, Intv_TR_Zona_Div_UC, OS_Externa, OS_Acessante)
SELECT [2 Gravar_OS_Corrigidas].TIPO_OS,
       [2 Gravar_OS_Corrigidas].DTA_CMPT_MNB,
       [2 Gravar_OS_Corrigidas].COD_CPU_OS_MNB,
       [2 Gravar_OS_Corrigidas].NUM_SEQ_OPER_OS_MNB,
       [2 Gravar_OS_Corrigidas].NUM_SEQ_GER_OS_MNB,
       [2 Gravar_OS_Corrigidas].NOM_USU_PROGM_MNB,
       [2 Gravar_OS_Corrigidas].NOM_USU_CFER_MNB,
       [2 Gravar_OS_Corrigidas].NOM_USU_EXEC_MNB,
       [2 Gravar_OS_Corrigidas].COD_TIPO_ORIG_INTV_MNB,
       [2 Gravar_OS_Corrigidas].DES_ORIG_OGE,
       [2 Gravar_OS_Corrigidas].COD_ORIG_INTV_MNB,
       [2 Gravar_OS_Corrigidas].DES_ORIG_ORI,
       [2 Gravar_OS_Corrigidas].COD_CAUSA_MNB,
       [2 Gravar_OS_Corrigidas].DES_CAUSA_INTER_CAU,
       [2 Gravar_OS_Corrigidas].COD_SUB_CAUSA_MNB,
       [2 Gravar_OS_Corrigidas].DES_SUB_CAUSA_INTER_SCR,
       [2 Gravar_OS_Corrigidas].NUM_CAUSA_ANEEL_MNB,
       [2 Gravar_OS_Corrigidas].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Gravar_OS_Corrigidas].DES_INTV_MNB,
       [2 Gravar_OS_Corrigidas].DTA_INIC_MNB,
       [2 Gravar_OS_Corrigidas].DTA_AVI_EQP_MNB,
       [2 Gravar_OS_Corrigidas].DTA_DLCT_EQP_MNB,
       [2 Gravar_OS_Corrigidas].DTA_VERI_EQP_MNB,
       [2 Gravar_OS_Corrigidas].DTA_SERV_EQP_MNB,
       [2 Gravar_OS_Corrigidas].DTA_FIM_MNB,
       [2 Gravar_OS_Corrigidas].COD_ELE_MNB,
       [2 Gravar_OS_Corrigidas].COD_INS_SEC_INS,
       [2 Gravar_OS_Corrigidas].COD_TIPO_CONCL_COS,
       [2 Gravar_OS_Corrigidas].COD_SUB_TIPO_OS_COS,
       [2 Gravar_OS_Corrigidas].TIPO_TR,
       [2 Gravar_OS_Corrigidas].TMA,
       [2 Gravar_OS_Corrigidas].DEC,
       [2 Gravar_OS_Corrigidas].DIF_1ª_2ª_RCM_1h,
       [2 Gravar_OS_Corrigidas].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Gravar_OS_Corrigidas].TR_Próprio_OS_Proc,
       [2 Gravar_OS_Corrigidas].Intev_Impro_Causa_Proc,
       [2 Gravar_OS_Corrigidas].Intev_Proc_Causa_Impro,
       [2 Gravar_OS_Corrigidas].[DEC_>_0,001],
       [2 Gravar_OS_Corrigidas].TMD_0,
       [2 Gravar_OS_Corrigidas].[TMA_>_1440],
       [2 Gravar_OS_Corrigidas].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Gravar_OS_Corrigidas].Intev_S_OS_Vinc,
       [2 Gravar_OS_Corrigidas].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Gravar_OS_Corrigidas].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Gravar_OS_Corrigidas].OS_Vinc_UCs_Interr,
       [2 Gravar_OS_Corrigidas].Intev_0_UCs_Inter,
       [2 Gravar_OS_Corrigidas].[Comp_>_500],
       [2 Gravar_OS_Corrigidas].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Gravar_OS_Corrigidas].OS_Elemen_Particular_Proc,
       [2 Gravar_OS_Corrigidas].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Gravar_OS_Corrigidas].OS_Impro_Sem_Elem_Partic,
       [2 Gravar_OS_Corrigidas].MULTA_OS,
       [2 Gravar_OS_Corrigidas].FEC,
       [2 Gravar_OS_Corrigidas].COD_LOC_COS,
       [2 Gravar_OS_Corrigidas].LOCALIDADE,
       [2 Gravar_OS_Corrigidas].COEC,
       [2 Gravar_OS_Corrigidas].[Correção Realizada],
       [2 Gravar_OS_Corrigidas].C_Classificação,
       [2 Gravar_OS_Corrigidas].[C_OS Vinculada],
       [2 Gravar_OS_Corrigidas].[C_Passo de Manobra],
       [2 Gravar_OS_Corrigidas].C_Horário,
       [2 Gravar_OS_Corrigidas].[C_Elemento Origem],
       [2 Gravar_OS_Corrigidas].USUÁRIO,
       [2 Gravar_OS_Corrigidas].OBSERVAÇÃO,
       [2 Gravar_OS_Corrigidas].STATUS,
       [2 Gravar_OS_Corrigidas].[DATA ANÁLISE],
       [2 Gravar_OS_Corrigidas].[DATA BAIXA],
       [2 Gravar_OS_Corrigidas].Intv_TR_Zona_Div_UC,
       [2 Gravar_OS_Corrigidas].OS_Externa,
       [2 Gravar_OS_Corrigidas].OS_Acessante
FROM [2 Gravar_OS_Corrigidas]
GROUP BY [2 Gravar_OS_Corrigidas].TIPO_OS, [2 Gravar_OS_Corrigidas].DTA_CMPT_MNB, [2 Gravar_OS_Corrigidas].COD_CPU_OS_MNB, [2 Gravar_OS_Corrigidas].NUM_SEQ_OPER_OS_MNB, [2 Gravar_OS_Corrigidas].NUM_SEQ_GER_OS_MNB, [2 Gravar_OS_Corrigidas].NOM_USU_PROGM_MNB, [2 Gravar_OS_Corrigidas].NOM_USU_CFER_MNB, [2 Gravar_OS_Corrigidas].NOM_USU_EXEC_MNB, [2 Gravar_OS_Corrigidas].COD_TIPO_ORIG_INTV_MNB, [2 Gravar_OS_Corrigidas].DES_ORIG_OGE, [2 Gravar_OS_Corrigidas].COD_ORIG_INTV_MNB, [2 Gravar_OS_Corrigidas].DES_ORIG_ORI, [2 Gravar_OS_Corrigidas].COD_CAUSA_MNB, [2 Gravar_OS_Corrigidas].DES_CAUSA_INTER_CAU, [2 Gravar_OS_Corrigidas].COD_SUB_CAUSA_MNB, [2 Gravar_OS_Corrigidas].DES_SUB_CAUSA_INTER_SCR, [2 Gravar_OS_Corrigidas].NUM_CAUSA_ANEEL_MNB, [2 Gravar_OS_Corrigidas].NUM_SUB_CAUSA_ANEEL_MNB, [2 Gravar_OS_Corrigidas].DES_INTV_MNB, [2 Gravar_OS_Corrigidas].DTA_INIC_MNB, [2 Gravar_OS_Corrigidas].DTA_AVI_EQP_MNB, [2 Gravar_OS_Corrigidas].DTA_DLCT_EQP_MNB, [2 Gravar_OS_Corrigidas].DTA_VERI_EQP_MNB, [2 Gravar_OS_Corrigidas].DTA_SERV_EQP_MNB, [2 Gravar_OS_Corrigidas].DTA_FIM_MNB, [2 Gravar_OS_Corrigidas].COD_ELE_MNB, [2 Gravar_OS_Corrigidas].COD_INS_SEC_INS, [2 Gravar_OS_Corrigidas].COD_TIPO_CONCL_COS, [2 Gravar_OS_Corrigidas].COD_SUB_TIPO_OS_COS, [2 Gravar_OS_Corrigidas].TIPO_TR, [2 Gravar_OS_Corrigidas].TMA, [2 Gravar_OS_Corrigidas].DEC, [2 Gravar_OS_Corrigidas].DIF_1ª_2ª_RCM_1h, [2 Gravar_OS_Corrigidas].DIF_1ª_Man_1ª_OS_Vinc_2h, [2 Gravar_OS_Corrigidas].TR_Próprio_OS_Proc, [2 Gravar_OS_Corrigidas].Intev_Impro_Causa_Proc, [2 Gravar_OS_Corrigidas].Intev_Proc_Causa_Impro, [2 Gravar_OS_Corrigidas].[DEC_>_0,001], [2 Gravar_OS_Corrigidas].TMD_0, [2 Gravar_OS_Corrigidas].[TMA_>_1440], [2 Gravar_OS_Corrigidas].[Intev_<_3_OS_Vinc_>_50_UCs], [2 Gravar_OS_Corrigidas].Intev_S_OS_Vinc, [2 Gravar_OS_Corrigidas].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [2 Gravar_OS_Corrigidas].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [2 Gravar_OS_Corrigidas].OS_Vinc_UCs_Interr, [2 Gravar_OS_Corrigidas].Intev_0_UCs_Inter, [2 Gravar_OS_Corrigidas].[Comp_>_500], [2 Gravar_OS_Corrigidas].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [2 Gravar_OS_Corrigidas].OS_Elemen_Particular_Proc, [2 Gravar_OS_Corrigidas].[OS_Vinc_Hr_>_Ult_Passo], [2 Gravar_OS_Corrigidas].OS_Impro_Sem_Elem_Partic, [2 Gravar_OS_Corrigidas].MULTA_OS, [2 Gravar_OS_Corrigidas].FEC, [2 Gravar_OS_Corrigidas].COD_LOC_COS, [2 Gravar_OS_Corrigidas].LOCALIDADE, [2 Gravar_OS_Corrigidas].COEC, [2 Gravar_OS_Corrigidas].[Correção Realizada], [2 Gravar_OS_Corrigidas].C_Classificação, [2 Gravar_OS_Corrigidas].[C_OS Vinculada], [2 Gravar_OS_Corrigidas].[C_Passo de Manobra], [2 Gravar_OS_Corrigidas].C_Horário, [2 Gravar_OS_Corrigidas].[C_Elemento Origem], [2 Gravar_OS_Corrigidas].USUÁRIO, [2 Gravar_OS_Corrigidas].OBSERVAÇÃO, [2 Gravar_OS_Corrigidas].STATUS, [2 Gravar_OS_Corrigidas].[DATA ANÁLISE], [2 Gravar_OS_Corrigidas].[DATA BAIXA], [2 Gravar_OS_Corrigidas].Intv_TR_Zona_Div_UC, [2 Gravar_OS_Corrigidas].OS_Externa, [2 Gravar_OS_Corrigidas].OS_Acessante;

-- ===== 2 Gravar_OS_Corrigidas  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros].TMA,
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc,
       [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic,
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros]
  LEFT JOIN [3 OS_Corrigida] ON [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB = [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB
  INNER JOIN [1 OS_Corrigidas] ON [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB = [1 OS_Corrigidas].NUM_SEQ_OPER_OS_MNB
WHERE ((([3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY [2 Intervenção Unificada - Filtros].TIPO_OS, [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB, [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB, [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB, [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB, [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB, [2 Intervenção Unificada - Filtros].DES_ORIG_OGE, [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB, [2 Intervenção Unificada - Filtros].DES_ORIG_ORI, [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB, [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU, [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB, [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR, [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB, [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB, [2 Intervenção Unificada - Filtros].DES_INTV_MNB, [2 Intervenção Unificada - Filtros].DTA_INIC_MNB, [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_FIM_MNB, [2 Intervenção Unificada - Filtros].COD_ELE_MNB, [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS, [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS, [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS, [2 Intervenção Unificada - Filtros].TIPO_TR, [2 Intervenção Unificada - Filtros].TMA, [2 Intervenção Unificada - Filtros].DEC, [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h, [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h, [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc, [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc, [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro, [2 Intervenção Unificada - Filtros].[DEC_>_0,001], [2 Intervenção Unificada - Filtros].TMD_0, [2 Intervenção Unificada - Filtros].[TMA_>_1440], [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs], [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc, [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr, [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter, [2 Intervenção Unificada - Filtros].[Comp_>_500], [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc, [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo], [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic, [2 Intervenção Unificada - Filtros].MULTA_OS, [2 Intervenção Unificada - Filtros].FEC, [2 Intervenção Unificada - Filtros].COD_LOC_COS, [2 Intervenção Unificada - Filtros].LOCALIDADE, [2 Intervenção Unificada - Filtros].COEC, [2 Intervenção Unificada - Filtros].[Correção Realizada], [2 Intervenção Unificada - Filtros].C_Classificação, [2 Intervenção Unificada - Filtros].[C_OS Vinculada], [2 Intervenção Unificada - Filtros].[C_Passo de Manobra], [2 Intervenção Unificada - Filtros].C_Horário, [2 Intervenção Unificada - Filtros].[C_Elemento Origem], [2 Intervenção Unificada - Filtros].USUÁRIO, [2 Intervenção Unificada - Filtros].OBSERVAÇÃO, [2 Intervenção Unificada - Filtros].STATUS, [2 Intervenção Unificada - Filtros].[DATA ANÁLISE], [2 Intervenção Unificada - Filtros].[DATA BAIXA], [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC, [2 Intervenção Unificada - Filtros].OS_Externa, [2 Intervenção Unificada - Filtros].OS_Acessante
HAVING ((([2 Intervenção Unificada - Filtros].TIPO_OS)="INTERVENÇÃO"));

-- ===== 2 T_OS_Corrigida  (SELECT)
SELECT [3 OS_Corrigida].DTA_CMPT_MNB,
       [3 OS_Corrigida].TIPO_OS,
       [3 OS_Corrigida].COD_CPU_OS_MNB,
       [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB,
       [3 OS_Corrigida].NUM_SEQ_GER_OS_MNB,
       [3 OS_Corrigida].NOM_USU_PROGM_MNB,
       [3 OS_Corrigida].NOM_USU_CFER_MNB,
       [3 OS_Corrigida].NOM_USU_EXEC_MNB,
       [3 OS_Corrigida].COD_TIPO_ORIG_INTV_MNB,
       [3 OS_Corrigida].DES_ORIG_OGE,
       [3 OS_Corrigida].COD_ORIG_INTV_MNB,
       [3 OS_Corrigida].DES_ORIG_ORI,
       [3 OS_Corrigida].COD_CAUSA_MNB,
       [3 OS_Corrigida].DES_CAUSA_INTER_CAU,
       [3 OS_Corrigida].COD_SUB_CAUSA_MNB,
       [3 OS_Corrigida].DES_SUB_CAUSA_INTER_SCR,
       [3 OS_Corrigida].NUM_CAUSA_ANEEL_MNB,
       [3 OS_Corrigida].NUM_SUB_CAUSA_ANEEL_MNB,
       [3 OS_Corrigida].DES_INTV_MNB,
       [3 OS_Corrigida].DTA_INIC_MNB,
       [3 OS_Corrigida].DTA_AVI_EQP_MNB,
       [3 OS_Corrigida].DTA_DLCT_EQP_MNB,
       [3 OS_Corrigida].DTA_VERI_EQP_MNB,
       [3 OS_Corrigida].DTA_SERV_EQP_MNB,
       [3 OS_Corrigida].DTA_FIM_MNB,
       [3 OS_Corrigida].COD_ELE_MNB,
       [3 OS_Corrigida].COD_INS_SEC_INS,
       [3 OS_Corrigida].COD_TIPO_CONCL_COS,
       [3 OS_Corrigida].COD_SUB_TIPO_OS_COS,
       [3 OS_Corrigida].TIPO_TR,
       [3 OS_Corrigida].TMA,
       [3 OS_Corrigida].DEC,
       [3 OS_Corrigida].DIF_1ª_2ª_RCM_1h,
       [3 OS_Corrigida].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [3 OS_Corrigida].TR_Próprio_OS_Proc,
       [3 OS_Corrigida].Intev_Impro_Causa_Proc,
       [3 OS_Corrigida].Intev_Proc_Causa_Impro,
       [3 OS_Corrigida].[DEC_>_0,001],
       [3 OS_Corrigida].TMD_0,
       [3 OS_Corrigida].[TMA_>_1440],
       [3 OS_Corrigida].[Intev_<_3_OS_Vinc_>_50_UCs],
       [3 OS_Corrigida].Intev_S_OS_Vinc,
       [3 OS_Corrigida].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [3 OS_Corrigida].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [3 OS_Corrigida].OS_Vinc_UCs_Interr,
       [3 OS_Corrigida].Intev_0_UCs_Inter,
       [3 OS_Corrigida].[Comp_>_500],
       [3 OS_Corrigida].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [3 OS_Corrigida].OS_Elemen_Particular_Proc,
       [3 OS_Corrigida].[OS_Vinc_Hr_>_Ult_Passo],
       [3 OS_Corrigida].OS_Impro_Sem_Elem_Partic,
       [3 OS_Corrigida].MULTA_OS,
       [3 OS_Corrigida].FEC,
       [3 OS_Corrigida].COD_LOC_COS,
       [3 OS_Corrigida].LOCALIDADE,
       [3 OS_Corrigida].COEC,
       [3 OS_Corrigida].[Correção Realizada],
       [3 OS_Corrigida].C_Classificação,
       [3 OS_Corrigida].[C_OS Vinculada],
       [3 OS_Corrigida].[C_Passo de Manobra],
       [3 OS_Corrigida].C_Horário,
       [3 OS_Corrigida].[C_Elemento Origem],
       [3 OS_Corrigida].USUÁRIO,
       [3 OS_Corrigida].OBSERVAÇÃO,
       [3 OS_Corrigida].STATUS,
       [3 OS_Corrigida].[DATA ANÁLISE],
       [3 OS_Corrigida].[DATA BAIXA]
FROM [3 OS_Corrigida];

-- ===== 2 T_OS_Corrigida_Ganho  (SELECT)
SELECT [2 T_OS_Corrigida].DTA_CMPT_MNB,
       [2 T_OS_Corrigida].TIPO_OS,
       [2 T_OS_Corrigida].COD_CPU_OS_MNB,
       [2 T_OS_Corrigida].NUM_SEQ_OPER_OS_MNB,
       [2 T_OS_Corrigida].NUM_SEQ_GER_OS_MNB,
       [2 T_OS_Corrigida].NOM_USU_PROGM_MNB,
       [2 T_OS_Corrigida].NOM_USU_CFER_MNB,
       [2 T_OS_Corrigida].NOM_USU_EXEC_MNB,
       [2 T_OS_Corrigida].COD_TIPO_ORIG_INTV_MNB,
       [2 T_OS_Corrigida].DES_ORIG_OGE,
       [2 T_OS_Corrigida].COD_ORIG_INTV_MNB,
       [2 T_OS_Corrigida].DES_ORIG_ORI,
       [2 T_OS_Corrigida].COD_CAUSA_MNB,
       [2 T_OS_Corrigida].DES_CAUSA_INTER_CAU,
       [2 T_OS_Corrigida].COD_SUB_CAUSA_MNB,
       [2 T_OS_Corrigida].DES_SUB_CAUSA_INTER_SCR,
       [2 T_OS_Corrigida].NUM_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida].DES_INTV_MNB,
       [2 T_OS_Corrigida].DTA_INIC_MNB,
       [2 T_OS_Corrigida].DTA_AVI_EQP_MNB,
       [2 T_OS_Corrigida].DTA_DLCT_EQP_MNB,
       [2 T_OS_Corrigida].DTA_VERI_EQP_MNB,
       [2 T_OS_Corrigida].DTA_SERV_EQP_MNB,
       [2 T_OS_Corrigida].DTA_FIM_MNB,
       [2 T_OS_Corrigida].COD_ELE_MNB,
       [2 T_OS_Corrigida].COD_INS_SEC_INS,
       [2 T_OS_Corrigida].COD_TIPO_CONCL_COS,
       [2 T_OS_Corrigida].COD_SUB_TIPO_OS_COS,
       [2 T_OS_Corrigida].TIPO_TR,
       [2 T_OS_Corrigida].TMA,
       [2 T_OS_Corrigida].DEC,
       [2 T_OS_Corrigida].DIF_1ª_2ª_RCM_1h,
       [2 T_OS_Corrigida].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 T_OS_Corrigida].TR_Próprio_OS_Proc,
       [2 T_OS_Corrigida].Intev_Impro_Causa_Proc,
       [2 T_OS_Corrigida].Intev_Proc_Causa_Impro,
       [2 T_OS_Corrigida].[DEC_>_0,001],
       [2 T_OS_Corrigida].TMD_0,
       [2 T_OS_Corrigida].[TMA_>_1440],
       [2 T_OS_Corrigida].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 T_OS_Corrigida].Intev_S_OS_Vinc,
       [2 T_OS_Corrigida].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 T_OS_Corrigida].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 T_OS_Corrigida].OS_Vinc_UCs_Interr,
       [2 T_OS_Corrigida].Intev_0_UCs_Inter,
       [2 T_OS_Corrigida].[Comp_>_500],
       [2 T_OS_Corrigida].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 T_OS_Corrigida].OS_Elemen_Particular_Proc,
       [2 T_OS_Corrigida].[OS_Vinc_Hr_>_Ult_Passo],
       [2 T_OS_Corrigida].OS_Impro_Sem_Elem_Partic,
       [2 T_OS_Corrigida].MULTA_OS,
       [2 T_OS_Corrigida].FEC,
       [2 T_OS_Corrigida].COD_LOC_COS,
       [2 T_OS_Corrigida].LOCALIDADE,
       [2 T_OS_Corrigida].COEC,
       [2 T_OS_Corrigida].[Correção Realizada],
       [2 T_OS_Corrigida].C_Classificação,
       [2 T_OS_Corrigida].[C_OS Vinculada],
       [2 T_OS_Corrigida].[C_Passo de Manobra],
       [2 T_OS_Corrigida].C_Horário,
       [2 T_OS_Corrigida].[C_Elemento Origem],
       [2 T_OS_Corrigida].USUÁRIO,
       [2 T_OS_Corrigida].OBSERVAÇÃO,
       [2 T_OS_Corrigida].STATUS,
       [2 T_OS_Corrigida].[DATA ANÁLISE],
       [2 T_OS_Corrigida].[DATA BAIXA]
FROM [2 T_OS_Corrigida]
  INNER JOIN [1 Cruzamento_Bases_Cálculo_Ganho_Correção] ON [2 T_OS_Corrigida].NUM_SEQ_OPER_OS_MNB = [1 Cruzamento_Bases_Cálculo_Ganho_Correção].NUM_SEQ_OPER_OS_MNB;

-- ===== 2 T_OS_Corrigida_Ganho_Cruzamento  (SELECT)
SELECT [2 T_OS_Corrigida_Ganho].DTA_CMPT_MNB,
       [2 T_OS_Corrigida_Ganho].TIPO_OS,
       [2 T_OS_Corrigida_Ganho].COD_CPU_OS_MNB,
       [2 T_OS_Corrigida_Ganho].NUM_SEQ_OPER_OS_MNB,
       [2 T_OS_Corrigida_Ganho].NUM_SEQ_GER_OS_MNB,
       [2 T_OS_Corrigida_Ganho].NOM_USU_PROGM_MNB,
       [2 T_OS_Corrigida_Ganho].NOM_USU_CFER_MNB,
       [2 T_OS_Corrigida_Ganho].NOM_USU_EXEC_MNB,
       [2 T_OS_Corrigida_Ganho].COD_TIPO_ORIG_INTV_MNB,
       [2 T_OS_Corrigida_Ganho].DES_ORIG_OGE,
       [2 T_OS_Corrigida_Ganho].COD_ORIG_INTV_MNB,
       [2 T_OS_Corrigida_Ganho].DES_ORIG_ORI,
       [2 T_OS_Corrigida_Ganho].COD_CAUSA_MNB,
       [2 T_OS_Corrigida_Ganho].DES_CAUSA_INTER_CAU,
       [2 T_OS_Corrigida_Ganho].COD_SUB_CAUSA_MNB,
       [2 T_OS_Corrigida_Ganho].DES_SUB_CAUSA_INTER_SCR,
       [2 T_OS_Corrigida_Ganho].NUM_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida_Ganho].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida_Ganho].DES_INTV_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_INIC_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_AVI_EQP_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_DLCT_EQP_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_VERI_EQP_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_SERV_EQP_MNB,
       [2 T_OS_Corrigida_Ganho].DTA_FIM_MNB,
       [2 T_OS_Corrigida_Ganho].COD_ELE_MNB,
       [2 T_OS_Corrigida_Ganho].COD_INS_SEC_INS,
       [2 T_OS_Corrigida_Ganho].COD_TIPO_CONCL_COS,
       [2 T_OS_Corrigida_Ganho].COD_SUB_TIPO_OS_COS,
       [2 T_OS_Corrigida_Ganho].TIPO_TR,
       [2 T_OS_Corrigida_Ganho].TMA,
       [2 T_OS_Corrigida_Ganho].DEC,
       [2 T_OS_Corrigida_Ganho].DIF_1ª_2ª_RCM_1h,
       [2 T_OS_Corrigida_Ganho].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 T_OS_Corrigida_Ganho].TR_Próprio_OS_Proc,
       [2 T_OS_Corrigida_Ganho].Intev_Impro_Causa_Proc,
       [2 T_OS_Corrigida_Ganho].Intev_Proc_Causa_Impro,
       [2 T_OS_Corrigida_Ganho].[DEC_>_0,001],
       [2 T_OS_Corrigida_Ganho].TMD_0,
       [2 T_OS_Corrigida_Ganho].[TMA_>_1440],
       [2 T_OS_Corrigida_Ganho].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 T_OS_Corrigida_Ganho].Intev_S_OS_Vinc,
       [2 T_OS_Corrigida_Ganho].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 T_OS_Corrigida_Ganho].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 T_OS_Corrigida_Ganho].OS_Vinc_UCs_Interr,
       [2 T_OS_Corrigida_Ganho].Intev_0_UCs_Inter,
       [2 T_OS_Corrigida_Ganho].[Comp_>_500],
       [2 T_OS_Corrigida_Ganho].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 T_OS_Corrigida_Ganho].OS_Elemen_Particular_Proc,
       [2 T_OS_Corrigida_Ganho].[OS_Vinc_Hr_>_Ult_Passo],
       [2 T_OS_Corrigida_Ganho].OS_Impro_Sem_Elem_Partic,
       [2 T_OS_Corrigida_Ganho].MULTA_OS,
       [2 T_OS_Corrigida_Ganho].FEC,
       [2 T_OS_Corrigida_Ganho].COD_LOC_COS,
       [2 T_OS_Corrigida_Ganho].LOCALIDADE,
       [2 T_OS_Corrigida_Ganho].COEC,
       [2 T_OS_Corrigida_Ganho].[Correção Realizada],
       [2 T_OS_Corrigida_Ganho].C_Classificação,
       [2 T_OS_Corrigida_Ganho].[C_OS Vinculada],
       [2 T_OS_Corrigida_Ganho].[C_Passo de Manobra],
       [2 T_OS_Corrigida_Ganho].C_Horário,
       [2 T_OS_Corrigida_Ganho].[C_Elemento Origem],
       [2 T_OS_Corrigida_Ganho].USUÁRIO,
       [2 T_OS_Corrigida_Ganho].OBSERVAÇÃO,
       [2 T_OS_Corrigida_Ganho].STATUS,
       [2 T_OS_Corrigida_Ganho].[DATA ANÁLISE],
       [2 T_OS_Corrigida_Ganho].[DATA BAIXA],
       [1 Cruzamento_Bases_Cálculo_Ganho_Correção].DEC_G,
       [1 Cruzamento_Bases_Cálculo_Ganho_Correção].FEC_G,
       [1 Cruzamento_Bases_Cálculo_Ganho_Correção].TMA_G,
       [1 Cruzamento_Bases_Cálculo_Ganho_Correção].MULTA_OS_G
FROM [2 T_OS_Corrigida_Ganho]
  LEFT JOIN [5 T_OS_Ganhos] ON [2 T_OS_Corrigida_Ganho].NUM_SEQ_OPER_OS_MNB = [5 T_OS_Ganhos].NUM_SEQ_OPER_OS_MNB
  INNER JOIN [1 Cruzamento_Bases_Cálculo_Ganho_Correção] ON [2 T_OS_Corrigida_Ganho].NUM_SEQ_OPER_OS_MNB = [1 Cruzamento_Bases_Cálculo_Ganho_Correção].NUM_SEQ_OPER_OS_MNB
WHERE ((([5 T_OS_Ganhos].NUM_SEQ_OPER_OS_MNB) Is Null));

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

-- ===== 3 Cálculo_Ganho  (SELECT)
SELECT "Pendente" AS [ID],
       Sum([5 T_OS_Ganhos].DEC_G) AS [DEC_G],
       Sum([5 T_OS_Ganhos].FEC_G) AS [FEC_G],
       Sum([5 T_OS_Ganhos].TMA_G) AS [TMA_G],
       Sum([5 T_OS_Ganhos].MULTA_OS_G) AS [COMP_G]
FROM [5 T_OS_Ganhos]
  INNER JOIN [0 Competência_Atual] ON [5 T_OS_Ganhos].DTA_CMPT_MNB = [0 Competência_Atual].DTA_CMPT_MNB
GROUP BY "Pendente";

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

-- ===== 4 Gravar_Base_Original_Correções  (APPEND)
INSERT INTO [4 Base_Original_Correções] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Correção Realizada, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, FEC, COD_LOC_COS, LOCALIDADE, COEC, MULTA_OS, Concat, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, Intv_TR_Zona_Div_UC, OS_Externa, OS_Acessante)
SELECT [1 Base Original Filtros].TIPO_OS,
       [1 Base Original Filtros].DTA_CMPT_MNB,
       [1 Base Original Filtros].COD_CPU_OS_MNB,
       [1 Base Original Filtros].NUM_SEQ_OPER_OS_MNB,
       [1 Base Original Filtros].NUM_SEQ_GER_OS_MNB,
       [1 Base Original Filtros].NOM_USU_PROGM_MNB,
       [1 Base Original Filtros].NOM_USU_CFER_MNB,
       [1 Base Original Filtros].NOM_USU_EXEC_MNB,
       [1 Base Original Filtros].COD_TIPO_ORIG_INTV_MNB,
       [1 Base Original Filtros].DES_ORIG_OGE,
       [1 Base Original Filtros].COD_ORIG_INTV_MNB,
       [1 Base Original Filtros].DES_ORIG_ORI,
       [1 Base Original Filtros].COD_CAUSA_MNB,
       [1 Base Original Filtros].DES_CAUSA_INTER_CAU,
       [1 Base Original Filtros].COD_SUB_CAUSA_MNB,
       [1 Base Original Filtros].DES_SUB_CAUSA_INTER_SCR,
       [1 Base Original Filtros].NUM_CAUSA_ANEEL_MNB,
       [1 Base Original Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [1 Base Original Filtros].DES_INTV_MNB,
       [1 Base Original Filtros].DTA_INIC_MNB,
       [1 Base Original Filtros].DTA_AVI_EQP_MNB,
       [1 Base Original Filtros].DTA_DLCT_EQP_MNB,
       [1 Base Original Filtros].DTA_VERI_EQP_MNB,
       [1 Base Original Filtros].DTA_SERV_EQP_MNB,
       [1 Base Original Filtros].DTA_FIM_MNB,
       [1 Base Original Filtros].COD_ELE_MNB,
       [1 Base Original Filtros].COD_INS_SEC_INS,
       [1 Base Original Filtros].COD_TIPO_CONCL_COS,
       [1 Base Original Filtros].COD_SUB_TIPO_OS_COS,
       [1 Base Original Filtros].TIPO_TR,
       [1 Base Original Filtros].TMA,
       [1 Base Original Filtros].DEC,
       [1 Base Original Filtros].DIF_1ª_2ª_RCM_1h,
       [1 Base Original Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [1 Base Original Filtros].TR_Próprio_OS_Proc,
       [1 Base Original Filtros].Intev_Impro_Causa_Proc,
       [1 Base Original Filtros].Intev_Proc_Causa_Impro,
       [1 Base Original Filtros].[DEC_>_0,001],
       [1 Base Original Filtros].TMD_0,
       [1 Base Original Filtros].[TMA_>_1440],
       [1 Base Original Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [1 Base Original Filtros].Intev_S_OS_Vinc,
       [1 Base Original Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [1 Base Original Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [1 Base Original Filtros].OS_Vinc_UCs_Interr,
       [1 Base Original Filtros].Intev_0_UCs_Inter,
       [1 Base Original Filtros].[Correção Realizada],
       [1 Base Original Filtros].[Comp_>_500],
       [1 Base Original Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [1 Base Original Filtros].OS_Elemen_Particular_Proc,
       [1 Base Original Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [1 Base Original Filtros].OS_Impro_Sem_Elem_Partic,
       [1 Base Original Filtros].FEC,
       [1 Base Original Filtros].COD_LOC_COS,
       [1 Base Original Filtros].LOCALIDADE,
       [1 Base Original Filtros].COEC,
       [1 Base Original Filtros].MULTA_OS,
       [1 Base Original Filtros].Concat,
       [1 Base Original Filtros].C_Classificação,
       [1 Base Original Filtros].[C_OS Vinculada],
       [1 Base Original Filtros].[C_Passo de Manobra],
       [1 Base Original Filtros].C_Horário,
       [1 Base Original Filtros].[C_Elemento Origem],
       [1 Base Original Filtros].USUÁRIO,
       [1 Base Original Filtros].OBSERVAÇÃO,
       [1 Base Original Filtros].STATUS,
       [1 Base Original Filtros].[DATA ANÁLISE],
       [1 Base Original Filtros].[DATA BAIXA],
       [1 Base Original Filtros].Intv_TR_Zona_Div_UC,
       [1 Base Original Filtros].OS_Externa,
       [1 Base Original Filtros].OS_Acessante
FROM [1 Base Original Filtros]
  LEFT JOIN [4 Base_Original_Correções] ON [1 Base Original Filtros].NUM_SEQ_OPER_OS_MNB = [4 Base_Original_Correções].NUM_SEQ_OPER_OS_MNB
WHERE ((([4 Base_Original_Correções].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY [1 Base Original Filtros].TIPO_OS, [1 Base Original Filtros].DTA_CMPT_MNB, [1 Base Original Filtros].COD_CPU_OS_MNB, [1 Base Original Filtros].NUM_SEQ_OPER_OS_MNB, [1 Base Original Filtros].NUM_SEQ_GER_OS_MNB, [1 Base Original Filtros].NOM_USU_PROGM_MNB, [1 Base Original Filtros].NOM_USU_CFER_MNB, [1 Base Original Filtros].NOM_USU_EXEC_MNB, [1 Base Original Filtros].COD_TIPO_ORIG_INTV_MNB, [1 Base Original Filtros].DES_ORIG_OGE, [1 Base Original Filtros].COD_ORIG_INTV_MNB, [1 Base Original Filtros].DES_ORIG_ORI, [1 Base Original Filtros].COD_CAUSA_MNB, [1 Base Original Filtros].DES_CAUSA_INTER_CAU, [1 Base Original Filtros].COD_SUB_CAUSA_MNB, [1 Base Original Filtros].DES_SUB_CAUSA_INTER_SCR, [1 Base Original Filtros].NUM_CAUSA_ANEEL_MNB, [1 Base Original Filtros].NUM_SUB_CAUSA_ANEEL_MNB, [1 Base Original Filtros].DES_INTV_MNB, [1 Base Original Filtros].DTA_INIC_MNB, [1 Base Original Filtros].DTA_AVI_EQP_MNB, [1 Base Original Filtros].DTA_DLCT_EQP_MNB, [1 Base Original Filtros].DTA_VERI_EQP_MNB, [1 Base Original Filtros].DTA_SERV_EQP_MNB, [1 Base Original Filtros].DTA_FIM_MNB, [1 Base Original Filtros].COD_ELE_MNB, [1 Base Original Filtros].COD_INS_SEC_INS, [1 Base Original Filtros].COD_TIPO_CONCL_COS, [1 Base Original Filtros].COD_SUB_TIPO_OS_COS, [1 Base Original Filtros].TIPO_TR, [1 Base Original Filtros].TMA, [1 Base Original Filtros].DEC, [1 Base Original Filtros].DIF_1ª_2ª_RCM_1h, [1 Base Original Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h, [1 Base Original Filtros].TR_Próprio_OS_Proc, [1 Base Original Filtros].Intev_Impro_Causa_Proc, [1 Base Original Filtros].Intev_Proc_Causa_Impro, [1 Base Original Filtros].[DEC_>_0,001], [1 Base Original Filtros].TMD_0, [1 Base Original Filtros].[TMA_>_1440], [1 Base Original Filtros].[Intev_<_3_OS_Vinc_>_50_UCs], [1 Base Original Filtros].Intev_S_OS_Vinc, [1 Base Original Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [1 Base Original Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [1 Base Original Filtros].OS_Vinc_UCs_Interr, [1 Base Original Filtros].Intev_0_UCs_Inter, [1 Base Original Filtros].[Correção Realizada], [1 Base Original Filtros].[Comp_>_500], [1 Base Original Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [1 Base Original Filtros].OS_Elemen_Particular_Proc, [1 Base Original Filtros].[OS_Vinc_Hr_>_Ult_Passo], [1 Base Original Filtros].OS_Impro_Sem_Elem_Partic, [1 Base Original Filtros].FEC, [1 Base Original Filtros].COD_LOC_COS, [1 Base Original Filtros].LOCALIDADE, [1 Base Original Filtros].COEC, [1 Base Original Filtros].MULTA_OS, [1 Base Original Filtros].Concat, [1 Base Original Filtros].C_Classificação, [1 Base Original Filtros].[C_OS Vinculada], [1 Base Original Filtros].[C_Passo de Manobra], [1 Base Original Filtros].C_Horário, [1 Base Original Filtros].[C_Elemento Origem], [1 Base Original Filtros].USUÁRIO, [1 Base Original Filtros].OBSERVAÇÃO, [1 Base Original Filtros].STATUS, [1 Base Original Filtros].[DATA ANÁLISE], [1 Base Original Filtros].[DATA BAIXA], [1 Base Original Filtros].Intv_TR_Zona_Div_UC, [1 Base Original Filtros].OS_Externa, [1 Base Original Filtros].OS_Acessante;

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

-- ===== 5 Ganho_Correções_Final  (APPEND)
INSERT INTO [5 T_OS_Ganhos] (DTA_CMPT_MNB, TIPO_OS, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, MULTA_OS, FEC, COD_LOC_COS, LOCALIDADE, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, DEC_G, FEC_G, TMA_G, MULTA_OS_G)
SELECT [5 T_OS_Ganhos_Temp].DTA_CMPT_MNB,
       [5 T_OS_Ganhos_Temp].TIPO_OS,
       [5 T_OS_Ganhos_Temp].COD_CPU_OS_MNB,
       [5 T_OS_Ganhos_Temp].NUM_SEQ_OPER_OS_MNB,
       [5 T_OS_Ganhos_Temp].NUM_SEQ_GER_OS_MNB,
       [5 T_OS_Ganhos_Temp].NOM_USU_PROGM_MNB,
       [5 T_OS_Ganhos_Temp].NOM_USU_CFER_MNB,
       [5 T_OS_Ganhos_Temp].NOM_USU_EXEC_MNB,
       [5 T_OS_Ganhos_Temp].COD_TIPO_ORIG_INTV_MNB,
       [5 T_OS_Ganhos_Temp].DES_ORIG_OGE,
       [5 T_OS_Ganhos_Temp].COD_ORIG_INTV_MNB,
       [5 T_OS_Ganhos_Temp].DES_ORIG_ORI,
       [5 T_OS_Ganhos_Temp].COD_CAUSA_MNB,
       [5 T_OS_Ganhos_Temp].DES_CAUSA_INTER_CAU,
       [5 T_OS_Ganhos_Temp].COD_SUB_CAUSA_MNB,
       [5 T_OS_Ganhos_Temp].DES_SUB_CAUSA_INTER_SCR,
       [5 T_OS_Ganhos_Temp].NUM_CAUSA_ANEEL_MNB,
       [5 T_OS_Ganhos_Temp].NUM_SUB_CAUSA_ANEEL_MNB,
       [5 T_OS_Ganhos_Temp].DES_INTV_MNB,
       [5 T_OS_Ganhos_Temp].DTA_INIC_MNB,
       [5 T_OS_Ganhos_Temp].DTA_AVI_EQP_MNB,
       [5 T_OS_Ganhos_Temp].DTA_DLCT_EQP_MNB,
       [5 T_OS_Ganhos_Temp].DTA_VERI_EQP_MNB,
       [5 T_OS_Ganhos_Temp].DTA_SERV_EQP_MNB,
       [5 T_OS_Ganhos_Temp].DTA_FIM_MNB,
       [5 T_OS_Ganhos_Temp].COD_ELE_MNB,
       [5 T_OS_Ganhos_Temp].COD_INS_SEC_INS,
       [5 T_OS_Ganhos_Temp].COD_TIPO_CONCL_COS,
       [5 T_OS_Ganhos_Temp].COD_SUB_TIPO_OS_COS,
       [5 T_OS_Ganhos_Temp].TIPO_TR,
       [5 T_OS_Ganhos_Temp].TMA,
       [5 T_OS_Ganhos_Temp].DEC,
       [5 T_OS_Ganhos_Temp].DIF_1ª_2ª_RCM_1h,
       [5 T_OS_Ganhos_Temp].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [5 T_OS_Ganhos_Temp].TR_Próprio_OS_Proc,
       [5 T_OS_Ganhos_Temp].Intev_Impro_Causa_Proc,
       [5 T_OS_Ganhos_Temp].Intev_Proc_Causa_Impro,
       [5 T_OS_Ganhos_Temp].[DEC_>_0,001],
       [5 T_OS_Ganhos_Temp].TMD_0,
       [5 T_OS_Ganhos_Temp].[TMA_>_1440],
       [5 T_OS_Ganhos_Temp].[Intev_<_3_OS_Vinc_>_50_UCs],
       [5 T_OS_Ganhos_Temp].Intev_S_OS_Vinc,
       [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [5 T_OS_Ganhos_Temp].OS_Vinc_UCs_Interr,
       [5 T_OS_Ganhos_Temp].Intev_0_UCs_Inter,
       [5 T_OS_Ganhos_Temp].[Comp_>_500],
       [5 T_OS_Ganhos_Temp].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [5 T_OS_Ganhos_Temp].OS_Elemen_Particular_Proc,
       [5 T_OS_Ganhos_Temp].[OS_Vinc_Hr_>_Ult_Passo],
       [5 T_OS_Ganhos_Temp].OS_Impro_Sem_Elem_Partic,
       [5 T_OS_Ganhos_Temp].MULTA_OS,
       [5 T_OS_Ganhos_Temp].FEC,
       [5 T_OS_Ganhos_Temp].COD_LOC_COS,
       [5 T_OS_Ganhos_Temp].LOCALIDADE,
       [5 T_OS_Ganhos_Temp].COEC,
       [5 T_OS_Ganhos_Temp].[Correção Realizada],
       [5 T_OS_Ganhos_Temp].C_Classificação,
       [5 T_OS_Ganhos_Temp].[C_OS Vinculada],
       [5 T_OS_Ganhos_Temp].[C_Passo de Manobra],
       [5 T_OS_Ganhos_Temp].C_Horário,
       [5 T_OS_Ganhos_Temp].[C_Elemento Origem],
       [5 T_OS_Ganhos_Temp].USUÁRIO,
       [5 T_OS_Ganhos_Temp].OBSERVAÇÃO,
       [5 T_OS_Ganhos_Temp].STATUS,
       [5 T_OS_Ganhos_Temp].[DATA ANÁLISE],
       [5 T_OS_Ganhos_Temp].[DATA BAIXA],
       [5 T_OS_Ganhos_Temp].DEC_G,
       [5 T_OS_Ganhos_Temp].FEC_G,
       [5 T_OS_Ganhos_Temp].TMA_G,
       [5 T_OS_Ganhos_Temp].MULTA_OS_G
FROM [5 T_OS_Ganhos_Temp]
  LEFT JOIN [5 T_OS_Ganhos] ON [5 T_OS_Ganhos_Temp].NUM_SEQ_OPER_OS_MNB = [5 T_OS_Ganhos].NUM_SEQ_OPER_OS_MNB
WHERE ((([5 T_OS_Ganhos].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY [5 T_OS_Ganhos_Temp].DTA_CMPT_MNB, [5 T_OS_Ganhos_Temp].TIPO_OS, [5 T_OS_Ganhos_Temp].COD_CPU_OS_MNB, [5 T_OS_Ganhos_Temp].NUM_SEQ_OPER_OS_MNB, [5 T_OS_Ganhos_Temp].NUM_SEQ_GER_OS_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_PROGM_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_CFER_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_EXEC_MNB, [5 T_OS_Ganhos_Temp].COD_TIPO_ORIG_INTV_MNB, [5 T_OS_Ganhos_Temp].DES_ORIG_OGE, [5 T_OS_Ganhos_Temp].COD_ORIG_INTV_MNB, [5 T_OS_Ganhos_Temp].DES_ORIG_ORI, [5 T_OS_Ganhos_Temp].COD_CAUSA_MNB, [5 T_OS_Ganhos_Temp].DES_CAUSA_INTER_CAU, [5 T_OS_Ganhos_Temp].COD_SUB_CAUSA_MNB, [5 T_OS_Ganhos_Temp].DES_SUB_CAUSA_INTER_SCR, [5 T_OS_Ganhos_Temp].NUM_CAUSA_ANEEL_MNB, [5 T_OS_Ganhos_Temp].NUM_SUB_CAUSA_ANEEL_MNB, [5 T_OS_Ganhos_Temp].DES_INTV_MNB, [5 T_OS_Ganhos_Temp].DTA_INIC_MNB, [5 T_OS_Ganhos_Temp].DTA_AVI_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_DLCT_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_VERI_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_SERV_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_FIM_MNB, [5 T_OS_Ganhos_Temp].COD_ELE_MNB, [5 T_OS_Ganhos_Temp].COD_INS_SEC_INS, [5 T_OS_Ganhos_Temp].COD_TIPO_CONCL_COS, [5 T_OS_Ganhos_Temp].COD_SUB_TIPO_OS_COS, [5 T_OS_Ganhos_Temp].TIPO_TR, [5 T_OS_Ganhos_Temp].TMA, [5 T_OS_Ganhos_Temp].DEC, [5 T_OS_Ganhos_Temp].DIF_1ª_2ª_RCM_1h, [5 T_OS_Ganhos_Temp].DIF_1ª_Man_1ª_OS_Vinc_2h, [5 T_OS_Ganhos_Temp].TR_Próprio_OS_Proc, [5 T_OS_Ganhos_Temp].Intev_Impro_Causa_Proc, [5 T_OS_Ganhos_Temp].Intev_Proc_Causa_Impro, [5 T_OS_Ganhos_Temp].[DEC_>_0,001], [5 T_OS_Ganhos_Temp].TMD_0, [5 T_OS_Ganhos_Temp].[TMA_>_1440], [5 T_OS_Ganhos_Temp].[Intev_<_3_OS_Vinc_>_50_UCs], [5 T_OS_Ganhos_Temp].Intev_S_OS_Vinc, [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [5 T_OS_Ganhos_Temp].OS_Vinc_UCs_Interr, [5 T_OS_Ganhos_Temp].Intev_0_UCs_Inter, [5 T_OS_Ganhos_Temp].[Comp_>_500], [5 T_OS_Ganhos_Temp].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [5 T_OS_Ganhos_Temp].OS_Elemen_Particular_Proc, [5 T_OS_Ganhos_Temp].[OS_Vinc_Hr_>_Ult_Passo], [5 T_OS_Ganhos_Temp].OS_Impro_Sem_Elem_Partic, [5 T_OS_Ganhos_Temp].MULTA_OS, [5 T_OS_Ganhos_Temp].FEC, [5 T_OS_Ganhos_Temp].COD_LOC_COS, [5 T_OS_Ganhos_Temp].LOCALIDADE, [5 T_OS_Ganhos_Temp].COEC, [5 T_OS_Ganhos_Temp].[Correção Realizada], [5 T_OS_Ganhos_Temp].C_Classificação, [5 T_OS_Ganhos_Temp].[C_OS Vinculada], [5 T_OS_Ganhos_Temp].[C_Passo de Manobra], [5 T_OS_Ganhos_Temp].C_Horário, [5 T_OS_Ganhos_Temp].[C_Elemento Origem], [5 T_OS_Ganhos_Temp].USUÁRIO, [5 T_OS_Ganhos_Temp].OBSERVAÇÃO, [5 T_OS_Ganhos_Temp].STATUS, [5 T_OS_Ganhos_Temp].[DATA ANÁLISE], [5 T_OS_Ganhos_Temp].[DATA BAIXA], [5 T_OS_Ganhos_Temp].DEC_G, [5 T_OS_Ganhos_Temp].FEC_G, [5 T_OS_Ganhos_Temp].TMA_G, [5 T_OS_Ganhos_Temp].MULTA_OS_G;

-- ===== 5 Ganho_Correções_Temp  (APPEND)
INSERT INTO [5 T_OS_Ganhos_Temp] (DTA_CMPT_MNB, TIPO_OS, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, MULTA_OS, FEC, COD_LOC_COS, LOCALIDADE, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, DEC_G, FEC_G, TMA_G, MULTA_OS_G)
SELECT [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_CMPT_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].TIPO_OS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_CPU_OS_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NUM_SEQ_OPER_OS_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NUM_SEQ_GER_OS_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NOM_USU_PROGM_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NOM_USU_CFER_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NOM_USU_EXEC_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_TIPO_ORIG_INTV_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DES_ORIG_OGE,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_ORIG_INTV_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DES_ORIG_ORI,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_CAUSA_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DES_CAUSA_INTER_CAU,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_SUB_CAUSA_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DES_SUB_CAUSA_INTER_SCR,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NUM_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DES_INTV_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_INIC_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_AVI_EQP_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_DLCT_EQP_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_VERI_EQP_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_SERV_EQP_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DTA_FIM_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_ELE_MNB,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_INS_SEC_INS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_TIPO_CONCL_COS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_SUB_TIPO_OS_COS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].TIPO_TR,
       [2 T_OS_Corrigida_Ganho_Cruzamento].TMA,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DEC,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DIF_1ª_2ª_RCM_1h,
       [2 T_OS_Corrigida_Ganho_Cruzamento].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 T_OS_Corrigida_Ganho_Cruzamento].TR_Próprio_OS_Proc,
       [2 T_OS_Corrigida_Ganho_Cruzamento].Intev_Impro_Causa_Proc,
       [2 T_OS_Corrigida_Ganho_Cruzamento].Intev_Proc_Causa_Impro,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[DEC_>_0,001],
       [2 T_OS_Corrigida_Ganho_Cruzamento].TMD_0,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[TMA_>_1440],
       [2 T_OS_Corrigida_Ganho_Cruzamento].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 T_OS_Corrigida_Ganho_Cruzamento].Intev_S_OS_Vinc,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 T_OS_Corrigida_Ganho_Cruzamento].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 T_OS_Corrigida_Ganho_Cruzamento].OS_Vinc_UCs_Interr,
       [2 T_OS_Corrigida_Ganho_Cruzamento].Intev_0_UCs_Inter,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[Comp_>_500],
       [2 T_OS_Corrigida_Ganho_Cruzamento].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 T_OS_Corrigida_Ganho_Cruzamento].OS_Elemen_Particular_Proc,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[OS_Vinc_Hr_>_Ult_Passo],
       [2 T_OS_Corrigida_Ganho_Cruzamento].OS_Impro_Sem_Elem_Partic,
       [2 T_OS_Corrigida_Ganho_Cruzamento].MULTA_OS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].FEC,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COD_LOC_COS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].LOCALIDADE,
       [2 T_OS_Corrigida_Ganho_Cruzamento].COEC,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[Correção Realizada],
       [2 T_OS_Corrigida_Ganho_Cruzamento].C_Classificação,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[C_OS Vinculada],
       [2 T_OS_Corrigida_Ganho_Cruzamento].[C_Passo de Manobra],
       [2 T_OS_Corrigida_Ganho_Cruzamento].C_Horário,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[C_Elemento Origem],
       [2 T_OS_Corrigida_Ganho_Cruzamento].USUÁRIO,
       [2 T_OS_Corrigida_Ganho_Cruzamento].OBSERVAÇÃO,
       [2 T_OS_Corrigida_Ganho_Cruzamento].STATUS,
       [2 T_OS_Corrigida_Ganho_Cruzamento].[DATA ANÁLISE],
       [2 T_OS_Corrigida_Ganho_Cruzamento].[DATA BAIXA],
       [2 T_OS_Corrigida_Ganho_Cruzamento].DEC_G,
       [2 T_OS_Corrigida_Ganho_Cruzamento].FEC_G,
       [2 T_OS_Corrigida_Ganho_Cruzamento].TMA_G,
       [2 T_OS_Corrigida_Ganho_Cruzamento].MULTA_OS_G
FROM [2 T_OS_Corrigida_Ganho_Cruzamento];

-- ===== 5 L_Ganho_Correções_Temp  (DELETE)
DELETE [5 T_OS_Ganhos_Temp].DTA_CMPT_MNB, [5 T_OS_Ganhos_Temp].TIPO_OS, [5 T_OS_Ganhos_Temp].COD_CPU_OS_MNB, [5 T_OS_Ganhos_Temp].NUM_SEQ_OPER_OS_MNB, [5 T_OS_Ganhos_Temp].NUM_SEQ_GER_OS_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_PROGM_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_CFER_MNB, [5 T_OS_Ganhos_Temp].NOM_USU_EXEC_MNB, [5 T_OS_Ganhos_Temp].COD_TIPO_ORIG_INTV_MNB, [5 T_OS_Ganhos_Temp].DES_ORIG_OGE, [5 T_OS_Ganhos_Temp].COD_ORIG_INTV_MNB, [5 T_OS_Ganhos_Temp].DES_ORIG_ORI, [5 T_OS_Ganhos_Temp].COD_CAUSA_MNB, [5 T_OS_Ganhos_Temp].DES_CAUSA_INTER_CAU, [5 T_OS_Ganhos_Temp].COD_SUB_CAUSA_MNB, [5 T_OS_Ganhos_Temp].DES_SUB_CAUSA_INTER_SCR, [5 T_OS_Ganhos_Temp].NUM_CAUSA_ANEEL_MNB, [5 T_OS_Ganhos_Temp].NUM_SUB_CAUSA_ANEEL_MNB, [5 T_OS_Ganhos_Temp].DES_INTV_MNB, [5 T_OS_Ganhos_Temp].DTA_INIC_MNB, [5 T_OS_Ganhos_Temp].DTA_AVI_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_DLCT_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_VERI_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_SERV_EQP_MNB, [5 T_OS_Ganhos_Temp].DTA_FIM_MNB, [5 T_OS_Ganhos_Temp].COD_ELE_MNB, [5 T_OS_Ganhos_Temp].COD_INS_SEC_INS, [5 T_OS_Ganhos_Temp].COD_TIPO_CONCL_COS, [5 T_OS_Ganhos_Temp].COD_SUB_TIPO_OS_COS, [5 T_OS_Ganhos_Temp].TIPO_TR, [5 T_OS_Ganhos_Temp].TMA, [5 T_OS_Ganhos_Temp].DEC, [5 T_OS_Ganhos_Temp].DIF_1ª_2ª_RCM_1h, [5 T_OS_Ganhos_Temp].DIF_1ª_Man_1ª_OS_Vinc_2h, [5 T_OS_Ganhos_Temp].TR_Próprio_OS_Proc, [5 T_OS_Ganhos_Temp].Intev_Impro_Causa_Proc, [5 T_OS_Ganhos_Temp].Intev_Proc_Causa_Impro, [5 T_OS_Ganhos_Temp].[DEC_>_0,001], [5 T_OS_Ganhos_Temp].TMD_0, [5 T_OS_Ganhos_Temp].[TMA_>_1440], [5 T_OS_Ganhos_Temp].[Intev_<_3_OS_Vinc_>_50_UCs], [5 T_OS_Ganhos_Temp].Intev_S_OS_Vinc, [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [5 T_OS_Ganhos_Temp].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [5 T_OS_Ganhos_Temp].OS_Vinc_UCs_Interr, [5 T_OS_Ganhos_Temp].Intev_0_UCs_Inter, [5 T_OS_Ganhos_Temp].[Comp_>_500], [5 T_OS_Ganhos_Temp].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [5 T_OS_Ganhos_Temp].OS_Elemen_Particular_Proc, [5 T_OS_Ganhos_Temp].[OS_Vinc_Hr_>_Ult_Passo], [5 T_OS_Ganhos_Temp].OS_Impro_Sem_Elem_Partic, [5 T_OS_Ganhos_Temp].Intv_TR_Zona_Div_UC, [5 T_OS_Ganhos_Temp].OS_Externa, [5 T_OS_Ganhos_Temp].OS_Acessante, [5 T_OS_Ganhos_Temp].MULTA_OS, [5 T_OS_Ganhos_Temp].FEC, [5 T_OS_Ganhos_Temp].COD_LOC_COS, [5 T_OS_Ganhos_Temp].LOCALIDADE, [5 T_OS_Ganhos_Temp].COEC, [5 T_OS_Ganhos_Temp].[Correção Realizada], [5 T_OS_Ganhos_Temp].C_Classificação, [5 T_OS_Ganhos_Temp].[C_OS Vinculada], [5 T_OS_Ganhos_Temp].[C_Passo de Manobra], [5 T_OS_Ganhos_Temp].C_Horário, [5 T_OS_Ganhos_Temp].[C_Elemento Origem], [5 T_OS_Ganhos_Temp].USUÁRIO, [5 T_OS_Ganhos_Temp].OBSERVAÇÃO, [5 T_OS_Ganhos_Temp].STATUS, [5 T_OS_Ganhos_Temp].[DATA ANÁLISE], [5 T_OS_Ganhos_Temp].[DATA BAIXA], [5 T_OS_Ganhos_Temp].DEC_G, [5 T_OS_Ganhos_Temp].FEC_G, [5 T_OS_Ganhos_Temp].TMA_G, [5 T_OS_Ganhos_Temp].MULTA_OS_G
FROM [5 T_OS_Ganhos_Temp];

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

-- ===== 7_0 TMA OS Individual Converter em Número  (SELECT)
SELECT [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR,
       [1 Tabela Ocorrência_Individual]![TMA]*1 AS [TMA]
FROM [1 Tabela Ocorrência_Individual];

-- ===== 7_1 TMA OS individual > 2160  (SELECT)
SELECT [7_0 TMA OS Individual Converter em Número].NUM_SEQ_OPER_CNR,
       [7_0 TMA OS Individual Converter em Número].TMA,
       "Verificar" AS [Status]
FROM [7_0 TMA OS Individual Converter em Número]
WHERE ((([7_0 TMA OS Individual Converter em Número].TMA)>1440));

-- ===== 8_0 Base Mano Filt Aber Inter  (SELECT)
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

-- ===== 8_1 Dt Menor Passo  (SELECT)
SELECT [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       Min([8_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB) AS [DTA_PASSO_PNB]
FROM [8_0 Base Mano Filt Aber Inter]
GROUP BY [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB;

-- ===== 8_2 Cruz Dt Menor Passo x Num Passo  (SELECT)
SELECT [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB,
       [8_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB,
       [8_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
FROM [8_1 Dt Menor Passo]
  INNER JOIN [8_0 Base Mano Filt Aber Inter] ON [8_1 Dt Menor Passo].NUM_SEQ_OPER_OS_PNB = [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB AND [8_1 Dt Menor Passo].DTA_PASSO_PNB = [8_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB
GROUP BY [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [8_0 Base Mano Filt Aber Inter].DTA_PASSO_PNB, [8_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB
ORDER BY [8_0 Base Mano Filt Aber Inter].NUM_SEQ_OPER_OS_PNB, [8_0 Base Mano Filt Aber Inter].NUM_SEQ_PNB;

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

-- ===== 98 F_Comp_>_500  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Comp_>_500])="Verificar"));

-- ===== 98 F_Comp_>_500 - Count  (SELECT)
SELECT [98 F_Comp_>_500].TIPO,
       Count([98 F_Comp_>_500].[Comp_>_500]) AS [Comp_>_500]
FROM [98 F_Comp_>_500]
GROUP BY [98 F_Comp_>_500].TIPO;

-- ===== 98 F_DEC_>_0,001  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[DEC_>_0,001])="Verificar"));

-- ===== 98 F_DEC_>_0,001 - Count  (SELECT)
SELECT [98 F_DEC_>_0,001].TIPO,
       Count([98 F_DEC_>_0,001].[DEC_>_0,001]) AS [DEC_>_0,001]
FROM [98 F_DEC_>_0,001]
GROUP BY [98 F_DEC_>_0,001].TIPO;

-- ===== 98 F_DIF_1ª_2ª_RCM_1h  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h AS [DIF_1ª_2ª_RCM_1h]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h)="Verificar"));

-- ===== 98 F_DIF_1ª_2ª_RCM_1h - Count  (SELECT)
SELECT [98 F_DIF_1ª_2ª_RCM_1h].TIPO,
       Count([98 F_DIF_1ª_2ª_RCM_1h].DIF_1ª_2ª_RCM_1h) AS [DIF_1ª_2ª_RCM_1h]
FROM [98 F_DIF_1ª_2ª_RCM_1h]
GROUP BY [98 F_DIF_1ª_2ª_RCM_1h].TIPO;

-- ===== 98 F_DIF_1ª_Man_1ª_OS_Vinc_2h  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h) In ("Verificar Abrir","Verificar Interr")));

-- ===== 98 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count  (SELECT)
SELECT [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h].TIPO,
       Count([98 F_DIF_1ª_Man_1ª_OS_Vinc_2h].DIF_1ª_Man_1ª_OS_Vinc_2h) AS [DIF_1ª_Man_1ª_OS_Vinc_2h]
FROM [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h]
GROUP BY [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h].TIPO;

-- ===== 98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio)<>"" & "" & ""));

-- ===== 98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count  (SELECT)
SELECT "Pendente" AS [TIPO],
       Count([98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio) AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]
FROM [98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]
GROUP BY "Pendente";

-- ===== 98 F_Intev_0_UCs_Inter  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter)="Verificar"));

-- ===== 98 F_Intev_0_UCs_Inter - Count  (SELECT)
SELECT [98 F_Intev_0_UCs_Inter].TIPO,
       Count([98 F_Intev_0_UCs_Inter].Intev_0_UCs_Inter) AS [Intev_0_UCs_Inter]
FROM [98 F_Intev_0_UCs_Inter]
GROUP BY [98 F_Intev_0_UCs_Inter].TIPO;

-- ===== 98 F_Intev_<_3_OS_Vinc_>_50_UCs  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs])="Verificar"));

-- ===== 98 F_Intev_<_3_OS_Vinc_>_50_UCs - Count  (SELECT)
SELECT [98 F_Intev_<_3_OS_Vinc_>_50_UCs].TIPO,
       Count([98 F_Intev_<_3_OS_Vinc_>_50_UCs].[Intev_<_3_OS_Vinc_>_50_UCs]) AS [Intev_<_3_OS_Vinc_>_50_UCs]
FROM [98 F_Intev_<_3_OS_Vinc_>_50_UCs]
GROUP BY [98 F_Intev_<_3_OS_Vinc_>_50_UCs].TIPO;

-- ===== 98 F_Intev_Impro_Causa_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc)="Verificar"));

-- ===== 98 F_Intev_Impro_Causa_Proc - Count  (SELECT)
SELECT [98 F_Intev_Impro_Causa_Proc].TIPO,
       Count([98 F_Intev_Impro_Causa_Proc].Intev_Impro_Causa_Proc) AS [Intev_Impro_Causa_Proc]
FROM [98 F_Intev_Impro_Causa_Proc]
GROUP BY [98 F_Intev_Impro_Causa_Proc].TIPO;

-- ===== 98 F_Intev_Proc_Causa_Impro  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro)="Verificar"));

-- ===== 98 F_Intev_Proc_Causa_Impro - Count  (SELECT)
SELECT [98 F_Intev_Proc_Causa_Impro].TIPO,
       Count([98 F_Intev_Proc_Causa_Impro].Intev_Proc_Causa_Impro) AS [Intev_Proc_Causa_Impro]
FROM [98 F_Intev_Proc_Causa_Impro]
GROUP BY [98 F_Intev_Proc_Causa_Impro].TIPO;

-- ===== 98 F_Intev_S_OS_Vinc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc)="Verificar"));

-- ===== 98 F_Intev_S_OS_Vinc - Count  (SELECT)
SELECT [98 F_Intev_S_OS_Vinc].TIPO,
       Count([98 F_Intev_S_OS_Vinc].Intev_S_OS_Vinc) AS [Intev_S_OS_Vinc]
FROM [98 F_Intev_S_OS_Vinc]
GROUP BY [98 F_Intev_S_OS_Vinc].TIPO;

-- ===== 98 F_Intv_TR_Zona_Div_UC  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC)="Verificar"));

-- ===== 98 F_Intv_TR_Zona_Div_UC - Count  (SELECT)
SELECT [98 F_Intv_TR_Zona_Div_UC].TIPO,
       Count([98 F_Intv_TR_Zona_Div_UC].Intv_TR_Zona_Div_UC) AS [Intv_TR_Zona_Div_UC]
FROM [98 F_Intv_TR_Zona_Div_UC]
GROUP BY [98 F_Intv_TR_Zona_Div_UC].TIPO;

-- ===== 98 F_OS_Acessante  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Acessante)="Verificar"));

-- ===== 98 F_OS_Acessante - Count  (SELECT)
SELECT [98 F_OS_Acessante].TIPO,
       Count([98 F_OS_Acessante].OS_Acessante) AS [OS_Acessante]
FROM [98 F_OS_Acessante]
GROUP BY [98 F_OS_Acessante].TIPO;

-- ===== 98 F_OS_Elemen_Particular_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc)="Verificar"));

-- ===== 98 F_OS_Elemen_Particular_Proc - Count  (SELECT)
SELECT "Pendente" AS [TIPO],
       Count([98 F_OS_Elemen_Particular_Proc].OS_Elemen_Particular_Proc) AS [OS_Elemen_Particular_Proc]
FROM [98 F_OS_Elemen_Particular_Proc]
GROUP BY "Pendente";

-- ===== 98 F_OS_Externa  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].OS_Externa
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Externa)="Verificar"));

-- ===== 98 F_OS_Externa - Count  (SELECT)
SELECT [98 F_OS_Externa].TIPO,
       Count([98 F_OS_Externa].OS_Externa) AS [OS_Externa]
FROM [98 F_OS_Externa]
GROUP BY [98 F_OS_Externa].TIPO;

-- ===== 98 F_OS_Impro_Sem_Elem_Partic  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic)="Verificar"));

-- ===== 98 F_OS_Impro_Sem_Elem_Partic - Count  (SELECT)
SELECT "Pendente" AS [TIPO],
       Count([98 F_OS_Impro_Sem_Elem_Partic].OS_Impro_Sem_Elem_Partic) AS [OS_Impro_Sem_Elem_Partic]
FROM [98 F_OS_Impro_Sem_Elem_Partic]
GROUP BY "Pendente";

-- ===== 98 F_OS_Vinc_Hr_>_Ult_Passo  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo])="Verificar"));

-- ===== 98 F_OS_Vinc_Hr_>_Ult_Passo - Count  (SELECT)
SELECT "Pendente" AS [TIPO],
       Count([98 F_OS_Vinc_Hr_>_Ult_Passo].[OS_Vinc_Hr_>_Ult_Passo]) AS [OS_Vinc_Hr_>_Ult_Passo]
FROM [98 F_OS_Vinc_Hr_>_Ult_Passo]
GROUP BY "Pendente";

-- ===== 98 F_OS_Vinc_UCs_Interr  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr)="Verificar"));

-- ===== 98 F_OS_Vinc_UCs_Interr - Count  (SELECT)
SELECT [98 F_OS_Vinc_UCs_Interr].TIPO,
       Count([98 F_OS_Vinc_UCs_Interr].OS_Vinc_UCs_Interr) AS [OS_Vinc_UCs_Interr]
FROM [98 F_OS_Vinc_UCs_Interr]
GROUP BY [98 F_OS_Vinc_UCs_Interr].TIPO;

-- ===== 98 F_TMA_>_1440  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[TMA_>_1440])="Verificar"));

-- ===== 98 F_TMA_>_1440 - Count  (SELECT)
SELECT [98 F_TMA_>_1440].TIPO,
       Count([98 F_TMA_>_1440].[TMA_>_1440]) AS [TMA_>_1440]
FROM [98 F_TMA_>_1440]
GROUP BY [98 F_TMA_>_1440].TIPO;

-- ===== 98 F_TMD_0  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].TMD_0
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].TMD_0)="Verificar"));

-- ===== 98 F_TMD_0 - Count  (SELECT)
SELECT [98 F_TMD_0].TIPO,
       Count([98 F_TMD_0].TMD_0) AS [TMD_0]
FROM [98 F_TMD_0]
GROUP BY [98 F_TMD_0].TIPO;

-- ===== 98 F_TR_Próprio_OS_Proc  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc)="Verificar"));

-- ===== 98 F_TR_Próprio_OS_Proc - Count  (SELECT)
SELECT [98 F_TR_Próprio_OS_Proc].TIPO,
       Count([98 F_TR_Próprio_OS_Proc].TR_Próprio_OS_Proc) AS [TR_Próprio_OS_Proc]
FROM [98 F_TR_Próprio_OS_Proc]
GROUP BY [98 F_TR_Próprio_OS_Proc].TIPO;

-- ===== 98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min])="Verificar"));

-- ===== 98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count  (SELECT)
SELECT [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].TIPO,
       Count([98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]) AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]
FROM [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]
GROUP BY [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min].TIPO;

-- ===== 98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr  (SELECT)
SELECT "Pendente" AS [TIPO],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr])="Verificar"));

-- ===== 98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count  (SELECT)
SELECT [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].TIPO,
       Count([98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]) AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]
FROM [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]
GROUP BY [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr].TIPO;

-- ===== 99 A_Pendente  (SELECT)
SELECT "Pendente" AS [AGRUP],
       Count([99 Base Correções Pendentes].NUM_SEQ_OPER_OS_MNB) AS [Pendente]
FROM [99 Base Correções Pendentes]
GROUP BY "Pendente";

-- ===== 99 A_Pendente_Ag_Retorno  (SELECT)
SELECT "Pendente" AS [AGRUP],
       Count([99 Base Intervenção Unificada - Filtro Ag Retorno].NUM_SEQ_OPER_OS_MNB) AS [Pendente_A]
FROM [99 Base Intervenção Unificada - Filtro Ag Retorno]
GROUP BY "Pendente";

-- ===== 99 A_Unificação_Checklist  (SELECT)
SELECT T_Lixo.ID,
       [98 F_Comp_>_500 - Count].[Comp_>_500],
       [98 F_DEC_>_0,001 - Count].[DEC_>_0,001],
       [98 F_DIF_1ª_2ª_RCM_1h - Count].DIF_1ª_2ª_RCM_1h,
       [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [98 F_Intev_<_3_OS_Vinc_>_50_UCs - Count].[Intev_<_3_OS_Vinc_>_50_UCs],
       [98 F_Intev_0_UCs_Inter - Count].Intev_0_UCs_Inter,
       [98 F_Intev_Impro_Causa_Proc - Count].Intev_Impro_Causa_Proc,
       [98 F_Intev_Proc_Causa_Impro - Count].Intev_Proc_Causa_Impro,
       [98 F_Intev_S_OS_Vinc - Count].Intev_S_OS_Vinc,
       [98 F_OS_Vinc_UCs_Interr - Count].OS_Vinc_UCs_Interr,
       [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [98 F_TMA_>_1440 - Count].[TMA_>_1440],
       [98 F_TMD_0 - Count].TMD_0,
       [98 F_TR_Próprio_OS_Proc - Count].TR_Próprio_OS_Proc,
       [98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio
FROM T_Lixo
  LEFT JOIN [98 F_Comp_>_500 - Count] ON T_Lixo.ID = [98 F_Comp_>_500 - Count].TIPO
  LEFT JOIN [98 F_DEC_>_0,001 - Count] ON T_Lixo.ID = [98 F_DEC_>_0,001 - Count].TIPO
  LEFT JOIN [98 F_DIF_1ª_2ª_RCM_1h - Count] ON T_Lixo.ID = [98 F_DIF_1ª_2ª_RCM_1h - Count].TIPO
  LEFT JOIN [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count] ON T_Lixo.ID = [98 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count].TIPO
  LEFT JOIN [98 F_Intev_<_3_OS_Vinc_>_50_UCs - Count] ON T_Lixo.ID = [98 F_Intev_<_3_OS_Vinc_>_50_UCs - Count].TIPO
  LEFT JOIN [98 F_Intev_0_UCs_Inter - Count] ON T_Lixo.ID = [98 F_Intev_0_UCs_Inter - Count].TIPO
  LEFT JOIN [98 F_Intev_Impro_Causa_Proc - Count] ON T_Lixo.ID = [98 F_Intev_Impro_Causa_Proc - Count].TIPO
  LEFT JOIN [98 F_Intev_Proc_Causa_Impro - Count] ON T_Lixo.ID = [98 F_Intev_Proc_Causa_Impro - Count].TIPO
  LEFT JOIN [98 F_Intev_S_OS_Vinc - Count] ON T_Lixo.ID = [98 F_Intev_S_OS_Vinc - Count].TIPO
  LEFT JOIN [98 F_OS_Vinc_UCs_Interr - Count] ON T_Lixo.ID = [98 F_OS_Vinc_UCs_Interr - Count].TIPO
  LEFT JOIN [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count] ON T_Lixo.ID = [98 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count].TIPO
  LEFT JOIN [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count] ON T_Lixo.ID = [98 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count].TIPO
  LEFT JOIN [98 F_TMA_>_1440 - Count] ON T_Lixo.ID = [98 F_TMA_>_1440 - Count].TIPO
  LEFT JOIN [98 F_TMD_0 - Count] ON T_Lixo.ID = [98 F_TMD_0 - Count].TIPO
  LEFT JOIN [98 F_TR_Próprio_OS_Proc - Count] ON T_Lixo.ID = [98 F_TR_Próprio_OS_Proc - Count].TIPO
  LEFT JOIN [98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count] ON T_Lixo.ID = [98 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count].TIPO;

-- ===== 99 A_Unificação_Checklist - Final  (SELECT)
SELECT [99 A_Unificação_Checklist].ID,
       [99 A_Unificação_Checklist_Original].[Comp_>_500_O],
       [99 A_Unificação_Checklist].[Comp_>_500],
       [99 A_Unificação_Checklist_Original].[DEC_>_0,001_O],
       [99 A_Unificação_Checklist].[DEC_>_0,001],
       [99 A_Unificação_Checklist_Original].DIF_1ª_2ª_RCM_1h_O,
       [99 A_Unificação_Checklist].DIF_1ª_2ª_RCM_1h,
       [99 A_Unificação_Checklist_Original].DIF_1ª_Man_1ª_OS_Vinc_2h_O,
       [99 A_Unificação_Checklist].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 A_Unificação_Checklist_Original].[Intev_<_3_OS_Vinc_>_50_UCs_O],
       [99 A_Unificação_Checklist].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 A_Unificação_Checklist_Original].Intev_0_UCs_Inter_O,
       [99 A_Unificação_Checklist].Intev_0_UCs_Inter,
       [99 A_Unificação_Checklist_Original].Intev_Impro_Causa_Proc_O,
       [99 A_Unificação_Checklist].Intev_Impro_Causa_Proc,
       [99 A_Unificação_Checklist_Original].Intev_Proc_Causa_Impro_O,
       [99 A_Unificação_Checklist].Intev_Proc_Causa_Impro,
       [99 A_Unificação_Checklist_Original].Intev_S_OS_Vinc_O,
       [99 A_Unificação_Checklist].Intev_S_OS_Vinc,
       [99 A_Unificação_Checklist_Original].OS_Vinc_UCs_Interr_O,
       [99 A_Unificação_Checklist].OS_Vinc_UCs_Interr,
       [99 A_Unificação_Checklist_Original].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min_O],
       [99 A_Unificação_Checklist].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 A_Unificação_Checklist_Original].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr_O],
       [99 A_Unificação_Checklist].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 A_Unificação_Checklist_Original].[TMA_>_1440_O],
       [99 A_Unificação_Checklist].[TMA_>_1440],
       [99 A_Unificação_Checklist_Original].TMD_0_O,
       [99 A_Unificação_Checklist].TMD_0,
       [99 A_Unificação_Checklist_Original].TR_Próprio_OS_Proc_O,
       [99 A_Unificação_Checklist].TR_Próprio_OS_Proc,
       [99 A_Unificação_Checklist_Original].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio_O,
       [99 A_Unificação_Checklist].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [1 F_OS_Elemen_Particular_Proc - Count].OS_Elemen_Particular_Proc_O,
       [98 F_OS_Elemen_Particular_Proc - Count].OS_Elemen_Particular_Proc,
       [1 F_OS_Impro_Sem_Elem_Partic - Count].OS_Impro_Sem_Elem_Partic_O,
       [98 F_OS_Impro_Sem_Elem_Partic - Count].OS_Impro_Sem_Elem_Partic,
       [1 F_OS_Vinc_Hr_>_Ult_Passo - Count].[OS_Vinc_Hr_>_Ult_Passo_O],
       [98 F_OS_Vinc_Hr_>_Ult_Passo - Count].[OS_Vinc_Hr_>_Ult_Passo],
       [1 F_Intv_TR_Zona_Div_UC - Count].Intv_TR_Zona_Div_UC_O,
       [98 F_Intv_TR_Zona_Div_UC - Count].Intv_TR_Zona_Div_UC,
       [1 F_OS_Acessante - Count].OS_Acessante_O,
       [98 F_OS_Acessante - Count].OS_Acessante,
       [1 F_OS_Externa - Count].OS_Externa_O,
       [98 F_OS_Externa - Count].OS_Externa
FROM [99 A_Unificação_Checklist]
  LEFT JOIN [98 F_OS_Elemen_Particular_Proc - Count] ON [99 A_Unificação_Checklist].ID = [98 F_OS_Elemen_Particular_Proc - Count].TIPO
  LEFT JOIN [98 F_OS_Impro_Sem_Elem_Partic - Count] ON [99 A_Unificação_Checklist].ID = [98 F_OS_Impro_Sem_Elem_Partic - Count].TIPO
  LEFT JOIN [98 F_OS_Vinc_Hr_>_Ult_Passo - Count] ON [99 A_Unificação_Checklist].ID = [98 F_OS_Vinc_Hr_>_Ult_Passo - Count].TIPO
  INNER JOIN [99 A_Unificação_Checklist_Original] ON [99 A_Unificação_Checklist].ID = [99 A_Unificação_Checklist_Original].ID
  LEFT JOIN [1 F_OS_Vinc_Hr_>_Ult_Passo - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_OS_Vinc_Hr_>_Ult_Passo - Count].TIPO
  LEFT JOIN [1 F_OS_Elemen_Particular_Proc - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_OS_Elemen_Particular_Proc - Count].TIPO
  LEFT JOIN [1 F_OS_Impro_Sem_Elem_Partic - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_OS_Impro_Sem_Elem_Partic - Count].TIPO
  LEFT JOIN [98 F_Intv_TR_Zona_Div_UC - Count] ON [99 A_Unificação_Checklist].ID = [98 F_Intv_TR_Zona_Div_UC - Count].TIPO
  LEFT JOIN [98 F_OS_Acessante - Count] ON [99 A_Unificação_Checklist].ID = [98 F_OS_Acessante - Count].TIPO
  LEFT JOIN [98 F_OS_Externa - Count] ON [99 A_Unificação_Checklist].ID = [98 F_OS_Externa - Count].TIPO
  LEFT JOIN [1 F_Intv_TR_Zona_Div_UC - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_Intv_TR_Zona_Div_UC - Count].TIPO
  LEFT JOIN [1 F_OS_Externa - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_OS_Externa - Count].TIPO
  LEFT JOIN [1 F_OS_Acessante - Count] ON [99 A_Unificação_Checklist_Original].ID = [1 F_OS_Acessante - Count].TIPO;

-- ===== 99 A_Unificação_Checklist_Original  (SELECT)
SELECT T_Lixo.ID,
       [1 F_Comp_>_500 - Count].[Comp_>_500_O],
       [1 F_DEC_>_0,001 - Count].[DEC_>_0,001_O],
       [1 F_DIF_1ª_2ª_RCM_1h - Count].DIF_1ª_2ª_RCM_1h_O,
       [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count].DIF_1ª_Man_1ª_OS_Vinc_2h_O,
       [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio_O,
       [1 F_Intev_<_3_OS_Vinc_>_50_UCs - Count].[Intev_<_3_OS_Vinc_>_50_UCs_O],
       [1 F_Intev_0_UCs_Inter - Count].Intev_0_UCs_Inter_O,
       [1 F_Intev_Impro_Causa_Proc - Count].Intev_Impro_Causa_Proc_O,
       [1 F_Intev_Proc_Causa_Impro - Count].Intev_Proc_Causa_Impro_O,
       [1 F_Intev_S_OS_Vinc - Count].Intev_S_OS_Vinc_O,
       [1 F_OS_Vinc_UCs_Interr - Count].OS_Vinc_UCs_Interr_O,
       [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min_O],
       [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr_O],
       [1 F_TMA_>_1440 - Count].[TMA_>_1440_O],
       [1 F_TMD_0 - Count].TMD_0_O,
       [1 F_TR_Próprio_OS_Proc - Count].TR_Próprio_OS_Proc_O
FROM T_Lixo
  LEFT JOIN [1 F_Comp_>_500 - Count] ON T_Lixo.ID = [1 F_Comp_>_500 - Count].TIPO
  LEFT JOIN [1 F_DEC_>_0,001 - Count] ON T_Lixo.ID = [1 F_DEC_>_0,001 - Count].TIPO
  LEFT JOIN [1 F_DIF_1ª_2ª_RCM_1h - Count] ON T_Lixo.ID = [1 F_DIF_1ª_2ª_RCM_1h - Count].TIPO
  LEFT JOIN [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count] ON T_Lixo.ID = [1 F_DIF_1ª_Man_1ª_OS_Vinc_2h - Count].TIPO
  LEFT JOIN [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count] ON T_Lixo.ID = [1 F_Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio - Count].TIPO
  LEFT JOIN [1 F_Intev_<_3_OS_Vinc_>_50_UCs - Count] ON T_Lixo.ID = [1 F_Intev_<_3_OS_Vinc_>_50_UCs - Count].TIPO
  LEFT JOIN [1 F_Intev_0_UCs_Inter - Count] ON T_Lixo.ID = [1 F_Intev_0_UCs_Inter - Count].TIPO
  LEFT JOIN [1 F_Intev_Impro_Causa_Proc - Count] ON T_Lixo.ID = [1 F_Intev_Impro_Causa_Proc - Count].TIPO
  LEFT JOIN [1 F_Intev_Proc_Causa_Impro - Count] ON T_Lixo.ID = [1 F_Intev_Proc_Causa_Impro - Count].TIPO
  LEFT JOIN [1 F_Intev_S_OS_Vinc - Count] ON T_Lixo.ID = [1 F_Intev_S_OS_Vinc - Count].TIPO
  LEFT JOIN [1 F_OS_Vinc_UCs_Interr - Count] ON T_Lixo.ID = [1 F_OS_Vinc_UCs_Interr - Count].TIPO
  LEFT JOIN [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count] ON T_Lixo.ID = [1 F_Tempo_Hr_Inic_Hr_1º_Passo_=_1_min - Count].TIPO
  LEFT JOIN [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count] ON T_Lixo.ID = [1 F_Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr - Count].TIPO
  LEFT JOIN [1 F_TMA_>_1440 - Count] ON T_Lixo.ID = [1 F_TMA_>_1440 - Count].TIPO
  LEFT JOIN [1 F_TMD_0 - Count] ON T_Lixo.ID = [1 F_TMD_0 - Count].TIPO
  LEFT JOIN [1 F_TR_Próprio_OS_Proc - Count] ON T_Lixo.ID = [1 F_TR_Próprio_OS_Proc - Count].TIPO;

-- ===== 99 A_Union_Final  (SELECT)
SELECT T_Lixo.ID,
       [99 OS_Analisada_Fora_Crítica].OS_Analisada_Fora_Crítica,
       [99 OS_Corrigida_Fora_Crítica].OS_Fora_Crítica,
       [99 A_Union_Status]![Correção]+[99 OS_Corrigida_Fora_Crítica]![OS_Fora_Crítica] AS [Correção],
       [99 A_Union_Status].Pendente_A,
       [99 A_Union_Status]![Pendente] AS [Pendente],
       [99 A_Union_Status]![Análise]+[99 OS_Analisada_Fora_Crítica]![OS_Analisada_Fora_Crítica] AS [Análise],
       IIf([99 A_Union_Status]![Pendente_A] Is Null,[Pendente],[99 A_Union_Status]![Pendente]+[99 A_Union_Status]![Pendente_A]) AS [Pendente_Calc],
       [99 A_Union_Status]![Pendente]+[99 A_Union_Status]![Análise]+[99 OS_Analisada_Fora_Crítica]![OS_Analisada_Fora_Crítica] AS [Total],
       [99 A_Unificação_Checklist - Final].[Comp_>_500_O],
       [99 A_Unificação_Checklist - Final].[Comp_>_500],
       [99 A_Unificação_Checklist - Final].[DEC_>_0,001_O],
       [99 A_Unificação_Checklist - Final].[DEC_>_0,001],
       [99 A_Unificação_Checklist - Final].DIF_1ª_2ª_RCM_1h_O,
       [99 A_Unificação_Checklist - Final].DIF_1ª_2ª_RCM_1h,
       [99 A_Unificação_Checklist - Final].DIF_1ª_Man_1ª_OS_Vinc_2h_O,
       [99 A_Unificação_Checklist - Final].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 A_Unificação_Checklist - Final].[Intev_<_3_OS_Vinc_>_50_UCs_O],
       [99 A_Unificação_Checklist - Final].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 A_Unificação_Checklist - Final].Intev_0_UCs_Inter_O,
       [99 A_Unificação_Checklist - Final].Intev_0_UCs_Inter,
       [99 A_Unificação_Checklist - Final].Intev_Impro_Causa_Proc_O,
       [99 A_Unificação_Checklist - Final].Intev_Impro_Causa_Proc,
       [99 A_Unificação_Checklist - Final].Intev_Proc_Causa_Impro_O,
       [99 A_Unificação_Checklist - Final].Intev_Proc_Causa_Impro,
       [99 A_Unificação_Checklist - Final].Intev_S_OS_Vinc_O,
       [99 A_Unificação_Checklist - Final].Intev_S_OS_Vinc,
       [99 A_Unificação_Checklist - Final].OS_Vinc_UCs_Interr_O,
       [99 A_Unificação_Checklist - Final].OS_Vinc_UCs_Interr,
       [99 A_Unificação_Checklist - Final].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min_O],
       [99 A_Unificação_Checklist - Final].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 A_Unificação_Checklist - Final].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr_O],
       [99 A_Unificação_Checklist - Final].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 A_Unificação_Checklist - Final].[TMA_>_1440_O],
       [99 A_Unificação_Checklist - Final].[TMA_>_1440],
       [99 A_Unificação_Checklist - Final].TMD_0_O,
       [99 A_Unificação_Checklist - Final].TMD_0,
       [99 A_Unificação_Checklist - Final].TR_Próprio_OS_Proc_O,
       [99 A_Unificação_Checklist - Final].TR_Próprio_OS_Proc,
       [99 A_Unificação_Checklist - Final].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio_O,
       [99 A_Unificação_Checklist - Final].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 A_Unificação_Checklist - Final].OS_Elemen_Particular_Proc_O,
       [99 A_Unificação_Checklist - Final].OS_Elemen_Particular_Proc,
       [99 A_Unificação_Checklist - Final].OS_Impro_Sem_Elem_Partic_O,
       [99 A_Unificação_Checklist - Final].OS_Impro_Sem_Elem_Partic,
       [99 A_Unificação_Checklist - Final].[OS_Vinc_Hr_>_Ult_Passo_O],
       [99 A_Unificação_Checklist - Final].[OS_Vinc_Hr_>_Ult_Passo],
       [99 A_Unificação_Checklist - Final].Intv_TR_Zona_Div_UC_O,
       [99 A_Unificação_Checklist - Final].Intv_TR_Zona_Div_UC,
       [99 A_Unificação_Checklist - Final].OS_Acessante_O,
       [99 A_Unificação_Checklist - Final].OS_Acessante,
       [99 A_Unificação_Checklist - Final].OS_Externa_O,
       [99 A_Unificação_Checklist - Final].OS_Externa,
       [3 Cálculo_Ganho].DEC_G,
       [3 Cálculo_Ganho].FEC_G,
       [3 Cálculo_Ganho].TMA_G,
       [3 Cálculo_Ganho].COMP_G
FROM T_Lixo
  LEFT JOIN [99 A_Union_Status] ON T_Lixo.ID = [99 A_Union_Status].ID
  LEFT JOIN [99 A_Unificação_Checklist - Final] ON T_Lixo.ID = [99 A_Unificação_Checklist - Final].ID
  LEFT JOIN [3 Cálculo_Ganho] ON T_Lixo.ID = [3 Cálculo_Ganho].ID
  LEFT JOIN [99 OS_Corrigida_Fora_Crítica] ON T_Lixo.ID = [99 OS_Corrigida_Fora_Crítica].Pendente
  LEFT JOIN [99 OS_Analisada_Fora_Crítica] ON T_Lixo.ID = [99 OS_Analisada_Fora_Crítica].Pendente;

-- ===== 99 A_Union_Status  (SELECT)
SELECT T_Lixo.ID,
       [99 Correção].Correção,
       [99 A_Pendente].Pendente,
       [99 A_Pendente_Ag_Retorno].Pendente_A,
       [99 Análise].Análise
FROM T_Lixo
  LEFT JOIN [99 A_Pendente] ON T_Lixo.ID = [99 A_Pendente].AGRUP
  LEFT JOIN [99 Análise] ON T_Lixo.ID = [99 Análise].AGRUP
  LEFT JOIN [99 Correção] ON T_Lixo.ID = [99 Correção].AGRUP
  LEFT JOIN [99 A_Pendente_Ag_Retorno] ON T_Lixo.ID = [99 A_Pendente_Ag_Retorno].AGRUP;

-- ===== 99 Análise  (SELECT)
SELECT "Pendente" AS [AGRUP],
       Count([99 Base Correções Não Arquivadas - Intev].NUM_SEQ_OPER_OS_MNB) AS [Análise]
FROM [99 Base Correções Não Arquivadas - Intev]
GROUP BY "Pendente";

-- ===== 99 Base Correções Não Arquivadas - Intev  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros]![TMA] AS [TMA],
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada]) AS [Correção],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [C_Classificação] & [C_OS Vinculada] & [C_Passo de Manobra] & [C_Horário] & [C_Elemento Origem] AS [Unificar]
FROM [2 Intervenção Unificada - Filtros]
WHERE (((IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada])) Is Not Null));

-- ===== 99 Base Correções Não Arquivadas - Intev Corrig  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros]![TMA] AS [TMA],
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada]) AS [Correção],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [C_Classificação] & [C_OS Vinculada] & [C_Passo de Manobra] & [C_Horário] & [C_Elemento Origem] AS [Unificar]
FROM [2 Intervenção Unificada - Filtros]
WHERE (((IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada])) Is Not Null) AND (([C_Classificação] & [C_OS Vinculada] & [C_Passo de Manobra] & [C_Horário] & [C_Elemento Origem]) Is Not Null));

-- ===== 99 Base Correções Pendentes  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem]
FROM [99 Base Intervenção Unificada - Filtro]
GROUP BY [99 Base Intervenção Unificada - Filtro].TIPO_OS, [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB, [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB, [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB, [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB, [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB, [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB, [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB, [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE, [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB, [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI, [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB, [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU, [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB, [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR, [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB, [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB, [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB, [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB, [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB, [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB, [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB, [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB, [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB, [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB, [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS, [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS, [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS, [99 Base Intervenção Unificada - Filtro].TIPO_TR, [99 Base Intervenção Unificada - Filtro].TMA, [99 Base Intervenção Unificada - Filtro].DEC, [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h, [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h, [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc, [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc, [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro, [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001], [99 Base Intervenção Unificada - Filtro].TMD_0, [99 Base Intervenção Unificada - Filtro].[TMA_>_1440], [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs], [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc, [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr, [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter, [99 Base Intervenção Unificada - Filtro].[Correção Realizada], [99 Base Intervenção Unificada - Filtro].[Comp_>_500], [99 Base Intervenção Unificada - Filtro].FEC, [99 Base Intervenção Unificada - Filtro].COD_LOC_COS, [99 Base Intervenção Unificada - Filtro].LOCALIDADE, [99 Base Intervenção Unificada - Filtro].COEC, [99 Base Intervenção Unificada - Filtro].MULTA_OS, [99 Base Intervenção Unificada - Filtro].Concat, [99 Base Intervenção Unificada - Filtro].C_Classificação, [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada], [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra], [99 Base Intervenção Unificada - Filtro].C_Horário, [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem];

-- ===== 99 Base Individual - Filtro  (SELECT)
SELECT [99 Individual Unificar Filtros].TIPO_OS,
       [99 Individual Unificar Filtros].DTA_CMPT_MNB,
       [99 Individual Unificar Filtros].COD_CPU_CNR,
       [99 Individual Unificar Filtros].NUM_SEQ_OPER_CNR,
       [99 Individual Unificar Filtros].COD_UN_CONS_CNR,
       [99 Individual Unificar Filtros].COD_TIPO_OS_CNR,
       [99 Individual Unificar Filtros].COD_SUB_TIPO_OS_CNR,
       [99 Individual Unificar Filtros].COD_TIPO_ORIG_CNR,
       [99 Individual Unificar Filtros].DES_ORIG_OGE,
       [99 Individual Unificar Filtros].COD_ORIG_CNR,
       [99 Individual Unificar Filtros].DES_ORIG_ORI,
       [99 Individual Unificar Filtros].COD_CAUSA_INTER_CNR,
       [99 Individual Unificar Filtros].DES_CAUSA_INTER_CAU,
       [99 Individual Unificar Filtros].COD_SUB_CAUSA_INTER_CNR,
       [99 Individual Unificar Filtros].DES_SUB_CAUSA_INTER_SCR,
       [99 Individual Unificar Filtros].NOM_CLI_CNR,
       [99 Individual Unificar Filtros].DES_BAI_CNR,
       [99 Individual Unificar Filtros].DES_LOC_CNR,
       [99 Individual Unificar Filtros].DES_ENDE_UN_CONS_CNR,
       [99 Individual Unificar Filtros].DES_PTO_REF_CNR,
       [99 Individual Unificar Filtros].DTA_RECL_CNR,
       [99 Individual Unificar Filtros].DTA_COMU_CNR,
       [99 Individual Unificar Filtros].DTA_DLCT_CNR,
       [99 Individual Unificar Filtros].DTA_VERI_CNR,
       [99 Individual Unificar Filtros].DTA_SERV_CNR,
       [99 Individual Unificar Filtros].DTA_FIM_CNR,
       [99 Individual Unificar Filtros].DES_OBS_EXEC_SERV_CNR,
       [99 Individual Unificar Filtros].COD_TIPO_LOC_CNR,
       [99 Individual Unificar Filtros].TIPO_LOC_CNR,
       [99 Individual Unificar Filtros].COD_TIPO_CONCL_CNR,
       [99 Individual Unificar Filtros].INTERV,
       [99 Individual Unificar Filtros].COD_INS_TRF_INT,
       [99 Individual Unificar Filtros].TIPO_TR,
       [99 Individual Unificar Filtros].TMA,
       [99 Individual Unificar Filtros].DEC,
       [99 Individual Unificar Filtros].FEC,
       [99 Individual Unificar Filtros].COD_GRU_TENS_FAT_UEE,
       [99 Individual Unificar Filtros].MULTA_OS,
       [99 Individual Unificar Filtros].[Correção Realizada],
       [99 Individual Unificar Filtros].Análise
FROM [99 Individual Unificar Filtros]
WHERE ((([99 Individual Unificar Filtros].Análise)="Verificar"));

-- ===== 99 Base Individual - Filtro Produção  (SELECT)
SELECT [2 Individual Unificada - Filtros].TIPO_OS,
       [2 Individual Unificada - Filtros].DTA_CMPT_MNB,
       [2 Individual Unificada - Filtros].COD_CPU_CNR,
       [2 Individual Unificada - Filtros].NUM_SEQ_OPER_CNR,
       [2 Individual Unificada - Filtros].COD_UN_CONS_CNR,
       [2 Individual Unificada - Filtros].COD_TIPO_OS_CNR,
       [2 Individual Unificada - Filtros].COD_SUB_TIPO_OS_CNR,
       [2 Individual Unificada - Filtros].COD_TIPO_ORIG_CNR,
       [2 Individual Unificada - Filtros].DES_ORIG_OGE,
       [2 Individual Unificada - Filtros].COD_ORIG_CNR,
       [2 Individual Unificada - Filtros].DES_ORIG_ORI,
       [2 Individual Unificada - Filtros].COD_CAUSA_INTER_CNR,
       [2 Individual Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Individual Unificada - Filtros].COD_SUB_CAUSA_INTER_CNR,
       [2 Individual Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Individual Unificada - Filtros].NOM_CLI_CNR,
       [2 Individual Unificada - Filtros].DES_BAI_CNR,
       [2 Individual Unificada - Filtros].DES_LOC_CNR,
       [2 Individual Unificada - Filtros].DES_ENDE_UN_CONS_CNR,
       [2 Individual Unificada - Filtros].DES_PTO_REF_CNR,
       [2 Individual Unificada - Filtros].DTA_RECL_CNR,
       [2 Individual Unificada - Filtros].DTA_COMU_CNR,
       [2 Individual Unificada - Filtros].DTA_DLCT_CNR,
       [2 Individual Unificada - Filtros].DTA_VERI_CNR,
       [2 Individual Unificada - Filtros].DTA_SERV_CNR,
       [2 Individual Unificada - Filtros].DTA_FIM_CNR,
       [2 Individual Unificada - Filtros].DES_OBS_EXEC_SERV_CNR,
       [2 Individual Unificada - Filtros].COD_TIPO_LOC_CNR,
       [2 Individual Unificada - Filtros].TIPO_LOC_CNR,
       [2 Individual Unificada - Filtros].COD_TIPO_CONCL_CNR,
       [2 Individual Unificada - Filtros].INTERV,
       [2 Individual Unificada - Filtros].COD_INS_TRF_INT,
       [2 Individual Unificada - Filtros].TIPO_TR,
       [2 Individual Unificada - Filtros].TMA,
       [2 Individual Unificada - Filtros].DEC,
       [2 Individual Unificada - Filtros].FEC,
       [2 Individual Unificada - Filtros].COD_GRU_TENS_FAT_UEE,
       [2 Individual Unificada - Filtros].MULTA_OS,
       [2 Individual Unificada - Filtros].Análise,
       [2 Individual Unificada - Filtros].[Correção Realizada],
       [2 Individual Unificada - Filtros].USUÁRIO,
       [2 Individual Unificada - Filtros].OBSERVAÇÃO,
       [2 Individual Unificada - Filtros].STATUS,
       [2 Individual Unificada - Filtros].[DATA ANÁLISE],
       [2 Individual Unificada - Filtros].[DATA BAIXA],
       [2 Individual Unificada - Filtros].COEC,
       [2 Individual Unificada - Filtros].[Cod Localidade],
       IIf([2 Individual Unificada - Filtros]![Correção Realizada]="0",Null,[2 Individual Unificada - Filtros]![Correção Realizada]) AS [Correção]
FROM [2 Individual Unificada - Filtros]
WHERE (((IIf([2 Individual Unificada - Filtros]![Correção Realizada]="0",Null,[2 Individual Unificada - Filtros]![Correção Realizada])) Is Null));

-- ===== 99 Base Intervenção Unificada  (SELECT)
SELECT [2 Intervenção Unificada - Filtros].TIPO_OS,
       [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB,
       [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB,
       [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB,
       [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_OGE,
       [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DES_ORIG_ORI,
       [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU,
       [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB,
       [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR,
       [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB,
       [2 Intervenção Unificada - Filtros].DES_INTV_MNB,
       [2 Intervenção Unificada - Filtros].DTA_INIC_MNB,
       [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB,
       [2 Intervenção Unificada - Filtros].DTA_FIM_MNB,
       [2 Intervenção Unificada - Filtros].COD_ELE_MNB,
       [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS,
       [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS,
       [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS,
       [2 Intervenção Unificada - Filtros].TIPO_TR,
       [2 Intervenção Unificada - Filtros]![TMA] AS [TMA],
       [2 Intervenção Unificada - Filtros].DEC,
       [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h,
       [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc,
       [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro,
       [2 Intervenção Unificada - Filtros].[DEC_>_0,001],
       [2 Intervenção Unificada - Filtros].TMD_0,
       [2 Intervenção Unificada - Filtros].[TMA_>_1440],
       [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs],
       [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc,
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr,
       [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter,
       [2 Intervenção Unificada - Filtros].[Correção Realizada],
       [2 Intervenção Unificada - Filtros].[Comp_>_500],
       [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc,
       [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo],
       [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic,
       [2 Intervenção Unificada - Filtros].MULTA_OS,
       [2 Intervenção Unificada - Filtros].FEC,
       [2 Intervenção Unificada - Filtros].COD_LOC_COS,
       [2 Intervenção Unificada - Filtros].LOCALIDADE,
       [2 Intervenção Unificada - Filtros].COEC,
       [DIF_1ª_2ª_RCM_1h] & [DIF_1ª_Man_1ª_OS_Vinc_2h] & [TR_Próprio_OS_Proc] & [Intev_Impro_Causa_Proc] & [Intev_Proc_Causa_Impro] & [DEC_>_0,001] & [TMD_0] & [TMA_>_1440] & [Intev_<_3_OS_Vinc_>_50_UCs] & [Intev_S_OS_Vinc] & [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min] & [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr] & [OS_Vinc_UCs_Interr] & [Intev_0_UCs_Inter] & [Correção Realizada] & [Comp_>_500] & [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio] & [OS_Elemen_Particular_Proc] & [OS_Vinc_Hr_>_Ult_Passo] & [OS_Impro_Sem_Elem_Partic] & [Intv_TR_Zona_Div_UC] & [OS_Externa] & [OS_Acessante] AS [CONCAT],
       IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada]) AS [Correção],
       [2 Intervenção Unificada - Filtros].C_Classificação,
       [2 Intervenção Unificada - Filtros].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros].C_Horário,
       [2 Intervenção Unificada - Filtros].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros].USUÁRIO,
       [2 Intervenção Unificada - Filtros].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros].STATUS,
       [2 Intervenção Unificada - Filtros].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros].[DATA BAIXA],
       [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC,
       [2 Intervenção Unificada - Filtros].OS_Externa,
       [2 Intervenção Unificada - Filtros].OS_Acessante
FROM [2 Intervenção Unificada - Filtros]
WHERE (((IIf([2 Intervenção Unificada - Filtros]![Correção Realizada]="0",Null,[2 Intervenção Unificada - Filtros]![Correção Realizada])) Is Null));

-- ===== 99 Base Intervenção Unificada - Filtro  (SELECT)
SELECT [99 Base Intervenção Unificada].TIPO_OS,
       [99 Base Intervenção Unificada].DTA_CMPT_MNB,
       [99 Base Intervenção Unificada].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_OGE,
       [99 Base Intervenção Unificada].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_ORI,
       [99 Base Intervenção Unificada].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].DES_INTV_MNB,
       [99 Base Intervenção Unificada].DTA_INIC_MNB,
       [99 Base Intervenção Unificada].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_FIM_MNB,
       [99 Base Intervenção Unificada].COD_ELE_MNB,
       [99 Base Intervenção Unificada].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada].TIPO_TR,
       [99 Base Intervenção Unificada].TMA,
       [99 Base Intervenção Unificada].DEC,
       [99 Base Intervenção Unificada].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada].[DEC_>_0,001],
       [99 Base Intervenção Unificada].TMD_0,
       [99 Base Intervenção Unificada].[TMA_>_1440],
       [99 Base Intervenção Unificada].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada].[Correção Realizada],
       [99 Base Intervenção Unificada].[Comp_>_500],
       [99 Base Intervenção Unificada].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada].FEC,
       [99 Base Intervenção Unificada].COD_LOC_COS,
       [99 Base Intervenção Unificada].LOCALIDADE,
       [99 Base Intervenção Unificada].COEC,
       [99 Base Intervenção Unificada].MULTA_OS,
       [99 Base Intervenção Unificada].Concat,
       [99 Base Intervenção Unificada].C_Classificação,
       [99 Base Intervenção Unificada].[C_OS Vinculada],
       [99 Base Intervenção Unificada].[C_Passo de Manobra],
       [99 Base Intervenção Unificada].C_Horário,
       [99 Base Intervenção Unificada].[C_Elemento Origem],
       [99 Base Intervenção Unificada].USUÁRIO,
       [99 Base Intervenção Unificada].OBSERVAÇÃO,
       [99 Base Intervenção Unificada].STATUS,
       [99 Base Intervenção Unificada].[DATA ANÁLISE],
       [99 Base Intervenção Unificada].[DATA BAIXA],
       [99 Base Intervenção Unificada].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada].OS_Externa,
       [99 Base Intervenção Unificada].OS_Acessante
FROM [99 Base Intervenção Unificada]
WHERE ((([99 Base Intervenção Unificada].Concat)<>"" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "") AND (([99 Base Intervenção Unificada].USUÁRIO) Is Null) AND (([99 Base Intervenção Unificada].OBSERVAÇÃO) Is Null) AND (([99 Base Intervenção Unificada].STATUS) Is Null) AND (([99 Base Intervenção Unificada].[DATA ANÁLISE]) Is Null));

-- ===== 99 Base Intervenção Unificada - Filtro - Buscar OS  (SELECT)
SELECT [99 Base Intervenção Unificada].TIPO_OS,
       [99 Base Intervenção Unificada].DTA_CMPT_MNB,
       [99 Base Intervenção Unificada].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_OGE,
       [99 Base Intervenção Unificada].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_ORI,
       [99 Base Intervenção Unificada].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].DES_INTV_MNB,
       [99 Base Intervenção Unificada].DTA_INIC_MNB,
       [99 Base Intervenção Unificada].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_FIM_MNB,
       [99 Base Intervenção Unificada].COD_ELE_MNB,
       [99 Base Intervenção Unificada].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada].TIPO_TR,
       [99 Base Intervenção Unificada].TMA,
       [99 Base Intervenção Unificada].DEC,
       [99 Base Intervenção Unificada].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada].[DEC_>_0,001],
       [99 Base Intervenção Unificada].TMD_0,
       [99 Base Intervenção Unificada].[TMA_>_1440],
       [99 Base Intervenção Unificada].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada].[Correção Realizada],
       [99 Base Intervenção Unificada].[Comp_>_500],
       [99 Base Intervenção Unificada].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada].FEC,
       [99 Base Intervenção Unificada].COD_LOC_COS,
       [99 Base Intervenção Unificada].LOCALIDADE,
       [99 Base Intervenção Unificada].COEC,
       [99 Base Intervenção Unificada].MULTA_OS,
       [99 Base Intervenção Unificada].Concat,
       [99 Base Intervenção Unificada].C_Classificação,
       [99 Base Intervenção Unificada].[C_OS Vinculada],
       [99 Base Intervenção Unificada].[C_Passo de Manobra],
       [99 Base Intervenção Unificada].C_Horário,
       [99 Base Intervenção Unificada].[C_Elemento Origem],
       [99 Base Intervenção Unificada].USUÁRIO,
       [99 Base Intervenção Unificada].OBSERVAÇÃO,
       [99 Base Intervenção Unificada].STATUS,
       [99 Base Intervenção Unificada].[DATA ANÁLISE],
       [99 Base Intervenção Unificada].[DATA BAIXA],
       [99 Base Intervenção Unificada].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada].OS_Externa,
       [99 Base Intervenção Unificada].OS_Acessante
FROM [99 Base Intervenção Unificada]
WHERE ((([99 Base Intervenção Unificada].Concat)<>"" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & ""));

-- ===== 99 Base Intervenção Unificada - Filtro Ag Retorno  (SELECT)
SELECT [99 Base Intervenção Unificada].TIPO_OS,
       [99 Base Intervenção Unificada].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_OGE,
       [99 Base Intervenção Unificada].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada].DES_ORIG_ORI,
       [99 Base Intervenção Unificada].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada].DES_INTV_MNB,
       [99 Base Intervenção Unificada].DTA_INIC_MNB,
       [99 Base Intervenção Unificada].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada].DTA_FIM_MNB,
       [99 Base Intervenção Unificada].COD_ELE_MNB,
       [99 Base Intervenção Unificada].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada].TIPO_TR,
       [99 Base Intervenção Unificada].TMA,
       [99 Base Intervenção Unificada].DEC,
       [99 Base Intervenção Unificada].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada].[DEC_>_0,001],
       [99 Base Intervenção Unificada].TMD_0,
       [99 Base Intervenção Unificada].[TMA_>_1440],
       [99 Base Intervenção Unificada].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada].[Correção Realizada],
       [99 Base Intervenção Unificada].[Comp_>_500],
       [99 Base Intervenção Unificada].FEC,
       [99 Base Intervenção Unificada].COD_LOC_COS,
       [99 Base Intervenção Unificada].LOCALIDADE,
       [99 Base Intervenção Unificada].COEC,
       [99 Base Intervenção Unificada].MULTA_OS,
       [99 Base Intervenção Unificada].Concat,
       [99 Base Intervenção Unificada].C_Classificação,
       [99 Base Intervenção Unificada].[C_OS Vinculada],
       [99 Base Intervenção Unificada].[C_Passo de Manobra],
       [99 Base Intervenção Unificada].C_Horário,
       [99 Base Intervenção Unificada].[C_Elemento Origem],
       [99 Base Intervenção Unificada].USUÁRIO,
       [99 Base Intervenção Unificada].OBSERVAÇÃO,
       [99 Base Intervenção Unificada].STATUS,
       [99 Base Intervenção Unificada].[DATA ANÁLISE],
       [99 Base Intervenção Unificada].[DATA BAIXA],
       [99 Base Intervenção Unificada].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada].OS_Externa,
       [99 Base Intervenção Unificada].OS_Acessante
FROM [99 Base Intervenção Unificada]
WHERE ((([99 Base Intervenção Unificada].Concat)<>"" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "" & "") AND (([99 Base Intervenção Unificada].USUÁRIO) Is Not Null));

-- ===== 99 Correção  (SELECT)
SELECT "Pendente" AS [AGRUP],
       Count([99 Base Correções Não Arquivadas - Intev Corrig].NUM_SEQ_OPER_OS_MNB) AS [Correção]
FROM [99 Base Correções Não Arquivadas - Intev Corrig]
GROUP BY "Pendente";

-- ===== 99 Individual Limpar Filtros  (DELETE)
DELETE [2 Individual Unificada - Filtros].DTA_CMPT_MNB, [2 Individual Unificada - Filtros].TIPO_OS, [2 Individual Unificada - Filtros].COD_CPU_CNR, [2 Individual Unificada - Filtros].NUM_SEQ_OPER_CNR, [2 Individual Unificada - Filtros].COD_UN_CONS_CNR, [2 Individual Unificada - Filtros].COD_TIPO_OS_CNR, [2 Individual Unificada - Filtros].COD_SUB_TIPO_OS_CNR, [2 Individual Unificada - Filtros].COD_TIPO_ORIG_CNR, [2 Individual Unificada - Filtros].DES_ORIG_OGE, [2 Individual Unificada - Filtros].COD_ORIG_CNR, [2 Individual Unificada - Filtros].DES_ORIG_ORI, [2 Individual Unificada - Filtros].COD_CAUSA_INTER_CNR, [2 Individual Unificada - Filtros].DES_CAUSA_INTER_CAU, [2 Individual Unificada - Filtros].COD_SUB_CAUSA_INTER_CNR, [2 Individual Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR, [2 Individual Unificada - Filtros].NOM_CLI_CNR, [2 Individual Unificada - Filtros].DES_BAI_CNR, [2 Individual Unificada - Filtros].DES_LOC_CNR, [2 Individual Unificada - Filtros].DES_ENDE_UN_CONS_CNR, [2 Individual Unificada - Filtros].DES_PTO_REF_CNR, [2 Individual Unificada - Filtros].DTA_RECL_CNR, [2 Individual Unificada - Filtros].DTA_COMU_CNR, [2 Individual Unificada - Filtros].DTA_DLCT_CNR, [2 Individual Unificada - Filtros].DTA_VERI_CNR, [2 Individual Unificada - Filtros].DTA_SERV_CNR, [2 Individual Unificada - Filtros].DTA_FIM_CNR, [2 Individual Unificada - Filtros].DES_OBS_EXEC_SERV_CNR, [2 Individual Unificada - Filtros].COD_TIPO_LOC_CNR, [2 Individual Unificada - Filtros].TIPO_LOC_CNR, [2 Individual Unificada - Filtros].COD_TIPO_CONCL_CNR, [2 Individual Unificada - Filtros].INTERV, [2 Individual Unificada - Filtros].COD_INS_TRF_INT, [2 Individual Unificada - Filtros].TIPO_TR, [2 Individual Unificada - Filtros].TMA, [2 Individual Unificada - Filtros].DEC, [2 Individual Unificada - Filtros].FEC, [2 Individual Unificada - Filtros].COD_GRU_TENS_FAT_UEE, [2 Individual Unificada - Filtros].MULTA_OS, [2 Individual Unificada - Filtros].Análise, [2 Individual Unificada - Filtros].[Correção Realizada], [2 Individual Unificada - Filtros].USUÁRIO, [2 Individual Unificada - Filtros].OBSERVAÇÃO, [2 Individual Unificada - Filtros].STATUS, [2 Individual Unificada - Filtros].[DATA ANÁLISE], [2 Individual Unificada - Filtros].[DATA BAIXA], [2 Individual Unificada - Filtros].COEC, [2 Individual Unificada - Filtros].[Cod Localidade]
FROM [2 Individual Unificada - Filtros];

-- ===== 99 Individual Unificar - Filtros  (APPEND)
INSERT INTO [2 Individual Unificada - Filtros] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_CNR, NUM_SEQ_OPER_CNR, COD_UN_CONS_CNR, COD_TIPO_OS_CNR, COD_SUB_TIPO_OS_CNR, COD_TIPO_ORIG_CNR, DES_ORIG_OGE, COD_ORIG_CNR, DES_ORIG_ORI, COD_CAUSA_INTER_CNR, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_INTER_CNR, DES_SUB_CAUSA_INTER_SCR, NOM_CLI_CNR, DES_BAI_CNR, DES_LOC_CNR, DES_ENDE_UN_CONS_CNR, DES_PTO_REF_CNR, DTA_RECL_CNR, DTA_COMU_CNR, DTA_DLCT_CNR, DTA_VERI_CNR, DTA_SERV_CNR, DTA_FIM_CNR, DES_OBS_EXEC_SERV_CNR, COD_TIPO_LOC_CNR, TIPO_LOC_CNR, COD_TIPO_CONCL_CNR, INTERV, COD_INS_TRF_INT, TIPO_TR, TMA, DEC, FEC, COD_GRU_TENS_FAT_UEE, MULTA_OS, Correção Realizada, Análise, Cod Localidade, COEC)
SELECT [99 Base Individual - Filtro].TIPO_OS,
       [99 Base Individual - Filtro].DTA_CMPT_MNB,
       [99 Base Individual - Filtro].COD_CPU_CNR,
       [99 Base Individual - Filtro].NUM_SEQ_OPER_CNR,
       [99 Base Individual - Filtro].COD_UN_CONS_CNR,
       [99 Base Individual - Filtro].COD_TIPO_OS_CNR,
       [99 Base Individual - Filtro].COD_SUB_TIPO_OS_CNR,
       [99 Base Individual - Filtro].COD_TIPO_ORIG_CNR,
       [99 Base Individual - Filtro].DES_ORIG_OGE,
       [99 Base Individual - Filtro].COD_ORIG_CNR,
       [99 Base Individual - Filtro].DES_ORIG_ORI,
       [99 Base Individual - Filtro].COD_CAUSA_INTER_CNR,
       [99 Base Individual - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Individual - Filtro].COD_SUB_CAUSA_INTER_CNR,
       [99 Base Individual - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Individual - Filtro].NOM_CLI_CNR,
       [99 Base Individual - Filtro].DES_BAI_CNR,
       [99 Base Individual - Filtro].DES_LOC_CNR,
       [99 Base Individual - Filtro].DES_ENDE_UN_CONS_CNR,
       [99 Base Individual - Filtro].DES_PTO_REF_CNR,
       [99 Base Individual - Filtro].DTA_RECL_CNR,
       [99 Base Individual - Filtro].DTA_COMU_CNR,
       [99 Base Individual - Filtro].DTA_DLCT_CNR,
       [99 Base Individual - Filtro].DTA_VERI_CNR,
       [99 Base Individual - Filtro].DTA_SERV_CNR,
       [99 Base Individual - Filtro].DTA_FIM_CNR,
       [99 Base Individual - Filtro].DES_OBS_EXEC_SERV_CNR,
       [99 Base Individual - Filtro].COD_TIPO_LOC_CNR,
       [99 Base Individual - Filtro].TIPO_LOC_CNR,
       [99 Base Individual - Filtro].COD_TIPO_CONCL_CNR,
       [99 Base Individual - Filtro].INTERV,
       [99 Base Individual - Filtro].COD_INS_TRF_INT,
       [99 Base Individual - Filtro].TIPO_TR,
       [99 Base Individual - Filtro].TMA,
       [99 Base Individual - Filtro].DEC,
       [99 Base Individual - Filtro].FEC,
       [99 Base Individual - Filtro].COD_GRU_TENS_FAT_UEE,
       [99 Base Individual - Filtro].MULTA_OS,
       [99 Base Individual - Filtro].[Correção Realizada],
       [99 Base Individual - Filtro].Análise,
       Segmentação_Lógica.[Cod Localidade],
       Segmentação_Lógica.COEC
FROM [Segmentação_Lógica]
  INNER JOIN [99 Base Individual - Filtro] ON Segmentação_Lógica.Local = [99 Base Individual - Filtro].DES_LOC_CNR;

-- ===== 99 Individual Unificar Filtros  (SELECT)
SELECT [1 Tabela Ocorrência_Individual].TIPO_OS,
       [1 Tabela Ocorrência_Individual].DTA_CMPT_MNB,
       [1 Tabela Ocorrência_Individual].COD_CPU_CNR,
       [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR,
       [1 Tabela Ocorrência_Individual].COD_UN_CONS_CNR,
       [1 Tabela Ocorrência_Individual].COD_TIPO_OS_CNR,
       [1 Tabela Ocorrência_Individual].COD_SUB_TIPO_OS_CNR,
       [1 Tabela Ocorrência_Individual].COD_TIPO_ORIG_CNR,
       [1 Tabela Ocorrência_Individual].DES_ORIG_OGE,
       [1 Tabela Ocorrência_Individual].COD_ORIG_CNR,
       [1 Tabela Ocorrência_Individual].DES_ORIG_ORI,
       [1 Tabela Ocorrência_Individual].COD_CAUSA_INTER_CNR,
       [1 Tabela Ocorrência_Individual].DES_CAUSA_INTER_CAU,
       [1 Tabela Ocorrência_Individual].COD_SUB_CAUSA_INTER_CNR,
       [1 Tabela Ocorrência_Individual].DES_SUB_CAUSA_INTER_SCR,
       [1 Tabela Ocorrência_Individual].NOM_CLI_CNR,
       [1 Tabela Ocorrência_Individual].DES_BAI_CNR,
       [1 Tabela Ocorrência_Individual].DES_LOC_CNR,
       [1 Tabela Ocorrência_Individual].DES_ENDE_UN_CONS_CNR,
       [1 Tabela Ocorrência_Individual].DES_PTO_REF_CNR,
       [1 Tabela Ocorrência_Individual].DTA_RECL_CNR,
       [1 Tabela Ocorrência_Individual].DTA_COMU_CNR,
       [1 Tabela Ocorrência_Individual].DTA_DLCT_CNR,
       [1 Tabela Ocorrência_Individual].DTA_VERI_CNR,
       [1 Tabela Ocorrência_Individual].DTA_SERV_CNR,
       [1 Tabela Ocorrência_Individual].DTA_FIM_CNR,
       [1 Tabela Ocorrência_Individual].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela Ocorrência_Individual].COD_TIPO_LOC_CNR,
       [1 Tabela Ocorrência_Individual].TIPO_LOC_CNR,
       [1 Tabela Ocorrência_Individual].COD_TIPO_CONCL_CNR,
       [1 Tabela Ocorrência_Individual].INTERV,
       [1 Tabela Ocorrência_Individual].COD_INS_TRF_INT,
       [1 Tabela Ocorrência_Individual].TIPO_TR,
       [1 Tabela Ocorrência_Individual].TMA,
       [1 Tabela Ocorrência_Individual].DEC,
       [1 Tabela Ocorrência_Individual].FEC,
       [1 Tabela Ocorrência_Individual].COD_GRU_TENS_FAT_UEE,
       [00 Multa Ocorrência].MULTA_OS,
       [1 Tabela Ocorrência_Individual].[Correção Realizada],
       IIf([COD_GRU_TENS_FAT_UEE]="A","Verificar",IIf([INTERV] Is Not Null,"Verificar","")) AS [Análise]
FROM [1 Tabela Ocorrência_Individual]
  LEFT JOIN [00 Multa Ocorrência] ON [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR = [00 Multa Ocorrência].NUM_SEQ_OPER_INIC_INTER_VDI
WHERE ((([1 Tabela Ocorrência_Individual].COD_SUB_TIPO_OS_CNR)<>"iNS") AND (([1 Tabela Ocorrência_Individual].COD_TIPO_CONCL_CNR)="000") AND (([1 Tabela Ocorrência_Individual].[Correção Realizada]) Is Null));

-- ===== 99 Intev Unificado - Retirada Filtro  (SELECT)
SELECT [99 Intev Unificado - Retirar Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Intev Unificado - Retirar Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Intev Unificado - Retirar Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Intev Unificado - Retirar Filtro].TR_Próprio_OS_Proc,
       [99 Intev Unificado - Retirar Filtro].Intev_Impro_Causa_Proc,
       [99 Intev Unificado - Retirar Filtro].Intev_Proc_Causa_Impro,
       [99 Intev Unificado - Retirar Filtro].[DEC_>_0,001],
       [99 Intev Unificado - Retirar Filtro].TMD_0,
       [99 Intev Unificado - Retirar Filtro].[TMA_>_1440],
       [99 Intev Unificado - Retirar Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Intev Unificado - Retirar Filtro].Intev_S_OS_Vinc,
       [99 Intev Unificado - Retirar Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Intev Unificado - Retirar Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Intev Unificado - Retirar Filtro].OS_Vinc_UCs_Interr,
       [99 Intev Unificado - Retirar Filtro].Intev_0_UCs_Inter,
       [99 Intev Unificado - Retirar Filtro].[Comp_>_500],
       [99 Intev Unificado - Retirar Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Intev Unificado - Retirar Filtro].OS_Elemen_Particular_Proc,
       [99 Intev Unificado - Retirar Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Intev Unificado - Retirar Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Intev Unificado - Retirar Filtro].Intv_TR_Zona_Div_UC,
       [99 Intev Unificado - Retirar Filtro].OS_Externa,
       [99 Intev Unificado - Retirar Filtro].OS_Acessante,
       [99 Intev Unificado - Retirar Filtro].Concat
FROM [99 Intev Unificado - Retirar Filtro]
WHERE ((([99 Intev Unificado - Retirar Filtro].Concat) Not In ("Verificar----------------","-----------------","--------Verificar--------","---------Verificar-------","-------------Dif Man e Pass---","-------------Dif Pass OS---","-------------Dif Passo OS---")));

-- ===== 99 Intev Unificado - Retirada Filtro Agrup  (SELECT)
SELECT [99 Intev Unificado - Retirada Filtro].NUM_SEQ_OPER_OS_MNB
FROM [99 Intev Unificado - Retirada Filtro]
GROUP BY [99 Intev Unificado - Retirada Filtro].NUM_SEQ_OPER_OS_MNB;

-- ===== 99 Intev Unificado - Retirar Filtro  (SELECT)
SELECT [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_SEQ_OPER_OS_MNB,
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![DIF_1ª_2ª_RCM_1h]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![DIF_1ª_2ª_RCM_1h]) AS [DIF_1ª_2ª_RCM_1h],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![DIF_1ª_Man_1ª_OS_Vinc_2h]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![DIF_1ª_Man_1ª_OS_Vinc_2h]) AS [DIF_1ª_Man_1ª_OS_Vinc_2h],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![TR_Próprio_OS_Proc]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![TR_Próprio_OS_Proc]) AS [TR_Próprio_OS_Proc],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_Impro_Causa_Proc]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_Impro_Causa_Proc]) AS [Intev_Impro_Causa_Proc],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_Proc_Causa_Impro]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_Proc_Causa_Impro]) AS [Intev_Proc_Causa_Impro],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![DEC_>_0,001]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![DEC_>_0,001]) AS [DEC_>_0,001],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![TMD_0]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![TMD_0]) AS [TMD_0],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![TMA_>_1440]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![TMA_>_1440]) AS [TMA_>_1440],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_<_3_OS_Vinc_>_50_UCs]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_<_3_OS_Vinc_>_50_UCs]) AS [Intev_<_3_OS_Vinc_>_50_UCs],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_S_OS_Vinc]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_S_OS_Vinc]) AS [Intev_S_OS_Vinc],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]) AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]) AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Vinc_UCs_Interr]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Vinc_UCs_Interr]) AS [OS_Vinc_UCs_Interr],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_0_UCs_Inter]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intev_0_UCs_Inter]) AS [Intev_0_UCs_Inter],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Comp_>_500]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Comp_>_500]) AS [Comp_>_500],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]) AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Elemen_Particular_Proc]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Elemen_Particular_Proc]) AS [OS_Elemen_Particular_Proc],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Vinc_Hr_>_Ult_Passo]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Vinc_Hr_>_Ult_Passo]) AS [OS_Vinc_Hr_>_Ult_Passo],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Impro_Sem_Elem_Partic]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Impro_Sem_Elem_Partic]) AS [OS_Impro_Sem_Elem_Partic],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![Intv_TR_Zona_Div_UC]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![Intv_TR_Zona_Div_UC]) AS [Intv_TR_Zona_Div_UC],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Externa]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Externa]) AS [OS_Externa],
       IIf([99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Acessante]="","-",[99 Intev Unificar - Filtros_Cruzamento_Backup]![OS_Acessante]) AS [OS_Acessante],
       [DIF_1ª_2ª_RCM_1h] & [DIF_1ª_Man_1ª_OS_Vinc_2h] & [TR_Próprio_OS_Proc] & [Intev_Impro_Causa_Proc] & [Intev_Proc_Causa_Impro] & [DEC_>_0,001] & [TMD_0] & [TMA_>_1440] & [Intev_<_3_OS_Vinc_>_50_UCs] & [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min] & [Intev_S_OS_Vinc] & [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr] & [OS_Vinc_UCs_Interr] & [Intev_0_UCs_Inter] & [Comp_>_500] & [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio] & [OS_Elemen_Particular_Proc] & [OS_Vinc_Hr_>_Ult_Passo] & [OS_Impro_Sem_Elem_Partic] & [Intv_TR_Zona_Div_UC] & [OS_Externa] & [OS_Acessante] AS [Concat]
FROM [99 Intev Unificar - Filtros_Cruzamento_Backup];

-- ===== 99 Intev Unificar - Filtros  (APPEND)
INSERT INTO [2 Intervenção Unificada - Filtros] (TIPO_OS, DTA_CMPT_MNB, COD_CPU_OS_MNB, NUM_SEQ_OPER_OS_MNB, NUM_SEQ_GER_OS_MNB, NOM_USU_PROGM_MNB, NOM_USU_CFER_MNB, NOM_USU_EXEC_MNB, COD_TIPO_ORIG_INTV_MNB, DES_ORIG_OGE, COD_ORIG_INTV_MNB, DES_ORIG_ORI, COD_CAUSA_MNB, DES_CAUSA_INTER_CAU, COD_SUB_CAUSA_MNB, DES_SUB_CAUSA_INTER_SCR, NUM_CAUSA_ANEEL_MNB, NUM_SUB_CAUSA_ANEEL_MNB, DES_INTV_MNB, DTA_INIC_MNB, DTA_AVI_EQP_MNB, DTA_DLCT_EQP_MNB, DTA_VERI_EQP_MNB, DTA_SERV_EQP_MNB, DTA_FIM_MNB, COD_ELE_MNB, COD_INS_SEC_INS, COD_TIPO_CONCL_COS, COD_SUB_TIPO_OS_COS, TIPO_TR, TMA, DEC, DIF_1ª_2ª_RCM_1h, DIF_1ª_Man_1ª_OS_Vinc_2h, TR_Próprio_OS_Proc, Intev_Impro_Causa_Proc, Intev_Proc_Causa_Impro, DEC_>_0,001, TMD_0, TMA_>_1440, Intev_<_3_OS_Vinc_>_50_UCs, Intev_S_OS_Vinc, Tempo_Hr_Inic_Hr_1º_Passo_=_1_min, Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr, OS_Vinc_UCs_Interr, Intev_0_UCs_Inter, Comp_>_500, Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, OS_Elemen_Particular_Proc, OS_Vinc_Hr_>_Ult_Passo, OS_Impro_Sem_Elem_Partic, Intv_TR_Zona_Div_UC, OS_Externa, OS_Acessante, MULTA_OS, FEC, COD_LOC_COS, COEC, Correção Realizada, C_Classificação, C_OS Vinculada, C_Passo de Manobra, C_Horário, C_Elemento Origem, USUÁRIO, OBSERVAÇÃO, STATUS, DATA ANÁLISE, DATA BAIXA, LOCALIDADE)
SELECT [99 Intev Unificar - Filtros_Cruzamento_Backup].TIPO_OS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_CMPT_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_CPU_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_SEQ_OPER_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_SEQ_GER_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NOM_USU_PROGM_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NOM_USU_CFER_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NOM_USU_EXEC_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_TIPO_ORIG_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DES_ORIG_OGE,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_ORIG_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DES_ORIG_ORI,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_CAUSA_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DES_CAUSA_INTER_CAU,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_SUB_CAUSA_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DES_SUB_CAUSA_INTER_SCR,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_CAUSA_ANEEL_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DES_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_INIC_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_AVI_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_DLCT_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_VERI_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_SERV_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DTA_FIM_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_ELE_MNB,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_INS_SEC_INS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_TIPO_CONCL_COS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_SUB_TIPO_OS_COS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].TIPO_TR,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].TMA,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DEC,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DIF_1ª_2ª_RCM_1h,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].TR_Próprio_OS_Proc,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Intev_Impro_Causa_Proc,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Intev_Proc_Causa_Impro,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[DEC_>_0,001],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].TMD_0,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[TMA_>_1440],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Intev_S_OS_Vinc,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OS_Vinc_UCs_Interr,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Intev_0_UCs_Inter,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[Comp_>_500],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OS_Elemen_Particular_Proc,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OS_Impro_Sem_Elem_Partic,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Intv_TR_Zona_Div_UC,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OS_Externa,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OS_Acessante,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].MULTA_OS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].FEC,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COD_LOC_COS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].COEC,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[Correção Realizada],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].C_Classificação,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[C_OS Vinculada],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[C_Passo de Manobra],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].C_Horário,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[C_Elemento Origem],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].USUÁRIO,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].OBSERVAÇÃO,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].STATUS,
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[DATA ANÁLISE],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].[DATA BAIXA],
       [99 Intev Unificar - Filtros_Cruzamento_Backup].Local
FROM [99 Intev Unificar - Filtros_Cruzamento_Backup]
  INNER JOIN [99 Intev Unificado - Retirada Filtro Agrup] ON [99 Intev Unificar - Filtros_Cruzamento_Backup].NUM_SEQ_OPER_OS_MNB = [99 Intev Unificado - Retirada Filtro Agrup].NUM_SEQ_OPER_OS_MNB;

-- ===== 99 Intev Unificar - Filtros_Cruzamento  (SELECT)
SELECT [1 Tabela_Intervenção].TIPO_OS,
       [1 Tabela_Intervenção].DTA_CMPT_MNB,
       [1 Tabela_Intervenção].COD_CPU_OS_MNB,
       [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].NUM_SEQ_GER_OS_MNB,
       [1 Tabela_Intervenção].NOM_USU_PROGM_MNB,
       [1 Tabela_Intervenção].NOM_USU_CFER_MNB,
       [1 Tabela_Intervenção].NOM_USU_EXEC_MNB,
       [1 Tabela_Intervenção].COD_TIPO_ORIG_INTV_MNB,
       [1 Tabela_Intervenção].DES_ORIG_OGE,
       [1 Tabela_Intervenção].COD_ORIG_INTV_MNB,
       [1 Tabela_Intervenção].DES_ORIG_ORI,
       [1 Tabela_Intervenção].COD_CAUSA_MNB,
       [1 Tabela_Intervenção].DES_CAUSA_INTER_CAU,
       [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB,
       [1 Tabela_Intervenção].DES_SUB_CAUSA_INTER_SCR,
       [1 Tabela_Intervenção].NUM_CAUSA_ANEEL_MNB,
       [1 Tabela_Intervenção].NUM_SUB_CAUSA_ANEEL_MNB,
       [1 Tabela_Intervenção].DES_INTV_MNB,
       [1 Tabela_Intervenção].DTA_INIC_MNB,
       [1 Tabela_Intervenção].DTA_AVI_EQP_MNB,
       [1 Tabela_Intervenção].DTA_DLCT_EQP_MNB,
       [1 Tabela_Intervenção].DTA_VERI_EQP_MNB,
       [1 Tabela_Intervenção].DTA_SERV_EQP_MNB,
       [1 Tabela_Intervenção].DTA_FIM_MNB,
       [1 Tabela_Intervenção].COD_ELE_MNB,
       [1 Tabela_Intervenção].COD_INS_SEC_INS,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       [1 Tabela_Intervenção].COD_SUB_TIPO_OS_COS,
       [1 Tabela_Intervenção].TIPO_TR,
       [1 Tabela_Intervenção].TMA,
       [1 Tabela_Intervenção].DEC,
       [99 Intev Unificar Filtros - TMA Tratado].DIF_1ª_2ª_RCM_1h,
       [99 Intev Unificar Filtros - TMA Tratado].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Intev Unificar Filtros - TMA Tratado].TR_Próprio_OS_Proc,
       [99 Intev Unificar Filtros - TMA Tratado].Intev_Impro_Causa_Proc,
       [99 Intev Unificar Filtros - TMA Tratado].Intev_Proc_Causa_Impro,
       [99 Intev Unificar Filtros - TMA Tratado].[DEC_>_0,001],
       [99 Intev Unificar Filtros - TMA Tratado].TMD_0,
       [99 Intev Unificar Filtros - TMA Tratado].[TMA_>_1440],
       [99 Intev Unificar Filtros - TMA Tratado].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Intev Unificar Filtros - TMA Tratado].Intev_S_OS_Vinc,
       [99 Intev Unificar Filtros - TMA Tratado].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Intev Unificar Filtros - TMA Tratado].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Intev Unificar Filtros - TMA Tratado].OS_Vinc_UCs_Interr,
       [99 Intev Unificar Filtros - TMA Tratado].Intev_0_UCs_Inter,
       [99 Intev Unificar Filtros - TMA Tratado].[Comp_>_500],
       [99 Intev Unificar Filtros - TMA Tratado].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Intev Unificar Filtros - TMA Tratado].OS_Elemen_Particular_Proc,
       [99 Intev Unificar Filtros - TMA Tratado].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Intev Unificar Filtros - TMA Tratado].OS_Impro_Sem_Elem_Partic,
       [99 Intev Unificar Filtros - TMA Tratado].Intv_TR_Zona_Div_UC,
       [99 Intev Unificar Filtros - TMA Tratado].OS_Externa,
       [99 Intev Unificar Filtros - TMA Tratado].OS_Acessante,
       Comp_Ocorrências.MULTA_OS,
       [1 Tabela_Intervenção].FEC,
       [1 Tabela_Intervenção].COD_LOC_COS,
       Segmentação_Lógica.Local,
       Segmentação_Lógica.COEC
FROM [1 Tabela_Intervenção]
  LEFT JOIN [Comp_Ocorrências] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI
  LEFT JOIN [Segmentação_Lógica] ON [1 Tabela_Intervenção].COD_LOC_COS = Segmentação_Lógica.[Cod Localidade]
  LEFT JOIN [99 Intev Unificar Filtros - TMA Tratado] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [99 Intev Unificar Filtros - TMA Tratado].NUM_SEQ_OPER_OS
  LEFT JOIN [14_6 Passo Cancelados Retirar] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = [14_6 Passo Cancelados Retirar].NUM_SEQ_OPER_OS_MNB
WHERE ((([14_6 Passo Cancelados Retirar].Cancelados) Is Null))
GROUP BY [1 Tabela_Intervenção].TIPO_OS, [1 Tabela_Intervenção].DTA_CMPT_MNB, [1 Tabela_Intervenção].COD_CPU_OS_MNB, [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB, [1 Tabela_Intervenção].NUM_SEQ_GER_OS_MNB, [1 Tabela_Intervenção].NOM_USU_PROGM_MNB, [1 Tabela_Intervenção].NOM_USU_CFER_MNB, [1 Tabela_Intervenção].NOM_USU_EXEC_MNB, [1 Tabela_Intervenção].COD_TIPO_ORIG_INTV_MNB, [1 Tabela_Intervenção].DES_ORIG_OGE, [1 Tabela_Intervenção].COD_ORIG_INTV_MNB, [1 Tabela_Intervenção].DES_ORIG_ORI, [1 Tabela_Intervenção].COD_CAUSA_MNB, [1 Tabela_Intervenção].DES_CAUSA_INTER_CAU, [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB, [1 Tabela_Intervenção].DES_SUB_CAUSA_INTER_SCR, [1 Tabela_Intervenção].NUM_CAUSA_ANEEL_MNB, [1 Tabela_Intervenção].NUM_SUB_CAUSA_ANEEL_MNB, [1 Tabela_Intervenção].DES_INTV_MNB, [1 Tabela_Intervenção].DTA_INIC_MNB, [1 Tabela_Intervenção].DTA_AVI_EQP_MNB, [1 Tabela_Intervenção].DTA_DLCT_EQP_MNB, [1 Tabela_Intervenção].DTA_VERI_EQP_MNB, [1 Tabela_Intervenção].DTA_SERV_EQP_MNB, [1 Tabela_Intervenção].DTA_FIM_MNB, [1 Tabela_Intervenção].COD_ELE_MNB, [1 Tabela_Intervenção].COD_INS_SEC_INS, [1 Tabela_Intervenção].COD_TIPO_CONCL_COS, [1 Tabela_Intervenção].COD_SUB_TIPO_OS_COS, [1 Tabela_Intervenção].TIPO_TR, [1 Tabela_Intervenção].TMA, [1 Tabela_Intervenção].DEC, [99 Intev Unificar Filtros - TMA Tratado].DIF_1ª_2ª_RCM_1h, [99 Intev Unificar Filtros - TMA Tratado].DIF_1ª_Man_1ª_OS_Vinc_2h, [99 Intev Unificar Filtros - TMA Tratado].TR_Próprio_OS_Proc, [99 Intev Unificar Filtros - TMA Tratado].Intev_Impro_Causa_Proc, [99 Intev Unificar Filtros - TMA Tratado].Intev_Proc_Causa_Impro, [99 Intev Unificar Filtros - TMA Tratado].[DEC_>_0,001], [99 Intev Unificar Filtros - TMA Tratado].TMD_0, [99 Intev Unificar Filtros - TMA Tratado].[TMA_>_1440], [99 Intev Unificar Filtros - TMA Tratado].[Intev_<_3_OS_Vinc_>_50_UCs], [99 Intev Unificar Filtros - TMA Tratado].Intev_S_OS_Vinc, [99 Intev Unificar Filtros - TMA Tratado].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [99 Intev Unificar Filtros - TMA Tratado].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [99 Intev Unificar Filtros - TMA Tratado].OS_Vinc_UCs_Interr, [99 Intev Unificar Filtros - TMA Tratado].Intev_0_UCs_Inter, [99 Intev Unificar Filtros - TMA Tratado].[Comp_>_500], [99 Intev Unificar Filtros - TMA Tratado].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [99 Intev Unificar Filtros - TMA Tratado].OS_Elemen_Particular_Proc, [99 Intev Unificar Filtros - TMA Tratado].[OS_Vinc_Hr_>_Ult_Passo], [99 Intev Unificar Filtros - TMA Tratado].OS_Impro_Sem_Elem_Partic, [99 Intev Unificar Filtros - TMA Tratado].Intv_TR_Zona_Div_UC, [99 Intev Unificar Filtros - TMA Tratado].OS_Externa, [99 Intev Unificar Filtros - TMA Tratado].OS_Acessante, Comp_Ocorrências.MULTA_OS, [1 Tabela_Intervenção].FEC, [1 Tabela_Intervenção].COD_LOC_COS, Segmentação_Lógica.Local, Segmentação_Lógica.COEC;

-- ===== 99 Intev Unificar - Filtros_Cruzamento_Backup  (SELECT)
SELECT [99 Intev Unificar - Filtros_Cruzamento].TIPO_OS,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_CMPT_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].COD_CPU_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NUM_SEQ_OPER_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NUM_SEQ_GER_OS_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NOM_USU_PROGM_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NOM_USU_CFER_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NOM_USU_EXEC_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].COD_TIPO_ORIG_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DES_ORIG_OGE,
       [99 Intev Unificar - Filtros_Cruzamento].COD_ORIG_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DES_ORIG_ORI,
       [99 Intev Unificar - Filtros_Cruzamento].COD_CAUSA_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DES_CAUSA_INTER_CAU,
       [99 Intev Unificar - Filtros_Cruzamento].COD_SUB_CAUSA_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DES_SUB_CAUSA_INTER_SCR,
       [99 Intev Unificar - Filtros_Cruzamento].NUM_CAUSA_ANEEL_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DES_INTV_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_INIC_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_AVI_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_DLCT_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_VERI_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_SERV_EQP_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].DTA_FIM_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].COD_ELE_MNB,
       [99 Intev Unificar - Filtros_Cruzamento].COD_INS_SEC_INS,
       [99 Intev Unificar - Filtros_Cruzamento].COD_TIPO_CONCL_COS,
       [99 Intev Unificar - Filtros_Cruzamento].COD_SUB_TIPO_OS_COS,
       [99 Intev Unificar - Filtros_Cruzamento].TIPO_TR,
       [99 Intev Unificar - Filtros_Cruzamento].TMA,
       [99 Intev Unificar - Filtros_Cruzamento].DEC,
       [99 Intev Unificar - Filtros_Cruzamento].DIF_1ª_2ª_RCM_1h,
       [99 Intev Unificar - Filtros_Cruzamento].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Intev Unificar - Filtros_Cruzamento].TR_Próprio_OS_Proc,
       [99 Intev Unificar - Filtros_Cruzamento].Intev_Impro_Causa_Proc,
       [99 Intev Unificar - Filtros_Cruzamento].Intev_Proc_Causa_Impro,
       [99 Intev Unificar - Filtros_Cruzamento].[DEC_>_0,001],
       [99 Intev Unificar - Filtros_Cruzamento].TMD_0,
       [99 Intev Unificar - Filtros_Cruzamento].[TMA_>_1440],
       [99 Intev Unificar - Filtros_Cruzamento].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Intev Unificar - Filtros_Cruzamento].Intev_S_OS_Vinc,
       [99 Intev Unificar - Filtros_Cruzamento].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Intev Unificar - Filtros_Cruzamento].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Intev Unificar - Filtros_Cruzamento].OS_Vinc_UCs_Interr,
       [99 Intev Unificar - Filtros_Cruzamento].Intev_0_UCs_Inter,
       [99 Intev Unificar - Filtros_Cruzamento].[Comp_>_500],
       [99 Intev Unificar - Filtros_Cruzamento].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Intev Unificar - Filtros_Cruzamento].OS_Elemen_Particular_Proc,
       [99 Intev Unificar - Filtros_Cruzamento].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Intev Unificar - Filtros_Cruzamento].OS_Impro_Sem_Elem_Partic,
       [99 Intev Unificar - Filtros_Cruzamento].Intv_TR_Zona_Div_UC,
       [99 Intev Unificar - Filtros_Cruzamento].OS_Externa,
       [99 Intev Unificar - Filtros_Cruzamento].OS_Acessante,
       [99 Intev Unificar - Filtros_Cruzamento].MULTA_OS,
       [99 Intev Unificar - Filtros_Cruzamento].FEC,
       [99 Intev Unificar - Filtros_Cruzamento].COD_LOC_COS,
       [99 Intev Unificar - Filtros_Cruzamento].Local,
       [99 Intev Unificar - Filtros_Cruzamento].COEC,
       [2 Intervenção Unificada - Filtros - Backup].[Correção Realizada],
       [2 Intervenção Unificada - Filtros - Backup].C_Classificação,
       [2 Intervenção Unificada - Filtros - Backup].[C_OS Vinculada],
       [2 Intervenção Unificada - Filtros - Backup].[C_Passo de Manobra],
       [2 Intervenção Unificada - Filtros - Backup].C_Horário,
       [2 Intervenção Unificada - Filtros - Backup].[C_Elemento Origem],
       [2 Intervenção Unificada - Filtros - Backup].USUÁRIO,
       [2 Intervenção Unificada - Filtros - Backup].OBSERVAÇÃO,
       [2 Intervenção Unificada - Filtros - Backup].STATUS,
       [2 Intervenção Unificada - Filtros - Backup].[DATA ANÁLISE],
       [2 Intervenção Unificada - Filtros - Backup].[DATA BAIXA]
FROM [99 Intev Unificar - Filtros_Cruzamento]
  LEFT JOIN [2 Intervenção Unificada - Filtros - Backup] ON [99 Intev Unificar - Filtros_Cruzamento].NUM_SEQ_OPER_OS_MNB = [2 Intervenção Unificada - Filtros - Backup].NUM_SEQ_OPER_OS_MNB;

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

-- ===== 99 Limpar Intev Unificar - Filtros  (DELETE)
DELETE [2 Intervenção Unificada - Filtros].DTA_CMPT_MNB, [2 Intervenção Unificada - Filtros].TIPO_OS, [2 Intervenção Unificada - Filtros].COD_CPU_OS_MNB, [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB, [2 Intervenção Unificada - Filtros].NUM_SEQ_GER_OS_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_PROGM_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_CFER_MNB, [2 Intervenção Unificada - Filtros].NOM_USU_EXEC_MNB, [2 Intervenção Unificada - Filtros].COD_TIPO_ORIG_INTV_MNB, [2 Intervenção Unificada - Filtros].DES_ORIG_OGE, [2 Intervenção Unificada - Filtros].COD_ORIG_INTV_MNB, [2 Intervenção Unificada - Filtros].DES_ORIG_ORI, [2 Intervenção Unificada - Filtros].COD_CAUSA_MNB, [2 Intervenção Unificada - Filtros].DES_CAUSA_INTER_CAU, [2 Intervenção Unificada - Filtros].COD_SUB_CAUSA_MNB, [2 Intervenção Unificada - Filtros].DES_SUB_CAUSA_INTER_SCR, [2 Intervenção Unificada - Filtros].NUM_CAUSA_ANEEL_MNB, [2 Intervenção Unificada - Filtros].NUM_SUB_CAUSA_ANEEL_MNB, [2 Intervenção Unificada - Filtros].DES_INTV_MNB, [2 Intervenção Unificada - Filtros].DTA_INIC_MNB, [2 Intervenção Unificada - Filtros].DTA_AVI_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_DLCT_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_VERI_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_SERV_EQP_MNB, [2 Intervenção Unificada - Filtros].DTA_FIM_MNB, [2 Intervenção Unificada - Filtros].COD_ELE_MNB, [2 Intervenção Unificada - Filtros].COD_INS_SEC_INS, [2 Intervenção Unificada - Filtros].COD_TIPO_CONCL_COS, [2 Intervenção Unificada - Filtros].COD_SUB_TIPO_OS_COS, [2 Intervenção Unificada - Filtros].TIPO_TR, [2 Intervenção Unificada - Filtros].TMA, [2 Intervenção Unificada - Filtros].DEC, [2 Intervenção Unificada - Filtros].DIF_1ª_2ª_RCM_1h, [2 Intervenção Unificada - Filtros].DIF_1ª_Man_1ª_OS_Vinc_2h, [2 Intervenção Unificada - Filtros].TR_Próprio_OS_Proc, [2 Intervenção Unificada - Filtros].Intev_Impro_Causa_Proc, [2 Intervenção Unificada - Filtros].Intev_Proc_Causa_Impro, [2 Intervenção Unificada - Filtros].[DEC_>_0,001], [2 Intervenção Unificada - Filtros].TMD_0, [2 Intervenção Unificada - Filtros].[TMA_>_1440], [2 Intervenção Unificada - Filtros].[Intev_<_3_OS_Vinc_>_50_UCs], [2 Intervenção Unificada - Filtros].Intev_S_OS_Vinc, [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min], [2 Intervenção Unificada - Filtros].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr], [2 Intervenção Unificada - Filtros].OS_Vinc_UCs_Interr, [2 Intervenção Unificada - Filtros].Intev_0_UCs_Inter, [2 Intervenção Unificada - Filtros].[Comp_>_500], [2 Intervenção Unificada - Filtros].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio, [2 Intervenção Unificada - Filtros].OS_Elemen_Particular_Proc, [2 Intervenção Unificada - Filtros].[OS_Vinc_Hr_>_Ult_Passo], [2 Intervenção Unificada - Filtros].OS_Impro_Sem_Elem_Partic, [2 Intervenção Unificada - Filtros].Intv_TR_Zona_Div_UC, [2 Intervenção Unificada - Filtros].OS_Externa, [2 Intervenção Unificada - Filtros].OS_Acessante, [2 Intervenção Unificada - Filtros].MULTA_OS, [2 Intervenção Unificada - Filtros].FEC, [2 Intervenção Unificada - Filtros].COD_LOC_COS, [2 Intervenção Unificada - Filtros].LOCALIDADE, [2 Intervenção Unificada - Filtros].COEC, [2 Intervenção Unificada - Filtros].[Correção Realizada], [2 Intervenção Unificada - Filtros].C_Classificação, [2 Intervenção Unificada - Filtros].[C_OS Vinculada], [2 Intervenção Unificada - Filtros].[C_Passo de Manobra], [2 Intervenção Unificada - Filtros].C_Horário, [2 Intervenção Unificada - Filtros].[C_Elemento Origem], [2 Intervenção Unificada - Filtros].USUÁRIO, [2 Intervenção Unificada - Filtros].OBSERVAÇÃO, [2 Intervenção Unificada - Filtros].STATUS, [2 Intervenção Unificada - Filtros].[DATA ANÁLISE], [2 Intervenção Unificada - Filtros].[DATA BAIXA]
FROM [2 Intervenção Unificada - Filtros];

-- ===== 99 Manobra  (SELECT)
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
       [1 Tabela_Manobra]![']*1 AS [QTD_UN_CONS_PNB],
       [1 Tabela_Manobra]![QTD_KVAS_PNB]*1 AS [QTD_KVAS_PNB],
       [1 Tabela_Manobra].COD_TIPO_MANO_PNB,
       [1 Tabela_Manobra]![NUM_SEQ_PNB]*1 AS [NUM_SEQ_PNB],
       [1 Tabela_Manobra]![NUM_PASSO_PNB]*1 AS [NUM_PASSO_PNB],
       [1 Tabela_Manobra].STA_EXEC_PNB,
       [1 Tabela_Manobra].STA_VIN_OS_PNB,
       [1 Tabela_Manobra].NUM_RET_MANO_PNB,
       [1 Tabela_Manobra].DES_PASSO_PNB,
       IIf([1 Tabela_Manobra]![DTA_PASSO_PNB] Is Null,Now(),[1 Tabela_Manobra]![DTA_PASSO_PNB]) AS [ORDENAR]
FROM [1 Tabela_Manobra];

-- ===== 99 Manobra - Ordenar  (SELECT)
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
       [1 Tabela_Manobra].NUM_SEQ_PNB,
       [1 Tabela_Manobra].NUM_PASSO_PNB,
       [1 Tabela_Manobra].STA_EXEC_PNB,
       [1 Tabela_Manobra].STA_VIN_OS_PNB,
       [1 Tabela_Manobra].NUM_RET_MANO_PNB,
       [1 Tabela_Manobra].DES_PASSO_PNB
FROM [1 Tabela_Manobra]
GROUP BY [1 Tabela_Manobra].TIPO_OS, [1 Tabela_Manobra].TIPO, [1 Tabela_Manobra].NUM_SEQ_OPER_OS_PNB, [1 Tabela_Manobra].COD_ELE_PNB, [1 Tabela_Manobra].COD_INS_SEC_INS, [1 Tabela_Manobra].TIPO_CHAVE, [1 Tabela_Manobra].COD_OPER_PNB, [1 Tabela_Manobra].DTA_PASSO_PNB, [1 Tabela_Manobra].DTA_PREV_PASSO_PNB, [1 Tabela_Manobra].QTD_UN_CONS_VIP_PNB, [1 Tabela_Manobra].QTD_UN_CONS_PNB, [1 Tabela_Manobra].QTD_KVAS_PNB, [1 Tabela_Manobra].COD_TIPO_MANO_PNB, [1 Tabela_Manobra].NUM_SEQ_PNB, [1 Tabela_Manobra].NUM_PASSO_PNB, [1 Tabela_Manobra].STA_EXEC_PNB, [1 Tabela_Manobra].STA_VIN_OS_PNB, [1 Tabela_Manobra].NUM_RET_MANO_PNB, [1 Tabela_Manobra].DES_PASSO_PNB
ORDER BY [1 Tabela_Manobra].DTA_PASSO_PNB, [1 Tabela_Manobra].NUM_SEQ_PNB;

-- ===== 99 OS_Analisada_Fora_Crítica  (SELECT)
SELECT "Pendente" AS [Pendente],
       Count([3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB) AS [OS_Analisada_Fora_Crítica]
FROM [3 T_OS_Analisada]
  LEFT JOIN [2 Intervenção Unificada - Filtros] ON [3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB = [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB
WHERE ((([2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY "Pendente";

-- ===== 99 OS_Corrigida_Fora_Crítica  (SELECT)
SELECT "Pendente" AS [Pendente],
       Count([3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB) AS [OS_Fora_Crítica]
FROM [3 OS_Corrigida]
  LEFT JOIN [2 Intervenção Unificada - Filtros] ON [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB = [2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB
WHERE ((([2 Intervenção Unificada - Filtros].NUM_SEQ_OPER_OS_MNB) Is Null))
GROUP BY "Pendente";

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

-- ===== B_OS_Analisadas  (SELECT)
SELECT [3 T_OS_Analisada].DTA_CMPT_MNB,
       [3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB
FROM [3 T_OS_Analisada]
GROUP BY [3 T_OS_Analisada].DTA_CMPT_MNB, [3 T_OS_Analisada].NUM_SEQ_OPER_OS_MNB;

-- ===== B_OS_Corrigidas  (SELECT)
SELECT [3 OS_Corrigida].DTA_CMPT_MNB,
       [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB
FROM [3 OS_Corrigida]
GROUP BY [3 OS_Corrigida].DTA_CMPT_MNB, [3 OS_Corrigida].NUM_SEQ_OPER_OS_MNB;

-- ===== Base de Ocorrências Pendentes  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS
FROM [99 Base Intervenção Unificada - Filtro];

-- ===== C_Base_Crítica  (SELECT)
SELECT Base_Crítica.DTA_CMPT_MNB,
       Base_Crítica.TIPO_OS,
       Base_Crítica.COD_CPU_OS_MNB,
       Base_Crítica.NUM_SEQ_OPER_OS_MNB,
       Base_Crítica.NUM_SEQ_GER_OS_MNB,
       Base_Crítica.NOM_USU_PROGM_MNB,
       Base_Crítica.NOM_USU_CFER_MNB,
       Base_Crítica.NOM_USU_EXEC_MNB,
       Base_Crítica.COD_TIPO_ORIG_INTV_MNB,
       Base_Crítica.DES_ORIG_OGE,
       Base_Crítica.COD_ORIG_INTV_MNB,
       Base_Crítica.DES_ORIG_ORI,
       Base_Crítica.COD_CAUSA_MNB,
       Base_Crítica.DES_CAUSA_INTER_CAU,
       Base_Crítica.COD_SUB_CAUSA_MNB,
       Base_Crítica.DES_SUB_CAUSA_INTER_SCR,
       Base_Crítica.NUM_CAUSA_ANEEL_MNB,
       Base_Crítica.NUM_SUB_CAUSA_ANEEL_MNB,
       Base_Crítica.DES_INTV_MNB,
       Base_Crítica.DTA_INIC_MNB,
       Base_Crítica.DTA_AVI_EQP_MNB,
       Base_Crítica.DTA_DLCT_EQP_MNB,
       Base_Crítica.DTA_VERI_EQP_MNB,
       Base_Crítica.DTA_SERV_EQP_MNB,
       Base_Crítica.DTA_FIM_MNB,
       Base_Crítica.COD_ELE_MNB,
       Base_Crítica.COD_INS_SEC_INS,
       Base_Crítica.QTD_KVAS_PNB,
       Base_Crítica.NUM_PASSO_PNB,
       Base_Crítica.NUM_RET_MANO_PNB,
       Base_Crítica.COD_TIPO_CONCL_COS,
       Base_Crítica.COD_SUB_TIPO_OS_COS,
       Base_Crítica.TIPO_TR,
       Base_Crítica.TMA,
       Base_Crítica.DEC,
       Base_Crítica.COD_TIPO_LOC_CNR,
       Base_Crítica.TIPO_LOC_CNR,
       Base_Crítica.DES_ENDE_UN_CONS_CNR,
       Base_Crítica.DES_OBS_EXEC_SERV_CNR,
       Base_Crítica.INTERV,
       Base_Crítica.FEC,
       Base_Crítica.COD_LOC_COS
FROM [Base_Crítica];

-- ===== F_Filtro_1  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h)<>""));

-- ===== F_Filtro_10  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc)<>""));

-- ===== F_Filtro_11  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min])<>""));

-- ===== F_Filtro_12  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr])<>""));

-- ===== F_Filtro_13  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr)<>""));

-- ===== F_Filtro_14  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter)<>""));

-- ===== F_Filtro_15  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Comp_>_500])<>""));

-- ===== F_Filtro_16  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio)<>""));

-- ===== F_Filtro_17  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc)<>""));

-- ===== F_Filtro_18  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic)<>""));

-- ===== F_Filtro_19  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo])<>""));

-- ===== F_Filtro_2  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h)<>""));

-- ===== F_Filtro_20  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC)<>""));

-- ===== F_Filtro_21  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Externa)<>""));

-- ===== F_Filtro_22  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].OS_Acessante)<>""));

-- ===== F_Filtro_23  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       IIf([99 Base Intervenção Unificada - Filtro]![DIF_1ª_2ª_RCM_1h]="","-",[99 Base Intervenção Unificada - Filtro]![DIF_1ª_2ª_RCM_1h]) AS [DIF_1ª_2ª_RCM_1h],
       IIf([99 Base Intervenção Unificada - Filtro]![DIF_1ª_Man_1ª_OS_Vinc_2h]="","-",[99 Base Intervenção Unificada - Filtro]![DIF_1ª_Man_1ª_OS_Vinc_2h]) AS [DIF_1ª_Man_1ª_OS_Vinc_2h],
       IIf([99 Base Intervenção Unificada - Filtro]![TR_Próprio_OS_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![TR_Próprio_OS_Proc]) AS [TR_Próprio_OS_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_Impro_Causa_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_Impro_Causa_Proc]) AS [Intev_Impro_Causa_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_Proc_Causa_Impro]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_Proc_Causa_Impro]) AS [Intev_Proc_Causa_Impro],
       IIf([99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]="","-",[99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]) AS [DEC_>_0,001],
       IIf([99 Base Intervenção Unificada - Filtro]![TMD_0]="","-",[99 Base Intervenção Unificada - Filtro]![TMD_0]) AS [TMD_0],
       IIf([99 Base Intervenção Unificada - Filtro]![TMA_>_1440]="","-",[99 Base Intervenção Unificada - Filtro]![TMA_>_1440]) AS [TMA_>_1440],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_<_3_OS_Vinc_>_50_UCs]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_<_3_OS_Vinc_>_50_UCs]) AS [Intev_<_3_OS_Vinc_>_50_UCs],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_S_OS_Vinc]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_S_OS_Vinc]) AS [Intev_S_OS_Vinc],
       IIf([99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]="","-",[99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]) AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       IIf([99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]="","-",[99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]) AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Vinc_UCs_Interr]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Vinc_UCs_Interr]) AS [OS_Vinc_UCs_Interr],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_0_UCs_Inter]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_0_UCs_Inter]) AS [Intev_0_UCs_Inter],
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       IIf([99 Base Intervenção Unificada - Filtro]![Comp_>_500]="","-",[99 Base Intervenção Unificada - Filtro]![Comp_>_500]) AS [Comp_>_500],
       IIf([99 Base Intervenção Unificada - Filtro]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]="","-",[99 Base Intervenção Unificada - Filtro]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]) AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Elemen_Particular_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Elemen_Particular_Proc]) AS [OS_Elemen_Particular_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Vinc_Hr_>_Ult_Passo]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Vinc_Hr_>_Ult_Passo]) AS [OS_Vinc_Hr_>_Ult_Passo],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Impro_Sem_Elem_Partic]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Impro_Sem_Elem_Partic]) AS [OS_Impro_Sem_Elem_Partic],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       IIf([99 Base Intervenção Unificada - Filtro]![Intv_TR_Zona_Div_UC] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![Intv_TR_Zona_Div_UC]) AS [Intv_TR_Zona_Div_UC],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Externa] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![OS_Externa]) AS [OS_Externa],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Acessante] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![OS_Acessante]) AS [OS_Acessante],
       [DIF_1ª_2ª_RCM_1h] & [DIF_1ª_Man_1ª_OS_Vinc_2h] & [TR_Próprio_OS_Proc] & [Intev_Impro_Causa_Proc] & [DEC_>_0,001] & [TMD_0] & [TMA_>_1440] & [Intev_<_3_OS_Vinc_>_50_UCs] & [Intev_S_OS_Vinc] & [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min] & [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr] & [OS_Vinc_UCs_Interr] & [Intev_0_UCs_Inter] & [Comp_>_500] & [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio] & [OS_Elemen_Particular_Proc] & [OS_Vinc_Hr_>_Ult_Passo] & [OS_Impro_Sem_Elem_Partic] & [Intv_TR_Zona_Div_UC] & [OS_Externa] & [OS_Acessante] AS [C]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE (((IIf([99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]="","-",[99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]))<>"-"));

-- ===== F_Filtro_23_2  (SELECT)
SELECT F_Filtro_23.TIPO_OS,
       F_Filtro_23.COD_CPU_OS_MNB,
       F_Filtro_23.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_23.NUM_SEQ_GER_OS_MNB,
       F_Filtro_23.NOM_USU_PROGM_MNB,
       F_Filtro_23.NOM_USU_CFER_MNB,
       F_Filtro_23.NOM_USU_EXEC_MNB,
       F_Filtro_23.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_23.DES_ORIG_OGE,
       F_Filtro_23.COD_ORIG_INTV_MNB,
       F_Filtro_23.DES_ORIG_ORI,
       F_Filtro_23.COD_CAUSA_MNB,
       F_Filtro_23.DES_CAUSA_INTER_CAU,
       F_Filtro_23.COD_SUB_CAUSA_MNB,
       F_Filtro_23.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_23.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_23.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_23.DES_INTV_MNB,
       F_Filtro_23.DTA_INIC_MNB,
       F_Filtro_23.DTA_AVI_EQP_MNB,
       F_Filtro_23.DTA_DLCT_EQP_MNB,
       F_Filtro_23.DTA_VERI_EQP_MNB,
       F_Filtro_23.DTA_SERV_EQP_MNB,
       F_Filtro_23.DTA_FIM_MNB,
       F_Filtro_23.COD_ELE_MNB,
       F_Filtro_23.COD_INS_SEC_INS,
       F_Filtro_23.COD_TIPO_CONCL_COS,
       F_Filtro_23.COD_SUB_TIPO_OS_COS,
       F_Filtro_23.TIPO_TR,
       F_Filtro_23.TMA,
       F_Filtro_23.DEC,
       F_Filtro_23.DIF_1ª_2ª_RCM_1h,
       F_Filtro_23.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_23.TR_Próprio_OS_Proc,
       F_Filtro_23.Intev_Impro_Causa_Proc,
       F_Filtro_23.Intev_Proc_Causa_Impro,
       F_Filtro_23.[DEC_>_0,001],
       F_Filtro_23.TMD_0,
       F_Filtro_23.[TMA_>_1440],
       F_Filtro_23.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_23.Intev_S_OS_Vinc,
       F_Filtro_23.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_23.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_23.OS_Vinc_UCs_Interr,
       F_Filtro_23.Intev_0_UCs_Inter,
       F_Filtro_23.[Correção Realizada],
       F_Filtro_23.[Comp_>_500],
       F_Filtro_23.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_23.OS_Elemen_Particular_Proc,
       F_Filtro_23.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_23.OS_Impro_Sem_Elem_Partic,
       F_Filtro_23.FEC,
       F_Filtro_23.COD_LOC_COS,
       F_Filtro_23.LOCALIDADE,
       F_Filtro_23.COEC,
       F_Filtro_23.MULTA_OS,
       F_Filtro_23.Concat,
       F_Filtro_23.C_Classificação,
       F_Filtro_23.[C_OS Vinculada],
       F_Filtro_23.[C_Passo de Manobra],
       F_Filtro_23.C_Horário,
       F_Filtro_23.[C_Elemento Origem],
       F_Filtro_23.USUÁRIO,
       F_Filtro_23.OBSERVAÇÃO,
       F_Filtro_23.STATUS,
       F_Filtro_23.[DATA ANÁLISE],
       F_Filtro_23.[DATA BAIXA],
       F_Filtro_23.ID,
       F_Filtro_23.Intv_TR_Zona_Div_UC,
       F_Filtro_23.OS_Externa,
       F_Filtro_23.OS_Acessante,
       F_Filtro_23.C
FROM F_Filtro_23
WHERE (((F_Filtro_23.C)="----Verificar--------------"));

-- ===== F_Filtro_3  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc)<>""));

-- ===== F_Filtro_4  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc)<>""));

-- ===== F_Filtro_5  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro)<>""));

-- ===== F_Filtro_6  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       IIf([99 Base Intervenção Unificada - Filtro]![DIF_1ª_2ª_RCM_1h]="","-",[99 Base Intervenção Unificada - Filtro]![DIF_1ª_2ª_RCM_1h]) AS [DIF_1ª_2ª_RCM_1h],
       IIf([99 Base Intervenção Unificada - Filtro]![DIF_1ª_Man_1ª_OS_Vinc_2h]="","-",[99 Base Intervenção Unificada - Filtro]![DIF_1ª_Man_1ª_OS_Vinc_2h]) AS [DIF_1ª_Man_1ª_OS_Vinc_2h],
       IIf([99 Base Intervenção Unificada - Filtro]![TR_Próprio_OS_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![TR_Próprio_OS_Proc]) AS [TR_Próprio_OS_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_Impro_Causa_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_Impro_Causa_Proc]) AS [Intev_Impro_Causa_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_Proc_Causa_Impro]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_Proc_Causa_Impro]) AS [Intev_Proc_Causa_Impro],
       IIf([99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]="","-",[99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]) AS [DEC_>_0,001],
       IIf([99 Base Intervenção Unificada - Filtro]![TMD_0]="","-",[99 Base Intervenção Unificada - Filtro]![TMD_0]) AS [TMD_0],
       IIf([99 Base Intervenção Unificada - Filtro]![TMA_>_1440]="","-",[99 Base Intervenção Unificada - Filtro]![TMA_>_1440]) AS [TMA_>_1440],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_<_3_OS_Vinc_>_50_UCs]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_<_3_OS_Vinc_>_50_UCs]) AS [Intev_<_3_OS_Vinc_>_50_UCs],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_S_OS_Vinc]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_S_OS_Vinc]) AS [Intev_S_OS_Vinc],
       IIf([99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]="","-",[99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_=_1_min]) AS [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       IIf([99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]="","-",[99 Base Intervenção Unificada - Filtro]![Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr]) AS [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Vinc_UCs_Interr]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Vinc_UCs_Interr]) AS [OS_Vinc_UCs_Interr],
       IIf([99 Base Intervenção Unificada - Filtro]![Intev_0_UCs_Inter]="","-",[99 Base Intervenção Unificada - Filtro]![Intev_0_UCs_Inter]) AS [Intev_0_UCs_Inter],
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       IIf([99 Base Intervenção Unificada - Filtro]![Comp_>_500]="","-",[99 Base Intervenção Unificada - Filtro]![Comp_>_500]) AS [Comp_>_500],
       IIf([99 Base Intervenção Unificada - Filtro]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]="","-",[99 Base Intervenção Unificada - Filtro]![Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio]) AS [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Elemen_Particular_Proc]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Elemen_Particular_Proc]) AS [OS_Elemen_Particular_Proc],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Vinc_Hr_>_Ult_Passo]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Vinc_Hr_>_Ult_Passo]) AS [OS_Vinc_Hr_>_Ult_Passo],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Impro_Sem_Elem_Partic]="","-",[99 Base Intervenção Unificada - Filtro]![OS_Impro_Sem_Elem_Partic]) AS [OS_Impro_Sem_Elem_Partic],
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       IIf([99 Base Intervenção Unificada - Filtro]![Intv_TR_Zona_Div_UC] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![Intv_TR_Zona_Div_UC]) AS [Intv_TR_Zona_Div_UC],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Externa] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![OS_Externa]) AS [OS_Externa],
       IIf([99 Base Intervenção Unificada - Filtro]![OS_Acessante] Is Null,"-",[99 Base Intervenção Unificada - Filtro]![OS_Acessante]) AS [OS_Acessante],
       [DIF_1ª_2ª_RCM_1h] & [DIF_1ª_Man_1ª_OS_Vinc_2h] & [TR_Próprio_OS_Proc] & [Intev_Impro_Causa_Proc] & [DEC_>_0,001] & [TMD_0] & [TMA_>_1440] & [Intev_<_3_OS_Vinc_>_50_UCs] & [Intev_S_OS_Vinc] & [Tempo_Hr_Inic_Hr_1º_Passo_=_1_min] & [Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr] & [OS_Vinc_UCs_Interr] & [Intev_0_UCs_Inter] & [Comp_>_500] & [Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio] & [OS_Elemen_Particular_Proc] & [OS_Vinc_Hr_>_Ult_Passo] & [OS_Impro_Sem_Elem_Partic] & [Intv_TR_Zona_Div_UC] & [OS_Externa] & [OS_Acessante] AS [C]
FROM [99 Base Intervenção Unificada - Filtro]
WHERE (((IIf([99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]="","-",[99 Base Intervenção Unificada - Filtro]![DEC_>_0,001]))<>"-"));

-- ===== F_Filtro_6_2  (SELECT)
SELECT F_Filtro_6.TIPO_OS,
       F_Filtro_6.COD_CPU_OS_MNB,
       F_Filtro_6.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_6.NUM_SEQ_GER_OS_MNB,
       F_Filtro_6.NOM_USU_PROGM_MNB,
       F_Filtro_6.NOM_USU_CFER_MNB,
       F_Filtro_6.NOM_USU_EXEC_MNB,
       F_Filtro_6.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_6.DES_ORIG_OGE,
       F_Filtro_6.COD_ORIG_INTV_MNB,
       F_Filtro_6.DES_ORIG_ORI,
       F_Filtro_6.COD_CAUSA_MNB,
       F_Filtro_6.DES_CAUSA_INTER_CAU,
       F_Filtro_6.COD_SUB_CAUSA_MNB,
       F_Filtro_6.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_6.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_6.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_6.DES_INTV_MNB,
       F_Filtro_6.DTA_INIC_MNB,
       F_Filtro_6.DTA_AVI_EQP_MNB,
       F_Filtro_6.DTA_DLCT_EQP_MNB,
       F_Filtro_6.DTA_VERI_EQP_MNB,
       F_Filtro_6.DTA_SERV_EQP_MNB,
       F_Filtro_6.DTA_FIM_MNB,
       F_Filtro_6.COD_ELE_MNB,
       F_Filtro_6.COD_INS_SEC_INS,
       F_Filtro_6.COD_TIPO_CONCL_COS,
       F_Filtro_6.COD_SUB_TIPO_OS_COS,
       F_Filtro_6.TIPO_TR,
       F_Filtro_6.TMA,
       F_Filtro_6.DEC,
       F_Filtro_6.DIF_1ª_2ª_RCM_1h,
       F_Filtro_6.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_6.TR_Próprio_OS_Proc,
       F_Filtro_6.Intev_Impro_Causa_Proc,
       F_Filtro_6.Intev_Proc_Causa_Impro,
       F_Filtro_6.[DEC_>_0,001],
       F_Filtro_6.TMD_0,
       F_Filtro_6.[TMA_>_1440],
       F_Filtro_6.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_6.Intev_S_OS_Vinc,
       F_Filtro_6.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_6.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_6.OS_Vinc_UCs_Interr,
       F_Filtro_6.Intev_0_UCs_Inter,
       F_Filtro_6.[Correção Realizada],
       F_Filtro_6.[Comp_>_500],
       F_Filtro_6.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_6.OS_Elemen_Particular_Proc,
       F_Filtro_6.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_6.OS_Impro_Sem_Elem_Partic,
       F_Filtro_6.FEC,
       F_Filtro_6.COD_LOC_COS,
       F_Filtro_6.LOCALIDADE,
       F_Filtro_6.COEC,
       F_Filtro_6.MULTA_OS,
       F_Filtro_6.Concat,
       F_Filtro_6.C_Classificação,
       F_Filtro_6.[C_OS Vinculada],
       F_Filtro_6.[C_Passo de Manobra],
       F_Filtro_6.C_Horário,
       F_Filtro_6.[C_Elemento Origem],
       F_Filtro_6.USUÁRIO,
       F_Filtro_6.OBSERVAÇÃO,
       F_Filtro_6.STATUS,
       F_Filtro_6.[DATA ANÁLISE],
       F_Filtro_6.[DATA BAIXA],
       F_Filtro_6.ID,
       F_Filtro_6.Intv_TR_Zona_Div_UC,
       F_Filtro_6.OS_Externa,
       F_Filtro_6.OS_Acessante,
       F_Filtro_6.C
FROM F_Filtro_6
WHERE (((F_Filtro_6.C) Not In ("----Verificar--------------")));

-- ===== F_Filtro_7  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].TMD_0)<>""));

-- ===== F_Filtro_8  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[TMA_>_1440])<>""));

-- ===== F_Filtro_9  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_CONCL_COS,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       [99 Base Intervenção Unificada - Filtro].TMA,
       [99 Base Intervenção Unificada - Filtro].DEC,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].FEC,
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       [99 Base Intervenção Unificada - Filtro].MULTA_OS,
       [99 Base Intervenção Unificada - Filtro].Concat,
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA],
       ([99 Base Intervenção Unificada - Filtro]![DEC])*1 AS [ID],
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante
FROM [99 Base Intervenção Unificada - Filtro]
WHERE ((([99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs])<>""));

-- ===== OS Individual Pro com TR Proprio  (SELECT)
SELECT [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR,
       [1 Tabela Ocorrência_Individual].COD_TIPO_CONCL_CNR,
       [1 Tabela Ocorrência_Individual].TIPO_TR,
       "Verificar" AS [STATUS]
FROM [1 Tabela Ocorrência_Individual]
WHERE ((([1 Tabela Ocorrência_Individual].COD_TIPO_CONCL_CNR)="000") AND (([1 Tabela Ocorrência_Individual].TIPO_TR)<>"ENERGISA"));

-- ===== OS Individual com Texto de Intervenção  (SELECT)
SELECT [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR,
       [1 Tabela Ocorrência_Individual].DES_OBS_EXEC_SERV_CNR,
       "Verificar" AS [STATUS]
FROM [1 Tabela Ocorrência_Individual]
WHERE ((([1 Tabela Ocorrência_Individual].INTERV) Is Not Null))
GROUP BY [1 Tabela Ocorrência_Individual].NUM_SEQ_OPER_CNR, [1 Tabela Ocorrência_Individual].DES_OBS_EXEC_SERV_CNR, "Verificar";

-- ===== OSs Aguardando Confirmação  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro Ag Retorno].USUÁRIO AS [RESPONSÁVEL],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].NUM_SEQ_OPER_OS_MNB AS [NUM_OS],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro Ag Retorno].COEC,
       IIf([COD_TIPO_CONCL_COS]="000","PRO","IMPRO") AS [CONCLUSÃO],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].TMA,
       [99 Base Intervenção Unificada - Filtro Ag Retorno].DEC,
       [99 Base Intervenção Unificada - Filtro Ag Retorno].MULTA_OS AS [COMPENSAÇÃO],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].[DATA ANÁLISE] AS [ENVIO_COBRANÇA],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].STATUS AS [PENDÊNCIA],
       [99 Base Intervenção Unificada - Filtro Ag Retorno].OBSERVAÇÃO
FROM [99 Base Intervenção Unificada - Filtro Ag Retorno];

-- ===== l_Base_Crítica  (DELETE)
DELETE [0 Base_Crítica].DTA_CMPT_MNB, [0 Base_Crítica].TIPO_OS, [0 Base_Crítica].COD_CPU_OS_MNB, [0 Base_Crítica].NUM_SEQ_OPER_OS_MNB, [0 Base_Crítica].NUM_SEQ_GER_OS_MNB, [0 Base_Crítica].NOM_USU_PROGM_MNB, [0 Base_Crítica].NOM_USU_CFER_MNB, [0 Base_Crítica].NOM_USU_EXEC_MNB, [0 Base_Crítica].COD_TIPO_ORIG_INTV_MNB, [0 Base_Crítica].DES_ORIG_OGE, [0 Base_Crítica].COD_ORIG_INTV_MNB, [0 Base_Crítica].DES_ORIG_ORI, [0 Base_Crítica].COD_CAUSA_MNB, [0 Base_Crítica].DES_CAUSA_INTER_CAU, [0 Base_Crítica].COD_SUB_CAUSA_MNB, [0 Base_Crítica].DES_SUB_CAUSA_INTER_SCR, [0 Base_Crítica].NUM_CAUSA_ANEEL_MNB, [0 Base_Crítica].NUM_SUB_CAUSA_ANEEL_MNB, [0 Base_Crítica].DES_INTV_MNB, [0 Base_Crítica].DTA_INIC_MNB, [0 Base_Crítica].DTA_AVI_EQP_MNB, [0 Base_Crítica].DTA_DLCT_EQP_MNB, [0 Base_Crítica].DTA_VERI_EQP_MNB, [0 Base_Crítica].DTA_SERV_EQP_MNB, [0 Base_Crítica].DTA_FIM_MNB, [0 Base_Crítica].COD_ELE_MNB, [0 Base_Crítica].COD_INS_SEC_INS, [0 Base_Crítica].QTD_KVAS_PNB, [0 Base_Crítica].NUM_PASSO_PNB, [0 Base_Crítica].NUM_RET_MANO_PNB, [0 Base_Crítica].COD_TIPO_CONCL_COS, [0 Base_Crítica].COD_SUB_TIPO_OS_COS, [0 Base_Crítica].TIPO_TR, [0 Base_Crítica].TMA, [0 Base_Crítica].DEC, [0 Base_Crítica].COD_TIPO_LOC_CNR, [0 Base_Crítica].TIPO_LOC_CNR, [0 Base_Crítica].DES_ENDE_UN_CONS_CNR, [0 Base_Crítica].DES_OBS_EXEC_SERV_CNR, [0 Base_Crítica].INTERV, [0 Base_Crítica].FEC, [0 Base_Crítica].COD_LOC_COS
FROM [0 Base_Crítica];

-- ===== ~sq_c0 F_Individual~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [0 F_Individual]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_c0 F_Individual~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [0 F_Individual]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_c0 F_Intervenção_Aguard_Retor~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [0 F_Intervenção_Aguard_Retor]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_10_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_10_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_10_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_10_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_10_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_10_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_11_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_11_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_11_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_11_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_11_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_11_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_11_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_11_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_12_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_12_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_12_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_12_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_12_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_12_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_13_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_13_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_13_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_13_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_13_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_13_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_13_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_13_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_14_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_14_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_14_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_14_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_14_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_14_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_15_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_15_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_15_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_15_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_15_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_15_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_16_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_16_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_16_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_16_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_16_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_16_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_17_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_17_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_17_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_17_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_17_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_17_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_17_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_17_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_18_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_18_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_18_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_18_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_18_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_18_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_18_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_18_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_19_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_19_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_19_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_19_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_19_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_19_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_19_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_19_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_1_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_1_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_1_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_1_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_1_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_1_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_1_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_1_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_1_~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_1_
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_1_~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_1_
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_1_~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_1_~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_1_~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_1_
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_20_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_20_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_20_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_20_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_20_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_20_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_20_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_20_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_21_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_21_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_21_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_21_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_21_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_21_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_22_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_22_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_22_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_22_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_22_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_22_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_23_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_23_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_23_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_23_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_23_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_23_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_2_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_2_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_2_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_2_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_2_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_2_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_2_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_2_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_3_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_3_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_3_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_3_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_3_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_3_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_3_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_3_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_4_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_4_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_4_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_4_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_4_F~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Filtro_4_F~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Filtro_4_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_4_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_5_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_5_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_5_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_5_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_5_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_5_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_6_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_6_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_6_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_6_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_6_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_6_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_7_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_7_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_7_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_7_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_7_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_7_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_8_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_8_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_8_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_8_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_8_F~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_8_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_9_F~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS F_Filtro_9_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Filtro_9_F~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_9_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Filtro_9_F~sq_cFilho6674耀前2KeepLocal
਀T  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS F_Filtro_9_F
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Intervenção_Buscar~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [F_Intervenção_Buscar]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Intervenção_Buscar~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [F_Intervenção_Buscar]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Intervenção~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS [F_Intervenção]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cF_Intervenção~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [F_Intervenção]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cF_Intervenção~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cF_Intervenção~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cF_Intervenção~sq_cFilho537  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [9 Union Filtros].NUM_SEQ_OPER_OS_MNB, [9 Union Filtros].Análise FROM [9 Union Filtros]) AS [F_Intervenção]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_MNB);

-- ===== ~sq_cF_Intervenção~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS [F_Intervenção]
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cX~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS X
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cX~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS X
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cX~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cX~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cX~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS X
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cxx~sq_c0 OS Vinculadas Intervenção subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [0 OS Vinculadas Intervenção].NUM_SEQ_OPER_INTER_CNR, [0 OS Vinculadas Intervenção].OS FROM [0 OS Vinculadas Intervenção]) AS xx
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_INTER_CNR);

-- ===== ~sq_cxx~sq_c1 Tabela_Manobra subformulário  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS xx
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_cxx~sq_cCombinação761  (SELECT)
SELECT 
FROM T_Analistas;

-- ===== ~sq_cxx~sq_cCombinação767  (SELECT)
SELECT 
FROM T_Status_OS;

-- ===== ~sq_cxx~sq_cFilho667  (SELECT)
PARAMETERS __NUM_SEQ_OPER_OS_MNB;
SELECT 
FROM (SELECT [99 Manobra].TIPO_OS, [99 Manobra].TIPO, [99 Manobra].NUM_SEQ_OPER_OS_PNB, [99 Manobra].COD_ELE_PNB, [99 Manobra].COD_INS_SEC_INS, [99 Manobra].TIPO_CHAVE, [99 Manobra].COD_OPER_PNB, [99 Manobra].DTA_PASSO_PNB, [99 Manobra].DTA_PREV_PASSO_PNB, [99 Manobra].QTD_UN_CONS_VIP_PNB, [99 Manobra].QTD_UN_CONS_PNB, [99 Manobra].QTD_KVAS_PNB, [99 Manobra].COD_TIPO_MANO_PNB, [99 Manobra].NUM_PASSO_PNB, [99 Manobra].STA_EXEC_PNB, [99 Manobra].STA_VIN_OS_PNB, [99 Manobra].NUM_RET_MANO_PNB, [99 Manobra].DES_PASSO_PNB, [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB FROM [99 Manobra] ORDER BY [99 Manobra].ORDENAR, [99 Manobra].NUM_SEQ_PNB) AS xx
WHERE ([__NUM_SEQ_OPER_OS_MNB] = NUM_SEQ_OPER_OS_PNB);

-- ===== ~sq_fF_Atualização  (SELECT)
SELECT T_Analistas.NOME
FROM T_Analistas;

-- ===== ~sq_fF_Filtro_11_F  (SELECT)
SELECT F_Filtro_11.TIPO_OS,
       F_Filtro_11.COD_CPU_OS_MNB,
       F_Filtro_11.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_11.NUM_SEQ_GER_OS_MNB,
       F_Filtro_11.NOM_USU_PROGM_MNB,
       F_Filtro_11.NOM_USU_CFER_MNB,
       F_Filtro_11.NOM_USU_EXEC_MNB,
       F_Filtro_11.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_11.DES_ORIG_OGE,
       F_Filtro_11.COD_ORIG_INTV_MNB,
       F_Filtro_11.DES_ORIG_ORI,
       F_Filtro_11.COD_CAUSA_MNB,
       F_Filtro_11.DES_CAUSA_INTER_CAU,
       F_Filtro_11.COD_SUB_CAUSA_MNB,
       F_Filtro_11.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_11.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_11.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_11.DES_INTV_MNB,
       F_Filtro_11.DTA_INIC_MNB,
       F_Filtro_11.DTA_AVI_EQP_MNB,
       F_Filtro_11.DTA_DLCT_EQP_MNB,
       F_Filtro_11.DTA_VERI_EQP_MNB,
       F_Filtro_11.DTA_SERV_EQP_MNB,
       F_Filtro_11.DTA_FIM_MNB,
       F_Filtro_11.COD_ELE_MNB,
       F_Filtro_11.COD_INS_SEC_INS,
       F_Filtro_11.COD_TIPO_CONCL_COS,
       F_Filtro_11.COD_SUB_TIPO_OS_COS,
       F_Filtro_11.TIPO_TR,
       F_Filtro_11.TMA,
       F_Filtro_11.DEC,
       F_Filtro_11.DIF_1ª_2ª_RCM_1h,
       F_Filtro_11.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_11.TR_Próprio_OS_Proc,
       F_Filtro_11.Intev_Impro_Causa_Proc,
       F_Filtro_11.Intev_Proc_Causa_Impro,
       F_Filtro_11.[DEC_>_0,001],
       F_Filtro_11.TMD_0,
       F_Filtro_11.[TMA_>_1440],
       F_Filtro_11.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_11.Intev_S_OS_Vinc,
       F_Filtro_11.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_11.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_11.OS_Vinc_UCs_Interr,
       F_Filtro_11.Intev_0_UCs_Inter,
       F_Filtro_11.[Correção Realizada],
       F_Filtro_11.[Comp_>_500],
       F_Filtro_11.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_11.OS_Elemen_Particular_Proc,
       F_Filtro_11.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_11.OS_Impro_Sem_Elem_Partic,
       F_Filtro_11.FEC,
       F_Filtro_11.COD_LOC_COS,
       F_Filtro_11.LOCALIDADE,
       F_Filtro_11.COEC,
       F_Filtro_11.MULTA_OS,
       F_Filtro_11.Concat,
       F_Filtro_11.C_Classificação,
       F_Filtro_11.[C_OS Vinculada],
       F_Filtro_11.[C_Passo de Manobra],
       F_Filtro_11.C_Horário,
       F_Filtro_11.[C_Elemento Origem],
       F_Filtro_11.USUÁRIO,
       F_Filtro_11.OBSERVAÇÃO,
       F_Filtro_11.STATUS,
       F_Filtro_11.[DATA ANÁLISE],
       F_Filtro_11.[DATA BAIXA],
       F_Filtro_11.ID
FROM F_Filtro_11
ORDER BY F_Filtro_11.ID DESC;

-- ===== ~sq_fF_Filtro_13_F  (SELECT)
SELECT F_Filtro_13.TIPO_OS,
       F_Filtro_13.COD_CPU_OS_MNB,
       F_Filtro_13.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_13.NUM_SEQ_GER_OS_MNB,
       F_Filtro_13.NOM_USU_PROGM_MNB,
       F_Filtro_13.NOM_USU_CFER_MNB,
       F_Filtro_13.NOM_USU_EXEC_MNB,
       F_Filtro_13.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_13.DES_ORIG_OGE,
       F_Filtro_13.COD_ORIG_INTV_MNB,
       F_Filtro_13.DES_ORIG_ORI,
       F_Filtro_13.COD_CAUSA_MNB,
       F_Filtro_13.DES_CAUSA_INTER_CAU,
       F_Filtro_13.COD_SUB_CAUSA_MNB,
       F_Filtro_13.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_13.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_13.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_13.DES_INTV_MNB,
       F_Filtro_13.DTA_INIC_MNB,
       F_Filtro_13.DTA_AVI_EQP_MNB,
       F_Filtro_13.DTA_DLCT_EQP_MNB,
       F_Filtro_13.DTA_VERI_EQP_MNB,
       F_Filtro_13.DTA_SERV_EQP_MNB,
       F_Filtro_13.DTA_FIM_MNB,
       F_Filtro_13.COD_ELE_MNB,
       F_Filtro_13.COD_INS_SEC_INS,
       F_Filtro_13.COD_TIPO_CONCL_COS,
       F_Filtro_13.COD_SUB_TIPO_OS_COS,
       F_Filtro_13.TIPO_TR,
       F_Filtro_13.TMA,
       F_Filtro_13.DEC,
       F_Filtro_13.DIF_1ª_2ª_RCM_1h,
       F_Filtro_13.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_13.TR_Próprio_OS_Proc,
       F_Filtro_13.Intev_Impro_Causa_Proc,
       F_Filtro_13.Intev_Proc_Causa_Impro,
       F_Filtro_13.[DEC_>_0,001],
       F_Filtro_13.TMD_0,
       F_Filtro_13.[TMA_>_1440],
       F_Filtro_13.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_13.Intev_S_OS_Vinc,
       F_Filtro_13.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_13.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_13.OS_Vinc_UCs_Interr,
       F_Filtro_13.Intev_0_UCs_Inter,
       F_Filtro_13.[Correção Realizada],
       F_Filtro_13.[Comp_>_500],
       F_Filtro_13.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_13.OS_Elemen_Particular_Proc,
       F_Filtro_13.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_13.OS_Impro_Sem_Elem_Partic,
       F_Filtro_13.FEC,
       F_Filtro_13.COD_LOC_COS,
       F_Filtro_13.LOCALIDADE,
       F_Filtro_13.COEC,
       F_Filtro_13.MULTA_OS,
       F_Filtro_13.Concat,
       F_Filtro_13.C_Classificação,
       F_Filtro_13.[C_OS Vinculada],
       F_Filtro_13.[C_Passo de Manobra],
       F_Filtro_13.C_Horário,
       F_Filtro_13.[C_Elemento Origem],
       F_Filtro_13.USUÁRIO,
       F_Filtro_13.OBSERVAÇÃO,
       F_Filtro_13.STATUS,
       F_Filtro_13.[DATA ANÁLISE],
       F_Filtro_13.[DATA BAIXA],
       F_Filtro_13.ID,
       F_Filtro_13.Intv_TR_Zona_Div_UC,
       F_Filtro_13.OS_Externa,
       F_Filtro_13.OS_Acessante
FROM F_Filtro_13
ORDER BY F_Filtro_13.ID DESC;

-- ===== ~sq_fF_Filtro_13_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR,
       [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_13_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_17_F  (SELECT)
SELECT F_Filtro_17.TIPO_OS,
       F_Filtro_17.COD_CPU_OS_MNB,
       F_Filtro_17.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_17.NUM_SEQ_GER_OS_MNB,
       F_Filtro_17.NOM_USU_PROGM_MNB,
       F_Filtro_17.NOM_USU_CFER_MNB,
       F_Filtro_17.NOM_USU_EXEC_MNB,
       F_Filtro_17.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_17.DES_ORIG_OGE,
       F_Filtro_17.COD_ORIG_INTV_MNB,
       F_Filtro_17.DES_ORIG_ORI,
       F_Filtro_17.COD_CAUSA_MNB,
       F_Filtro_17.DES_CAUSA_INTER_CAU,
       F_Filtro_17.COD_SUB_CAUSA_MNB,
       F_Filtro_17.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_17.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_17.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_17.DES_INTV_MNB,
       F_Filtro_17.DTA_INIC_MNB,
       F_Filtro_17.DTA_AVI_EQP_MNB,
       F_Filtro_17.DTA_DLCT_EQP_MNB,
       F_Filtro_17.DTA_VERI_EQP_MNB,
       F_Filtro_17.DTA_SERV_EQP_MNB,
       F_Filtro_17.DTA_FIM_MNB,
       F_Filtro_17.COD_ELE_MNB,
       F_Filtro_17.COD_INS_SEC_INS,
       F_Filtro_17.COD_TIPO_CONCL_COS,
       F_Filtro_17.COD_SUB_TIPO_OS_COS,
       F_Filtro_17.TIPO_TR,
       F_Filtro_17.TMA,
       F_Filtro_17.DEC,
       F_Filtro_17.DIF_1ª_2ª_RCM_1h,
       F_Filtro_17.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_17.TR_Próprio_OS_Proc,
       F_Filtro_17.Intev_Impro_Causa_Proc,
       F_Filtro_17.Intev_Proc_Causa_Impro,
       F_Filtro_17.[DEC_>_0,001],
       F_Filtro_17.TMD_0,
       F_Filtro_17.[TMA_>_1440],
       F_Filtro_17.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_17.Intev_S_OS_Vinc,
       F_Filtro_17.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_17.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_17.OS_Vinc_UCs_Interr,
       F_Filtro_17.Intev_0_UCs_Inter,
       F_Filtro_17.[Correção Realizada],
       F_Filtro_17.[Comp_>_500],
       F_Filtro_17.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_17.OS_Elemen_Particular_Proc,
       F_Filtro_17.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_17.OS_Impro_Sem_Elem_Partic,
       F_Filtro_17.FEC,
       F_Filtro_17.COD_LOC_COS,
       F_Filtro_17.LOCALIDADE,
       F_Filtro_17.COEC,
       [F_Filtro_17]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_17.Concat,
       F_Filtro_17.C_Classificação,
       F_Filtro_17.[C_OS Vinculada],
       F_Filtro_17.[C_Passo de Manobra],
       F_Filtro_17.C_Horário,
       F_Filtro_17.[C_Elemento Origem],
       F_Filtro_17.USUÁRIO,
       F_Filtro_17.OBSERVAÇÃO,
       F_Filtro_17.STATUS,
       F_Filtro_17.[DATA ANÁLISE],
       F_Filtro_17.[DATA BAIXA],
       F_Filtro_17.ID,
       F_Filtro_17.Intv_TR_Zona_Div_UC,
       F_Filtro_17.OS_Externa,
       F_Filtro_17.OS_Acessante
FROM F_Filtro_17
ORDER BY F_Filtro_17.ID DESC;

-- ===== ~sq_fF_Filtro_17_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_17_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_18_F  (SELECT)
SELECT F_Filtro_18.TIPO_OS,
       F_Filtro_18.COD_CPU_OS_MNB,
       F_Filtro_18.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_18.NUM_SEQ_GER_OS_MNB,
       F_Filtro_18.NOM_USU_PROGM_MNB,
       F_Filtro_18.NOM_USU_CFER_MNB,
       F_Filtro_18.NOM_USU_EXEC_MNB,
       F_Filtro_18.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_18.DES_ORIG_OGE,
       F_Filtro_18.COD_ORIG_INTV_MNB,
       F_Filtro_18.DES_ORIG_ORI,
       F_Filtro_18.COD_CAUSA_MNB,
       F_Filtro_18.DES_CAUSA_INTER_CAU,
       F_Filtro_18.COD_SUB_CAUSA_MNB,
       F_Filtro_18.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_18.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_18.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_18.DES_INTV_MNB,
       F_Filtro_18.DTA_INIC_MNB,
       F_Filtro_18.DTA_AVI_EQP_MNB,
       F_Filtro_18.DTA_DLCT_EQP_MNB,
       F_Filtro_18.DTA_VERI_EQP_MNB,
       F_Filtro_18.DTA_SERV_EQP_MNB,
       F_Filtro_18.DTA_FIM_MNB,
       F_Filtro_18.COD_ELE_MNB,
       F_Filtro_18.COD_INS_SEC_INS,
       F_Filtro_18.COD_TIPO_CONCL_COS,
       F_Filtro_18.COD_SUB_TIPO_OS_COS,
       F_Filtro_18.TIPO_TR,
       F_Filtro_18.TMA,
       F_Filtro_18.DEC,
       F_Filtro_18.DIF_1ª_2ª_RCM_1h,
       F_Filtro_18.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_18.TR_Próprio_OS_Proc,
       F_Filtro_18.Intev_Impro_Causa_Proc,
       F_Filtro_18.Intev_Proc_Causa_Impro,
       F_Filtro_18.[DEC_>_0,001],
       F_Filtro_18.TMD_0,
       F_Filtro_18.[TMA_>_1440],
       F_Filtro_18.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_18.Intev_S_OS_Vinc,
       F_Filtro_18.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_18.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_18.OS_Vinc_UCs_Interr,
       F_Filtro_18.Intev_0_UCs_Inter,
       F_Filtro_18.[Correção Realizada],
       F_Filtro_18.[Comp_>_500],
       F_Filtro_18.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_18.OS_Elemen_Particular_Proc,
       F_Filtro_18.OS_Impro_Sem_Elem_Partic,
       F_Filtro_18.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_18.FEC,
       F_Filtro_18.COD_LOC_COS,
       F_Filtro_18.LOCALIDADE,
       F_Filtro_18.COEC,
       [F_Filtro_18]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_18.Concat,
       F_Filtro_18.C_Classificação,
       F_Filtro_18.[C_OS Vinculada],
       F_Filtro_18.[C_Passo de Manobra],
       F_Filtro_18.C_Horário,
       F_Filtro_18.[C_Elemento Origem],
       F_Filtro_18.USUÁRIO,
       F_Filtro_18.OBSERVAÇÃO,
       F_Filtro_18.STATUS,
       F_Filtro_18.[DATA ANÁLISE],
       F_Filtro_18.[DATA BAIXA],
       F_Filtro_18.ID,
       F_Filtro_18.Intv_TR_Zona_Div_UC,
       F_Filtro_18.OS_Externa,
       F_Filtro_18.OS_Acessante
FROM F_Filtro_18
ORDER BY F_Filtro_18.ID DESC;

-- ===== ~sq_fF_Filtro_18_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_18_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_19_F  (SELECT)
SELECT F_Filtro_19.TIPO_OS,
       F_Filtro_19.COD_CPU_OS_MNB,
       F_Filtro_19.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_19.NUM_SEQ_GER_OS_MNB,
       F_Filtro_19.NOM_USU_PROGM_MNB,
       F_Filtro_19.NOM_USU_CFER_MNB,
       F_Filtro_19.NOM_USU_EXEC_MNB,
       F_Filtro_19.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_19.DES_ORIG_OGE,
       F_Filtro_19.COD_ORIG_INTV_MNB,
       F_Filtro_19.DES_ORIG_ORI,
       F_Filtro_19.COD_CAUSA_MNB,
       F_Filtro_19.DES_CAUSA_INTER_CAU,
       F_Filtro_19.COD_SUB_CAUSA_MNB,
       F_Filtro_19.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_19.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_19.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_19.DES_INTV_MNB,
       F_Filtro_19.DTA_INIC_MNB,
       F_Filtro_19.DTA_AVI_EQP_MNB,
       F_Filtro_19.DTA_DLCT_EQP_MNB,
       F_Filtro_19.DTA_VERI_EQP_MNB,
       F_Filtro_19.DTA_SERV_EQP_MNB,
       F_Filtro_19.DTA_FIM_MNB,
       F_Filtro_19.COD_ELE_MNB,
       F_Filtro_19.COD_INS_SEC_INS,
       F_Filtro_19.COD_TIPO_CONCL_COS,
       F_Filtro_19.COD_SUB_TIPO_OS_COS,
       F_Filtro_19.TIPO_TR,
       F_Filtro_19.TMA,
       F_Filtro_19.DEC,
       F_Filtro_19.DIF_1ª_2ª_RCM_1h,
       F_Filtro_19.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_19.TR_Próprio_OS_Proc,
       F_Filtro_19.Intev_Impro_Causa_Proc,
       F_Filtro_19.Intev_Proc_Causa_Impro,
       F_Filtro_19.[DEC_>_0,001],
       F_Filtro_19.TMD_0,
       F_Filtro_19.[TMA_>_1440],
       F_Filtro_19.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_19.Intev_S_OS_Vinc,
       F_Filtro_19.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_19.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_19.OS_Vinc_UCs_Interr,
       F_Filtro_19.Intev_0_UCs_Inter,
       F_Filtro_19.[Correção Realizada],
       F_Filtro_19.[Comp_>_500],
       F_Filtro_19.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_19.OS_Elemen_Particular_Proc,
       F_Filtro_19.OS_Impro_Sem_Elem_Partic,
       F_Filtro_19.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_19.FEC,
       F_Filtro_19.COD_LOC_COS,
       F_Filtro_19.LOCALIDADE,
       F_Filtro_19.COEC,
       [F_Filtro_19]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_19.Concat,
       F_Filtro_19.C_Classificação,
       F_Filtro_19.[C_OS Vinculada],
       F_Filtro_19.[C_Passo de Manobra],
       F_Filtro_19.C_Horário,
       F_Filtro_19.[C_Elemento Origem],
       F_Filtro_19.USUÁRIO,
       F_Filtro_19.OBSERVAÇÃO,
       F_Filtro_19.STATUS,
       F_Filtro_19.[DATA ANÁLISE],
       F_Filtro_19.[DATA BAIXA],
       F_Filtro_19.ID,
       F_Filtro_19.Intv_TR_Zona_Div_UC,
       F_Filtro_19.OS_Externa,
       F_Filtro_19.OS_Acessante
FROM F_Filtro_19
ORDER BY F_Filtro_19.ID DESC;

-- ===== ~sq_fF_Filtro_19_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_19_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_1_F  (SELECT)
SELECT [F_Filtro_1].TIPO_OS,
       [F_Filtro_1].COD_CPU_OS_MNB,
       [F_Filtro_1].NUM_SEQ_OPER_OS_MNB,
       [F_Filtro_1].NUM_SEQ_GER_OS_MNB,
       [F_Filtro_1].NOM_USU_PROGM_MNB,
       [F_Filtro_1].NOM_USU_CFER_MNB,
       [F_Filtro_1].NOM_USU_EXEC_MNB,
       [F_Filtro_1].COD_TIPO_ORIG_INTV_MNB,
       [F_Filtro_1].DES_ORIG_OGE,
       [F_Filtro_1].COD_ORIG_INTV_MNB,
       [F_Filtro_1].DES_ORIG_ORI,
       [F_Filtro_1].COD_CAUSA_MNB,
       [F_Filtro_1].DES_CAUSA_INTER_CAU,
       [F_Filtro_1].COD_SUB_CAUSA_MNB,
       [F_Filtro_1].DES_SUB_CAUSA_INTER_SCR,
       [F_Filtro_1].NUM_CAUSA_ANEEL_MNB,
       [F_Filtro_1].NUM_SUB_CAUSA_ANEEL_MNB,
       [F_Filtro_1].DES_INTV_MNB,
       [F_Filtro_1].DTA_INIC_MNB,
       [F_Filtro_1].DTA_AVI_EQP_MNB,
       [F_Filtro_1].DTA_DLCT_EQP_MNB,
       [F_Filtro_1].DTA_VERI_EQP_MNB,
       [F_Filtro_1].DTA_SERV_EQP_MNB,
       [F_Filtro_1].DTA_FIM_MNB,
       [F_Filtro_1].COD_ELE_MNB,
       [F_Filtro_1].COD_INS_SEC_INS,
       IIf([F_Filtro_1]![COD_TIPO_CONCL_COS]="000","PRO","IMPRO") AS [COD_TIPO_CONCL_COS],
       [F_Filtro_1].COD_SUB_TIPO_OS_COS,
       [F_Filtro_1].TIPO_TR,
       IIf([F_Filtro_1]![TMA] Is Null,0,[F_Filtro_1]![TMA]) AS [TMA],
       IIf([F_Filtro_1]![DEC] Is Null,0,[F_Filtro_1]![DEC]) AS [DEC],
       [F_Filtro_1].DIF_1ª_2ª_RCM_1h,
       [F_Filtro_1].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [F_Filtro_1].TR_Próprio_OS_Proc,
       [F_Filtro_1].Intev_Impro_Causa_Proc,
       [F_Filtro_1].Intev_Proc_Causa_Impro,
       [F_Filtro_1].[DEC_>_0,001],
       [F_Filtro_1].TMD_0,
       [F_Filtro_1].[TMA_>_1440],
       [F_Filtro_1].[Intev_<_3_OS_Vinc_>_50_UCs],
       [F_Filtro_1].Intev_S_OS_Vinc,
       [F_Filtro_1].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [F_Filtro_1].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [F_Filtro_1].OS_Vinc_UCs_Interr,
       [F_Filtro_1].Intev_0_UCs_Inter,
       [F_Filtro_1].[Comp_>_500],
       [F_Filtro_1].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [F_Filtro_1].OS_Elemen_Particular_Proc,
       [F_Filtro_1].[OS_Vinc_Hr_>_Ult_Passo],
       [F_Filtro_1].OS_Impro_Sem_Elem_Partic,
       [F_Filtro_1].Intv_TR_Zona_Div_UC,
       [F_Filtro_1].OS_Externa,
       [F_Filtro_1].OS_Acessante,
       IIf([F_Filtro_1]![FEC] Is Null,0,[F_Filtro_1]![FEC]) AS [FEC],
       [F_Filtro_1].COD_LOC_COS,
       [F_Filtro_1].LOCALIDADE,
       [F_Filtro_1].COEC,
       IIf([F_Filtro_1]![MULTA_OS]*1 Is Null,0,[F_Filtro_1]![MULTA_OS]*1) AS [MULTA_OS],
       [F_Filtro_1].[Correção Realizada],
       [F_Filtro_1].C_Classificação,
       [F_Filtro_1].[C_OS Vinculada],
       [F_Filtro_1].[C_Passo de Manobra],
       [F_Filtro_1].C_Horário,
       [F_Filtro_1].[C_Elemento Origem],
       [F_Filtro_1].USUÁRIO,
       [F_Filtro_1].OBSERVAÇÃO,
       [F_Filtro_1].STATUS,
       [F_Filtro_1].[DATA ANÁLISE],
       [F_Filtro_1].[DATA BAIXA],
       [F_Filtro_1].Intv_TR_Zona_Div_UC,
       [F_Filtro_1].OS_Externa,
       [F_Filtro_1].OS_Acessante
FROM F_Filtro_1
ORDER BY IIf([F_Filtro_1]![DEC] Is Null,0,[F_Filtro_1]![DEC]) DESC;

-- ===== ~sq_fF_Filtro_1_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR,
       [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].ZONA
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_1_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_20_F  (SELECT)
SELECT F_Filtro_20.TIPO_OS,
       F_Filtro_20.COD_CPU_OS_MNB,
       F_Filtro_20.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_20.NUM_SEQ_GER_OS_MNB,
       F_Filtro_20.NOM_USU_PROGM_MNB,
       F_Filtro_20.NOM_USU_CFER_MNB,
       F_Filtro_20.NOM_USU_EXEC_MNB,
       F_Filtro_20.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_20.DES_ORIG_OGE,
       F_Filtro_20.COD_ORIG_INTV_MNB,
       F_Filtro_20.DES_ORIG_ORI,
       F_Filtro_20.COD_CAUSA_MNB,
       F_Filtro_20.DES_CAUSA_INTER_CAU,
       F_Filtro_20.COD_SUB_CAUSA_MNB,
       F_Filtro_20.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_20.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_20.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_20.DES_INTV_MNB,
       F_Filtro_20.DTA_INIC_MNB,
       F_Filtro_20.DTA_AVI_EQP_MNB,
       F_Filtro_20.DTA_DLCT_EQP_MNB,
       F_Filtro_20.DTA_VERI_EQP_MNB,
       F_Filtro_20.DTA_SERV_EQP_MNB,
       F_Filtro_20.DTA_FIM_MNB,
       F_Filtro_20.COD_ELE_MNB,
       F_Filtro_20.COD_INS_SEC_INS,
       F_Filtro_20.COD_TIPO_CONCL_COS,
       F_Filtro_20.COD_SUB_TIPO_OS_COS,
       F_Filtro_20.TIPO_TR,
       F_Filtro_20.TMA,
       F_Filtro_20.DEC,
       F_Filtro_20.DIF_1ª_2ª_RCM_1h,
       F_Filtro_20.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_20.TR_Próprio_OS_Proc,
       F_Filtro_20.Intev_Impro_Causa_Proc,
       F_Filtro_20.Intev_Proc_Causa_Impro,
       F_Filtro_20.[DEC_>_0,001],
       F_Filtro_20.TMD_0,
       F_Filtro_20.[TMA_>_1440],
       F_Filtro_20.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_20.Intev_S_OS_Vinc,
       F_Filtro_20.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_20.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_20.OS_Vinc_UCs_Interr,
       F_Filtro_20.Intev_0_UCs_Inter,
       F_Filtro_20.[Correção Realizada],
       F_Filtro_20.[Comp_>_500],
       F_Filtro_20.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_20.OS_Elemen_Particular_Proc,
       F_Filtro_20.OS_Impro_Sem_Elem_Partic,
       F_Filtro_20.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_20.FEC,
       F_Filtro_20.COD_LOC_COS,
       F_Filtro_20.LOCALIDADE,
       F_Filtro_20.COEC,
       [F_Filtro_20]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_20.Concat,
       F_Filtro_20.C_Classificação,
       F_Filtro_20.[C_OS Vinculada],
       F_Filtro_20.[C_Passo de Manobra],
       F_Filtro_20.C_Horário,
       F_Filtro_20.[C_Elemento Origem],
       F_Filtro_20.USUÁRIO,
       F_Filtro_20.OBSERVAÇÃO,
       F_Filtro_20.STATUS,
       F_Filtro_20.[DATA ANÁLISE],
       F_Filtro_20.[DATA BAIXA],
       F_Filtro_20.ID,
       F_Filtro_20.Intv_TR_Zona_Div_UC,
       F_Filtro_20.OS_Externa,
       F_Filtro_20.OS_Acessante
FROM F_Filtro_20
ORDER BY F_Filtro_20.ID DESC;

-- ===== ~sq_fF_Filtro_20_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_20_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_2_F  (SELECT)
SELECT F_Filtro_2.TIPO_OS,
       F_Filtro_2.COD_CPU_OS_MNB,
       F_Filtro_2.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_2.NUM_SEQ_GER_OS_MNB,
       F_Filtro_2.NOM_USU_PROGM_MNB,
       F_Filtro_2.NOM_USU_CFER_MNB,
       F_Filtro_2.NOM_USU_EXEC_MNB,
       F_Filtro_2.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_2.DES_ORIG_OGE,
       F_Filtro_2.COD_ORIG_INTV_MNB,
       F_Filtro_2.DES_ORIG_ORI,
       F_Filtro_2.COD_CAUSA_MNB,
       F_Filtro_2.DES_CAUSA_INTER_CAU,
       F_Filtro_2.COD_SUB_CAUSA_MNB,
       F_Filtro_2.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_2.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_2.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_2.DES_INTV_MNB,
       F_Filtro_2.DTA_INIC_MNB,
       F_Filtro_2.DTA_AVI_EQP_MNB,
       F_Filtro_2.DTA_DLCT_EQP_MNB,
       F_Filtro_2.DTA_VERI_EQP_MNB,
       F_Filtro_2.DTA_SERV_EQP_MNB,
       F_Filtro_2.DTA_FIM_MNB,
       F_Filtro_2.COD_ELE_MNB,
       F_Filtro_2.COD_INS_SEC_INS,
       F_Filtro_2.COD_TIPO_CONCL_COS,
       F_Filtro_2.COD_SUB_TIPO_OS_COS,
       F_Filtro_2.TIPO_TR,
       F_Filtro_2.TMA,
       F_Filtro_2.DEC,
       F_Filtro_2.DIF_1ª_2ª_RCM_1h,
       F_Filtro_2.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_2.TR_Próprio_OS_Proc,
       F_Filtro_2.Intev_Impro_Causa_Proc,
       F_Filtro_2.Intev_Proc_Causa_Impro,
       F_Filtro_2.[DEC_>_0,001],
       F_Filtro_2.TMD_0,
       F_Filtro_2.[TMA_>_1440],
       F_Filtro_2.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_2.Intev_S_OS_Vinc,
       F_Filtro_2.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_2.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_2.OS_Vinc_UCs_Interr,
       F_Filtro_2.Intev_0_UCs_Inter,
       F_Filtro_2.[Correção Realizada],
       F_Filtro_2.[Comp_>_500],
       F_Filtro_2.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_2.OS_Elemen_Particular_Proc,
       F_Filtro_2.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_2.OS_Impro_Sem_Elem_Partic,
       F_Filtro_2.FEC,
       F_Filtro_2.COD_LOC_COS,
       F_Filtro_2.LOCALIDADE,
       F_Filtro_2.COEC,
       F_Filtro_2.MULTA_OS,
       F_Filtro_2.Concat,
       F_Filtro_2.C_Classificação,
       F_Filtro_2.[C_OS Vinculada],
       F_Filtro_2.[C_Passo de Manobra],
       F_Filtro_2.C_Horário,
       F_Filtro_2.[C_Elemento Origem],
       F_Filtro_2.USUÁRIO,
       F_Filtro_2.OBSERVAÇÃO,
       F_Filtro_2.STATUS,
       F_Filtro_2.[DATA ANÁLISE],
       F_Filtro_2.[DATA BAIXA],
       F_Filtro_2.ID,
       F_Filtro_2.Intv_TR_Zona_Div_UC,
       F_Filtro_2.OS_Externa,
       F_Filtro_2.OS_Acessante
FROM F_Filtro_2
ORDER BY F_Filtro_2.ID DESC;

-- ===== ~sq_fF_Filtro_2_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_2_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_3_F  (SELECT)
SELECT F_Filtro_3.TIPO_OS,
       F_Filtro_3.COD_CPU_OS_MNB,
       F_Filtro_3.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_3.NUM_SEQ_GER_OS_MNB,
       F_Filtro_3.NOM_USU_PROGM_MNB,
       F_Filtro_3.NOM_USU_CFER_MNB,
       F_Filtro_3.NOM_USU_EXEC_MNB,
       F_Filtro_3.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_3.DES_ORIG_OGE,
       F_Filtro_3.COD_ORIG_INTV_MNB,
       F_Filtro_3.DES_ORIG_ORI,
       F_Filtro_3.COD_CAUSA_MNB,
       F_Filtro_3.DES_CAUSA_INTER_CAU,
       F_Filtro_3.COD_SUB_CAUSA_MNB,
       F_Filtro_3.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_3.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_3.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_3.DES_INTV_MNB,
       F_Filtro_3.DTA_INIC_MNB,
       F_Filtro_3.DTA_AVI_EQP_MNB,
       F_Filtro_3.DTA_DLCT_EQP_MNB,
       F_Filtro_3.DTA_VERI_EQP_MNB,
       F_Filtro_3.DTA_SERV_EQP_MNB,
       F_Filtro_3.DTA_FIM_MNB,
       F_Filtro_3.COD_ELE_MNB,
       F_Filtro_3.COD_INS_SEC_INS,
       F_Filtro_3.COD_TIPO_CONCL_COS,
       F_Filtro_3.COD_SUB_TIPO_OS_COS,
       F_Filtro_3.TIPO_TR,
       F_Filtro_3.TMA,
       F_Filtro_3.DEC,
       F_Filtro_3.DIF_1ª_2ª_RCM_1h,
       F_Filtro_3.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_3.TR_Próprio_OS_Proc,
       F_Filtro_3.Intev_Impro_Causa_Proc,
       F_Filtro_3.Intev_Proc_Causa_Impro,
       F_Filtro_3.[DEC_>_0,001],
       F_Filtro_3.TMD_0,
       F_Filtro_3.[TMA_>_1440],
       F_Filtro_3.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_3.Intev_S_OS_Vinc,
       F_Filtro_3.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_3.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_3.OS_Vinc_UCs_Interr,
       F_Filtro_3.Intev_0_UCs_Inter,
       F_Filtro_3.[Correção Realizada],
       F_Filtro_3.[Comp_>_500],
       F_Filtro_3.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_3.OS_Elemen_Particular_Proc,
       F_Filtro_3.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_3.OS_Impro_Sem_Elem_Partic,
       F_Filtro_3.FEC,
       F_Filtro_3.COD_LOC_COS,
       F_Filtro_3.LOCALIDADE,
       F_Filtro_3.COEC,
       [F_Filtro_3]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_3.Concat,
       F_Filtro_3.C_Classificação,
       F_Filtro_3.[C_OS Vinculada],
       F_Filtro_3.[C_Passo de Manobra],
       F_Filtro_3.C_Horário,
       F_Filtro_3.[C_Elemento Origem],
       F_Filtro_3.USUÁRIO,
       F_Filtro_3.OBSERVAÇÃO,
       F_Filtro_3.STATUS,
       F_Filtro_3.[DATA ANÁLISE],
       F_Filtro_3.[DATA BAIXA],
       F_Filtro_3.ID,
       F_Filtro_3.Intv_TR_Zona_Div_UC,
       F_Filtro_3.OS_Externa,
       F_Filtro_3.OS_Acessante
FROM F_Filtro_3
ORDER BY F_Filtro_3.ID DESC;

-- ===== ~sq_fF_Filtro_3_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_3_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Filtro_4_F  (SELECT)
SELECT F_Filtro_4.TIPO_OS,
       F_Filtro_4.COD_CPU_OS_MNB,
       F_Filtro_4.NUM_SEQ_OPER_OS_MNB,
       F_Filtro_4.NUM_SEQ_GER_OS_MNB,
       F_Filtro_4.NOM_USU_PROGM_MNB,
       F_Filtro_4.NOM_USU_CFER_MNB,
       F_Filtro_4.NOM_USU_EXEC_MNB,
       F_Filtro_4.COD_TIPO_ORIG_INTV_MNB,
       F_Filtro_4.DES_ORIG_OGE,
       F_Filtro_4.COD_ORIG_INTV_MNB,
       F_Filtro_4.DES_ORIG_ORI,
       F_Filtro_4.COD_CAUSA_MNB,
       F_Filtro_4.DES_CAUSA_INTER_CAU,
       F_Filtro_4.COD_SUB_CAUSA_MNB,
       F_Filtro_4.DES_SUB_CAUSA_INTER_SCR,
       F_Filtro_4.NUM_CAUSA_ANEEL_MNB,
       F_Filtro_4.NUM_SUB_CAUSA_ANEEL_MNB,
       F_Filtro_4.DES_INTV_MNB,
       F_Filtro_4.DTA_INIC_MNB,
       F_Filtro_4.DTA_AVI_EQP_MNB,
       F_Filtro_4.DTA_DLCT_EQP_MNB,
       F_Filtro_4.DTA_VERI_EQP_MNB,
       F_Filtro_4.DTA_SERV_EQP_MNB,
       F_Filtro_4.DTA_FIM_MNB,
       F_Filtro_4.COD_ELE_MNB,
       F_Filtro_4.COD_INS_SEC_INS,
       F_Filtro_4.COD_TIPO_CONCL_COS,
       F_Filtro_4.COD_SUB_TIPO_OS_COS,
       F_Filtro_4.TIPO_TR,
       F_Filtro_4.TMA,
       F_Filtro_4.DEC,
       F_Filtro_4.DIF_1ª_2ª_RCM_1h,
       F_Filtro_4.DIF_1ª_Man_1ª_OS_Vinc_2h,
       F_Filtro_4.TR_Próprio_OS_Proc,
       F_Filtro_4.Intev_Impro_Causa_Proc,
       F_Filtro_4.Intev_Proc_Causa_Impro,
       F_Filtro_4.[DEC_>_0,001],
       F_Filtro_4.TMD_0,
       F_Filtro_4.[TMA_>_1440],
       F_Filtro_4.[Intev_<_3_OS_Vinc_>_50_UCs],
       F_Filtro_4.Intev_S_OS_Vinc,
       F_Filtro_4.[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       F_Filtro_4.[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       F_Filtro_4.OS_Vinc_UCs_Interr,
       F_Filtro_4.Intev_0_UCs_Inter,
       F_Filtro_4.[Correção Realizada],
       F_Filtro_4.[Comp_>_500],
       F_Filtro_4.Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       F_Filtro_4.OS_Elemen_Particular_Proc,
       F_Filtro_4.[OS_Vinc_Hr_>_Ult_Passo],
       F_Filtro_4.OS_Impro_Sem_Elem_Partic,
       F_Filtro_4.FEC,
       F_Filtro_4.COD_LOC_COS,
       F_Filtro_4.LOCALIDADE,
       F_Filtro_4.COEC,
       [F_Filtro_4]![MULTA_OS]*1 AS [MULTA_OS],
       F_Filtro_4.Concat,
       F_Filtro_4.C_Classificação,
       F_Filtro_4.[C_OS Vinculada],
       F_Filtro_4.[C_Passo de Manobra],
       F_Filtro_4.C_Horário,
       F_Filtro_4.[C_Elemento Origem],
       F_Filtro_4.USUÁRIO,
       F_Filtro_4.OBSERVAÇÃO,
       F_Filtro_4.STATUS,
       F_Filtro_4.[DATA ANÁLISE],
       F_Filtro_4.[DATA BAIXA],
       F_Filtro_4.ID,
       F_Filtro_4.Intv_TR_Zona_Div_UC,
       F_Filtro_4.OS_Externa,
       F_Filtro_4.OS_Acessante
FROM F_Filtro_4
ORDER BY F_Filtro_4.ID DESC;

-- ===== ~sq_fF_Filtro_9_F_V  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![F_Filtro_9_F]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Inicio  (SELECT)
SELECT T_Analistas.NOME
FROM T_Analistas;

-- ===== ~sq_fF_Intervenção  (SELECT)
SELECT [99 Base Intervenção Unificada - Filtro].TIPO_OS,
       [99 Base Intervenção Unificada - Filtro].COD_CPU_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_OPER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SEQ_GER_OS_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_PROGM_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_CFER_MNB,
       [99 Base Intervenção Unificada - Filtro].NOM_USU_EXEC_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_TIPO_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_OGE,
       [99 Base Intervenção Unificada - Filtro].COD_ORIG_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_ORIG_ORI,
       [99 Base Intervenção Unificada - Filtro].COD_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_CAUSA_INTER_CAU,
       [99 Base Intervenção Unificada - Filtro].COD_SUB_CAUSA_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_SUB_CAUSA_INTER_SCR,
       [99 Base Intervenção Unificada - Filtro].NUM_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].NUM_SUB_CAUSA_ANEEL_MNB,
       [99 Base Intervenção Unificada - Filtro].DES_INTV_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_INIC_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_AVI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_DLCT_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_VERI_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_SERV_EQP_MNB,
       [99 Base Intervenção Unificada - Filtro].DTA_FIM_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_ELE_MNB,
       [99 Base Intervenção Unificada - Filtro].COD_INS_SEC_INS,
       IIf([99 Base Intervenção Unificada - Filtro]![COD_TIPO_CONCL_COS]="000","PRO","IMPRO") AS [COD_TIPO_CONCL_COS],
       [99 Base Intervenção Unificada - Filtro].COD_SUB_TIPO_OS_COS,
       [99 Base Intervenção Unificada - Filtro].TIPO_TR,
       IIf([99 Base Intervenção Unificada - Filtro]![TMA] Is Null,0,[99 Base Intervenção Unificada - Filtro]![TMA]) AS [TMA],
       IIf([99 Base Intervenção Unificada - Filtro]![DEC] Is Null,0,[99 Base Intervenção Unificada - Filtro]![DEC]) AS [DEC],
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_2ª_RCM_1h,
       [99 Base Intervenção Unificada - Filtro].DIF_1ª_Man_1ª_OS_Vinc_2h,
       [99 Base Intervenção Unificada - Filtro].TR_Próprio_OS_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Impro_Causa_Proc,
       [99 Base Intervenção Unificada - Filtro].Intev_Proc_Causa_Impro,
       [99 Base Intervenção Unificada - Filtro].[DEC_>_0,001],
       [99 Base Intervenção Unificada - Filtro].TMD_0,
       [99 Base Intervenção Unificada - Filtro].[TMA_>_1440],
       [99 Base Intervenção Unificada - Filtro].[Intev_<_3_OS_Vinc_>_50_UCs],
       [99 Base Intervenção Unificada - Filtro].Intev_S_OS_Vinc,
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_=_1_min],
       [99 Base Intervenção Unificada - Filtro].[Tempo_Hr_Inic_Hr_1º_Passo_>_6_hr],
       [99 Base Intervenção Unificada - Filtro].OS_Vinc_UCs_Interr,
       [99 Base Intervenção Unificada - Filtro].Intev_0_UCs_Inter,
       [99 Base Intervenção Unificada - Filtro].[Comp_>_500],
       [99 Base Intervenção Unificada - Filtro].Dif_1º_Passo_1ª_OS_1º_Passo_Hr_Inicio,
       [99 Base Intervenção Unificada - Filtro].OS_Elemen_Particular_Proc,
       [99 Base Intervenção Unificada - Filtro].[OS_Vinc_Hr_>_Ult_Passo],
       [99 Base Intervenção Unificada - Filtro].OS_Impro_Sem_Elem_Partic,
       [99 Base Intervenção Unificada - Filtro].Intv_TR_Zona_Div_UC,
       [99 Base Intervenção Unificada - Filtro].OS_Externa,
       [99 Base Intervenção Unificada - Filtro].OS_Acessante,
       IIf([99 Base Intervenção Unificada - Filtro]![FEC] Is Null,0,[99 Base Intervenção Unificada - Filtro]![FEC]) AS [FEC],
       [99 Base Intervenção Unificada - Filtro].COD_LOC_COS,
       [99 Base Intervenção Unificada - Filtro].LOCALIDADE,
       [99 Base Intervenção Unificada - Filtro].COEC,
       IIf([99 Base Intervenção Unificada - Filtro]![MULTA_OS]*1 Is Null,0,[99 Base Intervenção Unificada - Filtro]![MULTA_OS]*1) AS [MULTA_OS],
       [99 Base Intervenção Unificada - Filtro].[Correção Realizada],
       [99 Base Intervenção Unificada - Filtro].C_Classificação,
       [99 Base Intervenção Unificada - Filtro].[C_OS Vinculada],
       [99 Base Intervenção Unificada - Filtro].[C_Passo de Manobra],
       [99 Base Intervenção Unificada - Filtro].C_Horário,
       [99 Base Intervenção Unificada - Filtro].[C_Elemento Origem],
       [99 Base Intervenção Unificada - Filtro].USUÁRIO,
       [99 Base Intervenção Unificada - Filtro].OBSERVAÇÃO,
       [99 Base Intervenção Unificada - Filtro].STATUS,
       [99 Base Intervenção Unificada - Filtro].[DATA ANÁLISE],
       [99 Base Intervenção Unificada - Filtro].[DATA BAIXA]
FROM [99 Base Intervenção Unificada - Filtro]
ORDER BY IIf([99 Base Intervenção Unificada - Filtro]![DEC] Is Null,0,[99 Base Intervenção Unificada - Filtro]![DEC]) DESC;

-- ===== ~sq_fF_Intervenção_Aguard_Retorn_Reclm_Material  (SELECT)
SELECT [1 Tabela_Equipe].DTA_CMPT_MNB,
       [1 Tabela_Equipe].TIPO_OS,
       [1 Tabela_Equipe].COD_CPU_OS_MNB,
       [1 Tabela_Equipe].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Equipe].EQUIPE,
       [1 Tabela_Equipe].COD_MATERIAL,
       [1 Tabela_Equipe].QUANTIDADE,
       [1 Tabela_Equipe].DESCRIÇÃO,
       [1 Tabela_Equipe].KM_INICIO,
       [1 Tabela_Equipe].KM_FIM
FROM [1 Tabela_Equipe]
WHERE ((([1 Tabela_Equipe].NUM_SEQ_OPER_OS_MNB)=[Formulários]![0 F_Intervenção_Aguard_Retor]![Texto507]));

-- ===== ~sq_fF_Intervenção_Reclm_Vinc_Ag_Retorno  (SELECT)
SELECT [1 Tabela_Individual_Vinculada].TIPO_OS,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR,
       [1 Tabela_Individual_Vinculada].COD_CPU_CNR,
       [1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_CNR,
       [1 Tabela_Individual_Vinculada].COD_MOTI_RECL_CNR,
       [1 Tabela_Individual_Vinculada].COD_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_SUB_TIPO_OS_CNR,
       [1 Tabela_Individual_Vinculada].COD_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].NUM_FONE_CNR,
       [1 Tabela_Individual_Vinculada].DES_BAI_CNR,
       [1 Tabela_Individual_Vinculada].DES_LOC_CNR,
       [1 Tabela_Individual_Vinculada].DES_ENDE_UN_CONS_CNR,
       [1 Tabela_Individual_Vinculada].DES_PTO_REF_CNR,
       [1 Tabela_Individual_Vinculada].DTA_RECL_CNR,
       [1 Tabela_Individual_Vinculada].DTA_COMU_CNR,
       [1 Tabela_Individual_Vinculada].DTA_DLCT_CNR,
       [1 Tabela_Individual_Vinculada].DTA_VERI_CNR,
       [1 Tabela_Individual_Vinculada].DTA_SERV_CNR,
       [1 Tabela_Individual_Vinculada].DTA_FIM_CNR,
       [1 Tabela_Individual_Vinculada].DES_OBS_EXEC_SERV_CNR,
       [1 Tabela_Individual_Vinculada].COD_INS_TRF_INT,
       [1 Tabela_Individual_Vinculada].NOM_TEC_RESP_CUR,
       [1 Tabela_Individual_Vinculada].COD_EQP_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_INIC_CUR,
       [1 Tabela_Individual_Vinculada].QTD_KM_FIM_CUR,
       [1 Tabela_Individual_Vinculada].USU_VINC,
       [1 Tabela_Individual_Vinculada].TIPO_VINC
FROM [1 Tabela_Individual_Vinculada]
WHERE ((([1 Tabela_Individual_Vinculada].NUM_SEQ_OPER_INTER_CNR)=[Formulários]![0 F_Intervenção_Aguard_Retor]![Texto507]))
ORDER BY [1 Tabela_Individual_Vinculada].DTA_RECL_CNR;

-- ===== ~sq_fF_Status_Correções  (SELECT)
SELECT [99 A_Union_Final].*
FROM [99 A_Union_Final];
