--=========================== Find refiral SIM by SN ===========================	
SELECT *
  FROM tm_cim.referral_sim_card@sm_deepdb.best.local
 WHERE ICCID_B = '893750302201220092';