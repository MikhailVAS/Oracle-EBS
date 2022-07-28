/* Проверка на увеличение учёта */
  SELECT TRANSACTION_ID, COUNT (*)
    FROM inv.MTL_TRANSACTION_ACCOUNTS a
   WHERE     1 = 1
         AND TRANSACTION_ID IN (SELECT TRANSACTION_ID
                                  FROM inv.mtl_material_transactions mt
                                 WHERE TRANSACTION_SET_ID IN (46645051))
GROUP BY TRANSACTION_ID
  HAVING COUNT (*) > 3
ORDER BY 2 DESC;

-- Service Desk 562355
delete (
select a.* from xla.xla_ae_lines a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (46645051))) 
)
);

-- Service Desk 562355
delete (
select a.* from xla.xla_ae_line_acs a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (46645051))) 
)
);

-- Service Desk 562355
delete (
select a.* from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (46645051)))
);

-- Service Desk 562355
delete (
select a.* from xla.xla_events a 
where entity_id in 
(select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt 
where transaction_set_id in (46645051)))
);

-- Service Desk 562355
delete (
select * from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt 
where transaction_set_id in (46645051))
);

-----------------------------------------------------

-- Service Desk 562355
delete (
select * from inv.MTL_TRANSACTION_ACCOUNTS 
where 1=1 
and TRANSACTION_ID in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (46645051))
);


-- Service Desk 562355          
update inv.mtl_material_transactions
set costed_flag = 'N'
where 1=1
and transaction_Set_id in (46645051);

--======================================================================================

select TRANSACTION_ID, count(*) from inv.MTL_TRANSACTION_ACCOUNTS a 
where 1=1
and TRANSACTION_ID in (select TRANSACTION_ID from inv.mtl_material_transactions mt 
                       where TRANSACTION_SET_ID in (46645051) )
group by TRANSACTION_ID
having count(*) > 3
order by 2 desc;  


-- Servicee Desk #562355   
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

-- Servicee Desk #562355
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

-- Servicee Desk #562355 
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
                WHERE TRANSACTION_TYPE_ID = 803 --54        -- Int Order Direct Ship
                      AND NOT EXISTS
                             (SELECT 1
                                FROM MTL_TRANSACTION_ACCOUNTS MTA
                               WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
                      AND transaction_date BETWEEN TO_DATE ('01112019',
                                                            'ddmmyyyy')
                                               AND TO_DATE ('01122019',
                                                            'ddmmyyyy'));
			
/* Formatted (QP5 v5.326) Servicee Desk  Mihail.Vasiljev */
  SELECT COUNT (te.entity_id), te.entity_id, te.SOURCE_ID_INT_1 --ccid.segment2
    FROM xla.xla_transaction_entities te,
         xla.xla_ae_headers          aeh,
         xla.xla_ae_lines            ael,
         gl_code_combinations        ccid
   WHERE     te.entity_code = 'MTL_ACCOUNTING_EVENTS'
         AND te.application_id = 707
         AND aeh.entity_id = te.entity_id
         AND ael.ae_header_id = aeh.ae_header_id
         AND ccid.code_combination_id = ael.code_combination_id
         AND ael.accounted_dr != 0
         AND transaction_number IN (SELECT TO_CHAR (transaction_id)
                                      FROM inv.mtl_material_transactions mt
                                     WHERE transaction_set_id IN (39302526,
                                                                  39297681,
                                                                  39297764,
                                                                  39302526))
         AND AE_LINE_NUM = 1
  HAVING COUNT (te.entity_id) > 1
GROUP BY te.entity_id, te.SOURCE_ID_INT_1


-- Service Desk 562355
delete (
select a.* from xla.xla_ae_lines a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in ('39302559','39297700')) 
)
);

-- Service Desk 562355
delete (
select a.* from xla.xla_ae_line_acs a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in ('39302559','39297700')) 
)
);

-- Service Desk 562355
delete (
select a.* from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in ('39302559','39297700'))
);

-- Service Desk 562355
delete (
select a.* from xla.xla_events a 
where entity_id in 
(select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in ('39302559','39297700'))
);

-- Service Desk 562355
delete (
select * from xla.xla_transaction_entities where transaction_number in ('39302559','39297700')
);

-----------------------------------------------------

-- Service Desk 562355
delete (
select * from inv.MTL_TRANSACTION_ACCOUNTS 
where 1=1 
and TRANSACTION_ID in ('39302559','39297700')
);


-- Service Desk 562355          
update inv.mtl_material_transactions
set costed_flag = 'N'
where 1=1
and transaction_id in ('39302559','39297700');

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


/* Delete 0003 Variance zero accounting*/ 
DELETE FROM INV.MTL_TRANSACTION_ACCOUNTS
      WHERE     TRANSACTION_ID IN (SELECT TO_CHAR (transaction_id)
                                     FROM inv.mtl_material_transactions mt
                                    WHERE transaction_set_id IN (37170937,
                                                                 37170857,
                                                                 37170736,
                                                                 37171115,
                                                                 37170779))
            AND BASE_TRANSACTION_VALUE = 0
