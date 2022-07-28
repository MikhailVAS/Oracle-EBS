/* еще один пока воркэраунд, если не идут платежи, в CashStation, надо, проверить тут, */
SELECT KRED_CITY_NR FROM XXTG_CS_BATCH_DETAILS_V 
WHERE LENGTH(KRED_CITY_NR) > 50

/* если найдутся такие, обновляем на <=50
обновлять здесь
HZ_PARTIES BRANCHPARTY
HZ_LOCATIONS
поле CITY */

/*Пример исправления */
BEGIN 
    UPDATE HZ_PARTIES BRANCHPARTY
SET BRANCHPARTY.CITY = 'Китайско-Белорусский инд. парк Великий камень'
  -- HZ_PARTIES BRANCHPARTY
WHERE 1=1
   AND BRANCHPARTY.PARTY_TYPE = 'ORGANIZATION'
   AND BRANCHPARTY.STATUS = 'A'
   AND LENGTH(BRANCHPARTY.CITY) > 50;
   COMMIT;
END;

/* Прошу утвердить бетч 09 06 20 7 */
UPDATE ap.ap_inv_selection_criteria_all
   SET ATTRIBUTE13 = '7'
 WHERE checkrun_name = '09 06 20 7'
 
 /* Formatted on Close Batch (QP5 v5.326) Service Desk 473813 Mihail.Vasiljev */
UPDATE ap.ap_inv_selection_criteria_all
   SET ATTRIBUTE13 = '7'
 -- SELECT ATTRIBUTE13 from ap.ap_inv_selection_criteria_all
 WHERE ATTRIBUTE13 != '7' AND checkrun_name = '26 03 21 4'
 
 /* Formatted on 17.06.2021 13:03:30 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM XXTG_CS_BATCH_DETAILS_V
 WHERE CHECKRUN_NAME IN ('17 06 21 2',  -- Не дошёл . Записи отсутвуют
                         '17 06 21 13') -- для примера Корректный бэтч\
						 
 --HD#380531
--delete from
--(
select * --
from ap.AP_SELECTED_INVOICES_ALL
where 1=1
and CHECKRUN_NAME  in ('22 06 2021 1 евро')
-- and  invoice_id in (726624)
--and AMOUNT_REMAINING = 450.00
--   )

--########################################################################################
--Если не загрузился платеж: (Cash station)

select * from ap_suppliers where vendor_name='Аристархова Светлана Юрьевна ИП г.Климовск. РФ (ИНН 502105486385)'   --892357

select * from XXTG_CS_ALL_DEALERBANKACCT_V where vendorid=892357

select * from XXTG_CS_ALL_DEALERBANKACCT_V where vendorid in (select VENDOR_ID from ap_suppliers where vendor_name='Светлогорский завод сварочных электродов ООО')

http://10.16.0.34/CS.Web/WS/INTEGRATION.asmx?op=SynchDealerBankAccount


--ISACTIVE = 1  значит на вебсервисе надо написать true Иначе false
--«
--ISABROAD = 0 значит на вебсервисе надо написать false Иначе true

--Результат вебсервиса после нажатия Invoke:


<string xmlns="http://tempuri.org/">SUCCESS</string>

--########################################################################################
 