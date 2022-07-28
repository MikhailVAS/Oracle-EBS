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