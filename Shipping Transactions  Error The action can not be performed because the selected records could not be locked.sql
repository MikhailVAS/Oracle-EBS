Shipping Transactions > Error: The action can not be performed because the selected records could not be locked

--Ship (Confirm / Pick Release)  errors with 'The action cannot be performed because the selected records could not be locked.
--
--Processing :-  Copy this script in Toad.
--        1) To execute, to press the "F5"
--        2) entry the "Delivery Detail ID"
--        3) Output the result, to check this field vlaue. (e.g. May be delete the space in "Description" column)
--        4) use the "edit" on sql database 
--              e.g.  edit WSH_DELIVERY_DETAILS where delivery_detail_id = 375105;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--<Solution and SQL program>
--
--Run the script loc_col.sql to check for trailing spaces within any of the item description.  This script can be downloaded from the following site:
--==================================================================================================

set serveroutput on size 1000000
set verify off

ACCEPT DEL_DETAIL_ID NUMBER PROMPT 'PLEASE ENTER DELIVERY_DETAIL_ID : '

DECLARE CURSOR C1 is Select column_name from fnd_columns Where table_id = ( Select table_id from fnd_tables Where table_name = 'WSH_DELIVERY_DETAILS' );

Cnt NUMBER(10) := 0;
DynSql VARCHAR2(1000);
DelDetId WSH_DELIVERY_DETAILS.Delivery_Detail_Id %TYPE;


BEGIN

dbms_output.put_line('Script to identify the problematic fields :');
dbms_output.put_line('============================================');

FOR i IN C1 LOOP

DelDetId := &DEL_DETAIL_ID;
DynSql := 'SELECT COUNT(*) FROM WSH_DELIVERY_DETAILS ';
DynSql := DynSql || 'WHERE NVL(LENGTH(LTRIM(RTRIM(' || i.column_name || '))), 0) <> ' ;
DYNSql := DynSql || ' LENGTH(' || i.column_name || ') ';
DynSql := DynSql || 'AND Delivery_Detail_Id = ' || DelDetId;

EXECUTE IMMEDIATE DynSql INTO Cnt;

IF ( cnt > 0 ) THEN
  dbms_output.put_line('Field ' ||i.COLUMN_NAME|| ' for delivery detail '|| DelDetId || ' has leading or trailing spaces');
 
END IF;

END LOOP;

dbms_output.put_line('Script completed succefully.......');

END;


/*Result 

Script to identify the problematic fields :
============================================
Field ITEM_DESCRIPTION for delivery detail 714299 has leading or trailing spaces
Script completed succefully.......

*/  

/* Formatted on (QP5 v5.326) Service Desk 574794 Mihail.Vasiljev 
Исправление в Item */
UPDATE inv.mtl_system_items_b
   SET DESCRIPTION = TRIM (DESCRIPTION)
WHERE SEGMENT1 = :ITem ;
                                 
/* Formatted on (QP5 v5.326) Service Desk 574794 Mihail.Vasiljev
 Исправление в Item TL  */
UPDATE APPS.MTL_SYSTEM_ITEMS_TL
   SET DESCRIPTION = TRIM (DESCRIPTION),
       LONG_DESCRIPTION = TRIM (DESCRIPTION)
WHERE INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                              FROM inv.mtl_system_items_b a
                             WHERE SEGMENT1 = :ITem);

/* Formatted on (QP5 v5.326) Service Desk 574794 Mihail.Vasiljev 
Исправление в Ship deails */
UPDATE wsh_delivery_details
   SET ITEM_DESCRIPTION = TRIM (ITEM_DESCRIPTION)
WHERE SOURCE_HEADER_ID = 465406