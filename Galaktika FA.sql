/* инфа для загрузки айтемов*/
SELECT DISTINCT NAME_PRODUCT,
       CASE GROUP_OF_ITEMS
           WHEN 'комплектующие к ОС 0705001' THEN '0705001'
           WHEN 'Запасные части к БС после демонтажа 100511' THEN '100511'
           WHEN 'Запасные части к БС после ремонта 100512' THEN '100512'
           WHEN 'лом и отходы содержащие драг. металлы 1015011' THEN '1015011'
           ELSE 'Other GROUP_OF_ITEMS'
       END
           AS "GROUP_OF_ITEMS",
       NUMBER_ITEM,
        CASE UOM
           WHEN 'метр' THEN 'Meters'
           WHEN 'Комплект' THEN 'Set'
           WHEN 'компл.' THEN 'Set'
           WHEN 'штук' THEN 'Each'
           ELSE 'Other UOM'
       END
           AS "UOM",
       UOM AS "UOM_RUS",
       ACCOUNT
  FROM APPS.XXTG_LOAD_LOGISTICS_FINAL la
 WHERE ITEM_NUM_ORA IS NULL