/*
Прошу выгрузить количество и стоимость оборудования и sim с отсутствующими серийными номерами (DUMMY) по складам дилеров на сегодняшний день.
*/

select distinct
  msib.segment1 as item_code
, mst.description
, a.lot_number
, a.CURRENT_SUBINVENTORY_CODE
, a.CURRENT_ORGANIZATION_ID
, count(*) as "Количество"
, apps.xxtg_inv_common_pkg.get_item_cost(a.current_organization_id,a.current_subinventory_code,a.inventory_item_id,a.lot_number) as "Цена"
from inv.mtl_serial_numbers a
, inv.mtl_system_items_b msib
, inv.mtl_system_items_tl mst
where
    a.serial_number like 'DUM%'
and a.current_status = 3
and a.inventory_item_id = msib.inventory_item_id
and msib.inventory_item_id = mst.inventory_item_id
and a.current_organization_id = msib.organization_id
and msib.organization_id = mst.organization_id
and mst.language = 'RU'
group by   msib.segment1
, mst.description
, a.lot_number
, a.CURRENT_SUBINVENTORY_CODE
, a.CURRENT_ORGANIZATION_ID
, a.inventory_item_id