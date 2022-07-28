/* Formatted on 23.07.2019 12:26:56 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
UPDATE xxtg.xxtg_otf_headers_all a
   SET a.status = 'APPROVED'
 WHERE a.otf_number IN ('%');
 
/*Прошу убрать из формы на утверждение платежей те платежи, которые прошли стадию утверждения и оплачены в системе:
По столбцу Payment Data не должны выпадать данные за 01-11-18 ,19-02-2019, 25-02-2019, 21-03-2019, 10-04-2019, 17-04-2019, 25-06-2019  */ 
SELECT *
  FROM xxtg.xxtg_otf_headers_all
 WHERE     STATUS <> ('APPROVED')
       AND PAYMENT_DATE IN (TO_DATE ('01-11-2018', 'dd-mm-yyyy'),
                            TO_DATE ('19-02-2019', 'dd-mm-yyyy'),
                            TO_DATE ('25-02-2019', 'dd-mm-yyyy'),
                            TO_DATE ('21-03-2019', 'dd-mm-yyyy'),
                            TO_DATE ('10-04-2019', 'dd-mm-yyyy'),
                            TO_DATE ('17-04-2019', 'dd-mm-yyyy'),
                            TO_DATE ('25-06-2019', 'dd-mm-yyyy'))
--AND OTF_NUMBER = 638277 -- Request No

/* Formatted on 23.07.2019 13:00:57 (QP5 v5.326) Service Desk 306180 Mihail.Vasiljev */
UPDATE xxtg.xxtg_otf_headers_all a
   SET a.status = 'APPROVED'
 WHERE     STATUS = 'REVISE'                                -- <> ('APPROVED')
       AND PAYMENT_DATE IN (TO_DATE ('01-11-2018', 'dd-mm-yyyy'),
                            TO_DATE ('19-02-2019', 'dd-mm-yyyy'),
                            TO_DATE ('25-02-2019', 'dd-mm-yyyy'),
                            TO_DATE ('21-03-2019', 'dd-mm-yyyy'),
                            TO_DATE ('10-04-2019', 'dd-mm-yyyy'),
                            TO_DATE ('17-04-2019', 'dd-mm-yyyy'),
                            TO_DATE ('25-06-2019', 'dd-mm-yyyy'))