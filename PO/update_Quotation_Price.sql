/*
 =======================================================================================================
 Name : Update Quotation Price --Updating price of existing Quotation

 Purpose : This plsql program is used to update price of existing Quotation
           PDOI : Import price catalog concurrent program
 =======================================================================================================
 */
DECLARE


------------------------------------------------------------------------------------
--Define Mandatory column variables to insert into interface tables. Values to all
-- Variables need to be intialized with required data before running the script.
------------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--Header level information
---------------------------------------------------------------------------------
--This provides batch id which is used to run particular set of data
l_batch_id		 po_headers_interface.batch_id%TYPE := 100;

-- Contains Attribute value which can be your username 
-- which can be used to check records inserted by the user
l_attribute1             po_headers_interface.attribute1%TYPE := 'SBONTALA';

--Specifies PO header Id to be updated
l_po_header_id         po_headers_interface.po_header_id%TYPE := 513309;

--Contains Organization ID
l_org_id		 po_headers_interface.org_id%TYPE := 204;

--Contains Ship to Location ID
l_ship_to_location_id    po_headers_interface.ship_to_location_id%TYPE := 204;

--Contains Bill to Location ID
l_bill_to_location_id    po_headers_interface.bill_to_location_id%TYPE := 204;

--Contains Ship to Organization ID
l_ship_to_org_id    po_line_locations_interface.ship_to_organization_id%TYPE := 204;

l_document_type_code  po_headers_interface.document_type_code%TYPE := 'QUOTATION';

l_document_subtype po_headers_interface.document_subtype%TYPE := 'STANDARD';

l_agent_id po_headers_interface.agent_id%TYPE := 31420;

l_vendor_id po_headers_interface.vendor_id%TYPE := 11;

l_vendor_site_id po_headers_interface.vendor_site_id%TYPE := 15;




---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------
l_line_num po_lines_interface.line_num%TYPE:= 1;

--Contains Unit price of the Item
l_unit_price             po_lines_interface.unit_price%TYPE:= 20;

--Specifies the price override for the item
l_price_override         po_line_locations_interface.price_override%TYPE := 20;

--Specified the quantity for the price break
l_quantity               po_line_locations_interface.quantity%TYPE := 100;

l_shipment_num        po_line_locations_interface.shipment_num%TYPE := 1;



--To track Progress
l_progress       VARCHAR2(10) ;

BEGIN

 ---- Inserting into header interface table
 l_progress := '001';
 
	     Insert into PO.PO_HEADERS_INTERFACE 
	      (INTERFACE_HEADER_ID, 
	       BATCH_ID, 
	       PROCESS_CODE, 
	       ACTION, 
	       ORG_ID, 
	       DOCUMENT_TYPE_CODE,   
	       DOCUMENT_SUBTYPE, 
	       PO_HEADER_ID, 
	       AGENT_ID,   
	       VENDOR_ID, 
	       VENDOR_SITE_ID,  
	       ATTRIBUTE1,
	       CREATION_DATE
	       ) 
	     VALUES 
	     ( po_headers_interface_s.NEXTVAL, --- INTERFACE_HEADER_ID, 
	       l_batch_id,	---	    BATCH_ID,   
	       'PENDING', ---    PROCESS_CODE, 
	       'UPDATE', ---    ACTION, 
	       l_org_id, ---    ORG_ID, 
	       l_document_type_code, ---    DOCUMENT_TYPE_CODE, 
	       l_document_subtype, 
	       l_po_header_id, 
	       l_agent_id,        ---   AGENT_ID, 
	       l_vendor_id, ---   VENDOR_ID, 
	       l_vendor_site_id, ---   VENDOR_SITE_ID,
	       l_attribute1,
   SYSDATE ); ---    CREATION_DATE   


	      --- Inserting into Lines interface table
                l_progress := '002';
		 
		 Insert into PO.PO_LINES_INTERFACE 
		  (INTERFACE_LINE_ID, 
		   INTERFACE_HEADER_ID, 
		   ACTION, 
		   LINE_NUM,   
		   UNIT_PRICE,   
		   LINE_LOC_POPULATED_FLAG) 
		 Values 
		  (po_lines_interface_s.nextval, --- INTERFACE_LINE_ID, 
		   po_headers_interface_s.currval, --- INTERFACE_HEADER_ID, 
		  'UPDATE', ---    ACTION, 
		   l_line_num, ---    LINE_NUM,   
		   l_unit_price,---    UNIT_PRICE,     
   'Y'); ---    LINE_LOC_POPULATED_FLAG 



           --Inserting into line location interface table
           
             l_progress := '003';

  Insert into PO.PO_LINE_LOCATIONS_INTERFACE 
              (INTERFACE_LINE_LOCATION_ID, 
               INTERFACE_HEADER_ID, 
               INTERFACE_LINE_ID,               
               SHIPMENT_NUM,               
               QUANTITY,       
               PRICE_OVERRIDE, 
               CREATION_DATE) 
            Values 
              (po_line_locations_interface_s.nextval,---     INTERFACE_LINE_LOCATION_ID, 
               po_headers_interface_s.currval,    ---         INTERFACE_HEADER_ID, 
               po_lines_interface_s.currval,    ---        INTERFACE_LINE_ID,   
              l_shipment_num,    ---        SHIPMENT_NUM, 
               l_quantity,    ---        QUANTITY     
               l_price_override, 
              SYSDATE);    ---        CREATION_DATE 
	 
COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||SQLCODE||SQLERRM);

END;