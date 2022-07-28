CREATE OR REPLACE VIEW XXTG_NMA_REC_TRANS_V
as
(SELECT
distinct DAT.LOCATION_CODE,
DAT.employee_name,
DAT.employee_id,
DAT.ASSET_ID,
DAT.category_class_1,
DAT.category_class_2,
DAT.category_class_3,
DAT.category_class_4,
DAT.category_class_5,
DAT.ASSET_TYPE,
DAT.asset_number,
DAT.tag_number,
DAT.description,
DAT.quantity,
DAT.places_in_service,
DAT.life_in_months,
DAT.life_in_years,
DAT.rem_life_in_months,
DAT.remaining_life_in_months,
DAT.original_cost,
DAT.balance_cost,
DAT.depreciation_amount,
DAT.deprn_reserve,
DAT.F_20,
DAT.DAY,
DAT.MONTH,
DAT.YEAR,
DAT.doc_num,
DAT.RET_DATE,
DAT.Order_Number,
DAT.Order_Date,
DAT.buh_account,
DAT.code,
DAT.COMMITTEE_ID,
DAT.full_name,
DAT.job_name,
DAT.unit,
DAT.MEMBERSHIP_ID,
DAT.transaction_header_id,
DAT.AMOR_AMOUNT,
DAT.PRORATE_DATE,
DAT.F31
FROM 
(
SELECT                                                /*--- Расположение ---*/
       (SELECT location_code
          FROM XXTG_HR_LOCATIONS_V
         WHERE rownum=1 and
         location_id =
               (SELECT loc.segment4
                  FROM fa_locations loc
                 WHERE loc.location_id =
                       (SELECT dh.location_id
                          FROM fa_distribution_history dh
                         WHERE     dh.asset_id = ad.asset_id
                               AND dh.transaction_header_id_in =
                                   (SELECT MAX (th.transaction_header_id)
                                      FROM fa_deprn_periods        dp1,
                                           fa_transaction_headers  th
                                     WHERE     th.book_type_code =
                                               dp1.book_type_code
                                           AND th.book_type_code =
                                               bc.distribution_source_book
                                           AND (   dp1.period_name =
                                                   (SELECT cp2.period_name
                                                      FROM fa_calendar_periods
                                                           cp2,
                                                           fa_book_controls
                                                           bc2
                                                     WHERE     cp2.calendar_type =
                                                               bc2.deprn_calendar
                                                           AND bc2.book_type_code =
                                                               bc.distribution_source_book
                                                           AND cp2.end_date =
                                                               sysdate+100)
                                                OR dp1.period_counter <=
                                                   (SELECT MAX (
                                                               dp2.period_counter)
                                                      FROM fa_deprn_periods
                                                           dp2
                                                     WHERE     th.book_type_code =
                                                               dp2.book_type_code
                                                           AND th.date_effective BETWEEN dp2.period_open_date
                                                                                     AND NVL (
                                                                                             dp2.period_close_date,
                                                                                             th.date_effective)))
                                           AND th.transaction_type_code IN
                                                   ('TRANSFER', 'TRANSFER IN')
                                           AND th.date_effective BETWEEN dp1.period_open_date
                                                                     AND NVL (
                                                                             dp1.period_close_date,
                                                                             th.date_effective)
                                           AND th.asset_id = dh.asset_id))))
          LOCATION_CODE ,
       /*--- МОЛ ---*/
       (SELECT emp.employee_number || ' - ' || emp.name     employee_name
          FROM fa_employees emp
         WHERE   rownum=1 and
         emp.employee_id =
               (SELECT dh.assigned_to
                  FROM fa_distribution_history dh
                 WHERE     dh.asset_id = ad.asset_id
                       AND dh.transaction_header_id_in =
                           (SELECT MAX (th.transaction_header_id)
                              FROM fa_deprn_periods        dp1,
                                   fa_transaction_headers  th
                             WHERE     th.book_type_code = dp1.book_type_code
                                   AND th.book_type_code =
                                       bc.distribution_source_book
                                   AND (   dp1.period_name =
                                           (SELECT TO_CHAR (cp2.period_name)
                                              FROM fa_calendar_periods  cp2,
                                                   fa_book_controls     bc2
                                             WHERE     cp2.calendar_type =
                                                       bc2.deprn_calendar
                                                   AND bc2.book_type_code =
                                                       bc.distribution_source_book
                                                   AND cp2.end_date =
                                                      sysdate+100)
                                        OR dp1.period_counter <=
                                           (SELECT MAX (dp2.period_counter)
                                              FROM fa_deprn_periods dp2
                                             WHERE     th.book_type_code =
                                                       dp2.book_type_code
                                                   AND th.date_effective BETWEEN dp2.period_open_date
                                                                             AND NVL (
                                                                                     dp2.period_close_date,
                                                                                     th.date_effective)))
                                   AND th.transaction_type_code IN
                                           ('TRANSFER', 'TRANSFER IN')
                                   AND th.date_effective BETWEEN dp1.period_open_date
                                                             AND NVL (
                                                                     dp1.period_close_date,
                                                                     th.date_effective)
                                   AND th.asset_id = dh.asset_id)))
         employee_name  ,
       /*--- ID ---*/
       (SELECT employee_id   employee_id
          FROM fa_employees emp
         WHERE   rownum=1 and
         emp.employee_id =
               (SELECT dh.assigned_to
                  FROM fa_distribution_history dh
                 WHERE     dh.asset_id = ad.asset_id
                       AND dh.transaction_header_id_in =
                           (SELECT MAX (th.transaction_header_id)
                              FROM fa_deprn_periods        dp1,
                                   fa_transaction_headers  th
                             WHERE     th.book_type_code = dp1.book_type_code
                                   AND th.book_type_code =
                                       bc.distribution_source_book
                                   AND (   dp1.period_name =
                                           (SELECT TO_CHAR (cp2.period_name)
                                              FROM fa_calendar_periods  cp2,
                                                   fa_book_controls     bc2
                                             WHERE     cp2.calendar_type =
                                                       bc2.deprn_calendar
                                                   AND bc2.book_type_code =
                                                       bc.distribution_source_book
                                                   AND cp2.end_date =
                                                      sysdate+100)
                                        OR dp1.period_counter <=
                                           (SELECT MAX (dp2.period_counter)
                                              FROM fa_deprn_periods dp2
                                             WHERE     th.book_type_code =
                                                       dp2.book_type_code
                                                   AND th.date_effective BETWEEN dp2.period_open_date
                                                                             AND NVL (
                                                                                     dp2.period_close_date,
                                                                                     th.date_effective)))
                                   AND th.transaction_type_code IN
                                           ('TRANSFER', 'TRANSFER IN')
                                   AND th.date_effective BETWEEN dp1.period_open_date
                                                             AND NVL (
                                                                     dp1.period_close_date,
                                                                     th.date_effective)
                                   AND th.asset_id = dh.asset_id)))
         employee_id ,         
       ad.asset_id,
       /*--- Категория актива - Класс ---*/
       (SELECT b.flex_value || ' - ' || t.description
          FROM fnd_flex_values_tl t, fnd_flex_values b
         WHERE     b.flex_value_id = t.flex_value_id
               AND t.language = USERENV ('LANG')
               AND flex_value_set_id =
                   (SELECT flex_value_set_id
                      FROM fnd_flex_value_sets
                     WHERE flex_value_set_name = 'XXTG_FA_MODE')
               AND flex_value = ca.segment1
                and rownum=1)
           category_class_1,
       /*--- Категория актива - Класс ---*/
       (SELECT ffvl.flex_value || ' - ' || ffvl.description
          FROM fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvl
         WHERE     ffvs.flex_value_set_name = 'XXTG_FA_GROUP'
               AND ffvs.flex_value_set_id = ffvl.flex_value_set_id
               AND ffvl.enabled_flag = 'Y'
               AND ffvl.flex_value = ca.segment2
                and rownum=1)
           category_class_2,
       /*--- Категория актива - Класс ---*/
       (SELECT ffvl.flex_value || ' - ' || ffvl.description
          FROM fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvl
         WHERE     ffvs.flex_value_set_name = 'XXTG_FA_SUBGROUP'
               AND ffvs.flex_value_set_id = ffvl.flex_value_set_id
               AND ffvl.enabled_flag = 'Y'
               AND flex_value = ca.segment3)
           category_class_3,
       /*--- Категория актива - Класс ---*/
       (SELECT ffvl.flex_value || ' - ' || ffvl.description
          FROM fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvl
         WHERE     ffvs.flex_value_set_name = 'XXTG_FA_TYPE'
               AND ffvs.flex_value_set_id = ffvl.flex_value_set_id
               AND ffvl.enabled_flag = 'Y'
               AND flex_value = ca.segment4
                and rownum=1)
           category_class_4,
       /*--- Категория актива - Класс ---*/
       (SELECT b.flex_value || ' - ' || t.description
          FROM fnd_flex_values_tl t, fnd_flex_values b
         WHERE     b.flex_value_id = t.flex_value_id
               AND t.language = USERENV ('LANG')
               AND flex_value_set_id =
                   (SELECT flex_value_set_id
                      FROM fnd_flex_value_sets
                     WHERE flex_value_set_name = 'XXTG_FA_ACCOUNTING_GROUP')
               AND flex_value = ca.segment5
                and rownum=1)
           category_class_5,
       /*--- Тип актива ---*/
       (SELECT t.meaning
          FROM fa_lookups_tl t, fa_lookups_b b
         WHERE     b.lookup_type = t.lookup_type
               AND b.lookup_code = t.lookup_code
                and rownum=1
               AND t.language = USERENV ('LANG')
               AND t.lookup_type = 'ASSET TYPE'
               AND b.lookup_code =
                   (SELECT ah.asset_type
                      FROM fa_asset_history ah
                     WHERE     ah.asset_id = ad.asset_id
                           AND ah.transaction_header_id_in =
                               (SELECT MAX (ah2.transaction_header_id_in)
                                  FROM fa_transaction_headers  th,
                                       fa_asset_history        ah2
                                 WHERE     ah2.transaction_header_id_in =
                                           th.transaction_header_id
                                       AND ah2.asset_id = th.asset_id
                                       AND th.asset_id = ah.asset_id
                                       AND th.transaction_date_entered <=
                                           sysdate+100)))
           asset_type,
       /*--- Номер  ---*/
       ad.asset_number
           asset_number,
       /*--- Инвентарный № ---*/
       /*(SELECT ak.segment5
          FROM fa_asset_keywords ak
         WHERE ak.code_combination_id = ad.asset_key_ccid)*/
        ad.tag_number
           tag_number,
       /*--- Наименование основного средства ---*/
       ad.description
           description,
       /*--- Количество ---*/
       (SELECT ah.units
          FROM fa_asset_history ah
         WHERE     ah.asset_id = ad.asset_id
         and rownum=1
               AND ah.transaction_header_id_in =
                   (SELECT MAX (ah2.transaction_header_id_in)
                      FROM fa_transaction_headers th, fa_asset_history ah2
                     WHERE     ah2.transaction_header_id_in =
                               th.transaction_header_id
                           AND ah2.asset_id = th.asset_id
                           AND th.asset_id = ah.asset_id
                           AND th.transaction_date_entered <= sysdate+100))
           quantity,
       /*--- Дата ввода в эксплуатацию ---*/
       TO_CHAR (bk.date_placed_in_service, 'DD.MM.RRRR')
           places_in_service,
       NVL (bk.life_in_months, 0)
           life_in_months,
       case when mod(NVL (bk.life_in_months, 0),12) = 0
           then
               case when NVL (bk.life_in_months, 0)/12 in (1,21,31)
                then bk.life_in_months/12 ||' год'
                when bk.life_in_months/12 in (2,3,4,22,23,24)
                then bk.life_in_months/12 ||' года' 
                else bk.life_in_months/12 ||' лет'
               end
        end  life_in_years,    
         case when mod(NVL (bk.life_in_months, 0),12) != 0 
                then
                case when mod(NVL (bk.life_in_months, 0),12) = 1 
                      then mod(NVL (bk.life_in_months, 0),12)|| ' месяц'
                     when mod(NVL (bk.life_in_months, 0),12) in (2,3,4)
                       then mod(NVL (bk.life_in_months, 0),12)|| ' месяца'
                     else mod(NVL (bk.life_in_months, 0),12)|| ' месяцев' 
                end     
             end  
           rem_life_in_months, 
       mod(NVL (bk.life_in_months, 0),12)
       rem_life_in_years,       
       /*--- Остаток срока службы  (месяцев) ---*/
       (SELECT DECODE (
                   books.period_counter_fully_retired,
                   NULL, GREATEST (
                               NVL (books.life_in_months, 0)
                             - TRUNC (
                                   MONTHS_BETWEEN (
                                       SYSDATE,
                                       books.date_placed_in_service)),
                             0),
                   0)    remaining_life_in_months
          FROM fa_books books
         WHERE books.asset_id = ad.asset_id
         and rownum=1)
           remaining_life_in_months,
       /*--- Первичная стоимость (манат) ---*/
       NVL (bk.original_cost, 0)
           original_cost,
       /*--- Балансовая стоимость (манат) ---*/
       NVL (bk.cost, 0)
           balance_cost,
       /*--- Сумма переоценки ---*/
       NVL (
           (SELECT SUM (pos.reval_reserve)
              FROM FA_DEPRN_DETAIL pos
             WHERE     1 = 1          --- pos.source_type_code = 'REVALUATION'
                   -- AND pos.adjustment_type = 'COST'
                   AND pos.asset_id = ad.asset_id
                   AND pos.book_type_code = bk.book_type_code
                   AND pos.PERIOD_COUNTER <= dp.period_counter
                   AND DEPRN_SOURCE_CODE = 'D'),
           0)
           depreciation_amount,
		                  XXTG_FA_REGISTER_PKG.XXTG_BALANCES (ad.asset_id, bk.book_type_code, -1/*bk.transaction_header_id_in*/, 0/*dp.period_counter*/, 'deprn') deprn_reserve, -- deprn_reserve
          NVL (bk.cost, 0)-XXTG_FA_REGISTER_PKG.XXTG_BALANCES (ad.asset_id, bk.book_type_code, -1/*bk.transaction_header_id_in*/, 0/*dp.period_counter*/, 'deprn')  F_20,
                    EXTRACT(DAY FROM nvl(to_date(substr(fth.attribute2,0,10),'YYYY.MM.DD'),rt.date_retired)) AS DAY,
          CASE EXTRACT(MONTH FROM nvl(to_date(substr(fth.attribute2,0,10),'YYYY.MM.DD'),rt.date_retired))
             when 1 then 'Января'
             when 2 then 'Февраля'
             when 3 then 'Марта'
             when 4 then 'Апреля'
             when 5 then 'Мая'
             when 6 then 'Июня'
             when 7 then 'Июля'
             when 8 then 'Августа'
             when 9 then 'Сентября'
             when 10 then 'Октября'
             when 11 then 'Ноября'
             when 12 then 'Декабря'
           END AS MONTH,
           EXTRACT(YEAR FROM nvl(to_date(substr(fth.attribute2,0,10),'YYYY.MM.DD'),rt.date_retired)) AS YEAR,
           fth.attribute1 doc_num,
           trunc(to_date(substr(fth.attribute10,0,10),'YYYY.MM.DD'),'DD') Order_Date,
           trunc(to_date(substr(fth.attribute2,0,10),'YYYY.MM.DD'),'DD') RET_DATE,
           fth.attribute11 Order_Number,
           -- ОГП для бух счета
           ADD_INFO.local_account||'/'||ADD_INFO.account_description||'/'||ADD_INFO.KAY1 buh_account,
           COMMITEE_VS.CODE code,
           com.COMMITTEE_ID COMMITTEE_ID,
           HR_DATA.full_name full_name,
           HR_DATA.job_name job_name,
           HR_DATA.Organzation unit,
           cmv.membership_id membership_id,
           fth.transaction_header_id,
           bk.prorate_date,
           NVL((fdd.DEPRN_RESERVE + fdd.DEPRN_ADJUSTMENT_AMOUNT + (select DEPRN_RESERVE from FA_DEPRN_DETAIL where PERIOD_COUNTER = fdd.PERIOD_COUNTER-1 and asset_id=rt.asset_id)),0) amor_amount
 -- NVL((fdd.DEPRN_RESERVE + fdd.DEPRN_ADJUSTMENT_AMOUNT + (select DEPRN_RESERVE from FA_DEPRN_DETAIL where PERIOD_COUNTER = fdd.PERIOD_COUNTER-1 and asset_id=rt.asset_id)),0) amor_amount
    , ad.SERIAL_NUMBER F31
  FROM fa_additions       ad,
       fa_book_controls   bc,
       fa_books           bk,
       fa_categories_b    ca,
       fa_category_books  cb,
       fa_deprn_periods   dp,
       fa_retirements     rt,
       FA_DEPRN_DETAIL    fdd,
(SELECT --ffvv.*, ffvs.* 
ffvv.flex_value attribute_category, ffvv.attribute1 local_account, LOC_ACCOUNT.DESCRIPTION account_description, TYPE_ACT.description KAY1                   --attribute1, attribute4, flex_value
  FROM apps.fnd_flex_values_vl ffvv, 
       apps.fnd_flex_value_sets ffvs,
       (SELECT flex_value, ffvv.description description--attribute1, attribute4, flex_value
          FROM apps.fnd_flex_values_vl ffvv, apps.fnd_flex_value_sets ffvs
          WHERE ffvv.flex_value_set_id = ffvs.flex_value_set_id
          AND ffvs.flex_value_set_name = 'XXTG_ACCOUNT') LOC_ACCOUNT,
          (SELECT flex_value, ffvv.description description--attribute1, attribute4, flex_value
          FROM apps.fnd_flex_values_vl ffvv, apps.fnd_flex_value_sets ffvs
          WHERE ffvv.flex_value_set_id = ffvs.flex_value_set_id
          AND ffvs.flex_value_set_name = 'XXTG_TYPE_OF_ACTIVITIES') TYPE_ACT       
 WHERE     ffvv.flex_value_set_id = ffvs.flex_value_set_id
       AND ffvs.flex_value_set_name = 'XXTG_FA_TRANS_TYPE'
       AND LOC_ACCOUNT.FLEX_VALUE(+) = ffvv.attribute1
       AND TYPE_ACT.flex_value(+) = ffvv.attribute4) ADD_INFO,
       (  SELECT v.flex_value_id,
           v.flex_value
               code,
           v.description
               NAME
      FROM fnd_flex_values_vl v, fnd_flex_value_sets s
     WHERE     v.flex_value_set_id = s.flex_value_set_id
           AND s.flex_value_set_name = 'XXTG_COMMITTEE_TYPE'
           AND v.enabled_flag = 'Y') COMMITEE_VS,
       FA_TRANSACTION_HISTORY_TRX_V fth,
       XXTG_COMMITTEE com,
       XXTG_COMMITTEE_MEMBERSHIP_V cmv,
       (SELECT papf.full_name,
            hapf.NAME Position,
            pj.attribute1 job_name,
            haou.NAME Organzation,
            papf.person_id
            FROM 
            per_all_people_f papf,
            per_all_assignments_f asg,
            hr_all_positions_f hapf,
            hr_all_organization_units haou,
            per_jobs           pj
            WHERE papf.person_id = asg.person_id(+)
            AND     pj.job_id(+) = asg.job_id
            AND SYSDATE BETWEEN papf.effective_start_date
            AND papf.effective_end_date
            AND SYSDATE BETWEEN asg.effective_start_date AND asg.effective_end_date
            AND asg.position_id = hapf.position_id(+)
            AND haou.organization_id = asg.organization_id )HR_DATA
 WHERE    bc.book_class = 'CORPORATE'-- DECODE ( :P_REP, 'IFRS', 'CORPORATE')
       AND bk.book_type_code = bc.book_type_code
       AND COM.COMMITEE_TYPE(+) = COMMITEE_VS.flex_value_id
       and com.COMMITTEE_ID  = cmv.COMMITTEE_ID(+)
       and fdd.asset_id=rt.asset_id
       AND fth.asset_id=rt.asset_id
       AND HR_DATA.person_id(+) = cmv.chief_user_id 
       AND COMMITEE_VS.CODE (+) = fth.attribute9
       AND ADD_INFO.attribute_category = fth.attribute_category_code
       --AND fth.TRANSACTION_TYPE in ('Full Retirement','Partial Retirement') 
      -- AND fth.TRANSACTION_TYPE_CODE in ('Полное списание') 
       AND bk.asset_id = ad.asset_id
       AND fth.ATTRIBUTE_CATEGORY_CODE=42--54
       AND bk.transaction_header_id_in = rt.TRANSACTION_HEADER_ID_IN
       and rt.asset_id= ad.asset_id 
       --and EXTRACT(MONTH FROM rt.date_retired) = dp.period_num
       --AND rt.ASSET_ID IN (1037459)
       AND fth.TRANSACTION_HEADER_ID =  rt.TRANSACTION_HEADER_ID_IN
       --and fth.PERIOD_COUNTER = rt.PERIOD_COUNTER
       and bk.transaction_header_id_in = rt.TRANSACTION_HEADER_ID_IN
       and bk.period_counter_fully_reserved = fdd.period_counter
--       and bk.period_counter_fully_retired = fdd.period_counter
       --AND bk.period_counter_fully_retired IS NOT NULL
       AND ca.category_id =
           (SELECT ah.category_id
              FROM fa_asset_history ah
             WHERE     ah.asset_id = ad.asset_id
                   AND ah.transaction_header_id_in =
                       (SELECT MAX (ah2.transaction_header_id_in)
                          FROM fa_transaction_headers  th,
                               fa_asset_history        ah2
                         WHERE     ah2.transaction_header_id_in =
                                   th.transaction_header_id
                               AND ah2.asset_id = th.asset_id
                               AND th.asset_id = ah.asset_id
                               AND th.transaction_date_entered <= sysdate+100))
       AND cb.book_type_code = bk.book_type_code
       AND cb.category_id = ca.category_id
       and fdd.PERIOD_COUNTER=dp.period_counter
       AND dp.book_type_code = bc.book_type_code
       AND dp.period_counter != 1
       AND bk.book_type_code = NVL ( 'BEST_FA_LOCAL', bk.book_type_code)
       --AND bk.date_placed_in_service <= dp.calendar_period_close_date
       --AND rt.date_retired <= dp.calendar_period_close_date
--       AND bk.transaction_header_id_in =
--           (SELECT MAX (ff.transaction_header_id_in)
--              FROM fa_financial_inquiry_cost_v ff
--             WHERE     ff.book_type_code = bk.book_type_code
--                   AND ff.asset_id = ad.asset_id
--                  -- and ff.transaction_type in ('Full Retirement','Partial Retirement') 
--                   AND (SELECT cp1.end_date
--                          FROM fa_calendar_periods cp1
--                         WHERE     cp1.calendar_type = bc.deprn_calendar
--                               AND cp1.period_name = ff.period_effective) <=
--                       sysdate+100)
--       AND EXISTS
--               (SELECT 1
--                  FROM FA_DEPRN_DETAIL dd
--                 WHERE     dd.asset_id = ad.asset_id
--                       AND dd.book_type_code = bk.book_type_code
--                       AND dd.period_counter = dp.period_counter)
)DAT)
