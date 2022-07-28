/* Who update Vendor*/
  SELECT fu.user_name,
         s.last_Update_date,
         s.vendor_name,
         s.vendor_id,
         s.*
    FROM apps.ap_suppliers s, apps.fnd_user fu
   WHERE s.last_updated_by = fu.user_id
   AND s.VAT_REGISTRATION_NUM = '200407663'
--ORDER BY last_update_date DESC