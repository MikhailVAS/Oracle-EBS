-- Поиск по номеру накладной 
Select
	receipt_num
	,WAYBILL_AIRBILL_NUM
	,a.*
from 
  PO.RCV_SHIPMeNT_HEADERS a
where receipt_num like ('%0087093%') 



-- Servic Desk 7777777	

--update 
Select * From  PO.RCV_SHIPMENT_HEADERS
--set receipt_num = '_'||receipt_num , 
   -- WAYBILL_AIRBILL_NUM = '_'|| WAYBILL_AIRBILL_NUM
where receipt_num = 'ИЛ 0087093' 

Select Transaction_TYPE_ID
, transaction_set_id
, ', '||CHR(39)||transaction_id||CHR(39)
, SHIPMENT_NUMBER 
, mt.ORGANIZATION_ID
, SOURCE_CODE
, TRX_SOURCE_LINE_ID
, mt.ATTRIBUTE14
, mt.ATTRIBUTE15
, cr.user_name as CREATED_BY 
, up.user_name as UpDated_BY
, transaction_id
, transaction_set_id
, TRANSACTION_DATE
, Transaction_TYPE_ID
, SOURCE_CODE
, mt.INVENTORY_ITEM_ID
, IC.segment1
, mt.attribute13
, mt.ATTRIBUTE14
, mt.ATTRIBUTE15
, mt.shipment_number
, mt.* 
from inv.mtl_material_transactions mt -- join  inv.mtl_system_items_b IC on mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
, applsys.fnd_user cr
, applsys.fnd_user up
, inv.mtl_system_items_b IC 
where mt.CREATED_BY      = cr.user_id 
and   mt.LAST_UPDATED_BY = up.user_id
and   mt.ORGANIZATION_ID = IC.ORGANIZATION_ID
and   mt.INVENTORY_ITEM_ID = IC.INVENTORY_ITEM_ID
--and   mt.transaction_date > to_date ('31.10.2015','dd.mm.yyyy')
--and   mt.ORGANIZATION_ID = 83
--and  IC.segment1 in ( '1013111044')
--and INVENTORY_ITEM_ID in (253485)
--and TRANSACTION_SOURCE_ID = 394638
--and transaction_set_id in (30505967)
--and TRANSACTION_TYPE_ID = 902
--and transaction_date between to_date ('01.07.2017','.dd.mm.yyyy') and to_date ('01.07.201','.dd.mm.yyyy')
-- and transaction_set_id in ( 31156423  )
--and  transaction_id in (374598 )
--and TRANSACTION_TYPE_ID = 199
--and transaction_set_id in (28746754  )
--and transaction_set_id in (25674229) --20786239, 20783874) -- , 23882887)
--and SUBINVENTORY_CODE ='ItemsInUsg'
--and TRANSACTION_SOURCE_NAME = '1146096'
--and TRANSFER_SUBINVENTORY='ФЛГ_ЦО'
---and transaction_id in (23654730, 23654726) -- 24642414 
and SHIPMENT_NUMBER in ('ИЛ 0087093') --066044
--and WAYBILL_AIRBILL like ('ЭЭ 0094100')
--and SHIPMENT_NUMBER like ('%ЮЖ%6756772%') --066044
--and TRX_SOURCE_LINE_ID=547541 -- (*)
--and SHIPMENT_NUMBER in ('1146096') --066044
--and SHIPMENT_NUMBER like '%0589122%'
--and SEGMENT1 in ( 'UHH32-D048-350-100')  
--and TRANSACTION_TYPE_ID = 542
--and TRANSACTION_TYPE_ID = 663 -- 321
--and transaction_set_id in (24905793)
--and TRANSACTION_SOURCE_ID in (449818, 434014,434016, 449813, 434017,449814, 449815, 434019)
--and SOURCE_CODE is null
--and mt.ATTRIBUTE14='0001'
--and mt.ATTRIBUTE15='0001'
order by mt.TRANSACTION_DATE, SUBINVENTORY_CODe,SEGMENT1