/* Formatted on 30.07.2020 15:23:43 (QP5 v5.326) Service Desk 406689 Mihail.Vasiljev */
/* Не отображается в отчёте BeST OnHand Quantity */ 
UPDATE inv.mtl_system_items_b
   SET ATTRIBUTE21 = NULL
 WHERE SEGMENT1 IN ('1013070537','1013070536')