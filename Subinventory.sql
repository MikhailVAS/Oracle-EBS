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
   WHERE -- secondary_inventory_name = '%SubInventoryName%'
    description LIKE '%СЕРВИС%' 
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

/* Close Subinventory*/
UPDATE inv.mtl_secondary_inventories
   SET DISABLE_DATE = TO_DATE ('10.09.2019', 'dd.mm.yyyy'),
       INVENTORY_ATP_CODE = 2,
       AVAILABILITY_TYPE = 2,
       RESERVABLE_TYPE = 2,
       STATUS_ID = 42
 WHERE secondary_inventory_name IN ('5622')

/*FRM-40654 Запись была обновлена , Для просмотра изменений выполните повторный запрос к блоку*/
UPDATE inv.mtl_secondary_inventories
   SET description = LTRIM (RTRIM (description))
 WHERE description LIKE '%Гайшинова Алиса%';
 
 /* Formatted (QP5 v5.326) Service Desk 531492 Mihail.Vasiljev 
 Прошу выгрузить список складских подразделений организаций BDW, BSW, BFC, по которым не было транзакций за последний год.*/
SELECT secondary_inventory_name     subinventory,
       description,
       organization_id,
       location_id,
       status_id
  FROM inv.mtl_secondary_inventories
 WHERE     ORGANIZATION_ID = '1369'
       AND STATUS_ID = '1'
       AND secondary_inventory_name NOT IN
               (SELECT DISTINCT SUBINVENTORY_CODE
                  FROM mtl_material_transactions
                 WHERE     TRANSACTION_DATE BETWEEN TO_DATE ('01.01.2021',
                                                             'dd.mm.yyyy')
                                                AND TO_DATE ('31.10.2021',
                                                             'dd.mm.yyyy')
                       AND TRANSACTION_QUANTITY != 0)