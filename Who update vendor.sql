/* Who update Vendor*/
  SELECT fu.user_name,
         s.last_Update_date,
         s.vendor_name,
         s.vendor_id
    FROM apps.ap_suppliers s, apps.fnd_user fu
   WHERE s.last_updated_by = fu.user_id
ORDER BY last_update_date DESC