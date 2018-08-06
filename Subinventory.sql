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