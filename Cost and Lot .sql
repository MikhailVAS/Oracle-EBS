--############# FORM Additional Cost Allocation ############# 
/* Alloc Headers */
SELECT *
  FROM XXTG_ADDC_ALLOC_HEADERS
 WHERE ADDC_ALLOCATION_ID IN (8826);

/* Alloc Lines */
SELECT *
  FROM XXTG_ADDC_ALLOC_LINES
 WHERE ADDC_ALLOCATION_ID IN (8826);

/* Alloc source document */
SELECT *
  FROM XXTG_ADDC_ALLOC_SOURCE_INV
 WHERE ADDC_ALLOCATION_ID IN (8826);

UPDATE XXTG_ADDC_ALLOC_HEADERS SET ALLOC_STATUS = 'S' WHERE ADDC_ALLOCATION_ID IN (8828,8829,8827,8826,8797);

 /* Additional cost allocation (View pars)*/
SELECT xah.RECEIPT_NUM,
       xal.addc_allocation_id,
       xal.invoice_distribution_id,
       xal.inventory_item_id,
       xal.precise_layer_cost,
       xal.new_layer_cost,
       xal.unit_addc_cost_amount,
       xal.cost_update_txn_id,
       xal.created_by,
       xal.creation_date,
       xal.last_updated_by,
       xal.last_update_date,
       xal.last_update_login,
       msi.segment1,
       msi.description,
       xal.ROWID                             row_id,
       NVL (aid.base_amount, aid.amount)     pre_alloc_amount,
       aid.quantity_invoiced,
       aid.unit_price,
       cil.inv_layer_id,
       mmt.cost_group_id,
       xal.cost_adj_error,
       cil.layer_cost                        current_cost,
       cil.layer_quantity,
       aid.dist_code_combination_id,
       xah.*
  FROM xxtg_addc_alloc_lines         xal,
       xxtg_addc_alloc_headers       xah,
       mtl_system_items_b            msi,
       ap_invoice_distributions_all  aid,
       rcv_transactions              rt,
       mtl_material_transactions     mmt,
       cst_inv_layers                cil
 WHERE     xah.addc_allocation_id = xal.addc_allocation_id
       AND msi.inventory_item_id = xal.inventory_item_id
       AND msi.organization_id = xah.organization_id
       AND aid.invoice_distribution_id = xal.invoice_distribution_id
       AND rt.parent_transaction_id = aid.rcv_transaction_id
       AND rt.transaction_type = 'DELIVER'
       AND mmt.rcv_transaction_id = rt.transaction_id
       AND cil.create_transaction_id = mmt.transaction_id
       AND msi.segment1 = '3705081038'
       AND xah.RECEIPT_NUM = '33710932(ENG24030501)'
 
 --########################################################## 


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


/* Search and auto-correct of cost */
DECLARE
BEGIN
    FOR r
        IN (SELECT DISTINCT cil.create_transaction_id,
                            mtlnn.lot_number,
                            cil.inventory_item_id,
                            msib.segment1,
                            cil.layer_cost,
                            mt.organization_id,
                            mt.source_code,
                            cil.inv_layer_id
             FROM inv.mtl_transaction_lot_numbers  mtlnn,
                  bom.cst_inv_layers               cil,
                  inv.mtl_material_transactions    mt,
                  inv.mtl_system_items_b           msib,
                  XXTG.xxtg_unit_cost              xuc
            WHERE     cil.create_transaction_id = mt.transaction_id
                  AND xuc.LOT_NUMBER(+) = mtlnn.lot_number
                  AND cil.organization_id = mt.organization_id
                  AND cil.inventory_item_id = mt.inventory_item_id
                  AND msib.inventory_item_id = cil.inventory_item_id
                  AND mt.transaction_quantity >= 0
                  AND mtlnn.transaction_id = mt.transaction_id
                  AND xuc.LOT_NUMBER IS NULL
                  AND mt.source_code = 'RCV')
    LOOP
        INSERT INTO XXTG.XXTG_UNIT_COST (UNIT_COST_ID,
                                         INVENTORY_ITEM_ID,
                                         LOT_NUMBER,
                                         UNIT_COST,
                                         CURRENCY_CODE,
                                         MODE#,
                                         DATE_FROM,
                                         DATE_TO,
                                         INV_LAYER_ID,
                                         CREATION_DATE,
                                         FIRST_TRANSACTION_DATE,
                                         CREATE_TRANSACTION_ID,
                                         DATE_OF_CHANGE)
                 VALUES (
                            XXTG.XXTG_UNIT_COST_S.nextval,
                            r.inventory_item_id,
                            r.lot_number,
                            r.layer_cost,
                            'BYN',
                            0,
                            TO_DATE ('7/1/2016', 'MM/DD/YYYY'),
                            TO_DATE ('1/1/2100', 'MM/DD/YYYY'),
                            r.inv_layer_id,
                            TO_DATE ('8/14/2023 2:24:12 PM',
                                     'MM/DD/YYYY HH:MI:SS AM'),
                            TO_DATE ('8/13/2023', 'MM/DD/YYYY'),
                            r.create_transaction_id,
                            TO_DATE ('8/14/2023 2:24:12 PM',
                                     'MM/DD/YYYY HH:MI:SS AM'));

        DBMS_OUTPUT.put_line ('ISSUANCE_ID:' || r.inventory_item_id || ' ' || r.lot_number);
        COMMIT;
    END LOOP;
END;