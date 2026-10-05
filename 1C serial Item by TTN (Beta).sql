/* 3 */
ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';

/* 1 */
ALTER SESSION SET NLS_LANGUAGE = 'RUSSIAN';

/* 2  Выгрузка по ТТН только серийного */
SELECT DISTINCT
       sn.LAST_TRANSACTION_ID,
--       mmt.SHIPMENT_NUMBER,
       si.secondary_inventory_name
           SUB_CODE,
       si.customer_name
           SUB_NAME,
       msi.description
           "Наименование",
       msi.long_description
           "НаименованиеПолное",
       NVL ( (SELECT c_attribute1
                FROM MTL_LOT_NUMBERS
               WHERE LOT_NUMBER = onh.lot_number AND ORGANIZATION_ID = '83'),
            sn.serial_number)
           "Штрихкод",
       sn.serial_number
           "Характеристика",
       msi.segment1
           "Артикул",
       --                  onh.lot_number,
       --         msi.segment1 "Штрихкод",
        (SELECT (SELECT DESCRIPTION
                  FROM fnd_flex_values_tl ffvt
                 WHERE     ffv.flex_value_id = ffvt.flex_value_id
                       AND ffvt.language = 'RU')    "VALUE_DESCRIPTION RU"
           FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv
          WHERE     ffvs.flex_value_set_id = ffv.flex_value_set_id
                AND ffvs.flex_value_set_id =
                    (SELECT DISTINCT FLEX_VALUE_SET_ID
                      FROM applsys.fnd_flex_value_sets fvs
                     WHERE fvs.flex_value_set_name =
                           NVL (UPPER ('XXTG_GROUP_OF_ITEM'),
                                flex_value_set_name))
                AND ffv.flex_value = msi.ATTRIBUTE6
                AND ffv.ATTRIBUTE1 IS NOT NULL
                AND ffv.END_DATE_ACTIVE IS NULL)
           "Группа",
       percentage_rate
           "СтавкаНДС",
       1
           "Остаток",
       NULL
           "Поставщик",
       (SELECT ATTRIBUTE5
          FROM MTL_LOT_NUMBERS
         WHERE LOT_NUMBER = onh.lot_number AND ORGANIZATION_ID = '83')
           "СтранаПроисхождения",
       uc.UNIT_COST
           "ЦенаУчетная",
       (SELECT OPERAND
         FROM APPS.qp_list_lines_v
        WHERE     LIST_HEADER_ID =
                  (SELECT QPHB.LIST_HEADER_ID
                    FROM QP_LIST_HEADERS_B QPHB, QP_LIST_HEADERS_TL QPHT
                   WHERE     QPHB.LIST_HEADER_ID = QPHT.LIST_HEADER_ID
                         AND QPHT.NAME =
                             'Flagship Equipment Price List (BYN)'
                         AND LANGUAGE = 'US')
              AND PRODUCT_ATTR_VAL_DISP = msi.segment1
              AND PRODUCT_ATTR_VALUE = TO_CHAR (msi.INVENTORY_ITEM_ID)
              AND END_DATE_ACTIVE IS NULL)
           "ЦенаРозничная",
       (SELECT c_attribute1
          FROM MTL_LOT_NUMBERS
         WHERE LOT_NUMBER = sn.lot_number AND ORGANIZATION_ID = '83')
           "GTIN",
       NVL (msi.ATTRIBUTE12, NULL)
           "ТН ВЭД"
  FROM MTL_ONHAND_QUANTITIES_DETAIL  onh,
       MTL_SERIAL_NUMBERS            sn,
       MTL_SYSTEM_ITEMS_VL           MSI,
       XXTG_SECONDARY_INVENTORIES_V  si,
       xxtg.xxtg_unit_cost           uc,
       ZX.zx_rates_b                 r
 WHERE     sn.current_organization_id = onh.organization_id
       AND sn.lot_number = onh.lot_number
       AND sn.inventory_item_id = onh.inventory_item_id
       AND sn.current_subinventory_code = onh.subinventory_code
       AND sn.CURRENT_STATUS != '4'
       AND sn.LAST_TRANSACTION_ID IN
               (SELECT TRANSACTION_ID
                 FROM mtl_material_transactions mmt
                WHERE     mmt.ORGANIZATION_ID = '83'
                      AND mmt.SHIPMENT_NUMBER = 'ФБ 1618014')
       AND msi.inventory_item_id = onh.inventory_item_id
       AND msi.organization_id = onh.organization_id
       AND msi.serial_number_control_code != '1'
       AND si.organization_id = onh.organization_id
       AND si.SECONDARY_INVENTORY_NAME = onh.subinventory_code
       AND uc.INVENTORY_ITEM_ID = onh.inventory_item_id
       AND uc.LOT_NUMBER = onh.LOT_NUMBER
       AND r.tax_rate_code = NVL (msi.attribute7, 'VAT20 REVENUE')
       AND uc.CURRENCY_CODE = 'BYN'
       AND onh.organization_id = 84
       AND onh.subinventory_code IN ('ФЛГ_ЦО')                  --like '%ФЛГ%'
--       AND msi.segment1 = '1013521527' --- 1013070965 3 Шт   -- 1013520936 2 шт
--         and onh.subinventory_code not like  ('%кнсг%')