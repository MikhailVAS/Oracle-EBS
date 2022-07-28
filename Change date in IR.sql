/* Formatted on 21.11.2018 20:23:33 (QP5 v5.318) Service Desk 251759 Mihail.Vasiljev */
UPDATE wsh.wsh_new_deliveries
   SET initial_pickup_date =
           TO_DATE ('21.11.2018 09:00:00', 'dd.mm.yyyy HH24:MI:ss')
 WHERE name IN ('СЖ 0203759')
 

/* Formatted on 21.11.2018 20:38:48 (QP5 v5.318) Service Desk 256391 Mihail.Vasiljev */
UPDATE inv.mtl_material_transactions
   SET attribute13 = '2018/11/21 09:00:00'                       -- 21.11.2018
                                          ,
       transaction_date =
           TO_DATE ('21.11.2018 9:00:00', 'dd.mm.yyyy HH24:MI:ss') -- income order
 WHERE TRANSACTION_ID IN (
                          34444725,
                          34444721,
                          34429077,
                          34429076,
                          34429068,
                          34429067)