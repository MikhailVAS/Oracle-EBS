/* Поиск всех схожих ручных журналов за февраль и получение JE_HEADER_ID для проверки в double_global */
  SELECT GJH.CREATED_BY,
         GJH.JE_HEADER_ID,
         fu.user_name,
         SOB.SHORT_NAME
             "BOOK",
         GLS.USER_JE_SOURCE_NAME
             "SOURCE",
         GLC.USER_JE_CATEGORY_NAME
             "CATEGORY",
         GJB.NAME
             "BATCH NAME",
         GJH.NAME
             "JOURNAL NAME",
         GJH.CURRENCY_CODE
             "CURRENCY",
         GJL.JE_LINE_NUM
             "JRNL LINE#",
         GJL.EFFECTIVE_DATE
             "ACCOUNTING DATE",
         GJH.PERIOD_NAME
             "PERIOD",
         GJH.DATE_CREATED
             "CREATED DATE",
         GJL.ENTERED_DR,
         GJL.ENTERED_CR,
         GJL.ACCOUNTED_DR,
         GJL.ACCOUNTED_CR,
         GJL.CONTEXT,
         APPS.xxtg_gl001_pkg.get_an_descr (GJL.CONTEXT, GJL.ATTRIBUTE1, 1)
             "КАУ-1",
         APPS.xxtg_gl001_pkg.get_an_descr (GJL.CONTEXT, GJL.ATTRIBUTE2, 2)
             "КАУ-2",
         APPS.xxtg_gl001_pkg.get_an_descr (GJL.CONTEXT, GJL.ATTRIBUTE3, 3)
             "КАУ-3",
         GJH.CURRENCY_CONVERSION_RATE
             "CONV RATE",
         GJH.CURRENCY_CONVERSION_DATE
             "CONV DATE",
         GJH.CURRENCY_CONVERSION_TYPE
             "CONV TYPE",
         GJL.DESCRIPTION
    FROM APPS.GL_JE_BATCHES       GJB,
         APPS.GL_JE_HEADERS       GJH,
         APPS.GL_JE_LINES         GJL,
         APPS.GL_CODE_COMBINATIONS GCC,
         APPS.GL_SETS_OF_BOOKS    SOB,
         APPS.GL_JE_SOURCES       GLS,
         APPS.GL_JE_CATEGORIES    GLC,
         APPS.fnd_user            fu
   WHERE     fu.user_id = GJH.CREATED_BY
         AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
         AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
         AND GCC.CODE_COMBINATION_ID = GJL.CODE_COMBINATION_ID
         AND GLS.JE_SOURCE_NAME = GJH.JE_SOURCE
         AND GLC.JE_CATEGORY_NAME = GJH.JE_CATEGORY
         -- AND GLS.USER_JE_SOURCE_NAME = 'Payables'
         AND GJH.PERIOD_NAME IN ('FEB-19')
         AND sob.set_of_books_id = 2047
         AND GJH.NAME LIKE
                 '%Зачет вознаграждения в счет уплаты штрафа%'
-- AND GJH.CREATED_BY = (SELECT user_id
--  FROM APPS.fnd_user fu
-- WHERE fu.user_name LIKE UPPER ('%' || :ORACLE_USER_NAME || '%')) /* BSTALICE*/
ORDER BY 11, 7, 9

/* Find all account by  transaction in double_global*/
  SELECT                                                            --distinct
         ENTERED_AMOUNT,
         D_ACCOUNTING_DATE,
         C_ACCOUNTING_DATE,
         D_AN_DESC_1,
         C_AN_DESC_3,
         ENTERED_AMOUNT,
         g1.C_DOC_NUM,
         g1.d_DOC_NUM,
         g1.*
    FROM xxtg.xxtg_gl001_double_global g1
   WHERE  (D_AE_HEADER_ID in (2182717,2182754) or c_AE_HEADER_ID in (2182717,2182754))
 and D_ACCOUNTING_DATE between to_date ('21.02.2019','.dd.mm.yyyy') and to_date ('28.02.2019','.dd.mm.yyyy')
ORDER BY                                                  
         g1.D_ACCOUNTING_DATE,
         g1.ENTERED_AMOUNT,
         g1.DOUBLE_GLOBAL_ID,
         g1.C_DOC_NUM


/* Formatted on 11.03.2019 11:45:52 (QP5 v5.326) Service Desk 280468 Mihail.Vasiljev */
/* Обновление статуса обсчёта , для перерасчёта из-за дублирования */
UPDATE APPS.GL_JE_HEADERS
   SET ATTRIBUTE10 = NULL
 WHERE JE_HEADER_ID in (2182717,2182754)
 
 /* Jurnals lines */
SELECT jh.doc_sequence_value         journal_entry_doc_number,
       jl.je_line_num                journal_entry_line_number,
       cc.concatenated_segments      gl_account_number,
       jl.accounted_dr               debit_amount,
       jl.accounted_cr               credit_amount,
       jh.period_name                period_name,
       jh.default_effective_date     effective_date,
       jh.creation_date              entry_date,
       jh.created_by                 perparer_id,
       jh.je_source                  je_source,
       jh.description                je_description
  FROM gl_je_headers jh, gl_je_lines jl, gl_code_combinations_kfv cc
 WHERE     jh.je_header_id = jl.je_header_id
       AND cc.code_combination_id = jl.code_combination_id
       AND jh.period_name = 'JUN-20'
       --and jh.status='P'
       AND jh.je_header_id = '2883608'