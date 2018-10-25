/* Not Ready WorkFlow */
  SELECT corrid,
         DECODE (state,
                 0, '0 = Ready',
                 1, '1 = Delayed',
                 2, '2 = Retained',
                 3, '3 = Exception',
                 TO_CHAR (state))
             State,
         COUNT (*)
             COUNT
    FROM APPS.wf_deferred
   WHERE state > 0
GROUP BY corrid, state

/* WorkFlow info by item_key */
SELECT wias.process_activity
           AS PROCESS_ACTIVITY,
       wias.activity_status
           AS ACTIVITY_STATUS,
       wa.TYPE
           AS ACTIVITY_TYPE,
       wa.display_name
           AS ACTIVITY_DISPLAY_NAME,
       wa2.display_name
           AS PARENT_ACTIVITY_DISPLAY,
       wpa.activity_name
           AS ACTIVITY_NAME,
       wpa.process_name
           AS PARENT_ACTIVITY,
       wias.item_type
           AS ITEM_TYPE,
       wias.item_key
           AS ITEM_KEY,
       wi.user_key
           AS USER_KEY,
       wias.notification_id
           AS NOTIFICATION_ID,
       wias.assigned_user
           AS ASSIGNED_USER,
           wias.notification_id,
       APPS.wf_notification.getsubject (wias.notification_id)
           AS SUBJECT,
      -- APPS.wf_fwkmon.getroleemailaddress (wias.assigned_user)
          -- AS ROLE_EMAIL_ADDRESS,
--       APPS.wf_directory.getroledisplayname (wias.assigned_user)
--           AS ROLE_DISPLAY_NAME,
       wl.meaning
           AS ACTIVITY_STATUS_DISPLAY,
       wl2.meaning
           AS ACTIVITY_TYPE_DISPLAY,
       wa.result_type
           AS RESULT_TYPE,
       wpa.default_result
           AS DEFAULT_RESULT,
       wias.due_date
           AS DUE_DATE,
       wpa.instance_label
           AS INSTANCE_LABEL,
       wias.begin_date
           AS BEGIN_DATE,
       wias.end_date
           AS END_DATE,
       wa.description
           AS DESCRIPTION,
       wa.version
           AS VERSION,
       wa.rerun
           AS RERUN,
       wa.expand_role
           AS EXPAND_ROLE,
       wa.function
           AS FUNCTION,
       wa.cost
           AS COST,
       wa.function_type
           AS FUNCTION_TYPE,
       wa.runnable_flag
           AS RUNNABLE_FLAG,
       wa.MESSAGE
           AS MESSAGE,
       wa.error_item_type
           AS ERROR_ITEM_TYPE,
       wit.display_name
           AS ERROR_ITEM_TYPE_DISPLAY,
       wa.error_process
           AS ERROR_PROCESS,
       wpa.perform_role_type
           AS PERFORM_ROLE_TYPE,
       wpa.perform_role
           AS PERFORM_ROLE,
       wpa.user_comment
           AS USER_COMMENT,
       wias.activity_result_code
           AS ACTIVITY_STATUS_RESULT_CODE,
       APPS.wf_core.activity_result (
           wa.result_type,
           DECODE (wias.activity_result_code,
                   '#NULL', 'NULL',
                   wias.activity_result_code))
           AS ACT_STAT_RESULT_DISP,
       APPS.wf_core.activity_result (
           wa.result_type,
           DECODE (wpa.default_result, '#NULL', 'NULL', wpa.default_result))
           AS ACT_USAGE_RESULT_DISP,
       fl.meaning
           AS EXPAND_ROLE_DISPLAY,
       fl3.meaning
           AS FUNCTION_TYPE_DISPLAY,
       wlt.display_name
           AS RESULT_TYPE_DISPLAY,
       fl2.meaning
           AS RERUN_DISPLAY,
       fl4.meaning
           AS PERFORM_ROLE_TYPE_DISPLAY,
       wpa.start_end
           AS START_END,
       fl5.meaning
           AS START_END_DISPLAY,
       DECODE (waav.value_type,
               'CONSTANT', TO_CHAR (waav.number_value),
               waav.text_value)
           AS TIMEOUT
  FROM APPS.wf_item_activity_statuses  wias,
       APPS.wf_process_activities      wpa,
       APPS.wf_activities_vl           wa,
       APPS.wf_activities_vl           wa2,
       APPS.wf_items                   wi,
       APPS.wf_lookups                 wl,
       APPS.wf_lookups                 wl2,
       APPS.fnd_lookups                fl,
       APPS.fnd_lookups                fl2,
       APPS.fnd_lookups                fl3,
       APPS.fnd_lookups                fl4,
       APPS.fnd_lookups                fl5,
       APPS.wf_item_types_vl           wit,
       APPS.wf_lookup_types            wlt,
       APPS.wf_activity_attr_values    waav
 WHERE     wias.item_type = wi.item_type
       AND wias.item_key = wi.item_key
       AND wias.process_activity = wpa.instance_id
       AND wpa.activity_name = wa.name
       AND wpa.activity_item_type = wa.item_type
       AND wi.begin_date BETWEEN wa.begin_date
                             AND NVL (wa.end_date, wi.begin_date)
       AND wpa.process_name = wa2.name
       AND wpa.process_item_type = wa2.item_type
       AND wpa.process_version = wa2.version
       AND wias.activity_status = wl.lookup_code
       AND wl.lookup_type = 'WFENG_STATUS'
       AND wa.TYPE = wl2.lookup_code
       AND wl2.lookup_type = 'WFENG_ACTIVITY_TYPE'
       --AND wias.item_type = :1
       AND wias.item_key = :DD
       --AND wias.process_activity = :3
       AND wa.error_item_type = wit.name
       AND wa.expand_role = fl.lookup_code
       AND fl.lookup_type = 'YES_NO'
       AND wa.result_type = wlt.lookup_type(+)
       AND wa.rerun = fl2.lookup_code
       AND fl2.lookup_type = 'FND_WF_ON_REVISIT'
       AND DECODE (wa.TYPE,
                   'FUNCTION', NVL (wa.function_type, 'PLSQL'),
                   wa.function_type) =
           fl3.lookup_code(+)
       AND 'FND_WF_FUNCTION_TYPE' = fl3.lookup_type(+)
       AND wpa.start_end = fl5.lookup_code(+)
       AND 'FND_WF_START_END' = fl5.lookup_type(+)
       AND wpa.perform_role_type = fl4.lookup_code
       AND fl4.lookup_type = 'FND_WF_VALUE_SOURCE'
       AND wias.process_activity = waav.process_activity_id(+)
       AND '#TIMEOUT' = waav.name(+)