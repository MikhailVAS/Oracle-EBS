
 SELECT owners.account_owner_party_id,
  asp.segment1 vendor_num,
  asp.vendor_name,
  (SELECT NAME
  FROM apps.hr_operating_units hou
  WHERE 1                 = 1
  AND hou.organization_id = asa.org_id
  ) ou_name,
  asa.vendor_site_code,
  ieb.country_code,
  cbbv.bank_name,
  cbbv.bank_number,
  cbbv.bank_branch_name,
  cbbv.branch_number,
  cbbv.bank_branch_type,
  cbbv.eft_swift_code,
  ieb.bank_account_num,
  ieb.currency_code,
  ieb.iban,
  ieb.foreign_payment_use_flag,
  ieb.bank_account_name_alt
FROM apps.iby_pmt_instr_uses_all instrument,
  apps.iby_account_owners owners,
  apps.iby_external_payees_all payees,
  apps.iby_ext_bank_accounts ieb,
  apps.ap_supplier_sites_all asa,
  apps.ap_suppliers asp,
  apps.ce_bank_branches_v cbbv
WHERE owners.primary_flag      = 'Y'
AND owners.ext_bank_account_id = ieb.ext_bank_account_id
AND owners.ext_bank_account_id = instrument.instrument_id
AND payees.ext_payee_id        = instrument.ext_pmt_party_id
AND payees.payee_party_id      = owners.account_owner_party_id
AND payees.supplier_site_id    = asa.vendor_site_id
AND asa.vendor_id              = asp.vendor_id
AND cbbv.branch_party_id(+)    = ieb.branch_id
  --and asp.vendor_name like '%ABC Emp, Name'
AND asp.vendor_name LIKE 'ABCD LLC'
ORDER BY 4,
  1,
  3 ;


SELECT   VENDOR_NAME,IEBA.BANK_ACCOUNT_NUM,
         IEBA.BANK_ACCOUNT_NAME,
         cbv.BANK_NAME,
         cbv.ADDRESS_LINE1 BANK_ADDRESS_1,
         CBV.COUNTRY BANK_COUNTRY,
         CBV.CITY BANK_CITY,
         CBBV.BANK_BRANCH_NAME,
         CBBV.ADDRESS_LINE1 BRANCH_ADDRESS_1,
         CBBV.CITY BRANCH_CITY,
         CBBV.COUNTRY BRANCH_COUNTRY,
         CBBV.BRANCH_NUMBER,
         CBBV.EFT_SWIFT_CODE Swift_Code ,
         FOREIGN_PAYMENT_USE_FLAG
 FROM    apps.AP_SUPPLIERS APS,
         apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
         apps.IBY_PMT_INSTR_USES_ALL IPIUA,
         APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
         apps.ce_banks_v cbv, 
         apps.ce_bank_BRANCHES_V CBBV
 WHERE   1=1
     AND APS.VENDOR_ID IN (select VENDOR_ID from apps.AP_SUPPLIER_SITES_ALL ass)
     AND IEPA.PAYEE_PARTY_ID=APS.PARTY_ID
     AND PARTY_SITE_ID IS NULL
     AND SUPPLIER_SITE_ID IS NULL
     AND IPIUA.EXT_PMT_PARTY_ID(+)=IEPA.EXT_PAYEE_ID
     AND IEBA.EXT_BANK_ACCOUNT_ID(+)=IPIUA.INSTRUMENT_ID
     AND IEBA.BANK_ID=cbv.BANK_PARTY_ID(+)
     AND IEBA.BRANCH_ID=CBBV.BRANCH_PARTY_ID(+);