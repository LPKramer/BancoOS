-- Regra TMA_maior_1440: consulta raiz [3_0 TMA] (1 consultas na cadeia)

-- ===== 3_0 TMA  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].TMA,
       IIf([TMA]>1440,"Verificar",Null) AS [STATUS],
       [1 Tabela_Intervenção]![DES_CAUSA_INTER_CAU] & "-" & [1 Tabela_Intervenção]![DES_SUB_CAUSA_INTER_SCR] AS [CAUSA]
FROM [1 Tabela_Intervenção];
