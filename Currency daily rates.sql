/* Daily rate on date */
SELECT RATE_SOURCE_CODE,
       CONVERSION_DATE,
       typ.user_conversion_type     "User Conversion Type",
       rat.from_currency            "From Currency",
       rat.to_currency              "To Currency",
       CONVERSION_RATE              "Exchange Rate"
  FROM gl_daily_conversion_types typ, gl_daily_rates rat
 WHERE     rat.conversion_type = typ.conversion_type
       AND rat.CONVERSION_DATE = TO_DATE ('24.12.2019', 'dd.mm.yyyy')

/* Currency daily rates */
SELECT *
  FROM APPS.GL_DAILY_RATES
 WHERE CREATION_DATE > TO_DATE ('22.09.2018', 'dd.mm.yyyy')