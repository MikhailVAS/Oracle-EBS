declare
   l_bres                      BOOLEAN;
   l_trx_error_code            VARCHAR2 (240);
   l_trx_message               VARCHAR2 (2000);
   ls_msg                      VARCHAR2 (1000);
begin


   l_bRes :=
          MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE (
             p_transaction_header_id   => 43692879,
             p_timeout                 => 20,
             p_error_code              => l_trx_error_code,
             p_error_explanation       => l_trx_message);
commit;
end;     


XXTG_MASS_TRANSACTIONS_HDR
XXTG_MASS_TRANSACTIONS_LINES
XXTG_MASS_TRANSACTIONS_UPLOAD