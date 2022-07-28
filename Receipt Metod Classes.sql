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