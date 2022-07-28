/*
 =======================================================================================================
 Name : Update Blanket Purchase Agreement -- Updating Line of existing BPA

 Purpose : This plsql program is used to update line in a BPA through 
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



---------------------------------------------------------------------------------
--Line level information
---------------------------------------------------------------------------------

--Contains Unit price of the Item
l_unit_price             po_lines_interface.unit_price%TYPE:= 400;

--Contains the line number to be modified
l_line_num    NUMBER := 1;

--To track Progress
l_progress       VARCHAR2(10) ;
BEGIN

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

	       l_progress := '002';
		Insert into PO.PO_LINES_INTERFACE
		   (INTERFACE_LINE_ID,
		    INTERFACE_HEADER_ID,
		    ACTION,		
		    LINE_NUM, 
		    UNIT_PRICE,	
		    CREATION_DATE)
		 Values
		   (po_lines_interface_s.nextval,	 ---	INTERFACE_LINE_ID,
		    po_headers_interface_s.currval,	 ---	INTERFACE_HEADER_ID,
		   'UPDATE',	 ---	    ACTION,		
		    l_line_num, 	 ---	    LINE_NUM, 	
		    l_unit_price,---	    UNIT_PRICE,	
		    SYSDATE); 	 ---	    CREATION_DATE

	   
COMMIT;

EXCEPTION

WHEN OTHERS THEN

dbms_output.put_line('Error while inserting data at :'||l_progress||SQLCODE||SQLERRM);

END;