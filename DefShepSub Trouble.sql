
/* Check double_global DefShpSub
Firs   Dt Amount
Second Ct Amount */

SELECT                                                              
      SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND D_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.03.2021', '.dd.mm.yyyy')
                                 AND TO_DATE ('31.03.2021', '.dd.mm.yyyy')
UNION ALL 
SELECT                                                              
       SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND  c_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.03.2021', '.dd.mm.yyyy')
                                 AND TO_DATE ('31.03.2021', '.dd.mm.yyyy')
--should be zero for period
select (select sum(accounted_amount) from XXTG_GL001_DOUBLE_GLOBAL
where d_segment2 = '0028' and c_segment2 not like '0__'
and d_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy'))
-
(select sum(accounted_amount) from XXTG_GL001_DOUBLE_GLOBAL
where c_segment2 = '0028' and d_segment2 not like '0__'
and c_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy')) diff from dual;


--look what comes by amount in DefShpSub but this amount not left DefShpSub
select accounted_amount from XXTG_GL001_DOUBLE_GLOBAL
where d_segment2 = '0028' and c_segment2 not like '0__'
and d_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy')
--group by d_accounting_date
minus
select accounted_amount from XXTG_GL001_DOUBLE_GLOBAL
where c_segment2 = '0028' and d_segment2 not like '0__'
and c_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy')
--group by c_accounting_date
;

--list of very podozritelnye documents
select distinct doc_num from
(select sum(accounted_amount), d_accounting_date, d_doc_num doc_num from XXTG_GL001_DOUBLE_GLOBAL
where d_segment2 = '0028' and c_segment2 not like '0__'
and d_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy')
group by d_accounting_date, d_doc_num
minus
select sum(accounted_amount), c_accounting_date, c_doc_num doc_num from XXTG_GL001_DOUBLE_GLOBAL
where c_segment2 = '0028' and d_segment2 not like '0__'
and c_accounting_date between to_date('01032021', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy')
group by c_accounting_date, c_doc_num)
;


--incorrect accounting for ТМЦ принятые в безвозмездное пользование
select * from XXTG_GL001_DOUBLE_GLOBAL
where d_segment2 = '0028'
and c_segment2 not like '0__'
and C_AN_DESC_2 = 'ТМЦ принятые в безвозмездное пользование'
and d_accounting_date between to_date('01032010', 'ddmmyyyy') and to_date('31032021', 'ddmmyyyy');