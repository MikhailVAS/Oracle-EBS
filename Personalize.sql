/* Personalize */
  SELECT form_name          form,
         function_name      Function,
         description        description,
         sequence           seq,
         trigger_event      triggerevent,
         trigger_object     triggerobject,
         condition          condition,
         enabled
    FROM fnd_form_custom_rules
ORDER BY form_name, function_name, sequence;

SELECT DISTINCT A.FORM_NAME,
A.FUNCTION_NAME,
A.ENABLED,
C.USER_FORM_NAME,
D.APPLICATION_NAME,
A.SEQUENCE,
A.TRIGGER_EVENT,
A.DESCRIPTION,
A.CONDITION
FROM FND_FORM_CUSTOM_RULES A,
FND_FORM B,
FND_FORM_TL C,
FND_APPLICATION_TL D 
WHERE ENABLED = 'Y' 
AND A.FORM_NAME = B.FORM_NAME 
AND B.FORM_ID = C.FORM_ID 
AND B.APPLICATION_ID = D.APPLICATION_ID 
ORDER BY APPLICATION_NAME;