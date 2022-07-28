
/*All Receipt info by date_tr */
SELECT *
  FROM rcv_transactions rtv
 WHERE TRANSACTION_DATE = TO_DATE ('22.01.2019', 'dd.mm.yyyy')
 
 /* Formatted on 28.01.2019 12:07:45 (QP5 v5.318) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM rcv_shipment_lines
 WHERE SHIPMENT_LINE_ID IN (460760, 460761)
 
/* Formatted on 28.01.2019 12:09:50 (QP5 v5.318) Service Desk 270562 Mihail.Vasiljev */
/* Изменение страны в Приходном ордере*/
UPDATE APPS.rcv_shipment_lines
   SET COUNTRY_OF_ORIGIN_CODE = 'CN' --BY
 WHERE SHIPMENT_LINE_ID IN (460761)
 
 /* Formatted on 28.01.2019 11:50:40 (QP5 v5.318) Service Desk  Mihail.Vasiljev */
UPDATE APPS.rcv_transactions rtv
   SET COUNTRY_OF_ORIGIN_CODE = 'CN' --BY
 WHERE     TRANSACTION_DATE = TO_DATE ('22.01.2019', 'dd.mm.yyyy')
       AND SHIPMENT_LINE_ID IN (460761)
 
 /* Описание позиции с страной в rcv_transactions
    INPUT 
    696804
    83
    '190122ЭлкоТелеком_ООО_РБ409198'*/
SELECT msi.inventory_item_id, msi.organization_id, mlt.lot_number, l.country_of_origin_code,
      NVL(mlt.attribute1, REPLACE(REPLACE(NVL(NVL(msi.long_description, msi.description), msib.description), ter.territory_short_name, '')
                                         || NVL2(ter.territory_short_name, ', ', '') || ter.territory_short_name, ' , ', ' ')
                ) AS item_name
            ,ROW_NUMBER() OVER(PARTITION BY msi.inventory_item_id, msi.organization_id/*, mlt.lot_number*/ ORDER BY l.country_of_origin_code NULLS LAST) AS rn
        FROM mtl_system_items_tl msi
        JOIN mtl_system_items_b msib  ON msib.inventory_item_id = msi.inventory_item_id AND msib.organization_id = msi.organization_id
        JOIN mtl_lot_numbers mlt      ON mlt.inventory_item_id = msi.inventory_item_id AND mlt.organization_id = msi.organization_id AND mlt.lot_number = NVL('190122ЭлкоТелеком_ООО_РБ409199', mlt.lot_number) -- '120510Huawei_Tech.Invest002936'
        LEFT OUTER JOIN
             rcv_lot_transactions rlt ON rlt.lot_num = mlt.lot_number AND rlt.item_id = mlt.inventory_item_id
        LEFT OUTER JOIN
             rcv_transactions rt      ON rt.transaction_id = rlt.transaction_id --AND rt.transaction_type = c_deliver
        LEFT OUTER JOIN
             rcv_shipment_lines l     ON l.shipment_line_id = rt.shipment_line_id
        LEFT OUTER JOIN
             rcv_shipment_headers h   ON h.shipment_header_id = l.shipment_header_id --AND h.receipt_source_code = c_vendor
        LEFT OUTER JOIN
             fnd_territories_tl ter   ON ter.territory_code = l.country_of_origin_code AND ter.language = 'RU'
       WHERE 1=1
         AND msi.language = 'RU'
         AND msi.inventory_item_id = 696804 --6032
         AND msi.organization_id = 83 -- 85

 
 /* XXTG: Inventory Receipt Order (PO)  (Input parameter SHIPMENT_HEADER_ID)*/
SELECT tt.shipment_line_id,
       tt.transaction_id,
       tt.shipment_header_id,
       tt.item_id,
       tt.organization_id,
       tt.item,
       tt.uom_name,
       tt.flag flag,
       tt.item_description item_description,
       tt.trans_quantity trans_quantity,
       ROUND (NVL (tt.transaction_cost, 0), 2) transaction_cost,
       ROUND (tt.trans_quantity * NVL (tt.transaction_cost, 0), 2) amount,
       SUM (ROUND (tt.trans_quantity * NVL (tt.transaction_cost, 0), 2))
          OVER ()
          tot_amount
  FROM (  SELECT DISTINCT
                 rtv.shipment_line_id,
                 rtv.transaction_id,
                 rtv.shipment_header_id,
                 mtl.inventory_item_id item_id,
                 mtl.organization_id organization_id,
                 mtl.segment1 item,
                 uoml.unit_of_measure_tl uom_name,
                 CASE
                    WHEN rtv.transaction_type = 'RECEIVE'
                    THEN
                       (  NVL (rtv.quantity, 0)
                        - NVL (
                             (SELECT SUM (NVL (rt2.quantity, 0))
                                FROM RCV_TRANSACTIONS rt2
                               WHERE     1 = 1
                                     AND rt2.transaction_type =
                                            'RETURN TO VENDOR'
                                     AND rtv.transaction_id =
                                            rt2.parent_transaction_id
                                     AND EXISTS
                                            (SELECT COUNT (*)
                                               FROM RCV_TRANSACTIONS
                                              WHERE     shipment_header_id =
                                                           rt2.shipment_header_id
                                                    AND parent_transaction_id =
                                                           rt2.parent_transaction_id
                                                    AND transaction_type =
                                                           'DELIVER')
                                     AND rtv.shipment_header_id =
                                            rt2.shipment_header_id),
                             0)
                        + NVL (
                             (SELECT SUM (NVL (rt2.quantity, 0))
                                FROM RCV_TRANSACTIONS rt2
                               WHERE     1 = 1
                                     AND rt2.transaction_type = 'CORRECT'
                                     AND rtv.transaction_id =
                                            rt2.parent_transaction_id
                                     AND EXISTS
                                            (SELECT COUNT (*)
                                               FROM RCV_TRANSACTIONS
                                              WHERE     shipment_header_id =
                                                           rt2.shipment_header_id
                                                    AND parent_transaction_id =
                                                           rt2.parent_transaction_id
                                                    AND transaction_type =
                                                           'DELIVER')
                                     AND rtv.shipment_header_id =
                                            rt2.shipment_header_id),
                             0))
                    WHEN rtv.transaction_type = 'DELIVER'
                    THEN
                       (  NVL (rtv.quantity, 0)
                        - NVL (
                             (SELECT SUM (NVL (rt2.quantity, 0))
                                FROM RCV_TRANSACTIONS rt2
                               WHERE     1 = 1
                                     AND rt2.transaction_type =
                                            'RETURN TO RECEIVING'
                                     AND rtv.transaction_id =
                                            rt2.parent_transaction_id
                                     AND EXISTS
                                            (SELECT COUNT (*)
                                               FROM RCV_TRANSACTIONS
                                              WHERE     shipment_header_id =
                                                           rt2.shipment_header_id
                                                    AND transaction_id =
                                                           rtv.parent_transaction_id
                                                    AND transaction_type =
                                                           'RECEIVE')
                                     AND rtv.shipment_header_id =
                                            rt2.shipment_header_id),
                             0)
                        + NVL (
                             (SELECT SUM (NVL (rt2.quantity, 0))
                                FROM RCV_TRANSACTIONS rt2
                               WHERE     1 = 1
                                     AND rt2.transaction_type = 'CORRECT'
                                     AND rtv.transaction_id =
                                            rt2.parent_transaction_id
                                     AND EXISTS
                                            (SELECT COUNT (*)
                                               FROM RCV_TRANSACTIONS
                                              WHERE     shipment_header_id =
                                                           rt2.shipment_header_id
                                                    AND transaction_id =
                                                           rtv.parent_transaction_id
                                                    AND transaction_type =
                                                           'RECEIVE')
                                     AND rtv.shipment_header_id =
                                            rt2.shipment_header_id),
                             0))
                    ELSE
                       NVL (rtv.quantity, 0)
                 END
                    trans_quantity,
                 NVL (
                    (SELECT costed_flag
                       FROM mtl_material_transactions
                      WHERE     rcv_transaction_id = rtv.transaction_id
                            AND ROWNUM = 1),
                    'Y')
                    FLAG,
                 -- rlot.lot_num,
                 CASE
                    WHEN     mmt.CURRENCY_CODE = 'BYR'
                         AND mmt.TRANSACTION_DATE <
                                TO_DATE ('01.07.2016', 'DD.MM.RRRR')
                    THEN
                         (mmt.ACTUAL_COST / mmt.CURRENCY_CONVERSION_RATE)
                       * (mmt.primary_quantity / mmt.transaction_quantity)
                    ELSE
                         NVL (
                            (  SELECT cil.layer_cost
                                 FROM rcv_lot_transactions mtlnn,
                                      cst_inv_layers cil,
                                      mtl_material_transactions mt
                                WHERE     cil.create_transaction_id =
                                             mt.transaction_id
                                      AND cil.layer_quantity >= 0
                                      AND cil.organization_id =
                                             mt.organization_id
                                      AND cil.inventory_item_id =
                                             mt.inventory_item_id
                                      AND mt.transaction_quantity >= 0
                                      AND mtlnn.transaction_id =
                                             mt.rcv_transaction_id
                                      AND mt.organization_id =
                                             mmt.organization_id
                                      AND mt.inventory_item_id =
                                             mmt.inventory_item_id
                                      AND mtlnn.lot_num = rlot.lot_num
                                      AND ROWNUM = 1
                             GROUP BY mtlnn.lot_num,
                                      layer_cost,
                                      inv_layer_id,
                                      mt.organization_id,
                                      mt.inventory_item_id,
                                      cil.layer_quantity,
                                      mt.TRANSACTION_DATE),
                            0)
                       * (mmt.primary_quantity / mmt.transaction_quantity)
                 END
                    transaction_cost,
                 -- xxtg_common_pkg.get_item_cost(mtl.inventory_item_id, lot.lot_number, to_date('30.06.2016', 'dd.mm.yyyy'))) transaction_cost_new,
                 /*case
                  when lot.attribute1 is not null then
                    LOT.ATTRIBUTE1
                  else
                    nvl(mtll.long_description, mtll.description)||', '||ftv.territory_short_name
                end */
                 xxtg_inv004_pkg.get_item_name (mtl.inventory_item_id,
                                                mtl.organization_id,
                                                lot.lot_number)
                    item_description
            FROM mtl_system_items_b mtl,
                 mtl_system_items_tl mtll,
                 mtl_material_transactions mmt,
                 mtl_units_of_measure_vl uoml,
                 mtl_lot_numbers_all_v lot,
                 rcv_transactions rtv,
                 rcv_shipment_lines rsl,
                 fnd_territories_vl ftv,
                 rcv_lot_transactions rlot,
                 DUAL
           WHERE     1 = 1
                 AND mtl.inventory_item_id = mtll.inventory_item_id
                 AND mtl.organization_id = mtll.organization_id
                 AND mtll.language = USERENV ('LANG')
                 AND mtl.inventory_item_id = mmt.inventory_item_id
                 AND mtl.organization_id = mmt.organization_id
                 AND mmt.rcv_transaction_id = rtv.transaction_id
                 AND mmt.transaction_quantity > 0
                 AND rtv.shipment_header_id = :P_SHIPMENT_HEADER_ID
                 AND rtv.shipment_line_id = rsl.shipment_line_id
                 AND rsl.unit_of_measure = uoml.unit_of_measure
                 AND rsl.shipment_line_status_code != 'EXPECTED'
                 AND rtv.country_of_origin_code = ftv.territory_code(+)
                 AND rlot.transaction_id = rtv.transaction_id
                 AND rlot.lot_num = lot.lot_number
                 AND mmt.inventory_item_id = lot.inventory_item_id
                 AND mmt.organization_id = lot.organization_id
        ORDER BY rtv.shipment_line_id) tt
		
		

/* Receipt Header */
SELECT *
  FROM PO.RCV_SHIPMENT_HEADERS                        
 WHERE RECEIPT_NUM = '41449'

/* Receipt Transaction */
SELECT * FROM PO.RCV_TRANSACTIONS
WHERE SHIPMENT_HEADER_ID = 554922

/* Receipt Header */
SELECT *
  FROM PO.RCV_SHIPMENT_HEADERS                        
 WHERE RECEIPT_NUM IN ('41314','41638')
 AND CREATION_DATE > to_date('01.01.2019','dd.mm.yyyy') 
/* Receipt Transaction */ -- 31.05.2019
SELECT * FROM PO.RCV_TRANSACTIONS
WHERE SHIPMENT_HEADER_ID = 516117

/* Formatted on 8/30/2019 4:32:59 PM (QP5 v5.326) Service Desk 321047 Mihail.Vasiljev */
/* Update date in Receipt*/
UPDATE  PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE =
           TO_DATE ('31.07.2019 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE     SHIPMENT_HEADER_ID IN (SELECT SHIPMENT_HEADER_ID
                                    FROM PO.RCV_SHIPMENT_HEADERS
                                   WHERE RECEIPT_NUM IN ('43778')) AND TRANSACTION_TYPE = 'CORRECT'
       AND PO_HEADER_ID = (SELECT po_header_id
                             FROM PO.po_headers_all
                            WHERE segment1 IN ('35305'))

/* Update date in Receipt*/
UPDATE PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE = to_date('30.07.2019 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE SHIPMENT_HEADER_ID in (SELECT SHIPMENT_HEADER_ID
  FROM PO.RCV_SHIPMENT_HEADERS                        
 WHERE RECEIPT_NUM IN ( '64249', '64248', '64251')) AND TRANSACTION_TYPE = 'RECEIVE'

/* Formatted on 04.06.2019 16:48:29 (QP5 v5.326) Service Desk 295658 Mihail.Vasiljev */
UPDATE PO.RCV_TRANSACTIONS
   SET TRANSACTION_DATE = ('31.05.2019 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
 WHERE SHIPMENT_HEADER_ID = 516117 AND TRANSACTION_TYPE = 'RECEIVE'