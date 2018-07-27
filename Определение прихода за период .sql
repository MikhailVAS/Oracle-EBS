
  SELECT DISTINCT msib.segment1        AS "Баркод Item-a",
                  msib.DESCRIPTION     AS "Нименование Item-a",
                  mtlnn.lot_number     AS "Номер партии",
                  ROUND(mta.rate_or_Amount,2)   AS "Цена за еденицу",
                  mt.transaction_quantity   AS "Кол-во",
                  mt.SHIPMENT_NUMBER   AS "Номер накладной",
                  mtlnn.TRANSACTION_DATE AS "Дата прихода"
    FROM inv.mtl_transaction_lot_numbers mtlnn,
         bom.cst_inv_layers            cil,
         inv.mtl_material_transactions mt,
         inv.mtl_system_items_b        msib,
         inv.MTL_TRANSACTION_ACCOUNTS  mta
   WHERE     1 = 1
         AND cil.create_transaction_id = mt.transaction_id
         AND cil.organization_id = mt.organization_id
         AND cil.inventory_item_id = mt.inventory_item_id
         AND msib.inventory_item_id = cil.inventory_item_id
         AND mt.transaction_quantity >= 0
         AND mtlnn.transaction_id = mt.transaction_id
         AND mt.transaction_date BETWEEN '01/JAN/12' AND '08/SEP/17' -- За пять лет
         AND mta.TRANSACTION_ID = mt.transaction_id
ORDER BY msib.segment1