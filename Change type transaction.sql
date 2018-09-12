/* Find Type transactions */
SELECT DISTINCT TRANSACTION_TYPE_ID, TRANSACTION_TYPE_NAME, DESCRIPTION
  FROM INV.MTL_TRANSACTION_TYPES
 WHERE TRANSACTION_TYPE_NAME LIKE '%XXTG RETURN ItemInUsg W/O %'

	
/* Formatted on 12.09.2018 14:50:50 (QP5 v5.318) */
UPDATE inv.mtl_material_transactions
   SET TRANSACTION_TYPE_ID = 763
 WHERE transaction_set_id IN ('33660200')
 
 	
/* Formatted on 12.09.2018 14:50:47 (QP5 v5.318) */
UPDATE inv.mtl_transaction_accounts
   SET TRANSACTION_TYPE_ID = 763
 WHERE transaction_set_id IN ('33660200')