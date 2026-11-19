-- Regra Intev_Impro_Causa_Proc: consulta raiz [2_1 Intev Impro Causa Pro] (1 consultas na cadeia)

-- ===== 2_1 Intev Impro Causa Pro  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       [1 Tabela_Intervenção].COD_SUB_CAUSA_MNB,
       [1 Tabela_Intervenção].COD_TIPO_CONCL_COS,
       IIf([COD_CAUSA_MNB]<>"IM",IIf([COD_TIPO_CONCL_COS]="004","Verificar",""),"") AS [Análise]
FROM [1 Tabela_Intervenção]
WHERE ((([1 Tabela_Intervenção].COD_SUB_CAUSA_MNB) Not In ("MV","EY","CB","KI","KG","KF","KK","KH","KE","KJ")) AND (([1 Tabela_Intervenção].COD_TIPO_CONCL_COS)="004"));
