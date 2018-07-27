SELECT distinct
--cil.create_transaction_id, mtlnn.lot_number, cil.inv_layer_id, cil.inventory_item_id , msib.segment1,  cil.layer_cost, mt.organization_id, mt.subinventory_code, mt.source_code, mt.transaction_type_id, mt.transaction_date
msib.segment1, mtlnn.lot_number, cil.layer_cost
from inv.mtl_transaction_lot_numbers mtlnn, bom.cst_inv_layers cil, inv.mtl_material_transactions mt , inv.mtl_system_items_b msib
where 1=1
and cil.create_transaction_id = mt.transaction_id 
and cil.organization_id = mt.organization_id
and cil.inventory_item_id = mt.inventory_item_id 
and msib.inventory_item_id = cil.inventory_item_id
and mt.transaction_quantity >= 0 
and mtlnn.transaction_id = mt.transaction_id 
and mtlnn.lot_number = '170807ЭлкоТелеком_ООО_РБ053906'
order by 1, 2

select * from  inv.mtl_transaction_accounts
where 1=1
and transaction_id =  '30603875'

--Servic Desk 140710
update BOM.CST_INV_LAYERS a 
set a.layer_cost = 173.10
where 1=1 
and CREATE_TRANSACTION_ID in (
SELECT distinct cil.create_transaction_id from inv.mtl_transaction_lot_numbers mtlnn, bom.cst_inv_layers cil, inv.mtl_material_transactions mt , inv.mtl_system_items_b msib
where 1=1 and cil.create_transaction_id = mt.transaction_id and cil.organization_id = mt.organization_id and cil.inventory_item_id = mt.inventory_item_id and msib.inventory_item_id = cil.inventory_item_id
and mt.transaction_quantity >= 0 and mtlnn.transaction_id = mt.transaction_id and mtlnn.lot_number = '170807ЭлкоТелеком_ООО_РБ053906'
) and a.layer_cost != 173.10


--Servic Desk 140710
update inv.mtl_transaction_accounts 
set RATE_OR_AMOUNT = 173.10, BASE_TRANSACTION_VALUE = primary_quantity*173.10
where transaction_id = '30603875'