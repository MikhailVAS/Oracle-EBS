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
 
 
 /* AP invoice without receipts */
SELECT DISTINCT aia.*
  FROM ap_invoice_distributions_all aid, ap_invoices_all aia
 WHERE     1 = 1
       AND aia.invoice_id = aid.invoice_id
       AND aia.INVOICE_DATE >= TO_DATE ('01.01.2020', 'dd.mm.yyyy')
       AND PO_DISTRIBUTION_ID IS NULL
	   
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
SET DOC_STATUS = 'NEW'
WHERE 1 != 1
AND ID = 573073;
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

/*##### Formatted on Service Desk 539444 Mihail.Vasiljev #####*/
UPDATE /*+ index(XXTG_EHSCHF_ISSUANCE, XXTG_EHSCHF_ISSUANCE_U1) */
       XXTG_EHSCHF_ISSUANCE
   SET DOC_STATUS = 'COMPLETED',
       LAST_UPDATE_DATE =
           TO_DATE ('10/11/2021 11:00:15', 'DD/MM/YYYY HH24:MI:SS'),
           DATE_ISSUANCE    = to_date(CREATION_DATE,'dd.mm.yyyy'),
       FILE_NAME =
              'invoice-'
           || INVOICE_FILE_NUMBER
           || '-status-2021_11_10-COMPLETED.xml'
WHERE     DOC_STATUS = 'XML_CREATED'
       AND INVOICE_FILE_NUMBER IN
               ('600274554-2021-0000000174');
--====================================================			


/* Formatted on 19.11.2021 19:46:37 (QP5 v5.326) Service Desk 541757 Mihail.Vasiljev 
 Mass update date in ESCF  */
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


/* Formatted on(QP5 v5.326) Service Desk 574946 Mihail.Vasiljev 
 Oksana podpisala na portale
 Mass update date in ESCF  */
DECLARE
    l_output   SYS_REFCURSOR;
BEGIN
    FOR r
        IN (SELECT INVOICE_FILE_NUMBER     AS EINVOICE_NUMBER,
       TO_DATE ('25.04.2022 11:00:00', 'dd.mm.yyyy hh24:mi:ss')         AS SIGNATURE_DATE
  FROM XXTG_EHSCHF_ISSUANCE
 WHERE INVOICE_FILE_NUMBER IN ('400088851-2017-0000000001',
                               '100286730-2020-1000000116',
                               '100286730-2020-1000000184',
                               '100286730-2020-0000078065',
                               '100286730-2020-0000078052',
                               '101120215-2017-8000022861',
                               '101120215-2017-8000035131',
                               '291313486-2020-1290128135',
                               '291313486-2020-1290133777',
                               '300194035-2020-0000001398',
                               '200132326-2018-0000000108',
                               '490779270-2018-0000000870',
                               '700048108-2020-0000000561',
                               '690591512-2019-0000000678',
                               '790687748-2021-0000000100',
                               '190230915-2019-0000000991',
                               '190230915-2019-0000000992',
                               '700087591-2020-0000000560',
                               '700087591-2018-0000000251',
                               '700087591-2021-0000000054',
                               '700087591-2019-0000000133',
                               '791245970-2021-0000000049',
                               '791245970-2021-0000000050',
                               '400395983-2021-9310009233',
                               '100028877-2021-0000008214',
                               '100028877-2021-0000009213',
                               '790375165-2017-0000000998',
                               '200269163-2018-0000000010'))
    LOOP

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
                       || ' 11:00:05',
                       'DD/MM/YYYY HH24:MI:SS')
              FROM XXTG_EHSCHF_ISSUANCE
             WHERE INVOICE_FILE_NUMBER = r.EINVOICE_NUMBER;

        COMMIT;
    END LOOP;
END;