Not Accounting

--non-accounted INV trx  
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records' error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity >= 0 AND TRANSACTION_TYPE_ID not IN (110, 95, 54)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where d_doc_id = transaction_id and D_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id
union
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records' error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ledger_id = 2047
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity < 0 AND TRANSACTION_TYPE_ID not IN (110)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = transaction_id and c_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id;


--non-accounted inter-org movements trx  
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records in ' || organization_id error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity >= 0 AND TRANSACTION_TYPE_ID IN (95, 54)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where d_doc_id = transaction_id and D_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
--and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id
union
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records in ' || organization_id error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity < 0 AND TRANSACTION_TYPE_ID IN (95, 54)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = transaction_id and c_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
--and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id;


--non-accounted AP invoices   
select h.ae_header_id, te.SOURCE_ID_INT_1, ai.invoice_num, ai.invoice_date 
from xla_ae_headers h
, xla.xla_transaction_entities te
, ap_invoices_all ai
where h.application_id = 200
and h.EVENT_TYPE_CODE = 'INVOICE VALIDATED'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select invoice_id from ap_invoices_all where invoice_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and ai.CANCELLED_DATE is null)
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and C_ENTITY_CODE = 'AP_INVOICES')
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.invoice_id;



--non-accounted payments   
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.check_number, ai.check_date
from xla_ae_headers h
, xla.xla_transaction_entities te
, ap_checks_all ai
where h.application_id = 200
and h.EVENT_TYPE_CODE = 'PAYMENT CREATED'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select check_id from ap_checks_all where check_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and ai.void_DATE is null and BANK_ACCOUNT_NAME != 'Netting Bank Account')
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and C_ENTITY_CODE = 'AP_PAYMENTS')
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.check_id;


--non-accounted netting payments   
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.check_number, ai.check_date
from xla_ae_headers h
, xla.xla_transaction_entities te
, ap_checks_all ai
where h.application_id = 200
and h.EVENT_TYPE_CODE = 'PAYMENT CREATED'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select check_id from ap_checks_all where check_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and ai.void_DATE is null and BANK_ACCOUNT_NAME = 'Netting Bank Account')
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where D_doc_id = te.SOURCE_ID_INT_1 and D_ENTITY_CODE = 'AP_PAYMENTS')
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.check_id;


--non-accounted netting receipts   
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.receipt_number, ai.receipt_date  
from xla_ae_headers h
, xla.xla_transaction_entities te
, ar_cash_receipts_all ai
where h.application_id = 222
and h.EVENT_TYPE_CODE = 'RECP_CREATE'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select cash_receipt_id from ar_cash_receipts_all where receipt_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and RECEIPT_NUMBER like 'NETTING%' and REVERSAL_DATE is null )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and C_ENTITY_CODE = 'RECEIPTS')
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.cash_receipt_id;


--non-accounted receipts   
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.receipt_number, ai.receipt_date 
from xla_ae_headers h
, xla.xla_transaction_entities te
, ar_cash_receipts_all ai
where h.application_id = 222
and h.EVENT_TYPE_CODE = 'RECP_CREATE'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select cash_receipt_id from ar_cash_receipts_all where receipt_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') and REVERSAL_DATE is null and RECEIPT_NUMBER not like 'NETTING%' )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where d_doc_id = te.SOURCE_ID_INT_1 and D_ENTITY_CODE = 'RECEIPTS')
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.cash_receipt_id;



--non-accounted AR trx  
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.trx_number, ai.trx_date 
from xla_ae_headers h
, xla.xla_transaction_entities te
, ra_customer_trx_all ai
where h.application_id = 222
and h.EVENT_TYPE_CODE = 'INV_CREATE'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select customer_trx_id from ra_customer_trx_all where trx_date between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') )--and RECEIPT_NUMBER like 'NETTING%' and REVERSAL_DATE is null )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and D_ENTITY_CODE = 'TRANSACTIONS' and d_appl_id = 222)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.customer_trx_id;


--non-accounted FA operations
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.transaction_header_id, ai.date_effective
from xla_ae_headers h
, xla.xla_transaction_entities te
, fa_transaction_headers ai
where h.application_id = 140
--and h.EVENT_TYPE_CODE = 'DEPRECIATION'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_header_id from fa_transaction_headers where date_effective between to_date('01052022','ddmmyyyy')  and to_date('31052022','ddmmyyyy') )--and RECEIPT_NUMBER like 'NETTING%' and REVERSAL_DATE is null )
--and exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and D_ENTITY_CODE = 'TRANSACTIONS' and d_appl_id = 140)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.transaction_header_id;


--FA_DEPRN_SUMMARY
select h.ae_header_id, te.SOURCE_ID_INT_1, h.EVENT_TYPE_CODE, ai.asset_id,  h.accounting_date
from xla_ae_headers h
, xla.xla_transaction_entities te
, fa_books ai
where h.application_id = 140
and h.EVENT_TYPE_CODE = 'DEPRECIATION'
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select asset_id from fa_books where BOOK_TYPE_CODE = 'BEST_FA_LOCAL' ) --and asset_id = 1041966)
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = te.SOURCE_ID_INT_1 and D_ENTITY_CODE = 'DEPRECIATION' and d_appl_id = 140)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
and te.SOURCE_ID_INT_1 = ai.asset_id
and h.period_name = 'NOV-21';
