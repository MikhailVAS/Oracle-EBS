/* Поиск счетов по названию фирмы */
  SELECT *
    FROM APPS.XXTG_EF_SUPPLIER_BANKS
   WHERE vendor_id =
         (SELECT vendor_id
            FROM xxtg.xxtg_ef_suppliers
           WHERE vendor_name =
                 'ГУ МФ РБ ПО ГОМЕЛЬСКОЙ ОБЛ.')
--AND BANK_ACCOUNT_NUM = 'BY33AKBB36024020001870000000' -- Поиск по IBAN
ORDER BY 1 DESC

/* Недоступна кнопка Update или в статусе "Wait for Approwal" */
UPDATE APPS.xxtg_ef_status
   SET status = 'PROCESSED'
 WHERE vendor_id = 116211 AND status <> 'PROCESSED' 

--IN PROCESS
--REJECTED
--NEW
--PROCESSED
--ERROR
--SAVED

/* Перевод в статус Новый  */
UPDATE xxtg.XXTG_EF_STATUS
   SET STATUS = 'NEW'
 WHERE ef_id =
       (SELECT ef_id
          FROM xxtg.xxtg_ef_suppliers
         WHERE vendor_name =
               'ГУ МФ РБ ПО ГОМЕЛЬСКОЙ ОБЛ.')