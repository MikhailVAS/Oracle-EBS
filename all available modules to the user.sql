SELECT DISTINCT  
 fu.user_id,
 fu.user_name,
 fu.email_address ,
 fr.RESPONSIBILITY_NAME,
 fu.START_DATE,
 fu.END_DATE
 FROM APPS.fnd_user_resp_groups_direct furg,
         APPS.fnd_user fu,
         APPS.fnd_responsibility_tl fr
   WHERE         
          fr.responsibility_id = furg.responsibility_id
         AND furg.user_id = fu.user_id
         AND furg.end_date IS NULL
         AND fu.end_date IS NULL
         AND fr.language = USERENV ('LANG')
         AND fu.user_name like UPPER('%'||:D||'%')
ORDER BY fu.user_name;



