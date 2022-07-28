= "UPDATE APPS.Po_Requisition_Lines_All
   SET NEED_BY_DATE =
           TO_DATE ('"&RC[-2]&"', 'dd-mm-yyyy hh24:mi:ss')
 WHERE REQUISITION_LINE_ID IN "
 
 (SELECT REQUISITION_LINE_ID
              FROM APPS.Po_Requisition_Lines_All    l,
                   APPS.Po_Requisition_Headers_All  h 
 
 = "WHERE     l.Requisition_Header_Id = h.Requisition_Header_Id
                   AND h.segment1 IN ('93527')
                   AND LINE_NUM = '"&RC[-6]&"'); "