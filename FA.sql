/*Disable dublicate location in Fixed Assets
Отключение дублей расположений. 
*/
declare 
BEGIN
    for rec in (select SEGMENT1 , SEGMENT2,  SEGMENT3,   SEGMENT4    , SEGMENT5, min(location_ID) location_ID
                from FA_LOCATIONS
                group by  SEGMENT1 , SEGMENT2,  SEGMENT3,   SEGMENT4    , SEGMENT5
                having count(1) >1 
                )
    loop
        for rec_loc in (select location_id from FA_LOCATIONS fa
                        where NVL(fa.SEGMENT1,'-1') = NVL(rec.SEGMENT1,'-1')
                        and   NVL(fa.SEGMENT2,'-1') = NVL(rec.SEGMENT2,'-1')
                        and   NVL(fa.SEGMENT3,'-1') = NVL(rec.SEGMENT3,'-1')
                        and   NVL(fa.SEGMENT4,'-1') = NVL(rec.SEGMENT4,'-1')
                        and   NVL(fa.SEGMENT5,'-1') = NVL(rec.SEGMENT5,'-1')
                       )
        loop
            update FA_DISTRIBUTION_HISTORY
            set location_id = rec.location_id
            where location_id  = rec_loc.location_id;
       
            delete from FA_LOCATIONS
            where location_id = rec_loc.location_id;
           
            commit;
        end loop;
   
    end loop;
END;
