/* Восстановление ЭСЧФ */ 

-- INVOICE_ID = 622172
SELECT * FROM xla.xla_transaction_entities te where   te.SOURCE_ID_INT_1 = 622172 and ENTITY_CODE = 'ENTITY_CODE';

SELECT * FROM  xla.xla_ae_headers aeh where  aeh.ENTITY_ID = 5588673;

/*Для исключения пересчёта по инвойсу в double global */
UPDATE xla.xla_ae_headers aeh
   SET ATTRIBUTE10 = 'Y'
 WHERE aeh.ENTITY_ID = 5588673;

/* Обнуление даты для  изменения статуса canceled */
UPDATE APPS.ap_invoices_all
   SET cancelled_date = NULL
 WHERE 1 = 1 AND INVOICE_ID = 622172;

/* Проверка статусов */
SELECT ai.cancelled_date,
       AI.INVOICE_TYPE_LOOKUP_CODE,
       AI.APPROVAL_DESCRIPTION,
       AI.APPROVAL_ITERATION,
       AI.APPROVAL_READY_FLAG,
       AI.APPROVAL_STATUS,
       AP_INVOICES_PKG.GET_APPROVAL_STATUS (AI.INVOICE_ID,
                                            AI.INVOICE_AMOUNT,
                                            AI.PAYMENT_STATUS_FLAG,
                                            AI.INVOICE_TYPE_LOOKUP_CODE)
           APPROVAL_STATUS_LOOKUP_CODE
  /*
  AI.APPROVAL_DESCRIPTION,
  AI.APPROVAL_ITERATION,
  AI.APPROVAL_READY_FLAG,
  AI.APPROVAL_STATUS,
  AP_INVOICES_PKG.GET_APPROVAL_STATUS(AI.INVOICE_ID,
                                      AI.INVOICE_AMOUNT,
                                      AI.PAYMENT_STATUS_FLAG,
                                      AI.INVOICE_TYPE_LOOKUP_CODE) APPROVAL_STATUS_LOOKUP_CODE
   */
  FROM AP_INVOICES_ALL AI
 ---where AI.APPROVAL_STATUS is not null
 WHERE 1 = 1                      --AI.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
             AND AI.INVOICE_ID = 622172
--AND AI.GLOBAL_ATTRIBUTE6 is not null
;