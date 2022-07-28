  SELECT DISTINCT a.form_name,
                  a.enabled,
                  c.USER_FORM_NAME,
                  d.APPLICATION_NAME
    FROM FND_FORM_CUSTOM_RULES a,
         FND_FORM             b,
         FND_FORM_TL          c,
         fnd_application_tl   d
   WHERE     enabled = 'Y'
         AND a.form_name = b.form_name
         AND b.form_id = c.form_id
         AND b.application_id = d.application_id
ORDER BY application_name;

/* Oracle Apps: Forms Personalization Tables
Below is the list of tables that are populated when any Forms Personalization is done */
FND_FORM_CUSTOM_RULES
FND_FORM_CUSTOM_SCOPES
FND_FORM_CUSTOM_ACTIONS
FND_FORM_CUSTOM_PARAMS
FND_FORM_CUSTOM_PROP_VALUES
FND_FORM_CUSTOM_PROP_LIST

 SELECT DISTINCT A.Id,
                  A.Form_Name,
                  A.Enabled,
                  C.User_Form_Name,
                  D.Application_Name,
                  a.sequence,
                  A.Description,
                  a.trigger_event,
                  a.trigger_object,
                  a.condition,
                  Ca.Action_Type,
                  ca.summary Action_description,
                  Ca.Enabled,
                  Ca.Object_Type,
                  ca.TARGET_OBJECT,
                  ca.property_value,
                  ca.MESSAGE_TYPE,
                  ca.MESSAGE_TEXT
    FROM FND_FORM_CUSTOM_RULES a,
         FND_FORM b,
         FND_FORM_TL c,
         Fnd_Application_Tl D,
         Fnd_Form_Custom_Actions ca
   WHERE     a.form_name = b.form_name
         AND B.Form_Id = C.Form_Id
         AND B.Application_Id = D.Application_Id
         --       AND D.Application_Id = 660                       --For Order Management
         --       AND C.User_Form_Name LIKE 'Sales%' --All the Forms that Start with Sales
         AND A.Enabled = 'Y'
         AND a.id = ca.rule_id
         AND (   CA.TARGET_OBJECT LIKE '%REQUEST_DATE%'
              OR CA.property_value LIKE '%REQUEST_DATE%'
              OR UPPER (A.Description) LIKE '%REQUEST_DATE%'
              OR UPPER (ca.summary) LIKE '%REQUEST_DATE%')
ORDER BY A.description