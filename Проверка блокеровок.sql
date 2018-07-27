/* Formatted on 15/09/2017 16:12:56 (QP5 v5.294) Created by LifTech Mihail.Vasiljev */
SELECT *
  FROM (SELECT s.username,
               l.sid,
               s.ACTION,
               TRUNC (l.id1 / POWER (2, 16))         rbs,
               BITAND (l.id1, POWER (2, 16) - 1) + 0 slot,
               l.id2                                 seq
          FROM v$lock l, v$session s
         WHERE l.TYPE = 'TX' AND l.sid = s.sid AND s.SCHEMANAME = 'APPS') a,
       all_objects     uo,
       v$locked_object lo
 WHERE     lo.XIDUSN = a.rbs
       AND lo.XIDSLOT = a.slot
       AND lo.XIDSQN = a.seq
       AND uo.object_id = lo.OBJECT_ID
       AND lo.SESSION_ID = a.SID
--and uo.object_name = 'Название таблицы ( в моем случае -invoice)';