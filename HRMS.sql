/*Find Approver status by user*/
SELECT f.USER_NAME     "FND USER NAME",
       wfr.DISPLAY_NAME,
       f.END_DATE,
       r.EXPIRATION_DATE,
       wfr.STATUS,
       wfr.EXPIRATION_DATE,
       wfr.ORIG_SYSTEM,
       wfr.PARENT_ORIG_SYSTEM
  FROM fnd_user f, wf_roles wfr, wf_local_user_roles r
 WHERE     f.USER_NAME = wfr.NAME
       AND wfr.NAME = r.ROLE_NAME
       AND r.user_name = '&username';

       

/* Update cost center by FIO*/
UPDATE APPS.PAY_COST_ALLOCATIONS_F
   SET COST_ALLOCATION_KEYFLEX_ID =
           (SELECT COST_ALLOCATION_KEYFLEX_ID
              FROM APPS.PAY_COST_ALLOCATION_KEYFLEX
             WHERE CONCATENATED_SEGMENTS = 'DSN0201')
 WHERE     ASSIGNMENT_ID = (SELECT ASSIGNMENT_ID
               FROM APPS.per_all_people_f       ppf,
                    APPS.per_all_assignments_f  pf,
                    APPS.gl_code_combinations   glcc
              WHERE     ppf.person_id = pf.person_id
                    AND pf.default_code_comb_id = glcc.code_combination_id
                    AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                                            AND ppf.effective_end_date
                    AND TRUNC (SYSDATE) BETWEEN pf.effective_start_date
                                            AND pf.effective_end_date
                    AND ppf.FULL_NAME LIKE '%Аблам%Юлия Сергеевна%')
       AND EFFECTIVE_END_DATE = TO_DATE ('31.12.4712', 'dd.mm.yyyy')

 SELECT COST_ALLOCATION_KEYFLEX_ID,CONCATENATED_SEGMENTS
              FROM APPS.PAY_COST_ALLOCATION_KEYFLEX
             WHERE CONCATENATED_SEGMENTS in('DSM130200',
'DSM130206',
'DSM130204')

/* FInd all Costin and Default Expense Account in HRMS card*/

  SELECT ppf.last_name,
         ppf.first_name,
         (SELECT asg.segment1
            FROM APPS.fnd_user u,
                 (SELECT cak.segment1, p.person_id
                    FROM (SELECT ff.assignment_id, ff.person_id
                            FROM (SELECT assignment_id,
                                         organization_id,
                                         person_id,
                                         effective_end_date,
                                         MAX (effective_end_date)
                                             OVER (PARTITION BY assignment_id)
                                             max_date
                                    FROM APPS.per_all_assignments_f f) ff
                           WHERE ff.max_date = ff.effective_end_date) asg,
                         (SELECT pp.person_id
                            FROM (SELECT person_id,
                                         effective_end_date,
                                         MAX (EFFECTIVE_END_DATE)
                                             OVER (PARTITION BY PERSON_ID)
                                             max_date
                                    FROM APPS.PER_ALL_PEOPLE_F) pp
                           WHERE pp.EFFECTIVE_END_DATE = pp.max_date) p,
                         APPS.PAY_COST_ALLOCATION_KEYFLEX cak,
                         APPS.PAY_COST_ALLOCATIONS_F     caf
                   WHERE     1 = 1
                         AND asg.person_id = p.person_id
                         AND caf.EFFECTIVE_END_DATE =
                             TO_DATE ('31.12.4712', 'DD.MM.YYYY')
                         AND caf.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
                         AND caf.COST_ALLOCATION_KEYFLEX_ID =
                             cak.COST_ALLOCATION_KEYFLEX_ID) asg
           WHERE                                              --user_id = 1248
                 asg.PERSON_ID = ppf.person_id --AND asg.person_id = u.EMPLOYEE_ID
                                               AND ROWNUM = 1)
             AS "Costing",
         glcc.segment6
             AS "DefExpAccount"
    FROM APPS.per_all_people_f     ppf,
         APPS.per_all_assignments_f pf,
         APPS.gl_code_combinations glcc
   WHERE     ppf.person_id = pf.person_id
         AND pf.default_code_comb_id = glcc.code_combination_id
         AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                                 AND ppf.effective_end_date
         AND TRUNC (SYSDATE) BETWEEN pf.effective_start_date
                                 AND pf.effective_end_date
         --AND LENGTH (glcc.segment6) <> 9
         AND ((SELECT asg.segment1
                 FROM APPS.fnd_user u,
                      (SELECT cak.segment1, p.person_id
                         FROM (SELECT ff.assignment_id, ff.person_id
                                 FROM (SELECT assignment_id,
                                              organization_id,
                                              person_id,
                                              effective_end_date,
                                              MAX (effective_end_date)
                                                  OVER (
                                                      PARTITION BY assignment_id)
                                                  max_date
                                         FROM APPS.per_all_assignments_f f) ff
                                WHERE ff.max_date = ff.effective_end_date) asg,
                              (SELECT pp.person_id
                                 FROM (SELECT person_id,
                                              effective_end_date,
                                              MAX (EFFECTIVE_END_DATE)
                                                  OVER (PARTITION BY PERSON_ID)
                                                  max_date
                                         FROM APPS.PER_ALL_PEOPLE_F) pp
                                WHERE pp.EFFECTIVE_END_DATE = pp.max_date) p,
                              APPS.PAY_COST_ALLOCATION_KEYFLEX cak,
                              APPS.PAY_COST_ALLOCATIONS_F     caf
                        WHERE     1 = 1
                              AND asg.person_id = p.person_id
                              AND caf.EFFECTIVE_END_DATE =
                                  TO_DATE ('31.12.4712', 'DD.MM.YYYY')
                              AND caf.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
                              AND caf.COST_ALLOCATION_KEYFLEX_ID =
                                  cak.COST_ALLOCATION_KEYFLEX_ID) asg
                WHERE                                         --user_id = 1248
                      asg.PERSON_ID = ppf.person_id --AND asg.person_id = u.EMPLOYEE_ID
                                                    AND ROWNUM = 1) <>
              glcc.segment6)
ORDER BY ppf.last_name

/* Find in HRMS (Purchase Order Information >> Default Expense Account) not valid 9 chr */
SELECT ppf.last_name,
       ppf.first_name,
       pf.default_code_comb_id,
       glcc.segment1,
       glcc.segment2,
       glcc.segment3,
       glcc.segment4,
       glcc.segment5,
       glcc.segment6
  FROM APPS.per_all_people_f       ppf,
       APPS.per_all_assignments_f  pf,
       APPS.gl_code_combinations   glcc
 WHERE     ppf.person_id = pf.person_id
       AND pf.default_code_comb_id = glcc.code_combination_id
       AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                               AND ppf.effective_end_date
       AND TRUNC (SYSDATE) BETWEEN pf.effective_start_date
                               AND pf.effective_end_date
       AND LENGTH (glcc.segment6) <> 9
       ORDER BY ppf.last_name
	   
/* Find Supervisor in card HRMS*/
  SELECT DISTINCT ppf.full_name emp_name, ppf1.full_name supervisor_name
    FROM per_all_people_f     ppf,
         per_all_assignments_f paaf,
         per_all_people_f     ppf1
   WHERE     1 = 1
         AND ppf.person_id = paaf.person_id
         AND ppf.employee_number IS NOT NULL
         --AND ppf.person_id=968956
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND paaf.supervisor_id = ppf1.person_id
         AND ppf.EFFECTIVE_END_DATE = TO_DATE ('31.12.4712', 'dd.mm.yyyy')
ORDER BY 1

/* Employee and Supervisor Details*/
SELECT fu.user_name,
--       (SELECT DISTINCT pff.NAME
--          FROM hr_all_positions_f pff
--         WHERE     PF.POSITION_ID = pf.POSITION_ID
--               AND pff.EFFECTIVE_END_DATE =
--                   TO_DATE ('31.12.4712', 'dd.mm.yyyy')
--               AND pff.JOB_ID = pf.JOB_ID),
PF.POSITION_ID,
       per.full_name,
       per.employee_number,
       gccf.SEGMENT6
           user_costing,
       gccf.concatenated_segments
           user_def_expense_acc,
       per1.full_name
           supervisor_name,
       per1.employee_number
           supervisor_number,
       gcc.SEGMENT6
           supervisor_costing,
       gcc.concatenated_segments
           supvisor_def_expense_acc
  FROM APPS.fnd_user                  fu,
       APPS.per_all_people_f          per,
       APPS.per_all_assignments_f     pf,
       APPS.gl_code_combinations_kfv  gccf,
       APPS.per_all_people_f          per1,
       APPS.per_all_assignments_f     pf1,
       APPS.gl_code_combinations_kfv  gcc
 WHERE     fu.employee_id = per.person_id
       AND SYSDATE BETWEEN per.effective_start_date
                       AND per.effective_end_date
       AND SYSDATE BETWEEN pf.effective_start_date AND pf.effective_end_date
       AND pf.person_id = per.person_id
       AND pf.supervisor_id = per1.person_id
       AND per1.person_id = pf1.person_id
       AND SYSDATE BETWEEN per1.effective_start_date
                       AND per1.effective_end_date
       AND SYSDATE BETWEEN pf1.effective_start_date
                       AND pf1.effective_end_date
       AND pf1.default_code_comb_id = gcc.code_combination_id
       AND pf.default_code_comb_id = gccf.code_combination_id(+)
       AND per.EFFECTIVE_END_DATE = TO_DATE ('31.12.4712', 'dd.mm.yyyy')

/* Unloading by HRMS с Costing Code */
  SELECT p.employee_number
             AS "Oracle Emp Number",
         p.attribute1
             AS "1C Number",
         p.full_name,
         UPPER (SUBSTR (jbs.attribute1, 1, 1)) || SUBSTR (jbs.attribute1, 2)
             "Position",
         p.person_id,
         --#################################################
         (SELECT                                                
                 asg.segment1
            FROM APPS.fnd_user u,
                 (SELECT cak.segment1, p.person_id
                    FROM (SELECT ff.assignment_id, ff.person_id
                            FROM (SELECT assignment_id,
                                         organization_id,
                                         person_id,
                                         effective_end_date,
                                         MAX (effective_end_date)
                                             OVER (PARTITION BY assignment_id)
                                             max_date
                                    FROM APPS.per_all_assignments_f f) ff
                           WHERE ff.max_date = ff.effective_end_date) asg,
                         (SELECT pp.person_id
                            FROM (SELECT person_id,
                                         effective_end_date,
                                         MAX (EFFECTIVE_END_DATE)
                                             OVER (PARTITION BY PERSON_ID)
                                             max_date
                                    FROM APPS.PER_ALL_PEOPLE_F) pp
                           WHERE pp.EFFECTIVE_END_DATE = pp.max_date) p,
                         APPS.PAY_COST_ALLOCATION_KEYFLEX cak,
                         APPS.PAY_COST_ALLOCATIONS_F     caf
                   WHERE     1 = 1
                         AND asg.person_id = p.person_id
                         AND caf.EFFECTIVE_END_DATE =
                             TO_DATE ('31.12.4712', 'DD.MM.YYYY')
                         AND caf.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
                         AND caf.COST_ALLOCATION_KEYFLEX_ID =
                             cak.COST_ALLOCATION_KEYFLEX_ID) asg
           WHERE                                              --user_id = 1248
                 asg.PERSON_ID = p.person_id --AND asg.person_id = u.EMPLOYEE_ID
                                             AND ROWNUM = 1)
             AS "Department_code",
         --#################################################
         ho.name
             AS "Department name",
         asg.EFFECTIVE_START_DATE,
         asg.EFFECTIVE_END_DATE
    FROM APPS.HR_ALL_POSITIONS_F          pos,
         per_jobs                         jbs,
         (SELECT ff.assignment_id,
                 ff.organization_id,
                 ff.position_id,
                 ff.job_id,
                 ff.person_id,
                 ff.effective_start_date,
                 ff.effective_end_date
            FROM (SELECT assignment_id,
                         organization_id,
                         position_id,
                         job_id,
                         person_id,
                         effective_start_date,
                         effective_end_date,
                         MAX (effective_end_date) OVER (PARTITION BY person_id)
                             max_date
                    FROM APPS.per_all_assignments_f f) ff
           WHERE ff.max_date = ff.effective_end_date) asg,
         (SELECT pp.person_id,
                 pp.person_type_id,
                 pp.employee_number,
                 pp.attribute1,
                 pp.first_name,
                 pp.full_name,
                 pp.last_name,
                 pp.middle_names
            FROM (SELECT person_id,
                         person_type_id,
                         employee_number,
                         first_name,
                         full_name,
                         last_name,
                         attribute1,
                         middle_names,
                         effective_end_date,
                         MAX (EFFECTIVE_END_DATE) OVER (PARTITION BY PERSON_ID)
                             max_date
                    FROM APPS.PER_ALL_PEOPLE_F) pp
           WHERE pp.EFFECTIVE_END_DATE = pp.max_date) p,
         APPS.HR_ALL_ORGANIZATION_UNITS_VL ho
   WHERE     asg.position_id = pos.position_id(+)
         AND asg.person_id = p.person_id
         AND asg.organization_id = pos.organization_id(+)
         AND asg.organization_id = ho.organization_id
         AND jbs.job_id(+) = pos.job_id
         AND asg.EFFECTIVE_END_DATE > SYSDATE
--         AND p.full_name like '%Full name%'
ORDER BY FULL_NAME
 


SELECT
 pad.primary_flag,
       papf.employee_number "Employee Number",
       papf.title "Title",
       papf.first_name "First Name",
       papf.last_name "Last Name",
       TO_CHAR(papf.date_of_birth, 'DD-MON-RRRR') "Birth Date",
       TRUNC(MONTHS_BETWEEN(SYSDATE, papf.date_of_birth) / 12) "Age",
       hrlsex.meaning "Gender",
       ppt.user_person_type "Person Type",
       papf.national_identifier "National Identifier",
       hrlnat.meaning "Nationality",
       hrlms.meaning "Marital Status",
       papf.email_address "E-mail",
       TO_CHAR(papf.effective_start_date, 'DD-MON-RRRR') "Start Date",
       TO_CHAR(papf.effective_end_date, 'DD-MON-RRRR') "End Date",
       TO_CHAR(papf.original_date_of_hire, 'DD-MON-RRRR') "Hire Date",
       pjobs.name "Job",
       ppos.name "Position",
       pgrade.name "Grade",
       haou.name "Organization",
       pbus.name "Business Group",
       hrlat.meaning "Address Type",
       pad.address_line1 || CHR(10) || pad.address_line2 || CHR(10) ||
       pad.address_line3 "Address",
       pad.postal_code "Postal Code",
       ftt.territory_short_name "Country",
       ftt.description "Full Country Name",
       hrleg.meaning "Ethnic Origin"
FROM per_all_people_f papf,
     per_all_assignments_f paaf,
     per_person_types_tl ppt,
     hr_lookups hrlsex,
     hr_lookups hrlnat,
     hr_lookups hrlms,
     hr_lookups hrleg,
     hr_lookups hrlat,
     per_jobs pjobs,
     per_all_positions ppos,
     per_addresses pad,
     per_grades_tl pgrade,
     per_business_groups pbus,
     hr_all_organization_units haou,
     fnd_territories_tl ftt
WHERE 1 = 1
  AND hrlat.lookup_code(+) = pad.address_type
  AND hrlat.lookup_type(+) = 'ADDRESS_TYPE'
  AND hrlsex.lookup_code(+) = papf.sex
  AND hrlsex.lookup_type(+) = 'SEX'
  AND hrlnat.lookup_code(+) = papf.nationality
  AND hrlnat.lookup_type(+) = 'NATIONALITY'
  AND hrlms.lookup_code(+) = papf.marital_status
  AND hrlms.lookup_type(+) = 'MAR_STATUS'
  AND hrleg.lookup_code(+) = papf.per_information1
  AND hrleg.lookup_type(+) = 'US_ETHNIC_GROUP'
  AND ftt.territory_code(+) = pad.country
  AND pad.business_group_id(+) = papf.business_group_id
  AND pad.date_to IS NULL
  AND pad.person_id(+) = papf.person_id
  AND pgrade.grade_id(+) = paaf.grade_id
  AND haou.organization_id(+) = paaf.organization_id
  AND haou.business_group_id(+) = paaf.business_group_id
  AND pbus.business_group_id(+) = paaf.business_group_id
  AND ppos.position_id(+) = paaf.position_id
  AND pjobs.job_id(+) = paaf.job_id
  AND ppt.person_type_id(+) = papf.person_type_id
  AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND
      paaf.effective_end_date
  AND paaf.person_id = papf.person_id
  AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND
      papf.effective_end_date;
	  


/* Employee ALl Details*/
SELECT DISTINCT fu.USER_ID,
                per.full_name,
                per.employee_number,
                PF.POSITION_ID,
                gccf.SEGMENT6     user_costing,
                gccf.concatenated_segments,
                haou.name         "Organization",
                pjobs.name        "Job",
                pgrade.name       "Grade",
                ppos.name         "Position"
  --  ,gccf.user_def_expense_acc
  FROM APPS.fnd_user                   fu,
       APPS.per_all_people_f           per,
       APPS.per_all_assignments_f      pf,
       APPS.gl_code_combinations_kfv   gccf,
       APPS.per_jobs                   pjobs,
       APPS.per_all_positions          ppos,
       APPS.hr_all_organization_units  haou,
       APPS.per_grades_tl              pgrade
 WHERE     fu.employee_id = per.person_id
       AND pjobs.job_id(+) = pf.job_id
       AND ppos.position_id(+) = pf.position_id
       AND haou.organization_id(+) = pf.organization_id
       AND haou.business_group_id(+) = pf.business_group_id
       AND pgrade.grade_id(+) = pf.grade_id
       AND SYSDATE BETWEEN per.effective_start_date
                       AND per.effective_end_date
       AND SYSDATE BETWEEN pf.effective_start_date AND pf.effective_end_date
       AND pf.person_id = per.person_id
       AND fu.USER_ID IN ('7758',
                          '1786',
                          '7999',
                          '8483',
                          '7357',
                          '6676')
       AND pf.default_code_comb_id = gccf.code_combination_id(+)
       AND per.EFFECTIVE_END_DATE = TO_DATE ('31.12.4712', 'dd.mm.yyyy')
	   
/*HR Special info Bank Accaunt ,IBAN */
  SELECT asp.segment1
             vendor_num,
         asp.vendor_name,
         asp.START_DATE_ACTIVE
             Vendor_START_DATE,
         asp.END_DATE_ACTIVE
             Vendor_END_DATE,
         (SELECT NAME
            FROM apps.hr_operating_units hou
           WHERE 1 = 1 AND hou.organization_id = asa.org_id)
             ou_name,
         asa.vendor_site_code,
         cbbv.bank_name,
         cbbv.bank_number,
         cbbv.bank_branch_name,
         cbbv.branch_number,
         cbbv.bank_branch_type,
         cbbv.eft_swift_code,   
         ieb.bank_account_num,
         ieb.iban,
         ieb.START_DATE
             BANK_START_DATE,
         ieb.END_DATE
             BANK_END_DATE,
         ieb.currency_code,
         --       asp.EMPLOYEE_ID,
         --         ppt.user_person_type employee_type,
         papf.EMPLOYEE_NUMBER,
         papf.full_name,
         TO_CHAR (ppa.date_from, 'dd-mon-yyyy')
             HR_ACC_start_date,
         --         TO_CHAR (ppa.date_to, 'dd-mon-yyyy') end_date,
         pac.segment3
             "HR Banc Accaunt",
         pac.segment5
             "HR IBAN",
         pac.segment4
             "Currency Code"
    FROM apps.iby_pmt_instr_uses_all instrument,
         apps.iby_account_owners     owners,
         apps.iby_external_payees_all payees,
         apps.iby_ext_bank_accounts  ieb,
         apps.ap_supplier_sites_all  asa,
         apps.ap_suppliers           asp,
         apps.ce_bank_branches_v     cbbv,
         apps.per_all_people_f       papf,
         apps.per_person_analyses    ppa,
         apps.fnd_id_flex_structures fifs,
         apps.per_special_info_types psit,
         apps.per_analysis_criteria  pac,
         apps.per_person_types_tl    ppt
   WHERE     1 = 1
         AND owners.ext_bank_account_id = ieb.ext_bank_account_id
         AND owners.ext_bank_account_id = instrument.instrument_id
         AND payees.ext_payee_id = instrument.ext_pmt_party_id
         AND payees.payee_party_id = owners.account_owner_party_id
         AND payees.supplier_site_id = asa.vendor_site_id
         AND asa.vendor_id = asp.vendor_id
         AND cbbv.branch_party_id(+) = ieb.branch_id
         AND asp.VENDOR_TYPE_LOOKUP_CODE = 'EMPLOYEE'
         --       AND VENDOR_NAME LIKE '%Тымко%'
         AND ppt.person_type_id = papf.person_type_id
         AND pac.id_flex_num = fifs.id_flex_num
         AND ppt.person_type_id(+) = papf.person_type_id
         AND psit.id_flex_num = pac.id_flex_num
         AND ppa.person_id(+) = papf.person_id
         AND pac.analysis_criteria_id(+) = ppa.analysis_criteria_id
         AND ppt.user_person_type <> 'ex-employee'
         AND psit.business_group_id + 0 = '81'
         AND psit.SPECIAL_INFORMATION_TYPE_ID = '1064'     -- Тип Banc Accaunt
         --         AND papf.full_name LIKE '%Колосун%'
         AND ppt.user_person_type = 'Работник'
         AND papf.EFFECTIVE_END_DATE >= SYSDATE
         --         AND papf.CURRENT_EMP_OR_APL_FLAG = 'Y'
         AND papf.person_id = asp.EMPLOYEE_ID(+)
--         AND ieb.bank_account_num <> pac.segment3
--         AND ppa.date_to IS NULL
--         AND ieb.END_DATE IS NULL
ORDER BY asp.vendor_name, papf.full_name

/* Formatted on 26.04.2022 11:08:45 (QP5 v5.326) Service Desk Mihail.Vasiljev */
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
                 AND frt.RESPONSIBILITY_ID = RT.RESPONSIBILITY_ID--AND RT.SOURCE_LANG = 'RU'
                                                                 )
             "RU RESPONSIBILITY",
         TO_CHAR (furg.START_DATE, 'DD-MM-YYYY')
             resp_attched_date
    --    , TO_CHAR(furg.END_DATE,'DD-MM-YYYY') resp_remove_date
    FROM FND_USER                   fuser,
         PER_PEOPLE_F               per,
         fnd_user_resp_groups_direct furg,
         FND_RESPONSIBILITY_TL      frt
   WHERE     fuser.EMPLOYEE_ID = per.PERSON_ID
         AND fuser.USER_ID = furg.USER_ID
         AND (TO_CHAR (fuser.END_DATE) IS NULL OR fuser.END_DATE > SYSDATE)
         AND frt.RESPONSIBILITY_ID = furg.RESPONSIBILITY_ID
         AND frt.LANGUAGE = 'US'
         AND furg.END_DATE IS NULL
--    and fuser.user_name like 'SYS%'
ORDER BY fuser.USER_NAME;


/* HRMS Oracle Purchasing Position Hierarchy Setup Query*/
SELECT 0                          levels,
       pp.name                    position,
       pse.parent_position_id     position_id,
       pp.name                    PATH
  FROM per_pos_structure_elements_v pse, per_positions pp
 WHERE     pse.business_group_id =
           (SELECT BUSINESS_GROUP_ID
             FROM per_pos_structure_versions_v
            WHERE     position_structure_id =
                      (SELECT position_structure_id
                         FROM per_position_structures_v)
                  AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
       AND pse.pos_structure_version_id =
           (SELECT POS_STRUCTURE_VERSION_ID
             FROM per_pos_structure_versions_v
            WHERE     position_structure_id =
                      (SELECT position_structure_id
                         FROM per_position_structures_v)
                  AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
       AND pse.parent_position_id =
           (SELECT DISTINCT parent_position_id
             FROM per_pos_structure_elements_v pse
            WHERE     pse.business_group_id =
                      (SELECT BUSINESS_GROUP_ID
                        FROM per_pos_structure_versions_v
                       WHERE     position_structure_id =
                                 (SELECT position_structure_id
                                    FROM per_position_structures_v)
                             AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
                  AND pse.pos_structure_version_id =
                      (SELECT POS_STRUCTURE_VERSION_ID
                        FROM per_pos_structure_versions_v
                       WHERE     position_structure_id =
                                 (SELECT position_structure_id
                                    FROM per_position_structures_v)
                             AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
                  AND NOT EXISTS
                          (SELECT subordinate_position_id
                             FROM per_pos_structure_elements_v pse1
                            WHERE     pse1.business_group_id =
                                      (SELECT BUSINESS_GROUP_ID
                                        FROM per_pos_structure_versions_v
                                       WHERE     position_structure_id =
                                                 (SELECT position_structure_id
                                                   FROM per_position_structures_v)
                                             AND NVL (DATE_TO, SYSDATE + 1) >=
                                                 SYSDATE)
                                  AND pse1.pos_structure_version_id =
                                      (SELECT POS_STRUCTURE_VERSION_ID
                                        FROM per_pos_structure_versions_v
                                       WHERE     position_structure_id =
                                                 (SELECT position_structure_id
                                                   FROM per_position_structures_v)
                                             AND NVL (DATE_TO, SYSDATE + 1) >=
                                                 SYSDATE)
                                  AND pse1.subordinate_position_id =
                                      pse.parent_position_id))
       AND pse.parent_position_id = pp.position_id
UNION
    SELECT LEVEL,
           has.name                                      position,
           has.position_id                               position_id,
              (SELECT name
                 FROM per_positions
                WHERE position_id = :p_parent_position_id)
           || SYS_CONNECT_BY_PATH (has.name, ' --> ')    PATH
      FROM (SELECT name, position_id
              FROM apps.hr_all_positions_f_tl
             WHERE language = USERENV ('LANG')) has,
           per_pos_structure_elements pse
     WHERE     pse.business_group_id =
               (SELECT BUSINESS_GROUP_ID
                 FROM per_pos_structure_versions_v
                WHERE     position_structure_id =
                          (SELECT position_structure_id
                             FROM per_position_structures_v)
                      AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
           AND has.position_id = pse.subordinate_position_id
           AND pse.pos_structure_version_id =
               (SELECT POS_STRUCTURE_VERSION_ID
                 FROM per_pos_structure_versions_v
                WHERE     position_structure_id =
                          (SELECT position_structure_id
                             FROM per_position_structures_v)
                      AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
START WITH pse.parent_position_id =
           (SELECT DISTINCT parent_position_id
             FROM per_pos_structure_elements_v pse
            WHERE     pse.business_group_id =
                      (SELECT BUSINESS_GROUP_ID
                        FROM per_pos_structure_versions_v
                       WHERE     position_structure_id =
                                 (SELECT position_structure_id
                                    FROM per_position_structures_v)
                             AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE)
                  AND pse.pos_structure_version_id =
                      (SELECT POS_STRUCTURE_VERSION_ID
                        FROM per_pos_structure_versions_v
                       WHERE     position_structure_id =
                                 (SELECT position_structure_id
                                    FROM per_position_structures_v)
                             AND NVL (DATE_TO, SYSDATE + 1) >= SYSDATE) --  From Query 2
                  AND NOT EXISTS
                          (SELECT subordinate_position_id
                             FROM per_pos_structure_elements_v pse1
                            WHERE     pse1.business_group_id =
                                      (SELECT BUSINESS_GROUP_ID
                                        FROM per_pos_structure_versions_v
                                       WHERE     position_structure_id =
                                                 (SELECT position_structure_id
                                                   FROM per_position_structures_v)
                                             AND NVL (DATE_TO, SYSDATE + 1) >=
                                                 SYSDATE)
                                  AND pse1.pos_structure_version_id =
                                      (SELECT POS_STRUCTURE_VERSION_ID
                                        FROM per_pos_structure_versions_v
                                       WHERE     position_structure_id =
                                                 (SELECT position_structure_id
                                                   FROM per_position_structures_v)
                                             AND NVL (DATE_TO, SYSDATE + 1) >=
                                                 SYSDATE)
                                  AND pse1.subordinate_position_id =
                                      pse.parent_position_id))
CONNECT BY     PRIOR pse.subordinate_position_id = pse.parent_position_id
           AND PRIOR pse.pos_structure_version_id =
               pse.pos_structure_version_id
           AND PRIOR pse.business_group_id = pse.business_group_id
ORDER BY 1