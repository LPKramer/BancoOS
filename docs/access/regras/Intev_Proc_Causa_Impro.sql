-- Regra Intev_Proc_Causa_Impro: consulta raiz [2_2 Intev Pro Causa Impro] (1 consultas na cadeia)

-- ===== 2_2 Intev Pro Causa Impro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([COD_CAUSA_MNB]="IM",IIf([COD_TIPO_CONCL_COS]="000","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_SUB_CAUSA_MNB) In ("MV","EY","CB","KI","KG","KF","KK","KH","KE","KJ")) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="000"));
