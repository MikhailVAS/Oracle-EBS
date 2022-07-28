

/* View all requests for the current date 
	 Просмотр всех requests за текущую дату*/
SELECT fcr.request_id,
       DECODE (fcpt.user_concurrent_program_name,
               'Report Set', 'Report Set:' || fcr.description,
               fcpt.user_concurrent_program_name)
          CONC_PROG_NAME,
       argument_text        PARAMETERS,
       NVL2 (fcr.resubmit_interval,
             'PERIODICALLY',
             NVL2 (fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE'))
          PROG_SCHEDULE_TYPE,
       DECODE (
          NVL2 (fcr.resubmit_interval,
                'PERIODICALLY',
                NVL2 (fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
          'PERIODICALLY',    'EVERY '
                          || fcr.resubmit_interval
                          || ' '
                          || fcr.resubmit_interval_unit_code
                          || ' FROM '
                          || fcr.resubmit_interval_type_code
                          || ' OF PREV RUN',
          'ONCE',    'AT :'
                  || TO_CHAR (fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
          'EVERY: ' || fcrc.class_info)
          PROG_SCHEDULE,
       fu.user_name         USER_NAME,
       requested_start_date START_DATE
  FROM apps.fnd_concurrent_programs_tl fcpt,
       apps.fnd_concurrent_requests    fcr,
       apps.fnd_user                   fu,
       apps.fnd_conc_release_classes   fcrc
 WHERE     fcpt.application_id = fcr.program_application_id
       AND fcpt.concurrent_program_id = fcr.concurrent_program_id
       AND fcr.requested_by = fu.user_id
       AND fcr.phase_code = 'P'
       AND fcr.requested_start_date > SYSDATE
       AND fcpt.LANGUAGE = 'US'
       AND fcrc.release_class_id(+) = fcr.release_class_id
       AND fcrc.application_id(+) = fcr.release_class_app_id;
	   
/*  View all requests for the selected USER
      Просмотр всех requests по выбранному USER-у */
  SELECT user_concurrent_program_name,
         responsibility_name,
         request_date,
         argument_text,
         request_id,
         phase_code,
         status_code,
         logfile_name,
         outfile_name,
         output_file_type
    FROM apps.fnd_concurrent_requests  fcr,
         apps.fnd_concurrent_programs_tl fcp,
         apps.fnd_responsibility_tl    fr,
         apps.fnd_user                 fu
   WHERE     fcr.CONCURRENT_PROGRAM_ID = fcp.concurrent_program_id
         AND fcr.responsibility_id = fr.responsibility_id
         AND fcr.requested_by = fu.user_id
         AND user_name = UPPER (:user_name)
ORDER BY REQUEST_DATE DESC;	   


select concurrent_program_name cp_short
      ,application_id
      ,USER_CONCURRENT_PROGRAM_NAME cp_name
      ,DESCRIPTION
      --,fcp.*
from fnd_concurrent_programs_vl fcp
where     queue_control_flag = 'N'
  and (executable_id in (select executable_id
                         from fnd_executables
                         where upper(executable_name) like '%XXTG_FILL_DLR_BLNC_REP%')) -- Например: XX_AR841
--  and (executable_application_id in (select application_id
--                                     from fnd_executables
--                                     where upper(executable_name) like '%&EXECUTABLE_LIKE%'))
order by application_id, user_concurrent_program_name

select rg.request_group_name, fap_rg.application_short_name, fcp.concurrent_program_name
      --,rg.*
from fnd_request_groups rg     --@MMKR11_KVAZAR.US.ORACLE.COM         rg
    ,fnd_request_group_units rgu    --@MMKR11_KVAZAR.US.ORACLE.COM    rgu
    ,fnd_concurrent_programs_vl fcp    --@MMKR11_KVAZAR.US.ORACLE.COM fcp
    ,fnd_application fap_rg --@MMKR11_KVAZAR.US.ORACLE.COM            fap_rg
    ,fnd_application fap_cp --@MMKR11_KVAZAR.US.ORACLE.COM            fap_cp
where rg.request_group_id = rgu.request_group_id
  and rgu.request_unit_id = fcp.concurrent_program_id
  and fap_cp.application_id = fcp.application_id
  and fap_rg.application_id = rg.application_id
  and fcp.concurrent_program_name like '%XXTG_FILL_DLR_BLNC_REP%'         -- Например: XX_AR841
;

select executable_name exec_name
      ,upper(execution_file_name) execution_file_name
      ,description
     --,fef.*
from fnd_executables_form_v fef
where 1=1 --executable_id > 4
  and (upper(execution_file_name) like '%XXTG_FILL_DLR_BLNC_REP%') -- Например: XXAR_LOG_FORM
order by application_name, executable_name
;
;

SELECT resp.RESPONSIBILITY_NAME
       --,resp.RESPONSIBILITY_KEY
       --,resp.DESCRIPTION
       ,resp.RESPONSIBILITY_ID
       ,resp.APPLICATION_ID
       --,resp.DATA_GROUP_ID
       --,resp.DATA_GROUP_APPLICATION_ID
       --,resp.MENU_ID
       ,resp.REQUEST_GROUP_ID
       --,resp.GROUP_APPLICATION_ID
       --,resp.START_DATE
FROM FND_RESPONSIBILITY_VL resp
    ,fnd_request_groups rg
    ,fnd_application fap_rg
WHERE 1 = 1
  --and (version = '4' OR version = 'W' OR version = 'M')
  and rg.request_group_id = resp.request_group_id
  and rg.APPLICATION_ID = resp.GROUP_APPLICATION_ID
  and fap_rg.application_id = rg.application_id
  and nvl(resp.END_DATE,trunc(sysdate)) >= trunc(sysdate)
  and exists(select urg.user_id, fu.user_name from fnd_user_resp_groups urg, fnd_user fu
             where urg.user_id = fu.user_id
               and urg.RESPONSIBILITY_ID = resp.RESPONSIBILITY_ID
               --and urg.user_id = 0              -- Полномочия есть у Сисадмина
               --and fu.user_name = 'SYSADMIN'    -- Полномочия есть у пользователя
            )
  and rg.request_group_name like '%&RG_NAME_LIKE%'  -- По названию Группы Запросов, например: Receivables All
  --and fap_rg.application_short_name = 'GMF'       -- По Приложению Группы Запросов
  --and rg.application_id = 101                     -- По ИД Приложения Группы Запросов
ORDER BY responsibility_name
;
	   