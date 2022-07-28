SELECT T_ADD.ASSET_ID,
       T_ADD.ATTRIBUTE_CATEGORY_CODE,
       T_ADD.GROUP_LOC_CODE                       "SID",       -- Поле 1  
       T_ADD.GROUP_DESCRIPTION                    "Родитель",  -- Поле 2   
       (SELECT EMPL.NAME
          FROM FA_DISTRIBUTION_INQUIRY_V FA_DIST,
               FA_EMPLOYEES EMPL
         WHERE FA_DIST.TRANSACTION_HEADER_ID_KEY = T_ADD.MAX_TRANSACTION_TRANSFER_ID
           --AND FA_DIST.TRANSTYPE in ('TRANSFER','-TRANSFER IN')
           AND FA_DIST.TRANS_UNITS > 0
           AND EMPL.EMPLOYEE_ID = FA_DIST.ASSIGNED_TO
           --AND EMPL.ACTUAL_TERMINATION_DATE IS NULL
           )  "МОЛ",      -- Поле 3
       T_ADD.TAG_NUMBER                          "Инвентарный номер",         -- Поле 4
       CASE
         WHEN SUBSTR(T_ADD.TAG_NUMBER,-1,1) in ('0','1','2','3','4','5','6','7','8','9') THEN T_ADD.TAG_NUMBER
         ELSE SUBSTR(T_ADD.TAG_NUMBER,1,LENGTH(T_ADD.TAG_NUMBER)-1)
       END                                       "Номер головного актива",    -- Поле 5
       T_ADD.ASSET_DESCRIPTION                   "Наименование",              -- Поле 6
       to_char(T_ADD.RECEIPT_DATE,'DD.MM.RRRR')  "Дата поступления",          -- Поле 7
       to_char(T_ADD.ENTER_DATE,'DD.MM.RRRR')    "Дата ввода в эксплуатацию", -- Поле 8
       T_ADD.CURRENT_UNITS                       "Количество",                -- Поле 9
       T_ADD.ORIGINAL_COST                       "Первоначальная стоимость",  -- Поле 10         
       T_ADD.CURRENT_COST            		         "Стоимость",                 -- Поле 11 
       T_ADD.CURRENT_COST - T_ADD.DEPRN_RESERVE  "Остаточная стоимость",      -- Поле 12 
       T_ADD.ASSET_LIFE                          "Срок амортизации",          -- Поле 13 
       T_ADD.DEPRN_RESERVE                       "Накопленная амортизация",   -- Поле 14
       T_ADD.YTD_DEPRN                           "Амортизация за отч.период", -- Поле 15
       (SELECT ASSET_LIFE.REMAINING_LIFE_DPIS 
          FROM XXTG_FA_ASSET_LIFE_V ASSET_LIFE  
         WHERE ASSET_LIFE.ASSET_ID = T_ADD.ASSET_ID 
           AND ASSET_LIFE.BOOK_TYPE_CODE = T_ADD.BOOK_TYPE_CODE)  "Остаточный срок амортизации", -- Поле 16
       T_ADD.TYPE                                "Тип"-- Поле 17
  FROM (SELECT BOOK.ASSET_ID,
               BOOK.BOOK_TYPE_CODE,  
               ASSET.ATTRIBUTE_CATEGORY_CODE,
               AGR.LOC_CODE  GROUP_LOC_CODE,    -- Поле 1
               AGR.CODE||' '||AGR.DESCRIPTION  GROUP_DESCRIPTION,  -- Поле 2
               (SELECT MAX(TRN_TRANSF.TRANSACTION_HEADER_ID) 
                  FROM FA_TRANSACTION_HEADERS TRN_TRANSF
                 WHERE TRN_TRANSF.ASSET_ID = BOOK.ASSET_ID
                   AND TRN_TRANSF.BOOK_TYPE_CODE = BOOK.BOOK_TYPE_CODE
                   AND TRN_TRANSF.TRANSACTION_TYPE_CODE IN ('TRANSFER','TRANSFER IN')) MAX_TRANSACTION_TRANSFER_ID,   -- Поле 3      
               ASSET.TAG_NUMBER                TAG_NUMBER,          -- Поле 5
               ASSET.DESCRIPTION               ASSET_DESCRIPTION,   -- Поле 6
               BOOK.DATE_PLACED_IN_SERVICE     RECEIPT_DATE,        -- Поле 7
               BOOK.DATE_PLACED_IN_SERVICE     ENTER_DATE,          -- Поле 8
               ASSET.CURRENT_UNITS             CURRENT_UNITS,       -- Поле 9
               BOOK.ORIGINAL_COST              ORIGINAL_COST,       -- Поле 10
               BOOK.COST                       CURRENT_COST,        -- Поле 11
               BOOK.LIFE_IN_MONTHS             ASSET_LIFE,          -- Поле 13
               XXTG_FA_UTILITY_PKG.GET_DEPRN_RESERVE (BOOK.ASSET_ID, BOOK.BOOK_TYPE_CODE, 0) DEPRN_RESERVE, -- Поле 14
               XXTG_FA_UTILITY_PKG.GET_YTD_DEPRN (BOOK.ASSET_ID, BOOK.BOOK_TYPE_CODE, 0)  YTD_DEPRN, -- Поле 15
               'Модернизация'    TYPE -- Поле 17 
          FROM (SELECT TRN_ADJ.ASSET_ID, 
                       TRN_ADJ.BOOK_TYPE_CODE,
                       MAX(TRN_ADJ.TRANSACTION_HEADER_ID) ADJUSTMENT_TRN_ID
                  FROM FA_TRANSACTION_HEADERS TRN_ADJ 
                 WHERE 1 = 1 
                   AND TRN_ADJ.TRANSACTION_DATE_ENTERED BETWEEN TO_DATE('01.01.2020','DD.MM.RRRR') AND TO_DATE('31.05.2020','DD.MM.RRRR')
                   AND TRN_ADJ.TRANSACTION_TYPE_CODE IN ('ADJUSTMENT')   
                   AND TRN_ADJ.ATTRIBUTE_CATEGORY_CODE NOT IN ('10','11','12','13','31','34','36','50','99')
                 GROUP BY TRN_ADJ.ASSET_ID, 
                          TRN_ADJ.BOOK_TYPE_CODE) ADJ_TRN 
          JOIN FA_ADDITIONS_V ASSET ON
               ASSET.ASSET_ID = ADJ_TRN.ASSET_ID
          JOIN FA_ASSET_KEYWORDS_KFV AKEY ON
               AKEY.CODE_COMBINATION_ID = ASSET.ASSET_KEY_CCID
          JOIN XXTG_FA_GROUPE_V AGR ON
               AGR.LOC_CODE = AKEY.SEGMENT1
          JOIN FA_BOOKS_BOOK_CONTROLS_V BOOK ON 
               BOOK.ASSET_ID = ASSET.ASSET_ID    
         WHERE 1 = 1
           AND SUBSTR(ASSET.ATTRIBUTE_CATEGORY_CODE,1,2) = '01'
           AND BOOK.DATE_INEFFECTIVE IS NULL) T_ADD; 