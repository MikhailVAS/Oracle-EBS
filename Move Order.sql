/* Formatted on (QP5 v5.388) Service Desk 642309 Mihail.Vasiljev */
UPDATE MTL_TXN_REQUEST_LINES
   SET FROM_LOCATOR_ID =
           (SELECT INVENTORY_LOCATION_ID
              FROM mtl_item_locations_kfv
             WHERE CONCATENATED_SEGMENTS = '2342.Демонтаж.7439')
WHERE HEADER_ID = 3908071 -- MOVE_ORDER_HEADER_ID


--SELECT *
--  FROM mtl_txn_request_lines mtrl
-- WHERE mtrl.header_id = (SELECT HEADER_ID
--                           FROM mtl_txn_request_headers mtrh
--                          WHERE REQUEST_NUMBER = '2239355')

/* Formatted on 22.06.2020 11:32:10 (QP5 v5.326) Service Desk 397143 Mihail.Vasiljev */
UPDATE mtl_txn_request_lines mtrl
   SET DATE_REQUIRED =
           TO_DATE ('22.06.2020 16:03:25', 'dd.mm.yyyy hh24:mi:ss'),
       STATUS_DATE = TO_DATE ('22.06.2020 16:03:25', 'dd.mm.yyyy hh24:mi:ss')
 WHERE mtrl.header_id = (SELECT HEADER_ID
                           FROM mtl_txn_request_headers mtrh
                          WHERE REQUEST_NUMBER = '2239355')
                          

--SELECT *
--  FROM mtl_txn_request_headers mtrh
-- WHERE REQUEST_NUMBER = '2239355'
                          
/* Formatted on 22.06.2020 11:27:59 (QP5 v5.326) Service Desk 397143 Mihail.Vasiljev */
UPDATE mtl_txn_request_headers mtrh
   SET DATE_REQUIRED =
           TO_DATE ('22.06.2020 16:03:25', 'dd.mm.yyyy hh24:mi:ss'),
       STATUS_DATE = TO_DATE ('22.06.2020', 'dd.mm.yyyy')
 WHERE REQUEST_NUMBER = '2239355'
 
 /* Formatted on 22.06.2020 11:27:59 (QP5 v5.326) Service Desk 397143 Mihail.Vasiljev */
UPDATE mtl_txn_request_headers mtrh
   SET DATE_REQUIRED =
           TO_DATE ('11.06.2020 16:03:25', 'dd.mm.yyyy hh24:mi:ss'),
       STATUS_DATE = TO_DATE ('11.06.2020', 'dd.mm.yyyy')
 WHERE REQUEST_NUMBER = '2230750'
 
/* Formatted on 28.04.2021 20:44:07 (QP5 v5.326) Service Desk 481937 Mihail.Vasiljev */
UPDATE mtl_txn_request_lines mtrl
   SET LOT_NUMBER = '210329Демонтаж422058',
       SERIAL_NUMBER_START = 'VIRT6647',
       SERIAL_NUMBER_END = 'VIRT6647'
WHERE     mtrl.header_id = (SELECT HEADER_ID
                               FROM mtl_txn_request_headers mtrh
                              WHERE REQUEST_NUMBER = '2502350')
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1051000126')

/* Formatted on 05.05.2020 18:26:38 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT wnd.delivery_id,
       wnd.name                       delivery_name,
       wnd.initial_pickup_location_id,
       mtrh.request_number            mo_number,
       mtrl.line_number               mo_line_number,
       mtrl.line_id                   mo_line_id,
       mtrl.from_subinventory_code,
       mtrl.to_subinventory_code,
       mtrl.lot_number,
       mtrl.serial_number_start,
       mtrl.serial_number_end,
       mtrl.uom_code,
       mtrl.quantity,
       mtrl.quantity_delivered,
       mtrl.quantity_detailed,
       wdd.source_header_number       so_order_number,
       oola.line_number               so_line_number,
       wdd.source_header_id           so_header_id,
       wdd.source_line_id             so_line_id,
       wdd.shipping_instructions,
       wdd.inventory_item_id,
       wdd.requested_quantity_uom,
       msi.description                item_description,
       msi.revision_qty_control_code,
       wdd.ship_method_code           carrier,
       wdd.shipment_priority_code     priority,
       wdd.organization_id,
       wdd.released_status,
       wdd.source_code
  FROM APPS.mtl_system_items_vl       msi,
       APPS.oe_order_lines_all        oola,
       APPS.mtl_txn_request_lines     mtrl,
       APPS.mtl_txn_request_headers   mtrh,
       APPS.wsh_delivery_details      wdd,
       APPS.wsh_delivery_assignments  wda,
       APPS.wsh_new_deliveries        wnd
 WHERE     1=1 --wnd.delivery_id = 18910
       AND wda.delivery_id = wnd.delivery_id(+)
       AND wdd.delivery_detail_id = wda.delivery_detail_id
       AND wdd.move_order_line_id = mtrl.line_id
       AND mtrl.header_id = mtrh.header_id
       AND wdd.inventory_item_id = msi.inventory_item_id(+)
       AND wdd.organization_id = msi.organization_id(+)
       AND wdd.source_line_id = oola.line_id
       AND wdd.source_header_id = oola.header_id
--       AND mtrl.HEADER_ID  = '2190707' -- Move Order 

/* query for linking move orders with the pending table: */
SELECT mmtt.transaction_temp_id,
       tol.organization_id,
       toh.request_number,
       toh.header_id,
       tol.line_number,
       tol.line_id,
       tol.inventory_item_id,
       toh.description,
       toh.move_order_type,
       tol.line_status,
       tol.quantity,
       tol.quantity_delivered,
       tol.quantity_detailed
  FROM mtl_txn_request_headers         toh,
       mtl_txn_request_lines           tol,
       mtl_material_transactions_temp  mmtt
 WHERE     toh.header_id = tol.header_id
       AND toh.organization_id = tol.organization_id
       AND tol.line_id = mmtt.move_order_line_id;
                    
/* query linking MTL_MATERIAL_TRANSACTIONS to the move order */
SELECT mmt.transaction_id,
       tol.organization_id,
       toh.request_number,
       toh.header_id,
       tol.line_number,
       tol.line_id,
       tol.inventory_item_id,
       toh.description,
       toh.move_order_type,
       tol.line_status,
       tol.quantity,
       tol.quantity_delivered,
       tol.quantity_detailed
  FROM mtl_txn_request_headers    toh,
       mtl_txn_request_lines      tol,
       mtl_material_transactions  mmt
 WHERE     toh.header_id = tol.header_id
       AND toh.organization_id = tol.organization_id
       AND tol.line_id = mmt.move_order_line_id
       AND toh.request_number = '280765'

/* Find all move order lines with transaction quantity 0*/
SELECT MTRL.QUANTITY,
       (SELECT La.ordered_quantity
          FROM ont.OE_ORDER_LINES_all La, ont.oe_order_headers_all h
         WHERE     La.header_id = H.HEADER_ID
               AND La.header_id IN
                       (SELECT ha.header_id
                          FROM ont.oe_order_headers_all  ha,
                               ont.OE_ORDER_LINES_all    LaL
                         WHERE     H.HEADER_ID = LaL.header_id
                               AND ha.order_number IN (280765)) -- Move Order 280765 Internal.ORDER ENTRY
               AND MTRL.TXN_SOURCE_LINE_ID = La.LINE_ID) AS "BackUp_By_SalOrde_Qt"
  FROM MTL_TXN_REQUEST_LINES MTRL
 WHERE     LINE_ID IN (SELECT MOVE_ORDER_LINE_ID
                         FROM WSH_DELIVERY_DETAILS
                        WHERE SOURCE_HEADER_NUMBER = '280765') -- Move Order 280765 Internal.ORDER ENTRY
                        AND MTRL.QUANTITY = '0'

/* Update to correct quantity all move order lines with transaction quantity 0 */
UPDATE MTL_TXN_REQUEST_LINES MTRL
   SET QUANTITY = 
           (SELECT La.ordered_quantity
              FROM ont.OE_ORDER_LINES_all La, ont.oe_order_headers_all h
             WHERE     La.header_id = H.HEADER_ID
                   AND La.header_id IN
                           (SELECT ha.header_id
                              FROM ont.oe_order_headers_all  ha,
                                   ont.OE_ORDER_LINES_all    LaL
                             WHERE     H.HEADER_ID = LaL.header_id
                                   AND ha.order_number IN (280765)) -- Move Order 280765 Internal.ORDER ENTRY
                   AND MTRL.TXN_SOURCE_LINE_ID = La.LINE_ID)
--        ,PRIMARY_QUANTITY = 
--        (SELECT La.ordered_quantity
--              FROM ont.OE_ORDER_LINES_all La, ont.oe_order_headers_all h
--             WHERE     La.header_id = H.HEADER_ID
--                   AND La.header_id IN
--                           (SELECT ha.header_id
--                              FROM ont.oe_order_headers_all  ha,
--                                   ont.OE_ORDER_LINES_all    LaL
--                             WHERE     H.HEADER_ID = LaL.header_id
--                                   AND ha.order_number IN (280765))
--                  AND MTRL.TXN_SOURCE_LINE_ID = La.LINE_ID) 
 ,QUANTITY_DETAILED =
        (SELECT La.ordered_quantity
              FROM ont.OE_ORDER_LINES_all La, ont.oe_order_headers_all h
             WHERE     La.header_id = H.HEADER_ID
                   AND La.header_id IN
                           (SELECT ha.header_id
                              FROM ont.oe_order_headers_all  ha,
                                   ont.OE_ORDER_LINES_all    LaL
                             WHERE     H.HEADER_ID = LaL.header_id
                                   AND ha.order_number IN (280765))
                  AND MTRL.TXN_SOURCE_LINE_ID = La.LINE_ID)
 WHERE     LINE_ID IN (SELECT MOVE_ORDER_LINE_ID
                         FROM WSH_DELIVERY_DETAILS
                        WHERE SOURCE_HEADER_NUMBER = '280765') -- Move Order 280765 Internal.ORDER ENTRY
       AND MTRL.QUANTITY = '0'