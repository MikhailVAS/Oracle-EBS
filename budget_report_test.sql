truncate table xxtg.Xxtg_Mustafa;

Declare 
l_flag Boolean; 
BEGIN 

XXTG_BUDGET_REP_EXT_PKG.P_BUDGET_ID := '2000';
--XXTG_BUDGET_REP_EXT_PKG.P_DEPARTMENT_CODE := '0';
XXTG_BUDGET_REP_EXT_PKG.P_BUDGET_CODE := '0';
XXTG_BUDGET_REP_EXT_PKG.P_DETAIL := '900_01_01_02_00_00 ';

l_flag := XXTG_BUDGET_REP_EXT_PKG.BEFOREREPORT;

end; 


Declare 
l_flag Boolean; 
BEGIN 

XXTG_BUDGET_CONTROL_API.P_BUDGET_ID := '2000';


end; 




select * from XXTG_BUDGET_REP_EXT_DATA WHERE june_budget !=0;


SELECT department_code,
       budget_code,
       DOC_TYPE_NAME,
       DOC_NUMBER,
       DOC_CREATION_DATE,
       DOC_CREATED_BY,
       DOC_DESCRIPTION,
       YEAR_AMOUNT
  FROM XXTG_BUDGET_REP_EXT_DATA
 WHERE DOC_TYPE IN
          ('PO_REQUISITION',
           'PO_HEADER (PR)',
           'AP_INVOICE',
           'GL_COMMIT',
           'GL_UNCOMMIT',
           'IEXPENSE')
      -- AND budget_code = '0'
       AND YEAR_AMOUNT != 0;


select * from XXTG_BUDGET_REP_EXT_DATA WHERE DOC_NUMBER = '84141'

 SELECT DOC.DEPARTMENT_CODE,
             DOC.BUDGET_CODE,
             DOC.BUDGET_NAME,
             DOC.DOC_ID,
             DOC.PARENT_DOC_ID,
             DOC.DOC_TYPE, DOC_TYPE_NAME,
             DOC.DOC_NUMBER,
             DOC.DOC_CREATION_DATE,
             DOC.DOC_CREATED_BY,
             DOC.DOC_DESCRIPTION,
             DOC.DOC_VENDOR_NAME,
             DOC.DOC_CURRENCY_CODE,
             DOC.RATE  DOC_CURRENCY_RATE,
             DOC.DOC_CONRACT_NUMBER,
             SUM(DOC.JANUARY_AMOUNT*DOC.RATE)+
             SUM(DOC.FEBRUARY_AMOUNT*DOC.RATE)+
             SUM(DOC.MARCH_AMOUNT*DOC.RATE)+
             SUM(DOC.APRIL_AMOUNT*DOC.RATE)+
             SUM(DOC.MAY_AMOUNT*DOC.RATE)+
             SUM(DOC.JUNE_AMOUNT*DOC.RATE)+
             SUM(DOC.JULY_AMOUNT*DOC.RATE)+
             SUM(DOC.AUGUST_AMOUNT*DOC.RATE)+
             SUM(DOC.SEPTEMBER_AMOUNT*DOC.RATE)+
             SUM(DOC.OCTOBER_AMOUNT*DOC.RATE)+
             SUM(DOC.NOVEMBER_AMOUNT*DOC.RATE)+
             SUM(DOC.DECEMBER_AMOUNT*DOC.RATE)  YEAR_AMOUNT,
             SUM(DOC.JANUARY_AMOUNT*DOC.RATE)   JANUARY_AMOUNT,
             SUM(DOC.FEBRUARY_AMOUNT*DOC.RATE)  FEBRUARY_AMOUNT,
             SUM(DOC.MARCH_AMOUNT*DOC.RATE)     MARCH_AMOUNT,
             SUM(DOC.APRIL_AMOUNT*DOC.RATE)     APRIL_AMOUNT,
             SUM(DOC.MAY_AMOUNT*DOC.RATE)       MAY_AMOUNT,
             SUM(DOC.JUNE_AMOUNT*DOC.RATE)      JUNE_AMOUNT,
             SUM(DOC.JULY_AMOUNT*DOC.RATE)      JULY_AMOUNT,
             SUM(DOC.AUGUST_AMOUNT*DOC.RATE)    AUGUST_AMOUNT,
             SUM(DOC.SEPTEMBER_AMOUNT*DOC.RATE) SEPTEMBER_AMOUNT,
             SUM(DOC.OCTOBER_AMOUNT*DOC.RATE)   OCTOBER_AMOUNT,
             SUM(DOC.NOVEMBER_AMOUNT*DOC.RATE)  NOVEMBER_AMOUNT,
             SUM(DOC.DECEMBER_AMOUNT*DOC.RATE)  DECEMBER_AMOUNT,
             SUM(JANUARY_BUDGET*DOC.RATE) JANUARY_BUDGET,
             SUM(FEBRUARY_BUDGET*DOC.RATE) FEBRUARY_BUDGET,
             SUM(MARCH_BUDGET*DOC.RATE) MARCH_BUDGET,
             SUM(APRIL_BUDGET*DOC.RATE) APRIL_BUDGET,
             SUM(MAY_BUDGET*DOC.RATE) MAY_BUDGET,
             SUM(JUNE_BUDGET*DOC.RATE) JUNE_BUDGET,
             SUM(JULY_BUDGET*DOC.RATE) JULY_BUDGET,
             SUM(AUGUST_BUDGET*DOC.RATE) AUGUST_BUDGET,
             SUM(SEPTEMBER_BUDGET*DOC.RATE) SEPTEMBER_BUDGET,
             SUM(OCTOBER_BUDGET*DOC.RATE) OCTOBER_BUDGET,
             SUM(NOVEMBER_BUDGET*DOC.RATE) NOVEMBER_BUDGET,
             SUM(DECEMBER_BUDGET*DOC.RATE) DECEMBER_BUDGET           
        FROM (SELECT CCID.SEGMENT6                          DEPARTMENT_CODE,
                     CCID.SEGMENT8                          BUDGET_CODE,
                     BUD.DESCRIPTION                        BUDGET_NAME,
                     POH.PO_HEADER_ID                       DOC_ID,
                     PORL.requisition_header_id  PARENT_DOC_ID,
                     'PO_HEADER (PR)'                       DOC_TYPE,
                     '2.  PO'                                 DOC_TYPE_NAME,
                     POH.SEGMENT1                           DOC_NUMBER,
                     POH.CREATION_DATE                      DOC_CREATION_DATE,
                     FU.USER_NAME                           DOC_CREATED_BY,
                     POH.COMMENTS                           DOC_DESCRIPTION,
                     VEN.VENDOR_NAME                        DOC_VENDOR_NAME,
                     POH.CURRENCY_CODE                      DOC_CURRENCY_CODE,
                     POH.RATE                               DOC_CURRENCY_RATE,
                     (SELECT CONTRAT_NO FROM XXTG_INVOICE_CONTRACT_V WHERE CONTRACT_ID = POH.ATTRIBUTE1) DOC_CONRACT_NUMBER,
                     CASE
                       WHEN NVL(POH.CURRENCY_CODE,'BYN') = 'BYN' THEN 1
                       ELSE nvl(POH.RATE,0) END             RATE,
                     /*
                     CASE
                       WHEN POH.CURRENCY_CODE = 'BYN' THEN 1
                       ELSE (SELECT CONVERSION_RATE
                               FROM GL_DAILY_RATES
                              WHERE CONVERSION_DATE = trunc(POL.CREATION_DATE)
                                AND from_currency = POH.CURRENCY_CODE
                                AND to_currency = 'BYN'
                                AND CONVERSION_TYPE = 1000) END RATE,
                     */
                     EXTRACT(MONTH FROM PLL.NEED_BY_DATE) LINE_MONTH,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 1  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END JANUARY_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 2  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END FEBRUARY_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 3  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END MARCH_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 4  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END APRIL_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 5  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END MAY_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 6  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END JUNE_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 7  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END JULY_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 8  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR  THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END AUGUST_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 9  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END SEPTEMBER_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 10  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END OCTOBER_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 11  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END NOVEMBER_AMOUNT,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 12  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR THEN NVL(nvl(POD.quantity_ordered, pll.quantity)*POL.UNIT_PRICE,0) ELSE 0 END DECEMBER_AMOUNT,
--calculation of budget amount based on line closure status and quantity from distribution 
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 1  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8) THEN NVL( (CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END JANUARY_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 2  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END FEBRUARY_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 3  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END MARCH_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 4  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END APRIL_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 5  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END MAY_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 6  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END JUNE_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 7  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END JULY_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 8  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END AUGUST_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 9  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8)  THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END SEPTEMBER_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 10  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8) THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END OCTOBER_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 11  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8) THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END NOVEMBER_BUDGET,
                     CASE WHEN EXTRACT(MONTH FROM PLL.NEED_BY_DATE) = 12  AND EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR AND CCID.SEGMENT8 =NVL(P_BUDGET_CODE, CCID.SEGMENT8) THEN NVL((CASE NVL (pll.closed_code, 'OPEN') WHEN 'OPEN' THEN nvl(POD.quantity_ordered, pll.quantity) ELSE 0 END DECEMBER_BUDGET
                FROM PO_HEADERS_ALL             POH,
                     PO_LINES_ALL               POL,
                     PO_DISTRIBUTIONS_ALL       POD,
                     PO_LINE_LOCATIONS_ALL      PLL,
                     GL_CODE_COMBINATIONS   CCID,
                     FND_USER                   FU,
                     XXTG_BUDGET_LIST_V         BUD,
                     PO_VENDORS                 VEN,
                     PO_REQUISITION_LINES_ALL   PORL,
                     PO_REQ_DISTRIBUTIONS_ALL   PORD,
                     (SELECT RED.DOC_ID                        DOC_ID,
                             RED.DEPARTMENT_CODE               DEPARTMENT_CODE,
                             RED.BUDGET_CODE                   BUDGET_CODE,
                             RED.DOC_CURRENCY_CODE CURRENCY_CODE  
                        FROM XXTG_BUDGET_REP_EXT_DATA  RED
                       WHERE RED.DOC_TYPE = 'PO_REQUISITION'
                     ) PARENT_DOC
               WHERE POH.PO_HEADER_ID = POL.PO_HEADER_ID
                 AND POH.AUTHORIZATION_STATUS not in ('CANCELLED','REJECTED','RETURNED')
                 AND NVL(POL.CANCEL_FLAG,'N') = 'N'
                 AND POL.PO_LINE_ID = POD.PO_LINE_ID
                 AND POH.PO_HEADER_ID = PLL.PO_HEADER_ID
                 AND poh.segment1 = '34930'
                 AND POL.PO_LINE_ID = PLL.PO_LINE_ID
                 AND POD.line_location_id = pll.line_location_id                 
                 AND POD.CODE_COMBINATION_ID = CCID.CODE_COMBINATION_ID
                 --AND CCID.SEGMENT6 = NVL(P_DEPARTMENT_CODE, CCID.SEGMENT6)
                 --AND CCID.SEGMENT8 = NVL(P_BUDGET_CODE, CCID.SEGMENT8)
                 AND CCID.SEGMENT8 = BUD.BUDGET_CODE
                 AND PARENT_DOC.BUDGET_CODE = CCID.SEGMENT8
                 AND POH.CREATED_BY = FU.USER_ID
                 AND POH.VENDOR_ID = VEN.VENDOR_ID(+)
                 AND (EXTRACT(YEAR FROM PLL.NEED_BY_DATE) = L_YEAR
                        OR exists   --проверяем, что PO использовался позднее в поступлении с датой в диапазоне отчета
                        (SELECT 1 
                             FROM po_line_locations_all      plla
                                  ,po_distributions_all       pda
                                  , RCV_TRANSACTIONS rcv
                            WHERE 1=1
                              AND pda.po_distribution_id = POD.po_distribution_id      
                              AND plla.line_location_id = pda.line_location_id 
                              AND  rcv.po_distribution_id = pda.po_distribution_id
                              AND (EXTRACT(YEAR FROM rcv.transaction_date) = L_YEAR))
                    OR exists   --проверяем, что PO использовался позднее в КСФ с датой в диапазоне отчета
                        (SELECT 1 
                             FROM po_line_locations_all      plla
                                  ,po_distributions_all       pda
                                  , ap_invoice_distributions_all aid
                                  , ap_invoices_all ai
                            WHERE 1=1
                              AND pda.po_distribution_id = POD.po_distribution_id      
                              AND plla.line_location_id = pda.line_location_id 
                              AND aid.po_distribution_id = pda.po_distribution_id
                              AND aid.invoice_id = ai.invoice_id
                              AND (EXTRACT(YEAR FROM ai.invoice_date) = L_YEAR))                 
                 )
                 ---------------------------------------------------------------------
                 AND PORD.DISTRIBUTION_ID(+) = POD.REQ_DISTRIBUTION_ID
                 AND PORL.requisition_line_id(+) = PORD.requisition_line_id
                 AND PARENT_DOC.doc_id = PORL.requisition_header_id                 
                 AND NVL(POH.CURRENCY_CODE, 'BYN') = PARENT_DOC.CURRENCY_CODE
                 --AND CCID.SEGMENT6 = PARENT_DOC.DEPARTMENT_CODE
                 --AND CCID.SEGMENT8 = PARENT_DOC.BUDGET_CODE
                 ) DOC
             GROUP BY  DOC.DEPARTMENT_CODE,
                       DOC.BUDGET_CODE,
                       DOC.BUDGET_NAME,
                       DOC.DOC_ID,
                       DOC.PARENT_DOC_ID,
                       DOC.DOC_TYPE,
                       DOC.DOC_TYPE_NAME,
                       DOC.DOC_NUMBER,
                       DOC.DOC_CREATION_DATE,
                       DOC.DOC_CREATED_BY,
                       DOC.DOC_DESCRIPTION,
                       DOC.DOC_VENDOR_NAME,
                       DOC.DOC_CURRENCY_CODE,
                       DOC.RATE,
                       DOC.DOC_CONRACT_NUMBER;
                    