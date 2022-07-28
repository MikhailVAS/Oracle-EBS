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