/* Проверка*/
SELECT sup.VENDOR_ID,
       sup.VENDOR_NAME,
       sup.VAT_REGISTRATION_NUM,
       ss.vendor_site_id
  FROM apps.ap_suppliers sup, apps.ap_supplier_sites_all ss
 WHERE     sup.vendor_id = ss.vendor_id
       AND sup.VENDOR_NAME LIKE '%Министерства финансов%'
       AND sup.VAT_REGISTRATION_NUM = '100049877'
--  and sup.vendor_id  = 3988

			 
/*Update vendor in PO-HEADER*/
UPDATE PO.PO_HEADERS_ALL po
   SET po.vendor_id = &vendor_id, po.vendor_site_id = &vendor_site_id
 WHERE po.segment1 = '&po_num';
 
 /* Update vendor in PO-ARCHIVE */
UPDATE APPS.PO_HEADERS_ARCHIVE_ALL PHA
   SET PHA.vendor_id = &vendor_id, PHA.vendor_site_id = &vendor_site_id
 WHERE PO_HEADER_ID = (SELECT PO_HEADER_ID
                         FROM PO.PO_HEADERS_ALL po
                        WHERE po.segment1 = '&po_num')

/* Update vendor in Receipt transactions*/
UPDATE PO.RCV_TRANSACTIONS rt
   SET rt.vendor_id = &vendor_id, rt.vendor_site_id = &vendor_site_id
 WHERE po_header_id = (SELECT po_header_id
                         FROM PO.PO_HEADERS_ALL po
                        WHERE po.segment1 = '&po_num');
                     
/* Update vendor in Receipt Header */
UPDATE PO.RCV_SHIPMENT_HEADERS rsh
   SET rsh.vendor_id = &vendor_id
 WHERE rsh.shipment_header_id IN
           (SELECT shipment_header_id
              FROM PO.RCV_TRANSACTIONS rt
             WHERE po_header_id = (SELECT po_header_id
                                     FROM PO.PO_HEADERS_ALL po
                                    WHERE po.segment1 = '&po_num'));