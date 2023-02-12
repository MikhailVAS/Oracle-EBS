/* Update recreate accounting material trx*/
UPDATE xla_events
   SET event_status_code = 'U', process_status_code = 'I'
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
              FROM xla.xla_transaction_entities
             WHERE     entity_code = '  MTL_ACCOUNTING_EVENTS'
                   AND SOURCE_ID_INT_1 IN
                           (SELECT transaction_id
                              --transfer_transaction_id
                              FROM mtl_material_transactions mmt
                             WHERE transaction_set_id IN (47006803,
                                                          47007333,
                                                          47015298,
                                                          47015310,
                                                          47015323)));

/* Formatted (QP5 v5.326) Service Desk  614127 Mihail.Vasiljev */
DELETE FROM mtl_cst_layer_act_cost_details
      WHERE TRANSACTION_ID = :TR_ID

/* =========================   Исправление  Кол-во ============================*/     
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

/* ===================    Отправка на пересчет   ==============================*/             
UPDATE inv.mtl_material_transactions
   SET costed_flag = 'N'
 WHERE 1 = 1 AND costed_flag = 'E' AND transaction_id IN (:TR_ID)


/* ========= Пропустить (Если ошибка Layer Cost a не Quantity) ==================*/       
UPDATE inv.mtl_material_transactions
   SET costed_flag = NULL
 WHERE 1 = 1 AND transaction_id IN (:TR_ID)
 
 
/* =========================   Проверка на ошибки =================================*/
SELECT costed_flag,
       transaction_id,
       primary_quantity,
       error_explanation,
       ERROR_CODE,
       a.*
  FROM inv.mtl_material_transactions a
   WHERE 1 = 1 AND costed_flag IN ('E')



/* =========================   Проверка на ошибки ================================= */
  SELECT costed_flag, COUNT (1)
    FROM inv.mtl_material_transactions
   WHERE 1 = 1 AND costed_flag IN ('E', 'N')
GROUP BY costed_flag

--AUTODATAFIX DUPLICATION OF MTL EVENTS AFTER COST MANAGER CRASH
delete from XXTG_GL001_DOUBLE_GLOBAL
where C_ACCOUNTING_CLASS_CODE = 'INVENTORY_VALUATION'
and c_ae_header_id in (select ae_header_id from xla_ae_headers 
                       where event_id in (select min(event_id)
                       from xla_events
                       where process_status_code <> 'P' 
                       AND ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                       and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_date >= to_date('01122020','ddmmyyyy')))
                       group by ENTITY_ID having count(1)>1)
                      );

delete from xla_ae_lines where ae_header_id in (select ae_header_id from xla_ae_headers 
                       where event_id in (select min(event_id)
                       from xla_events
                       where process_status_code <> 'P' 
                       AND ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                       and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_date >= to_date('01122020','ddmmyyyy')))
                       group by ENTITY_ID having count(1)>1)
                      );

delete from xla_ae_headers 
where event_id in (select ae_header_id from xla_ae_headers 
                       where event_id in (select min(event_id)
                       from xla_events
                       where process_status_code <> 'P' 
                       AND ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                       and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_date >= to_date('01122020','ddmmyyyy')))
                       group by ENTITY_ID having count(1)>1)
                      );

update xla_events
set EVENT_STATUS_CODE='P', PROCESS_STATUS_CODE='P'
where 1=1
    AND APPLICATION_ID = 707
    AND EVENT_ID in (select min(event_id)
                       from xla_events
                       where process_status_code <> 'P' 
                       AND ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                       and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_date >= to_date('01122020','ddmmyyyy')))
                       group by ENTITY_ID having count(1)>1)
    AND process_status_code <> 'P';

/* =================   удаление задвоений после падения кост-менеджера =============== */
declare      
   l_inv_start_date date:=to_date('01082020', 'ddmmyyyy');
   begin
            FOR c1_rec IN (select transaction_id from mtl_transaction_accounts
                        where transaction_date >= l_inv_start_date
                        group by  transaction_id having count(1) > 3
            ) LOOP
                  delete
                  from mtl_transaction_accounts dg1
                  where rowid <> (select max(rowid)
                                   from mtl_transaction_accounts dg2
                                  where dg2.transaction_id = c1_rec.transaction_id
                                    and dg2.ACCOUNTING_LINE_TYPE = 1)
                    and dg1.transaction_id = c1_rec.transaction_id
                    and dg1.ACCOUNTING_LINE_TYPE = 1;

                  delete
                  from mtl_transaction_accounts dg1
                  where rowid <> (select max(rowid)
                                   from mtl_transaction_accounts dg2
                                  where dg2.transaction_id = c1_rec.transaction_id
                                    and dg2.ACCOUNTING_LINE_TYPE = 2)
                    and dg1.transaction_id = c1_rec.transaction_id
                    and dg1.ACCOUNTING_LINE_TYPE = 2;
            END LOOP;
   end;     


/* ============ Update cost else unique constraint and have MTL_TRANSACTION_ACCOUNTS =============== */
UPDATE inv.mtl_material_transactions
   SET costed_flag = NULL
 WHERE     1 = 1
       AND transaction_id =
           (SELECT DISTINCT MTA.TRANSACTION_ID
              FROM MTL_TRANSACTION_ACCOUNTS   MTA,
                   MTL_MATERIAL_TRANSACTIONS  MMT
             WHERE     mta.transaction_id = mmt.transaction_id
                   AND mmt.transaction_id =
                       (SELECT transaction_id
                          FROM inv.mtl_material_transactions a
                         WHERE     costed_flag IN ('E')
                               AND ERROR_EXPLANATION =
                                   'CSTPLCIN.COST_INV_TXN:CSTPLENG.create_layers (100): ORA-00001: unique constraint (INV.MTL_CST_LAYER_ACT_CST_DTLS_U1) violated'))

/* ============ Update cost else unique constraint and have MTL_TRANSACTION_ACCOUNTS =============== */
UPDATE inv.mtl_material_transactions
   SET costed_flag = NULL
 WHERE     error_explanation =
           'CSTPLCIN.COST_INV_TXN:CSTPLVCP.interorg (160): ORA-00001: unique constraint (INV.MTL_CST_TXN_COST_DETAILS_U1) violated'
       AND TRANSACTION_ID IN (SELECT TRANSACTION_ID
                                FROM inv.MTL_TRANSACTION_ACCOUNTS
                               WHERE TRANSACTION_ID IN (:Trx))
							   
							   
 /* =========================   Исправление  Кол-во ============================*/     
/* Formatted (QP5 v5.326) Service Desk 348984 Mihail.Vasiljev */
UPDATE bom.cst_inv_layers
   SET layer_quantity = CREATION_QUANTITY
 WHERE INV_LAYER_ID IN
           (SELECT DISTINCT cil.inv_layer_id
              /*, cil.creation_quantity
              , cil.layer_quantity
              , cil.layer_Cost
              , mtln_in.lot_number
              , mtln_in.transaction_date*/
              FROM bom.cst_inv_layers               cil,
                   inv.mtl_transaction_lot_numbers  mtln_in,
                   inv.mtl_transaction_lot_numbers  mtln_out,
                   inv.mtl_material_transactions    mmt
             WHERE     cil.create_transaction_id = mmt.transaction_id --nvl(mmt.transfer_transaction_id, mmt.transaction_id)
                   AND cil.organization_id = mmt.organization_id
                   AND mtln_in.inventory_item_id = mtln_out.inventory_item_id
                   AND mtln_in.organization_id = mtln_out.organization_id
                   AND mtln_in.lot_number = mtln_out.lot_number
                   AND mmt.transaction_id = mtln_in.transaction_id
                   AND mmt.transaction_quantity > 0
                   AND mmt.transaction_quantity > cil.LAYER_QUANTITY -- ++ после update he покажет
                   AND mtln_out.transaction_id IN
                           (SELECT transaction_id
                              FROM inv.mtl_material_transactions a
                             WHERE     costed_flag IN ('E')
                                   AND ERROR_EXPLANATION =
                                       'CSTPLCIN.COST_INV_TXN:layers_hook: not enough quantity'))

/* ===================    Отправка на пересчет   ==============================*/             
/* Formatted (QP5 v5.326) Service Desk 348984 Mihail.Vasiljev */
UPDATE inv.mtl_material_transactions
   SET costed_flag = 'N'
 WHERE     1 = 1
       AND costed_flag = 'E'
       AND transaction_id IN
               (SELECT transaction_id
                  FROM inv.mtl_material_transactions a
                 WHERE     costed_flag IN ('E')
                       AND ERROR_EXPLANATION =
                           'CSTPLCIN.COST_INV_TXN:layers_hook: not enough quantity')
						   
-- Service Desk #349001   
delete from MTL_CST_TXN_COST_DETAILS where transaction_id in (
   select transaction_id from mtl_material_transactions where  transaction_id in (   select transaction_id
   from mtl_material_transactions MMT
   where 1=1 
    and (TRANSACTION_TYPE_ID = 803 or TRANSACTION_TYPE_ID = 581) --114--54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01112019', 'ddmmyyyy') and to_date('01122019', 'ddmmyyyy')
) and transfer_transaction_id is null
);

-- Service Desk #349001
delete from MTL_CST_LAYER_ACT_COST_DETAILS  where transaction_id in (
  select transaction_id from mtl_material_transactions where  transaction_id in (   select transaction_id
   from mtl_material_transactions MMT
   where (TRANSACTION_TYPE_ID = 803 or TRANSACTION_TYPE_ID = 581) --114-- 54 -- Int Order Direct Ship
     and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01112019', 'ddmmyyyy') and to_date('01122019', 'ddmmyyyy')
) and transfer_transaction_id is null
);   


/* ===================    Фикс задублированных событий учета в инвентори   ==============================*/ 
delete from XXTG_GL001_DOUBLE_GLOBAL
where C_ACCOUNTING_CLASS_CODE = 'INVENTORY_VALUATION'
and c_ae_header_id in ( (select ae_header_id from xla_ae_headers where  event_id in (select min(event_id)
                    from xla_events
                    where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                    and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_set_id in (43587399)))
                    group by ENTITY_ID)));

delete from xla_ae_lines where ae_header_id in (select ae_header_id from xla_ae_headers where  event_id in (select min(event_id)
                    from xla_events
                    where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                    and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_set_id in (43587399)))
                    group by ENTITY_ID));

delete from xla_ae_headers where  event_id in (select min(event_id)
                    from xla_events
                    where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                    and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_set_id in (43587399)))
                    group by ENTITY_ID);

update xla_events
set EVENT_STATUS_CODE='P', PROCESS_STATUS_CODE='P'
where 1=1
    AND APPLICATION_ID = 707
    AND EVENT_ID in (select min(event_id)
                    from xla_events
                    where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code = 'MTL_ACCOUNTING_EVENTS'
                    and SOURCE_ID_INT_1 in (select transaction_id from mtl_material_transactions where transaction_set_id in (43587399)))
                    group by ENTITY_ID)
    AND process_status_code <> 'P';
	
	/* ===================    т   ==============================*/ 


SELECT   transaction_id txnid, transfer_transaction_id txfrtxnid
       , organization_id orgid, transfer_organization_id txfrorgid, subinventory_code subinv
       , transfer_subinventory txfrsubinv, cost_group_id cgid
       , transfer_cost_group_id txfrcgid       , prior_costed_quantity
       , transfer_prior_costed_quantity       , rcv_transaction_id rcvtxnid
       , transaction_action_id txnactid       , transaction_source_type_id txnsrctypid
       , transaction_type_id txntypid       , costed_flag cstdflg
       , transaction_group_id       , inventory_item_id invitmid
       , transaction_source_id wip_entity_id       , transaction_cost txncst
       , shipment_number shipnum       , new_cost       , prior_cost
       , actual_cost       , project_id       , transaction_uom txnuom
       , transaction_quantity txnqty       , primary_quantity priqty       , prior_costed_quantity priorqty
       , currency_code altcurr       , currency_conversion_rate currconvrt       , currency_conversion_date currconvdt
       , TO_CHAR (mmt.creation_date, 'dd-mm-yyyy hh24:mi:ss') creation_date
       , TO_CHAR (mmt.last_update_date, 'dd-mm-yyyy hh24:mi:ss')last_upd_date
       , ERROR_CODE errcode
       , error_explanation errexpl
    FROM mtl_material_transactions mmt
   WHERE transaction_id IN (&Trx_Id)   -- Error transaction_id
ORDER BY transaction_id DESC

/* =====================================================================================================================*/ 


/*Cause
The cause of the issue is invalid / incorrect data in MMT*/

1. SELECT * FROM mtl_tranaction_accounts
WHERE transaction_id = 187288763;

2. SELECT * FROM mtl_cst_layer_act_cost_details
WHERE inventory_item_id =
(SELECT * FROM mtl_material_transactions
WHERE transaction_id = 187288763)
AND organization_id = 333;


-- Solution
-- To implement the solution, please execute the following steps::
-- 1. Ensure that you have taken a backup of your system before applying the recommended solution.

-- 2. Run the following scripts in a TEST environment first:

SELECT * FROM mtl_tranaction_accounts
WHERE transaction_id = xxx;

SELECT * FROM mtl_cst_layer_act_cost_details
WHERE inventory_item_id =
(SELECT * FROM mtl_material_transactions
WHERE transaction_id = &txn_id)
AND organization_id = &org_id;

/*If a row is returned for both scripts then the data should not be with costed flag N, or E,
because there exists data in MTA and MCLACD? We can set the costed_flag = NULL as the record is
already costed.The system is trying to insert a duplicate and this is the reason why we get the
error CSTPLENG.create_layers (100): ORA-00001: unique constraint (INV.MTL_CST_LAYER_ACT_CST_DTLS_U1)
As a result, the line will not be seen by the cost Manager as to be costed and we will not get
this error...

Run the following update script:*/

update mtl_material_transactions
set costed_flag = NULL,
transaction_group_id = NULL,
error_code = NULL,
error_explanation = NULL
where costed_flag ='E'
and TRANSACTION_ID = &txn_id
and organization_id= &org_id;


--3. Once the scripts complete, confirm that the data is corrected.

Select *
from mtl_material_transactions
where transaction_id = &txn_id
 /* =====================================================================================================================*/ 




  




'