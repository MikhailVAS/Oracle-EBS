
SELECT mti.SOURCE_CODE, -- will be inserted into inv.MTL_SERIAL_NUMBERS_INTERFACE
       mti.SOURCE_LINE_ID, -- will be inserted into inv.MTL_SERIAL_NUMBERS_INTERFACE
       mti.LAST_UPDATE_DATE, -- will be inserted into inv.MTL_SERIAL_NUMBERS_INTERFACE
       mti.LAST_UPDATE_LOGIN, -- will be inserted into inv.MTL_SERIAL_NUMBERS_INTERFACE
       mli.SERIAL_TRANSACTION_TEMP_ID, -- will be used as key indentifier under which all info above will be entered
       mti.TRANSACTION_INTERFACE_ID
  FROM inv.MTL_TRANSACTIONS_INTERFACE      mti,
       inv.MTL_TRANSACTION_LOTS_INTERFACE  mli
 WHERE     1 = 1
       AND transaction_header_id = 9216946 -- trx_header_id, can be act_header, transaction_set_id, etc
       AND mti.transaction_interface_id = 9216959 --trx_interface_id = trx_lot_interface_id
       AND mti.TRANSACTION_INTERFACE_ID = mli.TRANSACTION_INTERFACE_ID


SELECT mli.SERIAL_TRANSACTION_TEMP_ID, mli.*
  FROM inv.MTL_TRANSACTION_LOTS_INTERFACE mli
 WHERE mli.TRANSACTION_INTERFACE_ID = 9216961

  SELECT GROUP_ID, QUANTITY, c.*
    FROM rcv_transactions_interface c
   WHERE 1 = 1                                  --processing_mode_code='BATCH'
               AND CREATION_DATE >= TO_DATE ('25.06.2022', 'dd.mm.yyyy')
ORDER BY creation_date DESC;


SELECT mti.*
  FROM inv.MTL_TRANSACTIONS_INTERFACE mti
 WHERE mti.TRANSACTION_INTERFACE_ID IN (29184199, 29360618)


SELECT sn.*
  FROM inv.MTL_SERIAL_NUMBERS_INTERFACE sn
 WHERE sn.TRANSACTION_INTERFACE_ID = 9216961


UPDATE inv.MTL_TRANSACTION_LOTS_INTERFACE mli
   SET mli.SERIAL_TRANSACTION_TEMP_ID = 9216961
 -- select mli.SERIAL_TRANSACTION_TEMP_ID, mli.*
 -- from inv.MTL_TRANSACTION_LOTS_INTERFACE mli
 WHERE mli.TRANSACTION_INTERFACE_ID = 9216959

SELECT *
  FROM inv.MTL_SERIAL_NUMBERS_INTERFACE
 WHERE transaction_interface_id = 9216961



