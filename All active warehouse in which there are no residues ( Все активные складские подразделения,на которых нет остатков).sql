/* Все активные складские подразделения,на которых нет остатков*/
SELECT DISTINCT organization_id, secondary_inventory_name
  FROM apps.mtl_secondary_inventories si
 WHERE     NOT EXISTS
               (SELECT 1
                  FROM apps.mtl_onhand_quantities oh
                 WHERE     oh.organization_id = si.organization_id
                       AND oh.subinventory_code = si.secondary_inventory_name)
       AND si.disable_date IS NULL