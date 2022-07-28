declare
 fl boolean;
begin
  for cur in (select user_id  from fnd_user where user_name in  ('MIHAIL.VASILJEV')) loop
  fl:= fnd_profile.save('FND_DIAGNOSTICS','Y','USER',cur.user_id);                                         
  fl:= fnd_profile.save('DIAGNOSTICS','Y','USER',cur.user_id);
  fl:= fnd_profile.save('FND_HIDE_DIAGNOSTICS','N','USER',cur.user_id);
  DBMS_OUTPUT.put_line('Диагностика включена ! ');
  -- персонализация
  fl:= fnd_profile.save('FND_PERSONALIZATION_REGION_LINK_ENABLED','Y','USER',cur.user_id); -- FND: Personalization Region Link Enabled
  fl:= fnd_profile.save('FND_CUSTOM_OA_DEFINTION','Y','USER',cur.user_id);                 -- Personalize Self-Service Defn 
  fl:= fnd_profile.save('FND_DISABLE_OA_CUSTOMIZATIONS','N','USER',cur.user_id);           -- Disable Self-Service Persona
  end loop; 
  DBMS_OUTPUT.put_line('Персонализация включена ! ');
  commit;
end;