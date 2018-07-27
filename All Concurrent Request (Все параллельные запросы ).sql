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
	   