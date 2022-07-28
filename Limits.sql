/* All Employee Signing Limits(Payables Manager BeST) */
  SELECT pap.full_name,
         awsla.cost_center,
         awsla.org_id,
         hou.name organization_name,
         awsla.signing_limit
    FROM APPS.ap_web_signing_limits_all awsla,
         APPS.per_all_people_f         pap,
         APPS.hr_organization_units    hou
   WHERE     awsla.employee_id = pap.person_id
         AND awsla.org_id = hou.organization_id
         AND pap.effective_start_date = (SELECT MAX (pap1.effective_start_date)
                                           FROM apps.per_all_people_f pap1
                                          WHERE pap1.person_id = pap.person_id)
         AND awsla.document_type = 'APEXP'
ORDER BY hou.name,
         pap.full_name,
         awsla.cost_center,
         awsla.signing_limit;
		 
/*
		 Additional Info:
1. The columns START_DATE, EFFECTIVE_START_DATE and EFFECTIVE_END_DATE of per_all_people_f table are all maintained by DateTrack. 
The START_DATE is the date when the first record for this person was created. 
The earliest EFFECTIVE_START_DATE for a person is equal to the START_DATE.

2. Table ap_web_signing_limits_all corresponds to the Signing Limits window
Payables Manager: Employees > Signing Limits */

/* Insert Limit*/
INSERT INTO ap_web_signing_limits_all (document_type,
                                       employee_id,
                                       cost_center,
                                       signing_limit,
                                       last_update_date,
                                       last_updated_by,
                                       last_update_login,
                                       creation_date,
                                       created_by,
                                       org_id)
     VALUES ('APEXP',
             ln_person_id,
             lc_cost_center,
             ln_signing_limit,
             SYSDATE,
             fnd_profile.VALUE ('USER_ID'),
             fnd_profile.VALUE ('LOGIN_ID'),
             SYSDATE,
             fnd_profile.VALUE ('USER_ID'),
             ln_org_id);