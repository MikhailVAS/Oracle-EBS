SELECT
       -- s.vendor_id,
       -- st.vendor_site_id,
       -- s.party_id,
       -- st.party_site_id,
       s.vendor_name              "Vendor Name",
       s.segment1                 "Vendor Number",
       s.vendor_type_lookup_code  "Vendor Type",
       st.vendor_site_code        "Vendor Site Code",
       ou.name                    "Operating Unit",
       iepa.remit_advice_delivery_method  "Remittance Delivery Method",
       iepa.remit_advice_email            "Remittance Advice Email"
  FROM
       ap.ap_suppliers              s,
       ap.ap_supplier_sites_all     st,
       hr_operating_units           ou,
       iby.iby_external_payees_all  iepa
 WHERE
       1=1
   -- AND s.vendor_type_lookup_code = 'EMPLOYEE'
   AND TRUNC (SYSDATE) BETWEEN TRUNC (s.start_date_active) AND TRUNC (NVL (s.end_date_active, SYSDATE+1))
   AND s.enabled_flag = 'Y'
   AND iepa.supplier_site_id = st.vendor_site_id
   AND iepa.payee_party_id = s.party_id
   AND st.org_id = ou.organization_id
   AND st.vendor_id = s.vendor_id
 ORDER BY s.vendor_name, st.vendor_site_code;