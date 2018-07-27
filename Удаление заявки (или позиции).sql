select
La.shipped_quantity
, La.ordered_quantity
, La.line_number
, h.order_number
, La.*
from 
ont.OE_ORDER_LINES_all La
, ont.oe_order_headers_all h 
where 1=1
and La.header_id = H.HEADER_ID
and La.header_id in (select ha.header_id 
from ont.oe_order_headers_all ha
, ont.OE_ORDER_LINES_all LaL
where 1=1
and H.HEADER_ID = LaL.header_id
and ha.order_number in (173488)
)order by order_number, La.line_number;

-- Service Desk 183386
delete ont.OE_ORDER_LINES_all La
where 1=1
    and La.LINE_NUMBER in (10)
    and La.header_id in (select ha.header_id 
                        from ont.oe_order_headers_all ha
                           , ont.OE_ORDER_LINES_all LaL
                        where 1=1
                          and Ha.HEADER_ID = LaL.header_id
                          and ha.order_number in (173488));   


-- Service Desk 183386                          
delete from ont.oe_order_headers_all where header_id not in (select header_id from ont.oe_order_lines_all);
 
-- Service Desk 183386 
delete from ont.oe_order_lines_all where header_id not in (select header_id from ont.oe_order_headers_all);
 
-- Service Desk 183386 
-- for general cleaning also for deleting Ship_ID 
delete from xxtg.xxtg_oe_ship_line where oe_line_id not in (select line_id from ont.oe_order_lines_all ); 

-- Service Desk 183386  
delete from xxtg.xxtg_oe_ship_line where ship_id not in (select ship_id from xxtg.xxtg_oe_ship_hdr); 

-- Service Desk 183386      
delete from xxtg.xxtg_oe_ship_hdr where ship_id not in (select ship_id from xxtg.xxtg_oe_ship_line); 

-- Service Desk 183386       
delete from xxtg.xxtg_oe_ship_detail where line_id not in (select line_id from xxtg.xxtg_oe_ship_line);   