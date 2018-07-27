/* Исправление для SD 198104 Доступность Плана и освобождение ТТН для последующего выбора*/
UPDATE APPS.xxtg_plans_rcv_hdr
   SET parent_plan_rcv_id = NULL, RECEIPT_NUM = 'АД 0047790777' ---АД 0047790
 WHERE plan_rcv_id IN (2928)

 UPDATE APPS.xxtg_plans_rcv_hdr
   SET RECEIPT_NUM = 'АД 0047790777' ---АД 0047790                                     
 WHERE plan_rcv_id in (2928)
                      
UPDATE APPS.xxtg_plans_rcv_hdr
   SET parent_plan_rcv_id = NULL                                       
 WHERE plan_rcv_id in (2928)

/* Поиск номеров Batch с разными длинами с/н мменьше правильной длины (18) */
  SELECT COUNT (lot_number),
         lot_number,
         CAST (LENGTH (serial_number) AS VARCHAR (25))
    FROM inv.mtl_serial_numbers a
   WHERE     1 = 1
         AND lot_number BETWEEN '12785' AND '12884'
         AND LENGTH (serial_number) < 18
         AND INVENTORY_ITEM_ID = 524836
--  AND serial_number = 8937503011899000
--  893750301180099000
GROUP BY lot_number, LENGTH (serial_number)
ORDER BY CAST (LENGTH (serial_number) AS VARCHAR (25))

/* Formatted on 31.01.2018 12:21:52 (QP5 v5.294) Service Desk 178697 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'00'||SUBSTR(serial_number,12,LENGTH(serial_number)) -- 16
 WHERE     1 = 1
       AND lot_number BETWEEN '12785' and '12884' /* Batch No */ 
       AND LENGTH (serial_number) = 16
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted on 31.01.2018 13:42:33 (QP5 v5.294) Service Desk 178697 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 15
 WHERE     1 = 1
       AND lot_number BETWEEN '12785' and '12884' /* Batch No */ 
       AND LENGTH (serial_number) = 15
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted on 31.01.2018 13:42:33 (QP5 v5.294) Service Desk 178697 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'0000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 14
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 14
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted on 31.01.2018 14:12:25 (QP5 v5.294) Service Desk 178697 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'00000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 13
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 13
       AND INVENTORY_ITEM_ID = 524836;    
          
/* Formatted on 31.01.2018 14:31:57 (QP5 v5.294) Service Desk 178697 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'000000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 12
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 12
       AND INVENTORY_ITEM_ID = 524836; 