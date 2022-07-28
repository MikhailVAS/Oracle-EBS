/* Formatted on 03.08.2018 13:20:12 (QP5 v5.318) */
  SELECT org.ORGANIZATION_CODE,
  mt.subinventory_code,
         sub.DESCRIPTION                          subinventory_code,
         gi.name                                  group_name,mtln.lot_number
	   , SUM (mtln.primary_quantity)              qty,
         SUM (mtln.primary_quantity * uc.UNIT_COST) cost 
    FROM APPS.mtl_material_transactions  mt,
         APPS.MTL_SECONDARY_INVENTORIES  sub,
         APPS.mtl_transaction_lot_numbers mtln,
         APPS.mtl_system_items_vl        msi,
         APPS.mtl_parameters             org,
         APPS.XXTG_GROUP_OF_ITEM_V       gi,
         xxtg.xxtg_unit_cost             uc
   WHERE     msi.organization_id = mt.organization_id
         AND msi.inventory_item_id = mt.inventory_item_id
         AND sub.organization_id = mt.organization_id
         AND sub.SECONDARY_INVENTORY_NAME = mt.subinventory_code
         AND mt.TRANSACTION_DATE < TO_DATE ('01072018', 'ddmmyyyy')
         AND org.organization_id = mt.organization_id
         AND org.organization_id = 84
         AND sub.secondary_inventory_name = 'РЭБЗ'
         --AND MSI.ATTRIBUTE6 IN ('1013002790','1001003')
         AND MSI.SEGMENT1 IN ('1013002790')
         AND gi.code = MSI.ATTRIBUTE6
         AND uc.INVENTORY_ITEM_ID = msi.inventory_item_id
         AND uc.LOT_NUMBER = mtln.LOT_NUMBER
         AND uc.CURRENCY_CODE = 'BYN'
         AND mtln.transaction_id = mt.transaction_id
         AND mtln.organization_id = mt.organization_id
--   and TRANSACTION_QUANTITY !=0
/* */ GROUP BY org.ORGANIZATION_CODE,mt.subinventory_code, sub.DESCRIPTION, gi.name ,mtln.lot_number


--РЭБЗ  ЧТУП "Экономбизнес"
--РЭБЗКНСГ  Экономбизнес ЧТУП РБ
--РЭБЗинв ЧТУП "Экономбизнес" (ИНВ)
 4349 Легович Иван Геннадьевич (уволен)

SELECT * FROM  APPS.MTL_SECONDARY_INVENTORIES   WHERE 
DESCRIPTION like '%Экономбизнес%'
--secondary_inventory_name = '4349'

SELECT * FROM      APPS.mtl_system_items_vl  