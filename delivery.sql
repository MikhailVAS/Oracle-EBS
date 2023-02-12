/* Find all lines print TN-2 by delivery_id */
  SELECT item_description,
         uom,
         NVL (quantity, 0)              quantity,
         NVL (ROUND (price, 2), 0)      price,
         NVL (ROUND (amount, 2), 0)     amount
    --                ,nvl((select muom.unit_of_measure_tl from mtl_system_items_b msib,mtl_units_of_measure muom
    --                 where msib.ORGANIZATION_ID= 84 --:p_organization_id
    --                 and msib.inventory_item_id = inventory_item_id and rownum = 1 and muom.language = userenv('LANG') and msib.weight_uom_code = muom.uom_code),'кг') UOM_COD
    FROM apps.xxtg_waybill_line_v xa
   WHERE 1 = 1 AND delivery_id = 755565                       --:p_delivery_id
--AND ORGANIZATION_ID= 84 --:p_organization_id
ORDER BY item_description

/* Formatted on (QP5 v5.326) Service Desk 405850 Mihail.Vasiljev */
UPDATE wsh.wsh_new_deliveries
   SET name = 'БА 0948922_'
 WHERE name = 'БА 0948992'

  /* Formatted (QP5 v5.326) Service Desk 539679 Mihail.Vasiljev */
UPDATE PO.RCV_SHIPMENT_HEADERS
   SET receipt_num = '_' || receipt_num,
       WAYBILL_AIRBILL_NUM = '_' || WAYBILL_AIRBILL_NUM
 WHERE receipt_num = 'ТП 5641371'
 
 /* Formatted on (QP5 v5.326) Service Desk 431765 Mihail.Vasiljev */
UPDATE RCV_SHIPMENT_HEADERS
   SET RECEIPT_NUM = 'НХ 5594143_'
 WHERE RECEIPT_NUM = 'НХ 5594143'


Change Date
/* Formatted on  PM (QP5 v5.326) Service Desk 559741 Mihail.Vasiljev */
/* Shipping Initial_pickup_date , ULTIMATE_DROPOFF_DATE */
UPDATE wsh.wsh_new_deliveries
   SET INITIAL_PICKUP_DATE =
           TO_DATE ('21.01.2023 9:00:00', 'dd.mm.yyyy hh.mi.ss'),
       ULTIMATE_DROPOFF_DATE =
           TO_DATE ('21.01.2023 23:59:00', 'dd.mm.yyyy hh24:mi:ss')    
 WHERE name = 'ВТ 0060156';

 /* Formatted on (QP5 v5.326) Service Desk 417327 Mihail.Vasiljev */
-- 1. All assignments link to one
UPDATE WSH.WSH_DELIVERY_ASSIGNMENTS DD
   SET DELIVERY_ID =
           (SELECT DISTINCT DDA.DELIVERY_ID
              FROM WSH.WSH_DELIVERY_ASSIGNMENTS  DDA,
                   WSH.WSH_NEW_DELIVERIES        DND
             WHERE     DND.name IN ('НГ 2841171')
                   AND DDA.DELIVERY_ID = DND.DELIVERY_ID)
 WHERE DELIVERY_ID IN
           (SELECT DISTINCT TDA.DELIVERY_ID
              FROM WSH.WSH_DELIVERY_ASSIGNMENTS  TDA,
                   WSH.WSH_NEW_DELIVERIES        TND
             WHERE     TND.name IN ('798109')
                   AND TDA.DELIVERY_ID = TND.DELIVERY_ID)
                          
/* Formatted on (QP5 v5.326) Service Desk 417327 Mihail.Vasiljev */
-- 2.MTL_MATERIAL_TRANSACTIONS with one
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET transaction_set_id =
           (SELECT MIN(transaction_set_id)
              FROM INV.MTL_MATERIAL_TRANSACTIONS
             WHERE SHIPMENT_NUMBER IN ('НГ 2841171'))
 WHERE SHIPMENT_NUMBER IN ('798109')
  AND SOURCE_CODE = 'ORDER ENTRY'

/* Formatted on (QP5 v5.326) Service Desk 417327 Mihail.Vasiljev */
-- 3.MTL_MATERIAL_TRANSACTIONS with one shipment
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET SHIPMENT_NUMBER = 'НГ 2841171'
 WHERE SHIPMENT_NUMBER IN ('798109')
  AND SOURCE_CODE = 'ORDER ENTRY'
 
 
 /* Formatted on  (QP5 v5.326) Service Desk 432727 Mihail.Vasiljev */
DELETE FROM MTL_TXN_REQUEST_LINES MTRL
      WHERE line_id IN
                (SELECT wsh.move_order_line_id
                   FROM wsh_delivery_details_ob_grp_v wsh
                  WHERE source_code = 'OE' AND wsh.source_header_id = 388442)
                          
/* Formatted on (QP5 v5.326) Service Desk 432727 Mihail.Vasiljev */
DELETE FROM MTL_TXN_REQUEST_HEADERS MTRH
      WHERE HEADER_ID = 2339193
      
/* Formatted on (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE wsh.wsh_delivery_details
   SET RELEASED_STATUS = 'B', INV_INTERFACED_FLAG = 'N', MOVE_ORDER_LINE_ID = null
 WHERE delivery_detail_id IN (646874,646873)

 /* Formatted on (QP5 v5.326) Service Desk  632496 Mihail.Vasiljev */
UPDATE wsh.wsh_delivery_details
   SET RELEASED_STATUS = 'B', INV_INTERFACED_FLAG = 'N', MOVE_ORDER_LINE_ID = null
 WHERE delivery_detail_id IN (
           (SELECT DISTINCT DDA.delivery_detail_id
              FROM WSH.WSH_DELIVERY_ASSIGNMENTS  DDA,
                   WSH.WSH_NEW_DELIVERIES        DND
             WHERE     DND.name IN ('854270')
                   AND DDA.DELIVERY_ID = DND.DELIVERY_ID))

      
SELECT * FROM  wsh.wsh_delivery_details DD
--set c = 'P'
where delivery_detail_id in (646874,646873)