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