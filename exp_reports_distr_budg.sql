--OIE
select distinct erb.*, 
(SELECT DISTINCT
       NVL (
          SUM (NVL (gb.period_net_dr, 0) - NVL (gb.period_net_cr, 0))
             OVER (PARTITION BY gb.code_combination_id),
          0)
          AS amount
  FROM gl_balances gb, gl_periods gp, applsys.fnd_flex_values val, gl.gl_code_combinations cc
WHERE     gp.period_name = gb.period_name
       AND gb.actual_flag = 'B'
       AND gb.currency_code = 'BYN'
       AND NVL (gp.adjustment_period_flag, 'N') = 'N'
       AND gb.ledger_id = 2047
       AND gb.period_year = '2018'
       AND gb.code_combination_id = cc.code_combination_id
       AND val.flex_value_set_id = 1014715
       AND val.flex_value = cc.segment2
       and NVL(val.attribute2, 'N') = 'Y' 
        AND CC.SEGMENT6 = erb.SEGMENT6
       AND CC.SEGMENT8 = erb.SEGMENT8) department_year_amount,
(SELECT DISTINCT
       NVL (
          SUM (NVL (gb.period_net_dr, 0) - NVL (gb.period_net_cr, 0))
             OVER (PARTITION BY gb.code_combination_id),
          0)
          AS amount
  FROM gl_balances gb, gl_periods gp, applsys.fnd_flex_values val, gl.gl_code_combinations cc
WHERE     gp.period_name = gb.period_name
       AND gb.actual_flag = 'B'
       AND gb.currency_code = 'BYN'
       AND NVL (gp.adjustment_period_flag, 'N') = 'N'
       AND gb.ledger_id = 2047
       AND gb.period_year = '2018'
       AND gb.code_combination_id = cc.code_combination_id
       AND val.flex_value_set_id = 1014715
       AND val.flex_value = cc.segment2
       and NVL(val.attribute2, 'N') = 'Y' 
        AND CC.SEGMENT6 = substr(erb.SEGMENT6, 1, 3) || '000000'
       AND CC.SEGMENT8 = erb.SEGMENT8
       ) divvision_year_amount 
from (SELECT erh.invoice_num,
         erh.description,
         wf.full_name,
         erd.code_combination_id,
         ccid.segment2,
         ccid.segment6,
         ccid.segment8,
         SUM (amount) amount
    FROM AP_EXPENSE_REPORT_HEADERS_ALL erh,
         ap_exp_report_dists_all erd,
         gl_code_combinations_kfv ccid,
         PER_PEOPLE_F wf
   WHERE     erd.report_header_id = erh.report_header_id
         --      AND erh.invoice_num IN ('BST33491', 'BST33489', 'BST33496', 'BST33499')
         AND ccid.code_combination_id = erd.code_combination_id
         AND EXPENSE_STATUS_CODE = 'ERROR'
         AND wf.person_id = erh.employee_id
         AND EFFECTIVE_END_DATE = (select max(EFFECTIVE_END_DATE) from PER_PEOPLE_F where person_id = erh.preparer_id)
         AND erh.creation_date >= TO_DATE ('01042018', 'ddmmyyyy')
GROUP BY invoice_num,
         erh.description,
         wf.full_name,
         erd.code_combination_id,
         ccid.segment2,
         ccid.segment6,
         ccid.segment8) erb;
         
         
--PR
select distinct erb.*, 
(SELECT DISTINCT
       NVL (
          SUM (NVL (gb.period_net_dr, 0) - NVL (gb.period_net_cr, 0))
             OVER (PARTITION BY gb.code_combination_id),
          0)
          AS amount
  FROM gl_balances gb, gl_periods gp, applsys.fnd_flex_values val, gl.gl_code_combinations cc
WHERE     gp.period_name = gb.period_name
       AND gb.actual_flag = 'B'
       AND gb.currency_code = 'BYN'
       AND NVL (gp.adjustment_period_flag, 'N') = 'N'
       AND gb.ledger_id = 2047
       AND gb.period_year = '2018'
       AND gb.code_combination_id = cc.code_combination_id
       AND val.flex_value_set_id = 1014715
       AND val.flex_value = cc.segment2
       and NVL(val.attribute2, 'N') = 'Y' 
        AND CC.SEGMENT6 = erb.SEGMENT6
       AND CC.SEGMENT8 = erb.SEGMENT8) department_year_amount,
(SELECT DISTINCT
       NVL (
          SUM (NVL (gb.period_net_dr, 0) - NVL (gb.period_net_cr, 0))
             OVER (PARTITION BY gb.code_combination_id),
          0)
          AS amount
  FROM gl_balances gb, gl_periods gp, applsys.fnd_flex_values val, gl.gl_code_combinations cc
WHERE     gp.period_name = gb.period_name
       AND gb.actual_flag = 'B'
       AND gb.currency_code = 'BYN'
       AND NVL (gp.adjustment_period_flag, 'N') = 'N'
       AND gb.ledger_id = 2047
       AND gb.period_year = '2018'
       AND gb.code_combination_id = cc.code_combination_id
       AND val.flex_value_set_id = 1014715
       AND val.flex_value = cc.segment2
       and NVL(val.attribute2, 'N') = 'Y' 
        AND CC.SEGMENT6 = substr(erb.SEGMENT6, 1, 3) || '000000'
       AND CC.SEGMENT8 = erb.SEGMENT8
       ) divvision_year_amount 
from (SELECT erh.segment1,
         erh.description,
         wf.full_name,
         erd.code_combination_id,
         ccid.segment2,
         ccid.segment6,
         ccid.segment8,
         sum(erd.req_line_quantity*erl.unit_price) amount
    FROM PO_REQUISITION_HEADERS_ALL erh,
        PO_REQUISITION_LINES_ALL erl,
         PO_REQ_DISTRIBUTIONS_ALL erd,
         gl_code_combinations_kfv ccid,
         PER_PEOPLE_F wf
   WHERE     erl.requisition_header_id = erh.requisition_header_id
         AND erd.requisition_line_id = erl.REQUISITION_LINE_ID
         AND erh.segment1 IN ('74545')
         AND ccid.code_combination_id = erd.code_combination_id
         AND authorization_status = 'REJECTED'
         AND wf.person_id = erh.preparer_id
         AND EFFECTIVE_END_DATE = (select max(EFFECTIVE_END_DATE) from PER_PEOPLE_F where person_id = erh.preparer_id)
         AND erh.creation_date >= TO_DATE ('01042018', 'ddmmyyyy')
GROUP BY erh.segment1,
         erh.description,
         wf.full_name,
         erd.code_combination_id,
         ccid.segment2,
         ccid.segment6,
         ccid.segment8) erb;
         
         
         
SELECT erh.segment1,
         erh.description,
         wf.full_name,
         erh.preparer_id,
         erd.code_combination_id,
         ccid.segment2,
         ccid.segment6,
         ccid.segment8,
         erd.req_line_quantity,
         erl.unit_price
    FROM PO_REQUISITION_HEADERS_ALL erh,
        PO_REQUISITION_LINES_ALL erl,
         PO_REQ_DISTRIBUTIONS_ALL erd,
         gl_code_combinations_kfv ccid,
         PER_PEOPLE_F wf
   WHERE     erl.requisition_header_id = erh.requisition_header_id
         AND erd.requisition_line_id = erl.REQUISITION_LINE_ID
         AND erh.segment1 IN ('74545')
         AND ccid.code_combination_id = erd.code_combination_id
         AND authorization_status = 'REJECTED'
         AND wf.person_id = erh.preparer_id
         AND EFFECTIVE_END_DATE = (select max(EFFECTIVE_END_DATE) from PER_PEOPLE_F where person_id = erh.preparer_id)
         AND erh.creation_date >= TO_DATE ('01042018', 'ddmmyyyy')
                  