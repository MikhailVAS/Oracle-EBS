--ALTER SYSTEM KILL SESSION


--For Single Instance Database:

SELECT S.SID, S.SERIAL#, S.OSUSER, S.PROGRAM FROM V$SESSION S;

ALTER SYSTEM KILL SESSION 'sid,serial#';


--For RAC Instances:

SQL> select inst_id,sid,serial# from gv$session where username='SCOTT';

   INST_ID        SID    SERIAL# 
---------- ---------- ---------- 
         1        252  45632

SQL>  alter system kill session '252,45632,1'; 
 alter system kill session '252,45632,1' 
* 
--ERROR at line 1: 
--ORA-00026: missing or invalid session ID

--Now, it works:

SQL>  alter system kill session '252,45632,@1';

--System altered.