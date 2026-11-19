-- Regra DEC_maior_0001: consulta raiz [2_3 dec >= 0,001] (1 consultas na cadeia)

-- ===== 2_3 dec >= 0,001  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].DEC,
       IIf([1 Tabela_Intervenção]![DEC]>="0,001","Verificar","") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].DEC)>="0,001"));
