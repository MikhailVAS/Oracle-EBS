SELECT T_ADD.ASSET_ID,
       T_ADD.ATTRIBUTE_CATEGORY_CODE,
       T_ADD.GROUP_LOC_CODE                       "SID",       -- ���� 1  
       T_ADD.GROUP_DESCRIPTION                    "��������",  -- ���� 2  
       (SELECT EMPL.NAME
          FROM FA_DISTRIBUTION_INQUIRY_V FA_DIST,
               FA_EMPLOYEES EMPL
         WHERE FA_DIST.TRANSACTION_HEADER_ID_KEY = T_ADD.MAX_TRANSACTION_TRANSFER_ID
           --AND FA_DIST.TRANSTYPE = 'TRANSFER IN'
           AND FA_DIST.TRANS_UNITS > 0
           AND EMPL.EMPLOYEE_ID = FA_DIST.ASSIGNED_TO
           --AND EMPL.ACTUAL_TERMINATION_DATE IS NULL
           )  "���",      -- ���� 3
       T_ADD.TAG_NUMBER                          "����������� �����",         -- ���� 4
       CASE
         WHEN SUBSTR(T_ADD.TAG_NUMBER,-1,1) in ('0','1','2','3','4','5','6','7','8','9') THEN T_ADD.TAG_NUMBER
         ELSE SUBSTR(T_ADD.TAG_NUMBER,1,LENGTH(T_ADD.TAG_NUMBER)-1)
       END                                       "����� ��������� ������",    -- ���� 5
       T_ADD.ASSET_DESCRIPTION                   "������������",              -- ���� 6
       to_char(T_ADD.RECEIPT_DATE,'DD.MM.RRRR')  "���� �����������",          -- ���� 7
       to_char(T_ADD.ENTER_DATE,'DD.MM.RRRR')    "���� ����� � ������������", -- ���� 8
       T_ADD.CURRENT_UNITS                       "����������",                -- ���� 9
       T_ADD.ORIGINAL_COST                       "�������������� ���������",  -- ���� 10         
       T_ADD.COST            		                 "���������",                 -- ���� 11 
       T_ADD.COST - T_ADD.DEPRN_RESERVE          "���������� ���������",      -- ���� 12 
       T_ADD.ASSET_LIFE                          "���� �����������",          -- ���� 13 
       T_ADD.DEPRN_RESERVE                       "����������� �����������",   -- ���� 14
       T_ADD.YTD_DEPRN                           "����������� �� ���.������", -- ���� 15
       (SELECT ASSET_LIFE.REMAINING_LIFE_DPIS 
          FROM XXTG_FA_ASSET_LIFE_V ASSET_LIFE  
         WHERE ASSET_LIFE.ASSET_ID = T_ADD.ASSET_ID 
           AND ASSET_LIFE.BOOK_TYPE_CODE = T_ADD.BOOK_TYPE_CODE)  "���������� ���� �����������", -- ���� 16
       T_ADD.TYPE                                "���"-- ���� 17
  FROM (SELECT BOOK.ASSET_ID,
               BOOK.BOOK_TYPE_CODE,  
               ASSET.ATTRIBUTE_CATEGORY_CODE,
               AGR.LOC_CODE  GROUP_LOC_CODE,    -- ���� 1
               AGR.CODE||' '||AGR.DESCRIPTION  GROUP_DESCRIPTION,  -- ���� 2
               (SELECT MAX(TRN_TRANSF.TRANSACTION_HEADER_ID) 
                  FROM FA_TRANSACTION_HEADERS TRN_TRANSF
                 WHERE TRN_TRANSF.ASSET_ID = BOOK.ASSET_ID
                   AND TRN_TRANSF.BOOK_TYPE_CODE = BOOK.BOOK_TYPE_CODE
                   AND TRN_TRANSF.TRANSACTION_TYPE_CODE IN ('TRANSFER','TRANSFER IN')) MAX_TRANSACTION_TRANSFER_ID,   -- ���� 3      
               ASSET.TAG_NUMBER                TAG_NUMBER,          -- ���� 5
               ASSET.DESCRIPTION               ASSET_DESCRIPTION,   -- ���� 6
               BOOK.DATE_PLACED_IN_SERVICE     RECEIPT_DATE,        -- ���� 7
               BOOK.DATE_PLACED_IN_SERVICE     ENTER_DATE,          -- ���� 8
       ASSET.CURRENT_UNITS             CURRENT_UNITS,       -- ���� 9
       BOOK.ORIGINAL_COST              ORIGINAL_COST,       -- ���� 10
       BOOK.COST                       COST,                -- ���� 11
       BOOK.LIFE_IN_MONTHS             ASSET_LIFE,          -- ���� 13
       XXTG_FA_UTILITY_PKG.GET_DEPRN_RESERVE (BOOK.ASSET_ID, BOOK.BOOK_TYPE_CODE, 0) DEPRN_RESERVE, -- ���� 14
       XXTG_FA_UTILITY_PKG.GET_YTD_DEPRN (BOOK.ASSET_ID, BOOK.BOOK_TYPE_CODE, 0)  YTD_DEPRN, -- ���� 15
       '����������' TYPE-- ���� 17
  FROM FA_ADDITIONS_V ASSET
  JOIN FA_ASSET_KEYWORDS_KFV AKEY ON
       AKEY.CODE_COMBINATION_ID = ASSET.ASSET_KEY_CCID
  JOIN XXTG_FA_GROUPE_V AGR ON
       AGR.LOC_CODE = AKEY.SEGMENT1
  JOIN FA_BOOKS_BOOK_CONTROLS_V BOOK ON 
       BOOK.ASSET_ID = ASSET.ASSET_ID    
  JOIN FA_TRANSACTION_HEADERS TRN ON 
       TRN.ASSET_ID = BOOK.ASSET_ID AND
       TRN.BOOK_TYPE_CODE = BOOK.BOOK_TYPE_CODE 
  LEFT JOIN FA_FINANCIAL_INQUIRY_COST_V FA_FIN ON 
       FA_FIN.TRANSACTION_HEADER_ID_IN = TRN.TRANSACTION_HEADER_ID AND
       FA_FIN.ASSET_ID = TRN.ASSET_ID AND
       FA_FIN.BOOK_TYPE_CODE = TRN.BOOK_TYPE_CODE        
 WHERE 1 = 1
   AND SUBSTR(ASSET.ATTRIBUTE_CATEGORY_CODE,1,2) = '01'
   AND TRN.TRANSACTION_TYPE_CODE = 'ADDITION'
   AND TRN.TRANSACTION_DATE_ENTERED BETWEEN TO_DATE('01.01.2020','DD.MM.RRRR') AND TO_DATE('31.05.2020','DD.MM.RRRR')
   AND BOOK.DATE_INEFFECTIVE IS NULL ) T_ADD
   
   ; 