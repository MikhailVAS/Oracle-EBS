-- Поиск по номеру накладной 
Select
	receipt_num
	,WAYBILL_AIRBILL_NUM
	,a.*
from 
  PO.RCV_SHIPMeNT_HEADERS a
where receipt_num like ('%0439028%') 



-- Servic Desk 7777777	

update PO.RCV_SHIPMENT_HEADERS
set receipt_num = '_'||receipt_num , 
    WAYBILL_AIRBILL_NUM = '_'|| WAYBILL_AIRBILL_NUM
where receipt_num = 'ПХ 0439028' 