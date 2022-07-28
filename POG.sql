/* Formatted on 01.04.2019 15:20:00 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM all_objects
 WHERE object_name LIKE 'AP%' AND object_type = 'TABLE'

/* Serch POD header information 
   Example : AP Invoice (POG) № ВВ 3115715*/
SELECT *
  FROM xxtg.XXTG_AP_POG_HEADERS
 WHERE invoice_num = 'ВВ3098110'
 
 /*Find invoce in double_global  */
SELECT g1.*
    FROM xxtg.xxtg_gl001_double_global g1
   WHERE     1 = 1
         AND g1.c_doc_id = ( /* Поиск ID invoice для double_global , invoice_id=c_doc_id(double_global)  */
                            SELECT invoice_id
                              FROM APPS.ap_invoices_all
                             WHERE INVOICE_NUM = 'ВВ3098110') /* Номер Invoice*/ 
         AND g1.D_ENTITY_CODE = 'AP_INVOICES'               /*Фильтрация только Invoice*/ 
--         AND g1.D_SEGMENT2 = '1013'                         /* Дт-ый счет*/ 
ORDER BY g1.D_ACCOUNTING_DATE,
         g1.ENTERED_AMOUNT,
         g1.DOUBLE_GLOBAL_ID,
         g1.C_DOC_NUM

edit ap.ap_invoice_distributions_all

/* Formatted on 01.04.2019 15:20:17 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM ap.ap_invoice_distributions_all
 WHERE invoice_id = '142892'                  --where invoice_num='ПЕ 0073749'

update ap.ap_invoice_distributions_all set attribute3='010' where invoice_id='142892'


XXTG_AP_POG_JOURNAL_LINES
XXTG_AP_POG_LINES

/* Find POG line id */
SELECT *
  FROM XXTG_AP_POG_LINES
 WHERE invoice_id = (SELECT invoice_id
                       FROM APPS.ap_invoices_all
                      WHERE INVOICE_NUM = 'ВВ3098110')

 

/* Find all POG lines*/
SELECT *
  FROM XXTG_AP_POG_JOURNAL_LINES
 WHERE pog_line_id =
       (SELECT pog_line_id
          FROM XXTG_AP_POG_LINES
         WHERE invoice_id = (SELECT invoice_id
                               FROM APPS.ap_invoices_all
                              WHERE INVOICE_NUM = 'ВВ3098110'))
							  
/* POG All XLA lines  */
SELECT *
  FROM xla.xla_ae_lines
 WHERE ae_header_id IN (SELECT D_AE_HEADER_ID
                          FROM xxtg_gl001_double_global
                         WHERE D_DOC_NUM = 'ВВ3098110')--and ae_line_num = 1



/* POG All XLA Headers  */
SELECT a.*
  FROM xla.xla_ae_headers a
 WHERE ae_header_id IN (SELECT D_AE_HEADER_ID
                          FROM xxtg_gl001_double_global
                         WHERE D_DOC_NUM = 'ВВ3098110')
							  
--################################################################################
--################################################################################
/* All POG lines in double_global */
SELECT *
  FROM xxtg_gl001_double_global
 WHERE D_DOC_NUM = 'ВВ3098110'
--################################################################################
--################################################################################
/*update analytics in POG*/

update xxtg_gl001_double_global set d_an_code_1 = '010', d_an_desc_1 = 'Обслуживание и ремонт автотранспорта' where d_ae_Header_id in (106320849,
108658293) and d_ae_line_num = 1

select * from xxtg_gl001_double_global where d_ae_Header_id in (106320849,
108658293) and d_ae_line_num = 1

update xla.xla_ae_lines set attribute1 = '010' where ae_header_id in (106320849,
108658293 ) and ae_line_num = 1

select * from xla.xla_ae_lines where ae_header_id in (106320849,
108658293) and ae_line_num = 1

