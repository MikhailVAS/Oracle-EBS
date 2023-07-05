/* Find all info in value set by value set name */
SELECT ffvs.flex_value_set_id,
       ffvs.flex_value_set_name,
       ffvs.description     set_description,
       ffvs.validation_type,
       ffv.flex_value_id,
       ffv.flex_value,
       ffvt.flex_value_meaning,
       ffvt.description     value_description
  FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
 WHERE     ffvs.flex_value_set_id = ffv.flex_value_set_id
       AND ffv.flex_value_id = ffvt.flex_value_id
       AND ffvt.language = 'RU'--USERENV ('LANG')
       AND ffvs.flex_value_set_id =
           (SELECT DISTINCT FLEX_VALUE_SET_ID
              FROM applsys.fnd_flex_value_sets fvs
             WHERE fvs.flex_value_set_name =
                   NVL (UPPER ('' || :FLEX_FIELD_VALUE_NAME || ''), -- for example XXTG_INT_REQ_REASONS
                        flex_value_set_name));

/* Query to pull down all flexfield 
     values based upon a specified flex value set name*/
SELECT fv.*
  FROM applsys.fnd_flex_values fv, applsys.fnd_flex_value_sets fvs
 WHERE     fvs.flex_value_set_id = fv.flex_value_set_id
       AND fvs.flex_value_set_name =
           NVL (UPPER ('' || :FLEX_FIELD_VALUE_NAME || ''), -- for example XXTG_BUDGET
                flex_value_set_name); 
				
/* All info FLEX_FIELD_VALUE */
  SELECT FLEX_VALUE,
         FLEX_VALUE_MEANING,
         DESCRIPTION,
         ENABLED_FLAG,
         START_DATE_ACTIVE,
         END_DATE_ACTIVE,
         SUMMARY_FLAG,
         HIERARCHY_LEVEL,
         FLEX_VALUE_SET_ID,
         PARENT_FLEX_VALUE_LOW,
         PARENT_FLEX_VALUE_HIGH,
         FLEX_VALUE_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         STRUCTURED_HIERARCHY_LEVEL,
         COMPILED_VALUE_ATTRIBUTES,
         VALUE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_LOGIN,
         ROW_ID
    FROM APPS.FND_FLEX_VALUES_VL
    WHERE 1=1
--   WHERE     (   ('' IS NULL)
--              OR (structured_hierarchy_level IN
--                      (SELECT hierarchy_id
--                         FROM APPS.fnd_flex_hierarchies_vl h
--                        WHERE     h.flex_value_set_id = '1016137'
--                              AND h.hierarchy_name LIKE '')))
--         AND (FLEX_VALUE_SET_ID = '1016137')
--        -- AND (PARENT_FLEX_VALUE_LOW = 'Командир. Расходы')
AND FLEX_VALUE = '760_02_2_3_01_01' or FLEX_VALUE = '760_02_2_3_01_01' 
ORDER BY flex_value

SELECT *
  FROM FND_FLEX_VALUES_TL T
 WHERE T.FLEX_VALUE_ID =
       (SELECT B.FLEX_VALUE_ID
          FROM FND_FLEX_VALUES B
         WHERE FLEX_VALUE = 'Furnitures & fittings, Plant and Equipment')
         
/* Formatted on 25.03.2021 15:03:51 (QP5 v5.326) Service Desk 472790 Mihail.Vasiljev */
UPDATE FND_FLEX_VALUES_TL T
   SET DESCRIPTION = 'Furnitures & fittings,Plant & Equipment',
       FLEX_VALUE_MEANING = 'Furnitures & fittings,Plant & Equipment'
 WHERE T.FLEX_VALUE_ID =
       (SELECT B.FLEX_VALUE_ID
          FROM FND_FLEX_VALUES B
         WHERE FLEX_VALUE = 'Furnitures & fittings, Plant and Equipment')     
         
SELECT *
  FROM FND_FLEX_VALUES
 WHERE FLEX_VALUE = 'Furnitures & fittings, Plant and Equipment'
 
/* Formatted on 25.03.2021 15:04:45 (QP5 v5.326) Service Desk 472790 Mihail.Vasiljev */
UPDATE APPS.FND_FLEX_VALUES
   SET FLEX_VALUE = 'Furnitures & fittings,Plant & Equipment'
 WHERE FLEX_VALUE = 'Furnitures & fittings, Plant and Equipment'
 
 -- Concurrent Program Name with Parameter and Value set
 SELECT fcpl.user_concurrent_program_name
      , fcp.concurrent_program_name
      , par.column_seq_num     
      , par.end_user_column_name
      , par.form_left_prompt prompt
      , par.enabled_flag
      , par.required_flag
      , par.display_flag
      , par.flex_value_set_id
      , ffvs.flex_value_set_name
      , flv.meaning default_type
      , par.DEFAULT_VALUE
 FROM   fnd_concurrent_programs fcp
      , fnd_concurrent_programs_tl fcpl
      , fnd_descr_flex_col_usage_vl par
      , fnd_flex_value_sets ffvs
      , fnd_lookup_values flv
 WHERE  fcp.concurrent_program_id = fcpl.concurrent_program_id
 AND    fcpl.user_concurrent_program_name = :conc_prg_name
 AND    fcpl.LANGUAGE = 'US'
 AND    par.descriptive_flexfield_name = '$SRS$.' || fcp.concurrent_program_name
 AND    ffvs.flex_value_set_id = par.flex_value_set_id
 AND    flv.lookup_type(+) = 'FLEX_DEFAULT_TYPE'
 AND    flv.lookup_code(+) = par.default_type
 AND    flv.LANGUAGE(+) = USERENV ('LANG')

 ORDER BY par.column_seq_num

"Insert into APPS.FND_FLEX_VALUES
   (FLEX_VALUE_SET_ID, FLEX_VALUE_ID, FLEX_VALUE, LAST_UPDATE_DATE, LAST_UPDATED_BY, 
    CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, ENABLED_FLAG, SUMMARY_FLAG, 
    PARENT_FLEX_VALUE_LOW, VALUE_CATEGORY, ATTRIBUTE1 "	", ATTRIBUTE2)
 Values
   (1016137, (FND_FLEX_VALUES_S.nextval) , '740_08_02_01_00_00', TO_DATE('6/30/2023 11:23:11 AM', 'MM/DD/YYYY HH:MI:SS AM'), 7256, 
    TO_DATE('6/30/2023 11:22:36 AM', 'MM/DD/YYYY HH:MI:SS AM'), "	" 7256, 29669656, 'Y', 'N', 
    'Серверное оборудование', 'XXTG_CASH_FLOW_BUDGET_ITEM', '740_08_02_01_00_00', '20');
    
  COMMIT;  
  "

INSERT INTO APPS.FND_FLEX_VALUES_TL (FLEX_VALUE_ID,
                                     LANGUAGE,
                                     LAST_UPDATE_DATE,
                                     LAST_UPDATED_BY,
                                     CREATION_DATE,
                                     CREATED_BY,
                                     LAST_UPDATE_LOGIN,
                                     DESCRIPTION,
                                     SOURCE_LANG,
                                     FLEX_VALUE_MEANING)
    SELECT FLEX_VALUE_ID,
           'US',
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           (SELECT t.DESCRIPTION || ' (' || T.FLEX_VALUE_MEANING || ')'
             FROM FND_FLEX_VALUES_TL T
            WHERE     t.FLEX_VALUE_ID =
                      (SELECT MIN (T2.FLEX_VALUE_ID)
                        FROM FND_FLEX_VALUES_TL T2
                       WHERE     T2.FLEX_VALUE_MEANING = b.FLEX_VALUE
                             AND t2.LANGUAGE = 'US')
                  AND t.LANGUAGE = 'US'),
           'US',
           b.FLEX_VALUE
      FROM FND_FLEX_VALUES B
     WHERE     FLEX_VALUE_SET_ID = 1016137
           AND NOT EXISTS
                   (SELECT 1
                      FROM FND_FLEX_VALUES_TL t3
                     WHERE     t3.FLEX_VALUE_ID = b.FLEX_VALUE_ID
                           AND t3.LANGUAGE = 'US');

INSERT INTO APPS.FND_FLEX_VALUES_TL (FLEX_VALUE_ID,
                                     LANGUAGE,
                                     LAST_UPDATE_DATE,
                                     LAST_UPDATED_BY,
                                     CREATION_DATE,
                                     CREATED_BY,
                                     LAST_UPDATE_LOGIN,
                                     DESCRIPTION,
                                     SOURCE_LANG,
                                     FLEX_VALUE_MEANING)
    SELECT FLEX_VALUE_ID,
           'RU',
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           (SELECT t.DESCRIPTION || ' (' || T.FLEX_VALUE_MEANING || ')'
             FROM FND_FLEX_VALUES_TL T
            WHERE     t.FLEX_VALUE_ID =
                      (SELECT MIN (T2.FLEX_VALUE_ID)
                        FROM FND_FLEX_VALUES_TL T2
                       WHERE     T2.FLEX_VALUE_MEANING = b.FLEX_VALUE
                             AND t2.LANGUAGE = 'RU')
                  AND t.LANGUAGE = 'RU'),
           'RU',
           b.FLEX_VALUE
      FROM FND_FLEX_VALUES B
     WHERE     FLEX_VALUE_SET_ID = 1016137
           AND NOT EXISTS
                   (SELECT 1
                      FROM FND_FLEX_VALUES_TL t3
                     WHERE     t3.FLEX_VALUE_ID = b.FLEX_VALUE_ID
                           AND t3.LANGUAGE = 'RU');

 Insert into APPS.FND_FLEX_VALUES_TL
(FLEX_VALUE_ID, LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, DESCRIPTION, SOURCE_LANG, FLEX_VALUE_MEANING)
SELECT FLEX_VALUE_ID, 'US', LAST_UPDATE_DATE, CREATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, 
(SELECT t.DESCRIPTION ||' ('|| T.FLEX_VALUE_MEANING||')'   
    FROM FND_FLEX_VALUES_TL T
    WHERE t.FLEX_VALUE_ID = (SELECT min(T2.FLEX_VALUE_ID)
                            FROM FND_FLEX_VALUES_TL T2
                            WHERE T2.FLEX_VALUE_MEANING  = b.FLEX_VALUE
                              AND t2.LANGUAGE = 'US')
      AND t.LANGUAGE = 'US'), 'US', b.FLEX_VALUE
  FROM FND_FLEX_VALUES B
WHERE  FLEX_VALUE_SET_ID = 1016137
and not exists (select 1 from FND_FLEX_VALUES_TL t3 where t3.FLEX_VALUE_ID = b.FLEX_VALUE_ID AND t3.LANGUAGE = 'US');
    
Insert into APPS.FND_FLEX_VALUES_TL
(FLEX_VALUE_ID, LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, DESCRIPTION, SOURCE_LANG, FLEX_VALUE_MEANING)
SELECT FLEX_VALUE_ID, 'RU', LAST_UPDATE_DATE, CREATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, 
(SELECT t.DESCRIPTION ||' ('|| T.FLEX_VALUE_MEANING||')'   
    FROM FND_FLEX_VALUES_TL T
    WHERE t.FLEX_VALUE_ID = (SELECT min(T2.FLEX_VALUE_ID)
                            FROM FND_FLEX_VALUES_TL T2
                            WHERE T2.FLEX_VALUE_MEANING  = b.FLEX_VALUE
                              AND t2.LANGUAGE = 'RU')
      AND t.LANGUAGE = 'RU'), 'RU', b.FLEX_VALUE
  FROM FND_FLEX_VALUES B
WHERE  FLEX_VALUE_SET_ID = 1016137
and not exists (select 1 from FND_FLEX_VALUES_TL t3 where t3.FLEX_VALUE_ID = b.FLEX_VALUE_ID AND t3.LANGUAGE = 'RU');
