-- Regra Comp_maior_500: consulta raiz [2_6 Comp > R$ 1000] (1 consultas na cadeia)

-- ===== 2_6 Comp > R$ 1000  (SELECT)
SELECT [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB,
       Comp_Ocorrências.MULTA_OS
FROM [1 Tabela_Intervenção]
  INNER JOIN [Comp_Ocorrências] ON [1 Tabela_Intervenção].NUM_SEQ_OPER_OS_MNB = Comp_Ocorrências.NUM_SEQ_OPER_INIC_INTER_VDI
WHERE (((Comp_Ocorrências.MULTA_OS)>=1000));
