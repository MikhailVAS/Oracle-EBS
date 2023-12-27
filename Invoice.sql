/*=================== Change invoice type ====================== */
UPDATE APPS.FND_FLEX_VALUES  SET FLEX_VALUE = 'NEW' WHERE FLEX_VALUE = 'OLD';

UPDATE APPS.FND_FLEX_VALUES SET PARENT_FLEX_VALUE_LOW = 'NEW' WHERE PARENT_FLEX_VALUE_LOW = 'OLD';

UPDATE XXTG_AP_INVOICE_ACCOUNT_SETUP SET INVOICE_TYPE = 'NEW' WHERE INVOICE_TYPE = 'OLD';

UPDATE FND_LOOKUP_VALUES SET LOOKUP_CODE = UPPER('NEW') ,MEANING = 'NEW' ,DESCRIPTION = 'NEW'  WHERE MEANING = 'OLD';

UPDATE AP_INVOICES_ALL SET ATTRIBUTE5 = 'NEW' WHERE ATTRIBUTE5 =  'OLD';

UPDATE XXTG_OTF_HEADERS_ALL SET OTF_PAYMENT_CODE = 'NEW' WHERE OTF_PAYMENT_CODE = 'OLD';

UPDATE xxtg_otf_payment_codes SET OTF_PAYMENT_CODE = 'NEW' , DESCRIPTION = 'NEW' WHERE OTF_PAYMENT_CODE = 'OLD';

UPDATE xxtg_otf_dep_payment_codes SET OTF_PAYMENT_CODE = 'NEW' WHERE  OTF_PAYMENT_CODE = 'OLD';

/*============================================================== */


/* Опредиление дубликатов инвойсов */
  SELECT INVOICE_NUM, SENDER, TO_CHAR (CREATION_DATE, 'yyyy') AS CREATION_DATE
    FROM XXTG.XXTG_EHSCHF_ISSUANCE t
   WHERE 1 = 1
GROUP BY INVOICE_NUM, SENDER, TO_CHAR (CREATION_DATE, 'yyyy')
  HAVING COUNT (1) > 1
ORDER BY CREATION_DATE DESC

-- =ЛЕВСИМВ(ПРАВСИМВ(RC[-1];15);4) XLS  получение года ЭСЧФ

/* Получение  INVOICE_DISTRIBUTION по инвойсу и линии*/
SELECT INVOICE_DISTRIBUTION_ID, A.*
  FROM APPS.AP_INVOICE_DISTRIBUTIONS_ALL A
 WHERE invoice_id = '565826' AND (invoice_line_number = '1')
 
/* Получение  INVOICE_DISTRIBUTION по инвойсу */
SELECT *
  FROM AP.AP_INVOICE_DISTRIBUTIONS_ALL AID, AP_INVOICES_ALL AI1
 WHERE AID.INVOICE_ID = AI1.INVOICE_ID AND AID.invoice_id = '619543'
 
 /* Если не подставляется счёт в шапке инвойса*/ 
UPDATE APPS.ap_suppliers
   SET ATTRIBUTE3 = NULL
WHERE vendor_id = 727355
 
/* Обнуление неккоретного DISTRIBUTIONS */
UPDATE APPS.AP_INVOICE_DISTRIBUTIONS_ALL
   SET AMOUNT = 0, BASE_AMOUNT = 0
 WHERE     1 = 1
       AND INVOICE_DISTRIBUTION_ID IN ('3074429'
                                       '3074817');
									   
/* Нужно поменять дату в распределении в двух документах:
	1085478-с/ф 382 от 31.12.18
	1085467-с/ф 05294 от 31.12.18
	Сумма НДС с минусом села 01.01.19г., а нужно 31.12.18. */
UPDATE APPS.AP_INVOICE_DISTRIBUTIONS_ALL
   SET ACCOUNTING_DATE = TO_DATE ('31.12.2018', 'dd.mm.yyyy'),
       PERIOD_NAME = 'DEC-18'
 WHERE INVOICE_DISTRIBUTION_ID IN ('3333030',
                                   '3333032',
                                   '3332787',
                                   '3332789');
								  
/* Formatted on 05.02.2019 15:43:28 (QP5 v5.318) Service Desk 273723 Mihail.Vasiljev */
UPDATE AP.AP_INVOICE_LINES_all
   SET TOTAL_REC_TAX_AMOUNT = 0,
       TOTAL_REC_TAX_AMT_FUNCL_CURR = 0,
       INCLUDED_TAX_AMOUNT = 0
 WHERE invoice_id = '648676'
 
/* Formatted on 05.02.2019 16:09:38 (QP5 v5.318) Service Desk 273723 Mihail.Vasiljev */
UPDATE APPS.ZX_LINES ZL
   SET ZL.TAX_AMT = 0,
       ZL.ORIG_TAX_AMT = 0,
       ZL.UNROUNDED_TAX_AMT = 0,
       ZL.CANCEL_FLAG = 'Y'
 WHERE ZL.TAX_LINE_ID = 12390313;

 
/* Find Billing Error in OEBS by AUG-22*/
SELECT *
  --ORIG_INVOICE_NUMBER
  FROM XXTG_EHSCHF_ISSUANCE
 WHERE     -- INVOICE_NUM = '1420842891'
           DOC_TYPE = 'OUTCOMING'
       AND DOC_STATUS = 'ERROR'
       AND DATE_TRANSACTION BETWEEN TO_DATE ('01.08.2022', 'dd.mm.yyyy')
                                AND TO_DATE ('31.08.2022', 'dd.mm.yyyy')
       AND ERROR_MESSAGES LIKE
               '%Технические детали: ORA-29532: вызов Java прерван неустановленным исключением Java: oracle.xml.parser.v2.XMLParseException: Missing Attribute%'
 

 /* Find Billing Error by AUG-22 */
SELECT DISTINCT *
  FROM apps.MONTHLY_BILLS_DETAILS bd
 WHERE     bd.MONTH = 202208                                         -- AUG-22
       AND INVOICE_NUMBER IN
               (SELECT ORIG_INVOICE_NUMBER
                  FROM XXTG_EHSCHF_ISSUANCE
                 WHERE     DOC_TYPE = 'OUTCOMING'
                       AND DOC_STATUS = 'ERROR'
                       AND DATE_TRANSACTION BETWEEN TO_DATE ('01.08.2022',
                                                             'dd.mm.yyyy')
                                                AND TO_DATE ('31.08.2022',
                                                             'dd.mm.yyyy'))


 SELECT SUM (bd.CHARGE) AS CHARGE,
       SUM (bd.CLEAN_CHARGE) AS "CLEAN_CHARGE(P_ITEM_COST)",
       SUM (ROUND (CLEAN_CHARGE / 100 * VAT_RATE, 6)) AS "OEBS_SUM_TAX(P_VAT_SUMMA)",
       SUM (ROUND (CLEAN_CHARGE, 2) + ROUND (CLEAN_CHARGE / 100 * VAT_RATE, 2)) AS "OEBS_COST_VAT(P_COST_VAT)"
  FROM apps.MONTHLY_BILLS_DETAILS bd
 WHERE     bd.MONTH = 202205
       AND bd.UNP_CODE = '291664169'
       AND bd.INVOICE_NUMBER = '307069156-052022/1'
       AND bd.VAT_RATE = 25

 /* Find biling eInvoice */
SELECT *
  FROM XXTG_EHSCHF_ISSUANCE   xei,
       XXTG_EHSCHF_RECIPIENT  xer,
       XXTG_EHSCHF_ROSTER     ros
 WHERE xer.issuance_id = xei.id
       AND ros.issuance_id = xei.id
       --AND ORIG_UNP_CODE = '192749704'
--       AND INVOICE_FILE_NUMBER = '190579561-2022-1420803518'
       AND UNP = '190406628'
       AND DOC_TYPE = 'OUTCOMING'

/* Find eInvoice */
SELECT *
  FROM XXTG_EHSCHF_ISSUANCE   
 WHERE  INVOICE_FILE_NUMBER = '190579561-2022-1420803518'

 /* =========================== Find Error =============================*/
SELECT *
  FROM XXTG.XXTG_EHSCHF_ISSUANCE XEIS
 WHERE     XEIS.ID >= 2237479
       AND ERROR_MESSAGES IS NOT NULL
       AND DATE_TRANSACTION BETWEEN TO_DATE ('01.08.2022', 'dd.mm.yyyy')
                                AND TO_DATE ('31.08.2022', 'dd.mm.yyyy')      
       

SELECT *
  FROM XXTG.XXTG_EHSCHF_AR_INV XEAI, XXTG.XXTG_EHSCHF_ISSUANCE XEIS
 WHERE     XEAI.ISSUANCE_ID = XEIS.ID
      -- AND XEIS.ID >= 2237479
       AND ERROR_MESSAGES IS NOT NULL
       AND XEAI.TRX_DATE BETWEEN TO_DATE ('01.08.2022', 'dd.mm.yyyy')
                             AND TO_DATE ('31.08.2022', 'dd.mm.yyyy')
/* ===================================================================== */
 
 /* Find AP invoice */
SELECT *
  FROM XXTG_EHSCHF_AP_INV
 WHERE ISSUANCE_NUM = '1420847248'
 
 /* AP invoice without receipts */
SELECT DISTINCT aia.*
  FROM ap_invoice_distributions_all aid, ap_invoices_all aia
 WHERE     1 = 1
       AND aia.invoice_id = aid.invoice_id
       AND aia.INVOICE_DATE >= TO_DATE ('01.01.2020', 'dd.mm.yyyy')
       AND PO_DISTRIBUTION_ID IS NULL

/* Find AR Invoice by Invoice file number */
SELECT *
  FROM APPS.XXTG_EHSCHF_AR_INV
 WHERE INVOICE_NUM IN
           (SELECT INVOICE_NUM
              FROM XXTG.XXTG_EHSCHF_ISSUANCE
             WHERE INVOICE_FILE_NUMBER IN ('190579561-2023-1420945406',
                                           '190579561-2023-1420945431',
                                           '190579561-2023-1420946469',
                                           '190579561-2023-1420946471',
                                           '190579561-2023-1420946593'))
	   
--==============================================================
--1. Пришла заявка, что ЭСЧФ на портале не от того контрагента
--2. Миша проверяет, исходящая ли это ЭСЧФ (на основе AR инвойса), существуют ли дубли реально
select *
FROM XXTG.XXTG_EHSCHF_AR_INV XEAI,
XXTG.XXTG_EHSCHF_ISSUANCE XEIS
WHERE 1=1--XEAI.CUSTOMER_TRX_ID = REC_HEADER.CUSTOMER_TRX_ID
AND XEAI.ISSUANCE_ID = XEIS.ID
and XEAI.INVOICE_NUM = '1410192737';
--3. Миша ищет полный список ВОЗМОЖНЫХ дублей и отправляет список в ответ создавшей заявку бухгалтеру с вопросом 
--"Каким из этих AR-инвойсов нужно обновить статус для возможности выгрузки под новыми номерами на портал (раз старые номера заняты)?
--Отметьте нужные строки в файле зелёным цветом."
select XEIS.INVOICE_FILE_NUMBER, TRX_NUMBER "AR-инвойс", TRX_DATE "Дата транзакции", CUSTOMER_TRX_ID "ИД AR-инвойса"
from XXTG.XXTG_EHSCHF_AR_INV   XEAI,
     XXTG.XXTG_EHSCHF_ISSUANCE XEIS
WHERE 1=1--XEAI.CUSTOMER_TRX_ID = REC_HEADER.CUSTOMER_TRX_ID
  AND XEAI.ISSUANCE_ID = XEIS.ID
  AND XEAI.INVOICE_NUM in(select INVOICE_NUM
                          from XXTG_EHSCHF_AR_INV
                          where 1 = 1
                          GROUP BY INVOICE_NUM
                          having count(1) > 1)
ORDER BY XEAI.INVOICE_NUM;
--4. Бухгалтер проверяет список, отмечает зелёным строки что будет надо грузить, высылает Мише.
--5. После проверки наличия ошибки Миша берёт ISSUANCE_ID тех записи, которую надо обновить для загрузки на портал и обновляет статус:
UPDATE XXTG.XXTG_EHSCHF_ISSUANCE
SET DOC_STATUS = 'NEW',
               INVOICE_NUM =
                   (SELECT INVOICE_NUM + 1 FROM XXTG_EHSCHF_INVOICES), --Seq+1
               XML_DOCUMENT = NULL,
               XML_FILE = NULL,
               FILE_NAME = NULL,
               INVOICE_FILE_NUMBER = NULL
WHERE 1 != 1
AND ID = 573073;

UPDATE APPS.XXTG_EHSCHF_INVOICES
           SET INVOICE_NUM = INVOICE_NUM + 1, LAST_UPDATED_DATE = SYSDATE;
--6. Сообщает бухгалтеру, что статус документов обновлён и можно выполнять по ним действия, начиная
-- с п.5 инструкции Шириной. Если бух возбухает - Миша может согласиться провести документ по статусам за неё,
-- но только в качестве исключения, потому что выверять перед отправкой должна бух.

/*########### Invoice Num ########### */
SELECT r.DOC_SEQUENCE_VALUE, r.*
  FROM RA_CUSTOMER_TRX_ALL r
 WHERE r.TRX_NUMBER IN ('УН 0472857', '220003361');


DECLARE
BEGIN
    FOR r
        IN (/* Formatted on 07.07.2021 21:34:55 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT XEAI.ISSUANCE_ID
  FROM XXTG.XXTG_EHSCHF_AR_INV XEAI, XXTG.XXTG_EHSCHF_ISSUANCE XEIS
 WHERE     1 = 1           --XEAI.CUSTOMER_TRX_ID = REC_HEADER.CUSTOMER_TRX_ID
       AND XEAI.ISSUANCE_ID = XEIS.ID
       AND XEAI.TRX_NUMBER IN ('552/08/17-042019'))
    LOOP
        UPDATE XXTG.XXTG_EHSCHF_AR_INV
           SET INVOICE_NUM =
                   (SELECT INVOICE_NUM + 1 FROM XXTG_EHSCHF_INVOICES)  --Seq+1
         WHERE ISSUANCE_ID = r.ISSUANCE_ID;

        UPDATE XXTG.XXTG_EHSCHF_ISSUANCE
           SET DOC_STATUS = 'NEW',
               INVOICE_NUM =
                   (SELECT INVOICE_NUM + 1 FROM XXTG_EHSCHF_INVOICES), --Seq+1
               XML_DOCUMENT = NULL,
               XML_FILE = NULL,
               FILE_NAME = NULL,
               INVOICE_FILE_NUMBER = NULL
         WHERE ID = r.ISSUANCE_ID;

        UPDATE APPS.XXTG_EHSCHF_INVOICES
           SET INVOICE_NUM = INVOICE_NUM + 1, LAST_UPDATED_DATE = SYSDATE;

        DBMS_OUTPUT.put_line ('ISSUANCE_ID:' || r.ISSUANCE_ID);
        COMMIT;
    END LOOP;
END;


/* Formatted on 09.02.2022 13:54:35 (QP5 v5.326) Service Desk 561258 Mihail.Vasiljev */
DECLARE
BEGIN
    FOR r
        IN (SELECT XEAI.ISSUANCE_ID
              FROM XXTG.XXTG_EHSCHF_AR_INV    XEAI,
                   XXTG.XXTG_EHSCHF_ISSUANCE  XEIS
             WHERE     1 = 1 --XEAI.CUSTOMER_TRX_ID = REC_HEADER.CUSTOMER_TRX_ID
                   AND XEAI.ISSUANCE_ID = XEIS.ID
                   AND XEAI.INVOICE_NUM IN (  SELECT INVOICE_NUM
                                                FROM XXTG_EHSCHF_AR_INV
                                               WHERE 1 = 1
                                            GROUP BY INVOICE_NUM
                                              HAVING COUNT (1) > 1)
                   AND XEAI.CREATION_DATE >
                       TO_DATE ('07.02.2022 10:49:01',
                                'dd.mm.yyyy hh24:mi:ss'))
    LOOP
        UPDATE XXTG.XXTG_EHSCHF_AR_INV
           SET INVOICE_NUM =
                   (SELECT INVOICE_NUM + 1 FROM XXTG_EHSCHF_INVOICES)  --Seq+1
         WHERE ISSUANCE_ID = r.ISSUANCE_ID;

        UPDATE XXTG.XXTG_EHSCHF_ISSUANCE
           SET DOC_STATUS = 'NEW',
               INVOICE_NUM =
                   (SELECT INVOICE_NUM + 1 FROM XXTG_EHSCHF_INVOICES), --Seq+1
               XML_DOCUMENT = NULL,
               XML_FILE = NULL,
               FILE_NAME = NULL,
               INVOICE_FILE_NUMBER = NULL
         WHERE ID = r.ISSUANCE_ID;

        UPDATE APPS.XXTG_EHSCHF_INVOICES
           SET INVOICE_NUM = INVOICE_NUM + 1, LAST_UPDATED_DATE = SYSDATE;

        DBMS_OUTPUT.put_line ('ISSUANCE_ID:' || r.ISSUANCE_ID);
        COMMIT;
    END LOOP;
END;


    UPDATE XXTG.XXTG_EHSCHF_ISSUANCE
       SET DOC_STATUS = 'NEW'
     WHERE ID IN
               (
SELECT XEAI.ISSUANCE_ID
  FROM XXTG.XXTG_EHSCHF_AR_INV XEAI, XXTG.XXTG_EHSCHF_ISSUANCE XEIS
 WHERE     1 = 1           --XEAI.CUSTOMER_TRX_ID = REC_HEADER.CUSTOMER_TRX_ID
       AND XEAI.ISSUANCE_ID = XEIS.ID
       AND XEAI.TRX_NUMBER IN ('552/08/17-042019'));

--====================================================
--SD 453044 нету даты подписания в ведомости, СРОЧНО!!!
UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
       XXTG_EHSCHF_ISSUANCE
   SET DOC_STATUS = 'COMPLETED_SIGNED',
       LAST_UPDATE_DATE =
           TO_DATE ('12/01/2021 11:00:15', 'DD/MM/YYYY HH24:MI:SS'),
       FILE_NAME =
              'invoice-'
           || INVOICE_FILE_NUMBER
           || '-status-2021_01_12-COMPLETED_SIGNED.xml'
 WHERE     DOC_STATUS != 'COMPLETED_SIGNED'
       AND INVOICE_FILE_NUMBER IN ('100071593-2021-2900000026');


UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
       XXTG_EHSCHF_KSF
   SET INVOICE_STATUS = 'COMPLETED_SIGNED',
       LAST_UPDATE_DATE =
           TO_DATE ('12/01/2021 11:00:15', 'DD/MM/YYYY HH24:MI:SS')
 WHERE     INVOICE_STATUS != 'COMPLETED_SIGNED'
       AND INVOICE_NUM IN ('100071593-2021-2900000026');

INSERT INTO XXTG_EHSCHF_HISTORY (ISSUANCE_ID,
                                 FILE_DATE,
                                 FILE_NAME,
                                 DOC_STATUS,
                                 LAST_UPDATE_DATE)
    SELECT /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
           ID,
           TO_DATE ('12/01/2021 11:00:15', 'DD/MM/YYYY HH24:MI:SS'),
              'invoice-'
           || INVOICE_FILE_NUMBER
           || '-status-2021_01_12-COMPLETED_SIGNED.xml',
           'COMPLETED_SIGNED',
           TO_DATE ('12/01/2021 6:00:04', 'DD/MM/YYYY HH24:MI:SS')
      FROM XXTG_EHSCHF_ISSUANCE
     WHERE INVOICE_FILE_NUMBER IN ('100071593-2021-2900000026');

--====================================================

-- Прошу поменять дату ГК с 01.01.21 на 31.12.20 в стандартных инвойсах		

UPDATE APPS.xxtg_otf_headers_all
   SET INVOICE_DATE = TO_DATE ('31122020', 'DDMMYYYY')
 WHERE     1 = 1
       AND OTF_PAYMENT_CODE = 'Коммунальные Услуги'
       AND STATUS = 'REVISE'
       AND CREATION_DATE >= TO_DATE ('24012021', 'DDMMYYYY')
       AND CREATION_DATE <= TO_DATE ('30012021', 'DDMMYYYY')
       AND INVOICE_DATE <> TO_DATE ('31012020', 'DDMMYYYY');
	   
/* Formatted on (QP5 v5.326) Service Desk 460771 Mihail.Vasiljev */
UPDATE APPS.xxtg_otf_headers_all
   SET INVOICE_DATE = TO_DATE ('31012021', 'DDMMYYYY')
 WHERE     1 = 1
       AND OTF_PAYMENT_CODE = 'Коммунальные Услуги'
       AND STATUS = 'REVISE'
       AND CREATION_DATE >= TO_DATE ('06012021', 'DDMMYYYY')
       AND CREATION_DATE <= TO_DATE ('18022021', 'DDMMYYYY')
       AND INVOICE_DATE <> TO_DATE ('31012021', 'DDMMYYYY')
 AND  CREATED_BY = '6336'  --Сельванович, Ольга Анатольевна
--====================================================			
-- Не обновились статусы исходящего ЭСЧФ
--====================================================			


/* Formatted on 19.11.2021 19:46:37 (QP5 v5.326) Service Desk 541757 Mihail.Vasiljev 
 Mass update date in ESCF by Upload File */
DECLARE
    l_output   SYS_REFCURSOR;
BEGIN
    FOR r
        IN (SELECT EINVOICE_NUMBER, SIGNATURE_DATE
              FROM XXTG.XXTG_EINVOICE_PORTAL_DATA_TMP  ES
                   LEFT JOIN XXTG_EHSCHF_ISSUANCE EI
                       ON ES.EINVOICE_NUMBER = EI.INVOICE_FILE_NUMBER
             WHERE DOC_STATUS = 'COMPLETED' --       AND DATE_TRANSACTION > TO_DATE ('01.10.2021', 'dd.mm.yyyy')
                                            AND FILE_NAME NOT LIKE '%status%')
    LOOP
        --            UPDATE ap.ap_suppliers sup
        --                SET sup.END_DATE_ACTIVE = TO_DATE (r.DATE_BLOCK, 'dd.mm.yyyy')
        --            WHERE sup.VAT_REGISTRATION_NUM = r.VAT_REGISTRATION_NUM

        UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
               XXTG_EHSCHF_ISSUANCE
           SET DOC_STATUS = 'COMPLETED_SIGNED',
               LAST_UPDATE_DATE =
                   TO_DATE (
                          ''
                       || TO_DATE (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 11:00:15',
                       'DD/MM/YYYY HH24:MI:SS'),
               FILE_NAME =
                      'invoice-'
                   || INVOICE_FILE_NUMBER
                   || '-status-'
                   || TO_DATE (r.SIGNATURE_DATE, 'yyyy_mm_dd')
                   || '-COMPLETED_SIGNED.xml'
         WHERE     DOC_STATUS != 'COMPLETED_SIGNED'
               AND INVOICE_FILE_NUMBER = r.EINVOICE_NUMBER;


        UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
               XXTG_EHSCHF_KSF
           SET INVOICE_STATUS = 'COMPLETED_SIGNED',
               LAST_UPDATE_DATE =
                   TO_DATE (
                          ''
                       || TO_DATE (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || '11:00:15',
                       'DD/MM/YYYY HH24:MI:SS')
         WHERE     INVOICE_STATUS != 'COMPLETED_SIGNED'
               AND INVOICE_NUM = r.EINVOICE_NUMBER;

        INSERT INTO XXTG_EHSCHF_HISTORY (ISSUANCE_ID,
                                         FILE_DATE,
                                         FILE_NAME,
                                         DOC_STATUS,
                                         LAST_UPDATE_DATE)
            SELECT /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
                   ID,
                   TO_DATE (
                          ''
                       || TO_DATE (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 11:00:15',
                       'DD/MM/YYYY HH24:MI:SS'),
                      'invoice-'
                   || INVOICE_FILE_NUMBER
                   || '-status-'
                   || TO_DATE (r.SIGNATURE_DATE, 'yyyy_mm_dd')
                   || '-COMPLETED_SIGNED.xml',
                   'COMPLETED_SIGNED',
                   TO_DATE (
                          ''
                       || TO_DATE (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 6:00:04',
                       'DD/MM/YYYY HH24:MI:SS')
              FROM XXTG_EHSCHF_ISSUANCE
             WHERE INVOICE_FILE_NUMBER = r.EINVOICE_NUMBER;

        COMMIT;
    END LOOP;
END;


/* Mass update date in ESCF  */
DECLARE
    l_output   SYS_REFCURSOR;
BEGIN
    FOR r
        IN (SELECT INVOICE_FILE_NUMBER     AS EINVOICE_NUMBER,
       TO_DATE ('28.11.2023', 'dd.mm.yyyy')         AS SIGNATURE_DATE
  FROM XXTG_EHSCHF_ISSUANCE
 WHERE  INVOICE_FILE_NUMBER in ('500036458-2017-0000010591',
                                    '101120215-2017-8000022761',
                                    '290479718-2017-0000000088',
                                    '101120215-2017-8000052481',
                                    '100071593-2017-1000000988',
                                    '101120215-2017-8000069011',
                                    '101120215-2017-8000069011',
                                    '300035579-2018-2000000181',
                                    '200050653-2019-5181101700',
                                    '100302629-2020-0000025660',
                                    '100308099-2020-1120184370',
                                    '100308099-2020-1120184627',
                                    '100308099-2020-1120184865',
                                    '100308099-2020-1120185095',
                                    '100308099-2020-1120185131',
                                    '100308099-2020-1120185269',
                                    '100308099-2020-1220253179',
                                    '100308099-2020-1220253448',
                                    '100308099-2020-1220253689',
                                    '100308099-2020-1220254075',
                                    '100308099-2020-1220254146',
                                    '200094005-2017-0000011551',
                                    '290479718-2017-0000000088',
                                    '391043096-2017-0000000164',
                                    '400026368-2017-0000000228',
                                    '400026368-2017-0000000315',
                                    '100302629-2020-0000025660',
                                    '101120215-2017-8000022761',
                                    '192579300-2019-0000000220',
                                    '100236027-2016-0500074539'))
    LOOP

        UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
               XXTG_EHSCHF_ISSUANCE
           SET DOC_STATUS = 'COMPLETED_SIGNED',
               LAST_UPDATE_DATE =
                   TO_DATE (
                          ''
                       || TO_CHAR (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 11:00:15',
                       'DD/MM/YYYY HH24:MI:SS'),
               FILE_NAME =
                      'invoice-'
                   || INVOICE_FILE_NUMBER
                   || '-status-'
                   || TO_CHAR (r.SIGNATURE_DATE, 'yyyy_mm_dd')
                   || '-COMPLETED_SIGNED.xml'
         WHERE     DOC_STATUS != 'COMPLETED_SIGNED' -- Comment if Try again 
               AND INVOICE_FILE_NUMBER = r.EINVOICE_NUMBER;


        UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
               XXTG_EHSCHF_KSF
           SET INVOICE_STATUS = 'COMPLETED_SIGNED',
               LAST_UPDATE_DATE =
                   TO_DATE (
                          ''
                       || TO_CHAR (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || '11:00:15',
                       'DD/MM/YYYY HH24:MI:SS')
         WHERE    INVOICE_STATUS != 'COMPLETED_SIGNED' -- Comment if Try again 
               AND INVOICE_NUM = r.EINVOICE_NUMBER;

        INSERT INTO XXTG_EHSCHF_HISTORY (ISSUANCE_ID,
                                         FILE_DATE,
                                         FILE_NAME,
                                         DOC_STATUS,
                                         LAST_UPDATE_DATE)
            SELECT /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
                   ID,
                   TO_DATE (
                          ''
                       || TO_CHAR (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 11:00:15',
                       'DD/MM/YYYY HH24:MI:SS'),
                      'invoice-'
                   || INVOICE_FILE_NUMBER
                   || '-status-'
                   || TO_CHAR (r.SIGNATURE_DATE, 'yyyy_mm_dd')
                   || '-COMPLETED_SIGNED.xml',
                   'COMPLETED_SIGNED',
                   TO_DATE (
                          ''
                       || TO_CHAR (r.SIGNATURE_DATE, 'dd/mm/yyyy')
                       || ' 11:00:05',
                       'DD/MM/YYYY HH24:MI:SS')
              FROM XXTG_EHSCHF_ISSUANCE
             WHERE INVOICE_FILE_NUMBER = r.EINVOICE_NUMBER;

        COMMIT;
    END LOOP;
END;

/* Проблема автосоздания ЭСЧФ по Аренде*/
BEGIN
    UPDATE XXTG.XXTG_EHSCHF_KSF
       SET FILE_NAME = 'invoice-' || invoice_num || '.sgn.xml'
     WHERE     1 = 1
           AND INVOICE_STATUS = 'COMPLETED'
           AND CREATION_DATE IS NOT NULL
           AND LAST_UPDATE_DATE =
               TO_DATE ('10.04.2023 16:56:17', 'dd.mm.yyyy hh24:mi:ss');

    COMMIT;

    XXTG_EHSCHF_AP_KSF_PKG.prepare_files;
END;