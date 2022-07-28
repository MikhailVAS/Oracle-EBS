SELECT msi.INVENTORY_ITEM_ID, msi.segment1 Item, msi.description, v.attribute1 MID
     FROM fnd_flex_values_vl v, fnd_flex_value_sets s, mtl_system_items_b msi
    WHERE v.flex_value_set_id = s.flex_value_set_id
          AND s.flex_value_set_name = 'XXTG_DISTANT_ID_ITEMS'
          AND v.enabled_flag = 'Y'
          AND msi.segment1 = v.flex_value
          AND organization_id = 82


--========================= Update DID by old Transaction  ========================
/* Проверка */
SELECT DISTINCT ATTRIBUTE9
  FROM MTL_UNIT_TRANSACTIONS
 WHERE     SERIAL_NUMBER = '893126951038594700'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013070638')
       AND ATTRIBUTE9 IS NOT NULL;

/* Formatted on 26.07.2022 16:14:11 (QP5 v5.326) Service Desk Mihail.Vasiljev 
Update DID by old Transaction */
UPDATE inv.mtl_serial_numbers sn
   SET sn.attribute9 =
           (SELECT DISTINCT ATTRIBUTE9
              FROM MTL_UNIT_TRANSACTIONS
             WHERE     SERIAL_NUMBER = sn.SERIAL_NUMBER 
                   AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                              FROM inv.mtl_system_items_b a
                                             WHERE SEGMENT1 = '1013070638')
                   AND ATTRIBUTE9 IS NOT NULL)
 WHERE     sn.serial_number IN ('893126951038594700')
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE a.SEGMENT1 = '1013070638')
--===================================================================================

XXTG_DISTANT_ID_ITEMS