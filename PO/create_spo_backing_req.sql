/*
 =======================================================================================================
 Name : Create Standard Purchase Order

 Purpose : This plsql program is used to insert data into PO interface table to create Standard
           Purchase Order through PDOI having backing requisition
	   : Import Standard Purchase Order Concurrent Program .

	   Some mandatory columns have been defined users can have their own columns added
	   as per their requirement
	   

 History:

Date         Action     By        

27-mar-2014  Created    Supriya
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
l_batch_id   po_headers_interface.batch_id%TYPE := 121222;

--Contains Organization ID
l_org_id   po_headers_interface.org_id%TYPE := 204;

--Contains Agent ID for which PO is created
l_agent_id   po_headers_interface.agent_id%TYPE := 12344567;

--Contains Vendor ID
l_vendor_id   po_headers_interface.vendor_id%TYPE := 21;

--Contains Vendor Site ID 
l_vendor_site_id  po_headers_interface.vendor_site_id%TYPE := 41;

--Contains Ship to Location ID
l_ship_to_location_id    po_headers_interface.ship_to_location_id%TYPE := 204;

--Contains Bill to Location ID
l_bill_to_location_id    po_headers_interface.bill_to_location_id%TYPE := 204;

-- Contains Attribute value which can be your username 
-- which can be used to check records inserted by the user
l_attribute1             po_headers_interface.attribute1%TYPE := 'SBONTALA';



---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------

-- Provide the list of requisition line ids
l_req_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER(190013, 190014);

l_progress VARCHAR2(100);

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
     CURRENCY_CODE,  
     AGENT_ID,   
     VENDOR_ID,  
     VENDOR_SITE_ID,   
     SHIP_TO_LOCATION_ID,  
     BILL_TO_LOCATION_ID,  
     ATTRIBUTE1,    
     CREATION_DATE)
  VALUES 
  ( po_headers_interface_s.NEXTVAL,--- INTERFACE_HEADER_ID, 
     l_batch_id,   
     'PENDING', --- PROCESS_CODE,
     'ORIGINAL', --- ACTION,  
     l_org_id, --- ORG_ID,
     'STANDARD', --- DOCUMENT_TYPE_CODE, 
     'USD',  --- CURRENCY_CODE, 
     l_agent_id,        
     l_vendor_id, 
     l_vendor_Site_id,  
     l_ship_to_location_id, 
     l_bill_to_location_id, 
     l_attribute1, 
     SYSDATE ); --- CREATION_DATE,           

   l_progress := '002';

   FOR i  IN 1..l_req_line_id_tbl.COUNT LOOP
   
  Insert into PO.PO_LINES_INTERFACE
     (INTERFACE_LINE_ID,
      INTERFACE_HEADER_ID,
      ACTION,
      REQUISITION_LINE_ID,
      LINE_LOC_POPULATED_FLAG)
   Values
     (po_lines_interface_s.nextval, --- INTERFACE_LINE_ID,
      po_headers_interface_s.currval,--- INTERFACE_HEADER_ID,
     'ADD',--- ACTION,  
       l_req_line_id_tbl(i),
      'N');--- LINE_LOC_POPULATED_FLAG,    

  END LOOP;  
COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||'---'||SQLCODE||SQLERRM);

END;
