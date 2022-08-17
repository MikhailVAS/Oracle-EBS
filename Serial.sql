SELECT '''' || SERIAL_NUMBER || ''','
           AS SN,
       group_mark_id,
       line_mark_id,
       lot_line_mark_id,
       RESERVATION_ID,
       LOT_NUMBER,
       LENGTH (SERIAL_NUMBER),
       SERIAL_NUMBER,
       attribute9
           "DID",
       (SELECT DISTINCT ctxh.SEGMENT1
          FROM inv.mtl_system_items_b ctxh
         WHERE ctxh.INVENTORY_ITEM_ID = sn.INVENTORY_ITEM_ID)
           "Item",
       CURRENT_STATUS,
       CASE CURRENT_STATUS
           WHEN 3 THEN 'Активный'
           WHEN 4 THEN 'Списан'
           ELSE 'Other Status'
       END
           AS "Статус SN",
       LAST_TRANSACTION_ID,
       CASE CURRENT_ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           WHEN 1369 THEN 'BFC: Строительство ОС'
           ELSE 'Other organization'
       END
           AS "Наименованеи_организации",
       CURRENT_SUBINVENTORY_CODE,
       (SELECT SI.DESCRIPTION
          FROM INV.MTL_SECONDARY_INVENTORIES SI
         WHERE     SI.ORGANIZATION_ID = sn.CURRENT_ORGANIZATION_ID
               AND SI.SECONDARY_INVENTORY_NAME = sn.CURRENT_SUBINVENTORY_CODE)
           AS "Subinv name",
       sn.*
  FROM inv.mtl_serial_numbers sn
 WHERE serial_number IN ('893750305090076395',
                         '893750305090076396',
                         '893750305090076397',
                         '893750305090076398')
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE a.SEGMENT1 = '1051000126')

--==================== Transaction Move Order Change Serial Numbers ====================	
/* SD не комплектуется строка 2502353 
Не корректная партия и серийный номер в Transaction Move Order Line*/
UPDATE mtl_txn_request_lines mtrl
   SET LOT_NUMBER = '210329Демонтаж422058',
       SERIAL_NUMBER_START = 'VIRT6647',
       SERIAL_NUMBER_END = 'VIRT6647'
 WHERE     mtrl.header_id = (SELECT HEADER_ID
                               FROM mtl_txn_request_headers mtrh
                              WHERE REQUEST_NUMBER = '2502353')
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1051000126')
--=========================== Delete Block in Serial Numbers ===========================									 
								 
/* Formatted on (QP5 v5.326) Service Desk 547210 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE     INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013111033')
       AND CURRENT_SUBINVENTORY_CODE = '168'
       --                                 AND LOT_NUMBER = '14583|Комплектование425757'
       AND CURRENT_STATUS = '3'
	   
--=========================== Change Serial Numbers ===========================						 
/* Formatted on (QP5 v5.326) Service Desk 480746 Mihail.Vasiljev */
UPDATE MTL_UNIT_TRANSACTIONS
   SET SERIAL_NUMBER = 'W2APXPP0'
 WHERE     SERIAL_NUMBER = 'VIRT2629'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1051100153');

 /* Formatted on (QP5 v5.326) Service Desk 480746 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET serial_number = 'W2APXPP0'
WHERE     serial_number = 'VIRT2629'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1051100153');
								 
--=========================== Update Incorrect VIRTUAL Serial Numbers by Order ===========================		
/* Formatted on (QP5 v5.326) Service Desk 417327 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
WHERE LAST_TRANSACTION_ID IN
           (SELECT transaction_id
              FROM oe_order_headers_all       ooha,
                  oe_order_lines_all         oola,
                  mtl_material_transactions  mmt
             WHERE     ooha.HEADER_ID = oola.HEADER_ID
                   AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
                   --AND MMT.transaction_id IN (43500324)
                   AND ORDER_NUMBER = '262551' -- 253460.BeST Internal.ORDER ENTRY
                    AND SHIPPED_QUANTITY is null
                   ) AND GROUP_MARK_ID is not null
				    -- AND GROUP_MARK_ID is not null AND LINE_MARK_ID IS NULL;
--=============================================================================
/* query to find the serial number used by Inventory Transactions */
SELECT c.serial_number,
       a.transaction_id,
       a.transaction_type_id,
       a.transaction_quantity,
       b.lot_number
  FROM MTL_MATERIAL_TRANSACTIONS    a,
       MTL_TRANSACTION_LOT_NUMBERS  b,
       MTL_UNIT_TRANSACTIONS        c
 WHERE     a.TRANSACTION_ID = b.TRANSACTION_ID
       AND b.SERIAL_TRANSACTION_ID = c.TRANSACTION_ID
       AND c.serial_number = '355789142325975'
--       AND a.TRANSACTION_ID IN (SELECT mt.TRANSACTION_ID
--                                  FROM inv.mtl_material_transactions mt
--                                 WHERE mt.TRANSACTION_SOURCE_ID = 1509777)
/* Formatted on (QP5 v5.326) Service Desk 480746 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET serial_number = 'W2APXPP0'
 WHERE     serial_number = 'VIRT2629'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1051100153');
--==============================================================================	

/* Не работают массовые корректировки дилеров.*/
UPDATE inv.mtl_serial_numbers msn
   SET msn.LAST_TRANSACTION_ID =
           (SELECT mt.TRANSACTION_ID
              FROM inv.mtl_material_transactions    mt,
                   inv.mtl_transaction_lot_numbers  mtln
             WHERE     mtln.TRANSACTION_ID = mt.TRANSACTION_ID
                   AND mt.TRANSACTION_SOURCE_NAME = msn.LAST_TXN_SOURCE_NAME --'Распоряжение 6 от 18.02.2021'
                   AND mt.INVENTORY_ITEM_ID = msn.INVENTORY_ITEM_ID --'874843'
                   AND mtln.LOT_NUMBER = msn.LOT_NUMBER) -- '210218Комплектование421240'
 WHERE     msn.LAST_TXN_SOURCE_NAME LIKE '%Распоряжение%' --'Распоряжение 6 от 18.02.2021'
       AND msn.LAST_TRANSACTION_ID IS NULL

/* Formatted on 06.05.2020 15:52:42 (QP5 v5.326) Service Desk 385197 Mihail.Vasiljev */
DELETE FROM mtl_material_transactions_temp
      WHERE     inventory_item_id = (SELECT DISTINCT INVENTORY_ITEM_ID
                                       FROM inv.mtl_system_items_b a
                                      WHERE SEGMENT1 IN ('1051000045'))
            AND organization_id = 1369;

--========================= Update DID by old Transaction  ========================
/* Проверка */
SELECT DISTINCT ATTRIBUTE9
  FROM MTL_UNIT_TRANSACTIONS
 WHERE     SERIAL_NUMBER = '893126951038594700'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013070638')
       AND ATTRIBUTE9 IS NOT NULL;

/* Formatted on 26.07.2022 16:14:11 (QP5 v5.326) Service Desk Mihail.Vasiljev 
Update DID by old Transaction */
UPDATE inv.mtl_serial_numbers sn
   SET sn.attribute9 =
           (SELECT DISTINCT ATTRIBUTE9
              FROM MTL_UNIT_TRANSACTIONS
             WHERE     SERIAL_NUMBER = sn.SERIAL_NUMBER 
                   AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                              FROM inv.mtl_system_items_b a
                                             WHERE SEGMENT1 = '1013070638')
                   AND ATTRIBUTE9 IS NOT NULL)
 WHERE     sn.serial_number IN ('893126951038594700')
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE a.SEGMENT1 = '1013070638')
--==============================================================================				
			
/* Запрос для определения статуса отгрузки карт в Iguana, оборудования или аксессуаров
   Если он вернет Вам информацию со строкой Transfer, данные об отгрузке присутствуют в SM.*/
SELECT *
  FROM sm.int_tr_inventory_serial
 WHERE DS_PR_SERIAL = '893750305190963643';          

/*Missing serial numbers from Material Workbranch mold tree */
UPDATE APPS.MTL_SERIAL_NUMBERS
   SET CURRENT_SUBINVENTORY_CODE = 'DefShpSub',
       CURRENT_LOCATOR_ID = '338',
       group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE     CURRENT_ORGANIZATION_ID = '1369'
       AND (INVENTORY_ITEM_ID = '874785')
       AND (SERIAL_NUMBER BETWEEN 'VIRT5269' AND 'VIRT5280')
       AND (LOT_NUMBER = '210128Демонтаж420815')
			
/* Formatted on (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT group_mark_id,
       line_mark_id,
       lot_line_mark_id,
       RESERVATION_ID,
       LOT_NUMBER,
       sn.*
  FROM inv.mtl_serial_numbers sn
 WHERE serial_number IN ('19831.01733087')
 
/* Formatted on (QP5 v5.326) Service Desk 306737 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE serial_number IN ('19831.01733087')
        AND CURRENT_STATUS = 3
 
 /* Formatted on (QP5 v5.326) Service Desk 308603 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE     CURRENT_SUBINVENTORY_CODE = 'ТЕП'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b
                                 WHERE SEGMENT1 = '1013002790')
       AND CURRENT_STATUS = 3
       AND LOT_NUMBER = '4065'
	   
/*Update all s\n by Internal.ORDER */ 
/* Formatted on (QP5 v5.326) Service Desk 483077 Mihail.Vasiljev */
UPDATE inv.mtl_serial_numbers
   SET group_mark_id = NULL,
       line_mark_id = NULL,
       lot_line_mark_id = NULL,
       RESERVATION_ID = NULL
 WHERE LAST_TRANSACTION_ID IN
           (SELECT transaction_id
              FROM oe_order_headers_all       ooha,
                   oe_order_lines_all         oola,
                   mtl_material_transactions  mmt
             WHERE     ooha.HEADER_ID = oola.HEADER_ID
                   AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
                   --AND MMT.transaction_id IN (43500324)
                   AND ORDER_NUMBER = '262289' -- 253460.BeST Internal.ORDER ENTRY
                    AND SHIPPED_QUANTITY is null
                   ) AND GROUP_MARK_ID is not null 

/* Проверка */
SELECT group_mark_id,
       line_mark_id,
       lot_line_mark_id,
       RESERVATION_ID,
       LOT_NUMBER,
       SUBSTR (
           DECODE (CURRENT_STATUS,
                   1, 'Defined but not used',
                   3, 'Resides in Stores',
                   4, 'Out of Stores',
                   5, 'Intransit',
                   6, 'Invalid',
                   NULL, 'Verify Serial Number',
                   CURRENT_STATUS),
           1,
           25)
           "Status",
       sn.*
  FROM inv.mtl_serial_numbers sn
 WHERE     1 = 1
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b
                                 WHERE SEGMENT1 = '3705006536')

-- AND LOT_NUMBER = '4065'
--and  serial_number between '040571243' and '893750302180163199'
--and  serial_number in ('��0008923'
-- )
--and GROUP_MARK_ID = 32783527
---order by 1,2,3,4

/* Необходимо выгрузить из системы информацию о наличии DUMMY серийных номеров на текущую дату.
 Выходной файл должен содержать: наименование склада, наименование ТМЦ, количество, цена, сумма.
 Идентификация DUMMY серийных номеров не нужна.*/
  SELECT DISTINCT msib.segment1
                      AS item_code,
                  mst.description,
                  a.lot_number,
                  a.CURRENT_SUBINVENTORY_CODE,
                  a.CURRENT_ORGANIZATION_ID,
                  COUNT (*)
                      AS "Количество",
                  apps.xxtg_inv_common_pkg.get_item_cost (
                      a.current_organization_id,
                      a.current_subinventory_code,
                      a.inventory_item_id,
                      a.lot_number)
                      AS "Цена"
    FROM inv.mtl_serial_numbers a,
         inv.mtl_system_items_b msib,
         inv.mtl_system_items_tl mst
   WHERE     a.serial_number LIKE 'DUM%'
         AND a.current_status = 3
         AND a.inventory_item_id = msib.inventory_item_id
         AND msib.inventory_item_id = mst.inventory_item_id
         AND a.current_organization_id = msib.organization_id
         AND msib.organization_id = mst.organization_id
         AND mst.language = 'RU'
GROUP BY msib.segment1,
         mst.description,
         a.lot_number,
         a.CURRENT_SUBINVENTORY_CODE,
         a.CURRENT_ORGANIZATION_ID,
         a.inventory_item_id

select
-- item_ID
-- distinct last_transaction_id
distinct serial_number
--serial_number
--, current_ORGANIZATION_ID
, msib.SEGMENT1 as Item
, LOT_NUMBER
, group_mark_id
, line_mark_id
, lot_line_mark_id
, reservation_id
, current_status
, current_subinventory_code
, a.*
from inv.mtl_serial_numbers a
inner join inv.mtl_system_items_b msib on msib.inventory_item_id = a.inventory_item_id
--, inv.mtl_system_items_b   msib
where 1=1
--lot_number = '9356|??????????????006027' and current_subinventory_code='UserEquip'
 --and reservation_id is not null
--and
-- serial_number like '893750314103094700'
--serial_number = '354638042030675'
--and INVENTORY_ITEM_ID = 30267
--and CURRENT_SUBINVENTORY_CODE = 'UserPril'
--and CURRENT_SUBINVENTORY_CODE = 'StagingDpt'
--and CURRENT_SUBINVENTORY_CODE = 'DefShpSub'
--and CURRENT_SUBINVENTORY_CODE = 'Transit'
--and CURRENT_SUBINVENTORY_CODE = '���'
--and INVENTORY_ITEM_ID = 62428
--and LOT_NUMBER = '140316���������127|�����026216'
--and CURRENT_STATUS = 3
--and LOT_NUMBER = '151231�����������������045491'
--and LAST_TXN_SOURCE_ID = 499450
and LOT_NUMBER in ( '190117���_�����_�����_��409149'
)
--and INVENTORY_ITEM_ID = 48272
--and serial_number between '893750303158184830' and '893750303158187829'
--and serial_number like ('866254021785056')
 /*
--like '860557021384472' --'%V3N6RB12A0903621%'*/
/*in ( '355698052679547'
, '355698052679216'
, '355698052678291'
, '355698052677558'
, '353569053351687'
, '353569053221021'
, '353569053222730'
)*/
order by a.GROUP_MARK_ID,    a.LINE_MARK_ID,    a.LOT_LINE_MARK_ID,    a.RESERVATION_ID
-- order by a.serial_number
--and RESERVATION_ID = 4161836

-- История серийных ! ! ! ! ! ! ! !
select distinct mmt.transaction_id, mut.serial_number,
nvl(trunc(to_date(mmt.attribute13,'yyyy.mm.dd hh24:mi:ss'), 'ddd'), trunc(mmt.transaction_date, 'ddd')) as actiondate, mmt.creation_date,
msib.segment1, msib.description, mtln.lot_number,
mtt.transaction_type_name, mmt.transaction_type_id as ttid, mmt.inventory_item_id as iiid, mmt.shipment_number as ship_n,-- a.transaction_source_id, a.organization_id as org_id,
mmt.subinventory_code as sub_code, mtln.transaction_quantity as tr_q, mmt.transaction_source_name as tr_s_nam, mmt.attribute14 as a14, mmt.attribute15 as a15
--mta.rate_or_amount, mta.base_transaction_value
from inv.mtl_material_transactions mmt
join inv.mtl_transaction_types mtt on mtt.transaction_type_id = mmt.transaction_type_id
join inv.mtl_transaction_lot_numbers mtln on mmt.transaction_id = mtln.transaction_id
left join inv.mtl_transaction_accounts mta on mta.transaction_id = mmt.transaction_id
join inv.mtl_system_items_b msib on msib.inventory_item_id = mmt.inventory_item_id and msib.organization_id = mmt.organization_id
left join inv.mtl_unit_transactions mut on mut.transaction_id = mtln.serial_transaction_id
where 1=1
and mut.serial_number in (
'893750301190700669'
)
--and mtln.lot_number = '130221Хоккейный_клуб_Дин011187'
--and msib.SEGMENT1 = '100040069'
order by mut.serial_number, mmt.creation_date, mmt.transaction_id;


select count(*) from inv.mtl_serial_numbers // 12493016

select
-- item_ID
-- distinct last_transaction_id
  current_ORGANIZATION_ID
, serial_number
, group_mark_id
, line_mark_id
, lot_line_mark_id
, reservation_id
, current_status
, current_subinventory_code
, a.*
from inv.mtl_serial_numbers a
where 1=1
and CURRENT_STATUS = 3
and LOT_NUMBER = '3347'
and CURRENT_SUBINVENTORY_CODE ='���'
--and serial_number like ('%867212024930227%') -- in ('893750306102371807')
--and  serial_number between '39919019' and '39919062'
--and serial_number in ( '868767022690429'
--)
--and serial_number like ('893750307126927862')
order by a.serial_number

select SERIAL_NUMBER
, msib.segment1, CURRENT_SUBINVENTORY_CODE
,a.*
from inv.mtl_serial_numbers a --T4SBBCB--510807215
 join inv.mtl_system_items_b msib on msib.inventory_item_id = a.inventory_item_id
where 1=1
and serial_number in ('359880090033491'
)
--and LOT_NUMBER = '2729'
-- and serial_number beetwin '��0151301' and ''

040530844
04580844

select
-- item_ID
-- distinct last_transaction_id
distinct serial_number
--serial_number
--, current_ORGANIZATION_ID
, organization_type
, msib.SEGMENT1 as Item
, LOT_NUMBER
, group_mark_id
, line_mark_id
, lot_line_mark_id
, reservation_id
, current_status
, current_subinventory_code
, a.*
from inv.mtl_serial_numbers a
inner join inv.mtl_system_items_b msib on msib.inventory_item_id = a.inventory_item_id
where 1=1
--and serial_number in ('��0151301')
--and CURRENT_STATUS = 3
--and LOT_LINE_MARK_ID = 21224187
--and GROUP_MARK_ID= 21220947
and serial_number like '8648490465%'
                        864849046520263
                        864849046535964

select
-- item_ID
-- distinct last_transaction_id
--distinct serial_number
--serial_number
--, current_ORGANIZATION_ID
--, msib.SEGMENT1 as Item
--, LOT_NUMBER
--, group_mark_id
--, line_mark_id
--, lot_line_mark_id
--, reservation_id
count(*)
, current_status
--, current_subinventory_code
--, a.*
from inv.mtl_serial_numbers a
inner join inv.mtl_system_items_b msib on msib.inventory_item_id = a.inventory_item_id
where 1=1
--and serial_number in ('��0151301')
group by current_status
--and CURRENT_STATUS = 3
--and LOT_LINE_MARK_ID = 21224187
--and GROUP_MARK_ID= 21220947
--and serial_number in ( 'DUM0000170023')

and serial_number like ('%%')
order by a.serial_number

-- HD#298733 
update inv.mtl_serial_numbers
set
group_mark_id    =  null --6396455
, line_mark_id     = null --
, lot_line_mark_id = null --6396455
, RESERVATION_ID   = null
-- RESERVATION_ID=4161836
--select group_mark_id, line_mark_id, lot_line_mark_id, RESERVATION_ID,LOT_NUMBER, sn.* from inv.mtl_serial_numbers sn
where 1=1
--and CURRENT_SUBINVENTORY_CODE != '���'
--and CURRENT_STATUS = 3
--and  serial_number between '040571243' and '893750302180163199'
and  serial_number in ('��0008923'
 )
--and GROUP_MARK_ID = 32783527
---order by 1,2,3,4



and serial_number in ('040999006'
,'040999012'
)

-- HD#174659
update inv.mtl_serial_numbers
set serial_number = '15003232'
where 1=1
and serial_number in ('5')

--and serial_number like ("357476050483982%")

RESERVATION_ID=4161836

select *
from po.rcv_transactions_interface a
where a.interface_id in (13006909, 13006910, 13006913, 13006916, 13006915);

select serial_number, group_mark_id, line_mark_id, lot_line_mark_id, reservation_id, a.*
from inv.mtl_serial_numbers a where --lot_number = '9356|??????????????006027' and current_subinventory_code='UserEquip'
 --and reservation_id is not null
--and
/*
serial_number like (
'862823020133403???????%'
-- '862823020117653%'
-- '8628230201183%'
-- '862823020118%'
-- , '862823020118560%'
)*/
LOT_NUMBER = '120427������������_�����002106_f1'

UpDate inv.mtl_serial_numbers SN
Set SERIAL_NUMBER = '862823020118222'
where serial_number like ('862823020133403???????%')

Select distinct SI.segment1, count(1) from inv.mtl_system_items_b SI where inventory_item_id in (
  Select INVENTORY_ITEM_ID from inv.MTL_SERIAL_NUMBERs where current_status != 4 and
    serial_number in (
  '893750309115094433'

) ) GROUP BY SI.segment1

select segment1 from inv.mtl_system_items_b where INVENTORY_ITEM_ID = 16083

Select distinct SI.segment1, count(1) from inv.mtl_system_items_b SI where inventory_item_id in (
  Select INVENTORY_ITEM_ID from inv.MTL_SERIAL_NUMBERs where current_status != 4 and
    serial_number in (
  '893750317116352489'
) ) GROUP BY SI.segment1


Select distinct SI.segment1, count(1) from inv.mtl_system_items_b SI where inventory_item_id in (
  Select INVENTORY_ITEM_ID from inv.MTL_SERIAL_NUMBERs where
   current_status != 4 and
    serial_number in (
 '893750306114896957'
) ) GROUP BY SI.segment1

---------------------------------
-- current serial which begining from DUMM
select
-- count(1)
 msib.segment1 as item_code
, mst.description
, lot_number
, CURRENT_SUBINVENTORY_CODE
, serial_number
from inv.mtl_serial_numbers a
, inv.mtl_system_items_b msib
, inv.mtl_system_items_tl mst
where
    a.serial_number like 'DUM%'
and a.CURRENT_SUBINVENTORY_CODE like 'UserEquip%'
and a.current_status = 3
and a.inventory_item_id = msib.inventory_item_id
and msib.inventory_item_id = mst.inventory_item_id
and a.current_organization_id = msib.organization_id
and msib.organization_id = mst.organization_id
and mst.language = 'RU'
-- group by a.inventory_item_id
order by msib.segment1, a.lot_number, a.serial_number;


      select a.serial_number, a.attribute1
      from MTL_serial_numbers a
      where a.current_ORGANIZATION_ID = :parameter.org_id
      and a.INVENTORY_ITEM_ID = :hdr.item_id
      and a.current_SUBINVENTORY_CODE = :hdr.SUBINVENTORY
      AND a.current_status = 3
      AND NVL (a.organization_type, 2) = 2
      and lot_number = :lns.batch_no
      and exists ( select 1 from mtl_lot_numbers mln
                       where mln.LOT_NUMBER = a.lot_number
                         and mln.organization_id = a.current_ORGANIZATION_ID
                         and mln.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
                         and MLN.STATUS_ID = 1)
      and not exists (select 1 from mtl_reservations mr
                      where mr.reservation_id = a.group_mark_id)
      and not exists (select 1 from mtl_reservations mr
                      where mr.organization_id = a.current_organization_id
                      and mr.subinventory_code = a.current_subinventory_code
                      and mr.inventory_item_id = a.inventory_item_id
                      and mr.lot_number = a.lot_number)
      order by to_number(a.attribute1), a.serial_number ;


----------------------------------
update xxtg.xxtg_return_info set party_id = 11556 where party_id is null

select ml.serial_number
        ,msi.segment1 item_code
        ,msi.description
        ,ml.lot_number--, ml.current_organization_id
        ,ml.current_subinventory_code--, msi.inventory_item_id--
        ,decode(ml.current_status,3,'Active',4,'Written Off', ml.current_status) status
--        ,ml.status_id
--        ,ml.last_transaction_id
--        ,apps.xxtg_inv_common_pkg.get_item_cost(ml.current_organization_id,ml.current_subinventory_code,ml.inventory_item_id,ml.lot_number) cost
 from inv.mtl_serial_numbers ml
        ,inv.mtl_system_items_b msi
        ,inv.mtl_system_items_tl mst
        ,xxtg.xxtg_return_info a
        ,inv.mtl_material_transactions mmt
where 1=1
    and a.serial_number = ml.serial_number (+)
    and msi.inventory_item_id (+) =  ml.inventory_item_id
    and msi.inventory_item_id =  mst.inventory_item_id (+)
    and msi.organization_id =  mst.organization_id (+)
    and mst.language (+) = 'RU'
    and msi.organization_id (+) = ml.current_organization_id
--    and msi.organization_id = 83
--    and ml.status_id=62
--    and ml.current_status (+) = 3
    and a.party_id=11556
--    and ml.current_subinventory_code = 'UserEquip'
    and ml.last_transaction_id = mmt.transaction_id (+)
--    and ml.serial_number in (   )
order by 1, 2, 3


select
  a.description
, a.*
from INV.MTL_SYSTEM_ITEMS_B a
where SEGMENT1 = '10130040110'

select
  a.LONG_DESCRIPTION
, a.* from INV.MTL_SYSTEM_ITEMS_TL a
where INVENTORY_ITEM_ID = 142312

select
*
from
INV.MTL_SECONDARY_INVENTORIES
where 1=1
-- and ORGANIZATION_ID=84
-- and SECONDARY_INVENTORY_NAME='����'
and (ATTRIBUTE5 =164223
or ATTRIBUTE7 =164223
or ATTRIBUTE10=164223)

---- ?????????? ??????????????
select mst.fm_serial_number, mst.to_serial_number, oeh.order_number
  from inv.MTL_SERIAL_NUMBERS_TEMP mst
        ,inv.MTL_TRANSACTION_LOTS_TEMP mlt
        ,inv.MTL_MATERIAL_TRANSACTIONS_TEMP mtt
       ,ont.OE_ORDER_LINES_all oel
       ,ont.OE_ORDER_HEADERS_ALL oeh
where mst.transaction_temp_id = mlt.serial_transaction_temp_id
   and mlt.transaction_temp_id = mtt.transaction_temp_id
   and mtt.TRX_SOURCE_LINE_ID = oel.line_id
   and oel.header_id = oeh.header_id
   and mst.fm_serial_number in(
 '353026043026770'
, '353026043026788'
, '353026043026820'
, '353026043031374'
, '353026043031507'
, '353026043031515'
)

select a.* from inv.MTL_RESERVATIONS a
where REQUIREMENT_DATE = to_date ('22:02:2014 10:05:50','dd.mm.yyyy HH24:MI:ss')

select a.* from inv.MTL_RESERVATIONS_INTERFACE a



SHIP_N
1832001
SHIP_N
11897

--serial in transaction
Select -- distinct transaction_type_id, sum(1) --,
-- distinct transaction_source_id, sum(1)
-- sum(1)
 SERIAL_NUMBER
, LOT.LOT_NUMBER
--, SERIAL_NUMBER
, mt.SUBINVENTORY_CODE
, mt.transaction_source_id
, mt.transaction_set_id
, mt.attribute13
, mt.ATTRIBUTE14
, mt.ATTRIBUTE15
, mt.transaction_date
, mt.*
from inv.mtl_material_transactions mt
   , inv.MTL_TRANSACTION_LOT_numbers lot
--   , inv.MTL_LOT_NUMBERS MLN
   , inv.MTL_UNIT_TRANSACTIONS SN
where 1=1
and lot.TRANSACTION_ID = mt.TRANSACTION_ID
--AND lot.ORGANIZATION_ID = MLN.ORGANIZATION_ID
--AND lot.INVENTORY_ITEM_ID = MLN.INVENTORY_ITEM_ID
--AND lot.LOT_NUMBER = MLN.LOT_NUMBER;
--and lot.SERIAL_TRANSACTION_ID SN.TRANSACTION_ID
and SN.TRANSACTION_ID  = lot.SERIAL_TRANSACTION_ID
and mt.transaction_set_id in (
--where transaction_id in (
  6167792
, 7727969
 ) -- and -- where
-- transaction_source_id in (165446,177886)
-- group by SERIAL_NUMBER
 order by SERIAL_NUMBER, mt.transaction_set_id

Select * from inv.MTL_TRANSACTION_LOT_numbers

SERIAL_TRANSACTION_ID
8042

Select a.* from inv.MTL_UNIT_TRANSACTIONS a


TRANSACTION_ID

SERIAL_TRANSACTION_ID


apps.MTL_UNIT_TRANSACTIONS_ALL_V

apps.MTL_TRANSACTION_LOT_VAL_V

select * from inv.MTL_SERIAL_NUMBERS_TEMP where TRANSACTION_TEMP_ID
16556897

SELECT DISTINCT osh.customer_name,
                   OSH.ORD_TYPE_MNG order_type,
                   osh.req_date order_date,
                   osl.order_number,
                   osh.ttn_date,
                   osh.ttn_number,
                   msi.segment1 ordered_item,
                   mst.description,
                   --          sub.secondary_inventory_name subinventory,--BSTSUP-716
                   mmt.transfer_subinventory subinventory,        --BSTSUP-716
                   shp.lot_number,
                   shp.serial_number_b serial_from,
                   shp.serial_number_e serial_to,
                   shp.quantity,
                   osh.inv_trans_mng shipment_status,
                   msi.inventory_item_id,
                   osh.customer_id
     FROM apps.XXTG_OE_SHIP_LINE_v osl,
          apps.XXTG_OE_SHIP_HDR_v osh,
          xxtg.XXTG_OE_SHIP_DETAIL shp,
          inv.mtl_system_items_b msi,                             --BSTSUP-716
          inv.mtl_system_items_tl mst,
          inv.mtl_parameters mp,
          inv.mtl_secondary_inventories sub                       --BSTSUP-716
                                           ,
          inv.mtl_material_transactions mmt
    WHERE     osl.ship_id = osh.ship_id
          AND osl.ship_id = shp.ship_id(+)
          AND osl.line_id = shp.line_id(+)
          AND osl.inventory_item_id = shp.inventory_item_id(+)
          AND mp.organization_code = 'BMW'
          AND mp.organization_id = msi.organization_id
          AND osl.inventory_item_id = msi.inventory_item_id
          AND osh.customer_id = sub.attribute5
--          AND (   (    osh.ord_type IN ('40', '90','80')
--                   AND NVL (sub.attribute12, 'N') = 'Y') --dealer consignment flg consignment --BSTSUP-787
--               OR (    (    osh.ord_type NOT IN ('40', '90','80')
--                        AND NVL (sub.attribute12, 'N') = 'N')
--                   AND NVL (sub.attribute13, 'N') = 'N')) --for all rest --BSTSUP-787
          AND msi.inventory_item_id = mst.inventory_item_id
          AND mst.language = 'RU'
          AND msi.organization_id = mst.organization_id
          AND mmt.transaction_set_id = osh.ship_id                --BSTSUP-716
          AND mmt.inventory_item_id = osl.inventory_item_id       --BSTSUP-716
          AND mmt.organization_id = osl.SHIP_FROM_ORG_ID          --BSTSUP-716
     and osl.order_number = '67796'
     AND mmt.transaction_id =
                 (SELECT MAX (m.transaction_id)
                    FROM inv.mtl_material_transactions m
                   WHERE     m.transaction_set_id = mmt.transaction_set_id
                         AND m.inventory_item_id = mmt.inventory_item_id
                         AND m.organization_id = mmt.organization_id) --BSTSUP-787

WAYBILL4376245705(�/�)

select v.* from apps.xxtg_om_shipment_serials_rep_v v, inv.mtl_system_items_b b
where 1=1
and v.order_type = 'Sim and Scratch'
and v.SHIPMENT_STATUS = 'Transferred'
and v.inventory_item_id = b.inventory_item_id
and b.organization_id = 83
--and ordered_item = '1013010358'
--and TTN_DATE = to_date ('22.04.2014','dd,mm,yyyy')
--and TTN_NUMBER = '0629973'
--and Customer_Name in ('������ ������')
--and description = '�� 89000 ��������� life- S519D�'
order by order_date desc, customer_name, order_number desc, ordered_item, lot_number, serial_from

select mst.fm_serial_number, mst.to_serial_number --, oeh.order_number 
  from inv.MTL_SERIAL_NUMBERS_TEMP mst 
        ,inv.MTL_TRANSACTION_LOTS_TEMP mlt 
        ,inv.MTL_MATERIAL_TRANSACTIONS_TEMP mtt 
      -- ,ont.OE_ORDER_LINES_all oel 
      -- ,ont.OE_ORDER_HEADERS_ALL oeh 
where mst.transaction_temp_id = mlt.serial_transaction_temp_id 
   and mlt.transaction_temp_id = mtt.transaction_temp_id 
 --  and mtt.TRX_SOURCE_LINE_ID = oel.line_id 
--   and oel.header_id = oeh.header_id 
   and mst.fm_serial_number = mst.FM_SERIAL_NUMBER
   and mst.fm_serial_number in(
 '893750307126928731'
)

--========================================================================
-- SD 540515 предоставление ICCID для конвертов комплектов
/* Formatted on 15.11.2021 19:53:11 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT SERIAL_NUMBER,
       attribute9
           "DID",
       (SELECT DISTINCT ctxh.SEGMENT1
          FROM inv.mtl_system_items_b ctxh
         WHERE ctxh.INVENTORY_ITEM_ID = sn.INVENTORY_ITEM_ID)
           "Item",
       CURRENT_STATUS,
       CASE CURRENT_STATUS
           WHEN 3 THEN 'Активный'
           WHEN 4 THEN 'Списан'
           ELSE 'Other Status'
       END
           AS "Статус SN",
       LAST_TRANSACTION_ID,
       CASE CURRENT_ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организация ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           WHEN 1369 THEN 'BFC: Строительство ОС'
           ELSE 'Other organization'
       END
           AS "Наименованеи_организации",
       CURRENT_SUBINVENTORY_CODE,
       (SELECT SI.DESCRIPTION
          FROM INV.MTL_SECONDARY_INVENTORIES SI
         WHERE     SI.ORGANIZATION_ID = sn.CURRENT_ORGANIZATION_ID
               AND SI.SECONDARY_INVENTORY_NAME = sn.CURRENT_SUBINVENTORY_CODE)
           AS "Subinv name"
  --       sn.*
  FROM inv.mtl_serial_numbers sn
 WHERE serial_number IN ('893412696147292251', '893569732741750119')
        AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE a.SEGMENT1 = '1051000126')
--========================================================================
DROP TABLE XXTG.XXTG_SERIAL_NUMBERS 

CREATE TABLE XXTG.XXTG_SERIAL_NUMBERS
(
  INVENTORY_ITEM_ID          VARCHAR2 (30),
  SERIAL_NUMBER              VARCHAR2(30 BYTE)  NOT NULL
)

UPDATE XXTG.XXTG_SERIAL_NUMBERS
   SET INVENTORY_ITEM_ID = REPLACE (INVENTORY_ITEM_ID, '?'),
       SERIAL_NUMBER = REPLACE (SERIAL_NUMBER, '?')

SELECT MSN.SERIAL_NUMBER,
       MSN.attribute9
           "DID"
            FROM XXTG.XXTG_SERIAL_NUMBERS XSN
LEFT JOIN inv.mtl_serial_numbers MSN ON MSN.serial_number = XSN.serial_number

--========================= Excele =================================
= "UPDATE MTL_UNIT_TRANSACTIONS
   SET SERIAL_NUMBER = '"&D2&"'
 WHERE     SERIAL_NUMBER = '"&B2&"'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '"&F2&"');
								 
								 "
								 
= "UPDATE inv.mtl_serial_numbers
   SET SERIAL_NUMBER = '"&D2&"'
 WHERE     SERIAL_NUMBER = '"&B2&"'
       AND INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '"&F2&"');
								 
								 " 





