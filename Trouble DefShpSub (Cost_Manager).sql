--CSTPLCIN.COST_INV_TXN:CSTPLVCP.interorg (160): ORA-00001: unique constraint (INV.MTL_CST_TXN_COST_DETAILS_U1) violated
--CSTPLCIN.COST_INV_TXN:CSTPLENG.create_layers (100): ORA-00001: unique constraint (INV.MTL_CST_LAYER_ACT_CST_DTLS_U1) violated
  

delete from APPS.MTL_CST_TXN_COST_DETAILS where transaction_id in (select transfer_transaction_id from INV.mtl_material_transactions where  transaction_id in (   select transaction_id
   from INV.mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01012018', 'ddmmyyyy') and to_date('01022018', 'ddmmyyyy')
));

delete from APPS.MTL_CST_LAYER_ACT_COST_DETAILS  where transaction_id in (select transfer_transaction_id from INV.mtl_material_transactions where  transaction_id in (   select transaction_id
   from INV.mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01012018', 'ddmmyyyy') and to_date('01022018', 'ddmmyyyy')
));

/* Formatted on 20.02.2018 11:44:19 (QP5 v5.163.1008.3004) */
UPDATE INV.mtl_material_transactions MMT
   SET MMT.costed_flag = 'N',
       MMT.ERROR_CODE = NULL,
       MMT.error_explanation = NULL
 WHERE NOT EXISTS
          (SELECT 1
             FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
            WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
       AND transaction_id IN
              (SELECT transaction_id
                 FROM INV.mtl_material_transactions MMT
                WHERE TRANSACTION_TYPE_ID = 54        -- Int Order Direct Ship
                      AND NOT EXISTS
                             (SELECT 1
                                FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
                               WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
                      AND transaction_date BETWEEN TO_DATE ('01012018',
                                                            'ddmmyyyy')
                                               AND TO_DATE ('01022018',
                                                            'ddmmyyyy'));

UPDATE INV.mtl_material_transactions MMT
   SET MMT.costed_flag = 'N',
       MMT.ERROR_CODE = NULL,
       MMT.error_explanation = NULL
 WHERE NOT EXISTS
          (SELECT 1
             FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
            WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
       AND transaction_id IN
              (SELECT transfer_transaction_id
                 FROM INV.mtl_material_transactions MMT
                WHERE TRANSACTION_TYPE_ID = 54        -- Int Order Direct Ship
                      AND NOT EXISTS
                             (SELECT 1
                                FROM INV.MTL_TRANSACTION_ACCOUNTS MTA
                               WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
                      AND transaction_date BETWEEN TO_DATE ('01012018',
                                                            'ddmmyyyy')
                                               AND TO_DATE ('01022018',
                                                            'ddmmyyyy'));



/*

select transaction_id, transfer_transaction_id, costed_flag, request_id,  trx_source_line_id, transaction_source_type_id, TRANSFER_ORGANIZATION_ID, error_code, error_explanation, transaction_action_id, primary_quantity, creation_date from
 mtl_material_transactions MMT  
    where MMT.transaction_id in (   select transaction_id
   from mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01012018', 'ddmmyyyy') and to_date('01022018', 'ddmmyyyy'))
    union all
select transaction_id, transfer_transaction_id, costed_flag, request_id,  trx_source_line_id, transaction_source_type_id, TRANSFER_ORGANIZATION_ID, error_code, error_explanation, transaction_action_id, primary_quantity, creation_date from
 mtl_material_transactions MMT  
    where MMT.transaction_id in (   select transfer_transaction_id
   from mtl_material_transactions MMT
   where TRANSACTION_TYPE_ID = 54 -- Int Order Direct Ship
    and NOT  EXISTS ( SELECT 1
    FROM MTL_TRANSACTION_ACCOUNTS MTA
    WHERE MMT.TRANSACTION_ID = MTA.TRANSACTION_ID)
    and transaction_date between to_date('01012018', 'ddmmyyyy') and to_date('01022018', 'ddmmyyyy'))    
    
    */