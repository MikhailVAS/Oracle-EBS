select user_name, acqr_date, audsid, sid, serial  from xxtg.xxtg_oe_ship_hdr a where ship_id in (32321754)

http://its.experteam.com.tr/browse/BSTSUP-3271

Dear Nadya,

The system sometimes (i think because of the 2 nodes in server) has this error. How I fixed it:
-- 4,423,550

120617

Select Transaction_ID, Transaction_TYPE_ID, mt.* from inv.mtl_material_transactions mt
where transaction_set_id in (32321754)


select
 ship_id
, ACQR_DATE
, user_name 
, audsid   
, sid      
, serial   
, a.* from 
xxtg.xxtg_oe_ship_hdr a 
where  1=1
-- and ship_id in (27817596)
--and user_name = 'BSTIDORMASH' -- is not  null
and ACQR_DATE < to_date('06.06.2018 09:00:00','dd.mm.yyyy HH24:MI:ss')



--HD#267592
update xxtg.xxtg_oe_ship_hdr
set
  user_name = null
, audsid    = null
, sid       = null
, serial    = null
--select  user_name, audsid, sid, serial from xxtg.xxtg_oe_ship_hdr
where 1=1 
and ship_id in (36017410 )
-- and user_name = 'BSTIDORMASH'
--and ACQR_DATE = to_date('09.11.2018','dd.mm.yyyy')

for the relevant ship_id, I emptied fields below

user_name
acqr_date
audsid
sid
serial
