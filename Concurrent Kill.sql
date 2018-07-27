--Как завершить запросы.

--1)    Проверяем, активен ли сейчас запрос

SELECT ses.sid, ses.serial#
  FROM gv$session ses, gv$process pro
 WHERE     ses.paddr = pro.addr
       AND pro.spid IN (SELECT oracle_process_id
                          FROM apps.fnd_concurrent_requests
WHERE request_id = 5427879);

--2)    Если активен, необходимо сначала погасить его сессию (сессии может не быть).  Введя параметры 
ALTER SYSTEM KILL SESSION '<sid>,<serial>' IMMEDIATE;
Или 
exec admin.kill_session(<sid>,<serial>);  


--3)    Затем необходимо пометить запросы как завершенные в базе

UPDATE apps.fnd_concurrent_requests --4440385
    SET status_code = 'X', phase_code = 'C'
    WHERE request_id = '5427879';

COMMIT;

UPDATE apps.fnd_concurrent_requests --4440385
    SET status_code = 'E', phase_code = 'C'
    WHERE request_id = '5427879'
    
COMMIT;

--#Status Code
--E -  Error
--X -  Terminate
--G -  Warning

На этом этапе возможно зависание Update, т.к. менеджеры не сразу фиксируют изменения и пока именно этот менеджер (1 из 30) не выполнит, какой нить другой запрос, все может висеть. Поэтому проверяем блокировку
SELECT
   s.blocking_session, 
   s.sid, 
   s.serial#, 
   s.seconds_in_wait
FROM
   v$session s
WHERE
   blocking_session IS NOT NULL;

Если статус сессии которая блокирует ‘INACTIVE’ то убиваем ее, подставляя соотвествующие значения.
exec admin.kill_session(<sid>,<serial>);  
