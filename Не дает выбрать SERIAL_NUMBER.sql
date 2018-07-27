-- Проверка 
SELECT DISTINCT  msn.group_mark_id,
       msn.line_mark_id,
       msn.lot_line_mark_id,
       msn.RESERVATION_ID
       --, msn.*
  FROM inv.mtl_serial_numbers msn
 WHERE     1 = 1
       and CURRENT_SUBINVENTORY_CODE = '5044'
       --and CURRENT_STATUS = 3
     --  AND msn.serial_number IN
     --         ('893750302179596811')


/* Formatted on 04.10.2017 14:06:10 (QP5 v5.294) Service Desk 152729 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE     1 = 1
       AND serial_number IN
              ('893750302179596811')