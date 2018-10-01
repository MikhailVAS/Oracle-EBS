
/* Find Vacation Rules by user_name in OracleEBS ( Поиск правил переадрисации на время отпуска по имени учётки в Oracle EBS)*/
  SELECT RoutingRulesEO.ROLE,
         RoutingRulesEO.RULE_ID,
         RoutingRulesEO.MESSAGE_TYPE,
         RoutingRulesEO.MESSAGE_NAME,
         RoutingRulesEO.BEGIN_DATE,
         RoutingRulesEO.END_DATE,
         RoutingRulesEO.ACTION,
         RoutingRulesEO.ACTION_ARGUMENT,
         ItemTypesEO.DISPLAY_NAME AS TYPE_DISPLAY,
         MessagesEO.DISPLAY_NAME AS MSG_DISPLAY,
         MessagesEO.SUBJECT,
         LookupsEO.MEANING      AS ACTION_DISPLAY,
         ItemTypesEO.NAME,
         MessagesEO.TYPE,
         MessagesEO.NAME        AS NAME1,
         LookupsEO.LOOKUP_TYPE,
         LookupsEO.LOOKUP_CODE
    FROM APPS.WF_ROUTING_RULES RoutingRulesEO,
         APPS.WF_ITEM_TYPES_VL ItemTypesEO,
         APPS.WF_MESSAGES_VL  MessagesEO,
         APPS.WF_LOOKUPS      LookupsEO
   WHERE     RoutingRulesEO.ROLE LIKE '%TRIF%'
         AND RoutingRulesEO.MESSAGE_TYPE = ItemTypesEO.NAME(+)
         AND RoutingRulesEO.MESSAGE_TYPE = MessagesEO.TYPE(+)
         AND RoutingRulesEO.MESSAGE_NAME = MessagesEO.NAME(+)
         AND RoutingRulesEO.ACTION = LookupsEO.LOOKUP_CODE
         AND LookupsEO.LOOKUP_TYPE = 'WFSTD_ROUTING_ACTIONS'
ORDER BY RoutingRulesEO.BEGIN_DATE DESC,
         TYPE_DISPLAY,
         MSG_DISPLAY,
         BEGIN_DATE