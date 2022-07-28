declare
l_ret_code1 varchar2(1000);
l_ret_code2 varchar2(1000);
l_point number := 8465271;
l_dealer varchar2(1000) := 'ФЛГ9';
begin
     
--     DBMS_OUTPUT.put_line (ranges.dealer_code || ' - ' ||  '0' || sn || ' - ' || l_point);
            XXTG_INV_SCARD_ACT_PUB.ACTIVATE_SCRATCH_CARD(l_ret_code1, l_ret_code2, l_dealer, '041072120', l_point);

commit;
  
end;
