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
