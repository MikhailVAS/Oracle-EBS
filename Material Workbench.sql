 /* Вычисляет значения на форме Наличное/Доступное процедура inv_quantity_tree_pub.query_quantities,
  но внутри процедуры еще есть код который еще отдельно смотрит на APPS.MTL_RESERVATIONS по ID документа */
  
DELETE APPS.MTL_RESERVATIONS
 WHERE RESERVATION_ID = :RESERVATION_ID
 

SELECT *
  FROM MTL_ONHAND_QUANTITIES
 WHERE     INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013520419')
       AND SUBINVENTORY_CODE IN ('ФЛГ5_ЦО', 'ФЛГ11Scrap')
 

SELECT *
  FROM MTL_ONHAND_QUANTITIES_DETAIL
 WHERE     INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013520419')
       AND SUBINVENTORY_CODE IN ('ФЛГ5_ЦО', 'ФЛГ11Scrap')