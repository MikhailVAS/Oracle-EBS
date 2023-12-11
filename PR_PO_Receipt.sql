/* Ошибка при создании PR
Для позиции интегрируемой с Галактикой,
флаг "Доставка в запасы" длжен быть снят
Проверка: */
SELECT segment1, attribute21, DESCRIPTION
  FROM inv.mtl_system_items_b
 WHERE DESCRIPTION LIKE '%Print Conductor%'

/* Исправление */
UPDATE inv.mtl_system_items_b
   SET attribute21 = 'N'
 WHERE segment1 IN ('3400000329')
Find incorect amount in PO
 UPDATE PO.po_headers_all
   SET CREATION_DATE =
           TO_DATE ('31.08.2023 12:13:56', 'dd.mm.yyyy hh24:mi:ss')
 WHERE segment1 IN ('47585')

/* 	Update need by date in  PR*/	
UPDATE Po_Requisition_Lines_All
   SET NEED_BY_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd-mm-yyyy hh24:mi:ss')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND h.segment1 IN ('108683') -- Number PR
				   AND LINE_NUM = 555 -- Line PR
                   ); 
				   
/* 	Update need by date in  PO*/	   
UPDATE APPS.PO_LINE_LOCATIONS_all
   SET NEED_BY_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd-mm-yyyy hh24:mi:ss')
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('43220')); -- Number PO
                        
/* Update date in Receipt*/
UPDATE  PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE PO_HEADER_ID in (SELECT po_header_id
                             FROM PO.po_headers_all
                            WHERE segment1 IN ('54772')); 
                            
 /* Update date in Receipt*/
UPDATE  PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('30.04.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE     SHIPMENT_HEADER_ID IN (SELECT SHIPMENT_HEADER_ID
                                    FROM PO.RCV_SHIPMENT_HEADERS
                                   WHERE RECEIPT_NUM IN ('RECEIPT')) --AND TRANSACTION_TYPE = 'CORRECT'
       AND PO_HEADER_ID = (SELECT po_header_id
                             FROM PO.po_headers_all
                            WHERE segment1 IN ('PO'));

/* Formatted on (QP5 v5.326) Service Desk 424589 Mihail.Vasiljev */
/* Update date in Receipt by PR*/
UPDATE PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('30.04.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE     SHIPMENT_HEADER_ID IN (SELECT SHIPMENT_HEADER_ID
                                    FROM PO.RCV_SHIPMENT_HEADERS
                                   WHERE RECEIPT_NUM IN ('RECEIPT')) --AND TRANSACTION_TYPE = 'CORRECT'
       AND PO_HEADER_ID =
           (SELECT po_header_id
              FROM PO.po_headers_all
             WHERE segment1 IN
                       (SELECT POH.SEGMENT1
                          FROM APPS.PO_HEADERS_ALL              POH,
                               APPS.PO_DISTRIBUTIONS_ALL        PDA,
                               APPS.PO_REQ_DISTRIBUTIONS_ALL    PRDA,
                               APPS.PO_REQUISITION_LINES_ALL    PRLA,
                               APPS.PO_REQUISITION_HEADERS_ALL  PRHA
                         WHERE     POH.PO_HEADER_ID = PDA.PO_HEADER_ID
                               AND PDA.REQ_DISTRIBUTION_ID =
                                   PRDA.DISTRIBUTION_ID
                               AND PRDA.REQUISITION_LINE_ID =
                                   PRLA.REQUISITION_LINE_ID
                               AND PRLA.REQUISITION_HEADER_ID =
                                   PRHA.REQUISITION_HEADER_ID
                               AND PRHA.SEGMENT1 = 'PR'));  					 
						 
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
								 
/*1) Не получается создать Receipt на услугу, ошибка складского подразделения  */
UPDATE PO_REQUISITION_LINES_ALL
SET DESTINATION_CONTEXT = 'EXPENSE'                             --INVENTORY
                                    , DESTINATION_TYPE_CODE = 'EXPENSE' --INVENTORY
--select DESTINATION_CONTEXT, DESTINATION_TYPE_CODE, PRL.* from PO_REQUISITION_LINES_ALL PRL
WHERE     LINE_LOCATION_ID IN
            (SELECT LINE_LOCATION_ID
                FROM PO_LINE_LOCATIONS_ALL
                WHERE po_header_id IN (SELECT po_header_id
                                        FROM po_headers_all
                                        WHERE segment1 IN ( :PO)))
    AND (   DESTINATION_CONTEXT != 'EXPENSE'
        OR DESTINATION_TYPE_CODE != 'EXPENSE');

/*2) Не получается создать Receipt на услугу, ошибка складского подразделения  */
UPDATE po_distributions_all
SET DESTINATION_CONTEXT = 'EXPENSE',                           -- INVENTORY
    Destination_Type_Code = 'EXPENSE',                          --INVENTORY
    ACCRUE_ON_RECEIPT_FLAG = 'N'                                     -- 'Y'
--select PDA.DESTINATION_CONTEXT, PDA.Destination_Type_Code, ACCRUE_ON_RECEIPT_FLAG, PDA.* /*,RLA.* */ from po_distributions_all PDA --, PO_REQUISITION_LINES_ALL RLA
WHERE     po_distribution_id IN
            (SELECT po_distribution_id
                FROM po.po_distributions_all d
                WHERE po_header_id IN (SELECT po_header_id
                                        FROM po_headers_all
                                        WHERE segment1 IN ( :PO)))
    AND (   DESTINATION_CONTEXT != 'EXPENSE'
        OR Destination_Type_Code != 'EXPENSE'
        OR ACCRUE_ON_RECEIPT_FLAG != 'N');

/* Не получается создать Receipt на услугу */
UPDATE APPS.po_distributions_all
   SET DELIVER_TO_LOCATION_ID = '142'
WHERE po_header_id IN (SELECT po_header_id
                          FROM APPS.po_headers_all
                         WHERE segment1 IN ('48464'))

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

/*=======================================================================*/
/* Formatted on  (QP5 v5.326) Service Desk 458163 Mihail.Vasiljev */
/* Изменить номер прихода*/
UPDATE PO.RCV_SHIPMENT_HEADERS rsh
   SET WAYBILL_AIRBILL = '8559225213(1538558572)'
 WHERE rsh.shipment_header_id IN
           (SELECT shipment_header_id
              FROM PO.RCV_TRANSACTIONS rt
             WHERE po_header_id = (SELECT po_header_id
                                     FROM PO.PO_HEADERS_ALL po
                                    WHERE po.segment1 = '42494'))

UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET WAYBILL_AIRBILL = '8559225213(1538558572)'
 WHERE TRANSACTION_ID IN ('43621766',
                          '43621761',
                          '43621756',
                          '43621751')
/* Изменить номер прихода  End */
/*=======================================================================*/

/* Add code_combination_id in po_req_distributions_all*/
UPDATE po.po_req_distributions_all
   SET code_combination_id = 180320
 WHERE     requisition_line_id IN (SELECT requisition_line_id
                                     FROM po.po_requisition_lines_all
                                    WHERE requisition_header_id = 1079934)
       AND code_combination_id = 0	   
-- Old 529740   01.0806.0.0.0.DMN040200.0.740_07_06_00_00_00.0.0.A_2_250_01_04_1.0.0.0.0
-- NEW 540397   01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0
SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0'

/* Formatted (QP5 v5.326) Service Desk 355956 Mihail.Vasiljev */						 
/* Update budget code(ccid) in PR */
UPDATE po.PO_REQ_DISTRIBUTIONS_ALL
   SET CODE_COMBINATION_ID =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQUISITION_LINES_ALL
             WHERE REQUISITION_HEADER_ID IN
                       (SELECT REQUISITION_HEADER_ID
                          FROM po.PO_REQUISITION_HEADERS_ALL
                         WHERE segment1 IN ('93022')))
                         
                         
/* Formatted (QP5 v5.326) Service Desk 355956 Mihail.Vasiljev */
/* Update budget code(ccid) in PO */
UPDATE po.po_distributions_all
   SET code_combination_id =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0')
 WHERE po_header_id IN (SELECT po_header_id
                          FROM po.po_headers_all
                         WHERE segment1 IN ('36784'))
	   
/* Formatted on 9/2/2021 1:08:38 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
/* Update budget code(ccid) in PO */
UPDATE po.po_distributions_all
   SET code_combination_id =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.2001.0.0.0.DMN040200.0.740_07_07_01_00_00.0.0.PL_740_07.0.0.0.0')
 WHERE po_header_id IN (SELECT po_header_id
                          FROM po.po_headers_all
                         WHERE segment1 IN ('35488'))

/* Formatted on 9/2/2021 1:08:38 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */						 
/* Update budget code(ccid) in PR */
UPDATE po.PO_REQ_DISTRIBUTIONS_ALL
   SET CODE_COMBINATION_ID =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.2001.0.0.0.DMN040200.0.740_07_07_01_00_00.0.0.PL_740_07.0.0.0.0')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQUISITION_LINES_ALL
             WHERE REQUISITION_HEADER_ID IN
                       (SELECT REQUISITION_HEADER_ID
                          FROM po.PO_REQUISITION_HEADERS_ALL
                         WHERE segment1 IN ('89816')))
						 
						 
/* Find all lines in PR by 15 segment account and PR */
SELECT *
  FROM po.PO_REQUISITION_LINES_ALL
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQ_DISTRIBUTIONS_ALL
             WHERE     REQUISITION_LINE_ID IN
                           (SELECT REQUISITION_LINE_ID
                              FROM po.PO_REQUISITION_LINES_ALL
                             WHERE REQUISITION_HEADER_ID IN
                                       (SELECT REQUISITION_HEADER_ID
                                          FROM po.PO_REQUISITION_HEADERS_ALL
                                         WHERE segment1 IN ('94947')))
                   AND CODE_COMBINATION_ID =
                       (SELECT CODE_COMBINATION_ID
                          FROM apps.gl_code_combinations_kfv
                         WHERE CONCATENATED_SEGMENTS =
                               '01.2001.0.0.0.DSM150001.0.740_18_19_03_13_00.0.0.PL_740_05_01_6.0.0.0.0'))
       
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

 /*Update Service Desk 550383(557922) Mihail.Vasiljev */
UPDATE po.po_distributions_all
   SET RATE = '2.9482'
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('46814'))  

/*Исключение , когда в PO показывает что курс валютаыесть , а в базе нету */
UPDATE PO.po_distributions_all
   SET RATE_DATE = TO_DATE ('04.05.2021', 'dd.mm.yyyy'), RATE = 2.4265
 WHERE PO_DISTRIBUTION_ID = 1127013       
              
/* Find incorect amount in PO by PR with currency rate*/
SELECT prha.segment1
           PR,
       prla.line_num
           PR_LINE_NUM,
       prla.QUANTITY
           AS "PR QUANTITY",
       ROUND(prla.QUANTITY_DELIVERED * NVL (pha.rate, 1),2)
           AS "PR QUANTITY_DELIVERED",
       pha.segment1
           po_no,
       pha.CURRENCY_CODE
           AS "PO Currenccy",
       pha.rate
           AS "PO Rate",
       pda.QUANTITY_ORDERED
           AS "QUANTITY_ORDERED in PO"
  FROM po.po_requisition_headers_all  prha,
       po.po_requisition_lines_all    prla,
       po.po_req_distributions_all    prda,
       po.po_distributions_all        pda,
       po.po_headers_all              pha
 WHERE     prha.requisition_header_id = prla.requisition_header_id
       AND prla.requisition_line_id = prda.requisition_line_id
       AND prda.distribution_id = pda.req_distribution_id(+)
       AND pda.po_header_id = pha.po_header_id(+)
       AND prha.segment1 = 128860                                        -- PR
UNION
SELECT prha.segment1
           PR,
       prla.line_num
           PR_LINE_NUM,
       prla.QUANTITY
           AS "PR QUANTITY",
       ROUND(prla.QUANTITY_DELIVERED * NVL (pha.rate, 1),2)
           AS "PR QUANTITY_DELIVERED",
       pha.segment1
           po_no,
       pha.CURRENCY_CODE
           AS "PO Currenccy",
       pha.rate
           AS "PO Rate",
       pda.QUANTITY_ORDERED
           AS "QUANTITY_ORDERED in PO"
  FROM po.po_requisition_headers_all  prha,
       po.po_requisition_lines_all    prla,
       po.po_req_distributions_all    prda,
       po.po_distributions_all        pda,
       po.po_headers_all              pha
 WHERE     prha.requisition_header_id = prla.requisition_header_id
       AND prla.requisition_line_id = prda.requisition_line_id
       AND prda.distribution_id = pda.req_distribution_id(+)
       AND pda.po_header_id = pha.po_header_id(+)
       AND prha.segment1 = 128860    


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
								 
/* Open PO or not viseble Receipt */
BEGIN
    UPDATE po_headers_all h
       SET h.authorization_status = 'APPROVED'   ,             --l_change_status                              
           h.APPROVED_FLAG = 'Y',
           approved_date = TRUNC (SYSDATE, 'DD'),
           closed_code = 'OPEN'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));

    UPDATE po_lines_all l
       SET CLOSED_CODE = 'OPEN',
           CLM_INFO_FLAG = 'N',
           clm_option_indicator = 'B'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));


    UPDATE PO_LINE_LOCATIONS_all
       SET APPROVED_FLAG = 'Y',
           CLOSED_CODE = 'OPEN',
           approved_date = SYSDATE,
           ENCUMBERED_FLAG = 'Y'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));

    COMMIT;
END;								 


 /*Find all PR and PO by user*/
SELECT DISTINCT
       prh.segment1
           req_num,
       poh.segment1
           "PO NUMMBER",
       POH.closed_code,
       POH.CREATION_DATE
           CREATION_DATE_PO,                         --fnd.user_name requestor
       POH.TERMS_ID,
       POH.CREATED_BY,
       papf.FULL_NAME
           AS "Buyer in PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = POH.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = prh.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PR",
       eit.INVOICE_TYPE_DETAIL
           AS "CONTRACT IN PO",
       TT.NAME
           "TERMS NAME IN PO",
       TT.DESCRIPTION
           "TERMS DESCRIPTION IN PO",
       POH.COMMENTS
           "COMMENTS IN PO",
       POH.CREATION_DATE
           "CREATION DATE IN PO",
       POH.AUTHORIZATION_STATUS
           "STATUS  IN PO"
  FROM APPS.po_line_locations_all       ploc,
       APPS.po_lines_all                pol,
       APPS.po_headers_all              poh,
       APPS.po_requisition_lines_all    prl,
       APPS.po_requisition_headers_all  prh,
       APPS.AP_TERMS_TL                 TT,
       APPS.xxtg_ef_invoice_type        eit,
       po.po_agents                     pa,
       hr.per_all_people_f              papf
 WHERE     poh.po_header_id = pol.po_header_id(+)
       AND pol.po_line_id = ploc.po_line_id(+)
       AND ploc.line_location_id = prl.line_location_id(+)
       AND prl.requisition_header_id = prh.requisition_header_id(+)
       AND (poh.TERMS_ID = TT.TERM_ID(+) AND TT.SOURCE_LANG = 'US')
       AND eit.INVOICE_TYPE_ID(+) = poh.ATTRIBUTE1
       AND POH.AGENT_ID = pa.agent_id
       AND pa.agent_id = papf.person_id
       --   AND prh.preparer_id = fnd.employee_id(+)
       AND (   POH.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                                  'dd.mm.yyyy HH24:MI:ss')
                                     AND TO_DATE ('28.01.2021 23:59:59',
                                                  'dd.mm.yyyy HH24:MI:ss')
            OR prh.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                                  'dd.mm.yyyy HH24:MI:ss')
                                     AND TO_DATE ('28.01.2021 23:59:59',
                                                  'dd.mm.yyyy HH24:MI:ss'))
       AND (   prh.CREATED_BY =
               (SELECT user_id
                  FROM APPS.fnd_user
                 WHERE EMPLOYEE_ID IN
                           (SELECT PERSON_ID
                              FROM APPS.per_all_people_f
                             WHERE FULL_NAME LIKE '%Роксолана%'))
            OR POH.AGENT_ID =
               (SELECT papf2.person_id
                  FROM hr.per_all_people_f papf2
                 WHERE papf2.FULL_NAME LIKE '%Роксолана%'))
       AND POH.closed_code = 'OPEN'  
							            

/* Проблема согласования PO "Не найден утверждающий для документа"  
1) Проверка карточки сотрудника 
2) Проверка иерархии
3) Проверка Supervisor-ov запросом*/
SELECT *
  FROM APPS.wf_users
 WHERE     1 = 1
       AND --AND orig_system = 'PER'
           --AND status = 'ACTIVE'
           DESCRIPTION IN
               ('Томуть, Евгения Александровна',
                'Церкасевич, Татьяна Витальевна',
                'Бородач, Марина Александровна')

/* Все PO  за 2018 с условиями оплаты */
SELECT DISTINCT  PHA.SEGMENT1 "PO NUMMBER",
       PHA.COMMENTS,
       PHA.CREATION_DATE,
       PHA.AUTHORIZATION_STATUS,
       TT.NAME        "TERMS NAME",
       TT.DESCRIPTION "TERMS DESCRIPTION"
  FROM APPS.po_headers_all PHA, APPS.AP_TERMS_TL TT
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND TT.SOURCE_LANG = 'US'
       --AND segment1 IN ('30203')
       AND PHA.CREATION_DATE >= to_date('01.01.2018', 'dd.mm.yyyy')
       ORDER BY PHA.SEGMENT1
	   

/* Open PO for Cancel*/
DECLARE
    l_search_status   VARCHAR2 (30) := 'INCOMPLETE';
    l_change_status   VARCHAR2 (30) := 'APPROVED';
BEGIN
    FOR hrec
        IN (SELECT po_HEADER_ID, segment1, APPROVED_FLAG
              FROM po_headers_all
             WHERE     APPROVED_FLAG = 'Y'
                   AND segment1 = '32040'
                   AND closed_code = 'CLOSED'--                        and trunc(last_update_date) = to_date('28122018', 'ddmmyyyy')
                                             )
    LOOP
        --        DBMS_OUTPUT.put_line ( 'Change status for order #: ' || hrec.segment1);

        UPDATE po_headers_all h
           SET h.authorization_status = 'APPROVED'           --l_change_status
                                                  ,
               h.APPROVED_FLAG = 'Y',
               approved_date = SYSDATE,
               closed_code = 'OPEN'
         --      , AUTHORIZATION_STATUS = 'INCOMPLETE'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;

        UPDATE po_lines_all l
           SET CLOSED_CODE = 'OPEN',
               CLM_INFO_FLAG = 'N',
               clm_option_indicator = 'B'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;


        UPDATE PO_LINE_LOCATIONS_all
           SET APPROVED_FLAG = 'Y',
               CLOSED_CODE = 'OPEN',
               approved_date = SYSDATE,
               ENCUMBERED_FLAG = 'Y'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;

        DELETE FROM PO_ACTION_HISTORY
              WHERE OBJECT_ID = hrec.po_HEADER_ID AND ACTION_CODE = 'CLOSE';
    END LOOP;

    COMMIT;
END;

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

								 
/* */

 -- line 2 of 84374
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '760_02_2_3_02_01')
where requisition_line_id = 969154;

 -- line 1 of 84374
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '760_02_2_3_01_01')
where requisition_line_id = 969842;

-- line 1 of 84385
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '740_15_05_00_00_00')
where requisition_line_id = 969869; 

-- line 2 of 84385
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '740_15_03_00_00_00')
where requisition_line_id = 969872; 

update Po_Requisition_Lines_All     
set NEED_BY_DATE = to_date('31-01-2021 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
where REQUISITION_LINE_ID in (select REQUISITION_LINE_ID 
    FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
    WHERE l.Requisition_Header_Id = h.Requisition_Header_Id
       AND h.segment1 in ('84390', '84395 ', '84374'));
       


declare
   L_Cc_Segment1       VARCHAR2 (25 BYTE) := '01';
   L_Cc_Segment2       VARCHAR2 (25 BYTE) := '0001';
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
   
   l_DESTINATION_TYPE_CODE VARCHAR2 (25 BYTE);   

   l_nat_acc VARCHAR2 (25 BYTE);
   l_ifrs_acc VARCHAR2 (25 BYTE);
   

  BEGIN
  
    FOR rec_line IN (
                            SELECT DISTINCT h.segment1 as req_num,
                                            l.line_num,
                                            l.requisition_line_id,
                                            reqd.distribution_id,
                                            pod.po_distribution_id,
                                            fv.flex_value budget_code,
                                            NVL(l.Attribute10, h.Attribute10) department_code,
                                            l.NEED_BY_DATE,
                                            l.quantity,
                                            l.item_id,
                                            reqd.Set_Of_Books_Id,
                                            gcc.Segment1,
                                            gcc.Segment2,
                                            gcc.Segment3,
                                            gcc.Segment4,
                                            gcc.Segment5,
                                            gcc.Segment6,
                                            gcc.Segment7,
                                            gcc.Segment8,
                                            gcc.Segment9,
                                            gcc.Segment10,
                                            gcc.Segment11,
                                            gcc.Segment12,
                                            gcc.Segment13,
                                            gcc.Segment14,
                                            gcc.Segment15,
                                            l.DESTINATION_TYPE_CODE,
                                            reqd.CODE_COMBINATION_ID
                              FROM po_distributions_all pod,
                                   PO_REQ_DISTRIBUTIONS_ALL reqd,
                                   Po_Requisition_Lines_All l,
                                   Po_Requisition_Headers_All h,
                                   gl_code_combinations gcc,
                                   fnd_flex_values fv
                             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                                   AND reqd.requisition_line_id = l.requisition_line_id
                                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                                   AND gcc.code_combination_id = reqd.CODE_COMBINATION_ID
                                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                                   AND fv.flex_Value_id = NVL (l.Attribute9, h.Attribute9)
                                   AND h.segment1 IN ('84390', '84395 ', '84374','84385')                             
                            )
    LOOP
        
        L_Cc_Id := rec_line.CODE_COMBINATION_ID;

       L_Cc_Segment1 := rec_line.Segment1;
       L_Cc_Segment2 := rec_line.Segment2    ;
       L_Cc_Segment3 := rec_line.Segment3      ;
       L_Cc_Segment4 := rec_line.Segment4      ;
       L_Cc_Segment5 := rec_line.Segment5      ;
       L_Cc_Segment6 := rec_line.Segment6     ;
       L_Cc_Segment7 := rec_line.Segment7    ;
       L_Cc_Segment8 := rec_line.Segment8  ;
       L_Cc_Segment9 := rec_line.Segment9     ;
       L_Cc_Segment10 := rec_line.Segment10   ;
       L_Cc_Segment11 := rec_line.Segment11    ;
       L_Cc_Segment12 := rec_line.Segment12    ;
       L_Cc_Segment13 := rec_line.Segment13    ;
       L_Cc_Segment14 := rec_line.Segment14  ;
       L_Cc_Segment15 := rec_line.Segment15   ;        
       

        DBMS_OUTPUT.put_line ('Original ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
        
        L_Cc_Segment8 :=  rec_line.budget_code;
    
        if rec_line.DESTINATION_TYPE_CODE = 'EXPENSE' and L_Cc_Segment2 = '0001' then

                  SELECT nvl(cat.ATTRIBUTE1, L_Cc_Segment2), nvl(cat.ATTRIBUTE3, L_Cc_Segment11)
                    INTO l_nat_acc, l_ifrs_acc
                    FROM Mtl_Item_Categories ic, Mtl_Categories_b cat
                   WHERE inventory_item_id = rec_line.item_id
                            and organization_id = 83
                         AND Category_Set_Id = 1100000041
                         AND cat.category_id = ic.category_id; 

                     L_Cc_Segment2 := l_nat_acc;
                     L_Cc_Segment11 := l_ifrs_acc;

       end if;              


        SELECT Chart_Of_Accounts_Id
        INTO L_Coa_Id
        FROM Gl_Sets_Of_Books
        WHERE Set_Of_Books_Id = rec_line.Set_Of_Books_Id;
    
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
                
        DBMS_OUTPUT.put_line ('Updated ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);

         UPDATE po.po_req_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE distribution_id = rec_line.distribution_id;           
         
        if (rec_line.po_distribution_id is not null) then

            UPDATE po.po_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE po_distribution_id = rec_line.po_distribution_id;              

        end if;


    END LOOP;
    
--commit;    

  END return_pr_lines;
  
  /* Перенос сумм бюджета с мая на июнь */
--by line number

DECLARE
    l_req_num        VARCHAR2 (40) := '97864';                    -- PR number
    l_req_line_num   NUMBER := &Rln;                                -- PR line
    l_amount         NUMBER := &amount;
BEGIN
    UPDATE Po_Requisition_Lines_All                     --PO_LINES_ARCHIVE_ALL
       SET quantity = l_amount
     -- select quantity from Po_Requisition_Lines_All
     WHERE REQUISITION_LINE_ID IN
               (SELECT REQUISITION_LINE_ID
                  FROM Po_Requisition_Lines_All    l,
                       Po_Requisition_Headers_All  h
                 WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                       AND h.segment1 IN (l_req_num)
                       AND LINE_NUM = l_req_line_num);

    UPDATE Po_Req_distributions_All d
       SET REQ_LINE_QUANTITY =
               (SELECT quantity
                  FROM Po_Requisition_Lines_All l1
                 WHERE l1.REQUISITION_LINE_ID = d.REQUISITION_LINE_ID)
     WHERE REQUISITION_LINE_ID IN
               (SELECT REQUISITION_LINE_ID
                  FROM Po_Requisition_Lines_All    l,
                       Po_Requisition_Headers_All  h
                 WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                       AND h.segment1 IN (l_req_num)
                       AND LINE_NUM = l_req_line_num);

    UPDATE Po_distributions_All d
       SET QUANTITY_ORDERED =
               (SELECT REQ_LINE_QUANTITY
                  FROM Po_Req_distributions_All d1
                 WHERE d1.DISTRIBUTION_ID = d.req_DISTRIBUTION_ID)
     WHERE req_DISTRIBUTION_ID IN
               (SELECT DISTRIBUTION_ID
                  FROM Po_Req_distributions_All d
                 WHERE REQUISITION_LINE_ID IN
                           (SELECT REQUISITION_LINE_ID
                              FROM Po_Requisition_Lines_All    l,
                                   Po_Requisition_Headers_All  h
                             WHERE     l.Requisition_Header_Id =
                                       h.Requisition_Header_Id
                                   AND h.segment1 IN (l_req_num)
                                   AND LINE_NUM = l_req_line_num));

    UPDATE Po_lines_All l
       SET quantity =
               (SELECT QUANTITY_ORDERED
                  FROM Po_distributions_All d1
                 WHERE d1.po_line_id = l.po_line_id)
     WHERE po_line_id IN
               (SELECT po_line_id
                  FROM Po_distributions_All
                 WHERE req_DISTRIBUTION_ID IN
                           (SELECT DISTRIBUTION_ID
                              FROM Po_Req_distributions_All d
                             WHERE REQUISITION_LINE_ID IN
                                       (SELECT REQUISITION_LINE_ID
                                          FROM Po_Requisition_Lines_All    l,
                                               Po_Requisition_Headers_All  h
                                         WHERE     l.Requisition_Header_Id =
                                                   h.Requisition_Header_Id
                                               AND h.segment1 IN (l_req_num)
                                               AND LINE_NUM = l_req_line_num)));
											   
UPDATE PO_LINE_LOCATIONS_ALL
   SET QUANTITY = l_amount
WHERE PO_LINE_ID  IN
               (SELECT po_line_id
                  FROM Po_distributions_All
                 WHERE req_DISTRIBUTION_ID IN
                           (SELECT DISTRIBUTION_ID
                              FROM Po_Req_distributions_All d
                             WHERE REQUISITION_LINE_ID IN
                                       (SELECT REQUISITION_LINE_ID
                                          FROM Po_Requisition_Lines_All    l,
                                               Po_Requisition_Headers_All  h
                                         WHERE     l.Requisition_Header_Id =
                                                   h.Requisition_Header_Id
                                               AND h.segment1 IN (:l_req_num)
                                               AND LINE_NUM = :l_req_line_num)));

    COMMIT;
END;



/* Прошу сделать выборку всех открытых РО, с указанием:
1. Контрагента,
2. Уникального номера контрагента,
3. Номера контракта,
4. Контрагента,
5. Даты создания контрагента,
6. Условия оплаты.*/
SELECT DISTINCT                                                            --*
                PHA.SEGMENT1       "PO NUMMBER",
                sup.VENDOR_NAME,
                SUP.VAT_REGISTRATION_NUM,
                eit.INVOICE_TYPE_DETAIL,
                SUP.START_DATE_ACTIVE,
                SUP.END_DATE_ACTIVE,
                TT.NAME            "TERMS NAME",
                TT.DESCRIPTION     "TERMS DESCRIPTION",
                PHA.COMMENTS,
                PHA.CREATION_DATE,
                PHA.AUTHORIZATION_STATUS
 FROM APPS.po_headers_all  PHA,
       APPS.AP_TERMS_TL     TT,
       ap.ap_suppliers      sup,
       xxtg_ef_invoice_type  eit
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND SUP.VENDOR_ID = PHA.VENDOR_ID
       AND eit.VENDOR_ID(+) = PHA.VENDOR_ID
       AND eit.INVOICE_TYPE_ID(+) = PHA.ATTRIBUTE1
       AND TT.SOURCE_LANG = 'US'
--       AND APPROVED_FLAG = 'Y'
       AND closed_code = 'OPEN'
       --       AND PHA.SEGMENT1 IN ('32264')
       AND PHA.CREATION_DATE BETWEEN TO_DATE ('01.01.2021', 'dd.mm.yyyy')
                                 AND SYSDATE;
--       ORDER BY PHA.SEGMENT1


/* Прошу сделать выборку всех открытых РО, с указанием:
1. Контрагента,
2. Уникального номера контрагента,
3. Номера контракта,
4. Контрагента,
5. Даты создания контрагента,
6. Условия оплаты.*/
SELECT DISTINCT                                                            
       PHA.SEGMENT1
           "PO NUMMBER",
       PHA.TERMS_ID,
       PHA.CREATED_BY,
       (SELECT DISTINCT USER_NAME
          FROM APPS.fnd_user fu
         WHERE fu.USER_ID = PHA.CREATED_BY)
           AS "CREATOR PO",
       eit.INVOICE_TYPE_DETAIL
           AS "CONTRACT IN PO",
       TT.NAME
           "TERMS NAME IN PO",
       TT.DESCRIPTION
           "TERMS DESCRIPTION IN PO",
       (SELECT DISTINCT ATT.NAME
          FROM XXTG.XXTG_EF_INVOICE_TYPE XEIT, APPS.AP_TERMS_TL ATT
         WHERE     1 = 1
               AND XEIT.INVOICE_TYPE_DETAIL = eit.INVOICE_TYPE_DETAIL
               AND XEIT.VENDOR_ID = PHA.VENDOR_ID
               AND XEIT.PAYMENT_TERM(+) = ATT.TERM_ID
               AND ATT.SOURCE_LANG = 'US')
           AS "TERMS NAME IN eFirm",
       sup.VENDOR_NAME
           AS "VENDOR NAME IN eFirm",
       SUP.VAT_REGISTRATION_NUM
           AS "VRN(УНП) IN eFirm",
       SUP.START_DATE_ACTIVE
           AS "START DATE IN eFirm",
       SUP.END_DATE_ACTIVE
           AS "END DATE IN eFirm",
       PHA.COMMENTS
           "COMMENTS IN PO",
       PHA.CREATION_DATE
           "CREATION DATE IN PO",
       PHA.AUTHORIZATION_STATUS
           "STATUS  IN PO"
  FROM APPS.po_headers_all        PHA,
       APPS.AP_TERMS_TL           TT,
       ap.ap_suppliers            sup,
       APPS.xxtg_ef_invoice_type  eit
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND SUP.VENDOR_ID = PHA.VENDOR_ID
       AND eit.VENDOR_ID(+) = PHA.VENDOR_ID
       AND eit.INVOICE_TYPE_ID(+) = PHA.ATTRIBUTE1
       AND TT.SOURCE_LANG = 'US'
       AND APPROVED_FLAG = 'Y'
       AND closed_code = 'OPEN'
       --                AND PHA.SEGMENT1 IN ('35720')
       AND PHA.CREATION_DATE BETWEEN TO_DATE ('01.01.2021', 'dd.mm.yyyy')
                                 AND SYSDATE
								 
								 
/*================================*/
SELECT apss.VENDOR_SITE_ID, aps.VENDOR_ID,
       aps.VENDOR_NAME
           AS "Наименование",
       aps.VENDOR_NAME_ALT
           AS "Альтернативное наименование",
       aps.VAT_REGISTRATION_NUM
           AS "УНП",
       NVL2 (TO_CHAR (aps.END_DATE_ACTIVE), 'No', 'Active')
           AS "Статус",
    aps.VENDOR_TYPE_LOOKUP_CODE
           AS "Тип Фирмы",
       MSI.SECONDARY_INVENTORY_NAME
           AS "Код дилера",
           MSI.ORGANIZATION_ID,
       CASE MSI.ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организаци ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           ELSE 'Слад не привязан'
       END
           AS "Наименованеи_склада"
  FROM ap.ap_suppliers                aps,
       ap.ap_supplier_sites_all       apss,
       APPS.ar_customers              ars,
       inv.MTL_SECONDARY_INVENTORIES  MSI
 WHERE     aps.vendor_id = apss.vendor_id
       AND ars.CUSTOMER_NAME(+) = aps.VENDOR_NAME
       --AND ars.TAX_REFERENCE = aps.VAT_REGISTRATION_NUM
	   --aps.VAT_REGISTRATION_NUM = 'УНП'
       AND ars.CUSTOMER_ID = MSI.ATTRIBUTE5(+)
       AND VENDOR_NAME like '%ООО ЭЛИТ%'   --- 104409  
	   
/* Update vendor in PO */
UPDATE PO.PO_HEADERS_ALL po
   SET po.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                       'Минский городской центр недвижимости УП'),
       po.vendor_site_id =
           (SELECT apss.VENDOR_SITE_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                       'Минский городской центр недвижимости УП')
 WHERE po.segment1 = '50722';
                    

/* Update vendor in Receipt transactions */
UPDATE PO.RCV_TRANSACTIONS rt
   SET rt.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                           'Минский городской центр недвижимости УП'),
       rt.vendor_site_id =
           (SELECT apss.VENDOR_SITE_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                           'Минский городской центр недвижимости УП')
 WHERE     po_header_id = (SELECT po_header_id
                             FROM PO.PO_HEADERS_ALL po
                            WHERE po.segment1 = '50722')
       AND shipment_header_id in
           (SELECT rsh.shipment_header_id
              FROM PO.RCV_SHIPMENT_HEADERS rsh
             WHERE     rsh.shipment_header_id IN
                           (SELECT shipment_header_id
                              FROM PO.RCV_TRANSACTIONS rt
                             WHERE po_header_id in
                                   (SELECT po_header_id
                                      FROM PO.PO_HEADERS_ALL po
                                     WHERE po.segment1 = '50722'))
                   AND RECEIPT_NUM in ('67640'));

/* Update vendor in Receipt Header */
UPDATE PO.RCV_SHIPMENT_HEADERS rsh
   SET rsh.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps
             WHERE  VENDOR_NAME =
                           'Минский городской центр недвижимости УП')
 WHERE     rsh.shipment_header_id IN
               (SELECT shipment_header_id
                  FROM PO.RCV_TRANSACTIONS rt
                 WHERE po_header_id in (SELECT po_header_id
                                         FROM PO.PO_HEADERS_ALL po
                                        WHERE po.segment1 = '50722'))
       AND RECEIPT_NUM in ('67640');


/* №PO, 
   Покупатель (сотрудник отдела закупок),
   сумма PO,
   описание PO,
   поставщик,
   контракт и СРОК ОПЛАТЫ ДЛЯ PO */
  SELECT --PO_ST.PO_HEADER_ID           "Ид Заказа на приобретение",
         PO_ST.PO_NUMBER
             "Номер Заказа на приобретение",
         SUM (PO_ST.PO_AMOUNT)
             OVER (
                 PARTITION BY PO_ST.PO_NUMBER,
                              PO_ST.PO_VENDOR_NAME,
                              PO_ST.PO_CREATION_DATE)
             "Общая сумма Заказа",
         PO_ST.PO_VENDOR_NAME
             "Поставщик",
         PO_ST.PO_DESCRIPTION
             "Описание Заказа",
         PO_ST.PO_CONTRAT_NO
             "Номер контракта",
         TO_CHAR (PO_ST.PO_CREATION_DATE, 'DD.MM.RRRR')
             "Дата создания Заказа",
         PO_ST.PO_BUYER
             "Закупщик",
         PO_ST.PO_LINE_NUM
             "Номер строки Заказа",
         PO_ST.PO_CANCEL_FLAG
             "Статус отменены",
         PO_ST.PO_TERM_NAME
             "Условие оплаты Заказа",
         TO_CHAR (PO_ST.PO_NEED_BY_DATE, 'DD.MM.RRRR')
             "Ожидаемая дата поставки",
         TO_CHAR (PO_ST.DUE_DATE, 'DD.MM.RRRR')
             "Дата платежа",
         PO_ST.PO_AMOUNT
             "Сумма по строке Заказа",
         PO_ST.PO_CURRENCY_CODE
             "Валюта Заказа",
         PO_ST.BUDGET_CODE
             "Код бюджета",
         PO_ST.DEPARTMENT_CODE
             "Код департамента",
         PO_ST.CASH_FLOW_BUDGET_TYPE
             "Тип бюджета"
    FROM (SELECT POH.PO_HEADER_ID
                     PAYMENT_DOC_ID,
                 ------------------------------------------------------------------------------
                 'PO'
                     SOURCE,
                 POH.CURRENCY_CODE
                     CURRENCY_CODE,
                   NVL (POL.UNIT_PRICE, 0)
                 * (  PLL.QUANTITY
                    - NVL (PLL.QUANTITY_RECEIVED, 0)
                    + NVL (PLL.QUANTITY_CANCELLED, 0))
                 * (ATL.DUE_PERCENT / 100)
                     AMOUNT_PLAN_ON_DATE,
                 AP_CREATE_PAY_SCHEDS_PKG.CALC_DUE_DATE (
                     P_TERMS_DATE         => PLL.NEED_BY_DATE,
                     P_TERMS_ID           => ATL.TERM_ID,
                     P_CALENDAR           => ATL.CALENDAR,
                     P_SEQUENCE_NUM       => ATL.SEQUENCE_NUM,
                     P_CALLING_SEQUENCE   => ATL.SEQUENCE_NUM)
                     DUE_DATE,
                 CC.SEGMENT8
                     BUDGET_CODE,
                 DEP.DESCRIPTION
                     DEPARTMENT_CODE,
                 (SELECT FBI.BUDGET_ITEM_TYPE
                    FROM APPS.XXTG_CASH_FLOW_BUDGET_ITEM_V FBI
                   WHERE FBI.BUDGET_CODE = CC.SEGMENT8 AND ROWNUM = 1)
                     CASH_FLOW_BUDGET_TYPE,
                 ---------------------------------------------------------------------
                 POH.PO_HEADER_ID
                     PO_HEADER_ID,
                 TO_CHAR (POH.SEGMENT1)
                     PO_NUMBER,
                 PLL.NEED_BY_DATE
                     PO_NEED_BY_DATE,
                 NVL ((POL.QUANTITY * POL.UNIT_PRICE), 0)
                     PO_AMOUNT,
                 NVL ((POL.QUANTITY * POL.UNIT_PRICE), 0)
                     PO_SUM_AMOUNT,
                 POH.CURRENCY_CODE
                     PO_CURRENCY_CODE,
                 VEN.VENDOR_NAME
                     PO_VENDOR_NAME,
                 POH.COMMENTS
                     PO_DESCRIPTION,
                 IVC.CONTRAT_NO
                     PO_CONTRAT_NO,
                 ATR.NAME
                     PO_TERM_NAME,
                 (SELECT PLE.FULL_NAME
                    FROM APPS.PER_PEOPLE_F PLE
                   WHERE     POH.AGENT_ID = PLE.PERSON_ID
                         AND TRUNC (SYSDATE) BETWEEN PLE.EFFECTIVE_START_DATE
                                                 AND PLE.EFFECTIVE_END_DATE)
                     PO_BUYER,
                 POH.CREATION_DATE
                     PO_CREATION_DATE,
                 NVL (POL.CANCEL_FLAG, 'N')
                     PO_CANCEL_FLAG,
                 POL.LINE_NUM
                     PO_LINE_NUM
            FROM PO.PO_HEADERS_ALL           POH,
                 PO.PO_LINES_ALL             POL,
                 PO.PO_DISTRIBUTIONS_ALL     POD,
                 PO.PO_LINE_LOCATIONS_ALL    PLL,
                 APPS.AP_TERMS_VL            ATR,
                 AP_TERMS_LINES              ATL,
                 GL.GL_CODE_COMBINATIONS     CC,
                 APPS.XXTG_DEPARTMENT_V      DEP,
                 APPS.PO_VENDORS             VEN,
                 APPS.XXTG_INVOICE_CONTRACT_V IVC,
                 DUAL
           WHERE     1 = 1
                 --AND POH.PO_HEADER_ID in (240193)
                 --AND PO_ST.PO_CREATION_DATE BETWEEN TO_DATE('01.01.2021','DD.MM.RRRR') AND TO_DATE('30.04.2023','DD.MM.RRRR')
                 AND PLL.NEED_BY_DATE BETWEEN TO_DATE ('01.01.2021',
                                                       'DD.MM.RRRR')
                                          AND TO_DATE ('01.01.2021',
                                                       'DD.MM.RRRR')
                 AND POH.TYPE_LOOKUP_CODE = 'STANDARD'
                 AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
                 --AND NVL(POL.CANCEL_FLAG, 'N') = 'N'
                 --AND NVL(POL.CLOSED_CODE, 'OPEN') not in ('CLOSED','FINALLY CLOSED')
                 AND POL.PO_LINE_ID = POD.PO_LINE_ID
                 AND POD.PO_LINE_ID = PLL.PO_LINE_ID
                 AND POD.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID
                 AND POH.TERMS_ID = ATR.TERM_ID
                 AND ATR.TERM_ID = ATL.TERM_ID
                 AND POD.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
                 AND CC.SEGMENT6 = DEP.DEPARTMENT_CODE
                 AND POH.VENDOR_ID = VEN.VENDOR_ID
                 --AND VEN.VENDOR_NAME <> 'Dummy Supplier'
                 --AND PLL.QUANTITY - NVL(PLL.QUANTITY_RECEIVED,0) + nvl(PLL.QUANTITY_CANCELLED,0) = PLL.QUANTITY
                 AND POH.ATTRIBUTE1 = TO_CHAR (IVC.CONTRACT_ID(+))) PO_ST
ORDER BY                                                 --PO_ST.PO_HEADER_ID,
         PO_ST.PO_NUMBER, PO_ST.PO_LINE_NUM, PO_ST.PO_NEED_BY_DATE;
		 
		 
/* Find Buyer and creator in PO */
SELECT POH.segment1 "PO",
       POH.closed_code "Status PO",
       FULL_NAME
           AS "Buyer in PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = POH.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PO"
  FROM APPS.po_headers_all POH, po.po_agents pa, hr.per_all_people_f papf
 WHERE     POH.AGENT_ID = pa.agent_id
       AND pa.agent_id = papf.person_id
       AND FULL_NAME LIKE '%Роксолана%'
       AND POH.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                              'dd.mm.yyyy HH24:MI:ss')
                                 AND TO_DATE ('28.01.2021 23:59:59',
                                              'dd.mm.yyyy HH24:MI:ss')
       AND POH.closed_code = 'OPEN'

--=============================================================================
/* Formatted on (QP5 v5.326) Service Desk 562059 Mihail.Vasiljev */
/*Прошу изменить HIZ*/
UPDATE  Po_Requisition_Lines_All
   SET item_id =
           (SELECT DISTINCT INVENTORY_ITEM_ID
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012'),
         ITEM_DESCRIPTION = (SELECT DISTINCT DESCRIPTION
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND h.segment1 IN ('104856'));
     
UPDATE po_lines_all
   SET item_id =
           (SELECT DISTINCT INVENTORY_ITEM_ID
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012'),
         ITEM_DESCRIPTION = (SELECT DISTINCT DESCRIPTION
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012')
 WHERE po_line_ID IN
           (SELECT pod.po_line_ID
              FROM po_distributions_all        pod,
                   PO_REQ_DISTRIBUTIONS_ALL    reqd,
                   Po_Requisition_Lines_All    l,
                   Po_Requisition_Headers_All  h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND reqd.requisition_line_id = l.requisition_line_id
                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                   AND h.segment1 IN ('104856'));
				   
--=============================================================================
      
declare
   L_Cc_Segment1       VARCHAR2 (25 BYTE) := '01';
   L_Cc_Segment2       VARCHAR2 (25 BYTE) := '0001';
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
  
   l_DESTINATION_TYPE_CODE VARCHAR2 (25 BYTE);  
   l_nat_acc VARCHAR2 (25 BYTE);
   l_ifrs_acc VARCHAR2 (25 BYTE);
  
  BEGIN
 
    FOR rec_line IN (
                            SELECT DISTINCT h.segment1 as req_num,
                                            l.line_num,
                                            l.requisition_line_id,
                                            reqd.distribution_id,
                                            pod.po_distribution_id,
                                            fv.flex_value budget_code,
                                            NVL(l.Attribute10, h.Attribute10) department_code,
                                            l.NEED_BY_DATE,
                                            l.quantity,
                                            l.item_id,
                                            reqd.Set_Of_Books_Id,
                                            gcc.Segment1,
                                            gcc.Segment2,
                                            gcc.Segment3,
                                            gcc.Segment4,
                                            gcc.Segment5,
                                            gcc.Segment6,
                                            gcc.Segment7,
                                            gcc.Segment8,
                                            gcc.Segment9,
                                            gcc.Segment10,
                                            gcc.Segment11,
                                            gcc.Segment12,
                                            gcc.Segment13,
                                            gcc.Segment14,
                                            gcc.Segment15,
                                            l.DESTINATION_TYPE_CODE,
                                            reqd.CODE_COMBINATION_ID
                              FROM po_distributions_all pod,
                                   PO_REQ_DISTRIBUTIONS_ALL reqd,
                                   Po_Requisition_Lines_All l,
                                   Po_Requisition_Headers_All h,
                                   gl_code_combinations gcc,
                                   fnd_flex_values fv
                             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                                   AND reqd.requisition_line_id = l.requisition_line_id
                                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                                   AND gcc.code_combination_id = reqd.CODE_COMBINATION_ID
                                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                                   AND fv.flex_Value_id = NVL (l.Attribute9, h.Attribute9)
                                   AND h.segment1 IN ('95888','95982')                            
                            )
    LOOP
       
        L_Cc_Id := rec_line.CODE_COMBINATION_ID;
       L_Cc_Segment1 := rec_line.Segment1;
       L_Cc_Segment2 := rec_line.Segment2    ;
       L_Cc_Segment3 := rec_line.Segment3      ;
       L_Cc_Segment4 := rec_line.Segment4      ;
       L_Cc_Segment5 := rec_line.Segment5      ;
       L_Cc_Segment6 := rec_line.Segment6     ;
       L_Cc_Segment7 := rec_line.Segment7    ;
       L_Cc_Segment8 := rec_line.Segment8  ;
       L_Cc_Segment9 := rec_line.Segment9     ;
       L_Cc_Segment10 := rec_line.Segment10   ;
       L_Cc_Segment11 := rec_line.Segment11    ;
       L_Cc_Segment12 := rec_line.Segment12    ;
       L_Cc_Segment13 := rec_line.Segment13    ;
       L_Cc_Segment14 := rec_line.Segment14  ;
       L_Cc_Segment15 := rec_line.Segment15   ;       
      
        DBMS_OUTPUT.put_line ('Original ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
       
        L_Cc_Segment8 :=  rec_line.budget_code;
   
        if rec_line.DESTINATION_TYPE_CODE = 'EXPENSE'  then
                  SELECT nvl(cat.ATTRIBUTE1, L_Cc_Segment2), nvl(cat.ATTRIBUTE3, L_Cc_Segment11)
                    INTO l_nat_acc, l_ifrs_acc
                    FROM Mtl_Item_Categories ic, Mtl_Categories_b cat
                   WHERE inventory_item_id = rec_line.item_id
                            and organization_id = 83
                         AND Category_Set_Id = 1100000041
                         AND cat.category_id = ic.category_id;
                     L_Cc_Segment2 := l_nat_acc;
                     L_Cc_Segment11 := l_ifrs_acc;
       end if;             

        SELECT Chart_Of_Accounts_Id
        INTO L_Coa_Id
        FROM Gl_Sets_Of_Books
        WHERE Set_Of_Books_Id = rec_line.Set_Of_Books_Id;
   
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
               
        DBMS_OUTPUT.put_line ('Updated ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
         UPDATE po.po_req_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE distribution_id = rec_line.distribution_id;          
        
        if (rec_line.po_distribution_id is not null) then
            UPDATE po.po_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE po_distribution_id = rec_line.po_distribution_id;             
        end if;

    END LOOP;
   
commit;   
  END ;      


/* Приход средневзвешенный курс (QP5 v5.326) Service Desk 727299 Mihail.Vasiljev */
UPDATE PO.po_headers_all
   SET RATE_DATE = TO_DATE ('09.11.2023', 'dd.mm.yyyy'),
       RATE = 3.4166,
       RATE_TYPE = 'Spot'
WHERE segment1 IN ('53355')

/* Formatted on (QP5 v5.388) Service Desk 727299 Mihail.Vasiljev */
UPDATE PO.po_distributions_all
   SET RATE_DATE = TO_DATE ('09.11.2023', 'dd.mm.yyyy'), RATE = 3.4166
WHERE PO_HEADER_ID = (SELECT PO_HEADER_ID
                         FROM PO.po_headers_all
                        WHERE segment1 IN ('53355'))

  /* 635920 Приход средневзвешенный курс 
 (QP5 v5.326) Service Desk 635920 Mihail.Vasiljev */
UPDATE PO.po_headers_all
   SET RATE_DATE = TO_DATE ('18.11.2023', 'dd.mm.yyyy'),
       RATE = 2.4355,
       RATE_TYPE = 'Spot'
WHERE segment1 IN ('49941')

/* Formatted (QP5 v5.326) Service Desk 635920 Mihail.Vasiljev */
UPDATE PO.po_distributions_all
   SET RATE_DATE = TO_DATE ('18.11.2023', 'dd.mm.yyyy'), RATE = 2.4355
WHERE PO_DISTRIBUTION_ID in ( 1629200 ,1629201)

/* Formatted on (QP5 v5.388) Service Desk 647730 Исправление суммы в PR Mihail.Vasiljev */
UPDATE po_line_locations_all
   SET QUANTITY = :QUANTITY
 WHERE PO_LINE_ID = :PO_LINE_ID

/* Formatted on (QP5 v5.388) Service Desk 647730 Исправление суммы в PR Mihail.Vasiljev */
SELECT QUANTITY,
       (SELECT PLA2.QUANTITY
         FROM PO_LINES_ALL PLA2
        WHERE     PLA2.po_header_id = PLLA.po_header_id
              AND PLA2.PO_LINE_ID = PLLA.PO_LINE_ID)
  FROM po_line_locations_all PLLA
 WHERE     PLLA.po_header_id IN (SELECT PHA1.po_header_id
                                   FROM PO.po_headers_all PHA1
                                  WHERE PHA1.segment1 IN ('46378'))
       AND PLLA.PO_LINE_ID IN
               (SELECT PLA1.PO_LINE_ID
                 FROM PO_LINES_ALL PLA1
                WHERE     po_header_id IN (SELECT PHA2.po_header_id
                                             FROM PO.po_headers_all PHA2
                                            WHERE PHA2.segment1 IN ('46378'))
                      AND PLA1.LINE_NUM IN (12,
                                            24,
                                            36,
                                            48,
                                            60,
                                            72,
                                            84,
                                            96,
                                            108,
                                            120,
                                            132,
                                            144))

/* Formatted  (QP5 v5.388) Service Desk 653181 Mihail.Vasiljev */
/* Close PO for Receiving in iProcurment1 */
UPDATE po_lines_all 
   SET CLOSED_CODE = 'CLOSED'
 WHERE PO_HEADER_ID IN
           (SELECT poh.po_header_id
             FROM po_headers_all poh
            WHERE     --NVL (poh.closed_code, 'OPEN') = 'OPEN' AND
                   poh.segment1 IN ('24739'))
   AND CLOSED_CODE != 'CLOSED';
   
   
/* Formatted  (QP5 v5.388) Service Desk 653181 Mihail.Vasiljev */
/* Close PO for Receiving in iProcurment2 */
  UPDATE PO_LINE_LOCATIONS_ALL
      SET CLOSED_CODE = 'CLOSED'
 WHERE PO_HEADER_ID IN
           (SELECT poh.po_header_id
              FROM po_headers_all poh
            WHERE     --NVL (poh.closed_code, 'OPEN') = 'OPEN' AND
                   poh.segment1 IN ('24739'))
   AND CLOSED_CODE != 'CLOSED';

/*================== Split line PR by PO Service Desk  Mihail.Vasiljev ======================*/
DECLARE
    l_po_line_amount   NUMBER;
    l_req_line_id_s    NUMBER;
BEGIN
    FOR line_rec
        IN (SELECT DISTINCT rl.requisition_line_id, rl.QUANTITY
             FROM po_distributions_all      pod,
                  PO_REQ_DISTRIBUTIONS_ALL  reqd,
                  Po_Requisition_Lines_All  rl
            WHERE     po_header_id = (SELECT po_header_id
                                        FROM po_headers_all
                                       WHERE segment1 = '51854')
                  AND reqd.distribution_id = pod.req_distribution_id
                  AND rl.requisition_line_id = reqd.requisition_line_id)
    LOOP
        SELECT SUM (quantity * poh.rate)     po_sum_amount
          INTO l_po_line_amount
          FROM po_headers_all poh, po_lines_all pol, po_distributions_all pod
         WHERE     pod.req_distribution_id IN
                       (SELECT distribution_id
                         FROM PO_REQ_DISTRIBUTIONS_ALL
                        WHERE requisition_line_id =
                              line_rec.REQUISITION_LINE_ID)
               AND pol.po_line_id = pod.po_line_id
               AND poh.po_header_id = pod.po_header_id
               AND NVL (pol.cancel_flag, 'N') != 'Y';

        IF (line_rec.quantity > l_po_line_amount)
        THEN
            UPDATE Po_Requisition_Lines_All
               SET QUANTITY = ROUND (l_po_line_amount, 2)
             WHERE REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID;

            SELECT PO_REQUISITION_LINES_S.NEXTVAL
              INTO l_req_line_id_s
              FROM DUAL;

            INSERT INTO PO_REQUISITION_LINES_ALL (
                            REQUISITION_LINE_ID,
                            REQUISITION_HEADER_ID,
                            LINE_NUM,
                            LINE_TYPE_ID,
                            CATEGORY_ID,
                            ITEM_DESCRIPTION,
                            UNIT_MEAS_LOOKUP_CODE,
                            UNIT_PRICE,
                            QUANTITY,
                            DELIVER_TO_LOCATION_ID,
                            TO_PERSON_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            SOURCE_TYPE_CODE,
                            LAST_UPDATE_LOGIN,
                            CREATION_DATE,
                            CREATED_BY,
                            ITEM_ID,
                            SUGGESTED_BUYER_ID,
                            ENCUMBERED_FLAG,
                            RFQ_REQUIRED_FLAG,
                            NEED_BY_DATE,
                            LINE_LOCATION_ID,
                            DOCUMENT_TYPE_CODE,
                            BLANKET_PO_HEADER_ID,
                            BLANKET_PO_LINE_NUM,
                            CURRENCY_CODE,
                            RATE_TYPE,
                            RATE_DATE,
                            RATE,
                            CURRENCY_UNIT_PRICE,
                            SUGGESTED_VENDOR_NAME,
                            SUGGESTED_VENDOR_LOCATION,
                            URGENT_FLAG,
                            DESTINATION_TYPE_CODE,
                            DESTINATION_ORGANIZATION_ID,
                            VENDOR_ID,
                            VENDOR_SITE_ID,
                            DESTINATION_CONTEXT,
                            ORG_ID,
                            CATALOG_TYPE,
                            CATALOG_SOURCE,
                            REQUESTER_EMAIL,
                            PCARD_FLAG,
                            NEW_SUPPLIER_FLAG,
                            ORDER_TYPE_LOOKUP_CODE,
                            PURCHASE_BASIS,
                            MATCHING_BASIS,
                            NEGOTIATED_BY_PREPARER_FLAG,
                            BASE_UNIT_PRICE,
                            TAX_ATTRIBUTE_UPDATE_CODE,
                            UNSPSC_CODE,
                            REQS_IN_POOL_FLAG,
                            ATTRIBUTE9,
                            ATTRIBUTE10)
                SELECT l_req_line_id_s                 /*requisition_line_id*/
                                      ,
                       requisition_header_id         /*requisition_header_id*/
                                            ,
                       l_req_line_id_s                            /*line_num*/
                                      ,
                       line_type_id                           /*line_type_id*/
                                   ,
                       CATEGORY_ID                             /*category_id*/
                                  ,
                       item_description --replace(item_description, ' ' || to_char(l_line_NEED_BY_DATE, 'MM-YYYY'), '')  || ' ' || to_char(ADD_MONTHS(l_line_NEED_BY_DATE, l_counter), 'MM-YYYY')               /*item_description*/
                                       ,
                       unit_meas_lookup_code         /*unit_meas_lookup_code*/
                                            ,
                       UNIT_PRICE,
                       line_rec.quantity - l_po_line_amount,
                       DELIVER_TO_LOCATION_ID,
                       TO_PERSON_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       SOURCE_TYPE_CODE,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       ITEM_ID,
                       SUGGESTED_BUYER_ID,
                       ENCUMBERED_FLAG,
                       RFQ_REQUIRED_FLAG,
                       NEED_BY_DATE,
                       NULL,
                       DOCUMENT_TYPE_CODE,
                       BLANKET_PO_HEADER_ID,
                       BLANKET_PO_LINE_NUM,
                       CURRENCY_CODE,
                       RATE_TYPE,
                       RATE_DATE,
                       RATE,
                       CURRENCY_UNIT_PRICE,
                       SUGGESTED_VENDOR_NAME,
                       SUGGESTED_VENDOR_LOCATION,
                       URGENT_FLAG,
                       DESTINATION_TYPE_CODE,
                       DESTINATION_ORGANIZATION_ID,
                       VENDOR_ID,
                       VENDOR_SITE_ID,
                       DESTINATION_CONTEXT,
                       ORG_ID,
                       CATALOG_TYPE,
                       CATALOG_SOURCE,
                       REQUESTER_EMAIL,
                       PCARD_FLAG,
                       NEW_SUPPLIER_FLAG,
                       ORDER_TYPE_LOOKUP_CODE,
                       PURCHASE_BASIS,
                       MATCHING_BASIS,
                       NEGOTIATED_BY_PREPARER_FLAG,
                       BASE_UNIT_PRICE,
                       TAX_ATTRIBUTE_UPDATE_CODE,
                       UNSPSC_CODE,
                       'Y'                                 --REQS_IN_POOL_FLAG
                          ,
                       ATTRIBUTE9,
                       ATTRIBUTE10
                  FROM Po_Requisition_Lines_All l
                 WHERE REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID;

            INSERT INTO PO_REQ_DISTRIBUTIONS_ALL (DISTRIBUTION_ID,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY,
                                                  REQUISITION_LINE_ID,
                                                  SET_OF_BOOKS_ID,
                                                  CODE_COMBINATION_ID,
                                                  REQ_LINE_QUANTITY,
                                                  LAST_UPDATE_LOGIN,
                                                  CREATION_DATE,
                                                  CREATED_BY,
                                                  ENCUMBERED_FLAG,
                                                  ACCRUAL_ACCOUNT_ID,
                                                  VARIANCE_ACCOUNT_ID,
                                                  PREVENT_ENCUMBRANCE_FLAG,
                                                  DISTRIBUTION_NUM,
                                                  ALLOCATION_TYPE,
                                                  ALLOCATION_VALUE,
                                                  PROJECT_RELATED_FLAG,
                                                  ORG_ID,
                                                  TAX_RECOVERY_OVERRIDE_FLAG,
                                                  ATTRIBUTE14)
                SELECT PO_REQ_DISTRIBUTIONS_S.NEXTVAL,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       l_req_line_id_s,
                       SET_OF_BOOKS_ID,
                       CODE_COMBINATION_ID,
                       line_rec.quantity - l_po_line_amount,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       ENCUMBERED_FLAG,
                       ACCRUAL_ACCOUNT_ID,
                       VARIANCE_ACCOUNT_ID,
                       PREVENT_ENCUMBRANCE_FLAG,
                       DISTRIBUTION_NUM,
                       ALLOCATION_TYPE,
                       ALLOCATION_VALUE,
                       PROJECT_RELATED_FLAG,
                       ORG_ID,
                       TAX_RECOVERY_OVERRIDE_FLAG,
                       ATTRIBUTE14
                  FROM PO_REQ_DISTRIBUTIONS_ALL
                 WHERE     REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID
                       AND ROWNUM = 1;
        END IF;
    END LOOP;

    COMMIT;
END;
   
/*====================================================================================*/
/* Ошибка при создании PR
Для позиции интегрируемой с Галактикой,
флаг "Доставка в запасы" длжен быть снят
Проверка: */
SELECT segment1, attribute21, DESCRIPTION
  FROM inv.mtl_system_items_b
 WHERE DESCRIPTION LIKE '%Print Conductor%'

/* Исправление */
UPDATE inv.mtl_system_items_b
   SET attribute21 = 'N'
 WHERE segment1 IN ('3400000329')
Find incorect amount in PO
 UPDATE PO.po_headers_all
   SET CREATION_DATE =
           TO_DATE ('31.08.2023 12:13:56', 'dd.mm.yyyy hh24:mi:ss')
 WHERE segment1 IN ('47585')

/* 	Update need by date in  PR*/	
UPDATE Po_Requisition_Lines_All
   SET NEED_BY_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd-mm-yyyy hh24:mi:ss')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND h.segment1 IN ('108683') -- Number PR
				   AND LINE_NUM = 555 -- Line PR
                   ); 
				   
/* 	Update need by date in  PO*/	   
UPDATE APPS.PO_LINE_LOCATIONS_all
   SET NEED_BY_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd-mm-yyyy hh24:mi:ss')
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('43220')); -- Number PO
                        
/* Update date in Receipt*/
UPDATE  PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('31.08.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE PO_HEADER_ID in (SELECT po_header_id
                             FROM PO.po_headers_all
                            WHERE segment1 IN ('54772')); 
                            
 /* Update date in Receipt*/
UPDATE  PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('30.04.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE     SHIPMENT_HEADER_ID IN (SELECT SHIPMENT_HEADER_ID
                                    FROM PO.RCV_SHIPMENT_HEADERS
                                   WHERE RECEIPT_NUM IN ('RECEIPT')) --AND TRANSACTION_TYPE = 'CORRECT'
       AND PO_HEADER_ID = (SELECT po_header_id
                             FROM PO.po_headers_all
                            WHERE segment1 IN ('PO'));

/* Formatted on (QP5 v5.326) Service Desk 424589 Mihail.Vasiljev */
/* Update date in Receipt by PR*/
UPDATE PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('30.04.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE     SHIPMENT_HEADER_ID IN (SELECT SHIPMENT_HEADER_ID
                                    FROM PO.RCV_SHIPMENT_HEADERS
                                   WHERE RECEIPT_NUM IN ('RECEIPT')) --AND TRANSACTION_TYPE = 'CORRECT'
       AND PO_HEADER_ID =
           (SELECT po_header_id
              FROM PO.po_headers_all
             WHERE segment1 IN
                       (SELECT POH.SEGMENT1
                          FROM APPS.PO_HEADERS_ALL              POH,
                               APPS.PO_DISTRIBUTIONS_ALL        PDA,
                               APPS.PO_REQ_DISTRIBUTIONS_ALL    PRDA,
                               APPS.PO_REQUISITION_LINES_ALL    PRLA,
                               APPS.PO_REQUISITION_HEADERS_ALL  PRHA
                         WHERE     POH.PO_HEADER_ID = PDA.PO_HEADER_ID
                               AND PDA.REQ_DISTRIBUTION_ID =
                                   PRDA.DISTRIBUTION_ID
                               AND PRDA.REQUISITION_LINE_ID =
                                   PRLA.REQUISITION_LINE_ID
                               AND PRLA.REQUISITION_HEADER_ID =
                                   PRHA.REQUISITION_HEADER_ID
                               AND PRHA.SEGMENT1 = 'PR'));  					 
						 
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
								 
/*1) Не получается создать Receipt на услугу, ошибка складского подразделения  */
UPDATE PO_REQUISITION_LINES_ALL
SET DESTINATION_CONTEXT = 'EXPENSE'                             --INVENTORY
                                    , DESTINATION_TYPE_CODE = 'EXPENSE' --INVENTORY
--select DESTINATION_CONTEXT, DESTINATION_TYPE_CODE, PRL.* from PO_REQUISITION_LINES_ALL PRL
WHERE     LINE_LOCATION_ID IN
            (SELECT LINE_LOCATION_ID
                FROM PO_LINE_LOCATIONS_ALL
                WHERE po_header_id IN (SELECT po_header_id
                                        FROM po_headers_all
                                        WHERE segment1 IN ( :PO)))
    AND (   DESTINATION_CONTEXT != 'EXPENSE'
        OR DESTINATION_TYPE_CODE != 'EXPENSE');

/*2) Не получается создать Receipt на услугу, ошибка складского подразделения  */
UPDATE po_distributions_all
SET DESTINATION_CONTEXT = 'EXPENSE',                           -- INVENTORY
    Destination_Type_Code = 'EXPENSE',                          --INVENTORY
    ACCRUE_ON_RECEIPT_FLAG = 'N'                                     -- 'Y'
--select PDA.DESTINATION_CONTEXT, PDA.Destination_Type_Code, ACCRUE_ON_RECEIPT_FLAG, PDA.* /*,RLA.* */ from po_distributions_all PDA --, PO_REQUISITION_LINES_ALL RLA
WHERE     po_distribution_id IN
            (SELECT po_distribution_id
                FROM po.po_distributions_all d
                WHERE po_header_id IN (SELECT po_header_id
                                        FROM po_headers_all
                                        WHERE segment1 IN ( :PO)))
    AND (   DESTINATION_CONTEXT != 'EXPENSE'
        OR Destination_Type_Code != 'EXPENSE'
        OR ACCRUE_ON_RECEIPT_FLAG != 'N');

/* Не получается создать Receipt на услугу */
UPDATE APPS.po_distributions_all
   SET DELIVER_TO_LOCATION_ID = '142'
WHERE po_header_id IN (SELECT po_header_id
                          FROM APPS.po_headers_all
                         WHERE segment1 IN ('48464'))

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

/*=======================================================================*/
/* Formatted on  (QP5 v5.326) Service Desk 458163 Mihail.Vasiljev */
/* Изменить номер прихода*/
UPDATE PO.RCV_SHIPMENT_HEADERS rsh
   SET WAYBILL_AIRBILL = '8559225213(1538558572)'
 WHERE rsh.shipment_header_id IN
           (SELECT shipment_header_id
              FROM PO.RCV_TRANSACTIONS rt
             WHERE po_header_id = (SELECT po_header_id
                                     FROM PO.PO_HEADERS_ALL po
                                    WHERE po.segment1 = '42494'))

UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET WAYBILL_AIRBILL = '8559225213(1538558572)'
 WHERE TRANSACTION_ID IN ('43621766',
                          '43621761',
                          '43621756',
                          '43621751')
/* Изменить номер прихода  End */
/*=======================================================================*/

/* Add code_combination_id in po_req_distributions_all*/
UPDATE po.po_req_distributions_all
   SET code_combination_id = 180320
 WHERE     requisition_line_id IN (SELECT requisition_line_id
                                     FROM po.po_requisition_lines_all
                                    WHERE requisition_header_id = 1079934)
       AND code_combination_id = 0	   
-- Old 529740   01.0806.0.0.0.DMN040200.0.740_07_06_00_00_00.0.0.A_2_250_01_04_1.0.0.0.0
-- NEW 540397   01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0
SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0'

/* Formatted (QP5 v5.326) Service Desk 355956 Mihail.Vasiljev */						 
/* Update budget code(ccid) in PR */
UPDATE po.PO_REQ_DISTRIBUTIONS_ALL
   SET CODE_COMBINATION_ID =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQUISITION_LINES_ALL
             WHERE REQUISITION_HEADER_ID IN
                       (SELECT REQUISITION_HEADER_ID
                          FROM po.PO_REQUISITION_HEADERS_ALL
                         WHERE segment1 IN ('93022')))
                         
                         
/* Formatted (QP5 v5.326) Service Desk 355956 Mihail.Vasiljev */
/* Update budget code(ccid) in PO */
UPDATE po.po_distributions_all
   SET code_combination_id =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.0806.0.0.0.DMN040200.0.900_01_01_03_00_00.0.0.A_2_250_01_04_1.0.0.0.0')
 WHERE po_header_id IN (SELECT po_header_id
                          FROM po.po_headers_all
                         WHERE segment1 IN ('36784'))
	   
/* Formatted on 9/2/2021 1:08:38 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
/* Update budget code(ccid) in PO */
UPDATE po.po_distributions_all
   SET code_combination_id =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.2001.0.0.0.DMN040200.0.740_07_07_01_00_00.0.0.PL_740_07.0.0.0.0')
 WHERE po_header_id IN (SELECT po_header_id
                          FROM po.po_headers_all
                         WHERE segment1 IN ('35488'))

/* Formatted on 9/2/2021 1:08:38 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */						 
/* Update budget code(ccid) in PR */
UPDATE po.PO_REQ_DISTRIBUTIONS_ALL
   SET CODE_COMBINATION_ID =
           (SELECT CODE_COMBINATION_ID
              FROM apps.gl_code_combinations_kfv
             WHERE CONCATENATED_SEGMENTS =
                   '01.2001.0.0.0.DMN040200.0.740_07_07_01_00_00.0.0.PL_740_07.0.0.0.0')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQUISITION_LINES_ALL
             WHERE REQUISITION_HEADER_ID IN
                       (SELECT REQUISITION_HEADER_ID
                          FROM po.PO_REQUISITION_HEADERS_ALL
                         WHERE segment1 IN ('89816')))
						 
						 
/* Find all lines in PR by 15 segment account and PR */
SELECT *
  FROM po.PO_REQUISITION_LINES_ALL
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM po.PO_REQ_DISTRIBUTIONS_ALL
             WHERE     REQUISITION_LINE_ID IN
                           (SELECT REQUISITION_LINE_ID
                              FROM po.PO_REQUISITION_LINES_ALL
                             WHERE REQUISITION_HEADER_ID IN
                                       (SELECT REQUISITION_HEADER_ID
                                          FROM po.PO_REQUISITION_HEADERS_ALL
                                         WHERE segment1 IN ('94947')))
                   AND CODE_COMBINATION_ID =
                       (SELECT CODE_COMBINATION_ID
                          FROM apps.gl_code_combinations_kfv
                         WHERE CONCATENATED_SEGMENTS =
                               '01.2001.0.0.0.DSM150001.0.740_18_19_03_13_00.0.0.PL_740_05_01_6.0.0.0.0'))
       
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

 /*Update Service Desk 550383(557922) Mihail.Vasiljev */
UPDATE po.po_distributions_all
   SET RATE = '2.9482'
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('46814'))  

/*Исключение , когда в PO показывает что курс валютаыесть , а в базе нету */
UPDATE PO.po_distributions_all
   SET RATE_DATE = TO_DATE ('04.05.2021', 'dd.mm.yyyy'), RATE = 2.4265
 WHERE PO_DISTRIBUTION_ID = 1127013       
              
/* Find incorect amount in PO by PR with currency rate*/
SELECT prha.segment1
           PR,
       prla.line_num
           PR_LINE_NUM,
       prla.QUANTITY
           AS "PR QUANTITY",
       ROUND(prla.QUANTITY_DELIVERED * NVL (pha.rate, 1),2)
           AS "PR QUANTITY_DELIVERED",
       pha.segment1
           po_no,
       pha.CURRENCY_CODE
           AS "PO Currenccy",
       pha.rate
           AS "PO Rate",
       pda.QUANTITY_ORDERED
           AS "QUANTITY_ORDERED in PO"
  FROM po.po_requisition_headers_all  prha,
       po.po_requisition_lines_all    prla,
       po.po_req_distributions_all    prda,
       po.po_distributions_all        pda,
       po.po_headers_all              pha
 WHERE     prha.requisition_header_id = prla.requisition_header_id
       AND prla.requisition_line_id = prda.requisition_line_id
       AND prda.distribution_id = pda.req_distribution_id(+)
       AND pda.po_header_id = pha.po_header_id(+)
       AND prha.segment1 = 128860                                        -- PR
UNION
SELECT prha.segment1
           PR,
       prla.line_num
           PR_LINE_NUM,
       prla.QUANTITY
           AS "PR QUANTITY",
       ROUND(prla.QUANTITY_DELIVERED * NVL (pha.rate, 1),2)
           AS "PR QUANTITY_DELIVERED",
       pha.segment1
           po_no,
       pha.CURRENCY_CODE
           AS "PO Currenccy",
       pha.rate
           AS "PO Rate",
       pda.QUANTITY_ORDERED
           AS "QUANTITY_ORDERED in PO"
  FROM po.po_requisition_headers_all  prha,
       po.po_requisition_lines_all    prla,
       po.po_req_distributions_all    prda,
       po.po_distributions_all        pda,
       po.po_headers_all              pha
 WHERE     prha.requisition_header_id = prla.requisition_header_id
       AND prla.requisition_line_id = prda.requisition_line_id
       AND prda.distribution_id = pda.req_distribution_id(+)
       AND pda.po_header_id = pha.po_header_id(+)
       AND prha.segment1 = 128860    


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
								 
/* Open PO or not viseble Receipt */
BEGIN
    UPDATE po_headers_all h
       SET h.authorization_status = 'APPROVED'   ,             --l_change_status                              
           h.APPROVED_FLAG = 'Y',
           approved_date = TRUNC (SYSDATE, 'DD'),
           closed_code = 'OPEN'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));

    UPDATE po_lines_all l
       SET CLOSED_CODE = 'OPEN',
           CLM_INFO_FLAG = 'N',
           clm_option_indicator = 'B'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));


    UPDATE PO_LINE_LOCATIONS_all
       SET APPROVED_FLAG = 'Y',
           CLOSED_CODE = 'OPEN',
           approved_date = SYSDATE,
           ENCUMBERED_FLAG = 'Y'
     WHERE po_HEADER_ID = (SELECT po_header_id
                                  FROM APPS.po_headers_all
                                 WHERE segment1 IN ('37266'));

    COMMIT;
END;								 


 /*Find all PR and PO by user*/
SELECT DISTINCT
       prh.segment1
           req_num,
       poh.segment1
           "PO NUMMBER",
       POH.closed_code,
       POH.CREATION_DATE
           CREATION_DATE_PO,                         --fnd.user_name requestor
       POH.TERMS_ID,
       POH.CREATED_BY,
       papf.FULL_NAME
           AS "Buyer in PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = POH.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = prh.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PR",
       eit.INVOICE_TYPE_DETAIL
           AS "CONTRACT IN PO",
       TT.NAME
           "TERMS NAME IN PO",
       TT.DESCRIPTION
           "TERMS DESCRIPTION IN PO",
       POH.COMMENTS
           "COMMENTS IN PO",
       POH.CREATION_DATE
           "CREATION DATE IN PO",
       POH.AUTHORIZATION_STATUS
           "STATUS  IN PO"
  FROM APPS.po_line_locations_all       ploc,
       APPS.po_lines_all                pol,
       APPS.po_headers_all              poh,
       APPS.po_requisition_lines_all    prl,
       APPS.po_requisition_headers_all  prh,
       APPS.AP_TERMS_TL                 TT,
       APPS.xxtg_ef_invoice_type        eit,
       po.po_agents                     pa,
       hr.per_all_people_f              papf
 WHERE     poh.po_header_id = pol.po_header_id(+)
       AND pol.po_line_id = ploc.po_line_id(+)
       AND ploc.line_location_id = prl.line_location_id(+)
       AND prl.requisition_header_id = prh.requisition_header_id(+)
       AND (poh.TERMS_ID = TT.TERM_ID(+) AND TT.SOURCE_LANG = 'US')
       AND eit.INVOICE_TYPE_ID(+) = poh.ATTRIBUTE1
       AND POH.AGENT_ID = pa.agent_id
       AND pa.agent_id = papf.person_id
       --   AND prh.preparer_id = fnd.employee_id(+)
       AND (   POH.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                                  'dd.mm.yyyy HH24:MI:ss')
                                     AND TO_DATE ('28.01.2021 23:59:59',
                                                  'dd.mm.yyyy HH24:MI:ss')
            OR prh.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                                  'dd.mm.yyyy HH24:MI:ss')
                                     AND TO_DATE ('28.01.2021 23:59:59',
                                                  'dd.mm.yyyy HH24:MI:ss'))
       AND (   prh.CREATED_BY =
               (SELECT user_id
                  FROM APPS.fnd_user
                 WHERE EMPLOYEE_ID IN
                           (SELECT PERSON_ID
                              FROM APPS.per_all_people_f
                             WHERE FULL_NAME LIKE '%Роксолана%'))
            OR POH.AGENT_ID =
               (SELECT papf2.person_id
                  FROM hr.per_all_people_f papf2
                 WHERE papf2.FULL_NAME LIKE '%Роксолана%'))
       AND POH.closed_code = 'OPEN'  
							            

/* Проблема согласования PO "Не найден утверждающий для документа"  
1) Проверка карточки сотрудника 
2) Проверка иерархии
3) Проверка Supervisor-ov запросом*/
SELECT *
  FROM APPS.wf_users
 WHERE     1 = 1
       AND --AND orig_system = 'PER'
           --AND status = 'ACTIVE'
           DESCRIPTION IN
               ('Томуть, Евгения Александровна',
                'Церкасевич, Татьяна Витальевна',
                'Бородач, Марина Александровна')

/* Все PO  за 2018 с условиями оплаты */
SELECT DISTINCT  PHA.SEGMENT1 "PO NUMMBER",
       PHA.COMMENTS,
       PHA.CREATION_DATE,
       PHA.AUTHORIZATION_STATUS,
       TT.NAME        "TERMS NAME",
       TT.DESCRIPTION "TERMS DESCRIPTION"
  FROM APPS.po_headers_all PHA, APPS.AP_TERMS_TL TT
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND TT.SOURCE_LANG = 'US'
       --AND segment1 IN ('30203')
       AND PHA.CREATION_DATE >= to_date('01.01.2018', 'dd.mm.yyyy')
       ORDER BY PHA.SEGMENT1
	   

/* Open PO for Cancel*/
DECLARE
    l_search_status   VARCHAR2 (30) := 'INCOMPLETE';
    l_change_status   VARCHAR2 (30) := 'APPROVED';
BEGIN
    FOR hrec
        IN (SELECT po_HEADER_ID, segment1, APPROVED_FLAG
              FROM po_headers_all
             WHERE     APPROVED_FLAG = 'Y'
                   AND segment1 = '32040'
                   AND closed_code = 'CLOSED'--                        and trunc(last_update_date) = to_date('28122018', 'ddmmyyyy')
                                             )
    LOOP
        --        DBMS_OUTPUT.put_line ( 'Change status for order #: ' || hrec.segment1);

        UPDATE po_headers_all h
           SET h.authorization_status = 'APPROVED'           --l_change_status
                                                  ,
               h.APPROVED_FLAG = 'Y',
               approved_date = SYSDATE,
               closed_code = 'OPEN'
         --      , AUTHORIZATION_STATUS = 'INCOMPLETE'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;

        UPDATE po_lines_all l
           SET CLOSED_CODE = 'OPEN',
               CLM_INFO_FLAG = 'N',
               clm_option_indicator = 'B'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;


        UPDATE PO_LINE_LOCATIONS_all
           SET APPROVED_FLAG = 'Y',
               CLOSED_CODE = 'OPEN',
               approved_date = SYSDATE,
               ENCUMBERED_FLAG = 'Y'
         WHERE po_HEADER_ID = hrec.po_HEADER_ID;

        DELETE FROM PO_ACTION_HISTORY
              WHERE OBJECT_ID = hrec.po_HEADER_ID AND ACTION_CODE = 'CLOSE';
    END LOOP;

    COMMIT;
END;

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

								 
/* */

 -- line 2 of 84374
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '760_02_2_3_02_01')
where requisition_line_id = 969154;

 -- line 1 of 84374
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '760_02_2_3_01_01')
where requisition_line_id = 969842;

-- line 1 of 84385
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '740_15_05_00_00_00')
where requisition_line_id = 969869; 

-- line 2 of 84385
update Po_Requisition_Lines_All
set Attribute9 = (select flex_value_id from XXTG_PR_BUDGET_ITEM_V where flex_value = '740_15_03_00_00_00')
where requisition_line_id = 969872; 

update Po_Requisition_Lines_All     
set NEED_BY_DATE = to_date('31-01-2021 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
where REQUISITION_LINE_ID in (select REQUISITION_LINE_ID 
    FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
    WHERE l.Requisition_Header_Id = h.Requisition_Header_Id
       AND h.segment1 in ('84390', '84395 ', '84374'));
       


declare
   L_Cc_Segment1       VARCHAR2 (25 BYTE) := '01';
   L_Cc_Segment2       VARCHAR2 (25 BYTE) := '0001';
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
   
   l_DESTINATION_TYPE_CODE VARCHAR2 (25 BYTE);   

   l_nat_acc VARCHAR2 (25 BYTE);
   l_ifrs_acc VARCHAR2 (25 BYTE);
   

  BEGIN
  
    FOR rec_line IN (
                            SELECT DISTINCT h.segment1 as req_num,
                                            l.line_num,
                                            l.requisition_line_id,
                                            reqd.distribution_id,
                                            pod.po_distribution_id,
                                            fv.flex_value budget_code,
                                            NVL(l.Attribute10, h.Attribute10) department_code,
                                            l.NEED_BY_DATE,
                                            l.quantity,
                                            l.item_id,
                                            reqd.Set_Of_Books_Id,
                                            gcc.Segment1,
                                            gcc.Segment2,
                                            gcc.Segment3,
                                            gcc.Segment4,
                                            gcc.Segment5,
                                            gcc.Segment6,
                                            gcc.Segment7,
                                            gcc.Segment8,
                                            gcc.Segment9,
                                            gcc.Segment10,
                                            gcc.Segment11,
                                            gcc.Segment12,
                                            gcc.Segment13,
                                            gcc.Segment14,
                                            gcc.Segment15,
                                            l.DESTINATION_TYPE_CODE,
                                            reqd.CODE_COMBINATION_ID
                              FROM po_distributions_all pod,
                                   PO_REQ_DISTRIBUTIONS_ALL reqd,
                                   Po_Requisition_Lines_All l,
                                   Po_Requisition_Headers_All h,
                                   gl_code_combinations gcc,
                                   fnd_flex_values fv
                             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                                   AND reqd.requisition_line_id = l.requisition_line_id
                                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                                   AND gcc.code_combination_id = reqd.CODE_COMBINATION_ID
                                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                                   AND fv.flex_Value_id = NVL (l.Attribute9, h.Attribute9)
                                   AND h.segment1 IN ('84390', '84395 ', '84374','84385')                             
                            )
    LOOP
        
        L_Cc_Id := rec_line.CODE_COMBINATION_ID;

       L_Cc_Segment1 := rec_line.Segment1;
       L_Cc_Segment2 := rec_line.Segment2    ;
       L_Cc_Segment3 := rec_line.Segment3      ;
       L_Cc_Segment4 := rec_line.Segment4      ;
       L_Cc_Segment5 := rec_line.Segment5      ;
       L_Cc_Segment6 := rec_line.Segment6     ;
       L_Cc_Segment7 := rec_line.Segment7    ;
       L_Cc_Segment8 := rec_line.Segment8  ;
       L_Cc_Segment9 := rec_line.Segment9     ;
       L_Cc_Segment10 := rec_line.Segment10   ;
       L_Cc_Segment11 := rec_line.Segment11    ;
       L_Cc_Segment12 := rec_line.Segment12    ;
       L_Cc_Segment13 := rec_line.Segment13    ;
       L_Cc_Segment14 := rec_line.Segment14  ;
       L_Cc_Segment15 := rec_line.Segment15   ;        
       

        DBMS_OUTPUT.put_line ('Original ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
        
        L_Cc_Segment8 :=  rec_line.budget_code;
    
        if rec_line.DESTINATION_TYPE_CODE = 'EXPENSE' and L_Cc_Segment2 = '0001' then

                  SELECT nvl(cat.ATTRIBUTE1, L_Cc_Segment2), nvl(cat.ATTRIBUTE3, L_Cc_Segment11)
                    INTO l_nat_acc, l_ifrs_acc
                    FROM Mtl_Item_Categories ic, Mtl_Categories_b cat
                   WHERE inventory_item_id = rec_line.item_id
                            and organization_id = 83
                         AND Category_Set_Id = 1100000041
                         AND cat.category_id = ic.category_id; 

                     L_Cc_Segment2 := l_nat_acc;
                     L_Cc_Segment11 := l_ifrs_acc;

       end if;              


        SELECT Chart_Of_Accounts_Id
        INTO L_Coa_Id
        FROM Gl_Sets_Of_Books
        WHERE Set_Of_Books_Id = rec_line.Set_Of_Books_Id;
    
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
                
        DBMS_OUTPUT.put_line ('Updated ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);

         UPDATE po.po_req_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE distribution_id = rec_line.distribution_id;           
         
        if (rec_line.po_distribution_id is not null) then

            UPDATE po.po_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE po_distribution_id = rec_line.po_distribution_id;              

        end if;


    END LOOP;
    
--commit;    

  END return_pr_lines;
  
  /* Перенос сумм бюджета с мая на июнь */
--by line number

DECLARE
    l_req_num        VARCHAR2 (40) := '97864';                    -- PR number
    l_req_line_num   NUMBER := &Rln;                                -- PR line
    l_amount         NUMBER := &amount;
BEGIN
    UPDATE Po_Requisition_Lines_All                     --PO_LINES_ARCHIVE_ALL
       SET quantity = l_amount
     -- select quantity from Po_Requisition_Lines_All
     WHERE REQUISITION_LINE_ID IN
               (SELECT REQUISITION_LINE_ID
                  FROM Po_Requisition_Lines_All    l,
                       Po_Requisition_Headers_All  h
                 WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                       AND h.segment1 IN (l_req_num)
                       AND LINE_NUM = l_req_line_num);

    UPDATE Po_Req_distributions_All d
       SET REQ_LINE_QUANTITY =
               (SELECT quantity
                  FROM Po_Requisition_Lines_All l1
                 WHERE l1.REQUISITION_LINE_ID = d.REQUISITION_LINE_ID)
     WHERE REQUISITION_LINE_ID IN
               (SELECT REQUISITION_LINE_ID
                  FROM Po_Requisition_Lines_All    l,
                       Po_Requisition_Headers_All  h
                 WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                       AND h.segment1 IN (l_req_num)
                       AND LINE_NUM = l_req_line_num);

    UPDATE Po_distributions_All d
       SET QUANTITY_ORDERED =
               (SELECT REQ_LINE_QUANTITY
                  FROM Po_Req_distributions_All d1
                 WHERE d1.DISTRIBUTION_ID = d.req_DISTRIBUTION_ID)
     WHERE req_DISTRIBUTION_ID IN
               (SELECT DISTRIBUTION_ID
                  FROM Po_Req_distributions_All d
                 WHERE REQUISITION_LINE_ID IN
                           (SELECT REQUISITION_LINE_ID
                              FROM Po_Requisition_Lines_All    l,
                                   Po_Requisition_Headers_All  h
                             WHERE     l.Requisition_Header_Id =
                                       h.Requisition_Header_Id
                                   AND h.segment1 IN (l_req_num)
                                   AND LINE_NUM = l_req_line_num));

    UPDATE Po_lines_All l
       SET quantity =
               (SELECT QUANTITY_ORDERED
                  FROM Po_distributions_All d1
                 WHERE d1.po_line_id = l.po_line_id)
     WHERE po_line_id IN
               (SELECT po_line_id
                  FROM Po_distributions_All
                 WHERE req_DISTRIBUTION_ID IN
                           (SELECT DISTRIBUTION_ID
                              FROM Po_Req_distributions_All d
                             WHERE REQUISITION_LINE_ID IN
                                       (SELECT REQUISITION_LINE_ID
                                          FROM Po_Requisition_Lines_All    l,
                                               Po_Requisition_Headers_All  h
                                         WHERE     l.Requisition_Header_Id =
                                                   h.Requisition_Header_Id
                                               AND h.segment1 IN (l_req_num)
                                               AND LINE_NUM = l_req_line_num)));
											   
UPDATE PO_LINE_LOCATIONS_ALL
   SET QUANTITY = l_amount
WHERE PO_LINE_ID  IN
               (SELECT po_line_id
                  FROM Po_distributions_All
                 WHERE req_DISTRIBUTION_ID IN
                           (SELECT DISTRIBUTION_ID
                              FROM Po_Req_distributions_All d
                             WHERE REQUISITION_LINE_ID IN
                                       (SELECT REQUISITION_LINE_ID
                                          FROM Po_Requisition_Lines_All    l,
                                               Po_Requisition_Headers_All  h
                                         WHERE     l.Requisition_Header_Id =
                                                   h.Requisition_Header_Id
                                               AND h.segment1 IN (:l_req_num)
                                               AND LINE_NUM = :l_req_line_num)));

    COMMIT;
END;



/* Прошу сделать выборку всех открытых РО, с указанием:
1. Контрагента,
2. Уникального номера контрагента,
3. Номера контракта,
4. Контрагента,
5. Даты создания контрагента,
6. Условия оплаты.*/
SELECT DISTINCT                                                            --*
                PHA.SEGMENT1       "PO NUMMBER",
                sup.VENDOR_NAME,
                SUP.VAT_REGISTRATION_NUM,
                eit.INVOICE_TYPE_DETAIL,
                SUP.START_DATE_ACTIVE,
                SUP.END_DATE_ACTIVE,
                TT.NAME            "TERMS NAME",
                TT.DESCRIPTION     "TERMS DESCRIPTION",
                PHA.COMMENTS,
                PHA.CREATION_DATE,
                PHA.AUTHORIZATION_STATUS
 FROM APPS.po_headers_all  PHA,
       APPS.AP_TERMS_TL     TT,
       ap.ap_suppliers      sup,
       xxtg_ef_invoice_type  eit
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND SUP.VENDOR_ID = PHA.VENDOR_ID
       AND eit.VENDOR_ID(+) = PHA.VENDOR_ID
       AND eit.INVOICE_TYPE_ID(+) = PHA.ATTRIBUTE1
       AND TT.SOURCE_LANG = 'US'
--       AND APPROVED_FLAG = 'Y'
       AND closed_code = 'OPEN'
       --       AND PHA.SEGMENT1 IN ('32264')
       AND PHA.CREATION_DATE BETWEEN TO_DATE ('01.01.2021', 'dd.mm.yyyy')
                                 AND SYSDATE;
--       ORDER BY PHA.SEGMENT1


/* Прошу сделать выборку всех открытых РО, с указанием:
1. Контрагента,
2. Уникального номера контрагента,
3. Номера контракта,
4. Контрагента,
5. Даты создания контрагента,
6. Условия оплаты.*/
SELECT DISTINCT                                                            
       PHA.SEGMENT1
           "PO NUMMBER",
       PHA.TERMS_ID,
       PHA.CREATED_BY,
       (SELECT DISTINCT USER_NAME
          FROM APPS.fnd_user fu
         WHERE fu.USER_ID = PHA.CREATED_BY)
           AS "CREATOR PO",
       eit.INVOICE_TYPE_DETAIL
           AS "CONTRACT IN PO",
       TT.NAME
           "TERMS NAME IN PO",
       TT.DESCRIPTION
           "TERMS DESCRIPTION IN PO",
       (SELECT DISTINCT ATT.NAME
          FROM XXTG.XXTG_EF_INVOICE_TYPE XEIT, APPS.AP_TERMS_TL ATT
         WHERE     1 = 1
               AND XEIT.INVOICE_TYPE_DETAIL = eit.INVOICE_TYPE_DETAIL
               AND XEIT.VENDOR_ID = PHA.VENDOR_ID
               AND XEIT.PAYMENT_TERM(+) = ATT.TERM_ID
               AND ATT.SOURCE_LANG = 'US')
           AS "TERMS NAME IN eFirm",
       sup.VENDOR_NAME
           AS "VENDOR NAME IN eFirm",
       SUP.VAT_REGISTRATION_NUM
           AS "VRN(УНП) IN eFirm",
       SUP.START_DATE_ACTIVE
           AS "START DATE IN eFirm",
       SUP.END_DATE_ACTIVE
           AS "END DATE IN eFirm",
       PHA.COMMENTS
           "COMMENTS IN PO",
       PHA.CREATION_DATE
           "CREATION DATE IN PO",
       PHA.AUTHORIZATION_STATUS
           "STATUS  IN PO"
  FROM APPS.po_headers_all        PHA,
       APPS.AP_TERMS_TL           TT,
       ap.ap_suppliers            sup,
       APPS.xxtg_ef_invoice_type  eit
 WHERE     PHA.TERMS_ID = TT.TERM_ID
       AND SUP.VENDOR_ID = PHA.VENDOR_ID
       AND eit.VENDOR_ID(+) = PHA.VENDOR_ID
       AND eit.INVOICE_TYPE_ID(+) = PHA.ATTRIBUTE1
       AND TT.SOURCE_LANG = 'US'
       AND APPROVED_FLAG = 'Y'
       AND closed_code = 'OPEN'
       --                AND PHA.SEGMENT1 IN ('35720')
       AND PHA.CREATION_DATE BETWEEN TO_DATE ('01.01.2021', 'dd.mm.yyyy')
                                 AND SYSDATE
								 
								 
/*================================*/
SELECT apss.VENDOR_SITE_ID, aps.VENDOR_ID,
       aps.VENDOR_NAME
           AS "Наименование",
       aps.VENDOR_NAME_ALT
           AS "Альтернативное наименование",
       aps.VAT_REGISTRATION_NUM
           AS "УНП",
       NVL2 (TO_CHAR (aps.END_DATE_ACTIVE), 'No', 'Active')
           AS "Статус",
    aps.VENDOR_TYPE_LOOKUP_CODE
           AS "Тип Фирмы",
       MSI.SECONDARY_INVENTORY_NAME
           AS "Код дилера",
           MSI.ORGANIZATION_ID,
       CASE MSI.ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организаци ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           ELSE 'Слад не привязан'
       END
           AS "Наименованеи_склада"
  FROM ap.ap_suppliers                aps,
       ap.ap_supplier_sites_all       apss,
       APPS.ar_customers              ars,
       inv.MTL_SECONDARY_INVENTORIES  MSI
 WHERE     aps.vendor_id = apss.vendor_id
       AND ars.CUSTOMER_NAME(+) = aps.VENDOR_NAME
       --AND ars.TAX_REFERENCE = aps.VAT_REGISTRATION_NUM
	   --aps.VAT_REGISTRATION_NUM = 'УНП'
       AND ars.CUSTOMER_ID = MSI.ATTRIBUTE5(+)
       AND VENDOR_NAME like '%ООО ЭЛИТ%'   --- 104409  
	   
/* Update vendor in PO */
UPDATE PO.PO_HEADERS_ALL po
   SET po.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                       'Минский городской центр недвижимости УП'),
       po.vendor_site_id =
           (SELECT apss.VENDOR_SITE_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                       'Минский городской центр недвижимости УП')
 WHERE po.segment1 = '50722';
                    

/* Update vendor in Receipt transactions */
UPDATE PO.RCV_TRANSACTIONS rt
   SET rt.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                           'Минский городской центр недвижимости УП'),
       rt.vendor_site_id =
           (SELECT apss.VENDOR_SITE_ID
              FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
             WHERE     aps.vendor_id = apss.vendor_id
                   AND VENDOR_NAME =
                           'Минский городской центр недвижимости УП')
 WHERE     po_header_id = (SELECT po_header_id
                             FROM PO.PO_HEADERS_ALL po
                            WHERE po.segment1 = '50722')
       AND shipment_header_id in
           (SELECT rsh.shipment_header_id
              FROM PO.RCV_SHIPMENT_HEADERS rsh
             WHERE     rsh.shipment_header_id IN
                           (SELECT shipment_header_id
                              FROM PO.RCV_TRANSACTIONS rt
                             WHERE po_header_id in
                                   (SELECT po_header_id
                                      FROM PO.PO_HEADERS_ALL po
                                     WHERE po.segment1 = '50722'))
                   AND RECEIPT_NUM in ('67640'));

/* Update vendor in Receipt Header */
UPDATE PO.RCV_SHIPMENT_HEADERS rsh
   SET rsh.vendor_id =
           (SELECT aps.VENDOR_ID
              FROM ap.ap_suppliers aps
             WHERE  VENDOR_NAME =
                           'Минский городской центр недвижимости УП')
 WHERE     rsh.shipment_header_id IN
               (SELECT shipment_header_id
                  FROM PO.RCV_TRANSACTIONS rt
                 WHERE po_header_id in (SELECT po_header_id
                                         FROM PO.PO_HEADERS_ALL po
                                        WHERE po.segment1 = '50722'))
       AND RECEIPT_NUM in ('67640');


/* №PO, 
   Покупатель (сотрудник отдела закупок),
   сумма PO,
   описание PO,
   поставщик,
   контракт и СРОК ОПЛАТЫ ДЛЯ PO */
  SELECT --PO_ST.PO_HEADER_ID           "Ид Заказа на приобретение",
         PO_ST.PO_NUMBER
             "Номер Заказа на приобретение",
         SUM (PO_ST.PO_AMOUNT)
             OVER (
                 PARTITION BY PO_ST.PO_NUMBER,
                              PO_ST.PO_VENDOR_NAME,
                              PO_ST.PO_CREATION_DATE)
             "Общая сумма Заказа",
         PO_ST.PO_VENDOR_NAME
             "Поставщик",
         PO_ST.PO_DESCRIPTION
             "Описание Заказа",
         PO_ST.PO_CONTRAT_NO
             "Номер контракта",
         TO_CHAR (PO_ST.PO_CREATION_DATE, 'DD.MM.RRRR')
             "Дата создания Заказа",
         PO_ST.PO_BUYER
             "Закупщик",
         PO_ST.PO_LINE_NUM
             "Номер строки Заказа",
         PO_ST.PO_CANCEL_FLAG
             "Статус отменены",
         PO_ST.PO_TERM_NAME
             "Условие оплаты Заказа",
         TO_CHAR (PO_ST.PO_NEED_BY_DATE, 'DD.MM.RRRR')
             "Ожидаемая дата поставки",
         TO_CHAR (PO_ST.DUE_DATE, 'DD.MM.RRRR')
             "Дата платежа",
         PO_ST.PO_AMOUNT
             "Сумма по строке Заказа",
         PO_ST.PO_CURRENCY_CODE
             "Валюта Заказа",
         PO_ST.BUDGET_CODE
             "Код бюджета",
         PO_ST.DEPARTMENT_CODE
             "Код департамента",
         PO_ST.CASH_FLOW_BUDGET_TYPE
             "Тип бюджета"
    FROM (SELECT POH.PO_HEADER_ID
                     PAYMENT_DOC_ID,
                 ------------------------------------------------------------------------------
                 'PO'
                     SOURCE,
                 POH.CURRENCY_CODE
                     CURRENCY_CODE,
                   NVL (POL.UNIT_PRICE, 0)
                 * (  PLL.QUANTITY
                    - NVL (PLL.QUANTITY_RECEIVED, 0)
                    + NVL (PLL.QUANTITY_CANCELLED, 0))
                 * (ATL.DUE_PERCENT / 100)
                     AMOUNT_PLAN_ON_DATE,
                 AP_CREATE_PAY_SCHEDS_PKG.CALC_DUE_DATE (
                     P_TERMS_DATE         => PLL.NEED_BY_DATE,
                     P_TERMS_ID           => ATL.TERM_ID,
                     P_CALENDAR           => ATL.CALENDAR,
                     P_SEQUENCE_NUM       => ATL.SEQUENCE_NUM,
                     P_CALLING_SEQUENCE   => ATL.SEQUENCE_NUM)
                     DUE_DATE,
                 CC.SEGMENT8
                     BUDGET_CODE,
                 DEP.DESCRIPTION
                     DEPARTMENT_CODE,
                 (SELECT FBI.BUDGET_ITEM_TYPE
                    FROM APPS.XXTG_CASH_FLOW_BUDGET_ITEM_V FBI
                   WHERE FBI.BUDGET_CODE = CC.SEGMENT8 AND ROWNUM = 1)
                     CASH_FLOW_BUDGET_TYPE,
                 ---------------------------------------------------------------------
                 POH.PO_HEADER_ID
                     PO_HEADER_ID,
                 TO_CHAR (POH.SEGMENT1)
                     PO_NUMBER,
                 PLL.NEED_BY_DATE
                     PO_NEED_BY_DATE,
                 NVL ((POL.QUANTITY * POL.UNIT_PRICE), 0)
                     PO_AMOUNT,
                 NVL ((POL.QUANTITY * POL.UNIT_PRICE), 0)
                     PO_SUM_AMOUNT,
                 POH.CURRENCY_CODE
                     PO_CURRENCY_CODE,
                 VEN.VENDOR_NAME
                     PO_VENDOR_NAME,
                 POH.COMMENTS
                     PO_DESCRIPTION,
                 IVC.CONTRAT_NO
                     PO_CONTRAT_NO,
                 ATR.NAME
                     PO_TERM_NAME,
                 (SELECT PLE.FULL_NAME
                    FROM APPS.PER_PEOPLE_F PLE
                   WHERE     POH.AGENT_ID = PLE.PERSON_ID
                         AND TRUNC (SYSDATE) BETWEEN PLE.EFFECTIVE_START_DATE
                                                 AND PLE.EFFECTIVE_END_DATE)
                     PO_BUYER,
                 POH.CREATION_DATE
                     PO_CREATION_DATE,
                 NVL (POL.CANCEL_FLAG, 'N')
                     PO_CANCEL_FLAG,
                 POL.LINE_NUM
                     PO_LINE_NUM
            FROM PO.PO_HEADERS_ALL           POH,
                 PO.PO_LINES_ALL             POL,
                 PO.PO_DISTRIBUTIONS_ALL     POD,
                 PO.PO_LINE_LOCATIONS_ALL    PLL,
                 APPS.AP_TERMS_VL            ATR,
                 AP_TERMS_LINES              ATL,
                 GL.GL_CODE_COMBINATIONS     CC,
                 APPS.XXTG_DEPARTMENT_V      DEP,
                 APPS.PO_VENDORS             VEN,
                 APPS.XXTG_INVOICE_CONTRACT_V IVC,
                 DUAL
           WHERE     1 = 1
                 --AND POH.PO_HEADER_ID in (240193)
                 --AND PO_ST.PO_CREATION_DATE BETWEEN TO_DATE('01.01.2021','DD.MM.RRRR') AND TO_DATE('30.04.2023','DD.MM.RRRR')
                 AND PLL.NEED_BY_DATE BETWEEN TO_DATE ('01.01.2021',
                                                       'DD.MM.RRRR')
                                          AND TO_DATE ('01.01.2021',
                                                       'DD.MM.RRRR')
                 AND POH.TYPE_LOOKUP_CODE = 'STANDARD'
                 AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
                 --AND NVL(POL.CANCEL_FLAG, 'N') = 'N'
                 --AND NVL(POL.CLOSED_CODE, 'OPEN') not in ('CLOSED','FINALLY CLOSED')
                 AND POL.PO_LINE_ID = POD.PO_LINE_ID
                 AND POD.PO_LINE_ID = PLL.PO_LINE_ID
                 AND POD.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID
                 AND POH.TERMS_ID = ATR.TERM_ID
                 AND ATR.TERM_ID = ATL.TERM_ID
                 AND POD.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
                 AND CC.SEGMENT6 = DEP.DEPARTMENT_CODE
                 AND POH.VENDOR_ID = VEN.VENDOR_ID
                 --AND VEN.VENDOR_NAME <> 'Dummy Supplier'
                 --AND PLL.QUANTITY - NVL(PLL.QUANTITY_RECEIVED,0) + nvl(PLL.QUANTITY_CANCELLED,0) = PLL.QUANTITY
                 AND POH.ATTRIBUTE1 = TO_CHAR (IVC.CONTRACT_ID(+))) PO_ST
ORDER BY                                                 --PO_ST.PO_HEADER_ID,
         PO_ST.PO_NUMBER, PO_ST.PO_LINE_NUM, PO_ST.PO_NEED_BY_DATE;
		 
		 
/* Find Buyer and creator in PO */
SELECT POH.segment1 "PO",
       POH.closed_code "Status PO",
       FULL_NAME
           AS "Buyer in PO",
       (SELECT FULL_NAME
          FROM APPS.per_all_people_f PAPF
         WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                       FROM APPS.fnd_user fu
                                      WHERE fu.user_id = POH.CREATED_BY)
               AND ROWNUM = 1)
           AS "CREATOR PO"
  FROM APPS.po_headers_all POH, po.po_agents pa, hr.per_all_people_f papf
 WHERE     POH.AGENT_ID = pa.agent_id
       AND pa.agent_id = papf.person_id
       AND FULL_NAME LIKE '%Роксолана%'
       AND POH.CREATION_DATE BETWEEN TO_DATE ('01.01.2021 00:00:00',
                                              'dd.mm.yyyy HH24:MI:ss')
                                 AND TO_DATE ('28.01.2021 23:59:59',
                                              'dd.mm.yyyy HH24:MI:ss')
       AND POH.closed_code = 'OPEN'

--=============================================================================
/* Formatted on (QP5 v5.326) Service Desk 562059 Mihail.Vasiljev */
/*Прошу изменить HIZ*/
UPDATE  Po_Requisition_Lines_All
   SET item_id =
           (SELECT DISTINCT INVENTORY_ITEM_ID
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012'),
         ITEM_DESCRIPTION = (SELECT DISTINCT DESCRIPTION
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012')
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
              FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND h.segment1 IN ('104856'));
     
UPDATE po_lines_all
   SET item_id =
           (SELECT DISTINCT INVENTORY_ITEM_ID
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012'),
         ITEM_DESCRIPTION = (SELECT DISTINCT DESCRIPTION
              FROM inv.mtl_system_items_b a
             WHERE SEGMENT1 = 'HIZ000012')
 WHERE po_line_ID IN
           (SELECT pod.po_line_ID
              FROM po_distributions_all        pod,
                   PO_REQ_DISTRIBUTIONS_ALL    reqd,
                   Po_Requisition_Lines_All    l,
                   Po_Requisition_Headers_All  h
             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND reqd.requisition_line_id = l.requisition_line_id
                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                   AND h.segment1 IN ('104856'));
				   
--=============================================================================
      
declare
   L_Cc_Segment1       VARCHAR2 (25 BYTE) := '01';
   L_Cc_Segment2       VARCHAR2 (25 BYTE) := '0001';
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
  
   l_DESTINATION_TYPE_CODE VARCHAR2 (25 BYTE);  
   l_nat_acc VARCHAR2 (25 BYTE);
   l_ifrs_acc VARCHAR2 (25 BYTE);
  
  BEGIN
 
    FOR rec_line IN (
                            SELECT DISTINCT h.segment1 as req_num,
                                            l.line_num,
                                            l.requisition_line_id,
                                            reqd.distribution_id,
                                            pod.po_distribution_id,
                                            fv.flex_value budget_code,
                                            NVL(l.Attribute10, h.Attribute10) department_code,
                                            l.NEED_BY_DATE,
                                            l.quantity,
                                            l.item_id,
                                            reqd.Set_Of_Books_Id,
                                            gcc.Segment1,
                                            gcc.Segment2,
                                            gcc.Segment3,
                                            gcc.Segment4,
                                            gcc.Segment5,
                                            gcc.Segment6,
                                            gcc.Segment7,
                                            gcc.Segment8,
                                            gcc.Segment9,
                                            gcc.Segment10,
                                            gcc.Segment11,
                                            gcc.Segment12,
                                            gcc.Segment13,
                                            gcc.Segment14,
                                            gcc.Segment15,
                                            l.DESTINATION_TYPE_CODE,
                                            reqd.CODE_COMBINATION_ID
                              FROM po_distributions_all pod,
                                   PO_REQ_DISTRIBUTIONS_ALL reqd,
                                   Po_Requisition_Lines_All l,
                                   Po_Requisition_Headers_All h,
                                   gl_code_combinations gcc,
                                   fnd_flex_values fv
                             WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                                   AND reqd.requisition_line_id = l.requisition_line_id
                                   AND Pod.req_distribution_id(+) = reqd.distribution_id
                                   AND gcc.code_combination_id = reqd.CODE_COMBINATION_ID
                                   AND H.TYPE_LOOKUP_CODE != 'INTERNAL'
                                   AND fv.flex_Value_id = NVL (l.Attribute9, h.Attribute9)
                                   AND h.segment1 IN ('95888','95982')                            
                            )
    LOOP
       
        L_Cc_Id := rec_line.CODE_COMBINATION_ID;
       L_Cc_Segment1 := rec_line.Segment1;
       L_Cc_Segment2 := rec_line.Segment2    ;
       L_Cc_Segment3 := rec_line.Segment3      ;
       L_Cc_Segment4 := rec_line.Segment4      ;
       L_Cc_Segment5 := rec_line.Segment5      ;
       L_Cc_Segment6 := rec_line.Segment6     ;
       L_Cc_Segment7 := rec_line.Segment7    ;
       L_Cc_Segment8 := rec_line.Segment8  ;
       L_Cc_Segment9 := rec_line.Segment9     ;
       L_Cc_Segment10 := rec_line.Segment10   ;
       L_Cc_Segment11 := rec_line.Segment11    ;
       L_Cc_Segment12 := rec_line.Segment12    ;
       L_Cc_Segment13 := rec_line.Segment13    ;
       L_Cc_Segment14 := rec_line.Segment14  ;
       L_Cc_Segment15 := rec_line.Segment15   ;       
      
        DBMS_OUTPUT.put_line ('Original ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
       
        L_Cc_Segment8 :=  rec_line.budget_code;
   
        if rec_line.DESTINATION_TYPE_CODE = 'EXPENSE'  then
                  SELECT nvl(cat.ATTRIBUTE1, L_Cc_Segment2), nvl(cat.ATTRIBUTE3, L_Cc_Segment11)
                    INTO l_nat_acc, l_ifrs_acc
                    FROM Mtl_Item_Categories ic, Mtl_Categories_b cat
                   WHERE inventory_item_id = rec_line.item_id
                            and organization_id = 83
                         AND Category_Set_Id = 1100000041
                         AND cat.category_id = ic.category_id;
                     L_Cc_Segment2 := l_nat_acc;
                     L_Cc_Segment11 := l_ifrs_acc;
       end if;             

        SELECT Chart_Of_Accounts_Id
        INTO L_Coa_Id
        FROM Gl_Sets_Of_Books
        WHERE Set_Of_Books_Id = rec_line.Set_Of_Books_Id;
   
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
               
        DBMS_OUTPUT.put_line ('Updated ' || rec_line.req_num || '-' || rec_line.line_num || ': ' || L_Cc_Segment1 || '.' ||L_Cc_Segment2 || '.' ||L_Cc_Segment3 || '.' ||L_Cc_Segment4 || '.' ||L_Cc_Segment5 || '.' ||L_Cc_Segment6 || '.' ||L_Cc_Segment7 || '.' ||L_Cc_Segment8 || '.' ||L_Cc_Segment9 || '.' ||L_Cc_Segment10 || '.' ||L_Cc_Segment11 || '.' ||L_Cc_Segment12 || '.' ||L_Cc_Segment13 || '.' ||L_Cc_Segment14 || '.' ||L_Cc_Segment15 || ', CCID = ' || L_Cc_Id);
         UPDATE po.po_req_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE distribution_id = rec_line.distribution_id;          
        
        if (rec_line.po_distribution_id is not null) then
            UPDATE po.po_distributions_all
               SET code_combination_id = L_Cc_Id
             WHERE po_distribution_id = rec_line.po_distribution_id;             
        end if;

    END LOOP;
   
commit;   
  END ;      

/* Formatted on (QP5 v5.388) Service Desk 647730 Исправление суммы в PR Mihail.Vasiljev */
UPDATE po_line_locations_all
   SET QUANTITY = :QUANTITY
 WHERE PO_LINE_ID = :PO_LINE_ID

/* Formatted on (QP5 v5.388) Service Desk 647730 Исправление суммы в PR Mihail.Vasiljev */
SELECT QUANTITY,
       (SELECT PLA2.QUANTITY
         FROM PO_LINES_ALL PLA2
        WHERE     PLA2.po_header_id = PLLA.po_header_id
              AND PLA2.PO_LINE_ID = PLLA.PO_LINE_ID)
  FROM po_line_locations_all PLLA
 WHERE     PLLA.po_header_id IN (SELECT PHA1.po_header_id
                                   FROM PO.po_headers_all PHA1
                                  WHERE PHA1.segment1 IN ('46378'))
       AND PLLA.PO_LINE_ID IN
               (SELECT PLA1.PO_LINE_ID
                 FROM PO_LINES_ALL PLA1
                WHERE     po_header_id IN (SELECT PHA2.po_header_id
                                             FROM PO.po_headers_all PHA2
                                            WHERE PHA2.segment1 IN ('46378'))
                      AND PLA1.LINE_NUM IN (12,
                                            24,
                                            36,
                                            48,
                                            60,
                                            72,
                                            84,
                                            96,
                                            108,
                                            120,
                                            132,
                                            144))

/* Formatted  (QP5 v5.388) Service Desk 653181 Mihail.Vasiljev */
/* Close PO for Receiving in iProcurment1 */
UPDATE po_lines_all 
   SET CLOSED_CODE = 'CLOSED'
 WHERE PO_HEADER_ID IN
           (SELECT poh.po_header_id
             FROM po_headers_all poh
            WHERE     --NVL (poh.closed_code, 'OPEN') = 'OPEN' AND
                   poh.segment1 IN ('24739'))
   AND CLOSED_CODE != 'CLOSED';
   
   
/* Formatted  (QP5 v5.388) Service Desk 653181 Mihail.Vasiljev */
/* Close PO for Receiving in iProcurment2 */
  UPDATE PO_LINE_LOCATIONS_ALL
      SET CLOSED_CODE = 'CLOSED'
 WHERE PO_HEADER_ID IN
           (SELECT poh.po_header_id
              FROM po_headers_all poh
            WHERE     --NVL (poh.closed_code, 'OPEN') = 'OPEN' AND
                   poh.segment1 IN ('24739'))
   AND CLOSED_CODE != 'CLOSED';

/*================== Split line PR by PO Service Desk  Mihail.Vasiljev ======================*/
DECLARE
    l_po_line_amount   NUMBER;
    l_req_line_id_s    NUMBER;
BEGIN
    FOR line_rec
        IN (SELECT DISTINCT rl.requisition_line_id, rl.QUANTITY
             FROM po_distributions_all      pod,
                  PO_REQ_DISTRIBUTIONS_ALL  reqd,
                  Po_Requisition_Lines_All  rl
            WHERE     po_header_id = (SELECT po_header_id
                                        FROM po_headers_all
                                       WHERE segment1 = '51854')
                  AND reqd.distribution_id = pod.req_distribution_id
                  AND rl.requisition_line_id = reqd.requisition_line_id)
    LOOP
        SELECT SUM (quantity * poh.rate)     po_sum_amount
          INTO l_po_line_amount
          FROM po_headers_all poh, po_lines_all pol, po_distributions_all pod
         WHERE     pod.req_distribution_id IN
                       (SELECT distribution_id
                         FROM PO_REQ_DISTRIBUTIONS_ALL
                        WHERE requisition_line_id =
                              line_rec.REQUISITION_LINE_ID)
               AND pol.po_line_id = pod.po_line_id
               AND poh.po_header_id = pod.po_header_id
               AND NVL (pol.cancel_flag, 'N') != 'Y';

        IF (line_rec.quantity > l_po_line_amount)
        THEN
            UPDATE Po_Requisition_Lines_All
               SET QUANTITY = ROUND (l_po_line_amount, 2)
             WHERE REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID;

            SELECT PO_REQUISITION_LINES_S.NEXTVAL
              INTO l_req_line_id_s
              FROM DUAL;

            INSERT INTO PO_REQUISITION_LINES_ALL (
                            REQUISITION_LINE_ID,
                            REQUISITION_HEADER_ID,
                            LINE_NUM,
                            LINE_TYPE_ID,
                            CATEGORY_ID,
                            ITEM_DESCRIPTION,
                            UNIT_MEAS_LOOKUP_CODE,
                            UNIT_PRICE,
                            QUANTITY,
                            DELIVER_TO_LOCATION_ID,
                            TO_PERSON_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            SOURCE_TYPE_CODE,
                            LAST_UPDATE_LOGIN,
                            CREATION_DATE,
                            CREATED_BY,
                            ITEM_ID,
                            SUGGESTED_BUYER_ID,
                            ENCUMBERED_FLAG,
                            RFQ_REQUIRED_FLAG,
                            NEED_BY_DATE,
                            LINE_LOCATION_ID,
                            DOCUMENT_TYPE_CODE,
                            BLANKET_PO_HEADER_ID,
                            BLANKET_PO_LINE_NUM,
                            CURRENCY_CODE,
                            RATE_TYPE,
                            RATE_DATE,
                            RATE,
                            CURRENCY_UNIT_PRICE,
                            SUGGESTED_VENDOR_NAME,
                            SUGGESTED_VENDOR_LOCATION,
                            URGENT_FLAG,
                            DESTINATION_TYPE_CODE,
                            DESTINATION_ORGANIZATION_ID,
                            VENDOR_ID,
                            VENDOR_SITE_ID,
                            DESTINATION_CONTEXT,
                            ORG_ID,
                            CATALOG_TYPE,
                            CATALOG_SOURCE,
                            REQUESTER_EMAIL,
                            PCARD_FLAG,
                            NEW_SUPPLIER_FLAG,
                            ORDER_TYPE_LOOKUP_CODE,
                            PURCHASE_BASIS,
                            MATCHING_BASIS,
                            NEGOTIATED_BY_PREPARER_FLAG,
                            BASE_UNIT_PRICE,
                            TAX_ATTRIBUTE_UPDATE_CODE,
                            UNSPSC_CODE,
                            REQS_IN_POOL_FLAG,
                            ATTRIBUTE9,
                            ATTRIBUTE10)
                SELECT l_req_line_id_s                 /*requisition_line_id*/
                                      ,
                       requisition_header_id         /*requisition_header_id*/
                                            ,
                       l_req_line_id_s                            /*line_num*/
                                      ,
                       line_type_id                           /*line_type_id*/
                                   ,
                       CATEGORY_ID                             /*category_id*/
                                  ,
                       item_description --replace(item_description, ' ' || to_char(l_line_NEED_BY_DATE, 'MM-YYYY'), '')  || ' ' || to_char(ADD_MONTHS(l_line_NEED_BY_DATE, l_counter), 'MM-YYYY')               /*item_description*/
                                       ,
                       unit_meas_lookup_code         /*unit_meas_lookup_code*/
                                            ,
                       UNIT_PRICE,
                       line_rec.quantity - l_po_line_amount,
                       DELIVER_TO_LOCATION_ID,
                       TO_PERSON_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       SOURCE_TYPE_CODE,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       ITEM_ID,
                       SUGGESTED_BUYER_ID,
                       ENCUMBERED_FLAG,
                       RFQ_REQUIRED_FLAG,
                       NEED_BY_DATE,
                       NULL,
                       DOCUMENT_TYPE_CODE,
                       BLANKET_PO_HEADER_ID,
                       BLANKET_PO_LINE_NUM,
                       CURRENCY_CODE,
                       RATE_TYPE,
                       RATE_DATE,
                       RATE,
                       CURRENCY_UNIT_PRICE,
                       SUGGESTED_VENDOR_NAME,
                       SUGGESTED_VENDOR_LOCATION,
                       URGENT_FLAG,
                       DESTINATION_TYPE_CODE,
                       DESTINATION_ORGANIZATION_ID,
                       VENDOR_ID,
                       VENDOR_SITE_ID,
                       DESTINATION_CONTEXT,
                       ORG_ID,
                       CATALOG_TYPE,
                       CATALOG_SOURCE,
                       REQUESTER_EMAIL,
                       PCARD_FLAG,
                       NEW_SUPPLIER_FLAG,
                       ORDER_TYPE_LOOKUP_CODE,
                       PURCHASE_BASIS,
                       MATCHING_BASIS,
                       NEGOTIATED_BY_PREPARER_FLAG,
                       BASE_UNIT_PRICE,
                       TAX_ATTRIBUTE_UPDATE_CODE,
                       UNSPSC_CODE,
                       'Y'                                 --REQS_IN_POOL_FLAG
                          ,
                       ATTRIBUTE9,
                       ATTRIBUTE10
                  FROM Po_Requisition_Lines_All l
                 WHERE REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID;

            INSERT INTO PO_REQ_DISTRIBUTIONS_ALL (DISTRIBUTION_ID,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY,
                                                  REQUISITION_LINE_ID,
                                                  SET_OF_BOOKS_ID,
                                                  CODE_COMBINATION_ID,
                                                  REQ_LINE_QUANTITY,
                                                  LAST_UPDATE_LOGIN,
                                                  CREATION_DATE,
                                                  CREATED_BY,
                                                  ENCUMBERED_FLAG,
                                                  ACCRUAL_ACCOUNT_ID,
                                                  VARIANCE_ACCOUNT_ID,
                                                  PREVENT_ENCUMBRANCE_FLAG,
                                                  DISTRIBUTION_NUM,
                                                  ALLOCATION_TYPE,
                                                  ALLOCATION_VALUE,
                                                  PROJECT_RELATED_FLAG,
                                                  ORG_ID,
                                                  TAX_RECOVERY_OVERRIDE_FLAG,
                                                  ATTRIBUTE14)
                SELECT PO_REQ_DISTRIBUTIONS_S.NEXTVAL,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       l_req_line_id_s,
                       SET_OF_BOOKS_ID,
                       CODE_COMBINATION_ID,
                       line_rec.quantity - l_po_line_amount,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       CREATED_BY,
                       ENCUMBERED_FLAG,
                       ACCRUAL_ACCOUNT_ID,
                       VARIANCE_ACCOUNT_ID,
                       PREVENT_ENCUMBRANCE_FLAG,
                       DISTRIBUTION_NUM,
                       ALLOCATION_TYPE,
                       ALLOCATION_VALUE,
                       PROJECT_RELATED_FLAG,
                       ORG_ID,
                       TAX_RECOVERY_OVERRIDE_FLAG,
                       ATTRIBUTE14
                  FROM PO_REQ_DISTRIBUTIONS_ALL
                 WHERE     REQUISITION_LINE_ID = line_rec.REQUISITION_LINE_ID
                       AND ROWNUM = 1;
        END IF;
    END LOOP;

    COMMIT;
END;
   
/*====================================================================================*/

/* PR-PO-USER-Terms-Investment_PRJ  */
SELECT PORH.segment1       requisition_num,
       porh.DESCRIPTION,
       prj.description     AS project,
       porh.ATTRIBUTE8     AS vat_rate_code,
       FU.USER_NAME,
       POH.segment1        po_num,
       CON.PARTY_NAME,
       CONTRAT_NO,
       INVOICE_TYPE_NAME,
       INVESTMENT_AGREEMENTS
  FROM PO_HEADERS_ALL              POH,
       PO_LINES_ALL                POL,
       PO_DISTRIBUTIONS_ALL        POD,
       PO_LINE_LOCATIONS_ALL       PLL,
       PO_REQUISITION_LINES_ALL    PORL,
       PO_REQ_DISTRIBUTIONS_ALL    PORD,
       PO_REQUISITION_HEADERS_ALL  PORH,
       XXTG_INVOICE_CONTRACT_V     CON,
       FND_USER                    FU,
       XXTG_PROJECT_V              PRJ
 WHERE     1 = 1
       AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
       AND POH.AUTHORIZATION_STATUS NOT IN
               ('CANCELLED', 'REJECTED', 'RETURNED')
       AND NVL (POL.CANCEL_FLAG, 'N') = 'N'
       AND POL.PO_LINE_ID = POD.PO_LINE_ID
       AND POH.PO_HEADER_ID = PLL.PO_HEADER_ID
       AND POL.PO_LINE_ID = PLL.PO_LINE_ID
       AND POD.line_location_id = pll.line_location_id
       AND PORD.DISTRIBUTION_ID = POD.REQ_DISTRIBUTION_ID
       AND PORL.requisition_line_id = PORD.requisition_line_id
       AND PORL.requisition_header_id = PORH.requisition_header_id
       AND TRUNC (PORL.need_by_date, 'MM') = TRUNC (PLL.need_by_date, 'MM')
       AND CON.CONTRACT_ID =
           TO_NUMBER (REGEXP_REPLACE (POH.attribute1, '[^0-9]', ''))
       AND CON.INVESTMENT_AGREEMENTS IS NOT NULL
       AND FU.user_id = PORH.created_by
       AND PRJ.flex_value(+) = porh.ATTRIBUTE12
       AND PORH.CREATION_DATE >= TRUNC (SYSDATE, 'YEAR') - 31



/* Cancel PR*/
UPDATE Po_Requisition_Lines_All
   SET QUANTITY_DELIVERED = NULL,
       LINE_LOCATION_ID = NULL,
       SUGGESTED_VENDOR_NAME = 'ТрайдексБелПлюс ООО РБ',
       SUGGESTED_VENDOR_LOCATION = 'OFFICE',
       VENDOR_ID = '859360',
       VENDOR_SITE_ID = '18482',
       REQUEST_ID = NULL,
       PROGRAM_APPLICATION_ID = NULL,
       PROGRAM_ID = NULL,
       PROGRAM_UPDATE_DATE = NULL,
       REQS_IN_POOL_FLAG = 'Y'
 WHERE REQUISITION_LINE_ID IN
           (SELECT REQUISITION_LINE_ID
             FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
            WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                  AND h.segment1 IN ('132376')                    -- Number PR
                  AND LINE_NUM IN (18)                              -- Line PR
                                      );              
                                              
                                 
/* Cancel PO Loaction Lines */
UPDATE APPS.PO_LINE_LOCATIONS_all
   SET QUANTITY_CANCELLED = 1,
       CLOSED_DATE = TRUNC (SYSDATE, 'DD'),
       CANCEL_FLAG = 'Y',
       CLOSED_CODE = 'CLOSED',
       ACCRUE_ON_RECEIPT_FLAG = 'N'
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM APPS.po_headers_all
                         WHERE segment1 IN ('53495'))
                                                       
                
/* Cancel PO  Lines */
UPDATE po_lines_all
   SET QUANTITY = -1,
       CANCEL_FLAG = 'Y',
       NEGOTIATED_BY_PREPARER_FLAG = 'Y',
       CLOSED_CODE = 'CLOSED',
       CLOSED_DATE = TRUNC (SYSDATE, 'DD'),
       CLOSED_REASON = 'SD 717276'
 WHERE po_HEADER_ID IN (SELECT po_header_id
                          FROM APPS.po_headers_all
                         WHERE segment1 IN ('53495'))
                                 
                                 
/* Cancel PO  Headers */
UPDATE po_headers_all h
   SET h.authorization_status = 'REJECTED',                  --l_change_status
       h.APPROVED_FLAG = 'Y',
       approved_date = TRUNC (SYSDATE, 'DD'),
       closed_code = 'CLOSE'
 WHERE po_HEADER_ID = (SELECT po_header_id
                         FROM APPS.po_headers_all
                        WHERE segment1 IN ('53495'));
