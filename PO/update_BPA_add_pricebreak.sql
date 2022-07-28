/*
 =======================================================================================================
 Name : Update Blanket Purchase Agreement --Adding price breaks to existing line in a BPA

 Purpose : This plsql program is used to update BPA by adding price breaks through 
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
l_po_header_id         po_headers_interface.po_header_id%TYPE := 198445;


--Contains Ship to Location ID
l_ship_to_location_id    po_headers_interface.ship_to_location_id%TYPE := 204;

--Contains Bill to Location ID
l_bill_to_location_id    po_headers_interface.bill_to_location_id%TYPE := 204;

--Contains Ship to Organization ID
l_ship_to_org_id    po_line_locations_interface.ship_to_organization_id%TYPE := 204;


---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------
--Specifies the price override for the item
l_price_override         po_line_locations_interface.price_override%TYPE := 10;

--Specified the quantity for the price break
l_quantity               po_line_locations_interface.quantity%TYPE := 100;

--Contains the line number to be modified
l_line_num    NUMBER := 1;

--Contains the line loc number from which price breaks are added to the line
l_line_loc_num NUMBER;

--Specifies number of price breaks to be created per Line
L_prc_brk_count  NUMBER := 2;

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
	    PO_HEADER_ID,
	    ATTRIBUTE1, 	  
	    CREATION_DATE)
	 VALUES 
	 ( po_headers_interface_s.NEXTVAL,	---	INTERFACE_HEADER_ID, 
	    l_batch_id,	---	    BATCH_ID,	  
	    'PENDING',	---	    PROCESS_CODE,
	    'UPDATE', ---	    ACTION, 
	    l_po_header_id,
	    l_attribute1,	---	    ATTRIBUTE1, 
	    SYSDATE );	---	    CREATION_DATE,  
	    

    --- Inserting into Lines interface table
	       l_progress := '002';
		Insert into PO.PO_LINES_INTERFACE
		   (INTERFACE_LINE_ID,
		    INTERFACE_HEADER_ID,
		    ACTION,		
		    LINE_NUM,	    
		    CREATION_DATE, 		
		    LINE_LOC_POPULATED_FLAG)
		 Values
		   (po_lines_interface_s.nextval,	 ---	INTERFACE_LINE_ID,
		    po_headers_interface_s.currval,	 ---	INTERFACE_HEADER_ID,
		   'UPDATE',	 ---	    ACTION,		
		    l_line_num, 	 ---	    LINE_NUM, 
		    SYSDATE, 	 ---	    CREATION_DATE, 		  
		    'Y');	 ---	    LINE_LOC_POPULATED_FLAG,
     
         --- Fetching the maximum shipment number from line locations  table for the given  header id and line no
	 FOR i IN (SELECT MAX(shipment_num) cnt
		     FROM po_line_locations_all pll,po_lines_all pol
	             where pll.po_line_id = pol.po_line_id
		       and pol.po_header_id = l_po_header_id
		       and pol.line_num = l_line_num
		   )LOOP
           l_line_loc_num := i.cnt;
        END LOOP ;
       		   
	      --Price Break Loop          
        FOR i IN 1..L_prc_brk_count LOOP
	
            l_line_loc_num := l_line_loc_num +1;

              --Inserting into line location interface table
	     Insert into PO.PO_LINE_LOCATIONS_INTERFACE
               (INTERFACE_LINE_LOCATION_ID,
                INTERFACE_HEADER_ID,
                INTERFACE_LINE_ID,              
                SHIPMENT_TYPE,
                SHIPMENT_NUM,
                SHIP_TO_ORGANIZATION_ID,               
                SHIP_TO_LOCATION_ID,                 
                QUANTITY,       
		PRICE_OVERRIDE,
                CREATION_DATE)
             Values
               (po_line_locations_interface_s.nextval,---    INTERFACE_LINE_LOCATION_ID,
                po_headers_interface_s.currval,    ---        INTERFACE_HEADER_ID,
                po_lines_interface_s.currval,    ---        INTERFACE_LINE_ID,             
                'PRICE BREAK',    ---        SHIPMENT_TYPE,
                l_line_loc_num,    ---        SHIPMENT_NUM,
                l_ship_to_org_id,    ---        SHIP_TO_ORGANIZATION_ID,               
                l_ship_to_location_id,    ---        SHIP_TO_LOCATION_ID,   
                l_quantity,    ---        QUANTITY,             
		l_price_override,
                SYSDATE);    ---        CREATION_DATE,
         END LOOP;
	   
COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||SQLCODE||SQLERRM);

END;