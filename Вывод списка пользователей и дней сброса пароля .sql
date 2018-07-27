-- Общее кол-во пользователей и дней сброса пароля 
SELECT *
  FROM (SELECT PASSWORD_LIFESPAN_DAYS 
          FROM APPS.fnd_user 
         WHERE END_DATE IS NULL AND LAST_UPDATE_LOGIN > 1  )
       PIVOT
          (COUNT (*)
          FOR PASSWORD_LIFESPAN_DAYS 
          IN (NULL, 45, 46, 60, 88, 90, 120, 454))

-- Вывод списка пользователей и дней сброса пароля 
SELECT *
  FROM (SELECT USER_NAME as "Учетная запись Oracle",PASSWORD_LIFESPAN_DAYS 
          FROM APPS.fnd_user 
         WHERE END_DATE IS NULL AND LAST_UPDATE_LOGIN > 1 )
       PIVOT
          (COUNT (*)
          FOR PASSWORD_LIFESPAN_DAYS 
          IN (NULL, 45, 46, 60, 88, 90, 120, 454))
          
--  Поиск пользователей с неограниченным временем паролем. 
SELECT USER_NAME AS "Учетная запись Oracle",
       PASSWORD_LIFESPAN_DAYS
  FROM APPS.fnd_user
 WHERE     END_DATE IS NULL                           -- Активные пользователи
       AND LAST_UPDATE_LOGIN > 1
       AND PASSWORD_LIFESPAN_DAYS IS NULL                     -- Вечный пароль
       AND USER_ID NOT IN (0,
                           1090,
                           1131,
                           1767,
                           1550,
                           2281,
                           2868)         -- Исключение системных пользователей
						   
SELECT DISTINCT fu.USER_ID  ,USER_NAME AS "Учетная запись Oracle",
       fu.END_DATE,
       PER.FULL_NAME
  FROM APPS.fnd_user fu,
       APPS.PER_PEOPLE_F PER
 WHERE     
   fu.EMPLOYEE_ID = PER.PERSON_ID(+)
 AND fu.END_DATE IS NOT NULL                         -- Не Активные пользователи
      AND fu.LAST_UPDATE_LOGIN > 1
     AND fu.USER_NAME NOT LIke '%D_%'
                /*  Исключение системных пользователей*/ 
     AND fu.USER_ID NOT IN   (0,    /* SYSADMIN             */ 
                           1090, /* ASADMIN              */ 
                           1131, /* CORETECH             */ 
                           1767, /* LOGISTICS_CONCURRENT */ 
                           1550, /* SCHEDULE             */ 
                           2281, /* WEBLOGIC             */ 
                           2868, /* BSTEDEALER           */ 
                           1766) /* FINANCE_CONCURRENT   */
