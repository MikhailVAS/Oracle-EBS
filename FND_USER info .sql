/* Find FIO in HRMS by USER_ID */
SELECT FULL_NAME
  FROM per_all_people_f PAPF
 WHERE PERSON_ID = (SELECT EMPLOYEE_ID
                      FROM fnd_user
                     WHERE user_id = 7256)



SELECT DISTINCT pf.person_id, pf.full_name
  FROM --applsys.fnd_user fu,
       apps.per_people_f pf
 WHERE --fu.employee_id =
       pf.person_id IN (4046, 12203)
--AND SYSDATE BETWEEN NVL (pf.effective_start_date, SYSDATE)
--AND NVL (pf.effective_end_date, SYSDATE)
--AND fu.user_id = fnd_profile.VALUE ('USER_ID');

SELECT u.user_id           as user_id
     , u.user_name         as user_name
     , pap.full_name       as emp_name
     , pap.employee_number as emp_number
     , pj.name             as job_name
     --
FROM apps.fnd_user          u
   , apps.per_all_people_f  pap
   , apps.per_assignments_f paf
   , apps.per_jobs          pj
WHERE 1=1
      --and u.user_id = fnd_global.user_id
      and u.employee_id = pap.person_id(+)
      and sysdate between pap.effective_start_date(+) and pap.effective_end_date(+)
      -- per_assignments_f
      and paf.person_id (+) = pap.person_id
      and sysdate between paf.effective_start_date(+) and paf.effective_end_date(+)
      and paf.primary_flag(+) = 'Y'
      -- per_jobs
      and pj.job_id(+) = paf.job_id;

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

 /* for SOX Matrix Turlo  */
  SELECT DISTINCT
         fuser.USER_NAME
             USER_NAME,
         fuser.user_id,
         fuser.creation_date,
         fuser.last_update_date,
         fuser.LAST_LOGON_DATE,
         fuser.START_DATE,
         --         fuser.END_DATE,
         per.FULL_NAME
             FULL_NAME,
         per.EMPLOYEE_NUMBER
             EMPLOYEE_NUMBER,
         frt.RESPONSIBILITY_NAME
             RESPONSIBILITY,
         (SELECT RT.RESPONSIBILITY_NAME
            FROM FND_RESPONSIBILITY_TL RT
           WHERE     RT.LANGUAGE = 'RU'
                 AND frt.RESPONSIBILITY_ID = RT.RESPONSIBILITY_ID --AND RT.SOURCE_LANG = 'RU'
                                                                 )
             "RU RESPONSIBILITY",
         fr.responsibility_key,
         fa.application_short_name,
         TO_CHAR (furg.START_DATE, 'DD-MM-YYYY')
             resp_attched_date
    --    , TO_CHAR(furg.END_DATE,'DD-MM-YYYY') resp_remove_date
    FROM FND_USER                   fuser,
         PER_PEOPLE_F               per,
         fnd_user_resp_groups_direct furg,
         FND_RESPONSIBILITY_TL      frt,
         applsys.fnd_responsibility fr,
         applsys.fnd_application_tl fat,
         applsys.fnd_application    fa
   WHERE     fuser.EMPLOYEE_ID = per.PERSON_ID
         AND fuser.USER_ID = furg.USER_ID
         AND (TO_CHAR (fuser.END_DATE) IS NULL OR fuser.END_DATE > SYSDATE)
         AND frt.RESPONSIBILITY_ID = furg.RESPONSIBILITY_ID
         AND fr.responsibility_id = frt.responsibility_id
         AND fa.application_id = fat.application_id
         AND fr.application_id = fat.application_id
         AND frt.LANGUAGE = 'US'
         AND furg.END_DATE IS NULL
--    and fuser.user_name like 'SYS%'
ORDER BY fuser.USER_NAME

