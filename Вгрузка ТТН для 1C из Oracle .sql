select * from
(
SELECT DISTINCT osh.customer_name,
--                 OSH.ORD_TYPE_MNG order_type,
--                 osh.req_date order_date,
--                 osl.order_number,
                   osh.ttn_date,
                   osh.ttn_number,
                   msi.segment1 ordered_item,
                   mst.description,
--                 sub.secondary_inventory_name subinventory,     --BSTSUP-716
--                 mmt.transfer_subinventory subinventory,        --BSTSUP-716
                   shp.lot_number,
                   shp.serial_number_b as serial_number,
--                 shp.serial_number_e,
                   shp.quantity as quantity,
--                 osh.inv_trans_mng shipment_status,
                   apps.xxtg_inv_common_pkg.get_item_cost(84,
                                                       shp.SUBINVENTORY_CODE,
                                                       shp.inventory_item_id,
                                                       shp.lot_number) as cost,
                   NVL (
               TO_CHAR (
                  apps.xxtg_inv_common_pkg.get_item_tax_rate (osl.inventory_item_id,
                                                         osl.ship_from_org_id)),
               '20')
               AS vat_percentage                                 
     FROM apps.XXTG_OE_SHIP_LINE_v osl,
          apps.XXTG_OE_SHIP_HDR_v osh,
          xxtg.XXTG_OE_SHIP_DETAIL shp,
          inv.mtl_system_items_b msi,                             --BSTSUP-716
          inv.mtl_system_items_tl mst,
          inv.mtl_parameters mp,
          inv.mtl_secondary_inventories sub,                       --BSTSUP-716
--        inv.mtl_material_transactions mmt,
--        inv.mtl_transaction_lot_numbers mtln,
--        inv.mtl_unit_transactions mut,
          ONT.OE_ORDER_LINES_ALL oel
    WHERE     osl.ship_id = osh.ship_id
          AND osl.ship_id = shp.ship_id(+)
          AND osl.line_id = shp.line_id(+)
          AND osl.inventory_item_id = shp.inventory_item_id(+)
          AND mp.organization_code = 'BMW'
          AND mp.organization_id = msi.organization_id
          AND osl.inventory_item_id = msi.inventory_item_id
          AND osh.customer_id = sub.attribute5
          AND (   (    osh.ord_type IN ('40', '90')
                   AND NVL (sub.attribute12, 'N') = 'Y') --dealer consignment flg consignment --BSTSUP-787
               OR (    (    osh.ord_type NOT IN ('40', '90')
                        AND NVL (sub.attribute12, 'N') = 'N')
                   AND NVL (sub.attribute13, 'N') = 'N')) --for all rest --BSTSUP-787
          AND msi.inventory_item_id = mst.inventory_item_id
          AND mst.language = 'RU'
          AND msi.organization_id = mst.organization_id
--        AND mmt.transaction_set_id = osh.ship_id                --BSTSUP-716
--        AND mmt.inventory_item_id = osl.inventory_item_id       --BSTSUP-716
--        AND mmt.organization_id = osl.SHIP_FROM_ORG_ID          --BSTSUP-716
--        AND mmt.transaction_id =
--                 (SELECT MAX (m.transaction_id)
--                    FROM mtl_material_transactions m
--                   WHERE     m.transaction_set_id = mmt.transaction_set_id
--                         AND m.inventory_item_id = mmt.inventory_item_id
--                         AND m.organization_id = mmt.organization_id) --BSTSUP-787
--        AND mmt.transaction_id = mtln.transaction_id
--        AND mtln.serial_transaction_id = mut.transaction_id    
--        AND mut.serial_number between shp.serial_number_b AND nvl(shp.serial_number_e,shp.serial_number_b)          
--        AND mtln.serial_transaction_id = nvl(mut.transaction_id,mtln.serial_transaction_id)
--        AND mut.serial_number (+) between shp.serial_number_b AND nvl(shp.serial_number_e,shp.serial_number_b)               
          AND oel.line_id = osl.oe_line_id
--        AND shp.serial_number_b = '860254026015356'
--        AND osh.ttn_number in ('0299797', '0299798', '0299790', '0299791')
          AND shp.serial_number_b is null
--        AND trunc(osh.req_date) = to_date('06.11.2012','dd.mm.yyyy')
--        AND osh.customer_name in ('Флагманский магазин','Флагманский магазин 2')
--      order by osh.ttn_date, osh.ttn_number, msi.segment1,shp.lot_number
      union
      SELECT DISTINCT osh.customer_name,
--                 OSH.ORD_TYPE_MNG order_type,
--                 osh.req_date order_date,
--                 osl.order_number,
                   osh.ttn_date,
                   osh.ttn_number,
                   msi.segment1 ordered_item,
                   mst.description,
--                 sub.secondary_inventory_name subinventory,--BSTSUP-716
--                 mmt.transfer_subinventory subinventory,        --BSTSUP-716
                   shp.lot_number,
                   mut.serial_number,
                   1 as quantity,
--                 osh.inv_trans_mng shipment_status,
                   apps.xxtg_inv_common_pkg.get_item_cost(84,
                                                       mmt.transfer_subinventory,
                                                       mmt.inventory_item_id,
                                                       mtln.lot_number) as cost,
                   NVL (
               TO_CHAR (
                  apps.xxtg_inv_common_pkg.get_item_tax_rate (osl.inventory_item_id,
                                                         osl.ship_from_org_id)),
               '20')
               AS vat_percentage                                 
     FROM apps.XXTG_OE_SHIP_LINE_v osl,
          apps.XXTG_OE_SHIP_HDR_v osh,
          xxtg.XXTG_OE_SHIP_DETAIL shp,
          inv.mtl_system_items_b msi,                             --BSTSUP-716
          inv.mtl_system_items_tl mst,
          inv.mtl_parameters mp,
          inv.mtl_secondary_inventories sub,                       --BSTSUP-716
          inv.mtl_material_transactions mmt,
          inv.mtl_transaction_lot_numbers mtln,
          inv.mtl_unit_transactions mut,
          ONT.OE_ORDER_LINES_ALL oel
    WHERE     osl.ship_id = osh.ship_id
          AND osl.ship_id = shp.ship_id(+)
          AND osl.line_id = shp.line_id(+)
          AND osl.inventory_item_id = shp.inventory_item_id(+)
          AND mp.organization_code = 'BMW'
          AND mp.organization_id = msi.organization_id
          AND osl.inventory_item_id = msi.inventory_item_id
          AND osh.customer_id = sub.attribute5
          AND (   (    osh.ord_type IN ('40', '90')
                   AND NVL (sub.attribute12, 'N') = 'Y') --dealer consignment flg consignment --BSTSUP-787
               OR (    (    osh.ord_type NOT IN ('40', '90')
                        AND NVL (sub.attribute12, 'N') = 'N')
                   AND NVL (sub.attribute13, 'N') = 'N')) --for all rest --BSTSUP-787
          AND msi.inventory_item_id = mst.inventory_item_id
          AND mst.language = 'RU'
          AND msi.organization_id = mst.organization_id
          AND mmt.transaction_set_id = osh.ship_id                --BSTSUP-716
          AND mmt.inventory_item_id = osl.inventory_item_id       --BSTSUP-716
          AND mmt.organization_id = osl.SHIP_FROM_ORG_ID          --BSTSUP-716
--          AND mmt.transaction_id =
--                 (SELECT MAX (m.transaction_id)
--                    FROM mtl_material_transactions m
--                   WHERE     m.transaction_set_id = mmt.transaction_set_id
--                         AND m.inventory_item_id = mmt.inventory_item_id
--                         AND m.organization_id = mmt.organization_id) --BSTSUP-787
           AND mmt.transaction_id = mtln.transaction_id
           AND mtln.serial_transaction_id = mut.transaction_id    
           AND mut.serial_number between shp.serial_number_b AND nvl(shp.serial_number_e,shp.serial_number_b)          
           AND oel.line_id = osl.oe_line_id
--         AND shp.serial_number_b = '860254026015356'
--         AND osh.ttn_number in ('0299797', '0299798', '0299790', '0299791')
--         AND trunc(osh.req_date) = to_date('06.11.2012','dd.mm.yyyy')
--         AND osh.customer_name in ('Флагманский магазин','Флагманский магазин 2')
) where ttn_number in ('ЮК 1955295')
order by ttn_date, ttn_number, ordered_item, lot_number, serial_number
