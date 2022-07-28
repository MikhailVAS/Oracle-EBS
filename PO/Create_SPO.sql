/*
 =======================================================================================================
 Name : Create Standard Purchase Order

 Purpose : This plsql program is used to insert data into PO interface table to create Standard
           Purchase Order through PDOI: Import Standard Purchase Order Concurrent Program

 History:

Date         Action     By        

15-FEB-2010  Created    Supriya
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

--Contains Organization ID
l_org_id		 po_headers_interface.org_id%TYPE := 204;

--Contains Agent ID for which PO is created
l_agent_id		 po_headers_interface.agent_id%TYPE := 25;

--Contains Vendor ID
l_vendor_id		 po_headers_interface.vendor_id%TYPE := 21;

--Contains Vendor Site ID 
l_vendor_site_id	 po_headers_interface.vendor_site_id%TYPE := 41;

--Contains Ship to Location ID
l_ship_to_location_id    po_headers_interface.ship_to_location_id%TYPE := 204;

--Contains Bill to Location ID
l_bill_to_location_id    po_headers_interface.bill_to_location_id%TYPE := 204;

--Contains Ship to Organization ID
l_ship_to_org_id    po_line_locations_interface.ship_to_organization_id%TYPE := 204;

-- Contains Attribute value which can be your username 
-- which can be used to check records inserted by the user
l_attribute1             po_headers_interface.attribute1%TYPE := 'SBONTALA';

---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------
--Contains Line type 
l_line_type              po_lines_interface.line_type%TYPE := 'Goods';

--Contains Line information
l_item                   po_lines_interface.item%TYPE := 'AS10000';

--Specifies UOM code 
l_uom_code               po_lines_interface.uom_code%TYPE := 'Ea';

--Contains Quantity required of the item
l_quantity               po_lines_interface.quantity%TYPE := 100;

--Contains Unit price of the Item
l_unit_price             po_lines_interface.unit_price%TYPE:= 100;

--Contains charge account ID for the item distribution
l_charge_account_id      po_distributions_interface.charge_account_id%TYPE := 13402;


-- Specifies number of Purchase order to be created
l_header_count   NUMBER := 1;

--Specifies number of lines to be created per PO
l_line_count     NUMBER := 2;

--Specifies number of shipments to be created per line
l_shipment_count NUMBER :=  2;

--Specifies number of distributions to be created per shipment
l_dist_count     NUMBER :=  2;

--To track progess 
l_progress       VARCHAR2(10) ;

BEGIN

--Header Loop
FOR hdr_cnt IN 1..L_header_count
LOOP

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
	    'PENDING',	--- PROCESS_CODE,
	    'ORIGINAL', --- ACTION, 	
	    l_org_id,	--- ORG_ID,
	    'STANDARD',	--- DOCUMENT_TYPE_CODE,	
	    'USD', 	--- CURRENCY_CODE, 
	    l_agent_id,	       
	    l_vendor_id,	
	    l_vendor_Site_id, 	
	    l_ship_to_location_id,	
	    l_bill_to_location_id,	
	    l_attribute1,	
	    SYSDATE );	--- CREATION_DATE,           

        ---Line Loop
          FOR line_cnt IN 1..l_line_count LOOP 

	   --- Inserting into Lines interface table
                l_progress := '002';
		Insert into PO.PO_LINES_INTERFACE
		   (INTERFACE_LINE_ID,
		    INTERFACE_HEADER_ID,
		    ACTION,		
		    LINE_NUM, 		   
		    LINE_TYPE,		  
		    ITEM,		  
		    UOM_CODE,		  
		    QUANTITY,		  
		    UNIT_PRICE,		   
		    SHIP_TO_ORGANIZATION_ID,		 
		    SHIP_TO_LOCATION_ID,
		    NEED_BY_DATE,
		    PROMISED_DATE,		    
		    CREATION_DATE, 		
		    LINE_LOC_POPULATED_FLAG)
		 Values
		   (po_lines_interface_s.nextval, --- INTERFACE_LINE_ID,
		    po_headers_interface_s.currval,--- INTERFACE_HEADER_ID,
		   'ADD',--- ACTION,		
		    line_cnt,--- LINE_NUM, 		   
		    l_line_type, 
		    l_item,		 
		    l_uom_code,		
		    l_quantity,	  	
		    l_unit_price,	  
		    l_ship_to_org_id,  	  
		    l_ship_to_location_id,   
		    SYSDATE,--- NEED_BY_DATE,
		    SYSDATE,--- PROMISED_DATE,
		    SYSDATE,--- CREATION_DATE, 		  
		    'Y');--- LINE_LOC_POPULATED_FLAG, 		  

	    ----Shipment Loop
	     FOR ship_cnt IN 1..l_shipment_count LOOP 

               ---Inserting into Line Locations Interface table
	        l_progress := '003';
	        Insert into PO.PO_LINE_LOCATIONS_INTERFACE
			   (INTERFACE_LINE_LOCATION_ID,
			    INTERFACE_HEADER_ID,
			    INTERFACE_LINE_ID,			  
			    SHIPMENT_TYPE,
			    SHIPMENT_NUM,
			    SHIP_TO_ORGANIZATION_ID,			   
			    SHIP_TO_LOCATION_ID,
			    NEED_BY_DATE, 
			    PROMISED_DATE,			   
			    QUANTITY,			   
			    CREATION_DATE)
			 Values
			   (po_line_locations_interface_s.nextval,--- INTERFACE_LINE_LOCATION_ID,
			    po_headers_interface_s.currval,--- INTERFACE_HEADER_ID,
			    po_lines_interface_s.currval, --- INTERFACE_LINE_ID,			 
			    'STANDARD',	--- SHIPMENT_TYPE,
			    ship_cnt,	--- SHIPMENT_NUM,
			    l_ship_to_org_id,--- SHIP_TO_ORGANIZATION_ID,			   
			    l_ship_to_location_id,--- SHIP_TO_LOCATION_ID,			 
			    SYSDATE,--- NEED_BY_DATE, 
			    SYSDATE,--- PROMISED_DATE,			 
			    l_quantity/l_shipment_count,--- QUANTITY,			 
			    SYSDATE);--- CREATION_DATE,
		
                 --Distribution Loop			   
		    FOR dist_cnt IN 1..l_dist_count LOOP 
		      
                     ---Inserting into Distribution Interface table
		      l_progress := '004';
		      Insert into PO.PO_DISTRIBUTIONS_INTERFACE
				   (INTERFACE_HEADER_ID,
				    INTERFACE_LINE_ID, 
				    INTERFACE_LINE_LOCATION_ID,
				    INTERFACE_DISTRIBUTION_ID,				
				    DISTRIBUTION_NUM,				 
				    ORG_ID, 
				    QUANTITY_ORDERED, 				   
				    CHARGE_ACCOUNT_ID,
				     CREATION_DATE)
				 Values
				   (po_headers_interface_s.currval, ---	INTERFACE_HEADER_ID,
				    po_lines_interface_s.currval,  --- INTERFACE_LINE_ID, 
				    po_line_locations_interface_s.currval, ---	INTERFACE_LINE_LOCATION_ID,
				    po.po_distributions_interface_s.NEXTVAL,--- INTERFACE_DISTRIBUTION_ID,				   
				    dist_cnt, --- DISTRIBUTION_NUM,				  
				    l_org_id, 	  
				    l_quantity/(l_shipment_count*l_dist_count),--- QUANTITY_ORDERED, 				  
				    l_charge_account_id,   
				    SYSDATE);             
		     END LOOP; ---End of Distribution Loop                    
              END LOOP;---End of shipment Loop  
         END LOOP;---End of Line Loop  
  END LOOP;---End of Header Loop 

COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||'---'||SQLCODE||SQLERRM);

END;