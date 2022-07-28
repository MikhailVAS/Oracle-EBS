/* Formatted on 30.11.2021 11:29:39 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
  SELECT ROWID,
         IS_VALID,
         FILE_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_LOGIN,
         VALIDATION_ERROR,
         OPERATING_UNIT,
         INVOICE_TYPE,
         BUDGET_ITEM_CODE,
         BUDGET_ITEM_DESC,
         PAYMENT_DATE,
         VENDOR_ID,
         VENDOR_NAME,
         VENDOR_SITE_CODE,
         PAYMENT_AMOUNT,
         PAYMENT_CURRENCY_CODE,
         CONTRACT_ID,
         CONTRACT_NO,
         DESCRIPTION,
         PAYMENT_METHOD,
         EXT_BANK_ACCOUNT_ID,
         BANK_ACCOUNT_NUMBER,
         MFO,
         PO_NUMBER,
         INVOICE_DATE,
         INVOICED_VENDOR_NAME
    FROM XXTG_PREPAYMENT_INVOICE_UPLOAD
    WHERE CREATION_DATE > sysdate - 1
--   WHERE HEADER_ID IS NULL AND (FILE_ID = '926096')
--ORDER BY VALIDATION_ERROR NULLS LAST, VENDOR_NAME, CONTRACT_NO

/* Update Prepayment Invoices by FileID */
UPDATE APPS.XXTG_PREPAYMENT_INVOICE_UPLOAD
   SET PAYMENT_DATE = TO_DATE (:date_pay, 'dd.mm.yyyy')
 WHERE HEADER_ID IS NULL AND (FILE_ID = :file_id)
 
  /*Update Prepayment Invoices by Date, Service Desk 543914 Mihail.Vasiljev */
UPDATE APPS.XXTG_PREPAYMENT_INVOICES
   SET PERIOD_NAME = :PERIOD_NAME,
       PAYMENT_DATE = TO_DATE ( :date_pay, 'dd.mm.yyyy')
 WHERE CREATION_DATE BETWEEN TO_DATE ('01.12.2021 00:00:00', 'dd.mm.yyyy hh24:mi:ss')  AND TO_DATE ('01.12.2021 23:59:00', 'dd.mm.yyyy hh24:mi:ss')   
  AND PERIOD_NAME = 'JAN-70'
                                                  
/*Update Communal Management Screen BeST by Date, Service Desk 543914 Mihail.Vasiljev */
UPDATE APPS.xxtg_communal_invoices
   SET PERIOD_NAME = :PERIOD_NAME,
       PAYMENT_DATE = TO_DATE ( :date_pay, 'dd.mm.yyyy')
 WHERE header_ID IN
           (SELECT HEADER_ID
              FROM xxtg_communal_inv_lines
             WHERE                                   -- (HEADER_ID = '163114')
                   CREATION_DATE BETWEEN TO_DATE ('30.11.2021 00:00:00',
                                                  'dd.mm.yyyy hh24:mi:ss')
                                     AND TO_DATE ('30.11.2021 23:59:00',
                                                  'dd.mm.yyyy hh24:mi:ss'))
       AND PERIOD_NAME = 'JAN-70'
                                                  
/* Update Communal Management Screen BeST by DOCUMENT_NAME,  Service Desk 543914 Mihail.Vasiljev */
UPDATE APPS.xxtg_communal_invoices
   SET PERIOD_NAME = :PERIOD_NAME,
       PAYMENT_DATE = TO_DATE ( :date_pay, 'dd.mm.yyyy')
 WHERE DOCUMENT_NAME = :DOCUMENT_NAME