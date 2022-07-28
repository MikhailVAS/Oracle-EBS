/*
 =======================================================================================================
 Name : Update Standard Purchase Order -- Adding Line with New Item

 Purpose : This plsql program is used to Add line with New item to existing standard purchase order 
           through PDOI : Import standard Purchase Order concurrent program
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
l_po_header_id         po_headers_interface.po_header_id%TYPE := 198440;

---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------
--Contains Line type 
l_line_type              po_lines_interface.line_type%TYPE := 'Goods';

--Contains Item information
l_item                   po_lines_interface.item%TYPE := 'PDOI_TEST_ITEM123';

--Contains Item description
l_item_description       po_lines_interface.item_description%TYPE := 'Item Created from PDOI';

--Specifies UOM code 
l_uom_code               po_lines_interface.uom_code%TYPE := 'Ea';

--Contains Quantity required of the item
l_quantity               po_lines_interface.quantity%TYPE := 100;

--Contains Unit price of the Item
l_unit_price             po_lines_interface.unit_price%TYPE:= 100;

--Contains charge account ID for the item distribution
l_charge_account_id      po_distributions_interface.charge_account_id%TYPE := 13402;


--Contains the line number from which lines are added to the purchase order
l_line_num    NUMBER;

--Specifies number of shipments to be created per line
l_shipment_count NUMBER :=  2;

--Specifies number of distributions to be created per shipment
l_dist_count     NUMBER :=  2;

--To track progess 
l_progress       VARCHAR2(10) ;


BEGIN

 ---- Inserting into header interface table
 l_progress := '001';
   Insert into PO.PO_HEADERS_INTERFACE
       (INTERFACE_HEADER_ID, 
        BATCH_ID,     
        PROCESS_CODE,
        ACTION,   
        po_header_id,
        ATTRIBUTE1,       
        CREATION_DATE)
     VALUES 
     ( po_headers_interface_s.NEXTVAL, ---  INTERFACE_HEADER_ID, 
        l_batch_id,    ---  BATCH_ID,      
        'PENDING',    --- PROCESS_CODE,
        'UPDATE', ---  ACTION,
        l_po_header_id,
        l_attribute1,    
        SYSDATE );    ---  CREATION_DATE,   
	
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
            QUANTITY,          
            UNIT_PRICE,           
            SHIP_TO_ORGANIZATION_ID,         
            SHIP_TO_LOCATION_ID,
            NEED_BY_DATE,
            PROMISED_DATE,            
            CREATION_DATE,         
            LINE_LOC_POPULATED_FLAG)
         Values
           (po_lines_interface_s.nextval,     --- INTERFACE_LINE_ID,
            po_headers_interface_s.currval,   --- INTERFACE_HEADER_ID,
           'ADD',     ---        ACTION,        
            l_line_num,          	  
            l_line_type, 
            l_item,    
            l_item_description,
            l_uom_code, 
            l_quantity,     
            l_unit_price,    
            l_ship_to_org_id,  --- SHIP_TO_ORGANIZATION_ID,          
            l_ship_to_location_id,   --- SHIP_TO_LOCATION_ID,
            SYSDATE,     ---   NEED_BY_DATE,
            SYSDATE,      ---  PROMISED_DATE,
            SYSDATE,      ---  CREATION_DATE,           
            'Y');     ---  LINE_LOC_POPULATED_FLAG,           
            
    
       ----Shipment Loop
	      FOR ship_cnt IN 1..l_shipment_count LOOP 

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
		       (po_line_locations_interface_s.nextval,---    INTERFACE_LINE_LOCATION_ID,
			po_headers_interface_s.currval,    ---        INTERFACE_HEADER_ID,
			po_lines_interface_s.currval,    ---        INTERFACE_LINE_ID,             
			'STANDARD',    ---  SHIPMENT_TYPE,
			ship_cnt,    ---        SHIPMENT_NUM,
			l_ship_to_org_id,    ---        SHIP_TO_ORGANIZATION_ID,               
			l_ship_to_location_id,    ---        SHIP_TO_LOCATION_ID,             
			SYSDATE,    ---        NEED_BY_DATE, 
			SYSDATE,     ---        PROMISED_DATE,             
			l_quantity/l_shipment_count,    ---        QUANTITY,             
			SYSDATE);    ---        CREATION_DATE,
               
               --Distribution Loop		
		    FOR dist_cnt IN 1..l_dist_count LOOP 
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
				   (po_headers_interface_s.currval,         --- INTERFACE_HEADER_ID,
				    po_lines_interface_s.currval,         ---  INTERFACE_LINE_ID, 
				    po_line_locations_interface_s.currval,  ---  INTERFACE_LINE_LOCATION_ID,
				    po.po_distributions_interface_s.NEXTVAL, --- INTERFACE_DISTRIBUTION_ID,                   
				    dist_cnt,        ---    DISTRIBUTION_NUM,                  
				    l_org_id,        ---   ORG_ID, 
				     l_quantity/(l_shipment_count*l_dist_count),       ---   QUANTITY_ORDERED,                   
				    l_charge_account_id, ---  CHARGE_ACCOUNT_ID      
				    SYSDATE);  
               END LOOP; ---End of Distribution Loop                    
           END LOOP;---End of shipment Loop  				    

COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||SQLCODE||SQLERRM);

END;