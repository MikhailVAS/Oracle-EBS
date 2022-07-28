/* Clear status Order Shipment */
UPDATE XXTG.xxtg_oe_ship_hdr
   SET inv_trans = NULL
 WHERE ship_id = 34350603
 
 
/* Clear SHIPPED_QUANTITY in  Order Shipment*/
UPDATE ont.oe_order_lines_all
   SET SHIPPED_QUANTITY = NULL
 WHERE header_id IN (280847)

 /* Find all normal transaction in  XXTG_OE_SHIP_LINE */
UPDATE  
   ont.OE_ORDER_LINES_all La 
   SET 
--   SHIPPED_QUANTITY 
   SHIPPED_QUANTITY = (SELECT QUANTITY
  FROM apps.XXTG_OE_SHIP_LINE
 WHERE ship_id = 47426599  AND MISC_TRANS IS NOT NULL
 AND OE_LINE_ID = La.LINE_ID) 
 WHERE    La.header_id IN
               (SELECT ha.header_id
                  FROM ont.oe_order_headers_all  ha,
                       ont.OE_ORDER_LINES_all    LaL
                 WHERE     1 = 1
                       AND Ha.HEADER_ID = LaL.header_id
                       AND ha.order_number IN (281042))
       AND LINE_ID IN (SELECT OE_LINE_ID
                         FROM apps.XXTG_OE_SHIP_LINE
                        WHERE ship_id = 47426599 AND MISC_TRANS IS NOT NULL)