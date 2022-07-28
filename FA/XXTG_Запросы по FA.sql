-- Финансовые сведенья об активе ОС
SELECT BOOK.BOOK_TYPE_CODE,
       ASSET.ASSET_NUMBER,
       ASSET.TAG_NUMBER,
       ASSET.DESCRIPTION,
       -- Начальная стоимость
       BOOK.ORIGINAL_COST,
       /*
         Функция возвращает сумму накопленной амортизации для актива
         p_asset_id        -- Ид актива
         p_book_type_code  -- Тип книги
         p_period_counter  -- Номер периода (по умолчанию приcваивается 0 и выводятся данные на текущий период)
       */
       XXTG_FA_UTILITY_PKG.GET_DEPRN_RESERVE (BOOK.ASSET_ID,
                                              BOOK.BOOK_TYPE_CODE,
                                              0)   DEPRN_RESERVE,
       /*
         Функция возвращает сумму накопленной амортизации для актива с начала года
         p_asset_id        -- Ид актива
         p_book_type_code  -- Тип книги
         p_period_counter  -- Номер периода (по умолчанию приcваивается 0 и выводятся данные на текущий период)
       */
       XXTG_FA_UTILITY_PKG.GET_YTD_DEPRN (BOOK.ASSET_ID,
                                          BOOK.BOOK_TYPE_CODE,
                                          0)       YTD_DEPRN,
       /*
         Функция возвращает сумму остаточной балансовой стоимости для актива
         p_asset_id        -- Ид актива
         p_book_type_code  -- Тип книги
         p_period_counter  -- Номер периода (по умолчанию приcваивается 0 и выводятся данные на текущий период)
       */
       XXTG_FA_UTILITY_PKG.GET_NET_BOOK_VALUE (BOOK.ASSET_ID,
                                               BOOK.BOOK_TYPE_CODE,
                                               0)  NET_BOOK_VALUE,
       ----- Cрока службы актива (общее количество месяцев, целых лет и остаток меяцев) -----
       LIFE.LIFE_IN_MONTHS,
       LIFE.LIFE_YEARS,
       LIFE.LIFE_MONTHS,
       ----- Остаток срока службы актива с даты DPIS (общее количество месяцев, целых лет и остаток меяцев) -----
       LIFE.REMAINING_LIFE_DPIS,
       LIFE.REMAINING_LIFE_YEARS_DPIS,
       LIFE.REMAINING_LIFE_MONTHS_DPIS,
       ----- Остаток срока службы актива с даты пропорционирования (общее количество месяцев, целых лет и остаток меяцев) -----
       LIFE.REMAINING_LIFE,
       LIFE.REMAINING_LIFE_YEARS,
       LIFE.REMAINING_LIFE_MONTHS
  FROM FA_ADDITIONS_V  ASSET                               -- Активы
       JOIN FA_BOOKS_V BOOK ON                             -- Книги
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN XXTG_FA_ASSET_LIFE_V LIFE ON                   -- Срок жизни актива
            BOOK.ASSET_ID = LIFE.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = LIFE.BOOK_TYPE_CODE
 WHERE 1 = 1 
   AND ASSET.ASSET_NUMBER = 1000380;   
   
-- Амортизация
SELECT BOOK_TYPE_CODE,     -- Книга
       ASSET_NUMBER,       -- Актив
       PERIOD_ENTERED,     -- Период амортизации
       TOTAL_DEPRN_AMOUNT, -- Общай сумма
       DEPRN_AMOUNT,       -- Сумма амортизации
       ADJUSTMENT_AMOUNT,  -- Сумма корректировки
       BONUS_DEPRN_AMOUNT, -- Сумма ускоренной амортизации
       BONUS_ADJUSTMENT_AMOUNT,  -- Сумма корр. ускоренной амортизации
       REVAL_AMORTIZATION, -- Переоценненная амортизация
       CODE_COMBINATION_ID,
       DEPRN_RUN_ID,
       XLA_CONVERSION_STATUS
  FROM FA_FINANCIAL_INQUIRY_DEPRN_V DEPRN
 WHERE DEPRN.SOB_ID = 2047
   AND DEPRN.BOOK_TYPE_CODE = 'BEST_FA_LOCAL'
   AND DEPRN.ASSET_ID = 1000380
 ORDER BY DEPRN.PERIOD_COUNTER DESC;
 
-- История стоимости
SELECT COST_HIS.TRANSACTION_HEADER_ID_IN, -- Шифр
       COST_HIS.TRANSACTION_TYPE,         -- Тип транзакции
       COST_HIS.TRANSACTION_DATE_ENTERED, -- Дата транзакции
       COST_HIS.PERIOD_EFFECTIVE,         -- Период действия
       COST_HIS.PERIOD_ENTERED,           -- Период ввода
       COST_HIS.FISCAL_YEAR,              -- Финансовый год
       COST_HIS.CURRENT_COST              -- Стоимость
  FROM FA_FINANCIAL_INQUIRY_COST_V COST_HIS             
 WHERE 1 = 1 
   AND COST_HIS.ASSET_ID = 1010088
   AND COST_HIS.BOOK_TYPE_CODE = 'BEST_FA_LOCAL'
 ORDER BY COST_HIS.TRANSACTION_HEADER_ID_IN;

-- Транзакции с ОС
SELECT BOOK.BOOK_TYPE_CODE,
       ASSET.ASSET_NUMBER,
       ASSET.TAG_NUMBER,
       ASSET.DESCRIPTION,
       TRN.TRANSACTION_HEADER_ID,
       TRN.TRANSACTION_TYPE_CODE,
       TRN.TRANSACTION_DATE_ENTERED,
       TRN.DATE_EFFECTIVE,
       TRN.TRANSACTION_NAME
  FROM FA_ADDITIONS_V ASSET                             -- Активы
       JOIN FA_BOOKS_V BOOK ON                          -- Книги
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN FA_TRANSACTION_HEADERS TRN ON               -- Транзакции
            BOOK.ASSET_ID = TRN.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = TRN.BOOK_TYPE_CODE
 WHERE ASSET.ASSET_NUMBER = 1000281
 ORDER BY TRN.TRANSACTION_HEADER_ID;

-- Информация о списании ОС
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
  FROM FA_ADDITIONS_V ASSET                      -- Активы
       JOIN FA_BOOKS_V BOOK ON                   -- Книги
            ASSET.ASSET_ID = BOOK.ASSET_ID
       JOIN FA_RETIREMENTS RET ON                -- Списания
            BOOK.ASSET_ID = RET.ASSET_ID AND
            BOOK.BOOK_TYPE_CODE = RET.BOOK_TYPE_CODE
 WHERE ASSET.ASSET_NUMBER = 1010088
 ORDER BY RET.RETIREMENT_ID;

