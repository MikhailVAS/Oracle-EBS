UPDATE AR.AR_RECEIPT_METHOD_ACCOUNTS_ALL rma
   SET CASH_CCID =
          (SELECT NVL (bg.AR_ASSET_CCID,
                       ba.ASSET_CODE_COMBINATION_ID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID),
       ON_ACCOUNT_CCID =
          (SELECT NVL (bg.on_account_ccid,
                       ba.ASSET_CODE_COMBINATION_ID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID),
       UNAPPLIED_CCID =
          (SELECT NVL (bg.unapplied_ccid,
                       ba.ASSET_CODE_COMBINATION_ID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID),
       UNIDENTIFIED_CCID =
          (SELECT NVL (bg.unidentified_ccid,
                       ba.ASSET_CODE_COMBINATION_ID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID),
       BANK_CHARGES_CCID =
          (SELECT NVL (bg.BANK_CHARGES_CCID, ba.BANK_CHARGES_CCID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID),
       REMITTANCE_CCID   =
          (SELECT NVL (bg.remittance_ccid,
                       ba.ASSET_CODE_COMBINATION_ID)
             FROM CE_BANK_ACCT_USES_ALL au,
                  CE_BANK_ACCOUNTS ba,
                  CE_GL_ACCOUNTS_CCID bg
            WHERE     au.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
                  AND ba.bank_account_id = au.bank_account_id
                  AND bg.BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID)
where rma.RECEIPT_METHOD_ID in (select RECEIPT_METHOD_ID from ar_receipt_methods where NAME = 'Flag Ship Cash Transfer')      

/* Formatted on (QP5 v5.388) Service Desk 897878 Mihail.Vasiljev */
UPDATE AR_CASH_RECEIPTS_ALL
   SET ATTRIBUTE1 =
           (SELECT CUST_TRX_TYPE_ID
              FROM RA_CUST_TRX_TYPES_ALL
             WHERE NAME IN ('BS_LE_PEN'))
 WHERE     RECEIPT_DATE BETWEEN TO_DATE ('01.09.2025', 'dd.mm.yyyy')
                            AND TO_DATE ('19.09.2025', 'dd.mm.yyyy')
       AND ATTRIBUTE1 IN (SELECT CUST_TRX_TYPE_ID
                            FROM RA_CUST_TRX_TYPES_ALL
                           WHERE NAME IN ('BS_LE_NP'))


                                  
/* Formatted on 9/22/2025 5:15:25 PM (QP5 v5.388) Service Desk  Mihail.Vasiljev */
  SELECT CUST_TRX_TYPE_ID
    FROM RA_CUST_TRX_TYPES_ALL
   WHERE     NAME IN ('BS_IND_PEN')