SELECT *
  FROM RA_CUSTOMER_TRX_ALL
 WHERE TRX_NUMBER IN ('112235', '112212', '112234')


SELECT * FROM APPS.XXTG_EHSCHF_ISSUANCE
WHERE ID in (SELECT ISSUANCE_ID FROM APPS.XXTG_EHSCHF_AR_INV 
WHERE INVOICE_NUM in (1000139265,1000139266))


SELECT * FROM APPS.XXTG_EHSCHF_AR_INV 
WHERE INVOICE_NUM in (1000139265,1000139266)

/* Find all account by  AR transaction in double_global*/
SELECT                                                              --distinct
       ENTERED_AMOUNT,
       ACCOUNTED_AMOUNT,
       D_ACCOUNTING_DATE,
       C_ACCOUNTING_DATE,
       D_AN_DESC_1,
       C_AN_DESC_3,
       ENTERED_AMOUNT,
       g1.C_DOC_NUM,
       g1.d_DOC_NUM,
       g1.*
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     1 = 1     -- and ENTERED_AMOUNT in( 233.62, 518.24, 206.41, 359.65)
       -- and ACCOUNTED_AMOUNT in (472.08, 1734.54, 52.62, 58.06 )
       AND (   C_DOC_NUM IN ('112235', '112212', '112234')
            OR d_DOC_NUM IN ('112235', '112212', '112234')) -- Transaction Set ID or Header
       AND (   C_DOC_ID IN
                   (SELECT CUSTOMER_TRX_ID
                      FROM RA_CUSTOMER_TRX_ALL
                     WHERE TRX_NUMBER IN ('112235', '112212', '112234')) -- Ar Doc number
            OR d_DOC_ID IN
                   (SELECT CUSTOMER_TRX_ID
                      FROM RA_CUSTOMER_TRX_ALL
                     WHERE TRX_NUMBER IN ('112235', '112212', '112234'))) -- Ar Doc number


/* When AR transaction not selected block Bill To 
   Назаревич
 */
UPDATE HZ_CUST_ACCT_SITES_ALL
   SET bill_to_flag = 'P'
 WHERE CUST_ACCOUNT_ID = 908693 AND ORIG_SYSTEM_REFERENCE = 'AR-109-3:330832'


 /* Not creating Account log ora-01476 divisor is equal to zero*/
SELECT app.amount_applied_from, app.*
  FROM xla_events                      gt,
       ar_receivable_applications_all  app,
       ar_distributions_all            dist,
       gl_sets_of_books                sob,
       oe_system_parameters_all        osp,
       ar_cash_receipts_all            cr,
       ar_cash_receipt_history_all     crh,
       ra_customer_trx_all             trx
 WHERE     gt.event_type_code IN ('RECP_CREATE',
                                  'RECP_UPDATE',
                                  'RECP_RATE_ADJUST',
                                  'RECP_REVERSE')
       AND gt.application_id = 222
       AND gt.event_date BETWEEN TO_DATE ('01-02-2024', 'DD-MM-YYYY')
                             AND TO_DATE ('01-03-2024', 'DD-MM-YYYY')
       AND gt.event_id = app.event_id
       AND dist.source_table = 'RA' -- Don't need this join due to ar_app_dist_upg_v
       AND dist.source_id = app.receivable_application_id
       AND app.set_of_books_id = sob.set_of_books_id
       AND DECODE (app.acctd_amount_applied_to,
                   0, DECODE (app.acctd_amount_applied_from, 0, 'N', 'Y'),
                   'N') =
           'Y'
       AND app.org_id = osp.org_id(+)
       AND app.cash_receipt_id = cr.cash_receipt_id
       AND app.cash_receipt_history_id = crh.cash_receipt_history_id(+)
       AND app.applied_customer_trx_id = trx.customer_trx_id(+)
       AND dist.source_type IN ('REC',
                                'OTHER ACC',
                                'ACC',
                                'BANK_CHARGES',
                                'ACTIVITY',
                                'FACTOR',
                                'REMITTANCE',
                                'TAX',
                                'DEFERRED_TAX',
                                'UNEDISC',
                                'EDISC',
                                'CURR_ROUND',
                                'SHORT_TERM_DEBT',
                                'EXCH_LOSS',
                                'EXCH_GAIN',
                                'EDISC_NON_REC_TAX',
                                'UNEDISC_NON_REC_TAX',
                                'UNAPP')
       AND NVL (app.amount_applied_from, 0) = 0
       AND NVL (app.amount_applied, 0) = 0;

/* Correction update ora-01476 divisor is equal to zero*/
UPDATE ar_receivable_applications_all
   SET AMOUNT_APPLIED = 0.01
 WHERE RECEIVABLE_APPLICATION_ID = 2584118;

/* Finde  AR customet site adress*/
    SELECT hps.*
            FROM hz_party_sites    hps,
                 hz_locations      hzl,
                 fnd_territories_vl fvl,
                 hz_contact_points email,
                 hz_contact_points phone,
                 hz_contact_points fax,
                 hz_party_site_uses pay,
                 hz_party_site_uses pur,
                 hz_party_site_uses rfq
           WHERE     1=1 --hps.status = 'A'
                 AND hps.party_id = :1 --and hps.created_by_module like 'POS%'
                 AND hzl.COUNTRY = fvl.TERRITORY_CODE
                 AND email.owner_table_id(+) = hps.party_site_id
                 AND email.owner_table_name(+) = 'HZ_PARTY_SITES'
                 AND email.status(+) = 'A'
                 AND email.contact_point_type(+) = 'EMAIL'
                 AND email.primary_flag(+) = 'Y'
                 AND phone.owner_table_id(+) = hps.party_site_id
                 AND phone.owner_table_name(+) = 'HZ_PARTY_SITES'
                 AND phone.status(+) = 'A'
                 AND phone.contact_point_type(+) = 'PHONE'
                 AND phone.phone_line_type(+) = 'GEN'
                 AND phone.primary_flag(+) = 'Y'
                 AND fax.owner_table_id(+) = hps.party_site_id
                 AND fax.owner_table_name(+) = 'HZ_PARTY_SITES'
                 AND fax.status(+) = 'A'
                 AND fax.contact_point_type(+) = 'PHONE'
                 AND fax.phone_line_type(+) = 'FAX'
                 AND hps.location_id = hzl.location_id
                 AND pay.party_site_id(+) = hps.party_site_id
                 AND pur.party_site_id(+) = hps.party_site_id
                 AND rfq.party_site_id(+) = hps.party_site_id
                 AND pay.status(+) = 'A'
                 AND pur.status(+) = 'A'
                 AND rfq.status(+) = 'A'
                 AND NVL (pay.end_date(+), SYSDATE) >= SYSDATE
                 AND NVL (pur.end_date(+), SYSDATE) >= SYSDATE
                 AND NVL (rfq.end_date(+), SYSDATE) >= SYSDATE
                 AND NVL (pay.begin_date(+), SYSDATE) <= SYSDATE
                 AND NVL (pur.begin_date(+), SYSDATE) <= SYSDATE
                 AND NVL (rfq.begin_date(+), SYSDATE) <= SYSDATE
                 AND pay.site_use_type(+) = 'PAY'
                 AND pur.site_use_type(+) = 'PURCHASING'
                 AND rfq.site_use_type(+) = 'RFQ'
                 AND NOT EXISTS
                         (SELECT 1
                            FROM pos_address_requests par,
                                 pos_supplier_mappings psm
                           WHERE     psm.party_id = hps.party_id
                                 AND psm.mapping_id = par.MAPPING_ID
                                 AND party_site_id = hps.party_site_id
                                 AND request_status = 'PENDING'
                                 AND request_type IN ('UPDATE', 'DELETE'))

                                 
       
       SELECT * FROM hz_parties WHERE PARTY_ID = 257829
       
       SELECT * FROM HZ_PARTY_SITES WHERE PARTY_ID = 257829
       
       SELECT * FROM hz_Customer_profiles WHERE PARTY_ID = 257829
       
       SELECT * FROM hz_code_assignments WHERE OWNER_TABLE_NAME = 'HZ_PARTIES' AND CLASS_CODE = 'OTHER'
       
/* Formatted on 6/5/2024 9:23:28 AM (QP5 v5.388) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM HZ_PARTIES              HP,
       HZ_PARTY_SITES          HPS,
       HZ_CUST_ACCOUNTS        HCA,
       HZ_CUST_ACCT_SITES_ALL  HCASA,
       HZ_CUST_SITE_USES_ALL   HCSUA,
       HZ_LOCATIONS            HL
 WHERE     1 = 1
       AND HP.PARTY_ID = HPS.PARTY_ID
       AND HPS.PARTY_ID = HCA.PARTY_ID
       AND HPS.PARTY_SITE_ID = HCASA.PARTY_SITE_ID
       AND HCA.APPLICATION_ID = HCASA.APPLICATION_ID
       AND HCA.CUST_ACCOUNT_ID = HCASA.CUST_ACCOUNT_ID
       AND HCASA.CUST_ACCT_SITE_ID = HCSUA.CUST_ACCT_SITE_ID
       AND HPS.LOCATION_ID = HL.LOCATION_ID
--       AND HP.PARTY_ID = 257829
       AND HP.PARTY_NAME = 'ЛэпТоп ЧТУП';

SELECT PARTY_SITE_ID
  FROM HZ_PARTY_SITES
 WHERE PARTY_ID = '257829' AND PARTY_SITE_NAME = '.'
       
--       PARTY_ID = 257829
--       PARTY_NUMBER = 21098
--       PARTY_SITE_ID = 697808 BAD 

SELECT *
  FROM HZ_CUST_ACCT_SITES_ALL
 WHERE PARTY_SITE_ID IN (SELECT PARTY_SITE_ID
                           FROM HZ_PARTY_SITES
                          WHERE PARTY_ID = '257829')
       
/* Active AR customet site adress*/
UPDATE HZ_CUST_ACCT_SITES_ALL
   SET STATUS = 'A'
 WHERE PARTY_SITE_ID = '697808'

       
       
