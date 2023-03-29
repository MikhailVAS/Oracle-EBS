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

--################# Payment Batch error with inorrect bank Acount ###################

/* Formatted on (QP5 v5.326) Service 667827 Desk Mihail.Vasiljev */
UPDATE ap.AP_PAYMENT_SCHEDULES_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID = '40016' -- BY34ALFA30122674810010270000
WHERE invoice_id IN (1160493,1160495,1160494)

/* Formatted on  (QP5 v5.326) Service Desk 667827 Mihail.Vasiljev */
UPDATE ap.AP_SELECTED_INVOICES_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID = '40016' -- BY34ALFA30122674810010270000
WHERE invoice_id IN (1160493,1160495,1160494)

/* Formatted on  (QP5 v5.326) Service Desk 667827 Mihail.Vasiljev */
UPDATE ap.ap_invoices_all
   SET EXTERNAL_BANK_ACCOUNT_ID = '40016' -- BY34ALFA30122674810010270000
WHERE invoice_id IN (1160493,1160495,1160494)

/* Formatted on  (QP5 v5.326) Service Desk 667827 Mihail.Vasiljev */
UPDATE IBY_DOCS_PAYABLE_ALL
   SET EXTERNAL_BANK_ACCOUNT_ID = '40016'
 WHERE CALLING_APP_DOC_UNIQUE_REF2 IN (1160493, 1160495, 1160494)

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