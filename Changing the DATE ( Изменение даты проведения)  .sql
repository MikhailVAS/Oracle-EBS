
/* Date Transactions */
UPDATE inv.mtl_material_transactions
   SET attribute13 = '2018.02.08 09:00:00'
 WHERE 1 = 1 AND transaction_set_id IN ('32109547',
'32107192',
'32107183',
'32107173',
'32107164',
'32107153',
'32106141',
'32106130');
 
/* Shipping Initial_pickup_date */
UPDATE wsh.wsh_new_deliveries
   SET INITIAL_PICKUP_DATE =
          TO_DATE ('08.02.2018 9:00:00', 'dd.mm.yyyy hh.mi.ss')
 WHERE name IN ('ХК 0585157');