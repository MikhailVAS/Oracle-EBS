SELECT STATUS , ww.*
FROM  WF_NOTIFICATIONS ww
Where 1=1 
AND  MESSAGE_TYPE = 'XXTG_ITM' -- тип
and ORIGINAL_RECIPIENT = UPPER('Mariya.Skripko') -- кому 
--ORDER BY NOTIFICATION_ID
AND BEGIN_DATE >= TO_DATE ('11.02.2021 08:00:00', 'dd.mm.yyyy hh24:mi:ss') 

SELECT *
FROM FND_USER_PREFERENCES
WHERE user_name  LIKE '%VASILJEV%' 
AND module_name = 'WF' ;

SELECT *
FROM FND_USER_PREFERENCES
WHERE user_name  LIKE '%PONIK%' -- ('MIHAIL.VASILJEV','OLEG.PONIKARCHIK','MARIYA.SKRIPKO')
AND module_name = 'WF' ;

--UPDATE FND_USER_PREFERENCES SET param = NULL WHERE

/* Formatted on 17.02.2021 22:27:47 (QP5 v5.326) Service Desk 456402 Mihail.Vasiljev */
INSERT INTO APPS.FND_USER_PREFERENCES (USER_NAME,
                                       MODULE_NAME,
                                       PREFERENCE_NAME,
                                       PREFERENCE_VALUE)
     VALUES ('MARIYA.SKRIPKO',
             'WF',
             'MAILTYPE',
             'MAILHTML');
             
/* Formatted on 17.02.2021 22:36:44 (QP5 v5.326) Service Desk 456402 Mihail.Vasiljev */
UPDATE WF_NOTIFICATIONS
   SET STATUS = 'OPEN'
 WHERE     MESSAGE_TYPE = 'XXTG_ITM'                                    -- тип
       AND ORIGINAL_RECIPIENT = UPPER ('Mariya.Skripko')               -- кому
       AND BEGIN_DATE >=
           TO_DATE ('11.02.2021 08:00:00', 'dd.mm.yyyy hh24:mi:ss')

SELECT * FROM FND_USER WHERE USER_NAME in ('MIHAIL.VASILJEV','OLEG.PONIKARCHIK','MARIYA.SKRIPKO')

SELECT * FROM PER_ALL_PEOPLE_F WHERE LAST_NAME in ('Васильев','Скрипко','Поникарчик')

SELECT * FROM WF_LOCAL_ROLES
WHERE name in ('MIHAIL.VASILJEV','OLEG.PONIKARCHIK','MARIYA.SKRIPKO')

SELECT * FROM  wf_local_roles
--SET STATUS        ='INACTIVE' ,
--  expiration_date = (sysdate-1)
WHERE name in ('MIHAIL.VASILJEV','OLEG.PONIKARCHIK','MARIYA.SKRIPKO')
--AND parent_orig_system      ='WF_LOCAL_USERS'
--AND notification_preference ='DISABLED';

/* WorkList notification */
SELECT *
    FROM (SELECT NtfEO.NOTIFICATION_ID,
                 NtfEO.PRIORITY * -1
                     AS PRIORITY,
                 DECODE (
                     NtfEO.MORE_INFO_ROLE,
                     NULL, NtfEO.SUBJECT,
                        FND_MESSAGE.GET_STRING ('FND',
                                                'FND_MORE_INFO_REQUESTED')
                     || ' '
                     || NtfEO.SUBJECT)
                     AS SUBJECT,
                 NtfEO.LANGUAGE,
                 NVL (NtfEO.SENT_DATE, NtfEO.BEGIN_DATE)
                     BEGIN_DATE,
                 NtfEO.DUE_DATE,
                 'P'
                     AS PRIORITY_F,
                 NtfEO.STATUS,
                 NtfEO.FROM_USER,
                 NtfEO.MORE_INFO_ROLE,
                 NtfEO.FROM_ROLE,
                 NtfEO.RECIPIENT_ROLE,
                 DECODE (
                     NtfEO.MORE_INFO_ROLE,
                     NULL, NtfEO.TO_USER,
                     wf_directory.GetRoleDisplayName (NtfEO.MORE_INFO_ROLE))
                     AS TO_USER,
                 NtfEO.END_DATE,
                 NtfEO.MESSAGE_TYPE,
                 NtfEO.MESSAGE_NAME,
                 NtfEO.MAIL_STATUS,
                 NtfEO.ORIGINAL_RECIPIENT,
                 WIT.DISPLAY_NAME
                     AS TYPE
            FROM WF_NOTIFICATIONS NtfEO, WF_ITEM_TYPES_TL WIT
           WHERE     NtfEO.MESSAGE_TYPE = WIT.NAME
                 AND WIT.LANGUAGE = USERENV ('LANG')) QRSLT
   WHERE (    NVL (MORE_INFO_ROLE, RECIPIENT_ROLE) IN
                  (SELECT :1 FROM DUAL
                   UNION
                   SELECT WUR.role_name
                     FROM WF_USER_ROLES WUR
                    WHERE     WUR.user_name = 'VERA.TRIFONOVA'
--                          AND WUR.user_orig_system = :3
                          AND WUR.user_orig_system_id = '13432')
          AND STATUS = 'OPEN')
ORDER BY BEGIN_DATE DESC

/* Close WorkList notification (QP5 v5.326) Service Desk 507172 Mihail.Vasiljev */
UPDATE WF_NOTIFICATIONS
   SET STATUS = 'CLOSED'
 WHERE     RECIPIENT_ROLE IN
               (SELECT :1 FROM DUAL
                UNION
                SELECT WUR.role_name
                  FROM WF_USER_ROLES WUR
                 WHERE     WUR.user_name = 'VERA.TRIFONOVA'
                       --                          AND WUR.user_orig_system = :3
                       AND WUR.user_orig_system_id = '13432')
       AND STATUS = 'OPEN'

/* Delete WorkFlow notification (QP5 v5.388) Service Desk  Mihail.Vasiljev */
DELETE FROM WF_NOTIFICATIONS WN
      --select * FROM   WF_NOTIFICATIONS WN
      WHERE     WN.STATUS = 'OPEN'
            AND WN.recipient_role IN (SELECT WUR.role_name
                                        FROM WF_USER_ROLES WUR
                                       WHERE WUR.user_name = 'SYSADMIN')
            AND BEGIN_DATE < TO_DATE ('01.04.2023', 'dd.mm.yyyy')
            AND more_info_role IS NULL;