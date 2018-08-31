IBY_DISBURSE_UI_API_PUB_PKG .perform_check_print

select * from IBY_DOCS_PAYABLE_ALL where
CALLING_APP_DOC_UNIQUE_REF1 in(
13943,13811 )

edit IBY_PAY_INSTRUCTIONS_ALL where PAY_ADMIN_ASSIGNED_REF_CODE = '28 08 18 v'

update IBY_PAYMENTS_ALL  set PAYMENT_STATUS = 'CREATED'  where PAYMENT_PROCESS_REQUEST_NAME in ( '06 08 12')

select * from ap_inv_selection_criteria_all where checkrun_name in  ('23.07.2012_23', '06 08 12')

edit iby_pay_service_requests where  CALL_APP_PAY_SERVICE_REQ_CODE in  ('23.07.2012_23', '06 08 12')

