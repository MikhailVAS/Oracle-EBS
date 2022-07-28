/* Formatted on (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE xxtg.xxtg_oe_ship_hdr
   SET user_name = NULL,
       audsid = NULL,
       sid = NULL,
       serial = NULL
 WHERE ship_id IN (40440706)


/* Formatted on (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT user_name,
       audsid,
       sid,
       serial
  FROM xxtg.xxtg_oe_ship_hdr
 WHERE 1 = 1 AND ship_id IN (40440706)

 SELECT *
  FROM apps.XXTG_OE_SHIP_LINE    osl,
       apps.XXTG_OE_SHIP_HDR     osh,
       xxtg.XXTG_OE_SHIP_DETAIL  shp
 WHERE     osl.ship_id = osh.ship_id
       AND osl.ship_id = shp.ship_id
       AND osl.line_id = shp.line_id
       AND osh.SHIP_ID IN ('44801996', '44801978')

 --====== 487554 Необходимо объединить накладные ПХ 0955486 и ПХ 0955486. ======

/* Formatted on 21.05.2021 9:31:04 (QP5 v5.326) Service Desk 487554 Mihail.Vasiljev */
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET SHIPMENT_NUMBER = 'ПХ 0955486', TRANSACTION_SET_ID = '44801978'
WHERE SHIPMENT_NUMBER = 'ПХ 0955486.'

/* Formatted on 21.05.2021 12:24:38 (QP5 v5.326) Service Desk 487554 Mihail.Vasiljev */
UPDATE apps.XXTG_OE_SHIP_HDR
   SET SHIP_ID = '44801978', TTN_NUMBER = 'ПХ 0955486'
WHERE SHIP_ID = '44801996'
           
/* Formatted on 21.05.2021 12:24:28 (QP5 v5.326) Service Desk 487554 Mihail.Vasiljev */
UPDATE apps.XXTG_OE_SHIP_LINE
   SET SHIP_ID = '44801978'
WHERE SHIP_ID = '44801996' AND OE_LINE_ID = '1437709'
          
/* Formatted on 21.05.2021 12:26:03 (QP5 v5.326) Service Desk 487554 Mihail.Vasiljev */
UPDATE xxtg.XXTG_OE_SHIP_DETAIL
   SET SHIP_ID = '44801978'
WHERE SHIP_ID = '44801996'  AND  LINE_ID = '656424'

 --=============================================================================