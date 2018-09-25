/* Who added analytics (Additional trx inforation) 
   Кто добавил аналитику (дополнительная информация trx)*/
SELECT ADDINF.DFF_ID1
           AS "Transaction header",
       (SELECT DISTINCT PER.FULL_NAME
          FROM APPS.fnd_user fu, APPS.PER_PEOPLE_F PER
         WHERE     fu.EMPLOYEE_ID = PER.PERSON_ID(+)
               AND fu.USER_ID = ADDINF.CREATED_BY)
           AS "People",
       LAST_UPDATE_DATE
           AS "Last Update"
  FROM APPS.XXTG_INV_ADD_INFO_DFF_EXT ADDINF
 WHERE ADDINF.dff_id1 = '33845497' -- Header transaction