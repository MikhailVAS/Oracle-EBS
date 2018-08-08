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