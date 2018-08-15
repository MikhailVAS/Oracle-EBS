/* ERROR You are entering a duplicate orig_sys_line_ref for the same order

"Concurrent cannot be  Cancelled" for the parent request, Parent request
  status is 'Paused',  the child requests show as running

############################################################
INFO
concurrent - XXTG: Processing internal requsition to Pick Wave Order
Start childs  concurrents :
1) Create Internal Orders
2) Order Import
3) Order Import Child Req1 (Order Import)
4) Pick Selection List Generation – SRS (3 шт)
############################################################

Line	Oracle E-Business Suite	
Area	Order Management
Product	497 - Oracle Order Management

DATA FIX provided did:
  1. delete the duplicate records in headers and lines iface all.
  2. update the error flag and request_id to NULL so that all the headers 
     will be picked by Order Import Concurrent request for Processing. */
	 
/*  Delete the duplicate records in headers  iface all */
DELETE 
  FROM APPS.oe_headers_iface_all
 WHERE     order_source_id = 10
       AND orig_sys_document_ref IN (SELECT requisition_header_id
                                       FROM APPS.po_requisition_headers_all
                                      WHERE segment1 IN ('78277'));

/* Delete the duplicate records in lines iface all. */
DELETE 
  FROM APPS.oe_lines_iface_all
 WHERE     order_source_id = 10
       AND orig_sys_document_ref IN (SELECT requisition_header_id
                                       FROM APPS.po_requisition_headers_all
                                      WHERE segment1 IN ('78277')); 
									  
/* update the error flag  to NULL so that all the headers  will be picked by Order Import Concurrent request for Processing.*/
UPDATE PO.PO_REQUISITION_HEADERS_ALL PRH
   SET TRANSFERRED_TO_OE_FLAG = 'N'
 WHERE PRH.SEGMENT1 IN ('78277')
