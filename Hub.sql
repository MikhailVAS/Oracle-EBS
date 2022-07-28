/* Update status in HUB */
UPDATE APPS.xxtg_hub_events
   SET STATUS = 'NEW'
 WHERE EVENT_ID = 49157
 
 SELECT * FROM  APPS.xxtg_hub_events hev,
                  APPS.xxtg_hub_sources_v src,
                  APPS.xxtg_hub_ap_invoices hai,
                  APPS.po_vendors pv,
                  APPS.fnd_lookups fl
            WHERE     src.source = hev.source
                  AND hai.event_id = hev.event_id
                  AND pv.vendor_id = hai.vendor_id
                  AND fl.lookup_code = hev.status
                  AND hev.source IN
                         ('AP EXCEL INVOICE IMPORT',
                          'RENT CONTRACT INVOICE',
                          'INV AP INVOICES',
                          'E-INVOICE AP EXCEL IMPORT',
                          'COMMUNAL INVOICES')
						  
						  

/* Formatted on 9/2/2019 6:13:45 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM xxtg.xxtg_hub_ap_invoice_lines
              WHERE INVOICE_ID IN
                        (SELECT INVOICE_ID
                           FROM xxtg.xxtg_hub_ap_invoices
                          WHERE     1 = 1
                                AND INVOICE_NUM IN ('06/2019/РБПБ',
                                                    '06/2019/ДУА',
                                                    '06/2019/РСУХ',
                                                    '06/2019/ТРЕ')))


/* Formatted on 9/2/2019 6:13:48 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM xxtg.xxtg_hub_ap_invoices
              WHERE     1 = 1
                    AND INVOICE_NUM IN ('06/2019/РБПБ',
                                        '06/2019/ДУА',
                                        '06/2019/РСУХ',
                                        '06/2019/ТРЕ'))


/* Formatted on 9/2/2019 6:13:52 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM AP_INVOICE_LINES_INTERFACE
              WHERE INVOICE_ID IN (SELECT INVOICE_ID
                                     FROM ap_invoices_interface i
                                    WHERE INVOICE_NUM IN ('06/2019/РБПБ',
                                                          '06/2019/ДУА',
                                                          '06/2019/РСУХ',
                                                          '06/2019/ТРЕ')))


/* Formatted on 9/2/2019 6:13:55 PM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM ap_invoices_interface i
              WHERE INVOICE_NUM IN ('06/2019/РБПБ',
                                    '06/2019/ДУА',
                                    '06/2019/РСУХ',
                                    '06/2019/ТРЕ'))

--###########################################################################
 SELECT * FROM  APPS.xxtg_hub_events
--   SET STATUS = 'NEW'
 WHERE EVENT_ID BETWEEN '151587' AND '151644' 
 
/* Formatted on 11.03.2022 15:24:30 (QP5 v5.326) Service 568482 Desk Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM xxtg.xxtg_hub_ap_invoice_lines
              WHERE INVOICE_ID IN
                        (SELECT INVOICE_ID
                           FROM xxtg.xxtg_hub_ap_invoices
                          WHERE EVENT_ID BETWEEN '151587' AND '151644'))


/* Formatted on 11.03.2022 15:24:26 (QP5 v5.326) Service Desk 568482 Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM xxtg.xxtg_hub_ap_invoices
              WHERE EVENT_ID BETWEEN '151587' AND '151644')


/* Formatted on 11.03.2022 15:24:22 (QP5 v5.326) Service Desk 568482 Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM AP_INVOICE_LINES_INTERFACE
              WHERE INVOICE_ID IN
                        (SELECT INVOICE_ID
                           FROM ap_invoices_interface i
                          WHERE INVOICE_NUM IN
                                    (SELECT INVOICE_NUM
                                       FROM xxtg.xxtg_hub_ap_invoices
                                      WHERE EVENT_ID BETWEEN '151587'
                                                         AND '151644')))


/* Formatted on 11.03.2022 15:24:19 (QP5 v5.326) Service Desk 568482 Mihail.Vasiljev */
DELETE FROM (SELECT *
               FROM ap_invoices_interface i
              WHERE INVOICE_NUM IN
                        (SELECT INVOICE_NUM
                           FROM xxtg.xxtg_hub_ap_invoices
                          WHERE EVENT_ID BETWEEN '151587' AND '151644'))