 /* Subinventory information*/
  SELECT secondary_inventory_name subinventory,
         description,
         subinventory_type,
         organization_id,
         asset_inventory,
         quantity_tracked,
         inventory_atp_code,
         availability_type,
         reservable_type,
         locator_type,
         picking_order,
         dropping_order,
         location_id,
         status_id
    FROM inv.mtl_secondary_inventories
   WHERE secondary_inventory_name = '%SubInventoryName%'
   ORDER BY subinventory
   
   --HD#255183
update INV.MTL_SECONDARY_INVENTORIES SI
set DISABLE_DATE = To_Date('16.11.2018','dd.mm.yyyy')
--, AVAILABILITY_TYPE = 1
, STATUS_ID = 42
--select DISABLE_DATE, STATUS_ID from INV.MTL_SECONDARY_INVENTORIES SI
where 1=1 
--and ORGANIZATION_ID = 86
and SECONDARY_INVENTORY_NAME in ( '3477')