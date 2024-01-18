/* AR transactions Account */
SELECT RTA.NAME,
       RTA.DESCRIPTION,
       RTA.TYPE,
       (SELECT DISTINCT GCC.SEGMENT2
          FROM apps.gl_code_combinations_kfv GCC
         WHERE GCC.code_combination_id = RTA.GL_ID_REC)    AS "AR Account",
       terms.DESCRIPTION
  FROM AR.RA_CUST_TRX_TYPES_ALL RTA, ra_terms terms
 WHERE terms.term_id = RTA.default_term
--    WHERE NAME = 'Add VAT of goods'


/*  AP Invoice Type Account */
SELECT 
       INVOICE_TYPE,
       LIABILITY_ACCOUNT    AS "AP Account",
       IFRS_CODE,
       PAYMENT_CODE_DESCRIPTION,
       PAYMENT_CODE
  FROM XXTG_AP_INVOICE_ACCOUNT_SETUP