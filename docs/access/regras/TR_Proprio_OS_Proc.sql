-- Regra TR_Proprio_OS_Proc: consulta raiz [2_0 TR Próprio Intv Proced] (1 consultas na cadeia)

-- ===== 2_0 TR Próprio Intv Proced  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].TIPO_TR,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([1 Tabela_Intervenção]![TIPO_TR]="PRÓPRIO","Verificar","") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].TIPO_TR)="PRÓPRIO") AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));
