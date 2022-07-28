  SELECT DISTINCT
         si.secondary_inventory_name customer_code,
         si.customer_name,
         to_char(sysdate, 'dd.mm.yyyy') ttn_date,
         'АА 0000000' ttn_number,
         msi.segment1 ordered_item,
         msi.description,
         sn.lot_number,
         sn.serial_number "EAN/Serial",
         1 quantity,
         Round(uc.UNIT_COST,2) cost
         ,percentage_rate vat_percentage/*,
         apps.xxtg_inv_common_pkg.get_item_cost (
            84,
            onh.SUBINVENTORY_CODE,
            msi.inventory_item_id,
            sn.lot_number)
            AS cost,
         NVL (
            TO_CHAR (
               apps.xxtg_inv_common_pkg.get_item_tax_rate (
                  msi.inventory_item_id,
                  83)),
            '20')
            AS vat_percentage*/
    --, primary_transaction_quantity
    FROM APPS.MTL_ONHAND_QUANTITIES_DETAIL onh,
         APPS.MTL_SERIAL_NUMBERS sn,
         APPS.MTL_SYSTEM_ITEMS_VL MSI,
         APPS.XXTG_SECONDARY_INVENTORIES_V si,
         xxtg.xxtg_unit_cost uc,
         ZX.zx_rates_b r 
   WHERE     sn.current_organization_id = onh.organization_id
         AND sn.lot_number = onh.lot_number
         AND sn.inventory_item_id = onh.inventory_item_id
         AND sn.current_subinventory_code = onh.subinventory_code
         AND sn.CURRENT_STATUS != '4'
         AND msi.inventory_item_id = onh.inventory_item_id
         AND msi.organization_id = onh.organization_id
         AND msi.serial_number_control_code != '1'
         AND si.organization_id = onh.organization_id
         AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
         AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
         AND uc.LOT_NUMBER = onh.LOT_NUMBER
         AND r.tax_rate_code = nvl(msi.attribute7, 'VAT20 REVENUE')
         AND uc.CURRENCY_CODE = 'BYN'
         AND onh.organization_id = 84
         and onh.subinventory_code like 'ФЛГ6_ЦО'
         and onh.subinventory_code not like  ('%кнсг%')
--         AND msi.segment1 = 'M612H Gold'
union all
  SELECT DISTINCT
         si.secondary_inventory_name customer_code,
         si.customer_name,
         to_char(sysdate, 'dd.mm.yyyy') ttn_date,
         'АА 0000000' ttn_number,
         msi.segment1 ordered_item,
         msi.description,
         onh.lot_number,
         lot.c_attribute1 "EAN/Serial",
         primary_transaction_quantity quantity,
         Round(uc.UNIT_COST,2) item_cost
         ,percentage_rate vat_percentage
    FROM APPS.MTL_ONHAND_QUANTITIES_DETAIL onh,
         APPS.MTL_SYSTEM_ITEMS_VL MSI,
         APPS.MTL_LOT_NUMBERS lot,
         APPS.XXTG_SECONDARY_INVENTORIES_V si,
         xxtg.xxtg_unit_cost uc,
         ZX.zx_rates_b r 
   WHERE msi.inventory_item_id = onh.inventory_item_id
         AND msi.organization_id = onh.organization_id
         AND msi.serial_number_control_code = '1'
         AND lot.organization_id = onh.organization_id
         AND lot.lot_number = onh.lot_number
         AND lot.inventory_item_id = onh.inventory_item_id
         AND si.organization_id = onh.organization_id
         AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
         AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
         AND uc.LOT_NUMBER = onh.LOT_NUMBER
         AND r.tax_rate_code = nvl(msi.attribute7, 'VAT20 REVENUE')
         AND uc.CURRENCY_CODE = 'BYN'
         AND onh.organization_id = 84
         and onh.subinventory_code like 'ФЛГ6_ЦО'
         and onh.subinventory_code not like  ('%кнсг%')
--        AND msi.segment1 = 'M612H Gold'
ORDER BY 1