--Add to FLEX_FILD XXTG_INVOICE_TYPE_1

update xxtg.xxtg_otf_payment_codes_all
set budget_approval_flag = 'N'
        , fnc_approval_flag = 'N' 
where otf_payment_code in ('Возн-Е Конт-Провайдер RUR', 'Телефоны сим-карты RUR');

/* Проверка */
SELECT budget_approval_flag, fnc_approval_flag
  FROM xxtg.xxtg_otf_payment_codes_all
 WHERE otf_payment_code IN ('Ден.часть наград конкурса');
 
/* Formatted on 21.01.2019 13:09:20 (QP5 v5.318) Service Desk 269299 Mihail.Vasiljev */
UPDATE xxtg.xxtg_otf_payment_codes_all
   SET budget_approval_flag = 'N', fnc_approval_flag = 'N'
 WHERE otf_payment_code IN ('Ден.часть наград конкурса');