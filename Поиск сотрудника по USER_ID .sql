/* Поиск сотрудника по USER_ID */
SELECT DISTINCT fu.USER_ID,
                USER_NAME AS "Учетная запись Oracle",
                fu.END_DATE,
                PER.FULL_NAME
  FROM APPS.fnd_user fu, APPS.PER_PEOPLE_F PER
 WHERE fu.EMPLOYEE_ID = PER.PERSON_ID(+) AND fu.USER_ID = 4897