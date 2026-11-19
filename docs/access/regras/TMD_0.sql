-- Regra TMD_0: consulta raiz [2_5 TMD = 0 Análise] (2 consultas na cadeia)

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
