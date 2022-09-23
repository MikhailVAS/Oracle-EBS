/* ============ Проверка layer_cost   ============  */
SELECT distinct
--cil.create_transaction_id, mtlnn.lot_number, cil.inv_layer_id, cil.inventory_item_id , msib.segment1,  cil.layer_cost, mt.organization_id, mt.subinventory_code, mt.source_code, mt.transaction_type_id, mt.transaction_date
msib.segment1, mtlnn.lot_number, cil.layer_cost
from inv.mtl_transaction_lot_numbers mtlnn, bom.cst_inv_layers cil, inv.mtl_material_transactions mt , inv.mtl_system_items_b msib
where 1=1
and cil.create_transaction_id = mt.transaction_id 
and cil.organization_id = mt.organization_id
and cil.inventory_item_id = mt.inventory_item_id 
and msib.inventory_item_id = cil.inventory_item_id
and mt.transaction_quantity >= 0 
and mtlnn.transaction_id = mt.transaction_id 
and mtlnn.lot_number = '160503ZTE_Corporation._Z047761'
order by 1, 2

/* ============ Проверка в транзакции   ============  */
select * from  inv.mtl_transaction_accounts
where 1=1
and transaction_id =  '35711988'

/* ============ Проверка xxtg_unit_cost  ============  */
SELECT *
  FROM XXTG.xxtg_unit_cost
 WHERE LOT_NUMBER = '160503ZTE_Corporation._Z047761'
 
 --################################################################################

 /* Formatted on (QP5 v5.318) Service Desk 474929 Mihail.Vasiljev */
UPDATE BOM.CST_INV_LAYERS a
   SET a.layer_cost = 7.44
 WHERE     1 = 1
       AND CREATE_TRANSACTION_ID IN
               (SELECT DISTINCT cil.create_transaction_id
                  FROM inv.mtl_transaction_lot_numbers  mtlnn,
                       bom.cst_inv_layers               cil,
                       inv.mtl_material_transactions    mt,
                       inv.mtl_system_items_b           msib
                 WHERE     1 = 1
                       AND cil.create_transaction_id = mt.transaction_id
                       AND cil.organization_id = mt.organization_id
                       AND cil.inventory_item_id = mt.inventory_item_id
                       AND msib.inventory_item_id = cil.inventory_item_id
                       AND mt.transaction_quantity >= 0
                       AND mtlnn.transaction_id = mt.transaction_id
                       AND mtlnn.lot_number =
                           '30/08/2010Huawei Tc029692_f930')
       AND a.layer_cost != 7.44


/* Formatted on 15.01.2019 14:04:48 (QP5 v5.318) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_transaction_accounts
   SET RATE_OR_AMOUNT = 130.46,
       BASE_TRANSACTION_VALUE = primary_quantity * 130.46
 WHERE transaction_id = '35711988'

/* Formatted on (QP5 v5.318) Service Desk 474929 Mihail.Vasiljev */
UPDATE XXTG.xxtg_unit_cost
   SET UNIT_COST = 7.44
 --select * from xxtg_unit_cost
 WHERE LOT_NUMBER = '30/08/2010Huawei Tc029692_f930'
 AND CURRENCY_CODE = 'BYN'

 /* Formatted on 13.09.2022 16:36:08 (QP5 v5.326) Service Desk Mihail.Vasiljev */
UPDATE BOM.CST_INV_LAYERS a
   SET a.layer_cost =
           (SELECT unit_cost
              FROM xxtg_unit_cost
             WHERE     lot_number =
                       '211207Комплектование427284'
                   AND CURRENCY_CODE =
                       XXTG_GL_CURRENCY_PKG.get_default_currency)
 WHERE     1 = 1
       AND CREATE_TRANSACTION_ID IN
               (SELECT DISTINCT cil.create_transaction_id
                  FROM inv.mtl_transaction_lot_numbers  mtlnn,
                       bom.cst_inv_layers               cil,
                       inv.mtl_material_transactions    mt,
                       inv.mtl_system_items_b           msib
                 WHERE     1 = 1
                       AND cil.create_transaction_id = mt.transaction_id
                       AND cil.organization_id = mt.organization_id
                       AND cil.inventory_item_id = mt.inventory_item_id
                       AND msib.inventory_item_id = cil.inventory_item_id
                       AND mt.transaction_quantity >= 0
                       AND mtlnn.transaction_id = mt.transaction_id
                       AND mtlnn.lot_number =
                           '211207Комплектование427284')
       AND a.layer_cost !=
           (SELECT unit_cost
              FROM xxtg_unit_cost
             WHERE     lot_number =
                       '211207Комплектование427284'
                   AND CURRENCY_CODE =
                       XXTG_GL_CURRENCY_PKG.get_default_currency)

--################################################################################

/* Formatted on 14.11.2018 16:38:55 (QP5 v5.318) Service Desk 254751 Mihail.Vasiljev */
UPDATE mtl_transaction_accounts mta1
   SET rate_or_amount =
          (SELECT (SELECT DISTINCT ROUND (unit_cost, 2)
                     FROM xxtg_unit_cost uc
                    WHERE     uc.inventory_item_id = mmt.inventory_item_id
                          AND uc.LOT_NUMBER = mtln.LOT_NUMBER
                          AND CURRENCY_CODE = 'BYN'--and rownum = 1
                  )
                     utc_cost
             --sum(base_transaction_value) inv_cost
             FROM mtl_material_transactions mmt,
                  mtl_transaction_accounts mta,
                  mtl_transaction_lot_numbers mtln
            WHERE     1 = 1
                  AND mta.transaction_id = mmt.transaction_id
                  AND accounting_line_type = 2
                  AND mtln.inventory_item_id = mmt.inventory_item_id
                  AND mtln.transaction_id = mmt.transaction_id
                  AND mmt.transaction_id = mta1.transaction_id)
 WHERE mta1.transaction_id IN (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE transaction_set_id = 34013364);
                  
/* Formatted on 14.11.2018 16:38:55 (QP5 v5.318) Service Desk 254751 Mihail.Vasiljev */
UPDATE mtl_transaction_accounts mta1
   SET base_transaction_value = primary_quantity * rate_or_amount
 WHERE mta1.transaction_id IN (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE transaction_set_id = 34013364);
								
/* (QP5 v5.326) Service Desk  Mihail.Vasiljev
   1) Update correct layers cost by xxtg_unit_cost
   2) Update to correct mtl_transaction_accounts 
   3) Delete 0003 Variance zero accounting in  mtl_transaction_accounts */
BEGIN
    FOR AAA_LOT_NUMBER
        IN (SELECT mtl.LOT_NUMBER AS NEW_LOT, mt.TRANSACTION_ID AS TR_ID
              FROM INV.MTL_TRANSACTION_ACCOUNTS   TA,
                   inv.mtl_material_transactions  mt
                   JOIN inv.mtl_transaction_lot_numbers mtl
                       ON mt.transaction_id = mtl.transaction_id
             WHERE     TA.TRANSACTION_ID = mt.TRANSACTION_ID
                   AND TA.ACCOUNTING_LINE_TYPE = 13
                   AND TA.REFERENCE_ACCOUNT = 1005
                   AND TA.TRANSACTION_DATE BETWEEN TO_DATE ('01.12.2019',
                                                            'dd.mm.yyyy')
                                               AND TO_DATE ('31.12.2019',
                                                            'dd.mm.yyyy')
                   AND TA.BASE_TRANSACTION_VALUE != 0
                   --       AND mtl.LOT_NUMBER = '18/03/2010Huawei_Interna023920'
                                                     )
    LOOP
        UPDATE BOM.CST_INV_LAYERS a
           SET a.layer_cost =
                   (SELECT UNIT_COST
                      FROM XXTG.xxtg_unit_cost
                     WHERE     LOT_NUMBER = AAA_LOT_NUMBER.NEW_LOT
                           AND CURRENCY_CODE = 'BYN')
         WHERE     1 = 1
               AND CREATE_TRANSACTION_ID IN
                       (SELECT DISTINCT cil.create_transaction_id
                          FROM inv.mtl_transaction_lot_numbers  mtlnn,
                               bom.cst_inv_layers               cil,
                               inv.mtl_material_transactions    mt,
                               inv.mtl_system_items_b           msib
                         WHERE     1 = 1
                               AND cil.create_transaction_id =
                                   mt.transaction_id
                               AND cil.organization_id = mt.organization_id
                               AND cil.inventory_item_id =
                                   mt.inventory_item_id
                               AND msib.inventory_item_id =
                                   cil.inventory_item_id
                               AND mt.transaction_quantity >= 0
                               AND mtlnn.transaction_id = mt.transaction_id
                               AND mtlnn.lot_number = AAA_LOT_NUMBER.NEW_LOT)
               AND a.layer_cost !=
                   (SELECT UNIT_COST
                      FROM XXTG.xxtg_unit_cost
                     WHERE     LOT_NUMBER = AAA_LOT_NUMBER.NEW_LOT
                           AND CURRENCY_CODE = 'BYN');

        DBMS_OUTPUT.put_line (
               'UPDATE CST_INV_LAYERS by LOT                                       '
            || AAA_LOT_NUMBER.NEW_LOT);

        UPDATE inv.mtl_transaction_accounts
           SET RATE_OR_AMOUNT =
                   (SELECT UNIT_COST
                      FROM XXTG.xxtg_unit_cost
                     WHERE     LOT_NUMBER = AAA_LOT_NUMBER.NEW_LOT
                           AND CURRENCY_CODE = 'BYN'),
               BASE_TRANSACTION_VALUE =
                     primary_quantity
                   * (SELECT UNIT_COST
                        FROM XXTG.xxtg_unit_cost
                       WHERE     LOT_NUMBER = AAA_LOT_NUMBER.NEW_LOT
                             AND CURRENCY_CODE = 'BYN')
         WHERE transaction_id = AAA_LOT_NUMBER.TR_ID;

        DBMS_OUTPUT.put_line (
               'UPDATE mtl_transaction_accounts by TRANSACTION_ID   '
            || AAA_LOT_NUMBER.TR_ID);

        DELETE FROM INV.MTL_TRANSACTION_ACCOUNTS
              WHERE     TRANSACTION_ID IN (AAA_LOT_NUMBER.TR_ID)
                    AND ACCOUNTING_LINE_TYPE = 13
                    AND REFERENCE_ACCOUNT = 1005;

        DBMS_OUTPUT.put_line (
               'DELETE Cost Variance 003 by TRANSACTION_ID                '
            || AAA_LOT_NUMBER.TR_ID);
         DBMS_OUTPUT.put_line (
               '________________________________________________________________');
    END LOOP;
END;