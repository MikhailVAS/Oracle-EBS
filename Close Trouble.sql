UPDATE GL_INTERFACE
   SET CODE_COMBINATION_ID = '1037538',-- 0
       ATTRIBUTE2 = 'Y',-- Null
       CODE_COMBINATION_ID_INTERIM = '1037538'-- 0
       ,STATUS = 'P'
 WHERE STATUS = 'EF05'
 
 
 SELECT * FROM  GL_INTERFACE 
 WHERE USER_JE_SOURCE_NAME NOT IN ('USER_JE_SOURCE_NAME') 
 AND USER_JE_SOURCE_NAME  IN ('Вручную') 
-- AND GROUP_ID = 658438

 /* GL Journals NOT EXISTS IN DG*/
SELECT *
  FROM XXTG_GL001_DOUBLE_GLOBAL dg1
 WHERE     1 = 1
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.06.2024', 'dd.mm.yyyy')
                                 AND TO_DATE ('30.06.2024', 'dd.mm.yyyy')
       AND C_APPL_ID = 101
       AND NOT EXISTS
               (SELECT je_header_id
                  FROM gl_je_headers
                 WHERE PERIOD_NAME = 'JUN-24' AND je_header_id = C_doc_id);

 /* GL Journals NOT EXISTS IN DG*/
SELECT *
  FROM XXTG_GL001_DOUBLE_GLOBAL dg1
 WHERE     1 = 1
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.05.2024', 'dd.mm.yyyy')
                                 AND TO_DATE ('31.05.2024', 'dd.mm.yyyy')
       AND D_APPL_ID = 101
       AND NOT EXISTS
               (SELECT je_header_id
                  FROM gl_je_headers
                 WHERE PERIOD_NAME = 'MAY-24' AND je_header_id = d_doc_id);

/* XLA DG Ct */
SELECT * FROM 
    XXTG_GL001_DOUBLE_GLOBAL g
      WHERE     NOT EXISTS
                    (SELECT 1
                       FROM xla_ae_headers h
                      WHERE ae_header_id = g.c_ae_header_id)
            AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.06.2024',
                                                   'dd.mm.yyyy')
                                      AND TO_DATE ('30.06.2024',
                                                   'dd.mm.yyyy')
            AND C_APPL_ID != 101
/* XLA DG Dt */
SELECT * FROM 
    XXTG_GL001_DOUBLE_GLOBAL g
      WHERE     NOT EXISTS
                    (SELECT 1
                       FROM xla_ae_headers h
                      WHERE ae_header_id = g.d_ae_header_id)
            AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.06.2024',
                                                   'dd.mm.yyyy')
                                      AND TO_DATE ('30.06.2024',
                                                   'dd.mm.yyyy')
            AND D_APPL_ID != 101
