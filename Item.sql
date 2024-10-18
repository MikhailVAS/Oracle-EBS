begin

inv_item_events_pvt.invoke_icx_apis( p_entity_type       => 'ITEM',
                                     p_dml_type          => 'UPDATE',
                                     p_inventory_item_id => (SELECT DISTINCT INVENTORY_ITEM_ID
                                   FROM inv.mtl_system_items_b a
                                  WHERE SEGMENT1 = '1006635230'),
                                     p_item_description  => 'Наклейка самоклейка винил Светлогорск, ул. Батова 1 ТЦ Пассаж  1400*500',
                                     p_organization_id   => 82,
                                     p_master_org_flag   => 'Y',
                                     p_commit            => TRUE
                                  );

end;



-- ALTER SESSION SET NLS_LANGUAGE='Russian'

/* Здравствуйте. Я не могу создать PR, т.к. не соответствуют item и наименования ТМЦ в iProcurment.    */ 
     
/* Изменение описания в атемах на всех организациях, для подхватки описания 
после апдета добавить в Description пробел и сохранить , пробел за тримится 
зато айтем обновится */
UPDATE APPS.MTL_SYSTEM_ITEMS_TL
   SET DESCRIPTION = :DESCRIPTION, LONG_DESCRIPTION = :DESCRIPTION
--   SELECT * FROM APPS.MTL_SYSTEM_ITEMS_TL
 WHERE INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID        
  							FROM inv.mtl_system_items_b a
							 WHERE SEGMENT1 = '1013071148')
							 AND SOURCE_LANG = 'RU'; 
 
/* После чего запускаем канкарент XXTG Update Inventory Item Attributes в модуле Warehouse Manager */                    
/* Изменение в описание для iProcurment описания  1 */ 
UPDATE APPS.icx_cat_items_ctx_hdrs_tlp
   SET DESCRIPTION = :DESCRIPTION
--   SELECT * FROM icx_cat_items_ctx_hdrs_tlp
 WHERE INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID        
  							FROM inv.mtl_system_items_b a
							 WHERE SEGMENT1 = '1013071148')
							 AND LANGUAGE = 'RU';
 
 /* Изменение в описание для iProcurment описания 2  */ 
UPDATE ICX_CAT_ATTRIBUTE_VALUES_TLP a
   SET LONG_DESCRIPTION = :DESCRIPTION, DESCRIPTION = :DESCRIPTION 
-- select DESCRIPTION, a.* from ICX_CAT_ATTRIBUTE_VALUES_TLP a
 WHERE     1 = 1
       AND INVENTORY_ITEM_ID IN (SELECT DISTINCT INVENTORY_ITEM_ID
                                   FROM inv.mtl_system_items_b a
                                  WHERE SEGMENT1 = '1013071148');

/* Formatted on (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_system_items_b
   SET DESCRIPTION = :DESCRIPTION
 WHERE SEGMENT1 = '1005948999';

/* Описание Item-a по item коду */
SELECT DISTINCT DESCRIPTION        
  FROM inv.mtl_system_items_b a
 WHERE SEGMENT1 = '1005948999'
 
 /* Formatted on (QP5 v5.326) Service Desk 422621 Mihail.Vasiljev */
UPDATE inv.mtl_system_items_b a
   SET a.ATTRIBUTE_CATEGORY =
           (SELECT b.ATTRIBUTE_CATEGORY
              FROM inv.mtl_system_items_b b
             WHERE b.SEGMENT1 = :item AND b.ORGANIZATION_ID = '82'),
       a.ATTRIBUTE8 =
           (SELECT c.ATTRIBUTE8
              FROM inv.mtl_system_items_b c
             WHERE c.SEGMENT1 = :item AND c.ORGANIZATION_ID = '82'),
       a.ATTRIBUTE15 =
           (SELECT d.ATTRIBUTE15
              FROM inv.mtl_system_items_b d
             WHERE d.SEGMENT1 = :item AND d.ORGANIZATION_ID = '82')
 WHERE a.SEGMENT1 = :item
 

 /* Delete all serial number  */
DELETE FROM MTL_SERIAL_NUMBERS
      WHERE INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                   FROM inv.mtl_system_items_b a
                                  WHERE SEGMENT1 = '1005110063')
								  
/* Delete all lot serial number in transactions*/
DELETE FROM MTL_UNIT_TRANSACTIONS
      WHERE INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                   FROM inv.mtl_system_items_b a
                                  WHERE SEGMENT1 = '1052005866')

 
 /* Статус сериного , Item , Партия, Склад  по серийному*/
  SELECT DISTINCT
                   serial_number,
                   msib.SEGMENT1 AS Item,
                   LOT_NUMBER,
                   group_mark_id,
                   line_mark_id,
                   lot_line_mark_id,
                   reservation_id,
                   current_status,
                   current_subinventory_code,
                   a.*
    FROM inv.mtl_serial_numbers a
         INNER JOIN inv.mtl_system_items_b msib
             ON msib.inventory_item_id = a.inventory_item_id
   WHERE 1 = 1 AND serial_number = ('893750310158545219')
ORDER BY a.GROUP_MARK_ID,
         a.LINE_MARK_ID,
         a.LOT_LINE_MARK_ID,
         a.RESERVATION_ID
		 
/* Uniq Name */
UPDATE inv.mtl_system_items_b
   SET ATTRIBUTE2 = 'N',                                                --NULL
       ATTRIBUTE8 = 'ФЛГ ПОСМ: футболка',
       ATTRIBUTE12 = NULL,                                                -- 0
       ATTRIBUTE14 = SEGMENT1,
       CATALOG_STATUS_FLAG = 'N',                                      -- NULL
       COLLATERAL_FLAG = NULL,                                            -- N
       TAXABLE_FLAG = 'N',                                             -- Null
       END_ASSEMBLY_PEGGING_FLAG = 'N',                                -- NULL
       CONTAINER_ITEM_FLAG = NULL,                                        -- N
       VEHICLE_ITEM_FLAG = NULL,                                          -- N
       EVENT_FLAG = NULL,                                                 -- N
       ELECTRONIC_FLAG = NULL,                                            -- N
       DOWNLOADABLE_FLAG = NULL,                                          -- N
       INDIVISIBLE_FLAG = NULL,                                           -- N
       SO_AUTHORIZATION_FLAG = '1',
       ATTRIBUTE21 = 'N',
       GDSN_OUTBOUND_ENABLED_FLAG = NULL                                   --N
 WHERE SEGMENT1 IN ('1006633696',
                    '1006633697',
                    '1006633698',
                    '1006633699',
                    '1006633700',
                    '1006633701',
                    '1006633702',
                    '1006633703')
					
/* 1 Change primary UOM on item (QP5 v5.326) Service Desk 513871 Mihail.Vasiljev */
UPDATE inv.mtl_system_items_b
   SET PRIMARY_UOM_CODE = 'M2',                                           --EA
       PRIMARY_UNIT_OF_MEASURE = 'Square Meters' -- Each
 WHERE SEGMENT1 = '1013001148'

/* 2 Change primary UOM on Price List   Service Desk 513871 Mihail.Vasiljev */
UPDATE QP_PRICING_ATTRIBUTES
   SET PRODUCT_UOM_CODE = 'M2'
 WHERE LIST_LINE_ID = 1088941		 
		 
SELECT DISTINCT LOT_DIVISIBLE_FLAG,
       LOT_STATUS_ENABLED,
       DEFAULT_LOT_STATUS_ID,
       SERIAL_STATUS_ENABLED,
       DEFAULT_SERIAL_STATUS_ID,
       LOT_SPLIT_ENABLED,
       SERIAL_NUMBER_CONTROL_CODE,
       START_AUTO_SERIAL_NUMBER,
       AUTO_SERIAL_ALPHA_PREFIX
  FROM inv.mtl_system_items_b
 WHERE SEGMENT1 IN ('1013520378')

 /* Change to Serial item */
UPDATE inv.mtl_system_items_b
   SET LOT_DIVISIBLE_FLAG = 'Y',
       LOT_STATUS_ENABLED = 'Y',
       DEFAULT_LOT_STATUS_ID = 1,
       SERIAL_STATUS_ENABLED = 'Y',
       DEFAULT_SERIAL_STATUS_ID = 1,
       LOT_SPLIT_ENABLED = 'Y',
       SERIAL_NUMBER_CONTROL_CODE = 5,
       START_AUTO_SERIAL_NUMBER = 1,
       AUTO_SERIAL_ALPHA_PREFIX = 'S'
 WHERE SEGMENT1 IN ('1001024714')

 /* Change to Not Serial item */
UPDATE inv.mtl_system_items_b
   SET LOT_DIVISIBLE_FLAG = 'Y',
       LOT_STATUS_ENABLED = 'Y',
       DEFAULT_LOT_STATUS_ID = 1,
       SERIAL_STATUS_ENABLED = 'N',
       DEFAULT_SERIAL_STATUS_ID = NULL,
       LOT_SPLIT_ENABLED = 'Y',
       SERIAL_NUMBER_CONTROL_CODE =1,
       START_AUTO_SERIAL_NUMBER = NULL,
       AUTO_SERIAL_ALPHA_PREFIX = NULL
 WHERE SEGMENT1 IN ('1013520378')		 
		 
		 /* Formatted on 20.12.2018 12:19:14 (QP5 v5.318) Service Desk  Mihail.Vasiljev */
  SELECT  MSIB.INVENTORY_ITEM_ID,MSIB.ORGANIZATION_ID,
                  MSIB.DESCRIPTION,
                  MSIB.SEGMENT1,
                  MSIT.LANGUAGE,
                  MSIT.DESCRIPTION,
                  MSIT.LONG_DESCRIPTION
    FROM APPS.MTL_SYSTEM_ITEMS_B MSIB, APPS.MTL_SYSTEM_ITEMS_TL MSIT
   WHERE     MSIB.inventory_item_id = MSIT.inventory_item_id
         --       AND MSIB.organization_id = MIC.organizatin_id
         AND MSIB.segment1 IN ('1009300039')
ORDER BY MSIB.SEGMENT1, MSIT.LANGUAGE

/* Обновление символов в айтеме */
UPDATE APPS.MTL_SYSTEM_ITEMS_TL MSIT
   SET MSIT.DESCRIPTION = REPLACE (MSIT.DESCRIPTION, 'п', 'n'),
       MSIT.LONG_DESCRIPTION = REPLACE (MSIT.LONG_DESCRIPTION, 'п', 'n')
 WHERE MSIT.LANGUAGE = 'US'
       AND MSIT.inventory_item_id IN (SELECT DISTINCT INVENTORY_ITEM_ID
                                    FROM inv.mtl_system_items_b a
                                   WHERE SEGMENT1 IN ('1013520283',
                                                      '1013520284',
                                                      '1013520285',
                                                      '1013520286'))
/* Item , Status, Balance by Organization*/
SELECT a.SEGMENT1,
       a.DESCRIPTION,
       (SELECT PIS.STATUS_CODE
          FROM MTL_PENDING_ITEM_STATUS PIS
         WHERE     PIS.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
               AND PIS.ORGANIZATION_ID = a.ORGANIZATION_ID
               AND PIS.IMPLEMENTED_DATE =
                   (SELECT MAX (MIS.IMPLEMENTED_DATE)
                     FROM MTL_PENDING_ITEM_STATUS MIS
                    WHERE     MIS.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID --'553743'
                          AND MIS.ORGANIZATION_ID = a.ORGANIZATION_ID))
           AS STATUS,
       (SELECT NVL2 (COUNT (QD.PRIMARY_TRANSACTION_QUANTITY), 'Yes', 'No')
         FROM MTL_ONHAND_QUANTITIES_DETAIL QD
        WHERE     QD.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
              AND QD.ORGANIZATION_ID = a.ORGANIZATION_ID)
           AS balance,
       a.ORGANIZATION_ID,
       CASE a.ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           WHEN 1369 THEN 'BFC: Строительство ОС'
           ELSE 'Other organization'
       END
           AS "Наименованеи_организации"
  FROM inv.mtl_system_items_b a
 WHERE SEGMENT1 = '1001024715'


/* Formatted on 20.12.2018 15:06:57 (QP5 v5.318) Service Desk  Mihail.Vasiljev */
SELECT MSIT.INVENTORY_ITEM_ID,
       CASE MSIT.ORGANIZATION_ID
             WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
             WHEN 83 THEN 'BBW: Склад Бест'
             WHEN 84 THEN 'BDW: Дилеры'
             WHEN 85 THEN 'BHW: Головной офис Бест'
             WHEN 86 THEN 'BSW: Подрядчики'
             WHEN 1369 THEN 'BFC: Строительство ОС'
             ELSE 'Other organization'
       END
           AS "Наименованеи_организации",
       MSIT.LANGUAGE,
       MSIT.SOURCE_LANG,
       MSIT.DESCRIPTION,
       MSIT.LONG_DESCRIPTION
  FROM APPS.MTL_SYSTEM_ITEMS_TL MSIT
 WHERE                       --MSIB.inventory_item_id = MSIT.inventory_item_id
       INVENTORY_ITEM_ID = 690019

/* info template*/
SELECT template_id, template_name, description
  FROM MTL_ITEM_TEMPLATES
 WHERE template_id =
       (SELECT TEMPLATE_ID
          FROM MTL_ITEM_TEMPLATES_ALL_V
         WHERE UPPER (TEMPLATE_NAME) LIKE 'XXTG_ITEM_INV_LOT_CTRL');

/* To see all the attributes related to template*/
SELECT template_id,
       attribute_name,
       enabled_flag,
       report_user_value
  FROM MTL_ITEM_TEMPL_ATTRIBUTES
 WHERE template_id =
       (SELECT TEMPLATE_ID
          FROM MTL_ITEM_TEMPLATES_ALL_V
         WHERE UPPER (TEMPLATE_NAME) LIKE 'XXTG_ITEM_INV_LOT_CTRL');

 /* Item Category Assignment */
SELECT DISTINCT 
       (SELECT DISTINCT FIFS.ID_FLEX_STRUCTURE_NAME
          FROM APPS.FND_ID_FLEX_STRUCTURES_VL FIFS
         WHERE     MCB.STRUCTURE_ID = FIFS.ID_FLEX_NUM
               AND FIFS.APPLICATION_ID = 401
               AND FIFS.ID_FLEX_CODE = 'MCAT'  )
           "Item Category Assignment",
       MCB.CONCATENATED_SEGMENTS,
       MCT.DESCRIPTION,
       MCB.ENABLED_FLAG,
       to_date(MCB.DISABLE_DATE,'DD.MM.YY') DISABLE_DATE ,
       MCB.ATTRIBUTE1
           "Local Account",
       MCB.ATTRIBUTE2
           "In Use Account",
       MCB.ATTRIBUTE3
           "Analytic Account",
       MCB.ATTRIBUTE4
           "Detail Account",
       MCB.ATTRIBUTE13
           "Type of activity",
       MCB.ATTRIBUTE7
           "Vat Rate Reporting",
           MCB.SEGMENT1,
           MCB.SEGMENT2,
           MCB.SEGMENT3,
           MCB.SEGMENT4,
           MCB.SEGMENT5,
           MCB.SEGMENT6,
           MCB.SEGMENT7,
           MCB.SEGMENT8,
           to_date (MCB.CREATION_DATE,'dd.mm.yy') CREATION_DATE ,
           to_date (MCB.LAST_UPDATE_DATE,'dd.mm.yy') LAST_UPDATE_DATE
--          , mic.*
FROM  --APPS.mtl_item_categories mic, 
      APPS.MTL_CATEGORIES_B_KFV MCB,
      MTL_CATEGORIES_TL          MCT
        WHERE     --MCB.CATEGORY_ID = MIC.CATEGORY_ID AND
          MCB.CATEGORY_ID = MCT.CATEGORY_ID
       AND MCT.LANGUAGE = USERENV ('LANG')
  AND  MCB.CONCATENATED_SEGMENTS != 'Inventory'
--MIC.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
--AND  CONCATENATED_SEGMENTS = 'Capex.ICT.Hardware.Office/Personal Systems.Technical Office Equipment.Desktop Computer.Other.Other'
--ORDER BY MCB.LAST_UPDATE_DATE DESC        
		 
/* Item Category Assignment2 */
SELECT DISTINCT
       a.SEGMENT1,
       a.DESCRIPTION,
       (SELECT DISTINCT ID_FLEX_STRUCTURE_NAME
          FROM APPS.FND_ID_FLEX_STRUCTURES_VL FIFS
         WHERE     MCB.STRUCTURE_ID = FIFS.ID_FLEX_NUM
               AND FIFS.APPLICATION_ID = 401
               AND FIFS.ID_FLEX_CODE = 'MCAT')
           "Item Category Assignment",
       MCB.CONCATENATED_SEGMENTS,
       MCB.ENABLED_FLAG,
       MCB.ATTRIBUTE1
           "Local Account",
       MCB.ATTRIBUTE2
           "In Use Account",
       MCB.ATTRIBUTE3
           "Analytic Account",
       MCB.ATTRIBUTE4
           "Detail Account",
       MCB.ATTRIBUTE13
           "Type of activity",
       MCB.ATTRIBUTE7
           "Vat Rate Reporting"
  FROM inv.mtl_system_items_b  a
       LEFT JOIN APPS.mtl_item_categories mic
           ON MIC.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
       LEFT JOIN APPS.MTL_CATEGORIES_B_KFV MCB
           ON MCB.CATEGORY_ID = MIC.CATEGORY_ID
 WHERE a.SEGMENT1 IN ('1001025477')
 
 
 SELECT 
       CASE MSI.ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           WHEN 1369 THEN 'BFC: Строительство ОС'
           ELSE 'Other organization'
       END
           AS "Наименованеи_организации",
       msi.segment1,
       msi.description,
       (SELECT UNIT_OF_MEASURE_TL
          FROM apps.mtl_units_of_measure UOM
         WHERE UOM.UOM_CODE = msi.PRIMARY_UOM_CODE)
           "Ед. Изм.",
       msi.ATTRIBUTE_CATEGORY,
       (SELECT DISTINCT flv.meaning     item_type_meaning
          FROM apps.fnd_lookup_values flv
         WHERE     lookup_type = 'ITEM_TYPE'
               AND flv.lookup_code = msi.ATTRIBUTE_CATEGORY
               AND LANGUAGE = 'RU') "Тип",
       msi.ATTRIBUTE6
           "Group of Item",
       (SELECT DESCRIPTION
          FROM APPS.FND_FLEX_VALUES_VL
         WHERE     VALUE_CATEGORY = 'XXTG_GROUP_OF_ITEM'
               AND FLEX_VALUE = msi.ATTRIBUTE6)
           "Group of Item Description",
       msi.ATTRIBUTE11
           "Код поставщика",
       msi.ITEM_TYPE
  FROM apps.mtl_system_items_vl msi, apps.mtl_org_assign_v moa
 WHERE     moa.organization_id = msi.organization_id
       AND moa.inventory_item_id = msi.inventory_item_id
       AND moa.assigned_flag = 'Y'
       AND msi.SEGMENT1 = '1009300039'
	   
	   
/* Item creation form  ALL info (Header + Lines) by create date  */
  SELECT ICHDR.*, QRSLT.*
    FROM (SELECT VAL.APPRUVE_STATUS,
                 (SELECT FDECS
                    FROM (SELECT SRV.FLEX_VALUE      fvalue,
                                 SRV.DESCRIPTION     FDECS,
                                 'XXTG_SRV'          ITEM_TYPE
                            FROM XXTG_HEAD_OF_EXPENDITURE_V SRV
                          UNION ALL
                          SELECT FA_SRV.FLEX_VALUE      fvalue,
                                 FA_SRV.DESCRIPTION     decs,
                                 'XXTG_FA_SRV'          ITEM_TYPE
                            FROM XXTG_FA_HEAD_OF_EXPENDITURE_V FA_SRV)
                   WHERE     ITEM_TYPE = VAL.ITEM_TYPE
                         AND fvalue = VAL.HEAD_OF_EXPENDITURE_CODE)
                     HEAD_OF_EXPENDITURE_DESC,
                 MCAT.CONCATENATED_SEGMENTS
                     GROUP_PO_CATEOGRY_DESC,
                 (SELECT CONCATENATED_SEGMENTS
                    FROM FA_CATEGORIES_B_KFV FCAT
                   WHERE     FCAT.ENABLED_FLAG = 'Y'
                         AND FCAT.CATEGORY_ID = VAL.ASSET_CATEGORY_ID)
                     ASSET_CATEGORY_DESC,
                 VAL.ASSET_CATEGORY,
                 VAL.ASSET_CATEGORY_ID,
                 VAL.CREATED_BY,
                 VAL.CREATION_DATE,
                 VAL.CURRENCY_CODE,
                 VAL.EQUIPMENT_TYPE,
                 VAL.ERROR_MESSAGE,
                 VAL.GROUP_OF_ITEMS,
                 VAL.GROUP_PO_CATEOGRY,
                 VAL.GROUP_PO_CATEOGRY_ID,
                 VAL.HEADER_ID,
                 VAL.HEAD_OF_EXPENDITURE,
                 VAL.HEAD_OF_EXPENDITURE_CODE,
                 VAL.ITEM_TYPE,
                 VAL.LAST_UPDATED_BY,
                 VAL.LAST_UPDATE_DATE,
                 VAL.LAST_UPDATE_LOGIN,
                 VAL.LINE_ID,
                 VAL.MARKETING_ID,
                 VAL.NOMINAL,
                 VAL.PRECIOUS_METALS,
                 VAL.ROWID,
                 VAL.SALES_UNIQUE_NAME,
                 VAL.SALE_VAT_RATE,
                 VAL.SERIAL_CONTROL,
                 VAL.SIM_SCRATCH,
                 VAL.TRX_MEMO_LINE,
                 VAL.UNIT_VOLUME,
                 VAL.UNIT_WEIGHT,
                 VAL.UOM_CODE,
                 VAL.VENDOR_ITEM_CODE,
                 VAL.VOLUME_UOM,
                 VAL.WARRANTY,
                 VAL.WARRANTY_CODE,
                 VAL.WEIGHT_UOM,
                 VAL.APPROVER_ID,
                 VAL.ITEM_TYPE_APP_USER_ID,
                 VAL.ASSET_CATEGORY_APP_USER_ID,
                 VAL.CURRENCY_CODE_APP_USER_ID,
                 VAL.EQUIPMENT_TYPE_APP_USER_ID,
                 VAL.GROUP_OF_ITEMS_APP_USER_ID,
                 VAL.GROUP_PO_CAT_APP_USER_ID,
                 VAL.HEAD_OF_EXPEND_APP_USER_ID,
                 VAL.INV_OBJECT_COMP_APP_USER_ID,
                 VAL.ITEM_TYPE_APP_USER_ID
                     AS ITEM_TYPE_APP_USER_ID1,
                 VAL.MARKETING_APP_USER_ID,
                 VAL.NOMINAL_APP_USER_ID,
                 VAL.PRECIOUS_METALS_APP_USER_ID,
                 VAL.SALES_APP_USER_ID,
                 VAL.SALE_VAT_RATE_APP_USER_ID,
                 VAL.SERIAL_CONTROL_APP_USER_ID,
                 VAL.SIM_SCRATCH_APP_USER_ID,
                 VAL.TRX_MEMO_LINE_APP_USER_ID,
                 VAL.UOM_APP_USER_ID,
                 VAL.VENDOR_ITEM_CODE_APP_USER_ID,
                 VAL.VOLUME_APP_USER_ID,
                 VAL.WARRANTY_APP_USER_ID,
                 VAL.WEIGHT_APP_USER_ID,
                 VAL.INV_OBJECT_COMPONENT,
                 VAL.INV_OBJECT_COMPONENT_CODE,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.ITEM_TYPE_APP_USER_ID)
                     ITEM_TYPE_APPROVE_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.ASSET_CATEGORY_APP_USER_ID)
                     ASSET_CATEGORY_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.CURRENCY_CODE_APP_USER_ID)
                     CURRENCY_CODE_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.EQUIPMENT_TYPE_APP_USER_ID)
                     EQUIPMENT_TYPE_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.GROUP_OF_ITEMS_APP_USER_ID)
                     GROUP_OF_ITEMS_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.GROUP_PO_CAT_APP_USER_ID)
                     GROUP_PO_CAT_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.HEAD_OF_EXPEND_APP_USER_ID)
                     HEAD_OF_EXPEND_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.INV_OBJECT_COMP_APP_USER_ID)
                     INV_OBJECT_COMP_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.MARKETING_APP_USER_ID)
                     MARKETING_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.NOMINAL_APP_USER_ID)
                     NOMINAL_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.PRECIOUS_METALS_APP_USER_ID)
                     PRECIOUS_METALS_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.SALES_APP_USER_ID)
                     SALES_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.SALE_VAT_RATE_APP_USER_ID)
                     SALE_VAT_RATE_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.SERIAL_CONTROL_APP_USER_ID)
                     SERIAL_CONTROL_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.SIM_SCRATCH_APP_USER_ID)
                     SIM_SCRATCH_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.TRX_MEMO_LINE_APP_USER_ID)
                     TRX_MEMO_LINE_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.UOM_APP_USER_ID)
                     UOM_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.VENDOR_ITEM_CODE_APP_USER_ID)
                     VENDOR_ITEM_CODE_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.VOLUME_APP_USER_ID)
                     VOLUME_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.WARRANTY_APP_USER_ID)
                     WARRANTY_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.WEIGHT_APP_USER_ID)
                     WEIGHT_APP_USER,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (VAL.APPROVER_ID)
                     APPROVER_ID_USER_NAME,
--                 XXTG_CREATING_ITEM_PKG.GET_NOTIFICATION_MESS (VAL.HEADER_ID,
--                                                               VAL.APPROVER_ID)
--                     AS MESSAGE,
                 NVL (VAL.UOM,
                      (SELECT UM.UNIT_OF_MEASURE_TL
                         FROM MTL_UNITS_OF_MEASURE UM
                        WHERE UM.UOM_CODE = VAL.UOM_CODE))
                     UOM,
                 (SELECT UM.UNIT_OF_MEASURE_TL
                    FROM MTL_UNITS_OF_MEASURE_TL UM
                   WHERE UM.LANGUAGE = 'RU' AND UM.UOM_CODE = VAL.UOM_CODE)
                     UOM_DESC,
                 (SELECT UM.UNIT_OF_MEASURE_TL
                    FROM MTL_UNITS_OF_MEASURE_TL UM
                   WHERE UM.LANGUAGE = 'RU' AND UM.UOM_CODE = VAL.VOLUME_UOM)
                     VOLUME_UOM_DESC,
                 (SELECT UM.UNIT_OF_MEASURE_TL
                    FROM MTL_UNITS_OF_MEASURE_TL UM
                   WHERE UM.LANGUAGE = 'RU' AND UM.UOM_CODE = VAL.WEIGHT_UOM)
                     WEIGHT_UOM_DESC,
                 VAL.Declarant1_Id,
                 VAL.Declarant2_Id,
                 XXTG_CREATING_ITEM_PKG.GET_NAME (VAL.Declarant1_ID)
                     DeclarantId_NAME1,
                 XXTG_CREATING_ITEM_PKG.GET_NAME (VAL.Declarant2_ID)
                     DeclarantId_NAME2,
                 AssetCatSeg1,
                 AssetCatSeg2,
                 AssetCatSeg3,
                 AssetCatSeg4,
                 AssetCatSeg5,
                 (SELECT ffvv.flex_value || '-' || ffvv.DESCRIPTION
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_FA_MODE'
                         AND ffvv.flex_value = AssetCatSeg1)
                     AssetSegDesc1,
                 (SELECT ffvv.flex_value || '-' || ffvv.DESCRIPTION
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_FA_GROUP'
                         AND ffvv.flex_value = AssetCatSeg2)
                     AssetSegDesc2,
                 (SELECT ffvv.flex_value || '-' || ffvv.DESCRIPTION
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_FA_SUBGROUP'
                         AND ffvv.flex_value = AssetCatSeg3)
                     AssetSegDesc3,
                 (SELECT ffvv.flex_value || '-' || ffvv.DESCRIPTION
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_FA_TYPE'
                         AND ffvv.flex_value = AssetCatSeg4)
                     AssetSegDesc4,
                 (SELECT ffvv.flex_value || '-' || ffvv.DESCRIPTION
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name =
                             'XXTG_FA_ACCOUNTING_GROUP'
                         AND ffvv.flex_value = AssetCatSeg5)
                     AssetSegDesc5                               -------------
                                  ,
                 (SELECT FV.DESCRIPTION
                    FROM FND_FLEX_VALUE_SETS FVS, FND_FLEX_VALUES_VL FV
                   WHERE     FVS.FLEX_VALUE_SET_NAME = 'XXTG_GROUP_OF_ITEM'
                         AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
                         AND FV.FLEX_VALUE = VAL.GROUP_OF_ITEMS)
                     GROUP_OF_ITEMS_DES,
                 VAL.ASSET_CATEGORY14_APP_USER_ID,
                 XXTG_CREATING_ITEM_PKG.GET_NAME_IO (
                     VAL.ASSET_CATEGORY14_APP_USER_ID)
                     ASSET_CATEGORY14_APP_USER_USER,
                 (SELECT ffvv.flex_value || ' [' || ffvv.DESCRIPTION || ']'
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_ACCOUNT'
                         AND ffvv.flex_value = MCAT.ATTRIBUTE1)
                     LOCAL_ACCOUNT,
                 (SELECT ffvv.flex_value || ' [' || ffvv.DESCRIPTION || ']'
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_EAM_GROUP'
                         AND ffvv.flex_value = MCAT.ATTRIBUTE14)
                     EAM_GROUP,
                 (SELECT ffvv.flex_value || ' [' || ffvv.DESCRIPTION || ']'
                    FROM apps.fnd_flex_values_vl ffvv,
                         apps.fnd_flex_value_sets ffvs
                   WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
                         AND ffvs.flex_value_set_name = 'XXTG_EAM_TYPE'
                         AND ffvv.PARENT_FLEX_VALUE_LOW = MCAT.ATTRIBUTE14
                         AND ffvv.flex_value = MCAT.ATTRIBUTE15)
                     EAM_TYPE,
                 (SELECT ffv.flex_value || ' [' || ffv.DESCRIPTION || ']'
                    FROM apps.fnd_flex_values_vl ffv,
                         apps.fnd_flex_value_sets ffs
                   WHERE     ffv.flex_value_set_id = ffs.flex_value_set_id
                         AND ffs.flex_value_set_name = 'XXTG_ACCOUNT'
                         AND ffv.flex_value =
                             (SELECT FV.ATTRIBUTE1
                                FROM FND_FLEX_VALUE_SETS FVS,
                                     FND_FLEX_VALUES_VL FV
                               WHERE     FVS.FLEX_VALUE_SET_NAME =
                                         'XXTG_GROUP_OF_ITEM'
                                     AND FVS.FLEX_VALUE_SET_ID =
                                         FV.FLEX_VALUE_SET_ID
                                     AND FV.FLEX_VALUE = VAL.GROUP_OF_ITEMS))
                     TMC_LOC_ACCOUNT,
                 VAL.FILE_ID,
                 (SELECT MCT.DESCRIPTION
                    FROM MTL_CATEGORIES_TL MCT
                   WHERE     MCT.CATEGORY_ID(+) = MCAT.CATEGORY_ID
                         AND MCT.LANGUAGE(+) = USERENV ('LANG'))
                     PO_CAT_DESC
            FROM XXTG_ITEM_CREATION_ATTR_VAL VAL, MTL_CATEGORIES_B_KFV MCAT
           WHERE     1 = 1
                 AND MCAT.ENABLED_FLAG(+) = 'Y'
                 AND MCAT.STRUCTURE_ID(+) = 201
                 AND MCAT.CATEGORY_ID(+) = VAL.GROUP_PO_CATEOGRY_ID) QRSLT,
         XXTG_ITEM_CREATION_HDR ICHDR
   WHERE     QRSLT.CREATION_DATE >=
             TO_DATE ('01.01.2021 23:59:00', 'dd.mm.yyyy hh24:mi:ss')
         AND ((ICHDR.HEADER_ID = QRSLT.HEADER_ID))
         AND ICHDR.FILE_ID = 948689 -- ID Загрузки
ORDER BY QRSLT.CREATION_DATE