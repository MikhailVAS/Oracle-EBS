/*
 =======================================================================================================
 Name : Update Blanket Purchase Agreement --Adding lines to existing BPA with new item

 Purpose : This plsql program is used to update BPA by adding lines through 
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

--Contains Ship to Location ID
l_ship_to_location_id    po_headers_interface.ship_to_location_id%TYPE := 204;

--Contains Bill to Location ID
l_bill_to_location_id    po_headers_interface.bill_to_location_id%TYPE := 204;

--Contains Ship to Organization ID
l_ship_to_org_id    po_line_locations_interface.ship_to_organization_id%TYPE := 204;

-- Contains Attribute value which can be your username 
-- which can be used to check records inserted by the user
l_attribute1             po_headers_interface.attribute1%TYPE := 'SBONTALA';

--Specifies PO header Id to be updated
l_po_header_id         po_headers_interface.po_header_id%TYPE := 198445;

---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------
--Contains Line type 
l_line_type              po_lines_interface.line_type%TYPE := 'Goods';

--Contains Item information
l_item                   po_lines_interface.item%TYPE := 'PDOI_ITEM789';

--Contains Item description
l_item_description       po_lines_interface.item_description%TYPE := 'Item Created from PDOI for BPA';

--Specifies UOM code 
l_uom_code               po_lines_interface.uom_code%TYPE := 'Ea';

--Contains Unit price of the Item
l_unit_price             po_lines_interface.unit_price%TYPE:= 100;

--Specifies the price override for the item
l_price_override         po_line_locations_interface.price_override%TYPE := 10;

--Specified the quantity for the price break
l_quantity               po_line_locations_interface.quantity%TYPE := 100;


--Contains the line number from which lines are added to the purchase order
l_line_num    NUMBER;

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

     --- Fetching the maximum line number from lines table for the given  header id
    FOR i IN (SELECT MAX(line_num) cnt FROM po_lines_all WHERE po_header_id = l_po_header_id)
    LOOP     
       l_line_num := i.cnt;
    END LOOP ;
             
         --Incrementing the line number
              l_line_num := l_line_num + 1;
              
           --- Inserting into Lines interface table
                l_progress := '002';
		Insert into PO.PO_LINES_INTERFACE
		   (INTERFACE_LINE_ID,
		    INTERFACE_HEADER_ID,
		    ACTION,		
		    LINE_NUM, 		   
		    LINE_TYPE,		  
		    ITEM,	
		    ITEM_DESCRIPTION,
		    UOM_CODE,  
		    UNIT_PRICE,		   
		    SHIP_TO_ORGANIZATION_ID,		 
		    SHIP_TO_LOCATION_ID,
		    NEED_BY_DATE,
		    PROMISED_DATE,		    
		    CREATION_DATE, 		
		    LINE_LOC_POPULATED_FLAG)
		 Values
		   (po_lines_interface_s.nextval,	 ---	INTERFACE_LINE_ID,
		    po_headers_interface_s.currval,	 ---	INTERFACE_HEADER_ID,
		   'ADD',	 ---	    ACTION,		
		    l_line_num, 	 ---	    LINE_NUM, 		   
		    l_line_type, ---	    LINE_TYPE,		
		    l_item,	 ---	    ITEM,	
		    l_item_description,
		    l_uom_code,	 ---	    UOM_CODE,	
		    l_unit_price,---	    UNIT_PRICE,		  
		    l_ship_to_org_id,  ---	    SHIP_TO_ORGANIZATION_ID,		  
		    l_ship_to_location_id,   ---    SHIP_TO_LOCATION_ID,
		    SYSDATE,	 ---	    NEED_BY_DATE,
		    SYSDATE, 	 ---	    PROMISED_DATE,
		    SYSDATE, 	 ---	    CREATION_DATE, 		  
		    'Y');	 ---	    LINE_LOC_POPULATED_FLAG,
       
          --Price Break Loop
	 FOR prc_brk_cnt IN 1..L_prc_brk_count LOOP 

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
                prc_brk_cnt,    ---        SHIPMENT_NUM,
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