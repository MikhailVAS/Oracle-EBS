/* XXTG_BILLING_FILE */
SELECT *
  FROM XXTG.XXTG_BILLING_FILE BF, xxtg.xxtg_plans PL
 WHERE 1 = 1 AND PL.PLAN_NO = '0119' AND BF.PLAN_ID = PL.PLAN_ID

/* XXTG_vendor_file*/
SELECT *
  FROM XXTG.XXTG_vendor_file VF, xxtg.xxtg_plans PL
 WHERE 1 = 1 AND VF.PLAN_ID = PL.PLAN_ID AND PL.PLAN_NO = '0119'
 
/* For both organizations, for item=Lot-Serial-Controlled-1 , inventory_item_id=169845 
and LOT_CONTROL='Y' and SERIAL_CONTROL='Dynamic at INV receipt'*/
SELECT mp.organization_id
           Org_Id,
       mp.organization_code
           Org_Code,
       msi.inventory_item_id,
       msi.segment1,
       DECODE (TO_CHAR (msi.lot_control_code),  '2', 'Y',  '1', 'N')
           LOT_CONTROL,
       DECODE (TO_CHAR (msi.serial_number_control_code),
               '1', 'None',
               '2', 'Predefined',
               '5', 'Dynamic at INV receipt',
               '6', 'Dynamic at SO issue')
           SERIAL_CONTROL
  FROM mtl_system_items_b msi, mtl_parameters mp
 WHERE msi.segment1 LIKE '&item' AND msi.organization_id = mp.organization_id;

/* Исправление для SD  Доступность Плана и освобождение ТТН для последующего выбора*/
UPDATE APPS.xxtg_plans_rcv_hdr
   SET parent_plan_rcv_id = NULL, RECEIPT_NUM = 'АД7790777' ---АД 7790777
 WHERE plan_rcv_id IN (2928)

 UPDATE APPS.xxtg_plans_rcv_hdr
   SET RECEIPT_NUM = 'АД 7790777' ---АД 7790777                                     
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
--  AND serial_number = 89375030118999999

GROUP BY lot_number, LENGTH (serial_number)
ORDER BY CAST (LENGTH (serial_number) AS VARCHAR (25))

/* Formatted  (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'00'||SUBSTR(serial_number,12,LENGTH(serial_number)) -- 16
 WHERE     1 = 1
       AND lot_number BETWEEN '12785' and '12884' /* Batch No */ 
       AND LENGTH (serial_number) = 16
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted  (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 15
 WHERE     1 = 1
       AND lot_number BETWEEN '12785' and '12884' /* Batch No */ 
       AND LENGTH (serial_number) = 15
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted  (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'0000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 14
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 14
       AND INVENTORY_ITEM_ID = 524836;
       
/* Formatted (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'00000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 13
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 13
       AND INVENTORY_ITEM_ID = 524836;    
          
/* Formatted (QP5 v5.294) Service Desk  Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers a
   SET serial_number = SUBSTR(serial_number,1,11)||'000000'||SUBSTR(serial_number,12,LENGTH(serial_number))-- 12
 WHERE     1 = 1
       AND lot_number in ('12785') /* Batch No */ 
       AND LENGTH (serial_number) = 12
       AND INVENTORY_ITEM_ID = 524836; 

/* Formatted on 18.02.2022 15:30:47 (QP5 v5.326) Service Desk 561238 Mihail.Vasiljev */
UPDATE APPS.XXTG_ITEM_MATCH_HDR SET 
STATUS = '20' ,-- 10
TO_ORGANIZATION_ID = '86', -- Null
TO_SUBINVENTORY = 'Transit', -- Null
SERVICE_COST = '0', -- Null
--TTN_NUMBER = '777у.', -- Null
--TTN_DATE = to_date('09.02.2022','dd.mm.yyyy')  -- Null
 WHERE  HDR_ID = '22069'


 /* Formatted on 23.02.2022 10:04:41 (QP5 v5.326) Service Desk 561499 Mihail.Vasiljev */
UPDATE APPS.XXTG_ITEM_MATCH_HDR
   SET STATUS = '40',                                                    -- 10
       TO_ORGANIZATION_ID = '86',                                      -- Null
       TO_SUBINVENTORY = 'Transit',                                    -- Null
       SERVICE_COST = '0'                                              -- Null
 --TTN_NUMBER = '777у.', -- Null
 --TTN_DATE = to_date('09.02.2022','dd.mm.yyyy')  -- Null
 WHERE HDR_ID IN ('22064', '22066')