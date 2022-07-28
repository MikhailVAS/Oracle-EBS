 
 --Модуль INV — Текущее количество для позиции
 --http://apps-oracle.ru/inv_item_actual/
 
SELECT CASE moq.ORGANIZATION_ID
             WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
             WHEN 83 THEN 'BBW: Склад Бест'
             WHEN 84 THEN 'BDW: Дилеры'
             WHEN 85 THEN 'BHW: Головной офис Бест'
             WHEN 86 THEN 'BSW: Подрядчики'
             WHEN 1369 THEN 'BFC: Строительство ОС'
             ELSE 'Other warehouse'
         END
             AS "Наименованеи_организации",
         SYSDATE
             AS date_val,
         moq.inventory_item_id
             AS item_id,
         moq.subinventory_code
             AS subinventory_code,
         moq.locator_id
             AS locator_id,
         moq.lot_number
             AS lot_number,
         msi.segment1
             AS item,
         msi.primary_uom_code
             AS uom_code,
         SUM (moq.primary_transaction_quantity)
             AS actual_qty
    FROM mtl_onhand_quantities_detail moq, mtl_system_items_b msi
   WHERE     1 = 1
         -- msi
         AND msi.inventory_item_id = moq.inventory_item_id
         AND msi.organization_id = moq.organization_id
         AND moq.inventory_item_id IN (SELECT DISTINCT INVENTORY_ITEM_ID
                                         FROM mtl_system_items_b
                                        WHERE SEGMENT1 IN ('0100000246',
                                                           '0100000267',
                                                           '0100000337',
                                                           '0100000344',
                                                           '0100000345',
                                                           '0100000376',
                                                           '0100000436',
                                                           '0100000753',
                                                           '0100000754',
                                                           '0100001002',
                                                           '0100001020',
                                                           '0100001045',
                                                           '0100001063',
                                                           '0100001093',
                                                           '0100001094',
                                                           '0100001112',
                                                           '0100001115',
                                                           '0100001138',
                                                           '0100001227',
                                                           '0100001238',
                                                           '0100001252',
                                                           '0100001253'))
--and moq.organization_id    = :2
--and moq.subinventory_code  = :3
--and moq.lot_number         = :4
GROUP BY moq.organization_id,
         SYSDATE,
         moq.inventory_item_id,
         msi.segment1,
         msi.primary_uom_code,
         moq.subinventory_code,
         moq.locator_id,
         moq.lot_number
ORDER BY moq.organization_id, moq.inventory_item_id