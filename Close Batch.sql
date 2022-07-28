/* Formatted on 01/08/2018 11:10:20 (QP5 v5.318) */
UPDATE ap.ap_inv_selection_criteria_all
   SET ATTRIBUTE13 = '7'
 WHERE checkrun_name IN ('17 07 18 т', '19 07 18 t', '26 07 18 t')
 
 
/* Formatted on 01/08/2018 11:11:59 (QP5 v5.318) */
SELECT aisc.ATTRIBUTE13, aisc.*    --   SET ATTRIBUTE13 = '7' - Закрытый бетч
  FROM ap.ap_inv_selection_criteria_all aisc

 WHERE checkrun_name IN ('17 07 18 т', '19 07 18 t', '26 07 18 t')