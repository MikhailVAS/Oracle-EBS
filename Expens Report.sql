/* Поиск вендор ид для исправления и проверка аттрибута_3 */
SELECT vendor_id,VENDOR_NAME, attribute3
  FROM APPS.ap_suppliers
 WHERE VENDOR_NAME LIKE '%Захаров%В%'
 
/* Ошибка в авансовом отчете. Исправление */
/* Formatted  (QP5 v5.326) Service Desk 406981 Mihail.Vasiljev */
UPDATE APPS.ap_suppliers
   SET attribute3 = NULL
 WHERE vendor_id IN (1253367)

 
UPDATE AP_EXPENSE_REPORT_HEADERS_ALL
   SET ATTRIBUTE9 = TO_DATE ('04.10.2022 00:00:00', 'dd.mm.yyyy hh24:mi:ss'),
       ATTRIBUTE10 = TO_DATE ('04.10.2022 00:00:00', 'dd.mm.yyyy hh24:mi:ss'),
       ATTRIBUTE11 = TO_DATE ('04.10.2022 00:00:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE invoice_num IN ('BST377274')

 UPDATE ap_expense_report_lines_all
   SET  START_EXPENSE_DATE = to_date('04.10.2022','dd.mm.yyyy') , END_EXPENSE_DATE = to_date('04.10.2022','dd.mm.yyyy') 
 WHERE REPORT_HEADER_ID = 377274
 
/* Formatted on 17.07.2020 17:25:02 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT DISTINCT *
  --erh.invoice_num,
  --         erh.description,
  --         wf.full_name,
  --         erd.code_combination_id,
  --         ccid.segment2,
  --         ccid.segment6,
  --         ccid.segment8,
  --         amount
  FROM AP_EXPENSE_REPORT_HEADERS_ALL erh, ap_exp_report_dists_all erd
 --         gl_code_combinations_kfv ccid,
 --         PER_PEOPLE_F wf
 WHERE     erd.report_header_id = erh.report_header_id
       AND erh.invoice_num IN ('BST377274')
--         AND ccid.code_combination_id = erd.code_combination_id
--         AND EXPENSE_STATUS_CODE = 'ERROR'
--         AND wf.person_id = erh.employee_id
--         AND EFFECTIVE_END_DATE = (select max(EFFECTIVE_END_DATE) from PER_PEOPLE_F where person_id = erh.preparer_id)
--         AND erh.creation_date >= TO_DATE ('17072020', 'ddmmyyyy')

SELECT *
  FROM GL_CODE_COMBINATIONS
 WHERE CODE_COMBINATION_ID in (
500389,
423893)

/* Formatted on 17.07.2020 17:31:21 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM GL_CODE_COMBINATIONS
 WHERE CODE_COMBINATION_ID IN
           (SELECT CODE_COMBINATION_ID
              FROM gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.2001.0.0.0.DMN050400.0.740_18_03_03_00_00.0.0.PL_740_18_03.0.0.0.0' )-- Плохой счёт который подставляется их 2 штуку
            --01.2001.0.0.0.DMN030309.0.740_18_03_03_00_00.0.0.PL_740_18_03.0.0.0.0  А это корректный                                                                     )

01.2001.0.0.0.0.0.740_18_03_03_00_00.0.0.PL_740_18_03.0.0.0.0

01.2001.0.0.0.0.0.740_18_03_05_00_00.0.0.PL_740_18_03.0.0.0.0

--01.2001.0.0.0.DMN050200.0.740_18_03_03_00_00.0.0.PL_740_18_03.0.0.0.0
/* Formatted on 16.07.2020 16:56:36 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE APPS.GL_CODE_COMBINATIONS
   SET SEGMENT6 = 0
 WHERE CODE_COMBINATION_ID = 423893
