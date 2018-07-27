

update inv.mtl_material_transactions
set attribute13 = '2017.07.31 09:00:00'
where 1=1
and transaction_set_id in ('30553423');
						   
select * from wsh.wsh_new_deliveries a
where name in ('ЮК 777777');

update wsh.wsh_new_deliveries 
set INITIAL_PICKUP_DATE = to_date ('31.07.2017 9:00:00','dd.mm.yyyy hh.mi.ss')
where name in ('ЮК 777777');