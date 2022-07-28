/* Check double_global DefShpSub
Firs   Dt Amount
Second Ct Amount */

SELECT                                                              
      SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND D_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.02.2022', '.dd.mm.yyyy')
                                 AND TO_DATE ('28.02.2022', '.dd.mm.yyyy')
UNION ALL 
SELECT                                                              
       SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND  c_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.02.2022', '.dd.mm.yyyy')
                                 AND TO_DATE ('28.02.2022', '.dd.mm.yyyy')

--should be zero for period
select (select sum(accounted_amount) from XXTG_GL001_DOUBLE_GLOBAL
where d_segment2 = '0028' and c_segment2 not like '0__'
and d_accounting_date between to_date('01062022', 'ddmmyyyy') and to_date('30062022', 'ddmmyyyy'))
-
(select sum(accounted_amount) from XXTG_GL001_DOUBLE_GLOBAL
where c_segment2 = '0028' and d_segment2 not like '0__'
and c_accounting_date between to_date('01062022', 'ddmmyyyy') and to_date('30062022', 'ddmmyyyy')) diff from dual;

/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */	
delete from MTL_CST_TXN_COST_DETAILS where transaction_id in (select transfer_transaction_id from mtl_material_transactions where  transaction_id in (   select transaction_id
   from mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01062022', 'ddmmyyyy') and to_date('30062022', 'ddmmyyyy')
));

/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
delete from MTL_CST_LAYER_ACT_COST_DETAILS  where transaction_id in (select transfer_transaction_id from mtl_material_transactions where  transaction_id in (   select transaction_id
   from mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01062022', 'ddmmyyyy') and to_date('30062022', 'ddmmyyyy')
));

/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE mtl_material_transactions MMT
   SET MMT.costed_flag = 'N',
       MMT.ERROR_CODE = NULL,
       MMT.error_explanation = NULL
 WHERE NOT EXISTS
          (SELECT 1
             FROM MTL_TRANSACTION_ACCOUNTS MTA
            WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
       AND transaction_id IN
              (SELECT transaction_id
                 FROM mtl_material_transactions MMT
                WHERE TRANSACTION_TYPE_ID = 54        -- Int Order Direct Ship
                      AND NOT EXISTS
                             (SELECT 1
                                FROM MTL_TRANSACTION_ACCOUNTS MTA
                               WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
                      AND transaction_date BETWEEN TO_DATE ('01062022',
                                                            'ddmmyyyy')
                                               AND TO_DATE ('30062022',
                                                            'ddmmyyyy'));

/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE mtl_material_transactions MMT
   SET MMT.costed_flag = 'N',
       MMT.ERROR_CODE = NULL,
       MMT.error_explanation = NULL
 WHERE NOT EXISTS
          (SELECT 1
             FROM MTL_TRANSACTION_ACCOUNTS MTA
            WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
       AND transaction_id IN
              (SELECT transfer_transaction_id
                 FROM mtl_material_transactions MMT
                WHERE TRANSACTION_TYPE_ID = 54        -- Int Order Direct Ship
                      AND NOT EXISTS
                             (SELECT 1
                                FROM MTL_TRANSACTION_ACCOUNTS MTA
                               WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
                      AND transaction_date BETWEEN TO_DATE ('01062022',
                                                            'ddmmyyyy')
                                               AND TO_DATE ('30062022',
                                                            'ddmmyyyy'));
 

/* Чистка XLA*/ 
delete (
select a.* from xla.xla_ae_lines a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (176752))) 
)
)

/* Чистка XLA*/ 
delete (
select a.* from xla.xla_ae_line_acs a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a --- posted or not
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (:TR_SET_ID ))) 
)
)

/* Чистка XLA*/   -- PreLast
delete (
select a.* from xla.xla_ae_headers  a --- posted or not
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (:TR_SET_ID ))) --and AE_HEADER_ID = 293595766
)

/* Чистка XLA*/ 
delete (
select a.* from xla.xla_events a 
where entity_id in 
(select ENTITY_ID from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (:TR_SET_ID )))
)

/* Чистка XLA*/ --- ONLY LAST
delete (
select * from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (:TR_SET_ID ))
)

-----------------------------------------------------

/* Чистка XLA*/ 
delete (
select * from inv.MTL_TRANSACTION_ACCOUNTS 
where 1=1 
and TRANSACTION_ID in (select to_char(transaction_id) from inv.mtl_material_transactions mt where transaction_set_id in (:TR_SET_ID ))
)


/* Чистка XLA*/            
update inv.mtl_material_transactions
set costed_flag = 'N'
where 1=1
and transaction_Set_id in (:TR_SET_ID )

/* =====================================================================================================================*/ 

/*  Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE PO.PO_REQUISITION_HEADERS_all
   SET ATTRIBUTE1 = :ReaSoN                                -- MOVE_BETWEEN_MRP
 -- select ATTRIBUTE1 from PO.PO_REQUISITION_HEADERS_all
 WHERE 1 = 1 AND SEGMENT1 IN (:IR)

/*  Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev  */
UPDATE po.PO_REQUISITION_LINES_all
   SET REFERENCE_NUM = :ReaSoN,                            -- MOVE_BETWEEN_MRP
                               ATTRIBUTE_CATEGORY = NULL, ATTRIBUTE4 = NULL
 -- select REFERENCE_NUM, ATTRIBUTE_CATEGORY, ATTRIBUTE4 from po.PO_REQUISITION_LINES_all
 WHERE REQUISITION_HEADER_ID IN (SELECT REQUISITION_HEADER_ID
                                   FROM PO.PO_REQUISITION_HEADERS_all
                                  WHERE SEGMENT1 IN (:IR))
-- OR

/* Formatted (QP5 v5.326) Service Desk 570583 Mihail.Vasiljev */
UPDATE po.PO_REQUISITION_LINES_all
   SET REFERENCE_NUM = 'MOVE_BETWEEN_MRP',
       ATTRIBUTE_CATEGORY = NULL,
       ATTRIBUTE4 = NULL
 WHERE REQUISITION_HEADER_ID IN
           (SELECT REQUISITION_HEADER_ID
              FROM PO.PO_REQUISITION_HEADERS_all
             WHERE     ATTRIBUTE1 = 'SIT_PUT_INTO_OPERATION'
                   AND APPROVED_DATE BETWEEN TO_DATE ('01.02.2022',
                                                      'dd.mm.yyyy')
                                         AND TO_DATE ('28.02.2022',
                                                      'dd.mm.yyyy'))	 

/* Formatted (QP5 v5.326) Service Desk 570583 Mihail.Vasiljev */
UPDATE PO.PO_REQUISITION_HEADERS_all
   SET ATTRIBUTE1 = 'MOVE_BETWEEN_MRP'
 WHERE     ATTRIBUTE1 = 'SIT_PUT_INTO_OPERATION'
       AND APPROVED_DATE BETWEEN TO_DATE ('01.02.2022', 'dd.mm.yyyy')
                             AND TO_DATE ('28.02.2022', 'dd.mm.yyyy')

 

/* =====================================================================================================================*/ 
/*  Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev*/
--- unique
UPDATE inv.MTL_TRANSACTION_ACCOUNTS a
   SET rate_or_Amount = (:amount) / ABS (primary_quantity),
       base_transaction_value =
          primary_quantity * ( (:amount) / ABS (primary_quantity))
 --select TRANSACTION_ID, rate_or_Amount,base_transaction_value, primary_quantity from inv.MTL_TRANSACTION_ACCOUNTS
 WHERE 1 = 1 AND TRANSACTION_ID IN (:Trx)

/* =====================================================================================================================*/    
/*  Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE inv.mtl_material_transactions
   SET                  --  attribute13 = '2015/10/07 09:00:00'  -- 29.09.2015
 --, transaction_date = to_date ('11.08.2014 14:00:00','dd.mm.yyyy HH24:MI:ss') -- income order
       ATTRIBUTE14 = '0001', ATTRIBUTE15 = '0001'
 WHERE TRANSACTION_SET_ID IN (:TrxSetID)
/* =====================================================================================================================*/ 

---SD  unique  part I
/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE inv.MTL_TRANSACTION_ACCOUNTS a
   SET rate_or_Amount =
            (  SELECT ABS (SUM (base_transaction_value))
                 FROM inv.MTL_TRANSACTION_ACCOUNTS
                WHERE     transaction_id IN
                             (SELECT transaction_id
                                FROM (  SELECT DISTINCT
                                               ',' || mt.transaction_set_id,
                                               transaction_id,
                                               SHIPMENT_NUMBER,
                                               mt.ORGANIZATION_ID,
                                               SEGMENT1-- , mt.TRANSACTION_QUANTITY
                                                       --, TRX_SOURCE_LINE_ID
                                               ,
                                               mt.ATTRIBUTE14,
                                               mt.ATTRIBUTE15--, cr.user_name as CREATED_BY
                                                             --, up.user_name as UpDated_BY
                                               ,
                                               COUNT (1)
                                          --, mt.*
                                          FROM inv.mtl_material_transactions mt --join  inv.mtl_system_items_b IC on mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
                                                                               ,
                                               applsys.fnd_user          cr,
                                               applsys.fnd_user          UP,
                                               inv.mtl_system_items_b    IC
                                         WHERE     mt.CREATED_BY = cr.user_id
                                               AND mt.LAST_UPDATED_BY =
                                                      UP.user_id
                                               AND mt.ORGANIZATION_ID =
                                                      IC.ORGANIZATION_ID
                                               AND mt.INVENTORY_ITEM_ID =
                                                      IC.INVENTORY_ITEM_ID
                                               AND SUBINVENTORY_CODE =
                                                      'DefShpSub'
                                               AND TRANSACTION_QUANTITY < 0
                                               AND TRX_SOURCE_LINE_ID IN
                                                      (SELECT TRX_SOURCE_LINE_ID
                                                         FROM inv.mtl_material_transactions
                                                        WHERE     1 = 1
                                                              AND SHIPMENT_NUMBER IN
                                                                     (:SHIPMENT_NUM) --066044
                                                              AND SEGMENT1 IN
                                                                     (:item)) -- order by mt.TRANSACTION_QUANTITY
                                      GROUP BY mt.transaction_set_id,
                                               transaction_id,
                                               SHIPMENT_NUMBER,
                                               mt.ORGANIZATION_ID,
                                               SEGMENT1--, TRX_SOURCE_LINE_ID
                                               ,
                                               mt.ATTRIBUTE14,
                                               mt.ATTRIBUTE15))
                      AND BASE_TRANSACTION_VALUE < 0
             GROUP BY INVENTORY_ITEM_ID)
          / ABS (primary_quantity),
       base_transaction_value =
            primary_quantity
          * (  (  SELECT ABS (SUM (base_transaction_value))
                    FROM inv.MTL_TRANSACTION_ACCOUNTS
                   WHERE     transaction_id IN
                                (SELECT transaction_id
                                   FROM (  SELECT DISTINCT
                                                  ',' || mt.transaction_set_id,
                                                  transaction_id,
                                                  SHIPMENT_NUMBER,
                                                  mt.ORGANIZATION_ID,
                                                  SEGMENT1-- , mt.TRANSACTION_QUANTITY
                                                          --, TRX_SOURCE_LINE_ID
                                                  ,
                                                  mt.ATTRIBUTE14,
                                                  mt.ATTRIBUTE15--, cr.user_name as CREATED_BY
                                                                --, up.user_name as UpDated_BY
                                                  ,
                                                  COUNT (1)
                                             --, mt.*
                                             FROM inv.mtl_material_transactions
                                                  mt --join  inv.mtl_system_items_b IC on mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
                                                    ,
                                                  applsys.fnd_user   cr,
                                                  applsys.fnd_user   UP,
                                                  inv.mtl_system_items_b IC
                                            WHERE     mt.CREATED_BY = cr.user_id
                                                  AND mt.LAST_UPDATED_BY =
                                                         UP.user_id
                                                  AND mt.ORGANIZATION_ID =
                                                         IC.ORGANIZATION_ID
                                                  AND mt.INVENTORY_ITEM_ID =
                                                         IC.INVENTORY_ITEM_ID
                                                  AND SUBINVENTORY_CODE =
                                                         'DefShpSub'
                                                  AND TRANSACTION_QUANTITY < 0
                                                  AND TRX_SOURCE_LINE_ID IN
                                                         (SELECT TRX_SOURCE_LINE_ID
                                                            FROM inv.mtl_material_transactions
                                                           WHERE     1 = 1
                                                                 AND SHIPMENT_NUMBER IN
                                                                        (:SHIPMENT_NUM) --066044
                                                                 AND SEGMENT1 IN
                                                                        (:item)) -- order by mt.TRANSACTION_QUANTITY
                                         GROUP BY mt.transaction_set_id,
                                                  transaction_id,
                                                  SHIPMENT_NUMBER,
                                                  mt.ORGANIZATION_ID,
                                                  SEGMENT1--, TRX_SOURCE_LINE_ID
                                                  ,
                                                  mt.ATTRIBUTE14,
                                                  mt.ATTRIBUTE15))
                         AND BASE_TRANSACTION_VALUE < 0
                GROUP BY INVENTORY_ITEM_ID)
             / ABS (primary_quantity))
 WHERE     1 = 1
       AND TRANSACTION_ID IN
              (SELECT transaction_id
                 FROM (  SELECT DISTINCT ',' || mt.transaction_set_id,
                                         transaction_id,
                                         SHIPMENT_NUMBER,
                                         mt.ORGANIZATION_ID,
                                         SEGMENT1-- , mt.TRANSACTION_QUANTITY
                                                 --, TRX_SOURCE_LINE_ID
                                         ,
                                         mt.ATTRIBUTE14,
                                         mt.ATTRIBUTE15--, cr.user_name as CREATED_BY
                                                       --, up.user_name as UpDated_BY
                                         ,
                                         COUNT (1)
                           --, mt.*
                           FROM inv.mtl_material_transactions mt --join  inv.mtl_system_items_b IC on mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
                                                                ,
                                applsys.fnd_user            cr,
                                applsys.fnd_user            UP,
                                inv.mtl_system_items_b      IC
                          WHERE     mt.CREATED_BY = cr.user_id
                                AND mt.LAST_UPDATED_BY = UP.user_id
                                AND mt.ORGANIZATION_ID = IC.ORGANIZATION_ID
                                AND mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
                                AND TRANSFER_SUBINVENTORY = 'DefShpSub'
                                AND TRANSACTION_QUANTITY < 0
                                AND TRX_SOURCE_LINE_ID IN
                                       (SELECT TRX_SOURCE_LINE_ID
                                          FROM inv.mtl_material_transactions
                                         WHERE     1 = 1
                                               AND SHIPMENT_NUMBER IN
                                                      (:SHIPMENT_NUM) --066044
                                               AND SEGMENT1 IN (:item)) -- order by mt.TRANSACTION_QUANTITY
                       GROUP BY mt.transaction_set_id,
                                transaction_id,
                                SHIPMENT_NUMBER,
                                mt.ORGANIZATION_ID,
                                SEGMENT1--, TRX_SOURCE_LINE_ID
                                ,
                                mt.ATTRIBUTE14,
                                mt.ATTRIBUTE15))
                                
/* =========================   Исправление CostManager =================================*/
/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE bom.cst_inv_layers
   SET layer_quantity = CREATION_QUANTITY
 WHERE INV_LAYER_ID IN
          (SELECT DISTINCT cil.inv_layer_id
             /*, cil.creation_quantity
             , cil.layer_quantity
             , cil.layer_Cost
             , mtln_in.lot_number
             , mtln_in.transaction_date*/
             FROM bom.cst_inv_layers              cil,
                  inv.mtl_transaction_lot_numbers mtln_in,
                  inv.mtl_transaction_lot_numbers mtln_out,
                  inv.mtl_material_transactions   mmt
            WHERE     cil.create_transaction_id = mmt.transaction_id --nvl(mmt.transfer_transaction_id, mmt.transaction_id)
                  AND cil.organization_id = mmt.organization_id
                  AND mtln_in.inventory_item_id = mtln_out.inventory_item_id
                  AND mtln_in.organization_id = mtln_out.organization_id
                  AND mtln_in.lot_number = mtln_out.lot_number
                  AND mmt.transaction_id = mtln_in.transaction_id
                  AND mmt.transaction_quantity > 0
                  AND mmt.transaction_quantity > cil.LAYER_QUANTITY -- ++ после update he покажет
                  AND mtln_out.transaction_id IN (:TR_ID))

/* Formatted (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev*/
UPDATE inv.mtl_material_transactions
   SET costed_flag = 'N'
 WHERE 1 = 1 AND costed_flag = 'E'
  AND transaction_id IN (:TR_ID)
  

/* Formatted  (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
UPDATE inv.mtl_material_transactions
   SET costed_flag = NULL
 WHERE 1 = 1 AND transaction_id IN (:TR_ID)
 /* =====================================================================================================================*/ 
 
 /* Formatted  (QP5 v5.294) Service Desk 570583 Mihail.Vasiljev */
 DELETE APPS.MTL_RESERVATIONS WHERE RESERVATION_ID = :RESERVATION_ID 

/* (QP5 v5.288) Service Desk 570583 Mihail.Vasiljev */
DELETE FROM APPS.MTL_RESERVATIONS
      WHERE DEMAND_SOURCE_HEADER_ID = :SORCE_RESERVATION_ID

--non-accounted inter-org movements trx  
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records' error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01032022','ddmmyyyy')  and to_date('31032022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity >= 0 AND TRANSACTION_TYPE_ID IN (95, 54)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where d_doc_id = transaction_id and D_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
--and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id
union
select 'MTL_TRANSACTION' document_type, te.SOURCE_ID_INT_1 document_id, h.EVENT_TYPE_CODE EVENT_TYPE_CODE, 'No accounting records' error_description, ai.transaction_id document_num, ai.transaction_date document_date, '' creator_name, '' last_updated_name, '' last_update_time, sysdate acconting_date, ' D' accounting_mode
from xla_ae_headers h
, xla.xla_transaction_entities te
, mtl_material_transactions ai
where h.application_id = 707
and h.ENTITY_ID = te.ENTITY_ID
and te.SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions mmt
                            where transaction_date between to_date('01032022','ddmmyyyy')  and to_date('31032022','ddmmyyyy') and nvl(attribute14, 'xxx') != '0001' 
                            AND transaction_quantity < 0 AND TRANSACTION_TYPE_ID IN (95, 54)
                            and exists (select 1 from mtl_material_transactions mta where mta.transaction_id = mmt.transaction_id)
                          )
and not exists (select 1 from XXTG_GL001_DOUBLE_GLOBAL where c_doc_id = transaction_id and c_APPL_ID = 707)
and exists (select 1 from xla_ae_lines l where l.ae_header_id = h.ae_header_id and (nvl(ACCOUNTED_DR, 0) != 0 or nvl(ACCOUNTED_CR, 0) != 0 ))
--and not exists (select 1 from xla_ae_lines l, gl_code_combinations gcc  where l.ae_header_id = h.ae_header_id and gcc.code_combination_id = l.code_combination_id and gcc.segment2 = '0001')
and te.SOURCE_ID_INT_1 = ai.transaction_id;