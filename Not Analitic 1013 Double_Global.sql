/*============== По АР инвойсам нет аналитики по счету 1013 Service Desk 172467 ================*/ 

/* Добавдение аналитики по счету 1013 в АР инвойс из транзакции  Service Desk 172467 Mihail.Vasiljev */
UPDATE xxtg_gl001_double_global a
   SET D_AN_CODE_1 = 'UserPril_83',
       D_AN_CODE_2 = '1013003',
       D_AN_CODE_3 = '524814',
       D_AN_DESC_1 ='Cклад абонентского оборудования Cклад абонентского оборудования UserPril_83',
       D_AN_DESC_2 ='Сотовые телефоны (сч.10)',
       D_AN_DESC_3 ='PRA-LA1 Blue Сотовые телефоны Huawei P8 Lite 2017, модель PRA-LA1, цвет синий'
 WHERE DOUBLE_GLOBAL_ID IN (172501052, 172502930)
 
/* Поиск ID invoice для double_global , invoice_id=c_doc_id(double_global) */
SELECT invoice_id
  FROM APPS.ap_invoices_all 
 WHERE INVOICE_NUM = '3136376'

/*Поиска инвойса в double_global  */
SELECT g1.*
    FROM xxtg.xxtg_gl001_double_global g1
   WHERE     1 = 1
         AND g1.c_doc_id = ( /* Поиск ID invoice для double_global , invoice_id=c_doc_id(double_global)  */
                            SELECT invoice_id
                              FROM APPS.ap_invoices_all
                             WHERE INVOICE_NUM = '3136376') /* Номер Invoice*/ 
         AND g1.D_ENTITY_CODE = 'AP_INVOICES'               /*Фильтрация только Invoice*/ 
         AND g1.D_SEGMENT2 = '1013'                         /* Дт-ый счет*/ 
ORDER BY g1.D_ACCOUNTING_DATE,
         g1.ENTERED_AMOUNT,
         g1.DOUBLE_GLOBAL_ID,
         g1.C_DOC_NUM

/* Поиск транзакций по Item-y за дату */
  SELECT
         g1.*
    FROM xxtg.xxtg_gl001_double_global g1
  WHERE     1 = 1
         AND (   D_AN_DESC_3 LIKE ('%PRA-LA1 Blue%')
              OR c_AN_DESC_3 LIKE ('%PRA-LA1 Blue%'))           /* Item code*/
         AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('28.11.2017', '.dd.mm.yyyy')
                                   AND TO_DATE ('28.11.2017', '.dd.mm.yyyy')
ORDER BY   
        g1.D_ACCOUNTING_DATE,
         g1.ENTERED_AMOUNT,
         g1.DOUBLE_GLOBAL_ID,
         g1.C_DOC_NUM
/*=======================================================================================*/ 

/* Поиск для поля d_an_code_1 в xxtg_gl001_double_global  */
SELECT VENDOR_ID, VENDOR_NAME
  FROM AP.AP_SUPPLIERS
 WHERE VENDOR_NAME LIKE '%Крупень%'
 
 /*  По 7303 "Не выбрано значение"  нужно привязать аналитику к AP Invoice № ''акт 7706  Павлов Александр Александрович вместо "не выбрано значение*/
UPDATE xxtg_gl001_double_global
   SET d_an_code_1 = '11071',
       d_an_desc_1 = 'Павлов Александр Александрович'
 WHERE DOUBLE_GLOBAL_ID IN (194450399) AND d_segment2 = '7303'
 
 /*По 7303 "Не выбрано значение"  нужно привязать аналитику к  AP Invoice № ''акт 7789  Крупень Кирилл Николаевич вместо "не выбрано значение */
UPDATE xxtg_gl001_double_global
   SET d_an_code_1 = '294288',
       d_an_desc_1 = 'Крупень Кирилл Николаевич'
 WHERE DOUBLE_GLOBAL_ID IN (194450401) AND d_segment2 = '7303'
 
 /* ПО Кт9702 КАУ1 должно быть "Страхование имущества, сертификация"*/
UPDATE xxtg_gl001_double_global
   SET c_an_code_1 = '037',
       c_an_desc_1 =
          'Страхование имущества, сертификация'
 WHERE     c_doc_num IN ('ПЕ0193421')
       AND c_an_desc_1 = '- Не выбрано значение'
       AND c_accounting_date = TO_DATE ('31.03.2018', 'DD.MM.YYYY')

/*По Дт 9020 КАУ1 должно быть "Прочие доходы/расходы*/
UPDATE xxtg_gl001_double_global
   SET d_an_code_1 = '33',
       d_an_desc_1 = 'Прочие доходы/расходы'
 WHERE     c_doc_num IN ('б/н взносы GSM на 2017год')
       AND d_an_code_1 = '139'
       
