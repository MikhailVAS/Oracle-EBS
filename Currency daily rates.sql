/* Currency daily rates */
SELECT *
  FROM APPS.GL_DAILY_RATES
 WHERE CREATION_DATE > TO_DATE ('22.09.2018', 'dd.mm.yyyy')