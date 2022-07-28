select org, subinventory_code, SII.DISABLE_DATE, SII.AVAILABILITY_TYPE 
, SII.STATUS_ID 
, item_code, dsc, qty, total_cost
from (
select org, subinventory_code 
/*, SIC.AVAILABILITY_TYPE 
, SIC.STATUS_ID,*/ 
, item_code, description as dsc, sum(quantity) as qty, sum(total_usd) as total_cost
from (
select hou.name as org
      ,msn.current_subinventory_code as subinventory_code
      ,msib.segment1 as item_code
      ,msib.description 
      ,msn.lot_number
      ,msn.serial_number
      ,trunc(mmt.transaction_date) as trx_date
      ,1 as quantity
      ,xuc.unit_cost cost_local
      ,xuc.currency_code
      ,glr.conversion_rate
      ,round((xuc.unit_cost / glr.conversion_rate),2) as cost_usd
      ,1 * round((xuc.unit_cost / glr.conversion_rate),2) as total_usd
      ,mtt.transaction_type_name
      ,trunc(mmt.creation_date) as crt_date      
      ,fu.user_name as created_by
      ,papf.full_name --5620
      ,hou2.name employee_dep
      ,mmt.transaction_set_id
      ,mmt.transaction_id
from inv.mtl_serial_numbers msn
join inv.mtl_system_items_b msib on msn.inventory_item_id = msib.inventory_item_id and msib.organization_id = 82
join inv.mtl_system_items_tl msit on msn.inventory_item_id = msit.inventory_item_id and msit.organization_id = 82 and msit.language = 'RU'
join hr.hr_all_organization_units hou on hou.organization_id = msn.current_organization_id
join inv.mtl_material_transactions mmt on mmt.transaction_id = msn.last_transaction_id
join xxtg.xxtg_unit_cost xuc on xuc.inventory_item_id = msn.inventory_item_id and xuc.lot_number = msn.lot_number and trunc(mmt.transaction_date) between xuc.date_from and xuc.date_to 
join apps.gl_daily_rates glr on glr.conversion_date = trunc(mmt.transaction_date) and glr.from_currency = 'USD' and glr.conversion_type = '1000' 
                                and glr.to_currency = case when trunc(mmt.transaction_date) < to_date('01.07.2016','dd.mm.yyyy') then 'BYR' else 'BYN' end                             
join inv.mtl_transaction_types mtt on mtt.transaction_type_id = mmt.transaction_type_id
join applsys.fnd_user fu on fu.user_id = mmt.created_by
left join hr.per_all_people_f papf on papf.person_id = fu.employee_id and trunc(mmt.creation_date) between papf.effective_start_date and papf.effective_end_date
left join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id and trunc(mmt.creation_date) between paaf.effective_start_date and paaf.effective_end_date
left join hr.hr_all_organization_units hou2 on paaf.organization_id = hou2.organization_id 
where msn.current_status = 3 
--and msn.serial_number = '038160891'
--and msn.current_organization_id = 83
order by msn.current_organization_id, msn.current_subinventory_code, msib.segment1, msn.lot_number, msn.serial_number
)
--group by org, subinventory_code, item_code, description
union all
select org, subinventory_code, item_code, description, sum(quantity) as qty, sum(total_usd) as total_cost
from (select hou.name as org
      ,msn.subinventory_code
      ,msib.segment1 as item_code
      ,msib.description 
      ,msn.lot_number
      ,null as serial_number
      ,trunc(mmt.transaction_date) as trx_date
      ,msn.transaction_quantity as quantity
      ,xuc.unit_cost cost_local
      ,xuc.currency_code
      ,glr.conversion_rate
      ,round((xuc.unit_cost / glr.conversion_rate),2) as cost_usd
      ,msn.transaction_quantity * round((xuc.unit_cost / glr.conversion_rate),2) as total_usd
      ,mtt.transaction_type_name
      ,trunc(mmt.creation_date) as crt_date      
      ,fu.user_name as created_by
      ,papf.full_name --5620
      ,hou2.name employee_dep
      ,mmt.transaction_set_id
      ,mmt.transaction_id 
--      ,msn.*
from inv.mtl_onhand_quantities_detail msn
join inv.mtl_system_items_b msib on msn.inventory_item_id = msib.inventory_item_id and msib.organization_id = 82
join inv.mtl_system_items_tl msit on msn.inventory_item_id = msit.inventory_item_id and msit.organization_id = 82 and msit.language = 'RU'
join hr.hr_all_organization_units hou on hou.organization_id = msn.organization_id
join inv.mtl_material_transactions mmt on mmt.transaction_id = msn.update_transaction_id
join xxtg.xxtg_unit_cost xuc on xuc.inventory_item_id = msn.inventory_item_id and xuc.lot_number = msn.lot_number and trunc(mmt.transaction_date) between xuc.date_from and xuc.date_to 
join apps.gl_daily_rates glr on glr.conversion_date = trunc(mmt.transaction_date) and glr.from_currency = 'USD' and glr.conversion_type = '1000' 
                                and glr.to_currency = case when trunc(mmt.transaction_date) < to_date('01.07.2016','dd.mm.yyyy') then 'BYR' else 'BYN' end                             
join inv.mtl_transaction_types mtt on mtt.transaction_type_id = mmt.transaction_type_id
join applsys.fnd_user fu on fu.user_id = mmt.created_by
left join hr.per_all_people_f papf on papf.person_id = fu.employee_id and trunc(mmt.creation_date) between papf.effective_start_date and papf.effective_end_date
left join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id and trunc(mmt.creation_date) between paaf.effective_start_date and paaf.effective_end_date
left join hr.hr_all_organization_units hou2 on paaf.organization_id = hou2.organization_id 
--where msn.create_transaction_id = 24853382
order by msn.organization_id, msn.subinventory_code, msib.segment1, msn.lot_number
)
--group by org, subinventory_code, item_code, description
order by org, subinventory_code, item_code, dsc)
left join  INV.MTL_SECONDARY_INVENTORIES SII on SII.SECONDARY_INVENTORY_NAME = subinventory_code
