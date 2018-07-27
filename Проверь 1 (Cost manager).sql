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