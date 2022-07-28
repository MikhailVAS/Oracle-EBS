create or replace package xxtg_egr_ef_processing_pkg as
       
  procedure get_data_from_egr(p_errbuf out varchar2 ,
                              p_retcode out varchar2);
  procedure upd_end_data_ap_suppliers(p_errbuf out varchar2 ,
                                      p_retcode out varchar2);
end;
