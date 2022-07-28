--###############################################################
   UPDATE APPS.xxtg_otf_headers_all oha
      SET oha.EXCHANGE_DATE = TO_DATE ('27012021', 'DDMMYYYY'),
          EXCHANGE_RATE_TYPE = '1000',
          APPROVAL_EXCHANGE_RATE = '2,9206',
          EXCHANGE_RATE = '2,9206'
    WHERE     1 = 1
          AND oha.PAYMENT_CURRENCY_CODE = 'USD'
          AND oha.CREATION_DATE >= TO_DATE ('27012021', 'DDMMYYYY')
          AND oha.CREATION_DATE < TO_DATE ('28012021', 'DDMMYYYY')
          AND oha.STATUS = 'IN PROCESS';
          
          
/* Formatted  (QP5 v5.326) Service Desk 526661 Mihail.Vasiljev */
SELECT *
  FROM xxtg_otf_headers_all
 WHERE OTF_NUMBER IN (984883,
                      984884,
                      984886,
                      984888,
                      984889,
                      984890,
                      986291,
                      986292,
                      986293,
                      986294)
                      
/* Formatted  (QP5 v5.326) Service Desk 526661 Mihail.Vasiljev */
UPDATE APPS.xxtg_otf_headers_all
   SET PAYMENT_DATE = TO_DATE ('29.09.2021', 'dd.mm.yyyy'),
       EXCHANGE_DATE = TO_DATE ('29.09.2021', 'dd.mm.yyyy'),
       APPROVAL_EXCHANGE_RATE = '2,9206',
       EXCHANGE_RATE = '2,9206'
 WHERE     PAYMENT_CURRENCY_CODE = 'EUR'
       AND OTF_NUMBER IN (984883,
                          984884,
                          984886,
                          984888,
                          984889,
                          984890,
                          986291,
                          986292,
                          986293,
                          986294)
                          
/* Formatted on (QP5 v5.326) Service Desk 526661 Mihail.Vasiljev */
UPDATE APPS.xxtg_otf_headers_all
   SET PAYMENT_DATE = TO_DATE ('29.09.2021', 'dd.mm.yyyy'),
       EXCHANGE_DATE = TO_DATE ('29.09.2021', 'dd.mm.yyyy'),
       APPROVAL_EXCHANGE_RATE = '2,5',
       EXCHANGE_RATE = '2,5'
 WHERE     PAYMENT_CURRENCY_CODE = 'USD'
       AND OTF_NUMBER IN (984883,
                          984884,
                          984886,
                          984888,
                          984889,
                          984890,
                          986291,
                          986292,
                          986293,
                          986294)


/* Daily rate on date */
SELECT RATE_SOURCE_CODE,
       CONVERSION_DATE,
       typ.user_conversion_type     "User Conversion Type",
       rat.from_currency            "From Currency",
       rat.to_currency              "To Currency",
       CONVERSION_RATE              "Exchange Rate"
  FROM gl_daily_conversion_types typ, gl_daily_rates rat
 WHERE     rat.conversion_type = typ.conversion_type
       AND rat.CONVERSION_DATE = TO_DATE ('29.09.2021', 'dd.mm.yyyy')
       AND rat.from_currency = 'USD'
	   
--###############################################################


--Изменение бюджетного кода ARF
--'ARF:691714','ARF:691715','ARF:691716','ARF:691717','ARF:691718','ARF:691719','ARF:691720','ARF:691721','ARF:691722','ARF:691723','ARF:691724','ARF:691725','ARF:691726','ARF:691727','ARF:691728','ARF:691702','ARF:691703','ARF:691704','ARF:691705','ARF:691706','ARF:691707','ARF:691708','ARF:691709','ARF:691950'
DECLARE
--01.0001.0.0.0.0.0.0.0.0.0.0.0.0.0
   L_Cc_Segment1       VARCHAR2 (25 BYTE) := '01';
   L_Cc_Segment2       VARCHAR2 (25 BYTE) := '0001'; --Local
   L_Cc_Segment3       VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment4       VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment5       VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment6       VARCHAR2 (25 BYTE) := '0'; --department
   L_Cc_Segment7       VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment8       VARCHAR2 (25 BYTE) := '0'; --budget
   L_Cc_Segment9       VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment10      VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment11      VARCHAR2 (25 BYTE) := '0'; --IFRS
   L_Cc_Segment12      VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment13      VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment14      VARCHAR2 (25 BYTE) := '0';
   L_Cc_Segment15      VARCHAR2 (25 BYTE) := '0';
   
   L_Cc_Id             NUMBER;
   L_Set_Of_Books_Id   NUMBER;
   L_Coa_Id            NUMBER;   
   L_po_budget_code VARCHAR2 (40 BYTE) := '0';
   
BEGIN

update ap_invoices_all
set attribute9 = '740_09_01_00_00_00'
where invoice_num in ('ARF:730301');

commit;
    FOR dist_rec IN (
        select distinct  h.invoice_date, h.invoice_num, h.description, h.ATTRIBUTE9 budget_code, dist.Set_Of_Books_Id
      , gcc.Segment1  
       , gcc.Segment2    
       , gcc.Segment3      
       , gcc.Segment4      
       , gcc.Segment5      
       , gcc.Segment6     
       , gcc.Segment7    
       , gcc.Segment8  
       , gcc.Segment9     
       , gcc.Segment10   
       , gcc.Segment11    
       , gcc.Segment12    
       , gcc.Segment13    
       , gcc.Segment14  
       , gcc.Segment15   
       , DIST_CODE_COMBINATION_ID
       , po_distribution_id
from ap_invoices_all h,
      AP_INVOICE_DISTRIBUTIONS_ALL dist,
             gl_code_combinations_kfv gcc
where 1=1
       and h.invoice_id = dist.invoice_id
       and h.invoice_date  >= TO_DATE ('01012018', 'ddmmyyyy')
       and gcc.code_combination_id = dist.DIST_CODE_COMBINATION_ID
       and invoice_num in ('ARF:730301')
  )  
    LOOP
       L_po_budget_code := '0';
       L_Cc_Segment1 := dist_rec.Segment1;
       L_Cc_Segment2 := dist_rec.Segment2    ;
       L_Cc_Segment3 := dist_rec.Segment3      ;
       L_Cc_Segment4 := dist_rec.Segment4      ;
       L_Cc_Segment5 := dist_rec.Segment5      ;
       L_Cc_Segment6 := dist_rec.Segment6     ;
       L_Cc_Segment7 := dist_rec.Segment7    ;
       L_Cc_Segment8 := dist_rec.Segment8  ;
       L_Cc_Segment9 := dist_rec.Segment9     ;
       L_Cc_Segment10 := dist_rec.Segment10   ;
       L_Cc_Segment11 := dist_rec.Segment11    ;
       L_Cc_Segment12 := dist_rec.Segment12    ;
       L_Cc_Segment13 := dist_rec.Segment13    ;
       L_Cc_Segment14 := dist_rec.Segment14  ;
       L_Cc_Segment15 := dist_rec.Segment15   ;
       
        L_Cc_Segment8 := '740_09_01_00_00_00';

        SELECT Chart_Of_Accounts_Id
        INTO L_Coa_Id
        FROM Gl_Sets_Of_Books
        WHERE Set_Of_Books_Id = dist_rec.Set_Of_Books_Id;
    
        L_Cc_Id := Xxtg_Gl_Common_Pkg.Get_Ccid (P_Coa_Id => L_Coa_Id,
                                         P_Segment1             => L_Cc_Segment1,
                                         P_Segment2             => L_Cc_Segment2,
                                         P_Segment3             => L_Cc_Segment3,
                                         P_Segment4             => L_Cc_Segment4,
                                         P_Segment5             => L_Cc_Segment5,
                                         P_Segment6             => L_Cc_Segment6,
                                         P_Segment7             => L_Cc_Segment7,
                                         P_Segment8             => L_Cc_Segment8,
                                         P_Segment9             => L_Cc_Segment9,
                                         P_Segment10            => L_Cc_Segment10,
                                         P_Segment11            => L_Cc_Segment11,
                                         P_Segment12            => L_Cc_Segment12,
                                         P_Segment13            => L_Cc_Segment13,
                                         P_Segment14            => L_Cc_Segment14,
                                         P_Segment15            => L_Cc_Segment15,
                                         P_Generate_Ccid_Flag   => 'Y');
                
        DBMS_OUTPUT.put_line (L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id || ', L_po_budget_code = ' || L_po_budget_code);

        UPDATE AP_INVOICE_DISTRIBUTIONS_ALL
           SET DIST_CODE_COMBINATION_ID = L_Cc_Id
         WHERE DIST_CODE_COMBINATION_ID = dist_rec.DIST_CODE_COMBINATION_ID;                         
    END LOOP;
--commit;
END;
/


SELECT*
      FROM   ap_invoices_all aia,
             ap_invoice_payments_all aip,
             ap_checks_all aca,
             ce_bank_acct_uses_all cbau,
             ce_bank_accounts cba,
             ce_banks_v cbv
     WHERE   aia.invoice_id = aip.invoice_id
             AND aca.check_id = aip.check_id
             AND cbau.bank_acct_use_id = aca.ce_bank_acct_use_id
             AND cbau.bank_account_id = cba.bank_account_id
             AND cba.bank_id = cbv.bank_party_id
             AND aip.AMOUNT = 723.16
             
             
             SELECT * FROM ap_invoice_payments_all WHERE AMOUNT = 723.16