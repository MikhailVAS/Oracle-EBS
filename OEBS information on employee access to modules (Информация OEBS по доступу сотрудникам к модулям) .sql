/*Информация OEBS по доступу сотрудникам к модулям */
  SELECT fu.user_id,
         fur.name,
         fur.display_name,
         frv.responsibility_name,
         frv.description,
         fur.start_date,
         fur.status,
         fur.expiration_date AS user_name_end_date,
         furg.end_date     AS responsbility_end_date
    FROM apps.FND_USR_ROLES           fur,
         apps.fnd_user                fu,
         apps.FND_USER_RESP_GROUPS_ALL furg,
         apps.FND_RESPONSIBILITY_VL   frv
   WHERE     fur.name = fu.user_name
         AND fu.user_id = furg.user_id
         AND furg.responsibility_id = frv.responsibility_id
         AND fur.name LIKE UPPER ('%' || :D || '%')
ORDER BY fur.name

/*Персоны в HRMS*/
SELECT DISTINCT pf.person_id, pf.full_name
  FROM --applsys.fnd_user fu,
       apps.per_people_f pf
 WHERE --fu.employee_id =
       pf.person_id IN (4046, 12203)
--AND SYSDATE BETWEEN NVL (pf.effective_start_date, SYSDATE)
--AND NVL (pf.effective_end_date, SYSDATE)
--AND fu.user_id = fnd_profile.VALUE ('USER_ID');

/* Formatted on 25.06.2018 14:21:13 (QP5 v5.318) */
  SELECT DISTINCT fu.user_id,
                  fu.user_name,
                  PER.FULL_NAME,
                  fu.email_address,
                  fr.RESPONSIBILITY_NAME,
                  fr.DESCRIPTION,
                  fu.START_DATE,
                  fu.END_DATE
    FROM APPS.fnd_user_resp_groups_direct furg,
         APPS.fnd_user                   fu,
         APPS.PER_PEOPLE_F               PER,
         APPS.fnd_responsibility_tl      fr
   WHERE     fr.responsibility_id = furg.responsibility_id
         AND furg.user_id = fu.user_id
         AND fu.EMPLOYEE_ID = PER.PERSON_ID(+)
         AND furg.end_date IS NULL
         AND fu.end_date IS NULL
         AND fr.language = USERENV ('LANG')
 AND fu.user_name like UPPER('%'||:D||'%')
ORDER BY fu.user_name;
