/* Formatted on 06.10.2021 12:44:03 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT INVENTORY_LOCATION_ID,
       INVENTORY_ITEM_ID,
       SUBINVENTORY_CODE,
       SEGMENT7 || '.' || SEGMENT1 || '.' || SEGMENT8     AS "LOCATOR"
  FROM mtl_item_locations mil
 WHERE SUBINVENTORY_CODE = 7155 AND SEGMENT7 = '4306'
 
 SELECT *
  FROM mtl_item_locations_kfv
 WHERE INVENTORY_LOCATION_ID = '5887'
 
 SUBINVENTORY_CODE = 7003
 SEGMENT1 = 'Стройка'
 SEGMENT7 = '4306'
 SEGMENT8 = 'SEGMENT8'
 4306.Стройка.7003 
 
 /* Formatted on  (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE mtl_material_transactions
   SET LOCATOR_ID =
           (SELECT INVENTORY_LOCATION_ID
              FROM mtl_item_locations_kfv
             WHERE CONCATENATED_SEGMENTS = 'ФРО Минск.Ремонт.6638')
--SELECT * FROM mtl_material_transactions
 WHERE TRANSACTION_ID IN ('45376015')
 
 /* Formatted on  (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers sn
   SET CURRENT_LOCATOR_ID =
           (SELECT INVENTORY_LOCATION_ID
              FROM mtl_item_locations_kfv
             WHERE CONCATENATED_SEGMENTS = 'ФРО Минск.Ремонт.6638')
-- SELECT * FROM inv.mtl_serial_numbers sn
 WHERE     serial_number = '020KWPW08C003026'
       AND sn.INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                     FROM inv.mtl_system_items_b ctxh
                                    WHERE ctxh.SEGMENT1 = '1052005769')
             
      
/* Formatted on  (QP5 v5.326) Service Desk  Mihail.Vasiljev */    
UPDATE APPS.MTL_ONHAND_QUANTITIES_DETAIL
   SET LOCATOR_ID =
           (SELECT INVENTORY_LOCATION_ID
              FROM mtl_item_locations_kfv
             WHERE CONCATENATED_SEGMENTS = 'ФРО Минск.Ремонт.6638')
 SELECT * FROM  APPS.MTL_ONHAND_QUANTITIES_DETAIL
 WHERE     1=1 --ONHAND_QUANTITIES_ID IN (5304812, 5304813)
       AND OWNING_ORGANIZATION_ID = '1369'
       AND CREATE_TRANSACTION_ID = '45376015'


SELECT * FROM mtl_material_transactions WHERE --TRANSACTION_ID in (45443571)
LOCATOR_ID = 4603


SELECT
     substr(matsub.secondary_inventory_name,1,10) "SubInv",
     substr(matsub.description,1,20) "Descripton",
     substr(matloc.description,1,20) "Locator",
         substr(matloc.inventory_location_type,1,1) "Locator Type",
     substr(matloc.inventory_location_ID,1,4) "Locator ID"
FROM
     mtl_secondary_inventories a1,
     mtl_item_locations a2
WHERE
     a1.secondary_inventory_name LIKE '&XX_SUBINVENTORY%'
    AND a1.organization_id = 207
    AND a2.organization_id = 207
    AND a1.secondary_inventory_name = a2.subinventory_code
   
   
               SELECT
            mp.operating_unit, 
            mp.organization_code,
             msib.segment1 item_number,
             msib.description,
             msib.inventory_item_status_code Item_Status,
             mms2.status_code Sub_Status,
             mil.segment1 Locator,
             mms3.status_code location_status,
             mln.lot_number,
             msib.primary_uom_code,
             SUM (mpoq.primary_transaction_quantity) onhand_qty,
             mln.organization_id,
             TO_CHAR(mln.expiration_date,'DD-MON-RRRR') expiration_date,
             mms1.status_code Lot_status,
             mln.inventory_item_id,
             mil.inventory_location_id
        FROM mtl_system_items_b msib,
               mtl_item_status mis,
               mtl_item_locations mil,
             org_organization_definitions mp,
             mtl_lot_numbers mln,
             mtl_onhand_quantities_detail mpoq,
             mtl_material_statuses_tl mms1,
             mtl_material_statuses_tl mms2,
             mtl_material_statuses_tl mms3,
             mtl_secondary_inventories msi
       WHERE     1 = 1
             AND mln.inventory_item_id = msib.inventory_item_id
             AND mln.organization_id = msib.organization_id
             AND mis.inventory_item_status_code=msib.inventory_item_status_code
             AND msib.organization_id = mp.organization_id
             AND mil.inventory_location_id = mpoq.locator_id
             AND mil.organization_id = mln.organization_id
             AND mln.inventory_item_id = mpoq.inventory_item_id(+)
             AND mln.organization_id = mpoq.organization_id(+)
             AND mln.lot_number = mpoq.lot_number(+)
             AND mpoq.organization_id = msi.organization_id
             AND mpoq.subinventory_code = msi.secondary_inventory_name
             AND mms1.status_id = mln.status_id
             AND mms2.status_id=  msi.status_id
             AND mms3.status_id=  mil.status_id
             AND mms1.language=USERENV('LANG')
             AND mms2.language=USERENV('LANG')
             AND mms3.language=USERENV('LANG')
             AND mln.organization_id =:p_organization_id
             AND msib.inventory_item_id = :p_inventory_item_id
    GROUP BY mp.organization_code,
             msib.segment1,
             msib.description,
             mln.inventory_item_id,
             mln.organization_id,
             mln.lot_number,
             mil.inventory_location_id,
             msi.secondary_inventory_name,
             msib.inventory_item_status_code,
             msi.attribute6,
             mms1.status_code,
            mms2.status_code,
            mms3.status_code,
             msi.attribute4,
             mil.segment1,
             msib.primary_uom_code,
               (mln.expiration_date - sysdate) ,
             msib.shelf_life_days,
             TO_CHAR(mln.expiration_date,'DD-MON-RRRR'),
             mln.status_id,
             mpoq.locator_id,
             mp.operating_unit,
             mln.attribute14 ,
msi.reservable_type;

 
/* Formatted on 06.10.2021 12:32:33 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM mtl_item_locations mil
 WHERE 1=1 --INVENTORY_LOCATION_ID = 4603
 AND INVENTORY_ITEM_ID = '497713'
 
