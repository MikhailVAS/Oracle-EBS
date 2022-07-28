-- 1. Проверить количество "потерянных" ЭСЧФ
SELECT 'invoice-'||INVOICE_NUM||'.sgn.xml'
FROM XXTG_EHSCHF_KSF
WHERE 1 = 1
  AND INVOICE_STATUS = 'COMPLETED'
  AND file_name IS NULL
;-- Ориентировчно 923

-- 2. Выполнить фикс для возможности повторного запуска импорта
UPDATE XXTG_EHSCHF_KSF
  SET file_name = 'invoice-'||INVOICE_NUM||'.sgn.xml'
WHERE 1 = 1
  AND INVOICE_STATUS = 'COMPLETED'
  AND file_name IS NULL
;

         -- Исключить из обработки ошибочные ЭСЧФ
UPDATE XXTG_EHSCHF_KSF
   SET FILE_NAME = NULL
WHERE  ISSUANCE_ID IN (11545,11548,15184,15352,312508,312509,312511,312510);

-- 3. Запустить импорт
exec APPS.XXTG_EHSCHF_AP_KSF_PKG.prepare_files;

-- 4. Выполнить загрузку статусов на портал
-- 5. Проверить результат.


