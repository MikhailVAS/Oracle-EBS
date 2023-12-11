/* Выгрузка по вендорам УНП , статус, код диллера и склад */
SELECT aps.VENDOR_ID,
       aps.VENDOR_NAME
           AS "Наименование",
       aps.VENDOR_NAME_ALT
           AS "Альтернативное наименование",
       aps.VAT_REGISTRATION_NUM
           AS "УНП",
       NVL2 (TO_CHAR (aps.END_DATE_ACTIVE), 'No', 'Active')
           AS "Статус",
       aps.VENDOR_TYPE_LOOKUP_CODE
           AS "Тип Фирмы",
       MSI.SECONDARY_INVENTORY_NAME
           AS "Код дилера",
           MSI.ORGANIZATION_ID,
       CASE MSI.ORGANIZATION_ID
           WHEN 82 THEN 'BMW: Организаци ведения ТМЦ'
           WHEN 83 THEN 'BBW: Склад Бест'
           WHEN 84 THEN 'BDW: Дилеры'
           WHEN 85 THEN 'BHW: Головной офис Бест'
           WHEN 86 THEN 'BSW: Подрядчики'
           ELSE 'Слад не привязан'
    END
           AS "Наименованеи_склада"
  FROM ap.ap_suppliers                aps,
       ap.ap_supplier_sites_all       apss,
       APPS.ar_customers              ars,
       inv.MTL_SECONDARY_INVENTORIES  MSI
 WHERE     aps.vendor_id = apss.vendor_id
       AND ars.CUSTOMER_NAME(+) = aps.VENDOR_NAME
       --AND ars.TAX_REFERENCE = aps.VAT_REGISTRATION_NUM
	   AND aps.VAT_REGISTRATION_NUM = 'УНП'
       AND ars.CUSTOMER_ID = MSI.ATTRIBUTE5(+)
       --AND VENDOR_NAME like 'Навиком%'   --- 104409



  SELECT DISTINCT *
            FROM XXTG.xxtg_ef_suppliers xes, XXTG.xxtg_ef_status xest
           WHERE     TAX_REFERENCE in ('191041473', '101386085','193197348')--asu.vendor_id(+) = xest.vendor_id
                  AND xest.ef_id = xes.ef_id(+)	   
/* Типы счет-фактур AP в eFirme*/
SELECT *
  FROM XXTG.XXTG_EF_INVOICE_TYPE 
 WHERE     1 = 1
       AND VENDOR_ID =
           (SELECT VENDOR_ID
              FROM ap.ap_suppliers
             WHERE VENDOR_NAME LIKE 'МПОВТ ОАО%')
			 
/* Find  AP Invoice Type by nymber*/
SELECT (SELECT sup.VENDOR_NAME
          FROM ap.ap_suppliers sup
         WHERE sup.VENDOR_ID = EI.VENDOR_ID) AS "Vendor name",
       EI.INVOICE_TYPE_DETAIL,
       EI.ENABLED_FLAG,
       EI.CREATION_DATE,
       EI.LAST_UPDATE_DATE
  FROM XXTG.XXTG_EF_INVOICE_TYPE EI
 WHERE    INVOICE_TYPE_DETAIL LIKE '%106 сэп-09/2009 от 01.09.09%'
       OR INVOICE_TYPE_DETAIL LIKE '%17/09-БеСТ от 01.06.09г%'
       OR INVOICE_TYPE_DETAIL LIKE '%26юр/2009 от 22.12.09%'
	   
/* Find duplicate contract in eFirm */
  SELECT PROCESS, INVOICE_TYPE_DETAIL, COUNT (INVOICE_TYPE_DETAIL)
    FROM XXTG_EF_INVOICE_TYPE
   WHERE VENDOR_ID = (SELECT VENDOR_ID
                        FROM ap.ap_suppliers
                       WHERE VENDOR_NAME LIKE 'Лайфтех ООО РБ')
--             AND PROCESS = 'AR'
GROUP BY PROCESS, INVOICE_TYPE_DETAIL
  HAVING COUNT (INVOICE_TYPE_DETAIL) > 1
	   
/* Formatted on 19.12.2018 11:08:06 (QP5 v5.318) Service Desk 263186 Mihail.Vasiljev */
UPDATE xxtg_gl001_double_global a
   SET D_AN_CODE_3 = '1151360', D_AN_DESC_3 = 'ЗАО "БеСТ" 190579561'
 WHERE (C_DOC_NUM IN ('35679388') OR d_DOC_NUM IN ('35679388'))

/* Formatted on 24.08.2018 19:23:47 (QP5 v5.318) */
  SELECT DISTINCT
         VENDOR_NAME
             AS "Наименование",
         VENDOR_NAME_ALT
             AS "Альтернативное наименование",
         NVL2 (TO_CHAR (END_DATE_ACTIVE), 'No', 'Active')
             AS "Статус",
         TAX_REFERENCE
             AS "УНП",
         VENDOR_TYPE_LOOKUP_CODE
             AS "Тип Фирмы",
         EFSUP.END_DATE_ACTIVE
             AS "End Date",
         EFSUP.CREATION_DATE
             AS "Дада создания",
         EFSUP.LAST_UPDATE_DATE
             AS "Дата изменения записи",
         PER.FULL_NAME
             AS "Кто последний редактировал"
    FROM XXTG.XXTG_EF_SUPPLIERS EFSUP, apps.fnd_user fu, APPS.PER_PEOPLE_F PER
   WHERE EFSUP.last_updated_by = fu.user_id AND fu.EMPLOYEE_ID = PER.PERSON_ID
ORDER BY VENDOR_NAME ASC


/* Поиск счетов по названию фирмы */
  SELECT *
    FROM APPS.XXTG_EF_SUPPLIER_BANKS
   WHERE vendor_id =
         (SELECT vendor_id
            FROM xxtg.xxtg_ef_suppliers
           WHERE vendor_name =
                 'ГУ  РБ.')
--AND BANK_ACCOUNT_NUM = 'BY88AKCCB21024310008770000000' -- Поиск по IBAN
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
               'ГУ  РБ ')
			   
/* Formatted on 24.07.2019 14:47:11 (QP5 v5.326) Service Desk  Mihail.Vasiljev */
  SELECT *
    FROM (  SELECT aps.VENDOR_ID,
                   aps.VENDOR_NAME,
                   aps.VENDOR_NAME_ALT,
                   aps.VENDOR_TYPE_LOOKUP_CODE,
                   aps.num_1099,
                   aps.end_date_active,
                   aps.vat_registration_num,
                   aps.attribute1,
                   aps.attribute4,
                   'UpdateEnable'
                       detail_Flag,
                   DECODE (
                       (SELECT xest3.status
                          FROM XXTG.xxtg_ef_status xest3
                         WHERE     xest3.vendor_id = aps.VENDOR_ID
                               AND xest3.ef_id =
                                   (  SELECT MAX (ef_id)
                                        FROM XXTG.xxtg_ef_status xest2
                                       WHERE xest2.vendor_id = aps.VENDOR_ID
                                    GROUP BY xest2.vendor_id)),
                       'REJECTED', 'False',
                       'True')
                       history_detail,
                   (  SELECT MAX (ef_id)
                        FROM XXTG.xxtg_ef_status xest2
                       WHERE xest2.vendor_id = aps.VENDOR_ID
                    GROUP BY xest2.vendor_id)
                       AS ef_id,
                   DECODE (
                       (SELECT xest3.status
                          FROM XXTG.xxtg_ef_status xest3
                         WHERE     xest3.vendor_id = aps.VENDOR_ID
                               AND xest3.ef_id =
                                   (  SELECT MAX (ef_id)
                                        FROM XXTG.xxtg_ef_status xest2
                                       WHERE xest2.vendor_id = aps.VENDOR_ID
                                    GROUP BY xest2.vendor_id)),
                       'PROCESSED', 'APPROVED',
                       'REJECTED', 'REJECTED',
                       'APPROVED')
                       AS approval_status,
                   CASE
                       WHEN NVL (aps.end_date_active, SYSDATE + 1) > SYSDATE
                       THEN
                           'active'
                       ELSE
                           'inactive'
                   END
                       AS enabled
              FROM APPS.ap_suppliers aps
             WHERE aps.vendor_id NOT IN
                       (SELECT NVL (vendor_id, -1)
                          FROM XXTG.xxtg_ef_status xest
                         WHERE     xest.STATUS NOT IN ('PROCESSED', 'REJECTED')
                               AND xest.ef_id IN (  SELECT MAX (ef_id)
                                                      FROM XXTG.xxtg_ef_status xxe
                                                  GROUP BY vendor_id))
          GROUP BY aps.VENDOR_ID,
                   aps.VENDOR_NAME,
                   aps.VENDOR_NAME_ALT,
                   aps.VENDOR_TYPE_LOOKUP_CODE,
                   aps.num_1099,
                   aps.end_date_active,
                   aps.vat_registration_num,
                   aps.attribute1,
                   aps.attribute4
          UNION ALL
          SELECT NVL (xes.VENDOR_ID, asu.VENDOR_ID),
                 NVL (xes.VENDOR_NAME, asu.VENDOR_NAME),
                 NVL (xes.VENDOR_NAME_ALT, asu.VENDOR_NAME_ALT),
                 NVL (xes.VENDOR_TYPE_LOOKUP_CODE, asu.VENDOR_TYPE_LOOKUP_CODE),
                 NVL (xes.Jgzz_Fiscal_Code, asu.num_1099),
                 NVL (xes.end_date_active, asu.end_date_active),
                 NVL (xes.TAX_REFERENCE, asu.vat_registration_num),
                 NVL (xes.attribute1, asu.attribute1),
                 NVL (xes.attribute4, asu.attribute4),
                 CASE
                     WHEN xest.STATUS = 'SAVED' THEN 'UpdateEnableSave'
                     ELSE 'UpdateDisable'
                 END
                     AS detail_Flag,
                 CASE WHEN xest.STATUS = 'SAVED' THEN 'True' ELSE 'False' END
                     AS history_detail,
                 xest.ef_id,
                 CASE
                     WHEN xest.STATUS = 'SAVED' THEN 'SAVED'
                     ELSE 'WAITING_APPROVAL'
                 END
                     AS approval_status,
                 CASE
                     WHEN NVL (NVL (xes.end_date_active, asu.end_date_active),
                               SYSDATE + 1) >
                          SYSDATE
                     THEN
                         'active'
                     ELSE
                         'inactive'
                 END
                     AS enabled
            FROM XXTG.xxtg_ef_suppliers xes, APPS.ap_suppliers asu, XXTG.xxtg_ef_status xest
           WHERE     asu.vendor_id(+) = xest.vendor_id
                 AND xest.ef_id = xes.ef_id(+)
                 AND xest.STATUS NOT IN ('PROCESSED', 'REJECTED')
                 AND (   xes.vendor_id IS NULL
                      OR xest.ef_id IN (  SELECT MAX (ef_id)
                                            FROM XXTG.xxtg_ef_status xxe
                                        GROUP BY vendor_id)) /*SELECT aps.VENDOR_ID, aps.VENDOR_NAME, aps.VENDOR_NAME_ALT, aps.VENDOR_TYPE_LOOKUP_CODE, aps.num_1099, aps.end_date_active, aps.vat_registration_num, aps.attribute1, aps.attribute4, 'Y' detail_Flag FROM ap_suppliers aps*/
                                                            ) QRSLT
   WHERE (1 = 1 AND UPPER (vendor_name) LIKE UPPER ('%Тресском%'))
ORDER BY QRSLT.VENDOR_NAME ASC

 SELECT VAT_REGISTRATION_NUM,
         VENDOR_NAME,
         INVOICE_TYPE_DETAIL
             AS COntract_NO,
         VENDOR_TYPE_LOOKUP_CODE,
         sup.CREATION_DATE,
         (SELECT FULL_NAME
            FROM per_all_people_f PAPF
           WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                         FROM fnd_user fu
                                        WHERE fu.user_id = sup.CREATED_BY)
                 AND ROWNUM = 1)
             AS "CREATOR SUPPLIER",
         TT.NAME
             "TERMS NAME",
         TT.DESCRIPTION
             "TERMS DESCRIPTION"
    FROM ap.ap_suppliers sup
         LEFT JOIN XXTG.XXTG_EF_INVOICE_TYPE EIT
             ON sup.VENDOR_ID = EIT.VENDOR_ID
         LEFT JOIN APPS.AP_TERMS_TL TT
             ON EIT.PAYMENT_TERM = TT.TERM_ID AND TT.SOURCE_LANG = 'US'
   WHERE                                       --VENDOR_NAME LIKE 'МПОВТ ОАО%'
         sup.CREATION_DATE BETWEEN TO_DATE ('01.01.2019 00:00:00',
                                            'dd.mm.yyyy HH24:MI:ss')
                               AND TO_DATE ('31.12.2019 23:59:59',
                                            'dd.mm.yyyy HH24:MI:ss')
ORDER BY VAT_REGISTRATION_NUM


/* NEW with correct vendor Creator */
  SELECT DISTINCT
         efs.VENDOR_ID,
         sup.VAT_REGISTRATION_NUM,
         sup.VENDOR_NAME,
         sup.VENDOR_TYPE_LOOKUP_CODE,
         INVOICE_TYPE_DETAIL
             AS COntract_NO,
         (SELECT FULL_NAME
            FROM per_all_people_f PAPF
           WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                         FROM fnd_user fu
                                        WHERE fu.user_id = EIT.CREATED_BY)
                 AND ROWNUM = 1)
             AS "Contract CREATED_BY",
         efs.CREATION_DATE
             AS "Contract CREATION_DATE",
         EIT.PROCESS,
         END_DATE,
         TT.NAME
             "TERMS NAME",
         TT.DESCRIPTION
             "TERMS DESCRIPTION",
         sup.CREATION_DATE
             AS "eFirm CREATION_DATE",
         (SELECT FULL_NAME
            FROM per_all_people_f PAPF
           WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
                                         FROM fnd_user fu
                                        WHERE fu.user_id = efs.CREATED_BY)
                 AND ROWNUM = 1)
             AS "eFirm CREATED_BY"
    FROM xxtg_ef_suppliers efs
         LEFT JOIN ap.ap_suppliers sup ON sup.VENDOR_ID = efs.VENDOR_ID
         LEFT JOIN XXTG.XXTG_EF_INVOICE_TYPE EIT
             ON sup.VENDOR_ID = EIT.VENDOR_ID
         LEFT JOIN APPS.AP_TERMS_TL TT
             ON EIT.PAYMENT_TERM = TT.TERM_ID AND TT.SOURCE_LANG = 'US'
   WHERE                                       --VENDOR_NAME LIKE 'МПОВТ ОАО%'
         efs.CREATION_DATE BETWEEN TO_DATE ('01.01.2019 00:00:00',
                                            'dd.mm.yyyy HH24:MI:ss')
                               AND TO_DATE ('31.12.2019 23:59:59',
                                            'dd.mm.yyyy HH24:MI:ss')
ORDER BY sup.CREATION_DATE DESC,efs.CREATION_DATE DESC, VAT_REGISTRATION_NUM


/* Выгрузка по вендорам УНП , статус, код диллера и склад */
SELECT aps.VENDOR_NAME
  FROM ap.ap_suppliers                aps,
       ap.ap_supplier_sites_all       apss,
       APPS.ar_customers              ars,
       inv.MTL_SECONDARY_INVENTORIES  MSI
 WHERE     aps.vendor_id = apss.vendor_id
       AND ars.CUSTOMER_NAME(+) = aps.VENDOR_NAME
       --AND ars.TAX_REFERENCE = aps.VAT_REGISTRATION_NUM
	   AND aps.VAT_REGISTRATION_NUM = '192749704'
       AND ars.CUSTOMER_ID = MSI.ATTRIBUTE5(+)
       --AND VENDOR_NAME like 'Навиком%'   --- 104409
	   
SELECT   HZP.PARTY_NAME "VENDOR NAME",
           APS.SEGMENT1 "VENDOR NUMBER",
           ASS.VENDOR_SITE_CODE "SITE CODE",
           IEB.BANK_ACCOUNT_NUM "ACCOUNT NUMBER",
           IEB.BANK_ACCOUNT_NAME "ACCOUNT NAME",
           HZPBANK.PARTY_NAME "BANK NAME",
           HOPBRANCH.BANK_OR_BRANCH_NUMBER "BANK NUMBER",
           HZPBRANCH.PARTY_NAME "BRANCH NAME",
           HOPBRANCH.BANK_OR_BRANCH_NUMBER "BRANCH NUMBER"
    FROM   HZ_PARTIES HZP,
           AP_SUPPLIERS APS,
           HZ_PARTY_SITES SITE_SUPP,
           AP_SUPPLIER_SITES_ALL ASS,
           IBY_EXTERNAL_PAYEES_ALL IEP,
           IBY_PMT_INSTR_USES_ALL IPI,
           IBY_EXT_BANK_ACCOUNTS IEB,
           HZ_PARTIES HZPBANK,
           HZ_PARTIES HZPBRANCH,
           HZ_ORGANIZATION_PROFILES HOPBANK,
           HZ_ORGANIZATION_PROFILES HOPBRANCH
   WHERE       HZP.PARTY_ID = APS.PARTY_ID
           AND HZP.PARTY_ID = SITE_SUPP.PARTY_ID
           AND SITE_SUPP.PARTY_SITE_ID = ASS.PARTY_SITE_ID
           AND ASS.VENDOR_ID = APS.VENDOR_ID
           AND IEP.PAYEE_PARTY_ID = HZP.PARTY_ID
           AND IEP.PARTY_SITE_ID = SITE_SUPP.PARTY_SITE_ID
           AND IEP.SUPPLIER_SITE_ID = ASS.VENDOR_SITE_ID
           AND IEP.EXT_PAYEE_ID = IPI.EXT_PMT_PARTY_ID
           AND IPI.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID
           AND IEB.BANK_ID = HZPBANK.PARTY_ID
           AND IEB.BANK_ID = HZPBRANCH.PARTY_ID
           AND HZPBRANCH.PARTY_ID = HOPBRANCH.PARTY_ID
           AND HZPBANK.PARTY_ID = HOPBANK.PARTY_ID
ORDER BY   1, 3


/*Expense Contract detail*/
SELECT xei.invoice_type_id
           AS ef_contract_id,
       invoice_type_detail
           AS contract_number --,
--       NVL ( :XXTG_EXPENSE_CONTRACTS_B2.start_date_of_agreement,
--            xei.start_date)
--           AS start_date,
--       NVL ( :XXTG_EXPENSE_CONTRACTS_B2.end_date_of_agreement, xei.end_date)
--           AS end_date
,xi.flex_value
  FROM xxtg_ef_invoice_type xei, xxtg_invoice_types_v xi
 WHERE     NOT EXISTS
               (SELECT 1
                  FROM xxtg_expense_contracts xec
                 WHERE xec.ef_contract_id = xei.invoice_type_id)
       AND vendor_id = (SELECT VENDOR_ID
              FROM ap.ap_suppliers
             WHERE VAT_REGISTRATION_NUM = '100336872')
       AND xei.invoice_type = TO_CHAR (xi.flex_value_id)
       AND xi.flex_value =
           xxtg_fa_utility_pkg.get_param_value ('XXTG_RENTING_OTF_TYPE')


select hl.ADDRESS1, hl.POSTAL_CODE || ',' || pt.TERRITORY_SHORT_NAME || ',' || hl.CITY || ',' ||  hl.ADDRESS2 || ',' || hl.ADDRESS3
from   hz_cust_accounts ca
     , hz_cust_acct_sites_all cas
     , hz_cust_site_uses_all hcsua
     , hz_party_sites ps
     , hz_parties p
     , hz_locations hl
     , fnd_territories_vl pt
where 1=1
  and cas.cust_account_id=ca.cust_account_id
  and cas.cust_account_id=ca.cust_account_id
  and ps.party_site_id=cas.party_site_id
  and hl.location_id=ps.location_id
  and hcsua.cust_acct_site_id = cas.cust_acct_site_id
  and hcsua.site_use_code = 'BILL_TO'
  and hcsua.PRIMARY_FLAG = 'Y'
  and pt.TERRITORY_CODE = hl.country
  and p.party_id = ca.party_id
  and p.TAX_REFERENCE = '192817982';


  /* All suppliers and cotrcat  with terms */
  SELECT DISTINCT
--         efs.VENDOR_ID,
         aps.VENDOR_ID,
         aps.VENDOR_NAME
             AS "Наименование",
         aps.VENDOR_NAME_ALT
             AS "Альтернативное наименование",
         aps.VAT_REGISTRATION_NUM
             AS "УНП",
         NVL2 (TO_CHAR (aps.END_DATE_ACTIVE), 'No', 'Active')
             AS "Статус",
         aps.VENDOR_TYPE_LOOKUP_CODE
             AS "Тип Фирмы",
         MSI.SECONDARY_INVENTORY_NAME
             AS "Код дилера",
         --           MSI.ORGANIZATION_ID,
         CASE MSI.ORGANIZATION_ID
             WHEN 82 THEN 'BMW: Организаци ведения ТМЦ'
             WHEN 83 THEN 'BBW: Склад Бест'
             WHEN 84 THEN 'BDW: Дилеры'
             WHEN 85 THEN 'BHW: Головной офис Бест'
             WHEN 86 THEN 'BSW: Подрядчики'
             ELSE 'Слад не привязан'
         END
             AS "Наименованеи_склада",
         INVOICE_TYPE_DETAIL
             AS COntract_NO,
         --         (SELECT FULL_NAME
         --            FROM per_all_people_f PAPF
         --           WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
         --                                         FROM fnd_user fu
         --                                        WHERE fu.user_id = EIT.CREATED_BY)
         --                 AND ROWNUM = 1)
         --             AS "Contract CREATED_BY",
         --         efs.CREATION_DATE
         --             AS "Contract CREATION_DATE",
         EIT.PROCESS,
         END_DATE,
         TT.NAME
             "TERMS NAME",
         TT.DESCRIPTION
             "TERMS DESCRIPTION"
    --         aps.CREATION_DATE
    --             AS "eFirm CREATION_DATE",
    --         (SELECT FULL_NAME
    --            FROM per_all_people_f PAPF
    --           WHERE     PAPF.PERSON_ID = (SELECT fu.EMPLOYEE_ID
    --                                         FROM fnd_user fu
    --                                        WHERE fu.user_id = efs.CREATED_BY)
    --                 AND ROWNUM = 1)
    --             AS "eFirm CREATED_BY"
    FROM xxtg_ef_suppliers efs
         LEFT JOIN ap.ap_suppliers aps ON aps.VENDOR_ID = efs.VENDOR_ID
         LEFT JOIN APPS.ar_customers ars ON ars.CUSTOMER_NAME = aps.VENDOR_NAME
         LEFT JOIN inv.MTL_SECONDARY_INVENTORIES MSI
             ON ars.CUSTOMER_ID = MSI.ATTRIBUTE5
         LEFT JOIN XXTG.XXTG_EF_INVOICE_TYPE EIT
             ON aps.VENDOR_ID = EIT.VENDOR_ID
         LEFT JOIN APPS.AP_TERMS_TL TT
             ON EIT.PAYMENT_TERM = TT.TERM_ID AND TT.SOURCE_LANG = 'US'
   WHERE 1 = 1
ORDER BY aps.VAT_REGISTRATION_NUM


/* Find all vendor with incorrect Employee*/
SELECT DISTINCT pv.VENDOR_ID,
                pv.VENDOR_NAME,
                --       pv.VENDOR_NAME_ALT,
                pv.SEGMENT1,
                pv.VENDOR_TYPE_LOOKUP_CODE,
                pv.PAY_GROUP_LOOKUP_CODE,
                emp.full_name     AS employee_full_name,
                hp.party_name     AS hz_party_name
  FROM po_vendors               pv,
       ap_awt_groups            aag,
       ap_awt_groups            pay_aag,
       rcv_routing_headers      rcpt,
       fnd_currencies_tl        fct,
       fnd_currencies_tl        pay,
       fnd_lookup_values        pay_group,
       ap_terms_tl              terms,
       po_vendors               parent1,
       per_employees_current_x  emp,
       hz_parties               hp,
       AP_INCOME_TAX_TYPES      aptt,
       per_all_people_f         papf
 WHERE     1 = 1
       -- pv.vendor_id =  '12086'
       AND pv.party_id = hp.party_id
       AND pv.parent_vendor_id = parent1.vendor_id(+)
       AND pv.awt_group_id = aag.GROUP_ID(+)
       AND pv.pay_awt_group_id = pay_aag.GROUP_ID(+)
       AND pv.RECEIVING_ROUTING_ID = rcpt.ROUTING_HEADER_ID(+)
       AND fct.language(+) = USERENV ('lang')
       AND pay.language(+) = USERENV ('lang')
       AND pv.invoice_currency_code = fct.currency_code(+)
       AND pv.payment_currency_code = pay.currency_code(+)
       AND pv.pay_group_lookup_code = pay_group.lookup_code(+)
       AND pay_group.lookup_type(+) = 'PAY GROUP'
       AND pay_group.language(+) = USERENV ('lang')
       AND pv.terms_id = terms.term_id(+)
       AND terms.language(+) = USERENV ('LANG')
       AND terms.enabled_flag(+) = 'Y'
       AND pv.employee_id = emp.employee_id(+)
       AND pv.employee_id = papf.person_id(+)
       AND pv.type_1099 = aptt.income_tax_type(+)
       AND pv.VENDOR_NAME != hp.party_name
       AND pv.VENDOR_TYPE_LOOKUP_CODE = 'EMPLOYEE'
       AND pv.VENDOR_NAME != emp.full_name

       /* eFirm trouble long find > 6 min (360 sec default timeout*/
  SELECT *
    FROM (  SELECT aps.VENDOR_ID,
                   aps.VENDOR_NAME,
                   aps.VENDOR_NAME_ALT,
                   aps.VENDOR_TYPE_LOOKUP_CODE,
                   aps.num_1099,
                   aps.end_date_active,
                   aps.vat_registration_num,
                   aps.attribute1,
                   aps.attribute4,
                   'UpdateEnable'                detail_Flag,
                   DECODE (
                       (SELECT xest3.status
                         FROM xxtg_ef_status xest3
                        WHERE     xest3.vendor_id = aps.VENDOR_ID
                              AND xest3.ef_id =
                                  (  SELECT MAX (ef_id)
                                       FROM xxtg_ef_status xest2
                                      WHERE xest2.vendor_id = aps.VENDOR_ID
                                   GROUP BY xest2.vendor_id)),
                       'REJECTED', 'False',
                       'True')                   history_detail,
                   (  SELECT MAX (ef_id)
                        FROM xxtg_ef_status xest2
                       WHERE xest2.vendor_id = aps.VENDOR_ID
                    GROUP BY xest2.vendor_id)    AS ef_id,
                   DECODE (
                       (SELECT xest3.status
                         FROM xxtg_ef_status xest3
                        WHERE     xest3.vendor_id = aps.VENDOR_ID
                              AND xest3.ef_id =
                                  (  SELECT MAX (ef_id)
                                       FROM xxtg_ef_status xest2
                                      WHERE xest2.vendor_id = aps.VENDOR_ID
                                   GROUP BY xest2.vendor_id)),
                       'PROCESSED', 'APPROVED',
                       'REJECTED', 'REJECTED',
                       'APPROVED')               AS approval_status,
                   CASE
                       WHEN NVL (aps.end_date_active, SYSDATE + 1) > SYSDATE
                       THEN
                           'active'
                       ELSE
                           'inactive'
                   END                           AS enabled
              FROM ap_suppliers aps
             WHERE aps.vendor_id NOT IN
                       (SELECT NVL (vendor_id, -1)
                          FROM xxtg_ef_status xest
                         WHERE     xest.STATUS NOT IN ('PROCESSED', 'REJECTED')
                               AND xest.ef_id IN (  SELECT MAX (ef_id)
                                                      FROM xxtg_ef_status xxe
                                                  GROUP BY vendor_id))
          GROUP BY aps.VENDOR_ID,
                   aps.VENDOR_NAME,
                   aps.VENDOR_NAME_ALT,
                   aps.VENDOR_TYPE_LOOKUP_CODE,
                   aps.num_1099,
                   aps.end_date_active,
                   aps.vat_registration_num,
                   aps.attribute1,
                   aps.attribute4
          UNION ALL
          SELECT NVL (xes.VENDOR_ID, asu.VENDOR_ID),
                 NVL (xes.VENDOR_NAME, asu.VENDOR_NAME),
                 NVL (xes.VENDOR_NAME_ALT, asu.VENDOR_NAME_ALT),
                 NVL (xes.VENDOR_TYPE_LOOKUP_CODE, asu.VENDOR_TYPE_LOOKUP_CODE),
                 NVL (xes.Jgzz_Fiscal_Code, asu.num_1099),
                 NVL (xes.end_date_active, asu.end_date_active),
                 NVL (xes.TAX_REFERENCE, asu.vat_registration_num),
                 NVL (xes.attribute1, asu.attribute1),
                 NVL (xes.attribute4, asu.attribute4),
                 CASE
                     WHEN xest.STATUS = 'SAVED' THEN 'UpdateEnableSave'
                     ELSE 'UpdateDisable'
                 END
                     AS detail_Flag,
                 CASE WHEN xest.STATUS = 'SAVED' THEN 'True' ELSE 'False' END
                     AS history_detail,
                 xest.ef_id,
                 CASE
                     WHEN xest.STATUS = 'SAVED' THEN 'SAVED'
                     ELSE 'WAITING_APPROVAL'
                 END
                     AS approval_status,
                 CASE
                     WHEN NVL (NVL (xes.end_date_active, asu.end_date_active),
                               SYSDATE + 1) >
                          SYSDATE
                     THEN
                         'active'
                     ELSE
                         'inactive'
                 END
                     AS enabled
            FROM xxtg_ef_suppliers xes, ap_suppliers asu, xxtg_ef_status xest
           WHERE     asu.vendor_id(+) = xest.vendor_id
                 AND xest.ef_id = xes.ef_id(+)
                 AND xest.STATUS NOT IN ('PROCESSED', 'REJECTED')
                 AND (   xes.vendor_id IS NULL
                      OR xest.ef_id IN (  SELECT MAX (ef_id)
                                            FROM xxtg_ef_status xxe
                                        GROUP BY vendor_id)) /*SELECT aps.VENDOR_ID, aps.VENDOR_NAME, aps.VENDOR_NAME_ALT, aps.VENDOR_TYPE_LOOKUP_CODE, aps.num_1099, aps.end_date_active, aps.vat_registration_num, aps.attribute1, aps.attribute4, 'Y' detail_Flag FROM ap_suppliers aps*/
                                                            ) QRSLT
ORDER BY QRSLT.VENDOR_NAME ASC

