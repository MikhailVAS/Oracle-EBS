SELECT user_name, user_id, full_name, country, job, doc_name,
       appr_limit
  FROM (SELECT DISTINCT fu.user_name, ppf.full_name,
                        ppf.per_information_category country, pj.NAME job,
                        fu.user_id, appr.doc_name, appr.appr_limit
                   FROM APPS.fnd_user fu,
                        APPS.per_all_people_f ppf,
                        APPS.per_all_assignments_f paf,
                        (SELECT   ppca.job_id,
                                  pcf.control_function_name doc_name,
                                  MAX (amount_limit) appr_limit
                             FROM APPS.po_position_controls_all ppca,
                                  APPS.po_control_functions pcf,
                                  APPS.po_control_rules pcr,
                                  APPS.po_control_groups_all pcga
                            WHERE ppca.control_group_id = pcr.control_group_id
                              AND pcf.control_function_id =
                                                       pcf.control_function_id
                              AND pcga.control_group_id = pcr.control_group_id
                              AND pcr.object_code = 'DOCUMENT_TOTAL'
                         GROUP BY ppca.job_id, pcf.control_function_name) appr,
                        per_jobs pj
                  WHERE EXISTS (
                           SELECT '1'
                             FROM APPS.fnd_compiled_menu_functions cmf,
                                  APPS.fnd_form_functions ff,
                                  APPS.fnd_form_functions_tl ffl,
                                  APPS.fnd_form_vl ffv,
                                  APPS.fnd_responsibility_vl rtl,
                                  APPS.fnd_user_resp_groups furg
                            WHERE cmf.function_id = ff.function_id
                              AND rtl.menu_id = cmf.menu_id
                              AND cmf.grant_flag = 'Y'
                              AND ff.function_id = ffl.function_id
                              AND ffv.form_id = ff.form_id
                              AND ffv.form_name IN ('POXPOEPO', 'POXRQERQ')
                              AND furg.responsibility_id =
                                                         rtl.responsibility_id
                              AND furg.end_date IS NULL
                              AND rtl.end_date IS NULL
                              AND furg.user_id = fu.user_id)
                    AND fu.end_date IS NULL
                    AND fu.employee_id = ppf.person_id
                    AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                                            AND ppf.effective_end_date
                    AND ppf.person_id = paf.person_id
                    AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
                    AND ppf.employee_number IS NOT NULL
                    AND paf.assignment_type IN ('E', 'C')
                    AND paf.job_id = appr.job_id
                    AND pj.job_id = paf.job_id
               ORDER BY user_name)
               WHERE user_name like UPPER('%'||:D||'%')