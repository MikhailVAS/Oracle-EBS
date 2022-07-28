
/* Shippeng Transaction Deliveri info */
SELECT wda.delivery_id,
       wdd.delivery_detail_id,
       NAME as TTN,
       TRACKING_NUMBER as IR_Number,
       wnd.organization_id,
       (SELECT DISTINCT SEGMENT1
          FROM inv.mtl_system_items_b a
         WHERE a.INVENTORY_ITEM_ID = wdd.INVENTORY_ITEM_ID)
           AS Item_Code,
       ITEM_DESCRIPTION
           LOT_NUMBER
  FROM APPS.wsh_new_deliveries            wnd,
       APPS.wsh_delivery_assignments      wda,
       APPS.wsh_delivery_details          wdd,
       APPS.ORG_ORGANIZATION_DEFINITIONS  inv
 WHERE     wnd.delivery_id = wda.delivery_id
       AND wda.delivery_detail_id = wdd.delivery_detail_id
       AND wnd.organization_id = inv.ORGANIZATION_ID
       AND NAME in ('ВЛ 2889992')
	   
/* Find operation type in Internal Requsition by TTN*/
SELECT REFERENCE_NUM,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE4,
       SOURCE_ORGANIZATION_ID,
       SOURCE_SUBINVENTORY,
       DESTINATION_ORGANIZATION_ID,
       DESTINATION_SUBINVENTORY
  FROM po.PO_REQUISITION_LINES_all l
 WHERE REQUISITION_HEADER_ID IN
           (SELECT REQUISITION_HEADER_ID
              FROM PO.PO_REQUISITION_HEADERS_all
             WHERE SEGMENT1 IN
                       (SELECT TRACKING_NUMBER
                          FROM APPS.wsh_new_deliveries        wnd,
                               APPS.wsh_delivery_assignments  wda,
                               APPS.wsh_delivery_details      wdd
                         WHERE     wnd.delivery_id = wda.delivery_id
                               AND wda.delivery_detail_id =
                                   wdd.delivery_detail_id
                               AND NAME IN ('ВЛ 2889992')))
                                  
                                  
/* Find operation type and ORG, Subinventory in IR by Internal Requsition*/
SELECT REFERENCE_NUM,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE4,
       SOURCE_ORGANIZATION_ID,
       SOURCE_SUBINVENTORY,
       DESTINATION_ORGANIZATION_ID,
       DESTINATION_SUBINVENTORY
  FROM po.PO_REQUISITION_LINES_all l
 WHERE REQUISITION_HEADER_ID IN
           (SELECT REQUISITION_HEADER_ID
                                   FROM PO.PO_REQUISITION_HEADERS_all
                                  WHERE SEGMENT1 IN (:IR))