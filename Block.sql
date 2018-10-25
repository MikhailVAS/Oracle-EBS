select 
   owner       c1, 
   object_type c3,
   object_name c2
from 
  dba_objects 
where 
   status != 'VALID'
order by
   owner,
   object_type;
   

/* На этом этапе возможно зависание Update, т.к. менеджеры не сразу фиксируют изменения и 
пока именно этот менеджер (1 из 30) не выполнит, какой нить другой запрос, все может висеть. Поэтому проверяем блокировку;*/
SELECT
   s.blocking_session, 
   s.sid, 
   s.serial#, 
   s.seconds_in_wait
FROM
   v$session s
WHERE
   blocking_session IS NOT NULL

select distinct
       o.object_name,
       sh.username || '(' || sh.sid || ',' || sh.serial# || ')' Holder,
       sh.osuser,
       sw.username || '(' || sw.sid || ',' || sw.serial# || ')' Waiter,
decode(lh.lmode,
              1,'null',
              2,'row share',
              3,'row exclusive',
              4,'share',
              5,'share row exclusive',
              6,'exclusive') Lock_Type
from v$session   sw,
     v$lock      lw,
     all_objects o,
     v$session   sh,
     v$lock      lh
where lh.id1 = o.object_id
      and lh.id1 = lw.id1
      and sh.sid = lh.sid
      and sw.sid = lw.sid
      and sh.lockwait is null
      and sw.lockwait is not null
     and lh.type = 'TM'
     and lw.type = 'TM'
     
     
/* он показывает сессии которые блокируют и те что заблокированы больше 900 секунд ,
l.ctime - меняешь на нужное тебе и смотришь */
  SELECT DECODE (l.BLOCK, 0, 'Waiting', 'Blocking ->') user_status,
         s.sid || ',' || s.serial# || ',@' || l.inst_id sid_serial,
         s.program,
         s.osuser,
         s.machine,
         s.module,
         ffs.user_name,
         ffs.RESPONSIBILITY_NAME,
         ffs.USER_FORM_NAME,
         DECODE (l.TYPE,
                 'RT', 'Redo Log Buffer',
                 'TD', 'Dictionary',
                 'TM', 'DML',
                 'TS', 'Temp Segments',
                 'TX', 'Transaction',
                 'UL', 'User',
                 'RW', 'Row Wait',
                 l.TYPE)
            lock_type,
         DECODE (l.lmode,
                 0, 'None',
                 1, 'Null',
                 2, 'Row Share',
                 3, 'Row Excl.',
                 4, 'Share',
                 5, 'S/Row Excl.',
                 6, 'Exclusive',
                 LTRIM (TO_CHAR (lmode, '990')))
            lock_mode,
         ctime,
         DECODE (l.BLOCK,  0, 'Not Blocking',  1, 'Blocking',  2, 'Global')
            lock_status,
         object_name
    FROM gv$lock                l,
         gv$session             s,
         gv$locked_object       o,
         dba_objects            d,
         apps.fnd_form_sessions_v ffs
   WHERE     l.inst_id = s.inst_id
         AND l.sid = s.sid
         AND o.inst_id = s.inst_id
         AND s.sid = o.session_id
         AND d.object_id = o.object_id
         AND s.sid = ffs.sid(+)
         AND s.inst_id = ffs.inst_id(+)
         AND (l.id1, l.id2, l.TYPE) IN (SELECT id1, id2, TYPE
                                          FROM gv$lock
                                         WHERE request > 0)
         AND (l.ctime > 900)
ORDER BY 1
     
     
     SELECT SID, SERIAL#, SQL_ID, EVENT, SECONDS_IN_WAIT, BLOCKING_SESSION FROM V$SESSION WHERE BLOCKING_SESSION IS NOT NULL;
     
SELECT SES1.SID || ',' || SES1.SERIAL# || '(' || SES1.USERNAME || ')' "BLOCKING",
       SES2.SID || ',' || SES2.SERIAL# || '(' || SES2.USERNAME || ')' "WAITING", 
       SES2.SECONDS_IN_WAIT,
       DO.OWNER || '.' || DO.OBJECT_NAME "ON_OBJECT",
       DBMS_ROWID.ROWID_CREATE(1, SES2.ROW_WAIT_OBJ#, SES2.ROW_WAIT_FILE#, 
       SES2.ROW_WAIT_BLOCK#, SES2.ROW_WAIT_ROW#) "LOCKED_ROWID",
       SES2.SQL_ID "WAITING_SQLID"
FROM   V$SESSION SES1, V$SESSION SES2, DBA_OBJECTS DO 
WHERE  SES1.SID=SES2.BLOCKING_SESSION AND SES2.ROW_WAIT_OBJ#=DO.OBJECT_ID AND 
       SES2.BLOCKING_SESSION IS NOT NULL
ORDER BY 1,3;
      
