/* Query to pull down all flexfield 
     values based upon a specified flex value set name*/
SELECT fv.*
  FROM applsys.fnd_flex_values fv, applsys.fnd_flex_value_sets fvs
 WHERE     fvs.flex_value_set_id = fv.flex_value_set_id
       AND fvs.flex_value_set_name =
           NVL (UPPER ('' || :FLEX_FIELD_VALUE_NAME || ''),
                flex_value_set_name); 