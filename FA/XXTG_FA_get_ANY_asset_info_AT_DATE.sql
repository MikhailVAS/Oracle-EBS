SELECT *
FROM FA_ADDITIONS_B ASSET
JOIN (SELECT /*+ first_rows(40000) */ fdd2.asset_id, fdd2.book_type_code, fdd2.max_period_counter
            ,fdd2.max_distribution_id_to_date, fds0.deprn_amount, fds0.ytd_deprn, fds0.deprn_reserve, fdd0.cost--, fdd0.*
      FROM FA_DEPRN_SUMMARY fds0, FA_DEPRN_DETAIL fdd0 
          ,(SELECT fdd1.asset_id, fdd1.book_type_code, fdd1.deprn_source_code
                  ,MAX(fdd1.distribution_id) KEEP (DENSE_RANK LAST ORDER BY fdd1.deprn_run_date) MAX_DISTRIBUTION_ID_TO_DATE
                  --,MAX(fdd1.deprn_run_date)                                                      MAX_DEPRN_RUN_DATE
                  ,MAX(fdd1.period_counter)                                                      MAX_PERIOD_COUNTER
            FROM FA_DEPRN_DETAIL fdd1
                ,(SELECT fdp1.period_counter, fdp1.calendar_period_close_date, fdp1.period_close_date FROM FA_DEPRN_PERIODS fdp1 
                  WHERE TO_DATE('&P_TO_DATE','DD.MM.RRRR') BETWEEN fdp1.period_open_date AND fdp1.period_close_date) FDPD
            WHERE TRUNC(fdd1.deprn_run_date) <= decode(TO_DATE('&P_TO_DATE','DD.MM.RRRR')
                                                      ,fdpd.calendar_period_close_date,fdpd.period_close_date
                                                      ,TO_DATE('&P_TO_DATE','DD.MM.RRRR'))
              AND fdd1.deprn_source_code = 'D'
            GROUP BY fdd1.asset_id, fdd1.book_type_code, fdd1.deprn_source_code
           ) fdd2
          WHERE fds0.asset_id = fdd2.asset_id 
            AND fds0.book_type_code = fdd2.book_type_code
            AND fds0.period_counter = fdd2.max_period_counter
            AND SUBSTR(fds0.deprn_source_code,1,1) = fdd2.deprn_source_code
            AND fdd0.book_type_code = fdd2.book_type_code
            AND fdd0.period_counter = fdd2.max_period_counter
            AND fdd0.distribution_id = fdd2.max_distribution_id_to_date
            AND fdd0.deprn_source_code = fdd2.deprn_source_code
     ) FDS ON
     FDS.ASSET_ID = ASSET.ASSET_ID
-- AND FDS.BOOK_TYPE_CODE = TRN.BOOK_TYPE_CODE 
JOIN (SELECT /*+ first_rows(40000) */  fb2.book_type_code, fb2.asset_id
            ,GREATEST(0,fb0.life_in_months-CEIL(MONTHS_BETWEEN(TO_DATE('&P_TO_DATE','DD.MM.RRRR'),TRUNC(fb0.prorate_date,'MM')))
             --+GREATEST(0,-COUNT(1)+sum(decode(FBS0.DEPRECIATE_FLAG,'YES',1,0)))                    
                                                                            ) REAL_REMAINING_LIFE_TO_DATE
            , fb0.original_cost, fb0.life_in_months, fb0.transaction_header_id_in, fb0.prorate_date, fb0.date_placed_in_service
      FROM FA_BOOKS fb0 
         ,(SELECT fb1.asset_id, fb1.book_type_code
                 ,MAX(fb1.transaction_header_id_in) 
                      KEEP (DENSE_RANK LAST ORDER BY fb1.date_ineffective NULLS LAST, fb1.date_effective)         MAX_TRANSACTION_HEADER_ID_IN
                 --,MAX(fb1.date_effective) KEEP (DENSE_RANK LAST ORDER BY fb1.date_ineffective NULLS LAST)         MAX_DATE_EFFECTIVE
                 --,MAX(NVL(fb1.date_ineffective,SYSDATE+99999)) KEEP (DENSE_RANK LAST ORDER BY fb1.date_effective) MAX_DATE_INEFFECTIVE
           FROM FA_BOOKS fb1
               ,(SELECT fdp1.period_counter, fdp1.calendar_period_close_date, fdp1.period_close_date FROM FA_DEPRN_PERIODS fdp1 
                 WHERE TO_DATE('&P_TO_DATE','DD.MM.RRRR') BETWEEN fdp1.period_open_date AND fdp1.period_close_date) FDPD
           WHERE TRUNC(fb1.date_effective) <= decode(TO_DATE('&P_TO_DATE','DD.MM.RRRR')
                                                    ,fdpd.calendar_period_close_date,fdpd.period_close_date
                                                    ,TO_DATE('&P_TO_DATE','DD.MM.RRRR'))
           GROUP BY fb1.asset_id, fb1.book_type_code
          ) fb2
          WHERE fb0.asset_id = fb2.asset_id 
            AND fb0.book_type_code = fb2.book_type_code
            AND fb0.transaction_header_id_in = fb2.max_transaction_header_id_in
     ) FB ON
     FB.ASSET_ID = FDS.ASSET_ID
 AND FB.BOOK_TYPE_CODE = FDS.BOOK_TYPE_CODE
WHERE 1 = 1
  AND FB.BOOK_TYPE_CODE = '&P_BOOK_TYPE_CODE'
  AND ASSET.ASSET_ID = &P_ASSET_ID
; 
