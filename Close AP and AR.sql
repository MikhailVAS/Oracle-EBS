/* check AP */
SELECT *
  FROM xla.xla_events
 WHERE     event_status_code <> 'P'
       AND event_date BETWEEN TO_DATE ('01.10.2018', 'DD.MM.YYYY')
                          AND TO_DATE ('31.10.2018', 'DD.MM.YYYY')
       AND application_id = 200;

/* check AR */
SELECT *
  FROM xla.xla_events
 WHERE     event_status_code <> 'P'
       AND event_date BETWEEN TO_DATE ('01.10.2018', 'DD.MM.YYYY')
                          AND TO_DATE ('31.10.2018', 'DD.MM.YYYY')
       AND application_id = 222;

/* Close AP and AR period */ 
/* Formatted on 18.10.2018 12:03:21 (QP5 v5.318) Service Desk  248067 Mihail.Vasiljev */
UPDATE APPS.gl_period_statuses
   SET closing_status = 'C'
 WHERE     period_name IN ('SEP-18')
       AND application_id IN (200, 222)
       AND set_of_books_id IN (2022, 2047)
	   
/* Какие Документы*/
SELECT DESCRIPTION
  FROM xla.xla_ae_headers xah
 WHERE xah.event_id IN (5996513, 5996515, 5980710)