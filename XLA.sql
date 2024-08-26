/* Resend transactions on Acc recalculation by WSH_DELIVERY_NAME  */
UPDATE xla_events
   SET event_status_code = 'U', process_status_code = 'I'
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE     entity_code = 'MTL_ACCOUNTING_EVENTS'
                  AND SOURCE_ID_INT_1 IN
                          (SELECT DISTINCT *
                            FROM (SELECT TRANSACTION_ID -- Block find TR by Move Order
                                    FROM mtl_material_transactions
                                   WHERE -- INVENTORY_ITEM_ID IN (SELECT DISTINCT INVENTORY_ITEM_ID
                                         --                                   FROM inv.mtl_system_items_b a
                                         --                                  WHERE a.SEGMENT1 IN ('1051100972')) -- Item
                                         --       AND
                                          TRANSACTION_SOURCE_ID IN
                                             (SELECT DISTINCT TXN_SOURCE_ID
                                               FROM MTL_TXN_REQUEST_LINES
                                                    MTRL
                                              WHERE LINE_ID IN
                                                        (SELECT MOVE_ORDER_LINE_ID
                                                          FROM WSH_DELIVERY_DETAILS
                                                         WHERE --SOURCE_HEADER_NUMBER = '318318'
                                                               DELIVERY_DETAIL_ID IN
                                                                   (SELECT DISTINCT
                                                                           TDA.DELIVERY_DETAIL_ID
                                                                     FROM WSH.WSH_DELIVERY_ASSIGNMENTS
                                                                          TDA,
                                                                          WSH.WSH_NEW_DELIVERIES
                                                                          TND
                                                                    WHERE     TND.name IN
                                                                                  ('МЛ 0302064')   --Deliver Name TTN
                                                                          AND TDA.DELIVERY_ID =
                                                                              TND.DELIVERY_ID)))
                                  UNION ALL
                                  SELECT TRANSACTION_ID --Block find TR by Internal Req
                                    FROM mtl_material_transactions
                                   WHERE --  INVENTORY_ITEM_ID IN
                                         --           (SELECT DISTINCT INVENTORY_ITEM_ID
                                         --             FROM inv.mtl_system_items_b a
                                         --            WHERE     a.SEGMENT1 IN ('1051100972')  -- Item
                                         --                  AND
                                          TRANSACTION_SOURCE_ID IN
                                             (SELECT SOURCE_DOCUMENT_ID -- IR 1585784 TRANSACTION_SOURCE_ID
                                               FROM oe_order_headers_all oh
                                              WHERE --ORDER_NUMBER = '318318'  --  Internal.ORDER ENTRY
                                                    oh.HEADER_ID IN
                                                        (SELECT SOURCE_HEADER_ID
                                                          FROM WSH_DELIVERY_DETAILS
                                                         WHERE --SOURCE_HEADER_NUMBER = '318318'
                                                               DELIVERY_DETAIL_ID IN
                                                                   (SELECT DISTINCT
                                                                           TDA.DELIVERY_DETAIL_ID
                                                                     FROM WSH.WSH_DELIVERY_ASSIGNMENTS
                                                                          TDA,
                                                                          WSH.WSH_NEW_DELIVERIES
                                                                          TND
                                                                    WHERE     TND.name IN
                                                                                  ('МЛ 0302064')   --Deliver Name TTN
                                                                          AND TDA.DELIVERY_ID =
                                                                              TND.DELIVERY_ID))))));
                                                                              
/* send transactions on recalculation */
UPDATE xla_events
   SET event_status_code = 'U', process_status_code = 'I'
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
              FROM xla.xla_transaction_entities
             WHERE     entity_code = 'MTL_ACCOUNTING_EVENTS'
                   AND SOURCE_ID_INT_1 IN
                           (SELECT transaction_id
                              FROM mtl_material_transactions
                             WHERE transaction_set_id = '46646138')   --736721
                                                                   );

/* Send to recalculation Acc in DG by AP invoice*/
UPDATE xla_events
   SET event_status_code = 'U', process_status_code = 'I'
 WHERE ENTITY_ID IN
           ((SELECT ENTITY_ID
                                FROM xla.xla_transaction_entities
                               WHERE     TRANSACTION_NUMBER =
                                         'ШШ 3838264' -- Invoice Number
                                     AND SOURCE_ID_INT_1 = '1280186' -- Invoice ID
                                                                    ));    

/* XLA NOT EXISTS IN DG*/
SELECT *
  FROM XXTG_GL001_DOUBLE_GLOBAL g
 WHERE     NOT EXISTS
               (SELECT 1
                  FROM xla_ae_headers h
                 WHERE ae_header_id = g.d_ae_header_id)
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.05.2024', 'dd.mm.yyyy')
                                 AND TO_DATE ('31.05.2024', 'dd.mm.yyyy')
--       AND (D_SEGMENT2 = '9011' OR c_SEGMENT2 = '9011')
             AND D_APPL_ID != 101


/* GL Journals NOT EXISTS IN DG*/
SELECT *
  FROM XXTG_GL001_DOUBLE_GLOBAL dg1
 WHERE     1 = 1
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.05.2024', 'dd.mm.yyyy')
                                 AND TO_DATE ('31.05.2024', 'dd.mm.yyyy')
       AND D_APPL_ID = 101
       AND NOT EXISTS
               (SELECT je_header_id
                  FROM gl_je_headers
                 WHERE PERIOD_NAME = 'MAY-24' AND je_header_id = d_doc_id);
                                                                               

/* The Following Events Are Present In The Line Extract But MISSING In The Header Extract  */
SELECT xe.application_id,
       xte.entity_code        "Transaction Type",
       xte.source_id_int_1    "Transaction Id",
       xte.transaction_number "Transaction Number",
       xe.event_id,
       xet.event_class_code,
       xe.event_type_code,
       xe.event_status_code,
       xe.process_status_Code,
       xe.budgetary_control_flag,
       xte.transaction_number
  FROM xla_events xe, xla_transaction_entities_upg xte, xla_event_types_b xet
 WHERE     1 = 1                       --xte.application_id = P_APPLICATION_ID
       AND xte.entity_id = xe.entity_id
       AND xet.application_id = xe.application_id
       AND xet.event_type_code = xe.event_type_code
       --       AND xe.application_id = P_APPLICATION_ID
       --       AND xe.request_id = P_CREATE_ACCT_REQUEST_ID
       --       AND xte.transaction_number IN ('20093093')
       AND xe.event_id = 12470524


/* Duplicate XLA Headers by material transaction on period*/
  SELECT COUNT (a.ae_header_id)
             AS "Count_XLA_Head",
         a.ENTITY_ID,
         te.transaction_number,
         CASE mmt.ORGANIZATION_ID
             WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
             WHEN 83 THEN 'BBW: Склад Бест'
             WHEN 84 THEN 'BDW: Дилеры'
             WHEN 85 THEN 'BHW: Головной офис Бест'
             WHEN 86 THEN 'BSW: Подрядчики'
             WHEN 1369 THEN 'BFC: Строительство ОС'
             ELSE 'Other organization'
         END
             AS "Наименованеи_организации",
         MTY.TRANSACTION_TYPE_NAME
    FROM xla.xla_ae_headers a
         LEFT JOIN xla.xla_transaction_entities te
             ON te.ENTITY_ID = a.entity_id
         LEFT JOIN mtl_material_transactions mmt
             ON MMT.transaction_id = te.transaction_number
         LEFT JOIN inv.MTL_TRANSACTION_TYPES MTY
             ON MTY.TRANSACTION_TYPE_ID = mmt.TRANSACTION_TYPE_ID
   WHERE a.entity_id IN
             (SELECT ENTITY_ID
               FROM xla.xla_transaction_entities
              WHERE transaction_number IN
                        (SELECT TO_CHAR (transaction_id)
                          FROM inv.mtl_material_transactions mt
                         WHERE TRANSACTION_DATE BETWEEN TO_DATE ('01.01.2024',
                                                                 'dd.mm.yyyy')
                                                    AND TO_DATE ('31.01.2024',
                                                                 'dd.mm.yyyy')))
GROUP BY a.ENTITY_ID,
         te.transaction_number,
         mmt.ORGANIZATION_ID,
         MTY.TRANSACTION_TYPE_NAME
  HAVING COUNT (a.ae_header_id) > 1


/**xla accounting lines inventory*/
SELECT te.SOURCE_ID_INT_1 transaction_id,  ae_line_num, ccid.segment2, ael.accounted_dr dr, accounted_cr cr
  FROM xla.xla_transaction_entities te,
       xla.xla_ae_headers aeh,
       xla.xla_ae_lines ael,
       gl_code_combinations ccid
       ,  mtl_material_transactions trx --поменять на таблицу из модуля 
       , mtl_system_items_b msi
WHERE     te.entity_code = 'MTL_ACCOUNTING_EVENTS' --подстввить код для события модуля 
       AND te.application_id = 707 --application_id
       --and te.transaction_date = mmt.transaction_date
       AND aeh.entity_id = te.entity_id
       AND aeh.accounting_entry_status_code = 'I' -- проверка статуса I - ошибочные 
       AND ael.ae_header_id = aeh.ae_header_id
       AND ccid.code_combination_id = ael.code_combination_id
       AND trx.transaction_id = te.SOURCE_ID_INT_1 --связка с id таблицы-источника модуля
       AND msi.inventory_item_id = trx.inventory_item_id
       AND msi.organization_id = 82
       and ( ael.accounted_dr !=0 or ael.accounted_cr !=0 )
      AND te.SOURCE_ID_INT_1 IN --связка с id таблицы-источника модуля
             (SELECT transaction_id
                  FROM mtl_material_transactions mmt
                  , mtl_transaction_types mtt
                 WHERE 1=1 
--                 and mmt.TRANSACTION_ACTION_ID = 1
                 and transaction_date between  to_date('01012018', 'ddmmyyyy') and to_date('30112018', 'ddmmyyyy')
                 and mtt.transaction_type_name in ('XXTG RETURN from ItemInUsg OLD')
                 and mmt.transaction_type_id = mtt.transaction_type_id
                 and mtt.ATTRIBUTE14 is null
  --               and transaction_id in (33023483)
              )
--        AND not exists (select 1  from XXTG_GL001_DOUBLE_GLOBAL where C_ENTITY_CODE = 'MTL_ACCOUNTING_EVENTS' and C_DOC_ID  = te.SOURCE_ID_INT_1)
        and (accounted_cr >0 or accounted_dr >0)
order by ae_line_num    


/* Find all XLA by AP invoice*/ 
UPDATE xla.xla_events EV
   SET EVENT_STATUS_CODE = 'P', PROCESS_STATUS_CODE = 'P'
WHERE EV.entity_id IN (  SELECT DISTINCT XE.ENTITY_ID
    FROM APPS.AP_INVOICES_ALL        AI,
         APPS.XLA_EVENTS             XE,
         XLA.XLA_TRANSACTION_ENTITIES XTE
   WHERE     XTE.APPLICATION_ID = 200
         AND XE.APPLICATION_ID = 200
         AND AI.INVOICE_ID IN
                 (SELECT invoice_id
                    FROM APPS.ap_invoices_all
                   WHERE INVOICE_NUM IN
                             ('11/18-N 28-09/15-09а ОТ 28.09.15д',
                              '10/18-N 28-09/15-09а ОТ 28.09.15д',
                              '09/18-N 28-09/15-09а ОТ 28.09.15д',
                              '08/18-N 28-09/15-09а ОТ 28.09.15д'))
         AND XTE.LEDGER_ID = AI.SET_OF_BOOKS_ID
         AND XTE.ENTITY_CODE = 'AP_INVOICES'
         AND NVL (XTE.SOURCE_ID_INT_1, -99) = AI.INVOICE_ID
         AND XTE.ENTITY_ID = XE.ENTITY_ID
		 
		
/* All XLA info by tr_set_id */
  SELECT xah.creation_date,
         gcc.segment2                       AS acc,
         xal.code_combination_id,
         xte.transaction_number,
         xah.attribute10,
         xdl.ae_header_id                   AS AID,
         xah.accounting_date,
         xah.period_name,
         xah.gl_transfer_status_code,
         xah.accounting_entry_status_code,
         xdl.ae_line_num                    AS N,
         xdl.source_distribution_type,
         xdl.accounting_line_code,
         xdl.accounting_line_type_code      AS altc,
         xdl.line_definition_code,
         xdl.event_class_code,
         xdl.event_type_code,
         xdl.rounding_class_code,
         xala.analytical_criterion_code     AS sr,
         xala.ac1,
         xala.ac2,
         xala.ac3,
         xala.ac4,
         xala.ac5,
         xdl.unrounded_entered_dr           AS ued,
         xdl.unrounded_entered_cr           AS uec,
         xdl.unrounded_accounted_dr         AS uad,
         xdl.unrounded_accounted_cr         AS uac,
         XAL.LEDGER_ID,
         xte.creation_Date,
         xala.*
    FROM xla.XLA_DISTRIBUTION_LINKS  xdl,
         xla.xla_transaction_entities xte,
         xla.xla_ae_headers          xah,
         xla.xla_ae_lines            xal,
         gl.gl_code_combinations     gcc,
         xla.xla_ae_line_acs         xala
   WHERE     1 = 1
         AND xte.entity_id = xah.entity_id
         AND xah.ae_header_id = xdl.ae_header_id
         AND xal.ae_header_id = xah.ae_header_id
         AND xal.ae_line_num = xdl.ae_line_num
         AND gcc.code_combination_id = xal.code_combination_id
         AND xal.ae_header_id = xala.ae_header_id(+)
         AND xal.ae_line_num = xala.ae_line_num(+)
         --and beetwin to_date('06.03.2017')
         --and xah.ae_header_id  in (302682136)
         --and xah.je_category_name = 'Inventory'
         --and ACCOUNTING_ENTRY_STATUS_CODE = 'I'
         AND xah.LEDGER_ID = 2047
         --and gcc.segment2 = '0003'
         --and (xdl.unrounded_entered_dr > 0 or xdl.unrounded_entered_cr > 0)
         AND xte.transaction_number IN
                 (SELECT TO_CHAR (transaction_id)
                    FROM inv.mtl_material_transactions mt
                   WHERE transaction_SET_id IN (38849241))
ORDER BY AID, xdl.ae_header_id, UEC                         -- xdl.ae_line_num 

--In this post, we will check the Data related to the   
--Payable INVOICE ( Invoice_id = 166014 ) in Sub-Ledger Accounting (XLA). 
--All the queries given in this post and their related posts were tested in R12.1.1 Instance.

--XLA_EVENTS

SELECT DISTINCT xe.*
FROM   ap_invoices_all ai,
       xla_events xe,
       xla.xla_transaction_entities xte
WHERE  xte.application_id = 200
AND    xte.application_id   = xe.application_id
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id
AND    xte.entity_id        = xe.entity_id
ORDER BY
       xe.entity_id,
       xe.event_number;


--XLA_AE_HEADERS 

SELECT DISTINCT xeh.*
FROM   xla_ae_headers xeh,
       ap_invoices_all ai,
       xla.xla_transaction_entities xte
WHERE  xte.application_id = 200
AND    xte.application_id   = xeh.application_id
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id
AND    xte.entity_id        = xeh.entity_id
ORDER BY
       xeh.event_id,
       xeh.ae_header_id ASC; 

--XLA_AE_LINES

SELECT DISTINCT xel.*,
       fnd_flex_ext.get_segs('SQLGL','GL#', '50577' , xel.code_combination_id) "Account"
FROM   xla_ae_lines xel,
       xla_ae_headers xeh,
       ap_invoices_all ai,
       xla.xla_transaction_entities xte
WHERE  xte.application_id = 200
AND    xel.application_id   = xeh.application_id
AND    xte.application_id   = xeh.application_id
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xel.ae_header_id     = xeh.ae_header_id
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id
AND    xte.entity_id        = xeh.entity_id
ORDER BY
       xel.ae_header_id,
       xel.ae_line_num ASC;


--XLA_DISTRIBUTION_LINKS

SELECT DISTINCT xdl.*
FROM   xla_distribution_links xdl,
       xla_ae_headers xeh,
       ap_invoices_all ai,
       xla.xla_transaction_entities xte
WHERE  xte.application_id = 200
AND    xdl.application_id   = xeh.application_id
AND    xte.application_id   = xeh.application_id
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xdl.ae_header_id     = xeh.ae_header_id
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id
AND    xte.entity_id        = xeh.entity_id
ORDER BY
       xdl.event_id,
       xdl.a_header_id,
       xdl.ae_line_num ASC;

--XLA_TRANSACTION_ENTITIES 

SELECT DISTINCT xte.*
FROM   ap_invoices_all ai,
       xla.xla_transaction_entities xte
WHERE  xte.application_id = 200
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id;


--XLA_ACCOUNTING_ERRORS

SELECT DISTINCT xae.*
FROM   ap_invoices_all ai,
       xla_events xe,
       xla.xla_transaction_entities xte,
       xla_accounting_errors xae
WHERE  xte.application_id = 200
AND    xae.application_id   = xte.application_id
AND    xte.application_id   = xe.application_id
AND    ai.invoice_id        = '166014'
--                  (SELECT invoice_id
--                    FROM APPS.ap_invoices_all
--                   WHERE INVOICE_NUM IN ('BST13634')) 
AND    xe.event_id          = xae.event_id
AND    xte.entity_code      = 'AP_INVOICES'
AND    xte.source_id_int_1  = ai.invoice_id
AND    xte.entity_id        = xe.entity_id;


update xla_ae_line_acs 
set ac1 = 'ТПО_ЦО_84'
where AE_HEADER_ID in (select AE_HEADER_ID from xla_ae_headers xh
where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code='MTL_ACCOUNTING_EVENTS'
    and SOURCE_ID_INT_1 
    in (select transaction_id
        from mtl_material_transactions
        where INVENTORY_ITEM_ID = 412695 and TRANSACTION_TYPE_ID in (100, 664) and SUBINVENTORY_CODE = 'ТПО'
        and transaction_date > trunc(sysdate, 'MM'))
    )) and ac1 = 'ТПО_84'; 


/* Change date in xla_ae_lines*/
UPDATE xla.xla_ae_lines
   SET ACCOUNTING_DATE = TO_DATE ('23052023', 'ddmmyyyy')
 WHERE ae_header_id IN
           (SELECT ae_header_id
             FROM xla.xla_ae_headers a
            WHERE     1 = 1
                  AND entity_id IN
                          (SELECT ENTITY_ID
                            FROM xla.xla_transaction_entities
                           WHERE transaction_number IN
                                     (SELECT TO_CHAR (transaction_id)
                                       FROM inv.mtl_material_transactions mt
                                      WHERE transaction_set_id IN (49477450,
                                                                   49477374,
                                                                   49477362,
                                                                   49477461,
                                                                   49560697))))



/* Change date in xla_ae_headers */
UPDATE xla_ae_headers a
   SET ACCOUNTING_DATE = TO_DATE ('23052023', 'ddmmyyyy'),
--       GL_TRANSFER_STATUS_CODE = 'N',
--       GL_TRANSFER_DATE = NULL,
       PERIOD_NAME = 'MAY-23'
 WHERE entity_id IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE transaction_number IN
                      (SELECT TO_CHAR (transaction_id)
                         FROM inv.mtl_material_transactions mt
                        WHERE transaction_set_id IN (49477450,
                                                     49477374,
                                                     49477362,
                                                     49477461,
                                                     49560697)));

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      -- Service Desk 678948
/* Change date in xla_events */
UPDATE xla.xla_events a
   SET event_date = TO_DATE ('23052023', 'ddmmyyyy'),
       reference_date_1 = TO_DATE ('23052023', 'ddmmyyyy'),
       transaction_date = TO_DATE ('23052023', 'ddmmyyyy')
 WHERE entity_id IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE transaction_number IN
                      (SELECT TO_CHAR (transaction_id)
                         FROM inv.mtl_material_transactions mt
                        WHERE transaction_set_id IN (49477450,
                                                     49477374,
                                                     49477362,
                                                     49477461,
                                                     49560697)));

-- XLA AP Invoice in xla_ae_lines
SELECT a.*  
  FROM xla.xla_ae_lines a
 WHERE     1 = 1
       AND ae_header_id IN
               (SELECT ae_header_id
                 FROM xla.xla_ae_headers a
                WHERE     1 = 1
                      AND entity_id IN
                              (SELECT ENTITY_ID
                                FROM xla.xla_transaction_entities
                               WHERE     TRANSACTION_NUMBER =
                                         'Акт приема-передачи Лицензий 62' -- Invoice Number
                                     AND SOURCE_ID_INT_1 = '1217238' -- Invoice ID
                                                                    ))

-- XLA AP Invoice in xla_ae_line_acs
SELECT a.*  
  FROM xla.xla_ae_line_acs a
 WHERE     1 = 1
       AND ae_header_id IN
               (SELECT ae_header_id
                 FROM xla.xla_ae_headers a
                WHERE     1 = 1
                      AND entity_id IN
                              (SELECT ENTITY_ID
                                FROM xla.xla_transaction_entities
                               WHERE     TRANSACTION_NUMBER =
                                         'Акт приема-передачи Лицензий 62' -- Invoice Number
                                     AND SOURCE_ID_INT_1 = '1217238' -- Invoice ID
                                                                    ))


-- XLA AP Invoice in xla_ae_headers
SELECT a.*
  FROM xla.xla_ae_headers a
 WHERE     1 = 1
       AND entity_id IN
               ( (SELECT ENTITY_ID
                  FROM xla.xla_transaction_entities
                 WHERE     TRANSACTION_NUMBER =
                           'Акт приема-передачи Лицензий 62' -- Invoice Number
                       AND SOURCE_ID_INT_1 = '1217238'           -- Invoice ID
                                                      ))
                                                      
/* XLA xla_events Final*/
UPDATE xla.xla_events
   SET EVENT_STATUS_CODE = 'F', PROCESS_STATUS_CODE = 'F'
 WHERE entity_id IN
           ( (SELECT ENTITY_ID
              FROM xla.xla_transaction_entities
             WHERE     TRANSACTION_NUMBER =
                       'Акт приема-передачи Лицензий 62'
                   AND SOURCE_ID_INT_1 = '1217238'               -- Invoice ID
                                                  ))

/* 1 Final acc Payment - Do not reformat accounting in the future */
UPDATE xla_events
   SET EVENT_STATUS_CODE = 'P', PROCESS_STATUS_CODE = 'P'                --U D
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE ENTITY_CODE = 'AP_PAYMENTS' AND SOURCE_ID_INT_1 = '616904') -- Payment Num

/* 2 Final acc Payment - Do not reformat accounting in the future */
UPDATE xla_ae_headers h
   SET ACCOUNTING_ENTRY_STATUS_CODE = 'F'-- D
       , FUNDS_STATUS_CODE = 'S'         -- null
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
             FROM xla.xla_transaction_entities
            WHERE ENTITY_CODE = 'AP_PAYMENTS' AND SOURCE_ID_INT_1 = '616904') -- Payment Num

-- XLA AP Invoice in xla_events
SELECT a.*
  FROM xla.xla_events a
 WHERE entity_id IN
           ( (SELECT ENTITY_ID
                  FROM xla.xla_transaction_entities
                 WHERE     TRANSACTION_NUMBER =
                           'Акт приема-передачи Лицензий 62' -- Invoice Number
                       AND SOURCE_ID_INT_1 = '1217238'           -- Invoice ID
                                                      ))

-- XLA AP Invoice in xla_transaction_entities
SELECT *
  FROM xla.xla_transaction_entities
 WHERE     TRANSACTION_NUMBER =
           'Акт приема-передачи Лицензий 62' -- Invoice Number
       AND SOURCE_ID_INT_1 = '1217238'   -- Invoice ID


select xte.application_id        as appl_id
      ,xte.entity_code           as entity_code
      ,ec.event_class_code       as event_class_code
      ,ec.name                   as event_class
      ,xal.code_combination_id   as cc_id     
      ,fnd_flex_ext.get_segs('SQLGL','GL#',gl.chart_of_accounts_id, xal.code_combination_id)      as ACCOUNT
      --,xla_oa_functions_pkg.get_ccid_description(gl.chart_of_accounts_id,xal.code_combination_id) as account_description
      ,xah.ae_header_id          as xah_ae_header_id
      ,xal.ae_line_num           as xal_ae_line_num
      ,xal.ledger_id             as xal_ledger_id
      ,xte.ledger_id             as xte_ledger_id
      ,xae.event_type_code       as event_type_code
      ,et.name                   as event_type
      ,xae.event_number          as event_number
      ,xal.accounting_class_code as acc_class_code   -- класс учета
      ,lk1.meaning               as accounting_class
      ,xal.accounting_date       as accounting_date
      ,xal.accounted_dr          as accounted_dr
      ,xal.accounted_cr          as accounted_cr
      ,xal.currency_code         as currency_code
      ,nvl(xte.source_id_int_1, -99) as source_id_int_1
      ,decode(xal.party_type_code, 'C', xal.party_id)      as customer_id
      ,decode(xal.party_type_code, 'C', xal.party_site_id) as customer_site_id
from xla.xla_transaction_entities  xte
   , xla.xla_ae_headers            xah
   , xla.xla_ae_lines              xal
   , xla.xla_events                xae
   , xla_lookups                   lk1
   , xla_gl_ledgers_v              gl   
   , xla.xla_event_types_tl        et
   , xla.xla_event_classes_tl      ec
where 1=1
      -- sla xah
      and xah.entity_id      = xte.entity_id
      and xah.application_id = xte.application_id
      and xah.ledger_id      = xal.ledger_id
      -- sla xal
      and xal.ae_header_id   = xah.ae_header_id
      and xal.application_id = xah.application_id
      and (nvl(xal.accounted_dr,0) != 0 or nvl(xal.accounted_cr,0)!=0)
      -- sla xae
      and xae.application_id  = xah.application_id
      and xae.event_id        = xah.event_id  
      -- lk1
      and lk1.lookup_code = xal.accounting_class_code
      and lk1.lookup_type = 'XLA_ACCOUNTING_CLASS'
      -- gl
      and gl.ledger_id = xah.ledger_id
      -- et 
      and et.application_id  = xte.application_id
      and et.entity_code     = xte.entity_code      
      and et.event_type_code = xae.event_type_code
      and et.language        = USERENV('LANG')
      -- ec
      and ec.application_id   = xte.application_id
      and ec.entity_code      = xte.entity_code
      and ec.event_class_code = et.event_class_code
      and ec.language         = USERENV('LANG')
      -- ======
      -- and xte.entity_code    = 'RECEIPTS'
      -- and xte.application_id = 222
      -- and xte.ledger_id = fnd_profile.value('GL_SET_OF_BKS_ID')
      -- and nvl(source_id_int_1,(-99)) = 
