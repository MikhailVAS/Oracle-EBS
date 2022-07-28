select 
serial_number
, current_ORGANIZATION_ID 
, group_mark_id
, line_mark_id
, lot_line_mark_id
, reservation_id
, current_status
, current_subinventory_code
, a.*  
from inv.mtl_serial_numbers a 
where 1=1  
and serial_number in (
-- **-- For Ship_ID
Select SERIAL_NUMBER_B
FroM
  xxtg.xxtg_OE_SHIP_DETAIL SHD
, xxtg.xxtg_oe_ship_line   SHL
, xxtg.xxtg_oe_ship_hdr    SHHDR  
Where
    SHHDR.ship_id = (30731926)
and SHL.ship_id        = SHHDR.ship_id
and SHD.line_id        = SHL.line_id
)
 order by a.serial_number