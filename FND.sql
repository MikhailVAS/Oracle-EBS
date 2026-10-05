/*Find All Responsibility having PO Summary form*/
SELECT fapp.application_short_name     AS "Application",
       fres.responsibility_name        AS "Responsibility Name",
       ff.function_name                AS "Function Short Name",
       ffl.user_function_name          AS "User Function Name",
       fm.menu_name                    AS "Menu Short Name",
       fml.user_menu_name              AS "User Menu Name",
       ffl.language
  FROM fnd_form  ffrm
       JOIN fnd_form_functions ff
           ON     ffrm.form_id = ff.form_id
              AND ffrm.application_id = ff.application_id
       JOIN fnd_form_functions_tl ffl
           ON ff.function_id = ffl.function_id AND ffl.language = 'RU'
       JOIN fnd_menu_entries fme ON ff.function_id = fme.function_id
       JOIN fnd_menus fm ON fme.menu_id = fm.menu_id
       JOIN fnd_menus_tl fml
           ON fm.menu_id = fml.menu_id AND fml.language = 'RU'
       JOIN fnd_responsibility fr ON fr.menu_id = fm.menu_id
       JOIN fnd_responsibility_tl fres
           ON     fr.responsibility_id = fres.responsibility_id
              AND fres.language = 'RU'
       JOIN fnd_application fapp ON fr.application_id = fapp.application_id
 WHERE ffrm.form_name IN
             (SELECT FORM_NAME FROM fnd_form WHERE FORM_ID IN (SELECT FORM_ID
              FROM fnd_form_TL
             WHERE USER_FORM_NAME LIKE '%Purchase Order Summary%')) --'POXPOVPO' -- Purchase Orders Summary