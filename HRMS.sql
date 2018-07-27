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
 
