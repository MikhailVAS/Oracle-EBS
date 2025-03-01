/* Проверка статуса batch*/
SELECT sca.STATUS , sca.*
  FROM ap.ap_inv_selection_criteria_all sca
 WHERE checkrun_name = '30 08 18 6'
 
 /* Просмотр всех документов (Платежей) в бетче */
SELECT *
  FROM ap.AP_SELECTED_INVOICES_ALL
 WHERE checkrun_name = '30 08 18 6' 

/* Отмена оплаты из  строки batch из-за длинного назначения платежа ( Поле пустое) */
UPDATE ap.AP_PAYMENT_SCHEDULES_ALL
   SET checkrun_id = NULL
 WHERE invoice_id IN (603451)

/* Отмена строки batch из-за длинного назначения платежа ( Поле пустое)  */
DELETE FROM ap.AP_SELECTED_INVOICES_ALL
      WHERE invoice_id IN (603451)


 /* All Payment by Checkrun_name */
SELECT *
  FROM IBY_DOCS_PAYABLE_ALL
 --WHERE DOCUMENT_PAYABLE_ID = '878082'
 WHERE     CREATION_DATE > SYSDATE - 3
       AND DOCUMENT_STATUS != 'PAYMENT_CREATED'
       AND FORMATTING_PAYMENT_ID IN
               (SELECT PAYMENT_ID
                  FROM IBY_PAYMENTS_ALL
                 WHERE PAYMENT_PROCESS_REQUEST_NAME IN ('13 08 24 (3)'))
                 
                 
/*Find  Payment by Checkrun_name */
SELECT PAYMENT_REFERENCE_NUMBER
  FROM IBY_PAYMENTS_ALL
 WHERE PAYMENT_PROCESS_REQUEST_NAME IN ('13 08 24 (3)')

--################# Payment Batch error with inorrect bank Acount ###################

/* Formatted on (QP5 v5.388) Service Desk 673675 Mihail.Vasiljev */
UPDATE ap.AP_PAYMENT_SCHEDULES_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID =
           (SELECT EXT_BANK_ACCOUNT_ID
              FROM iby_ext_bank_accounts
             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988')
--SELECT * FROM ap.AP_PAYMENT_SCHEDULES_ALL
 WHERE invoice_id IN (1151154, 1159025, 1167957)
 
/* Formatted on (QP5 v5.388) Service Desk 673675 Mihail.Vasiljev */
UPDATE ap.AP_SELECTED_INVOICES_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID =
           (SELECT EXT_BANK_ACCOUNT_ID
              FROM iby_ext_bank_accounts
             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988')
--SELECT * FROM ap.AP_SELECTED_INVOICES_ALL
 WHERE invoice_id IN (1151154, 1159025, 1167957)

/* Formatted on (QP5 v5.388) Service Desk 673675 Mihail.Vasiljev */
UPDATE ap.ap_invoices_all
   SET EXTERNAL_BANK_ACCOUNT_ID =
           (SELECT EXT_BANK_ACCOUNT_ID
              FROM iby_ext_bank_accounts
             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988')
--             SELECT * FROM ap.ap_invoices_all
 WHERE invoice_id IN (1151154, 1159025, 1167957)

/* Formatted on (QP5 v5.388) Service Desk 673675 Mihail.Vasiljev */
UPDATE IBY_DOCS_PAYABLE_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID =
           (SELECT EXT_BANK_ACCOUNT_ID
              FROM iby_ext_bank_accounts
             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988')           
-- SELECT * FROM IBY_DOCS_PAYABLE_ALL
 WHERE CALLING_APP_DOC_UNIQUE_REF2 IN (1151154, 1159025, 1167957)
 
-- EXT_BANK_ACCOUNT_ID     BRANCH_ID   BANK_ACCOUNT_NUM
--40235                   819693      TR640014300000000013498988   -- Good
--28045                   51398       TR740006400000212990420402   -- Bed

/* Formatted on (QP5 v5.388) Service Desk 673675 Mihail.Vasiljev */
UPDATE iby_payments_all
   SET EXTERNAL_BANK_ACCOUNT_ID =
           (SELECT EXT_BANK_ACCOUNT_ID
              FROM iby_ext_bank_accounts
             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988'),
       EXT_BANK_ACCOUNT_NUMBER = 'TR640014300000000013498988',
       EXT_BANK_ACCOUNT_IBAN_NUMBER = 'TR640014300000000013498988', --       EXT_BANK_ACCOUNT_NUMBER =
       --           (SELECT EXT_BANK_ACCOUNT_ID
       --              FROM iby_ext_bank_accounts
       --             WHERE BANK_ACCOUNT_NUM = 'TR640014300000000013498988'),
       EXT_BANK_BRANCH_NAME = 'ISTANBUL. TURKEY',
       EXT_BANK_ACCOUNT_NAME = 'AKTIF YATIRIM BANKASI A.S.',
       EXT_BANK_NAME = 'AKTIF YATIRIM BANKASI A.S.',
       EXT_EFT_SWIFT_CODE = 'CAYTTRISXXX',
       EXT_BANK_BRANCH_PARTY_ID = '831050',
       EXT_BANK_ACCOUNT_NUM_ELEC = 'TR640014300000000013498988'
 WHERE     PAYMENT_DATE = TO_DATE ('26.04.2023', 'dd.mm.yyyy')
       AND PAYMENT_ID = 806071

 --##############################################################################

select * from ap.ap_invoices_all where invoice_num in ('��� 101')

select * from ap.ap_invoices_all where invoice_num in ('��� 101')

select * from ap.ap_invoice_distributions_all where invoice_id=267336

1272498

select * from xla.xla_events where event_id=2905103

select * from xla.xla_ae_headers where event_id=2905103

select * from ap.ap_checks_all

select * from ap.AP_PREPAY_HISTORY_ALL

select * from ap.AP_INVOICE_PAYMENTS_ALL where invoice_id in (267485,267481,267480,267336)

select * from ap.AP_PAYMENT_SCHEDULES_ALL where invoice_id in (267336,200808,87862)  --checkrun_id  31179

select * from ap.AP_SELECTED_INVOICES_ALL where invoice_id in (267336,200808,87862) --where invoice_id in (265592,265591)

SELECT * FROM ap.ap_inv_selection_criteria_all where checkrun_name='27.01.15_18'

select * from apps.XXTG_TYPE_OPER_INC_9900_V

select * from ap.AP_SELECTED_INVOICE_CHECKS_ALL

edit ap.AP_PAYMENT_SCHEDULES_ALL where invoice_id in  (267336,200808,87862)    --31379

select * from xxtg.xxtg_gl001_double_global where c_doc_num='��� 101'

select * from xla.xla_ae_headers where ae_header_id=278533313

select * from xla.xla_ae_lines where ae_header_id=278533313

/*It happens in Release 12 environment often,
What actually happens is, even though from front end , you have submitted the request for Terminating the PPR, the process some how does not complete successfully, therefore back end data remains the same....
you can cross check the status of the PPR from the back end... and make it cancelled
so that your invoices will be released.
This can be achieved by datafixes.*/

--First Check the Status of your Payment Process Request from table,
Select * from AP_INV_SELECTION_CRITERIA_ALL where Checkrun_name = 'Your PPR Name'
--This will display the the details of the PPR, in which under the column STATUS , verify whether it is CANCELED or not, if it is not cancelled, then perform the below datafixes to make the PPR cancelled and release the invoices

--First to Release the invoices,
Delete from AP_SELECTED_INVOICES_ALL where Checkrun_ID = 'Your check run id for the PPR'

--Second to remove the Payment references saved to your selected invoices,
update AP_SCHEDULED_PAYMENTS_ALL set Checkrun_ID = NULL where Checkrun_ID = 'Your check run id for the PPR'

--Finally to change the status of the PPR to cancelled,
Update AP_INV_SELECTION_CRITERIA_ALL set Status = 'CANCELED' where Checkrun_name = 'Your PPR Name'

--Now check the status of the invoices....


/* 1 Final acc Payment - Do not reformat accounting in the future */
UPDATE xla_events
   SET EVENT_STATUS_CODE = 'P', PROCESS_STATUS_CODE = 'P'                --U D
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE ENTITY_CODE = 'AP_PAYMENTS' AND SOURCE_ID_INT_1 = '635488') -- Payment Num
           

/* 2 Final acc Payment - Do not reformat accounting in the future */
UPDATE xla_ae_headers h
   SET ACCOUNTING_ENTRY_STATUS_CODE = 'F'-- D
       , FUNDS_STATUS_CODE = 'S'         -- null
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE ENTITY_CODE = 'AP_PAYMENTS' AND SOURCE_ID_INT_1 = '635488') -- Payment Num
            
DELETE FROM  xxtg.xxtg_gl001_double_global
 WHERE     (C_DOC_NUM IN ('635488') OR d_DOC_NUM IN ('635488')) -- PaymentNum
       AND D_ENTITY_CODE = 'AP_PAYMENTS'
       AND ACCOUNTED_AMOUNT = 0.01
--       AND DOUBLE_GLOBAL_ID = 400453534;

UPDATE xxtg.xxtg_gl001_double_global
   SET ACCOUNTED_AMOUNT = 6347.32
 WHERE     (C_DOC_NUM IN ('635488') OR d_DOC_NUM IN ('635488'))  -- PaymentNum
       AND D_ENTITY_CODE = 'AP_PAYMENTS'
       AND ACCOUNTED_AMOUNT = 6347.31