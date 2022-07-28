declare   
    P_LEDGER_ID     NUMBER := 2047; 
    P_CCID          NUMBER := 6104; --
    l_id_flex_num    number(15);
    l_func_curnc     varchar2(15);
    l_period_type    varchar2(15);
    l_delimiter      varchar2(15);
    lx_ccid          number;
    l_valid          boolean := true;
    l_seg_arr        fnd_flex_ext.segmentarray;
    l_segs_num       number;

BEGIN

        BEGIN
          SELECT gb.chart_of_accounts_id,
                 gb.currency_code,
                 gb.accounted_period_type
            INTO l_id_flex_num,
                 l_func_curnc,
                 l_period_type
            FROM gl_sets_of_books gb
           WHERE gb.set_of_books_id = p_ledger_id;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.put_line ('Error retrieving LEDGER data (LEDGER id = '||P_LEDGER_ID||'). '||SQLERRM);
        END;    

    l_delimiter := fnd_flex_ext.get_delimiter('SQLGL' ,'GL#', l_id_flex_num);

    -- Get KFF segment array
    l_valid := fnd_flex_ext.get_segments('SQLGL','GL#', l_id_flex_num, p_ccid, l_segs_num, l_seg_arr);

    FOR accs IN ( 
SELECT assignment_id, DEFAULT_CODE_COMB_ID, concatenated_segments curr_acc, substr(concatenated_segments, 1, instr(concatenated_segments, '.', 1, 5)) ||
(SELECT cak.segment1
          FROM (SELECT ff.assignment_id, ff.person_id
                  FROM (SELECT assignment_id,
                               organization_id,
                               person_id,
                               effective_end_date,
                               MAX (effective_end_date)
                                  OVER (PARTITION BY assignment_id)
                                  max_date
                          FROM per_all_assignments_f f) ff
                 WHERE ff.max_date = ff.effective_end_date) asg,
               PAY_COST_ALLOCATION_KEYFLEX cak,
               PAY_COST_ALLOCATIONS_F caf
         WHERE 1 = 1 
               AND caf.EFFECTIVE_END_DATE =
                      TO_DATE ('31.12.4712', 'DD.MM.YYYY')
                      AND asg.assignment_id = asg1.assignment_id
               AND caf.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
               AND caf.COST_ALLOCATION_KEYFLEX_ID =
                      cak.COST_ALLOCATION_KEYFLEX_ID
               and rownum=1)
 || substr(concatenated_segments, instr(concatenated_segments, '.', 1, 6)) new_acc,
 (SELECT cak.segment1
          FROM (SELECT ff.assignment_id, ff.person_id
                  FROM (SELECT assignment_id,
                               organization_id,
                               person_id,
                               effective_end_date,
                               MAX (effective_end_date)
                                  OVER (PARTITION BY assignment_id)
                                  max_date
                          FROM per_all_assignments_f f) ff
                 WHERE ff.max_date = ff.effective_end_date) asg,
               PAY_COST_ALLOCATION_KEYFLEX cak,
               PAY_COST_ALLOCATIONS_F caf
         WHERE 1 = 1 
               AND caf.EFFECTIVE_END_DATE =
                      TO_DATE ('31.12.4712', 'DD.MM.YYYY')
                      AND asg.assignment_id = asg1.assignment_id
               AND caf.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
               AND caf.COST_ALLOCATION_KEYFLEX_ID =
                      cak.COST_ALLOCATION_KEYFLEX_ID
                      and rownum=1) dep
,  segment1
,  segment2
,  segment3
,  segment4
,  segment5 
,  segment6
,  segment7
,  segment8
,  segment9
,  segment10
,  segment11
,  segment12
,  segment13
,  segment14
,  segment15
FROM hr.per_all_assignments_f asg1,
gl_code_combinations_kfv
where EFFECTIVE_END_DATE = to_date('31.12.4712' , 'DD.MM.YYYY') 
--and person_id = 12572
and code_combination_id = DEFAULT_CODE_COMB_ID
and concatenated_segments is not null
                                    ) 
    LOOP

        if accs.curr_acc != accs.new_acc then

            l_seg_arr(1) := accs.segment1; 
            l_seg_arr(2) := accs.segment2; 
            l_seg_arr(3) := accs.segment3; 
            l_seg_arr(4) := accs.segment4; 
            l_seg_arr(5) := accs.segment5; 
            l_seg_arr(6) := accs.dep; 
            l_seg_arr(7) := accs.segment7; 
            l_seg_arr(8) := accs.segment8; 
            l_seg_arr(9) := accs.segment9; 
            l_seg_arr(10) := accs.segment10; 
            l_seg_arr(11) := accs.segment11; 
            l_seg_arr(12) := accs.segment12; 
            l_seg_arr(13) := accs.segment13; 
            l_seg_arr(14) := accs.segment14; 
            l_seg_arr(15) := accs.segment15; 

            -- Checking account existance (=validity)
            l_valid := fnd_flex_ext.get_combination_id('SQLGL','GL#', l_id_flex_num, SYSDATE, l_segs_num, l_seg_arr, lx_ccid );
            
            IF l_valid  THEN
            null;
            ELSE
                DBMS_OUTPUT.put_line('Error getting account CCID. '||fnd_flex_ext.get_message);
            END IF;


  DBMS_OUTPUT.put_line('assignment_id=' || accs.assignment_id || accs.curr_acc || ' to ' || accs.new_acc);


        update hr.per_all_assignments_f asg1
        set DEFAULT_CODE_COMB_ID = lx_ccid
        where EFFECTIVE_END_DATE = to_date('31.12.4712' , 'DD.MM.YYYY') 
        and assignment_id = accs.assignment_id;
        
        
   end if;

    END LOOP;

END ;
