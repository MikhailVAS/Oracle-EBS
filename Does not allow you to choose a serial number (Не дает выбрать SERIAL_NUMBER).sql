-- Checking (Проверка)
SELECT DISTINCT  msn.group_mark_id,
       msn.line_mark_id,
       msn.lot_line_mark_id,
       msn.RESERVATION_ID
       --, msn.*
  FROM inv.mtl_serial_numbers msn
 WHERE     1 = 1
       and CURRENT_SUBINVENTORY_CODE = '9999'
       --and CURRENT_STATUS = 3
     --  AND msn.serial_number IN
     --         ('12312312312312312')


/* Formatted (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE     1 = 1
       AND serial_number IN
              ('12312312312312312')