-- ���������� �������� �� ������ ��
SELECT BOOK.BOOK_TYPE_CODE,
       ASSET.ASSET_NUMBER,
       ASSET.TAG_NUMBER,
       ASSET.DESCRIPTION,
       -- ��������� ���������
       BOOK.ORIGINAL_COST,
       /*
         ������� ���������� ����� ����������� ����������� ��� ������
         p_asset_id        -- �� ������
         p_book_type_code  -- ��� �����
         p_period_counter  -- ����� ������� (�� ��������� ���c��������� 0 � ��������� ������ �� ������� ������)
       */
       XXTG_FA_UTILITY_PKG.GET_DEPRN_RESERVE (BOOK.ASSET_ID,
                                              BOOK.BOOK_TYPE_CODE,
                                              0)   DEPRN_RESERVE,
       /*
         ������� ���������� ����� ����������� ����������� ��� ������ � ������ ����
         p_asset_id        -- �� ������
         p_book_type_code  -- ��� �����
         p_period_counter  -- ����� ������� (�� ��������� ���c��������� 0 � ��������� ������ �� ������� ������)
       */
       XXTG_FA_UTILITY_PKG.GET_YTD_DEPRN (BOOK.ASSET_ID,
                                          BOOK.BOOK_TYPE_CODE,
                                          0)       YTD_DEPRN,
       /*
         ������� ���������� ����� ���������� ���������� ��������� ��� ������
         p_asset_id        -- �� ������
         p_book_type_code  -- ��� �����
         p_period_counter  -- ����� ������� (�� ��������� ���c��������� 0 � ��������� ������ �� ������� ������)
       */
       XXTG_FA_UTILITY_PKG.GET_NET_BOOK_VALUE (BOOK.ASSET_ID,
                                               BOOK.BOOK_TYPE_CODE,
                                               0)  NET_BOOK_VALUE,
       ----- C���� ������ ������ (����� ���������� �������, ����� ��� � ������� ������) -----
       LIFE.LIFE_IN_MONTHS,
       LIFE.LIFE_YEARS,
       LIFE.LIFE_MONTHS,
       ----- ������� ����� ������ ������ � ���� DPIS (����� ���������� �������, ����� ��� � ������� ������) -----
       LIFE.REMAINING_LIFE_DPIS,
       LIFE.REMAINING_LIFE_YEARS_DPIS,
       LIFE.REMAINING_LIFE_MONTHS_DPIS,
       ----- ������� ����� ������ ������ � ���� ������������������ (����� ���������� �������, ����� ��� � ������� ������) -----
       LIFE.REMAINING_LIFE,
       LIFE.REMAINING_LIFE_YEARS,
       LIFE.REMAINING_LIFE_MONTHS
  FROM FA_ADDITIONS_V  ASSET                               -- ������
       JOIN FA_BOOKS_V BOOK ON                             -- �����
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN XXTG_FA_ASSET_LIFE_V LIFE ON                   -- ���� ����� ������
            BOOK.ASSET_ID = LIFE.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = LIFE.BOOK_TYPE_CODE
 WHERE 1 = 1 
   AND ASSET.ASSET_NUMBER = 1000380;   
   
-- �����������
SELECT BOOK_TYPE_CODE,     -- �����
       ASSET_NUMBER,       -- �����
       PERIOD_ENTERED,     -- ������ �����������
       TOTAL_DEPRN_AMOUNT, -- ����� �����
       DEPRN_AMOUNT,       -- ����� �����������
       ADJUSTMENT_AMOUNT,  -- ����� �������������
       BONUS_DEPRN_AMOUNT, -- ����� ���������� �����������
       BONUS_ADJUSTMENT_AMOUNT,  -- ����� ����. ���������� �����������
       REVAL_AMORTIZATION, -- �������������� �����������
       CODE_COMBINATION_ID,
       DEPRN_RUN_ID,
       XLA_CONVERSION_STATUS
  FROM FA_FINANCIAL_INQUIRY_DEPRN_V DEPRN
 WHERE DEPRN.SOB_ID = 2047
   AND DEPRN.BOOK_TYPE_CODE = 'BEST_FA_LOCAL'
   AND DEPRN.ASSET_ID = 1000380
 ORDER BY DEPRN.PERIOD_COUNTER DESC;
 
-- ������� ���������
SELECT COST_HIS.TRANSACTION_HEADER_ID_IN, -- ����
       COST_HIS.TRANSACTION_TYPE,         -- ��� ����������
       COST_HIS.TRANSACTION_DATE_ENTERED, -- ���� ����������
       COST_HIS.PERIOD_EFFECTIVE,         -- ������ ��������
       COST_HIS.PERIOD_ENTERED,           -- ������ �����
       COST_HIS.FISCAL_YEAR,              -- ���������� ���
       COST_HIS.CURRENT_COST              -- ���������
  FROM FA_FINANCIAL_INQUIRY_COST_V COST_HIS             
 WHERE 1 = 1 
   AND COST_HIS.ASSET_ID = 1010088
   AND COST_HIS.BOOK_TYPE_CODE = 'BEST_FA_LOCAL'
 ORDER BY COST_HIS.TRANSACTION_HEADER_ID_IN;

-- ���������� � ��
SELECT BOOK.BOOK_TYPE_CODE,
       ASSET.ASSET_NUMBER,
       ASSET.TAG_NUMBER,
       ASSET.DESCRIPTION,
       TRN.TRANSACTION_HEADER_ID,
       TRN.TRANSACTION_TYPE_CODE,
       TRN.TRANSACTION_DATE_ENTERED,
       TRN.DATE_EFFECTIVE,
       TRN.TRANSACTION_NAME
  FROM FA_ADDITIONS_V ASSET                             -- ������
       JOIN FA_BOOKS_V BOOK ON                          -- �����
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN FA_TRANSACTION_HEADERS TRN ON               -- ����������
            BOOK.ASSET_ID = TRN.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = TRN.BOOK_TYPE_CODE
 WHERE ASSET.ASSET_NUMBER = 1000281
 ORDER BY TRN.TRANSACTION_HEADER_ID;

-- ���������� � �������� ��
SELECT BOOK.BOOK_TYPE_CODE,
       ASSET.ASSET_NUMBER,
       ASSET.TAG_NUMBER,
       ASSET.DESCRIPTION,
       RET.RETIREMENT_ID,
       RET.TRANSACTION_HEADER_ID_IN,
       RET.TRANSACTION_HEADER_ID_OUT,
       RET.DATE_RETIRED,
       RET.DATE_EFFECTIVE,
       RET.COST_RETIRED,
       RET.STATUS
  FROM FA_ADDITIONS_V ASSET                      -- ������
       JOIN FA_BOOKS_V BOOK ON                   -- �����
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN FA_RETIREMENTS RET ON                -- ��������
            BOOK.ASSET_ID = RET.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = RET.BOOK_TYPE_CODE
 WHERE ASSET.ASSET_NUMBER = 1010088
 ORDER BY RET.RETIREMENT_ID;

