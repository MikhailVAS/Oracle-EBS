  
 /* Formatted on 11.10.2017 10:20:16 (QP5 v5.294) Service Desk  Mihail.Vasiljev */
DELETE FROM inv.MTL_SERIAL_NUMBERS_INTERFACE
      WHERE TRANSACTION_INTERFACE_ID IN
               (SELECT SERIAL_TRANSACTION_TEMP_ID
                  FROM inv.MTL_TRANSACTION_LOTS_INTERFACE
                 WHERE TRANSACTION_INTERFACE_ID IN
                          (SELECT TRANSACTION_INTERFACE_ID
                             FROM inv.MTL_TRANSACTIONS_INTERFACE
                            WHERE     1 = 1
                                  AND transaction_header_id IN ('31155402')
                          ))

/* Formatted on 11.10.2017 10:51:24 (QP5 v5.294) Service Desk  Mihail.Vasiljev */
DELETE FROM inv.MTL_TRANSACTION_LOTS_INTERFACE
      WHERE TRANSACTION_INTERFACE_ID IN
               (SELECT TRANSACTION_INTERFACE_ID
                  FROM inv.MTL_TRANSACTIONS_INTERFACE
                 WHERE 1 = 1 AND transaction_header_id IN ('31155402'))

/* Formatted on 11.10.2017 10:51:32 (QP5 v5.294) Service Desk  Mihail.Vasiljev */
DELETE FROM inv.MTL_TRANSACTIONS_INTERFACE
      WHERE 1 = 1 AND transaction_header_id IN ('31155402')
      
           
/* Formatted on 11.10.2017 11:00:42 (QP5 v5.294) Service Desk  Mihail.Vasiljev */
INSERT INTO inv.MTL_SERIAL_NUMBERS_INTERFACE (TRANSACTION_INTERFACE_ID,
                                              SOURCE_CODE,
                                              SOURCE_LINE_ID,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY,
                                              CREATION_DATE,
                                              CREATED_BY,
                                              FM_SERIAL_NUMBER,
                                              TO_SERIAL_NUMBER)
     VALUES (31169154,
             'ORDER ENTRY',
             782702,
             TO_DATE ('12.09.2017 10:04:46', '.dd.mm.yyyy HH24:MI:ss'),
             -1,
             TO_DATE ('12.09.2017 10:04:46', '.dd.mm.yyyy HH24:MI:ss'),
             -1,
             '359836070804764',
             '359836070804764')
             
/* Formatted on 11.10.2017 11:01:56 (QP5 v5.294) Service Desk 152254 Mihail.Vasiljev */
UPDATE inv.MTL_TRANSACTION_LOTS_INTERFACE mli
   SET mli.SERIAL_TRANSACTION_TEMP_ID = mli.TRANSACTION_INTERFACE_ID
 -- select mli.SERIAL_TRANSACTION_TEMP_ID, mli.*
 -- from inv.MTL_TRANSACTION_LOTS_INTERFACE mli
 WHERE mli.TRANSACTION_INTERFACE_ID IN (31169154)
 
/* Formatted on 11.10.2017 11:32:14 (QP5 v5.294) Service Desk 152254 Mihail.Vasiljev */
 DELETE MTL_RESERVATIONS WHERE RESERVATION_ID = 9551350 