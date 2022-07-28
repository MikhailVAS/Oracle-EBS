-- XXTG_GL001_DOUBLE_GLOBAL

select CURRENCY_CODE
      ,SEGMENT2 
      ,AN_CODE_1 ,AN_DESC_1 
      ,AN_CODE_2 ,AN_DESC_2 
      ,AN_CODE_3 ,AN_DESC_3 
      ,AN_CODE_4 ,AN_DESC_4 
      ,case when sum(DR)-sum(CR) < 0 then 0 else sum(DR)-sum(CR) end as DIFF_DR_BYN 
      ,case when sum(CR)-sum(DR) < 0 then 0 else sum(CR)-sum(DR) end as DIFF_CR_BYN
from(
select CURRENCY_CODE
      ,C_SEGMENT2 as SEGMENT2 
      ,C_AN_CODE_1 as AN_CODE_1 ,C_AN_DESC_1 as AN_DESC_1 
      ,C_AN_CODE_2 as AN_CODE_2 ,C_AN_DESC_2 as AN_DESC_2 
      ,C_AN_CODE_3 as AN_CODE_3 ,C_AN_DESC_3 as AN_DESC_3 
      ,C_AN_CODE_4 as AN_CODE_4 ,C_AN_DESC_4 as AN_DESC_4 
      ,0 as DR 
      ,accounted_amount as CR
from xxtg_gl001_double_global a where 1=1 
and c_segment2 like '10%'
and c_Accounting_date < to_date('01.08.2017','dd.mm.yyyy')
and ledger_id = 2047
union all
select CURRENCY_CODE
      ,d_SEGMENT2 
      ,d_AN_CODE_1 ,d_AN_DESC_1 
      ,d_AN_CODE_2 ,d_AN_DESC_2 
      ,d_AN_CODE_3 ,d_AN_DESC_3 
      ,d_AN_CODE_4 ,d_AN_DESC_4 
      ,accounted_amount as DR
      ,0 as DR
from xxtg_gl001_double_global a where 1=1 
and d_segment2 like '10%'
and d_Accounting_date < to_date('01.08.2017','dd.mm.yyyy')
and ledger_id = 2047
)
group by CURRENCY_CODE ,SEGMENT2 
      ,AN_CODE_1 ,AN_DESC_1 
      ,AN_CODE_2 ,AN_DESC_2 
      ,AN_CODE_3 ,AN_DESC_3 
      ,AN_CODE_4 ,AN_DESC_4 
order by CURRENCY_CODE ,SEGMENT2 
      ,AN_CODE_1 ,AN_DESC_1 
      ,AN_CODE_2 ,AN_DESC_2 
      ,AN_CODE_3 ,AN_DESC_3 
      ,AN_CODE_4 ,AN_DESC_4
