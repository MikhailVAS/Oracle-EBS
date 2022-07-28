
begin
delete from XXTG_GL001_DOUBLE_GLOBAL
where 1=1 
and D_APPL_ID = 200 and c_APPL_ID = 200
and C_AN_DESC_1 like '- Неверное значение%'
and d_segment2 like '6%'
AND d_accounting_date >= to_date('01052022', 'ddmmyyyy')  
AND C_ACCOUNTING_CLASS_CODE in ('GAIN', 'LOSS');
