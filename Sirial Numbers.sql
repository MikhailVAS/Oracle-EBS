/* Serch s/n */
  SELECT DISTINCT ser.serial_number,
                  msib.SEGMENT1,
                  mtln.LOT_NUMBER,
                  mt.INVENTORY_ITEM_ID,
                  TRX_SOURCE_LINE_ID          --, , mtln.* --LOT_NUMBER--,mt.*
    FROM inv.mtl_material_transactions mt,
         inv.mtl_transaction_lot_numbers mtln,
         inv.mtl_unit_transactions     ser,
         inv.mtl_system_items_b        msib
   -- ,INV.MTL_SERIAL_NUMBERS mtsn
   WHERE                       --  mt.TRANSACTION_SET_ID IN ('30980315')   AND
        mtln .TRANSACTION_ID = mt.TRANSACTION_ID
         AND mtln.SERIAL_TRANSACTION_ID = ser.TRANSACTION_ID(+)
         AND msib.INVENTORY_ITEM_ID = mt.INVENTORY_ITEM_ID
         AND TRX_SOURCE_LINE_ID IN ('782317',
                                    '782286')
ORDER BY TRX_SOURCE_LINE_ID DESC

/* Clear Block s/n */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE 1 = 1 AND serial_number IN ('862716039744998')

/* Serch Block s/n*/
SELECT group_mark_id,
       line_mark_id,
       lot_line_mark_id,
       RESERVATION_ID
  FROM inv.mtl_serial_numbers
 WHERE     1 = 1
       AND serial_number IN ('8611950309999999',
                             '862716039999998')
					
/* Serch Block s/n*/
SELECT group_mark_id,
       line_mark_id,
       lot_line_mark_id,
       RESERVATION_ID
  FROM inv.mtl_serial_numbers
 WHERE     1 = 1
       AND serial_number BETWEEN '040487002' and '040487031'
       
/*  Which documents have serial numbers 
    В каких документах фигурирует серийный номер */
  SELECT DISTINCT
         mmt.transaction_id,
         NVL (
            TRUNC (TO_DATE (mmt.attribute13, 'yyyy.mm.dd hh24:mi:ss'), 'ddd'),
            TRUNC (mmt.transaction_date, 'ddd'))
            AS actiondate,
         mmt.creation_date,
         msib.segment1,
         msib.description,
         mtln.lot_number,
         mtt.transaction_type_name,
         mmt.transaction_type_id   AS ttid,
         mmt.inventory_item_id     AS iiid,
         mmt.shipment_number       AS ship_n,
         mmt.subinventory_code     AS sub_code,
         mtln.transaction_quantity AS tr_q,
         mmt.transaction_source_name AS tr_s_nam,
         mmt.attribute14           AS a14,
         mmt.attribute15           AS a15
    FROM inv.mtl_material_transactions mmt
         JOIN inv.mtl_transaction_types mtt
            ON mtt.transaction_type_id = mmt.transaction_type_id
         JOIN inv.mtl_transaction_lot_numbers mtln
            ON mmt.transaction_id = mtln.transaction_id
         LEFT JOIN inv.mtl_transaction_accounts mta
            ON mta.transaction_id = mmt.transaction_id
         JOIN inv.mtl_system_items_b msib
            ON     msib.inventory_item_id = mmt.inventory_item_id
               AND msib.organization_id = mmt.organization_id
         LEFT JOIN inv.mtl_unit_transactions mut
            ON mut.transaction_id = mtln.serial_transaction_id
   WHERE 1 = 1 AND mut.serial_number BETWEEN '040487002' AND '040487031' -- OLD S/N
ORDER BY actiondate, mmt.transaction_id

/*Find old  serial number
Поиск старого серийного номера */
SELECT a.*
  FROM inv.mtl_serial_numbers a
 WHERE 1 = 1 AND serial_number BETWEEN '040487002' AND '040487031'  -- OLD S/N


/* LOT , CURRENT_SUBINVENTORY , CRG_ID , Quantity , Price */
  SELECT DISTINCT msib.segment1 AS item_code,
                  mst.description,
                  a.lot_number,
                  a.CURRENT_SUBINVENTORY_CODE,
                  a.CURRENT_ORGANIZATION_ID,
                  COUNT (*)   AS "Количество",
                  apps.xxtg_inv_common_pkg.get_item_cost (
                     a.current_organization_id,
                     a.current_subinventory_code,
                     a.inventory_item_id,
                     a.lot_number)
                     AS "Цена"
    FROM inv.mtl_serial_numbers a,
         inv.mtl_system_items_b msib,
         inv.mtl_system_items_tl mst
   WHERE     a.serial_number BETWEEN '040487002' AND '040487031'
         AND a.current_status = 3
         AND a.inventory_item_id = msib.inventory_item_id
         AND msib.inventory_item_id = mst.inventory_item_id
         AND a.current_organization_id = msib.organization_id
         AND msib.organization_id = mst.organization_id
         AND mst.language = 'RU'
GROUP BY msib.segment1,
         mst.description,
         a.lot_number,
         a.CURRENT_SUBINVENTORY_CODE,
         a.CURRENT_ORGANIZATION_ID,
         a.inventory_item_id

     
     
     	