-- Servic Desk 141137
delete (
select a.* from xla.xla_ae_lines a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (30602821))) 
)
);

-- Servic Desk 141137
delete (
select a.* from xla.xla_ae_line_acs a where 1=1
and ae_header_id in (
select ae_header_id from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (30602821))) 
)
);

-- Servic Desk 141137
delete (
select a.* from xla.xla_ae_headers  a 
where 1=1
and entity_id in ( select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (30602821)))
);

-- Servic Desk 141137
delete (
select a.* from xla.xla_events a 
where entity_id in 
(select ENTITY_ID from xla.xla_transaction_entities 
where transaction_number in (select to_char(transaction_id) from inv.mtl_material_transactions mt 
where transaction_set_id in (30602821)))
);

-- Servic Desk 141137
delete (
select * from xla.xla_transaction_entities where transaction_number in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt 
where transaction_set_id in (30602821))
);

-----------------------------------------------------

-- Servic Desk 141137
delete (
select * from inv.MTL_TRANSACTION_ACCOUNTS 
where 1=1 
and TRANSACTION_ID in (select to_char(transaction_id) 
from inv.mtl_material_transactions mt where transaction_set_id in (30602821))
);


-- Servic Desk 141137          
update inv.mtl_material_transactions
set costed_flag = 'N'
where 1=1
and transaction_Set_id in (30602821);

select TRANSACTION_ID, count(*) from inv.MTL_TRANSACTION_ACCOUNTS a 
where 1=1
and TRANSACTION_ID in (select TRANSACTION_ID from inv.mtl_material_transactions mt 
                       where TRANSACTION_SET_ID in (30602821) )
group by TRANSACTION_ID
having count(*) > 3
order by 2 desc;  
