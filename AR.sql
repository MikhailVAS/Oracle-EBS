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