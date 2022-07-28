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

select * from ap.AP_SELECTED_INVOICE_CHECKS_ALL

edit ap.AP_PAYMENT_SCHEDULES_ALL where invoice_id in  (267336,200808,87862)    --31379

select * from xxtg.xxtg_gl001_double_global where c_doc_num='��� 101'

select * from xla.xla_ae_headers where ae_header_id=278533313

select * from xla.xla_ae_lines where ae_header_id=278533313