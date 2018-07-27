/* Получение  INVOICE_DISTRIBUTION по инвойсу и линии*/
SELECT INVOICE_DISTRIBUTION_ID, A.*
  FROM APPS.AP_INVOICE_DISTRIBUTIONS_ALL A
 WHERE invoice_id = '565826' AND (invoice_line_number = '1')
 
/* Обнуление неккоретного DISTRIBUTIONS */
UPDATE APPS.AP_INVOICE_DISTRIBUTIONS_ALL
   SET AMOUNT = 0, BASE_AMOUNT = 0
 WHERE     1 = 1
       AND INVOICE_DISTRIBUTION_ID IN ('3074429',
                                       '3074430',
                                       '3074431',
                                       '3074815',
                                       '3074816',
                                       '3074817');