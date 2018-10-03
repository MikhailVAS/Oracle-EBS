/* Кто не закрыл ПО и ПР */
SELECT DISTINCT XXTG_PO_OPEN_V.PR_NUMBER,
                XXTG_PO_OPEN_V.USER_NAME,
                XXTG_PO_OPEN_V.PR_OWNER,
                XXTG_PO_OPEN_V.PR_NEED_BY_DATE
  FROM (SELECT DISTINCT pr.segment1                          PR_NUMBER,
                        pr.requisition_header_id,
                        pr.CREATION_DATE                     PR_DATE,
                        rl.NEED_BY_DATE                      AS PR_NEED_BY_DATE,
                        rl.ITEM_DESCRIPTION                  AS PR_DESCRIPTION,
                        hr.FULL_NAME                         AS PR_OWNER,
                        fu.email_address                     AS EMAIL,
                        fu.USER_NAME                         USER_NAME,
                        PH.SEGMENT1                          AS PO_number,
                        TO_CHAR (PR.CREATION_DATE, 'MON-YY') PR_PERIOD
          FROM apps.po_headers_all              ph,
               apps.po_distributions_all        pd,
               apps.po_req_distributions_all    rd,
               apps.po_requisition_lines_all    rl,
               apps.po_requisition_headers_all  pr,
               apps.po_line_locations_all       pll,
               apps.po_lines_all                pol,
               apps.per_people_f                hr,
               apps.fnd_user                    fu
         WHERE     ph.po_header_id = pd.po_header_id
               AND pd.req_distribution_id = rd.distribution_id
               AND rd.requisition_line_id = rl.requisition_line_id
               AND rl.requisition_header_id = pr.requisition_header_id
               AND PLL.PO_LINE_ID = POL.PO_LINE_ID
               AND PH.PO_HEADER_ID = POL.PO_HEADER_ID
               AND POL.ITEM_ID = RL.ITEM_ID
               AND pd.po_line_id = POL.PO_LINE_ID
               AND fu.employee_id = hr.person_id
               AND NVL (ph.APPROVED_FLAG, 'N') = 'Y'
               AND NVL (hr.effective_start_date, SYSDATE - 1) < SYSDATE
               AND NVL (hr.effective_END_date, SYSDATE + 1) > SYSDATE
               AND fu.user_id = pr.created_by
               AND rl.NEED_BY_DATE >= TO_DATE ('01.01.2018', 'dd.mm.yyyy')
               AND (  pd.QUANTITY_ORDERED
                    - pd.QUANTITY_DELIVERED
                    - pd.QUANTITY_CANCELLED) >
                   0                                                -- open po
               AND NOT EXISTS
                       (SELECT 1
                          FROM apps.PO_ACTION_HISTORY pah
                         WHERE     pah.action_code = 'CANCEL'
                               AND pah.object_type_code = 'REQUISITION'
                               AND pah.object_id = pr.REQUISITION_HEADER_ID))  XXTG_PO_OPEN_V
 WHERE XXTG_PO_OPEN_V.PR_NEED_BY_DATE <= TO_DATE ('20.06.2018', 'dd.mm.yyyy')

/* Кто не закрыл ПО и ПР */
SELECT DISTINCT PR_NUMBER,
                USER_NAME,
                PR_OWNER,
                PR_NEED_BY_DATE
  FROM APPS.XXTG_PO_OPEN_V
 WHERE PR_NEED_BY_DATE <= TO_DATE ('20.06.2018', 'dd.mm.yyyy')

/* Анти PR_PO спам (что не закрыт запрос на закупку) */
UPDATE PO.PO_HEADERS_ALL POH
   SET POH.APPROVED_FLAG = 'N'
 WHERE POH.SEGMENT1 IN ('29462')    

/* PO */
SELECT *
  FROM PO.po_distributions_all
 WHERE po_header_id IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('28827', '28849'))    
                         
/* PO*/
SELECT *
  FROM APPS.po_distributions_all   PDA,
       PO.PO_REQ_DISTRIBUTIONS_ALL PRDA,
       PO.PO_REQUISITION_LINES_ALL PRLA
 WHERE     PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
       AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
       AND PDA.po_header_id IN (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('28827', '28849'))


/* Find PR by PO number */
SELECT POH.PO_HEADER_ID, POH.SEGMENT1 "PO NO", PRHA.SEGMENT1 "REQUISTION NO"
  FROM PO.PO_HEADERS_ALL             POH,
       PO.PO_DISTRIBUTIONS_ALL       PDA,
       PO.PO_REQ_DISTRIBUTIONS_ALL   PRDA,
       PO.PO_REQUISITION_LINES_ALL   PRLA,
       PO.PO_REQUISITION_HEADERS_ALL PRHA
 WHERE     POH.PO_HEADER_ID = PDA.PO_HEADER_ID
       AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
       AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
       AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
       AND POH.SEGMENT1 IN ('28013', '28012', '28014')            -- PO NUMBER
--AND PRHA. SEGMENT1 = '230617' -- PO REQUISITION NUMBER

/* Find code_combination_id by PR */
SELECT *
  FROM po.PO_REQ_DISTRIBUTIONS_ALL
 WHERE REQUISITION_LINE_ID IN
          (SELECT REQUISITION_LINE_ID
             FROM po.PO_REQUISITION_LINES_ALL
            WHERE REQUISITION_HEADER_ID IN
                     (SELECT REQUISITION_HEADER_ID
                        FROM po.PO_REQUISITION_HEADERS_ALL
                       WHERE segment1 IN ('72161'))) --указать номер нужного PR (REQUISTION NO из "Find PR by PO number " )

/* Add code_combination_id in po_req_distributions_all*/
UPDATE po.po_req_distributions_all
   SET code_combination_id = 180320
 WHERE     requisition_line_id IN (SELECT requisition_line_id
                                     FROM po.po_requisition_lines_all
                                    WHERE requisition_header_id = 1079934)
       AND code_combination_id = 0
       
/* Add code_combination_id in po_distributions_all */
UPDATE po.po_distributions_all
   SET code_combination_id = 180320
 WHERE po_header_id IN (SELECT po_header_id
                          FROM po.po_headers_all
                         WHERE segment1 IN ('28013', '28012', '28014'))
                         
/* Leveling the quantity I*/
UPDATE po.po_line_locations_all n
   SET quantity_billed = quantity_received
 WHERE     1 = 1
       AND po_line_id IN
              (SELECT po_line_id
                 FROM po.po_lines_all
                WHERE po_header_id IN (SELECT po_header_id
                                         FROM po.po_headers_all
                                        WHERE segment1 IN ('28013', '28012', '28014')))
       AND quantity_billed > quantity_received

/* Leveling the quantity II */
UPDATE po.po_distributions_all n
   SET quantity_billed = quantity_delivered
 WHERE     1 = 1
       AND po_line_id IN
              (SELECT po_line_id
                 FROM po.po_lines_all
                WHERE po_header_id IN (SELECT po_header_id
                                         FROM po.po_headers_all
                                        WHERE segment1 IN ('28013', '28012', '28014')))
       AND quantity_billed > quantity_delivered
	   
	   
	   SELECT * --POH.PO_HEADER_ID, POH.SEGMENT1 "PO NO", PRHA.SEGMENT1 "REQUISTION NO"
  FROM PO.PO_HEADERS_ALL             POH,
       PO.PO_DISTRIBUTIONS_ALL       PDA,
       PO.PO_REQ_DISTRIBUTIONS_ALL   PRDA,
       PO.PO_REQUISITION_LINES_ALL   PRLA,
       PO.PO_REQUISITION_HEADERS_ALL PRHA
 WHERE     POH.PO_HEADER_ID = PDA.PO_HEADER_ID
       AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
       AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
       AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
       AND POH.SEGMENT1 IN ('28827')      

/* PO */
SELECT *
  FROM PO.po_distributions_all
 WHERE po_header_id IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('28827', '28849'))    
  

/*Исключение , когда в PO показывает что курс валютаыесть , а в базе нету */
UPDATE PO.po_distributions_all
   SET RATE_DATE = TO_DATE ('04.05.2018', 'dd.mm.yyyy'), RATE = 2.4265
 WHERE PO_DISTRIBUTION_ID = 1127013       
              
/* PO*/
SELECT *
  FROM APPS.po_distributions_all   PDA,
       PO.PO_REQ_DISTRIBUTIONS_ALL PRDA,
       PO.PO_REQUISITION_LINES_ALL PRLA
 WHERE     PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
       AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
       AND PDA.po_header_id IN (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('28827', '28849'))
