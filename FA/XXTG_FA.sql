/* XXTG_ACT_HDR_V */
  SELECT xah.doc_number
             AS "Номер документа",
         xah.doc_date
             AS "Дата документа",
         (SELECT fg.code
            FROM XXTG_FA_GROUPE_V fg
           WHERE fg.loc_code = XAH.CONSTR_OBJECT_CODE)
             AS "Объект нахождения ОС",
         xad.asset_number
             AS "ОС, инвентарный номер",
         xad.asset_name
             AS "Наименование ОС",
         xad.life_months
             AS "Срок продления, мес."
    FROM xxtg_act_details XAD, xxtg_act_hdr XAH
   WHERE xah.header_id = xad.header_id AND xah.doc_type = 'AVE'
ORDER BY xad.asset_number


XXTG_ACT_HDR_V
