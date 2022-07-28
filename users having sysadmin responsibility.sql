SELECT fu.user_id, fu.user_name, fu.email_address
    FROM APPS.fnd_user_resp_groups_direct furg,
         APPS.fnd_user fu,
         APPS.fnd_responsibility_tl fr
   WHERE     UPPER (fr.responsibility_name) = UPPER ('&Enter_Resp_Name')
         AND fr.responsibility_id = furg.responsibility_id
         AND furg.user_id = fu.user_id
         AND furg.end_date IS NULL
         AND fu.end_date IS NULL
         AND fr.language = USERENV ('LANG')
ORDER BY fu.user_name;

SELECT fu.user_name                "User Name",
       frt.responsibility_name     "Responsibility Name",
       furg.start_date             "Start Date",
       furg.end_date               "End Date",      
       fr.responsibility_key       "Responsibility Key",
       fa.application_short_name   "Application Short Name"
  FROM fnd_user_resp_groups_direct        furg,
       applsys.fnd_user                   fu,
       applsys.fnd_responsibility_tl      frt,
       applsys.fnd_responsibility         fr,
       applsys.fnd_application_tl         fat,
       applsys.fnd_application            fa
 WHERE furg.user_id             =  fu.user_id
   AND furg.responsibility_id   =  frt.responsibility_id
   AND fr.responsibility_id     =  frt.responsibility_id
   AND fa.application_id        =  fat.application_id
   AND fr.application_id        =  fat.application_id
   AND frt.language             =  USERENV('LANG')
   AND UPPER(fu.user_name)      =  UPPER('AMOHSIN')  -- <change it>
   -- AND (furg.end_date IS NULL OR furg.end_date >= TRUNC(SYSDATE))
 ORDER BY frt.responsibility_name;