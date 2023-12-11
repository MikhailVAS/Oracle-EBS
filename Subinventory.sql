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


/* Formatted on (QP5 v5.326) Service Desk 728890 Mihail.Vasiljev */
UPDATE inv.mtl_secondary_inventories
   SET DESCRIPTION = 'Duplicate ' || DESCRIPTION,
       INVENTORY_ATP_CODE = '2',
       AVAILABILITY_TYPE = '2',
       RESERVABLE_TYPE = '2',
       STATUS_ID = '42'
WHERE     status_id != '42'
       AND ORGANIZATION_ID = '85'
       AND description IN
               (  SELECT description
                    FROM inv.mtl_secondary_inventories
                   WHERE organization_id = '85' AND status_id != '42'
                GROUP BY description
                  HAVING COUNT (*) > 1)
       AND secondary_inventory_name NOT IN
               (SELECT DISTINCT SUBINVENTORY_CODE
                 FROM MTL_ONHAND_QUANTITIES OQ
                WHERE     ORGANIZATION_ID = '85'
                      AND OQ.SUBINVENTORY_CODE IN
                              (SELECT ss1.secondary_inventory_name
                                FROM inv.mtl_secondary_inventories ss1
                               WHERE ss1.description IN
                                         ( (  SELECT DISTINCT ss.description
                                              FROM inv.mtl_secondary_inventories
                                                   ss
                                             WHERE     ss.organization_id =
                                                       '85'
                                                   AND ss.status_id != '42'
                                          GROUP BY ss.description
                                            HAVING COUNT (*) > 1))))