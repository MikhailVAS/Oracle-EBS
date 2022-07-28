
/*
Остатки по терминальному оборудованию на 01.01.2019
Необходимо выгрузить остатки по терминальному оборудованию на 01.01.2019 по всем складам BDW по группам ТМЦ 1001003,1001004,1013003,1013004,1013005. Отчет должен содержать:
серийный номер, номенклатурный номер, наименование ТМЦ, склад хранения, партия, кол-во, цена, сумма.
*/


--DROP TABLE BSTMVASILIEV.xxtg_inv036_list2;

--DROP TABLE BSTMVASILIEV.xxtg_inv036_serial_2;

CREATE TABLE BSTMVASILIEV.xxtg_inv036_list2 AS SELECT * FROM xxtg.xxtg_inv036_list;

CREATE TABLE BSTMVASILIEV.xxtg_inv036_serial_2 AS SELECT * FROM xxtg.xxtg_inv036_serial_list_ig;

TRUNCATE table BSTMVASILIEV.xxtg_inv036_list2;

 TRUNCATE table BSTMVASILIEV.xxtg_inv036_serial_2;
 

/*Наполнение темповых таблиц*/
DECLARE
   l_result   BOOLEAN;
BEGIN
   apps.XXTG_INV036_PKG.P_ITEM_TYPE_2 := 'XXTG_SIM';
   apps.XXTG_INV036_PKG.P_ITEM_TYPE_1 := 'XXTG_INV';
   apps.XXTG_INV036_PKG.P_LOT_CONTROL := 'Y';
   apps.XXTG_INV036_PKG.P_SHOW_SERIALS := 'Y';
   FOR i IN (            SELECT 84 AS org_id FROM DUAL
             --             UNION ALL
             --             SELECT 83 FROM DUAL
             --             UNION ALL
            --              SELECT 85 FROM DUAL
			--             UNION ALL
            --             SELECT 86 FROM DUAL
            )
   LOOP
      FOR j IN (SELECT '1001003' AS item_id FROM DUAL
                UNION ALL
                SELECT '1001004' FROM DUAL
                UNION ALL
                SELECT '1013003' FROM DUAL
                UNION ALL
                SELECT '1013004' FROM DUAL
                UNION ALL
                SELECT '1013005' FROM DUAL)
      LOOP
         FOR l IN (SELECT '2019/01/01 00:00:00' AS l_date FROM DUAL)
         LOOP
            apps.XXTG_INV036_PKG.P_ORGANIZATION_ID := i.org_id;
            apps.XXTG_INV036_PKG.P_ITEM_CATEGORY_ID := j.item_id;
            apps.XXTG_INV036_PKG.P_DATE := l.l_date;
            l_result := apps.XXTG_INV036_PKG.beforereport ();
            IF l_result
            THEN
               INSERT INTO BSTMVASILIEV.xxtg_inv036_list2
                  SELECT * FROM xxtg.xxtg_inv036_list;
               INSERT INTO BSTMVASILIEV.xxtg_inv036_serial_2
                  SELECT * FROM xxtg.xxtg_inv036_serial_list_ig;
               COMMIT;
            END IF;
         END LOOP;
      END LOOP;
   END LOOP;
END;
  


/* Вывод данных */
SELECT mp.organization_code
      ,t.DESCRIPTION as GROUP_OF_ITEM
      ,xil.item_code
      ,xil.uom_name
      ,xil.trans_cost
      ,xil.trans_amount
      ,xil.trans_quantity
      ,xil.item_id
      ,xil.item_name
      ,xil.subinv
      ,CASE
         WHEN NVL(:P_LOT_CONTROL, 'N') = 'N' AND NVL(:P_SHOW_SERIALS, 'N') = 'N'
           THEN ''
         ELSE xil.lot_number
       END AS lot_number
      ,xsl.serial_number       
  FROM inv.mtl_parameters mp, inv.mtl_system_items_b SI,applsys.fnd_flex_values b, applsys.fnd_flex_values_tl t, BSTMVASILIEV.xxtg_inv036_list2 xil
  LEFT OUTER JOIN BSTMVASILIEV.xxtg_inv036_serial_2 xsl
    on xsl.org_id = xil.org_id
   AND xsl.subinv = xil.subinv
   AND xsl.item_id = xil.item_id
   AND NVL(xsl.lot_number, 'XXX') = NVL(xil.lot_number, 'XXX') 
where 1=1
and mp.organization_id = xil.org_id
and SI.organization_id = xil.org_id  
and SI.inventory_item_id=xil.item_id
and SI.ATTRIBUTE6 = b.FLEX_VALUE and b.value_category = 'XXTG_GROUP_OF_ITEM'
and t.flex_value_id = b.flex_value_id 
AND t.language = 'RU'
 ORDER BY xsl.SERIAL_NUMBER,xil.org_id, xil.subinv, xil.item_code, xil.lot_number    