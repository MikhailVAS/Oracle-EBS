SELECT a.sid,
a.serial#,
b.username,
opname OPERATION,
target OBJECT,
TRUNC (elapsed_seconds, 5) "ET (s)",
TO_CHAR (start_time, 'HH24:MI:SS') start_time,
ROUND ( (sofar / totalwork) * 100, 2) "COMPLETE (%)"
FROM v$session_longops a, v$session b
WHERE a.sid = b.sid
AND b.username NOT IN ('SYS', 'SYSTEM')
AND totalwork > 0
ORDER BY elapsed_seconds;