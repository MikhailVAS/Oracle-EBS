/*
1) Checking for locks in parallel jobs
2) To check the simultaneous operation of programs at present with information about the Processed Time and the Start Date
3) Verify the last run of the parallel program, along with the time worked. It is useful to find detailed information on parallel programs that work daily and for comparison purposes
4) The following query displays the time taken to execute parallel programs - for a specific user with the latest parallel programs, sorted in the shortest possible time - to complete the request.
5) Gives information on the execution of current assignments
6) List of current programs that are being performed today, Provision of information on the status and log (The problem of loading the currency exchange rates)
7) Status problems completed with errors I
8) Status problems completed with errors II
9) CONCURRENT REQUESTS WHICH HAS MORE THAN 30 MINUTES OF EXECUTION TIME

=========================================================================================================================================

1) Для проверки блокировок в параллельных заданиях
2) Для проверки одновременных запущенных программ в настоящее время с информацией о Обработанном времени и начальной дате
3) Для проверки последнего запуска параллельной программы вместе с обработанным временем - Полезно найти подробную информацию о параллельных программах, которые работают ежедневно и в целях сравнения
4) Следующий запрос отображает время, затраченное на выполнение параллельных программ - для конкретного пользователя с последними параллельными программами, отсортированными в наименьшее время - для завершения запроса.
5) Дает информацию о выполнении текущих заданий
6) Список текущих программ, которые выполняются сегодня, Предоставление сведений о статусе и журнала (Проблема отработки загрузки курсов валют)
7) Проблемы по состоянию, завершенные с ошибками I
8) Проблемы по состоянию, завершенные с ошибками II
9) CONCURRENT REQUESTS WHICH HAS MORE THAN 30 MINUTES OF EXECUTION TIME
*/


--1-- Для проверки блокировок в параллельных заданиях

  SELECT DECODE (request, 0, 'Holder: ', 'Waiter: ') || sid sess,
         inst_id,
         id1,
         id2,
         lmode,
         request,
         TYPE
    FROM gV$LOCK
   WHERE (id1, id2, TYPE) IN (SELECT id1, id2, TYPE
                                FROM gV$LOCK
                               WHERE request > 0)
ORDER BY id1, request;

--2-- Для проверки одновременных запущенных программ в настоящее время с информацией о Обработанном времени и начальной дате

  SELECT DISTINCT
         c.USER_CONCURRENT_PROGRAM_NAME,
         ROUND ( ( (SYSDATE - a.actual_start_date) * 24 * 60 * 60 / 60), 2)
            AS Process_time,
         a.request_id,
         a.parent_request_id,
         a.request_date,
         a.actual_start_date,
         a.actual_completion_date,
         (a.actual_completion_date - a.request_date) * 24 * 60 * 60
            AS end_to_end,
         (a.actual_start_date - a.request_date) * 24 * 60 * 60 AS lag_time,
         d.user_name,
         a.phase_code,
         a.status_code,
         a.argument_text,
         a.priority
    FROM apps.fnd_concurrent_requests  a,
         apps.fnd_concurrent_programs  b,
         apps.FND_CONCURRENT_PROGRAMS_TL c,
         apps.fnd_user                 d
   WHERE     a.concurrent_program_id = b.concurrent_program_id
         AND b.concurrent_program_id = c.concurrent_program_id
         AND a.requested_by = d.user_id
         AND status_code = 'R'
ORDER BY Process_time DESC;

--3-- Для проверки последнего запуска параллельной программы вместе с обработанным временем - Полезно найти подробную информацию о параллельных программах, которые работают ежедневно и в целях сравнения

SELECT DISTINCT
       c.USER_CONCURRENT_PROGRAM_NAME,
       ROUND (
          (  (a.actual_completion_date - a.actual_start_date)
           * 24
           * 60
           * 60
           / 60),
          2)
          AS Process_time,
       a.request_id,
       a.parent_request_id,
       TO_CHAR (a.request_date, 'DD-MON-YY HH24:MI:SS'),
       TO_CHAR (a.actual_start_date, 'DD-MON-YY HH24:MI:SS'),
       TO_CHAR (a.actual_completion_date, 'DD-MON-YY HH24:MI:SS'),
       (a.actual_completion_date - a.request_date) * 24 * 60 * 60
          AS end_to_end,
       (a.actual_start_date - a.request_date) * 24 * 60 * 60 AS lag_time,
       d.user_name,
       a.phase_code,
       a.status_code,
       a.argument_text,
       a.priority
  FROM apps.fnd_concurrent_requests    a,
       apps.fnd_concurrent_programs    b,
       apps.FND_CONCURRENT_PROGRAMS_TL c,
       apps.fnd_user                   d
 WHERE     a.concurrent_program_id = b.concurrent_program_id
       AND b.concurrent_program_id = c.concurrent_program_id
       AND a.requested_by = d.user_id
       AND --          trunc(a.actual_completion_date) = '24-AUG-2005'
           c.USER_CONCURRENT_PROGRAM_NAME =
              'Incentive Compensation Analytics - ODI' --  and argument_text like  '%, , , , ,%';
--          and status_code!='C'


--4-- Следующий запрос отображает время, затраченное на выполнение параллельных программ - для конкретного пользователя с последними параллельными программами, отсортированными в наименьшее время - для завершения запроса.
 SELECT f.request_id,
         pt.user_concurrent_program_name user_conc_program_name,
         f.actual_start_date           start_on,
         f.actual_completion_date      end_on,
            FLOOR (
                 (  (f.actual_completion_date - f.actual_start_date)
                  * 24
                  * 60
                  * 60)
               / 3600)
         || ' HOURS '
         || FLOOR (
                 (  (  (f.actual_completion_date - f.actual_start_date)
                     * 24
                     * 60
                     * 60)
                  -   FLOOR (
                           (  (f.actual_completion_date - f.actual_start_date)
                            * 24
                            * 60
                            * 60)
                         / 3600)
                    * 3600)
               / 60)
         || ' MINUTES '
         || ROUND (
               (  (  (f.actual_completion_date - f.actual_start_date)
                   * 24
                   * 60
                   * 60)
                -   FLOOR (
                         (  (f.actual_completion_date - f.actual_start_date)
                          * 24
                          * 60
                          * 60)
                       / 3600)
                  * 3600
                - (  FLOOR (
                          (  (  (f.actual_completion_date - f.actual_start_date)
                              * 24
                              * 60
                              * 60)
                           -   FLOOR (
                                    (  (  f.actual_completion_date
                                        - f.actual_start_date)
                                     * 24
                                     * 60
                                     * 60)
                                  / 3600)
                             * 3600)
                        / 60)
                   * 60)))
         || ' SECS '
            time_difference,
         p.concurrent_program_name     concurrent_program_name,
         DECODE (f.phase_code,
                 'R', 'Running',
                 'C', 'Complete',
                 f.phase_code)
            Phase,
         f.status_code
    FROM apps.fnd_concurrent_programs  p,
         apps.fnd_concurrent_programs_tl pt,
         apps.fnd_concurrent_requests  f
   WHERE     f.concurrent_program_id = p.concurrent_program_id
         AND f.program_application_id = p.application_id
         AND f.concurrent_program_id = pt.concurrent_program_id
         AND f.program_application_id = pt.application_id
         AND pt.language = USERENV ('Lang')
         AND f.actual_start_date IS NOT NULL
ORDER BY f.actual_start_date DESC;

--5--  Дает информацию о выполнении текущих заданий

  SELECT DISTINCT
         c.USER_CONCURRENT_PROGRAM_NAME,
         ROUND ( ( (SYSDATE - a.actual_start_date) * 24 * 60 * 60 / 60), 2)
            AS Process_time,
         a.request_id,
         a.parent_request_id,
         a.request_date,
         a.actual_start_date,
         a.actual_completion_date,
         (a.actual_completion_date - a.request_date) * 24 * 60 * 60
            AS end_to_end,
         (a.actual_start_date - a.request_date) * 24 * 60 * 60 AS lag_time,
         d.user_name,
         a.phase_code,
         a.status_code,
         a.argument_text,
         a.priority
    FROM apps.fnd_concurrent_requests  a,
         apps.fnd_concurrent_programs  b,
         apps.FND_CONCURRENT_PROGRAMS_TL c,
         apps.fnd_user                 d
   WHERE     a.concurrent_program_id = b.concurrent_program_id
         AND b.concurrent_program_id = c.concurrent_program_id
         AND a.requested_by = d.user_id
         AND status_code = 'R'
ORDER BY Process_time DESC;

--6-- Список текущих программ, которые выполняются сегодня, Предоставление сведений о статусе и журнала (Проблема отработки загрузки курсов валют)

  SELECT DISTINCT fcp.user_concurrent_program_name,
                  fcp.concurrent_program_name,
                  fcr.request_id,
                  fcr.request_date,
                  flv.meaning status,
                  fcr.status_code,
                  fcr.completion_text,
                  fcr.logfile_name,
                  fcr.outfile_name,
                  fcr.argument_text
    FROM apps.fnd_concurrent_programs_vl fcp,
         apps.fnd_concurrent_requests  fcr,
         apps.fnd_lookup_values        flv
   WHERE     fcr.concurrent_program_id = fcp.concurrent_program_id
         AND TRUNC (fcr.last_update_date) = TRUNC (SYSDATE)
         AND flv.lookup_code = fcr.status_code
         AND flv.lookup_type = 'CP_STATUS_CODE'
         AND flv.language = 'US'
--AND fcr.status_code = 'E' -- Проверка на статус Error
ORDER BY fcr.request_date, fcr.request_id DESC;

--7-- Проблемы по состоянию, завершенные с ошибками I
 SELECT a.request_id                                 request_id,
         SUBSTR (a.user_concurrent_program_name, 1, 50) name,
         TO_CHAR (a.actual_start_date, 'Hh24:MI')     st_time,
         TO_CHAR (a.actual_completion_date, 'Hh24:MI') end_time,
         requestor,
         DECODE (a.phase_code,
                 'R', 'Running',
                 'P', 'Inactive',
                 'C', 'Completed',
                 a.phase_code)
            phase_code,
         DECODE (a.status_code,
                 'E', 'Error',
                 'C', 'Normal',
                 'X', 'Terminated',
                 'Q', 'On Hold',
                 'D', 'Cancelled',
                 'G', 'Warning',
                 'R', 'Normal',
                 'W', 'Paused',
                 a.status_code)
            status_code,
         actual_start_date
    FROM apps.fnd_conc_req_summary_v a
   WHERE     TRUNC (actual_completion_date) >= TRUNC (SYSDATE - 1)
         AND a.status_code IN ('E', 'X', 'D')
ORDER BY actual_start_date

--8-- Проблемы по состоянию, завершенные с ошибками II
  SELECT a.request_id "Req Id",
         a.phase_code,
         a.status_code,
         actual_start_date,
         actual_completion_date,
         c.concurrent_program_name || ': ' || ctl.user_concurrent_program_name
            "program"
    FROM APPLSYS.fnd_Concurrent_requests  a,
         APPLSYS.fnd_concurrent_processes b,
         applsys.fnd_concurrent_queues    q,
         APPLSYS.fnd_concurrent_programs  c,
         APPLSYS.fnd_concurrent_programs_tl ctl
   WHERE     a.controlling_manager = b.concurrent_process_id
         AND a.concurrent_program_id = c.concurrent_program_id
         AND a.program_application_id = c.application_id
         AND a.status_code = 'E'
         AND a.phase_code = 'C'
         AND actual_start_date > SYSDATE - 7
         AND b.queue_application_id = q.application_id
         AND b.concurrent_queue_id = q.concurrent_queue_id
         AND ctl.concurrent_program_id = c.concurrent_program_id
         AND CTL.LANGUAGE = 'US'
ORDER BY 5 DESC;


--9--  CONCURRENT REQUESTS WHICH HAS MORE THAN 30 MINUTES OF EXECUTION TIME
SELECT a.request_id
, SUBSTR(user_concurrent_program_name,1,50) name
, TO_CHAR(actual_start_date,'DD-MON-YY Hh24:MI') st_dt
, TO_CHAR(actual_completion_date,'Hh24:MI') end_tm
, TRUNC(((actual_completion_date-actual_start_date)*24*60*60)/60)+(((actual_completion_date-actual_start_date)*24*60*60)-(TRUNC(((actual_completion_date-actual_start_date)*24*60*60)/60)*60))/100 exe_time
, requestor
, DECODE(a.status_code, 'E'
,'Error', 'X'
,'Terminated', 'Normal') status_code
FROM apps.fnd_conc_req_summary_v a
WHERE actual_start_date >= DECODE(TO_CHAR(SYSDATE,'DAY'), 'MONDAY'
,TRUNC(SYSDATE)-3, 'SUNDAY'
,TRUNC(SYSDATE)-2, TRUNC(SYSDATE-1))
AND NVL(actual_completion_date,SYSDATE) - actual_start_date >= 30/24/60
ORDER BY actual_start_date, name