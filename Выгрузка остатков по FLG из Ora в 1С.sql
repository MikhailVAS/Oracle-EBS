/* Formatted on 25.05.2018 14:55:46 (QP5 v5.163.1008.3004) */
  SELECT distinct
         si.secondary_inventory_name customer_code,
         si.customer_name,
         to_char(sysdate, 'dd-mm-yyyy') ttn_date,
         'АА 0000000' ttn_number,
         msi.segment1 ordered_item,
         msi.description,
         sn.lot_number,
         sn.serial_number,
         1 quantity,
         uc.UNIT_COST cost
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
    FROM MTL_ONHAND_QUANTITIES_DETAIL onh,
         MTL_SERIAL_NUMBERS sn,
         MTL_SYSTEM_ITEMS_VL MSI,
         XXTG_SECONDARY_INVENTORIES_V si,
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
         and onh.subinventory_code like '%ФЛГ%'
         and onh.subinventory_code not like  ('%кнсг%')
union all
  SELECT 
         si.secondary_inventory_name customer_code,
         si.customer_name,
         to_char(sysdate, 'dd-mm-yyyy') ttn_date,
         'АА 0000000' ttn_number,
         msi.segment1 ordered_item,
         msi.description,
         onh.lot_number,
         nvl(lot.c_attribute1, msi.segment1) serial_number,
         primary_transaction_quantity quantity,
         uc.UNIT_COST item_cost
         ,percentage_rate vat_percentage
    FROM MTL_ONHAND_QUANTITIES_DETAIL onh,
         MTL_SYSTEM_ITEMS_VL MSI,
         MTL_LOT_NUMBERS lot,
         XXTG_SECONDARY_INVENTORIES_V si,
         xxtg.xxtg_unit_cost uc,
         ZX.zx_rates_b r 
   WHERE msi.inventory_item_id = onh.inventory_item_id
         AND msi.organization_id = onh.organization_id
         AND msi.serial_number_control_code = '1'
         AND lot.organization_id = onh.organization_id
         AND lot.inventory_item_id = onh.inventory_item_id
         AND si.organization_id = onh.organization_id
         AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
         AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
         AND uc.LOT_NUMBER = onh.LOT_NUMBER
         AND r.tax_rate_code = nvl(msi.attribute7, 'VAT20 REVENUE')
         AND uc.CURRENCY_CODE = 'BYN'
         AND onh.organization_id = 84
         and onh.subinventory_code like '%ФЛГ%'
         and onh.subinventory_code not like  ('%кнсг%')
ORDER BY 2



--номенклатура в разрезе мазгазинов 


  SELECT 
         si.secondary_inventory_name customer_code,
         si.customer_name,
         to_char(sysdate, 'dd-mm-yyyy') ttn_date,
         'АА 0000000' ttn_number,
         msi.segment1 ordered_item,
         msi.description
    FROM MTL_ONHAND_QUANTITIES_DETAIL onh,
         MTL_SYSTEM_ITEMS_VL MSI,
         XXTG_SECONDARY_INVENTORIES_V si,
         xxtg.xxtg_unit_cost uc,
         ZX.zx_rates_b r 
   WHERE msi.inventory_item_id = onh.inventory_item_id
         AND msi.organization_id = onh.organization_id
         AND msi.serial_number_control_code = '1'
         AND si.organization_id = onh.organization_id
         AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
         AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
         AND uc.LOT_NUMBER = onh.LOT_NUMBER
         AND r.tax_rate_code = nvl(msi.attribute7, 'VAT20 REVENUE')
         AND uc.CURRENCY_CODE = 'BYN'
         AND onh.organization_id = 84
         and onh.subinventory_code like '%ФЛГ%'
         and onh.subinventory_code not like  ('%кнсг%')
group by si.secondary_inventory_name,
         si.customer_name,
         to_char(sysdate, 'dd-mm-yyyy'),
         'АА 0000000',
         msi.segment1,
         msi.description



--номенклатура во всех магазинах 

  SELECT 
         msi.segment1 ordered_item,
         msi.description
    FROM MTL_ONHAND_QUANTITIES_DETAIL onh,
         MTL_SYSTEM_ITEMS_VL MSI,
         XXTG_SECONDARY_INVENTORIES_V si,
         xxtg.xxtg_unit_cost uc,
         ZX.zx_rates_b r 
   WHERE msi.inventory_item_id = onh.inventory_item_id
         AND msi.organization_id = onh.organization_id
         AND msi.serial_number_control_code = '1'
         AND si.organization_id = onh.organization_id
         AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
         AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
         AND uc.LOT_NUMBER = onh.LOT_NUMBER
         AND r.tax_rate_code = nvl(msi.attribute7, 'VAT20 REVENUE')
         AND uc.CURRENCY_CODE = 'BYN'
         AND onh.organization_id = 84
         and onh.subinventory_code like '%ФЛГ%'
         and onh.subinventory_code not like  ('%кнсг%')
group by 
         msi.segment1,
         msi.description

