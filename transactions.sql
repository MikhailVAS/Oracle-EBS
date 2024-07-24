/* Update recreate accounting material trx*/
UPDATE xla_events
   SET event_status_code = 'U', process_status_code = 'I'
 WHERE ENTITY_ID IN
           (SELECT ENTITY_ID
              FROM xla.xla_transaction_entities
             WHERE     entity_code = 'MTL_ACCOUNTING_EVENTS'
                   AND SOURCE_ID_INT_1 IN
                           (SELECT transaction_id
                              --transfer_transaction_id
                              FROM mtl_material_transactions mmt
                             WHERE transaction_set_id IN (47006803,
                                                          47007333,
                                                          47015298,
                                                          47015310,
                                                          47015323)));

 /* Find all Material Transaction by Item and Delivery */
SELECT TRANSACTION_ID -- Block find TR by Move Order
  FROM mtl_material_transactions
 WHERE     INVENTORY_ITEM_ID IN (SELECT DISTINCT INVENTORY_ITEM_ID
                                   FROM inv.mtl_system_items_b a
                                  WHERE a.SEGMENT1 IN ('1051100972')) -- Item
       AND TRANSACTION_SOURCE_ID IN
               (SELECT DISTINCT TXN_SOURCE_ID
                 FROM MTL_TXN_REQUEST_LINES MTRL
                WHERE LINE_ID IN
                          (SELECT MOVE_ORDER_LINE_ID
                            FROM WSH_DELIVERY_DETAILS
                           WHERE             --SOURCE_HEADER_NUMBER = '318318'
                                 DELIVERY_DETAIL_ID IN
                                     (SELECT DISTINCT TDA.DELIVERY_DETAIL_ID
                                       FROM WSH.WSH_DELIVERY_ASSIGNMENTS  TDA,
                                            WSH.WSH_NEW_DELIVERIES        TND
                                      WHERE     TND.name IN ('ЮВ 1589984')   --Deliver Name TTN
                                            AND TDA.DELIVERY_ID =
                                                TND.DELIVERY_ID)))
UNION ALL
SELECT TRANSACTION_ID --Block find TR by Internal Req
  FROM mtl_material_transactions
 WHERE INVENTORY_ITEM_ID IN
           (SELECT DISTINCT INVENTORY_ITEM_ID
             FROM inv.mtl_system_items_b a
            WHERE     a.SEGMENT1 IN ('1051100972')  -- Item
                  AND TRANSACTION_SOURCE_ID IN
                          (SELECT SOURCE_DOCUMENT_ID -- IR 1585784 TRANSACTION_SOURCE_ID
                            FROM oe_order_headers_all oh
                           WHERE --ORDER_NUMBER = '318318'  --  Internal.ORDER ENTRY
                                 oh.HEADER_ID IN
                                     (SELECT SOURCE_HEADER_ID
                                       FROM WSH_DELIVERY_DETAILS
                                      WHERE  --SOURCE_HEADER_NUMBER = '318318'
                                            DELIVERY_DETAIL_ID IN
                                                (SELECT DISTINCT
                                                        TDA.DELIVERY_DETAIL_ID
                                                  FROM WSH.WSH_DELIVERY_ASSIGNMENTS
                                                       TDA,
                                                       WSH.WSH_NEW_DELIVERIES
                                                       TND
                                                 WHERE     TND.name IN
                                                               ('ЮВ 1589984')   --Deliver Name TTN
                                                       AND TDA.DELIVERY_ID =
                                                           TND.DELIVERY_ID))))                                                         

/* Mass update Account in material transactions by Group of Item*/
UPDATE inv.mtl_material_transactions mt
   SET ATTRIBUTE14 = (SELECT fv.ATTRIBUTE1
  FROM applsys.fnd_flex_values fv, applsys.fnd_flex_value_sets fvs
 WHERE     fvs.flex_value_set_id = fv.flex_value_set_id
       AND fvs.flex_value_set_name = 'XXTG_GROUP_OF_ITEM'
       AND FLEX_VALUE =   (SELECT DISTINCT ab.ATTRIBUTE6 FROM        
  				 inv.mtl_system_items_b ab
							 WHERE ab.INVENTORY_ITEM_ID =  mt.INVENTORY_ITEM_ID)) 
 WHERE transaction_set_id IN (47342043)

 /* Formatted on (QP5 v5.326) Service Desk 599955  Mihail.Vasiljev */
UPDATE inv.mtl_transaction_accounts mta
   SET RATE_OR_AMOUNT =
           (SELECT UNIT_COST
              FROM XXTG.xxtg_unit_cost UC
             WHERE UC.CREATE_TRANSACTION_ID = mta.TRANSACTION_ID),
       BASE_TRANSACTION_VALUE =
             primary_quantity
           * (SELECT UNIT_COST
                FROM XXTG.xxtg_unit_cost UC
               WHERE UC.CREATE_TRANSACTION_ID = mta.TRANSACTION_ID)
 WHERE transaction_id IN (SELECT TRANSACTION_ID
                            FROM mtl_material_transactions mmt
                           WHERE transaction_set_id IN (47342043))

/*====================== Deleet one serial in inv transaction ====================*/
/* Formatted on (QP5 v5.326) Service Desk 604949 Mihail.Vasiljev */
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET TRANSACTION_QUANTITY = -8, PRIMARY_QUANTITY = 8
 WHERE TRANSACTION_ID = '47552153'

/* Formatted on (QP5 v5.326) Service Desk 604949 Mihail.Vasiljev */
UPDATE MTL_TRANSACTION_LOT_NUMBERS
   SET TRANSACTION_QUANTITY = -8, PRIMARY_QUANTITY = 8
 WHERE (TRANSACTION_ID = '47552153')
 
/* Formatted on (QP5 v5.326) Service Desk 604949 Mihail.Vasiljev */
DELETE FROM MTL_UNIT_TRANSACTIONS
      WHERE     TRANSACTION_ID = '47552154'
            AND SERIAL_NUMBER = '893412701137609666'

/*==================================================================================*/ 
                             

/* Find dublicate in transactions */
  SELECT INVENTORY_ITEM_ID, MAX (TRANSACTION_ID), MIN (TRANSACTION_ID)
    FROM inv.mtl_material_transactions
   WHERE transaction_set_id IN (36947655) AND ORGANIZATION_ID = 84
GROUP BY INVENTORY_ITEM_ID
  HAVING COUNT (TRANSACTION_ID) > 1

/* Все типы трнзакции */
SELECT TRANSACTION_TYPE_ID, TRANSACTION_TYPE_NAME, DESCRIPTION
  FROM inv.MTL_TRANSACTION_TYPES
  (SELECT TRANSACTION_TYPE_NAME
  FROM APPS.MTL_TRANSACTION_TYPES MTT
  WHERE MTT.TRANSACTION_TYPE_ID=MMT.TRANSACTION_TYPE_ID
  )TRANSACTION_TYPE

  /* All transaction type */
SELECT TRANSACTION_TYPE_ID, TRANSACTION_TYPE_NAME, DESCRIPTION
  FROM inv.MTL_TRANSACTION_TYPES
  WHERE TRANSACTION_TYPE_NAME LIKE '%Dealer SCRATCH %' 

/* Change type in transactions */
UPDATE inv.mtl_material_transactions
   SET Transaction_TYPE_ID = 561                   --  XXTG Flagship Equip W/O
 WHERE transaction_set_id IN (32684144, 32692853)

 /* Find Internal Requisition by material transaction  */
SELECT ORIG_SYS_DOCUMENT_REF     AS "Internal Req"
  FROM oe_order_headers_all oeh, mtl_material_transactions mmt
 WHERE     mmt.TRANSACTION_SOURCE_ID = oeh.SOURCE_DOCUMENT_ID
       AND mmt.transaction_id = '47242030'

 /* All Transactions in one cell*/
SELECT LISTAGG (TRANSACTION_ID, ', ') WITHIN GROUP (ORDER BY TRANSACTION_ID)
           "TR_ID"
  FROM inv.mtl_material_transactions
 WHERE 1 = 1 AND transaction_set_id IN (32684144, 32692853)

/* Редкая ситуация , если в тр один тип а в учёте другой (Изменения типа в учёте)*/
UPDATE inv.mtl_transaction_accounts
   SET TRANSACTION_TYPE_ID = 322
 WHERE transaction_set_id IN ('32687656')
 
 /* Accounts > 3 lines*/
  SELECT TRANSACTION_ID, COUNT (TRANSACTION_ID)
    FROM inv.MTL_TRANSACTION_ACCOUNTS
   WHERE TRANSACTION_DATE BETWEEN TO_DATE ('01.12.2018', 'dd.mm.yyyy')
                              AND TO_DATE ('01.02.2019', 'dd.mm.yyyy')
--   TRANSACTION_ID = (36276638)
GROUP BY TRANSACTION_ID
  HAVING COUNT (*) > 3

/* Formatted on Internal order (QP5 v5.326) Service 572350 Desk Mihail.Vasiljev */
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET TRANSACTION_SET_ID = '46952470'  
--SELECT * FROM   INV.MTL_MATERIAL_TRANSACTIONS 
WHERE TRANSACTION_SOURCE_ID = 1573811
AND SOURCE_CODE = 'ORDER ENTRY'
 
/* Formatted on Internal requisition (QP5 v5.326) Service Desk 572350 Mihail.Vasiljev */
UPDATE INV.MTL_MATERIAL_TRANSACTIONS
   SET TRANSACTION_SET_ID = '46952470'
--SELECT * FROM   INV.MTL_MATERIAL_TRANSACTIONS 
WHERE TRANSACTION_SOURCE_ID = 1554054   

/* Transaction date for Open period*/
UPDATE inv.mtl_material_transactions
   SET transaction_date = CAST ((transaction_date + 71) AS DATE)
 WHERE     TRANSACTION_SOURCE_ID = 1593160
       AND TRANSACTION_DATE > TO_DATE ('22.03.2023', 'dd.mm.yyyy')

SELECT 
MSIB.SEGMENT1       AS ITEM,
  CIDV.ORGANIZATION_CODE   AS ORG,
  MMT.TRANSACTION_QUANTITY AS QTY,
  MMT.TRANSACTION_DATE,
  MMT.ATTRIBUTE14,
  MMT.SOURCE_CODE AS TRANSACTION_TYPE,
  MTLV.LOT_NUMBER,
  MTLV.GRADE_CODE,
  MTLV.EXPIRATION_DATE AS EXP_DATE,
  MUTV.SERIAL_NUMBER,
  CIDV.BASE_TRANSACTION_VALUE AS TRX_VALUE,
  CIDV.UNIT_COST
FROM MTL_MATERIAL_TRANSACTIONS MMT,
  MTL_TRANSACTION_LOT_VAL_V MTLV,
  MTL_UNIT_TRANSACTIONS_ALL_V MUTV,
  CST_INV_DISTRIBUTION_V CIDV,
  MTL_SYSTEM_ITEMS_B MSIB
WHERE MMT.ORGANIZATION_ID       = MSIB.ORGANIZATION_ID
AND MMT.INVENTORY_ITEM_ID       = MSIB.INVENTORY_ITEM_ID
AND MMT.TRANSACTION_ID          = CIDV.TRANSACTION_ID
AND MMT.TRANSACTION_ID          = MTLV.TRANSACTION_ID(+)
AND MTLV.SERIAL_TRANSACTION_ID  = MUTV.TRANSACTION_ID(+)
AND MMT.ORGANIZATION_ID         = CIDV.ORGANIZATION_ID
AND MMT.transaction_id = '46658490'
 
/* Просмотр транзакций в БД */
  SELECT transaction_set_id,
         SHIPMENT_NUMBER,
         mt.ORGANIZATION_ID,
         SOURCE_CODE,
         TRX_SOURCE_LINE_ID,
         mt.ATTRIBUTE14,
         mt.ATTRIBUTE15,
         cr.user_name AS CREATED_BY,
         UP.user_name AS UpDated_BY,
         transaction_id,
         transaction_set_id,
         TRANSACTION_DATE,
         Transaction_TYPE_ID,
         SOURCE_CODE,
         mt.INVENTORY_ITEM_ID,
         IC.segment1,
         mt.attribute13,
         mt.ATTRIBUTE14,
         mt.ATTRIBUTE15,
         mt.shipment_number,
         mt.*
    FROM inv.mtl_material_transactions mt,
         applsys.fnd_user             cr,
         applsys.fnd_user             UP,
         inv.mtl_system_items_b       IC
   WHERE     mt.CREATED_BY = cr.user_id
         AND mt.LAST_UPDATED_BY = UP.user_id
         AND mt.ORGANIZATION_ID = IC.ORGANIZATION_ID
         AND mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
         --and   mt.transaction_date = to_date ('31.10.2015','dd.mm.yyyy')
         --and   mt.ORGANIZATION_ID = 83
         --and   IC.segment1 = '10130050146'
         --and INVENTORY_ITEM_ID in (253485)
         --and TRANSACTION_SOURCE_ID = 394638
         -- and transaction_set_id in (26535218)
         AND transaction_id IN (26918719)
         --and TRANSACTION_TYPE_ID = 199
         --and SUBINVENTORY_CODE ='ItemsInUsg'
         --and TRANSFER_SUBINVENTORY='Tuda'
ORDER BY mt.TRANSACTION_DATE, SUBINVENTORY_CODe, SEGMENT1

--=========================== Find All Serial in transactions  ===========================
SELECT mut.serial_number,
       mmt.transaction_id,
       mmt.transaction_type_id,
       mmt.transaction_quantity,
       mtln.lot_number
  FROM mtl_material_transactions    mmt,
       mtl_transaction_lot_numbers  mtln,
       mtl_unit_transactions        mut
 WHERE     mmt.transaction_id = mtln.transaction_id
       AND mtln.serial_transaction_id = mut.transaction_id
       AND mmt.transaction_id IN
               (SELECT transaction_id
                  FROM inv.mtl_material_transactions  mt,
                       inv.mtl_system_items_b         IC
                 WHERE     mt.ORGANIZATION_ID = IC.ORGANIZATION_ID
                       AND mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
                       AND IC.segment1 = '1006633385')

--=========================== Find all non serial transactions by Serial item ===========================
SELECT *
  FROM inv.mtl_material_transactions mt, inv.mtl_system_items_b IC
 WHERE     mt.ORGANIZATION_ID = IC.ORGANIZATION_ID
       AND mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
       AND IC.segment1 = '1006633385'
       AND transaction_id NOT IN
               (SELECT mmt.transaction_id
                  FROM mtl_material_transactions    mmt,
                       mtl_transaction_lot_numbers  mtln,
                       mtl_unit_transactions        mut
                 WHERE     mmt.transaction_id = mtln.transaction_id
                       AND mtln.serial_transaction_id = mut.transaction_id
                       AND mmt.transaction_id IN
                               (SELECT transaction_id
                                  FROM inv.mtl_material_transactions  mt,
                                       inv.mtl_system_items_b         IC
                                 WHERE     mt.ORGANIZATION_ID =
                                           IC.ORGANIZATION_ID
                                       AND mt.INVENTORY_ITEM_ID =
                                           IC.INVENTORY_ITEM_ID
                                       AND IC.segment1 = '1006633385'))

/* Formatted on 05.06.2019 13:43:28 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM inv.mtl_material_transactions mmt
 WHERE     transaction_date BETWEEN to_date('01.05.2019','dd.mm.yyyy')  AND to_date('31.05.2019','dd.mm.yyyy') 
       AND ORGANIZATION_ID = 83
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT MSIB.INVENTORY_ITEM_ID
                                  FROM APPS.MTL_SYSTEM_ITEMS_B MSIB
                                 WHERE MSIB.segment1 IN ('1013110920'))
 

SELECT LOT_NUMBER,
       (SELECT DISTINCT SEGMENT1
          FROM inv.mtl_system_items_b a
         WHERE a.INVENTORY_ITEM_ID = mt.INVENTORY_ITEM_ID)
           AS Item,
       ABS (mt.TRANSACTION_QUANTITY)
  FROM inv.mtl_material_transactions mt, inv.mtl_transaction_lot_numbers mtln
 WHERE     mtln.TRANSACTION_ID = mt.TRANSACTION_ID
       AND mt.TRANSACTION_ID IN
               (SELECT TRANSACTION_ID
                  FROM inv.mtl_material_transactions
                 WHERE     1 = 1
                       AND Transaction_set_id IN ('37120669', '37115118')
                       AND TRANSACTION_QUANTITY < 0
                       AND TRANSACTION_ID NOT IN
                               (SELECT TRANSACTION_ID
                                  FROM inv.mtl_material_transactions
                                 WHERE     1 = 1
                                       AND Transaction_set_id IN
                                               ('37120669', '37115118')
                                       AND TRANSACTION_QUANTITY < 0
                                       AND ATTRIBUTE14 = '0001'))
									   
/*Find cost variance 003 and lot  */
SELECT TA.TRANSACTION_ID,TRANSACTION_SET_ID, TA.TRANSACTION_DATE, TA.BASE_TRANSACTION_VALUE,mt.ORGANIZATION_ID,SUBINVENTORY_CODE,','||chr(39)||mtl.LOT_NUMBER||chr(39)
  FROM INV.MTL_TRANSACTION_ACCOUNTS TA,inv.mtl_material_transactions mt
  join inv.mtl_transaction_lot_numbers mtl on mt.transaction_id = mtl.transaction_id
 WHERE     TA.TRANSACTION_ID = mt.TRANSACTION_ID                          -- TRANSACTION_SET_ID IN ('39990974')
       AND TA.ACCOUNTING_LINE_TYPE = 13
       AND TA.REFERENCE_ACCOUNT = 1005
       AND TA.TRANSACTION_DATE BETWEEN TO_DATE ('01.12.2019', 'dd.mm.yyyy')
                                AND TO_DATE ('31.12.2019', 'dd.mm.yyyy')
       AND TA.BASE_TRANSACTION_VALUE > 0
	   
	   
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

/* Mass update date in transactions */
DECLARE
BEGIN

update mtl_material_transactions
set attribute13 = '2020.04.25 13:36:38'
where transaction_type_id = 112
and inventory_item_id = 569723
and trunc(transaction_date) = to_date('04052020', 'ddmmyyyy');
commit;

FOR rec IN (select transaction_id from mtl_material_transactions where transaction_type_id = 112
and inventory_item_id = 569723
and trunc(transaction_date) = to_date('04052020', 'ddmmyyyy') and TRANSACTION_QUANTITY < 0) 
LOOP
    xxtg_inv_common_pkg.update_trx_GL_date(rec.transaction_id);
commit;
END LOOP;
END;

--====================================================================
/* Formatted on  (QP5 v5.326) Service Desk 544691 Mihail.Vasiljev */
/* Mass update date in transactions */
DECLARE
BEGIN
    UPDATE mtl_material_transactions
       SET attribute13 = '2021.11.24 00:00:00'
     WHERE transaction_set_id IN ('46267084', '46259677');

    COMMIT;

    FOR rec
        IN (SELECT transaction_id
              FROM mtl_material_transactions
             WHERE     transaction_set_id IN ('46267084', '46259677')
                   AND TRANSACTION_QUANTITY < 0)
    LOOP
        xxtg_inv_common_pkg.update_trx_GL_date (rec.transaction_id);
        COMMIT;
    END LOOP;
END;


--SELECT * FROM  mtl_material_transactions
--where transaction_set_id in ('46267084','46259677')
--====================================================================

/* Find all material transactions by Sales order*/
SELECT *
  FROM inv.mtl_material_transactions
 WHERE transaction_set_id IN
           (SELECT DISTINCT osh.SHIP_ID
             FROM xxtg_oe_ship_hdr  osh
                  JOIN xxtg_oe_ship_line osl ON osl.ship_id = osh.ship_id
                  JOIN oe_order_lines_all ol ON ol.line_id = osl.oe_line_id
                  JOIN oe_order_headers_all oh ON oh.header_id = ol.header_id
            WHERE oh.ORDER_NUMBER IN ('287344',
                                      '287708',
                                      '287745'))


/*Storno transactions by singl transactions*/
begin
xxtg_online_transaction_storno.transaction_storno_by_set(48499477, 'SINGLE');
end;