  /* Formatted on 6/28/2024 9:44:13 AM (QP5 v5.388) Service Desk  Mihail.Vasiljev */
SELECT *
  FROM GL_INTERFACE
 WHERE    1=1 -- STATUS != 'P'
       AND ACCOUNTING_DATE BETWEEN TO_DATE ('01.05.2024', 'dd.mm.yyyy')
                               AND TO_DATE ('31.05.2024', 'dd.mm.yyyy')
                               AND (ENTERED_DR = 973.12 OR ENTERED_CR = 973.12)
                               OR (ENTERED_DR = 785.84 OR ENTERED_CR = 785.84)
                               
                               
/* Formatted on 6/28/2024 2:38:45 PM (QP5 v5.388) Service Desk  Mihail.Vasiljev */
UPDATE GL_INTERFACE
   SET CODE_COMBINATION_ID = '1037538',-- 0
       ATTRIBUTE2 = 'Y',-- Null
       CODE_COMBINATION_ID_INTERIM = '1037538'-- 0
       ,STATUS = 'P'
 WHERE STATUS = 'EF05'
  
  
  SELECT SOB.SET_OF_BOOKS_ID
             "ID",
         SOB.NAME,
         SOB.SHORT_NAME,
         SOB.DESCRIPTION,
         SOB.CHART_OF_ACCOUNTS_ID
             "COA ID",
         FST.ID_FLEX_STRUCTURE_CODE
             "CHART OF ACCOUNTS",
         SOB.CURRENCY_CODE
             "CURR",
         PT.USER_PERIOD_TYPE
             "PERIOD",
         SOB.PERIOD_SET_NAME,
         SOB.FUTURE_ENTERABLE_PERIODS_LIMIT
             "FUT. PER",
         SOB.LATEST_OPENED_PERIOD_NAME
             "LATEST OPEN",
         SOB.ATTRIBUTE1
             "OPERATIONAL BOOK",
         SOB.ATTRIBUTE2
             "PPL ?",
         SOB.ENABLE_REVAL_SS_TRACK_FLAG || '.' || ENABLE_SECONDARY_TRACK_FLAG
             "SEC SEG TRACK?",
            RET.SEGMENT1
         || '-'
         || RET.SEGMENT2
         || '-'
         || RET.SEGMENT3
         || '-'
         || RET.SEGMENT4
         || '-'
         || RET.SEGMENT5
         || '-'
         || RET.SEGMENT6
             "RETAINED EARNINGS",
            TRAN.SEGMENT1
         || '-'
         || TRAN.SEGMENT2
         || '-'
         || TRAN.SEGMENT3
         || '-'
         || TRAN.SEGMENT4
         || '-'
         || TRAN.SEGMENT5
         || '-'
         || TRAN.SEGMENT6
             "TRAN EARNINGS",
         '---JOURNALS---',
         SOB.ALLOW_INTERCOMPANY_POST_FLAG
             "INTERCO?",
         SOB.ENABLE_JE_APPROVAL_FLAG
             "JRNL APP?",
         SOB.ENABLE_AUTOMATIC_TAX_FLAG
             "AUTO TAX?",
         SOB.SUSPENSE_ALLOWED_FLAG
             "SUSP?",
         SOB.TRACK_ROUNDING_IMBALANCE_FLAG
             "TRK RND?",
         '---AV BAL---',
            SOB.ENABLE_AVERAGE_BALANCES_FLAG
         || SOB.CONSOLIDATION_SOB_FLAG
         || SOB.TRANSACTION_CALENDAR_ID
         || SOB.NET_INCOME_CODE_COMBINATION_ID
         || SOB.DAILY_TRANSLATION_RATE_TYPE
         || SOB.TRANSLATE_EOD_FLAG
         || SOB.TRANSLATE_QATD_FLAG
         || SOB.TRANSLATE_YATD_FLAG
             "NOT USED",
         '---BUDGET CNTL---',
            SOB.ENABLE_BUDGETARY_CONTROL_FLAG
         || SOB.REQUIRE_BUDGET_JOURNALS_FLAG
         || SOB.RES_ENCUMB_CODE_COMBINATION_ID
             "NOT USED",
         '---MRC---',
         SOB.MRC_SOB_TYPE_CODE
             "NOT USED"
    FROM GL_SETS_OF_BOOKS      SOB,
         FND_ID_FLEX_STRUCTURES FST,
         GL_CODE_COMBINATIONS  TRAN,
         GL_CODE_COMBINATIONS  RET,
         GL_PERIOD_TYPES       PT
   WHERE     FST.ID_FLEX_NUM = SOB.CHART_OF_ACCOUNTS_ID
         AND RET.CODE_COMBINATION_ID(+) = SOB.RET_EARN_CODE_COMBINATION_ID
         AND TRAN.CODE_COMBINATION_ID(+) = SOB.CUM_TRANS_CODE_COMBINATION_ID
         AND PT.PERIOD_TYPE = SOB.ACCOUNTED_PERIOD_TYPE
--AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('BE','LU','ES','IT','HU','CZ','PL','RU')

ORDER BY 2

--GL Summary Account Template Definition Review

/* GL SUMMARY TEMPLATE DEFINITIONS
SMALL SCRIPT SHOWING SUMMARY TEMPLATE CONFIGURATION ACROSS MULTIPLE BOOKS */

SELECT SOB.NAME,
       ST.TEMPLATE_NAME,
       ST.CONCATENATED_DESCRIPTION,
       ST.ACCOUNT_CATEGORY_CODE        "CAT",
       ST.START_ACTUALS_PERIOD_NAME    "FROM",
          ST.SEGMENT1_TYPE
       || '-'
       || ST.SEGMENT2_TYPE
       || '-'
       || ST.SEGMENT3_TYPE
       || '-'
       || ST.SEGMENT4_TYPE
       || '-'
       || ST.SEGMENT5_TYPE
       || '-'
       || ST.SEGMENT6_TYPE
       || '-'
       || ST.SEGMENT7_TYPE
       || '-'
       || ST.SEGMENT8_TYPE
       || '-'
       || ST.SEGMENT9_TYPE
       || '-'
       || ST.SEGMENT10_TYPE            "SEGMENT TYPE"
  FROM GL_SUMMARY_TEMPLATES ST, GL_SETS_OF_BOOKS SOB
 WHERE ST.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
--AND SUBSTR(SOB.NAME,1,2) IN ('ES','BE','LU')

GL Segment Value Listing

/* SEGMENT VALUE SET LISTINGS
LISTS SINGLE OR MULTIPLE SEGMENT VALUE SETS. THIS IS USED TO PERFORM A QA ON CHART OF ACCOUNTS VALUES.
EXAMPLES OF OPTIONAL WHERE CLAUSES HAVE ALSO BEEN PROVIDED BELOW.*/


  SELECT FFVS1.FLEX_VALUE_SET_NAME--,   FFVS1.FLEX_VALUE_SET_ID

                                  ,
         FFVAL1.FLEX_VALUE                                            "VALUE",
         FFVAL1.SUMMARY_FLAG                                          "PARENT ACC ?",
         FFVTL1.DESCRIPTION,
         FFVAL1.ENABLED_FLAG,
         FH.HIERARCHY_CODE,
         SUBSTR (TO_CHAR (FFVAL1.COMPILED_VALUE_ATTRIBUTES), 1, 1)    "BUDGET",
         SUBSTR (TO_CHAR (FFVAL1.COMPILED_VALUE_ATTRIBUTES), 3, 1)    "POST",
         SUBSTR (TO_CHAR (FFVAL1.COMPILED_VALUE_ATTRIBUTES), 5, 1)    "TYPE",
         SUBSTR (TO_CHAR (FFVAL1.COMPILED_VALUE_ATTRIBUTES), 7, 1)    "CNTL",
         SUBSTR (TO_CHAR (FFVAL1.COMPILED_VALUE_ATTRIBUTES), 9, 1)    "RECON"--SELECT DISTINCT FFVS1.FLEX_VALUE_SET_NAME

                                                                             ,
         FFVAL1.LAST_UPDATED_BY,
         FFVAL1.LAST_UPDATE_DATE
    FROM FND_FLEX_VALUES        FFVAL1,
         FND_FLEX_VALUES_TL     FFVTL1,
         FND_FLEX_VALUE_SETS    FFVS1,
         FND_ID_FLEX_SEGMENTS   SEG,
         FND_FLEX_HIERARCHIES_VL FH
   WHERE     FFVAL1.FLEX_VALUE_SET_ID(+) = FFVS1.FLEX_VALUE_SET_ID
         AND SEG.FLEX_VALUE_SET_ID = FFVS1.FLEX_VALUE_SET_ID
         AND SEG.ID_FLEX_NUM = 51974 /* COA ID IS NEEDED IF SEGMENT IS CHART IN MULTPLE COA.  UPDATE FOR YOU CONFIGURATION OR REMOVE IF NOT APPLICABLE. */
         AND FFVAL1.FLEX_VALUE_ID = FFVTL1.FLEX_VALUE_ID(+)
         AND FFVS1.FLEX_VALUE_SET_NAME = 'OPERATIONS ACCOUNT'
         AND FFVAL1.STRUCTURED_HIERARCHY_LEVEL = FH.HIERARCHY_ID(+)
--AND SUBSTR(TO_CHAR(FFVAL1.COMPILED_VALUE_ATTRIBUTES),7,1) != 'N' -- NON-CONTROL ACCOUNTS ONLY
--AND SUBSTR(TO_CHAR(FFVAL1.COMPILED_VALUE_ATTRIBUTES),7,1) = 'Y' -- CONTROL ACCOUNTS ONLY
--AND FFVAL1.SUMMARY_FLAG = 'Y'
--AND FFVAL1.FLEX_VALUE >= '8000'
--AND FFVAL1.FLEX_VALUE <= '99999'
--AND FFVTL1.DESCRIPTION LIKE '%FTE%'
--AND FFVAL1.FLEX_VALUE LIKE '16%'
ORDER BY FFVS1.FLEX_VALUE_SET_NAME, FFVAL1.FLEX_VALUE

GL Period Status

/* GL PERIOD STATUSES
TWO SMALL SCRIPTS FOR REVIEWING OPEN PERIODS ACROSS MULTIPEL BOOKS.  ( MONTH END CLOSE CHECKING OR AUTOMATED ALERTS )
AND PERIOD STATUS FOR A GIVEN YEAR AND BOOK.
 */

  SELECT SOB.SHORT_NAME,
         PS.PERIOD_NAME,
         PS.SHOW_STATUS,
         PS.START_DATE || ' TO ' || PS.END_DATE,
         PS.PERIOD_YEAR,
         PS.PERIOD_NUM
    FROM GL_PERIOD_STATUSES_V PS, GL_SETS_OF_BOOKS SOB
   WHERE     PS.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
         AND APPLICATION_ID = 101
         --AND PERIOD_YEAR = 2006

         --AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('ES','LU','BE')

         AND PS.SHOW_STATUS NOT IN ('NEVER OPENED')
ORDER BY 1, 5, 6 DESC


SELECT SOB.SHORT_NAME,
       PS.PERIOD_NAME,
       PS.START_DATE,
       PS.END_DATE,
       PS.PERIOD_YEAR,
       PS.PERIOD_NUM,
       PS.SHOW_STATUS
  FROM GL_PERIOD_STATUSES_V PS, GL_SETS_OF_BOOKS SOB
 WHERE     PS.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
       AND APPLICATION_ID = 101
       AND PERIOD_YEAR = 2006
--AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('GB')
ORDER BY 1,5,6 DESC

GL Chart of Accounts Structure

/* CHART OF ACCOUNTS STRUCTURE
Gives an overview of the chart of accounts definitions and also status. 
This is used when implementing multiple charts of accounts to ensure consistent setup across countries and between environments.
Where clause can be added or commented out to just look at specific countries. */

  SELECT FST.ID_FLEX_STRUCTURE_NAME--,    FST.DESCRIPTION

                                   --,    FST.ID_FLEX_NUM

                                   --,    FST.ID_FLEX_STRUCTURE_CODE

                                   ,
         FST.CROSS_SEGMENT_VALIDATION_FLAG     "X-VAL",
         FST.FREEZE_STRUCTURED_HIER_FLAG       "FZ-HIER",
         FST.FREEZE_FLEX_DEFINITION_FLAG       "FZ-DEFN",
         FSEG.SEGMENT_NUM                      "SEG#",
         FSEG.SEGMENT_NAME                     "SEG NAME",
         VS.FLEX_VALUE_SET_NAME                "VALUE SET",
         FSEG.FLEX_VALUE_SET_ID                "VAL_SET_ID",
         FSEG.DEFAULT_TYPE                     "DEF TYPE",
         FSEG.DEFAULT_VALUE                    "DEF. VALUE",
         FSEG.ENABLED_FLAG                     "ENBLD",
         FSEG.REQUIRED_FLAG                    "REQD"
    FROM FND_ID_FLEX_STRUCTURES_VL FST,
         FND_ID_FLEX_SEGMENTS     FSEG,
         FND_FLEX_VALUE_SETS      VS
   WHERE     FST.ID_FLEX_NUM = FSEG.ID_FLEX_NUM
         AND FSEG.FLEX_VALUE_SET_ID = VS.FLEX_VALUE_SET_ID
         --AND SUBSTR(FST.ID_FLEX_STRUCTURE_CODE,1,2) IN ('BE','LU','ES','IT','HU','CZ','PL','RU')

         AND FST.APPLICATION_ID = 101
         AND FST.ID_FLEX_CODE = 'GL#'
ORDER BY 1, FSEG.SEGMENT_NUM

GL Chart of Accounts Structure Overview

/* CHART OF ACCOUNTS STRUCTURE
GIVES AN OVERVIEW OF THE CHART OF ACCOUNTS DEFINITIONS AND ALSO STATUS. 
THIS IS USED WHEN IMPLEMENTING MULTIPLE CHARTS OF ACCOUNTS TO ENSURE CONSISTENT SETUP ACROSS COUNTRIES AND BETWEEN ENVIRONMENTS.
WHERE CLAUSE CAN BE ADDED OR COMMENTED OUT TO JUST LOOK AT SPECIFIC COUNTRIES. */

  SELECT FST.ID_FLEX_STRUCTURE_NAME--,    FST.DESCRIPTION

                                   --,    FST.ID_FLEX_NUM

                                   --,    FST.ID_FLEX_STRUCTURE_CODE

                                   ,
         FST.CROSS_SEGMENT_VALIDATION_FLAG     "X-VAL",
         FST.FREEZE_STRUCTURED_HIER_FLAG       "FZ-HIER",
         FST.FREEZE_FLEX_DEFINITION_FLAG       "FZ-DEFN",
         FSEG.SEGMENT_NUM                      "SEG#",
         FSEG.SEGMENT_NAME                     "SEG NAME",
         VS.FLEX_VALUE_SET_NAME                "VALUE SET",
         FSEG.FLEX_VALUE_SET_ID                "VAL_SET_ID",
         FSEG.DEFAULT_TYPE                     "DEF TYPE",
         FSEG.DEFAULT_VALUE                    "DEF. VALUE",
         FSEG.ENABLED_FLAG                     "ENBLD",
         FSEG.REQUIRED_FLAG                    "REQD"
    FROM FND_ID_FLEX_STRUCTURES_VL FST,
         FND_ID_FLEX_SEGMENTS     FSEG,
         FND_FLEX_VALUE_SETS      VS
   WHERE     FST.ID_FLEX_NUM = FSEG.ID_FLEX_NUM
         AND FSEG.FLEX_VALUE_SET_ID = VS.FLEX_VALUE_SET_ID
         --AND SUBSTR(FST.ID_FLEX_STRUCTURE_CODE,1,2) IN ('BE','LU','ES','IT','HU','CZ','PL','RU')
         AND FST.APPLICATION_ID = 101
         AND FST.ID_FLEX_CODE = 'GL#'
ORDER BY 1, FSEG.SEGMENT_NUM

GL Journal Header Summary

/* GL JOURNAL HEADER SUMMARY
SUMMARY LISTING OF JOURNAL HEADER RECORDS BY CATEGORY AND SOURCE ACROSS MULTIPLE SETS OF BOOKS.) */

  SELECT SOB.SHORT_NAME                "BOOK",
         GJH.STATUS,
         GJH.POSTED_DATE,
         GJH.CREATION_DATE,
         GLS.USER_JE_SOURCE_NAME       "SOURCE",
         GLC.USER_JE_CATEGORY_NAME     "CATEGORY",
         GJH.PERIOD_NAME               "PERIOD",
         GJB.NAME                      "BATCH NAME",
         GJH.NAME                      "JOURNAL NAME",
         GJH.CURRENCY_CODE             "CURRENCY"
    FROM GL_JE_BATCHES   GJB,
         GL_JE_HEADERS   GJH,
         GL_SETS_OF_BOOKS SOB,
         GL_JE_SOURCES   GLS,
         GL_JE_CATEGORIES GLC
   WHERE     GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
         AND GJH.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
         AND GLS.JE_SOURCE_NAME = GJH.JE_SOURCE
         AND GLC.JE_CATEGORY_NAME = GJH.JE_CATEGORY
         --AND GJH.NAME     = 'QUV-DECLARATION TVA 11/04'  -- JOURNAL NAME
         --AND GLS.USER_JE_SOURCE_NAME LIKE '%MASS%'     -- JOURNAL SOURCE
         --AND GLC.USER_JE_CATEGORY_NAME= 'ADJUSTMENT'   -- JOURNAL CATEGORY
         --AND GJH.PERIOD_NAME IN ('MAY-06')             -- JOURNAL PERIOD
         AND (   TRUNC (GJH.CREATION_DATE) >=
                 TO_DATE ('01/07/2002', 'DD/MM/YYYY')
              OR TRUNC (GJH.POSTED_DATE) >=
                 TO_DATE ('01/07/2002', 'DD/MM/YYYY'))
--AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('DE')
ORDER BY 1,
         2 DESC,
         3,
         4,
         5,
         7

GL Journal Line Based Trial Balance Report

/* GL JOURNAL BASED TRIAL BALANCE
CREATES A TRIAL BALANCE BASED ON JOURNAL LINES.  CAN BE USED FOR NERVOUS DATA CONVERSION MANAGERS AS YOU CAN SEE THE IMPACT
OF JOURNALS ON ACCOUNT BALANCES WITHOUT THE NEED TO POST THE JOURNALS.*/

  SELECT SOB.SHORT_NAME,
         SOB.NAME,
         GJH.NAME,
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6
         || '-'
         || GCC.SEGMENT7
         || '-'
         || GCC.SEGMENT8
         || '-'
         || GCC.SEGMENT9
             "ACCOUNT",
         GJH.CURRENCY_CODE,
         SUM (GJL.ACCOUNTED_DR)
             "DR",
         SUM (GJL.ACCOUNTED_CR)
             "CR",
         SUM (NVL (GJL.ACCOUNTED_DR, 0) - NVL (GJL.ACCOUNTED_CR, 0))
             "END BALANCE",
         GJL.PERIOD_NAME
    FROM GL_JE_LINES         GJL,
         GL_JE_HEADERS       GJH,
         GL_CODE_COMBINATIONS GCC,
         GL_SETS_OF_BOOKS    SOB
   WHERE     GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
         AND GJL.JE_HEADER_ID = GJH.JE_HEADER_ID
         AND GJL.SET_OF_BOOKS_ID = GJH.SET_OF_BOOKS_ID
         AND SOB.SET_OF_BOOKS_ID = GJH.SET_OF_BOOKS_ID
         AND SOB.SET_OF_BOOKS_ID = GJL.SET_OF_BOOKS_ID
         AND GJL.PERIOD_NAME = 'JUL-03'
--AND SOB.SHORT_NAME = 'GBMAN'
--AND GJH.NAME LIKE '%PPL%'
--AND GCC.SEGMENT1 = '85'
--AND GCC.SEGMENT2 = '70'
--AND GCC.SEGMENT3 = '0000'
--AND GCC.SEGMENT4 = '88165'
--AND GJH.STATUS = 'P'
--AND GJL.EFFECTIVE_DATE >= TO_DATE('06/04/2002','DD/MM/YYYY')
--AND GJL.EFFECTIVE_DATE <= TO_DATE('30/11/2002','DD/MM/YYYY')
GROUP BY SOB.SHORT_NAME,
         SOB.NAME,
         GJH.NAME,
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6
         || '-'
         || GCC.SEGMENT7
         || '-'
         || GCC.SEGMENT8
         || '-'
         || GCC.SEGMENT9,
         GJH.CURRENCY_CODE,
         GJL.PERIOD_NAME

GL Journal Lines With AP Source Reference Fields

/* GL JOURNAL LINES WITH AP SOURCE REFERENCE FIELDS */

  SELECT SOB.SHORT_NAME                  "BOOK",
         GLS.USER_JE_SOURCE_NAME         "SOURCE",
         GLC.USER_JE_CATEGORY_NAME       "CATEGORY",
         GJB.NAME                        "BATCH NAME",
         GJH.NAME                        "JOURNAL NAME",
         GJH.CURRENCY_CODE               "CURRENCY",
         GJL.JE_LINE_NUM                 "JRNL LINE#",
         GJL.EFFECTIVE_DATE              "ACCOUNTING DATE",
         GJH.PERIOD_NAME                 "PERIOD",
         GJH.DATE_CREATED                "CREATED DATE",
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6
         || '-'
         || GCC.SEGMENT7
         || '-'
         || GCC.SEGMENT8
         || '-'
         || GCC.SEGMENT9
         || '-'
         || GCC.SEGMENT10                "ACCOUNT COMBINATION",
         GJL.ENTERED_DR,
         GJL.ENTERED_CR,
         GJL.ACCOUNTED_DR,
         GJL.ACCOUNTED_CR,
         GJH.CURRENCY_CONVERSION_RATE    "CONV RATE",
         GJH.CURRENCY_CONVERSION_DATE    "CONV DATE",
         GJH.CURRENCY_CONVERSION_TYPE    "CONV TYPE",
         GJL.DESCRIPTION,
         GJL.REFERENCE_1                 "AP VAND NAME",
         GJL.REFERENCE_2                 "AP INV_ID",
         GJL.REFERENCE_3                 "AP INV LINE#CHEQUEID",
         GJL.REFERENCE_4                 "AP PAYDOC#",
         GJL.REFERENCE_5                 "AP INVOICE #",
         GJL.REFERENCE_6                 "AP ACCOUNTING TYPE",
         GJL.REFERENCE_7                 "AP SOURCE ID",
         GJL.REFERENCE_8                 "AP NA",
         GJL.REFERENCE_9                 "AP DOCUMENT ID",
         GJL.REFERENCE_10                "AP LINE TYPE"
    FROM GL_JE_BATCHES       GJB,
         GL_JE_HEADERS       GJH,
         GL_JE_LINES         GJL,
         GL_CODE_COMBINATIONS GCC,
         GL_SETS_OF_BOOKS    SOB,
         GL_JE_SOURCES       GLS,
         GL_JE_CATEGORIES    GLC
   WHERE     GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
         AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
         AND GCC.CODE_COMBINATION_ID = GJL.CODE_COMBINATION_ID
         AND GJH.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
         AND GLS.JE_SOURCE_NAME = GJH.JE_SOURCE
         AND GLC.JE_CATEGORY_NAME = GJH.JE_CATEGORY
         AND GLS.USER_JE_SOURCE_NAME = 'Payables'
         AND GJH.PERIOD_NAME = 'JUL-04'
--and sob.set_of_books_id = 87
ORDER BY 1,
         2,
         3,
         4,
         5,
         7

GL Mass Allocation Rule Migration Script in Dataload Classic Format

/* MASS ALLOCATION MIGRATION - DATALOAD CLASSIC LAYOUT

CREATES A PRE-FORMATED SPREADSHEET LAYOUT TO MIGRATE MASS ALLOCATIONS BETWEEN ENVIRONMENTS AND/OR BOOKS USING DATALOAD CLASSIC.
IT HAS BEEN WRITTEN FOR A 10 SEGMENT COA BUT CAN BE MODIFIED TO SUIT DIFFERENT STRUCTURES. */

  SELECT SUBSTR (FST.ID_FLEX_STRUCTURE_CODE, 1, 2)
             "BOOK",
         GAB.NAME
             "ALLOCATION NAME"/*, (CASE WHEN GAFL.LINE_NUMBER = 1 THEN  GAB.NAME  ELSE NULL END )"ALLOCATION NAME"
                              ,   (CASE WHEN GAFL.LINE_NUMBER = 1 THEN  'TAB' ELSE NULL END )"TAB"
                              ,   (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'A' ELSE NULL END )"A"
                              ,   (CASE WHEN GAFL.LINE_NUMBER = 1 THEN   'TAB' ELSE NULL END )"TAB"
                              ,   (CASE WHEN GAFL.LINE_NUMBER = 1 THEN  GAB.DESCRIPTION  ELSE NULL END )"ALLOC DESCRIPTION"
                              ,   (CASE WHEN GAFL.LINE_NUMBER = 1 THEN   '*AR' ELSE NULL END )"TAB"
                              ,*/
                              ,
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN '\' || GAF.NAME ELSE NULL END)
             "FORMULA NAME",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'TAB' ELSE NULL END)
             "TAB",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'ALLOCATION' ELSE NULL END)
             "ALLOCATION",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'TAB' ELSE NULL END)
             "TAB",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN GAF.DESCRIPTION ELSE NULL END)
             "FORMULA DESC",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'TAB' ELSE NULL END)
             "TAB",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'TAB' ELSE NULL END)
             "TAB",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN '*SB' ELSE NULL END)
             "FCP",
         (CASE WHEN GAFL.LINE_NUMBER = 1 THEN 'TAB' ELSE NULL END)
             "TAB",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1,
                                                 2,
                                                 3,
                                                 4)
                       THEN
                           'TAB'
                       ELSE
                           NULL
                   END)
              ELSE
                  NULL
          END)
             "TAB",
         (CASE
              WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT1
              ELSE '\' || TO_CHAR (GAFL.AMOUNT)
          END)
             "1",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 0, 1)
              ELSE
                  NULL
          END)
             "1T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT2 ELSE NULL END)
             "2",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 3, 1)
              ELSE
                  NULL
          END)
             "2T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT3 ELSE NULL END)
             "3",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 5, 1)
              ELSE
                  NULL
          END)
             "3T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT4 ELSE NULL END)
             "4",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 7, 1)
              ELSE
                  NULL
          END)
             "4T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT5 ELSE NULL END)
             "5",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 9, 1)
              ELSE
                  NULL
          END)
             "5T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT6 ELSE NULL END)
             "6",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 11, 1)
              ELSE
                  NULL
          END)
             "6T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT7 ELSE NULL END)
             "7",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 13, 1)
              ELSE
                  NULL
          END)
             "7T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT8 ELSE NULL END)
             "8",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 15, 1)
              ELSE
                  NULL
          END)
             "8T",
         (CASE WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT9 ELSE NULL END)
             "9",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 17, 1)
              ELSE
                  NULL
          END)
             "9T",
         (CASE
              WHEN GAFL.AMOUNT IS NULL THEN '\' || GAFL.SEGMENT10
              ELSE NULL
          END)
             "10",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  '\' || SUBSTR (GAFL.SEGMENT_TYPES_KEY, 19, 1)
              ELSE
                  NULL
          END)
             "10T",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1,
                                                 2,
                                                 3,
                                                 4,
                                                 5)
                       THEN
                           'ENT'
                       ELSE
                           NULL
                   END)
              ELSE
                  NULL
          END)
             "TAB1",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1,
                                                 2,
                                                 3,
                                                 4)
                       THEN
                           GAFL.CURRENCY_CODE
                       ELSE
                           NULL
                   END)
              ELSE
                  NULL
          END)
             "CURR",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1,
                                                 2,
                                                 3,
                                                 4)
                       THEN
                           'TAB'
                       ELSE
                           NULL
                   END)
              ELSE
                  NULL
          END)
             "TAB2",
         (CASE
              WHEN GAFL.AMOUNT IS NOT NULL
              THEN
                  (CASE WHEN GAFL.LINE_NUMBER IN (2) THEN 'TAB' ELSE NULL END)
              ELSE
                  NULL
          END)
             "TAB2",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1, 2, 3) THEN GAFL.AMOUNT_TYPE
                       ELSE NULL
                   END)
              ELSE
                  NULL
          END)
             "PTD/YTD",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE
                       WHEN GAFL.LINE_NUMBER IN (1, 2)
                       THEN
                           '\{TAB 3}'
                       ELSE
                           (CASE
                                WHEN GAFL.LINE_NUMBER IN (3) THEN '\{TAB 2}'
                                ELSE NULL
                            END)
                   END)
              ELSE
                  NULL
          END)
             "TAB3",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE WHEN GAFL.LINE_NUMBER IN (5) THEN '*SAVE' ELSE NULL END)
              ELSE
                  NULL
          END)
             "*SAVE",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE WHEN GAFL.LINE_NUMBER IN (5) THEN '*PB' ELSE NULL END)
              ELSE
                  NULL
          END)
             "*PB",
         (CASE
              WHEN GAFL.AMOUNT IS NULL
              THEN
                  (CASE WHEN GAFL.LINE_NUMBER IN (5) THEN '*NR' ELSE NULL END)
              ELSE
                  NULL
          END)
             "*NR"
    FROM GL_ALLOC_BATCHES         GAB,
         GL_ALLOC_FORMULAS        GAF,
         GL_ALLOC_FORMULA_LINES   GAFL,
         FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     GAB.ALLOCATION_BATCH_ID = GAF.ALLOCATION_BATCH_ID
         AND GAB.CHART_OF_ACCOUNTS_ID = FST.ID_FLEX_NUM
         AND GAF.ALLOCATION_FORMULA_ID = GAFL.ALLOCATION_FORMULA_ID
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_CODE,1,2) IN ('DE')
ORDER BY 1,
         GAB.NAME,
         GAF.NAME,
         GAFL.LINE_NUMBER

GL Balances and Movements

/* GL BALANCES & MOVEMENTS

GIVES A TRIAL BALANCE WITH OPENING, MOVEMENT AND CLOSING BALANCES FOR UPTO TEN SEGMENTS IN THE CHART OF ACCOUNTS BY CURRENCY.
THIS CAN BE USED TO AS A QUICK METHOD OF RUNNING A TRIAL BALANCE FOR DATA EXTRACT IN THE DESIRED FORMAT.
FOR EXAMPLE TO USE TO EXTRACT TO A THIRD PARTY REPORTING SYSTEM SUCH AS HYPERION
IT IS RECOMMENDED THAT THIS SCRIPT IS RUN FOR A SINGLE PERIOD AND BOOK FIRST TO GAUGE PERFORMANCE IN YOUR ENVIRONMENT. */

  SELECT SOB.NAME,
         GB.ACTUAL_FLAG,
         GB.PERIOD_NAME,
         GCC.CODE_COMBINATION_ID,
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6
         || '-'
         || GCC.SEGMENT7
         || '-'
         || GCC.SEGMENT8
         || '-'
         || GCC.SEGMENT9
         || '-'
         || GCC.SEGMENT10
             "DISTRIBUTION",
         SUM (NVL (GB.BEGIN_BALANCE_DR, 0) - NVL (GB.BEGIN_BALANCE_CR, 0))
             "OPEN BAL",
         NVL (GB.PERIOD_NET_DR, 0)
             "DEBIT",
         NVL (GB.PERIOD_NET_CR, 0)
             "CREDIT",
         SUM (NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0))
             "NET MOVEMENT",
           SUM ((NVL (GB.PERIOD_NET_DR, 0) + NVL (GB.BEGIN_BALANCE_DR, 0)))
         - SUM (NVL (GB.PERIOD_NET_CR, 0) + NVL (GB.BEGIN_BALANCE_CR, 0))
             "CLOSE BAL",
         GB.CURRENCY_CODE,
         GB.TRANSLATED_FLAG,
         GB.TEMPLATE_ID
    FROM GL_BALANCES GB, GL_CODE_COMBINATIONS GCC, GL_SETS_OF_BOOKS SOB
   WHERE     GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
         AND GB.ACTUAL_FLAG = 'A'
         AND GB.CURRENCY_CODE = SOB.CURRENCY_CODE
         AND GB.TEMPLATE_ID IS NULL
         AND GB.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
         AND GB.PERIOD_NAME = 'APR-04'
         AND SUBSTR (SOB.SHORT_NAME, 1, 2) IN ('PR')
--AND GCC.SEGMENT1 = '85'
--AND GCC.SEGMENT2 = '70'
--AND GCC.SEGMENT3 = '0000'
--AND GCC.SEGMENT4 IN ('99659')
--AND GCC.SEGMENT7 = 'T'
--AND     NVL(GB.TRANSLATED_FLAG,'X') != 'R'
GROUP BY SOB.NAME,
         GB.ACTUAL_FLAG,
         GB.PERIOD_NAME,
         GCC.CODE_COMBINATION_ID,
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6
         || '-'
         || GCC.SEGMENT7
         || '-'
         || GCC.SEGMENT8
         || '-'
         || GCC.SEGMENT9
         || '-'
         || GCC.SEGMENT10,
         NVL (GB.PERIOD_NET_DR, 0),
         NVL (GB.PERIOD_NET_CR, 0),
         GB.CURRENCY_CODE,
         GB.TRANSLATED_FLAG,
         GB.TEMPLATE_ID
  HAVING   SUM ((NVL (GB.PERIOD_NET_DR, 0) + NVL (GB.BEGIN_BALANCE_DR, 0)))
         - SUM (NVL (GB.PERIOD_NET_CR, 0) + NVL (GB.BEGIN_BALANCE_CR, 0)) <>
         0

GL Chart of Account Segment Hierarchy Ranges

/* GL : CCHART OF ACCOUNT SEGMENT HIERARCHY RANGES
CHART OF ACCOUNT SEGMENT HIERARCHY RANGES AND ATTRIBUTES FOR PARENT ACCOUNTS*/

  SELECT FVS.FLEX_VALUE_SET_NAME                        "VALUE SET",
         FV.FLEX_VALUE,
         NH.PARENT_FLEX_VALUE                           "PARENT",
         FVT.DESCRIPTION,
         NH.RANGE_ATTRIBUTE                             "INC C OR P?",
         NH.CHILD_FLEX_VALUE_LOW                        "FROM",
         NH.CHILD_FLEX_VALUE_HIGH                       "TO",
            NH.PARENT_FLEX_VALUE
         || ' : '
         || NH.RANGE_ATTRIBUTE
         || ' : '
         || NH.CHILD_FLEX_VALUE_LOW
         || ' -> '
         || NH.CHILD_FLEX_VALUE_HIGH                    "HIERARCHY RANGE",
         SUBSTR (FV.COMPILED_VALUE_ATTRIBUTES, 1, 1)    "POSTING",
         SUBSTR (FV.COMPILED_VALUE_ATTRIBUTES, 3, 1)    "BUDGETING",
         SUBSTR (FV.COMPILED_VALUE_ATTRIBUTES, 5, 1)    "ACC TYPE",
         FV.ENABLED_FLAG                                "ENABLED",
         FV.SUMMARY_FLAG                                "PARENT?",
         NH.LAST_UPDATE_DATE,
         FV.HIERARCHY_LEVEL                             "LEVEL"
    FROM FND_FLEX_VALUE_NORM_HIERARCHY NH,
         FND_FLEX_VALUE_SETS          FVS,
         FND_FLEX_VALUES_TL           FVT,
         FND_FLEX_VALUES              FV
   WHERE     FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
         AND FVS.FLEX_VALUE_SET_ID = NH.FLEX_VALUE_SET_ID
         AND FV.FLEX_VALUE_ID = FVT.FLEX_VALUE_ID
         AND NH.PARENT_FLEX_VALUE(+) = FVT.FLEX_VALUE_MEANING
         AND FVS.FLEX_VALUE_SET_ID = NH.FLEX_VALUE_SET_ID
         AND FVS.FLEX_VALUE_SET_NAME LIKE '%ACCOUNT%' --- CHART OF ACCOUNTS SEGMENT NAME
         --  AND SUBSTR(FVS.FLEX_VALUE_SET_NAME,4,2) IN ('BE','LU','ES')
         AND FV.SUMMARY_FLAG = 'Y'
         AND FV.FLEX_VALUE LIKE '%XYZ%'  --- THIS IS THE PARENT SEGMENT VALUES
--  AND NH.PARENT_FLEX_VALUE = '%%'
--  AND FV.ENABLED_FLAG = 'Y'
--  AND FV.HIERARCHY_LEVEL = '2'
ORDER BY 1, 3

GL Code Combinations CCIDs

/* GL CODE COMBINATIONS

GL CODE COMBINATIONS EXTRACT. CAN BE SELECT BY CHART OF ACCOUNTS, SPECIFIC SEGMENT VALUES OR SPECIFIC CODE COMBINATION ATTRIBUTES.
THIS CAN BE USED FOR CHART OF ACCOUNTS MAINTENANCE AND REVIEW*/

  SELECT FST.ID_FLEX_STRUCTURE_NAME,
            GCC.SEGMENT1
         || '-'
         || GCC.SEGMENT2
         || '-'
         || GCC.SEGMENT3
         || '-'
         || GCC.SEGMENT4
         || '-'
         || GCC.SEGMENT5
         || '-'
         || GCC.SEGMENT6,
         GCC.CODE_COMBINATION_ID,
         GCC.LAST_UPDATE_DATE,
         GCC.JGZZ_RECON_FLAG,
         GCC.START_DATE_ACTIVE,
         GCC.END_DATE_ACTIVE,
         GCC.DETAIL_POSTING_ALLOWED_FLAG,
         GCC.ENABLED_FLAG,
         GCC.SUMMARY_FLAG,
         GCC.START_DATE_ACTIVE
    FROM GL_CODE_COMBINATIONS GCC, FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     FST.ID_FLEX_NUM = GCC.CHART_OF_ACCOUNTS_ID
         AND FST.APPLICATION_ID = 101
         AND FST.ID_FLEX_CODE = 'GL#'
--AND GCC.SEGMENT1 IN ('25','26','30')
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('ES','BE','LU')
--AND GCC.SEGMENT4 = '99901'
ORDER BY 1, 2, 3

GL CVR Cross Validation Rule Detail Listing

/* CVR CROSS VALIDATION RULE DETAIL LISTING
PROVIDES DETAIL VIEW OF CVR DEFINITION INCLUDING ACCOUNT RANGES.*/

  SELECT FST.ID_FLEX_STRUCTURE_NAME,
         R.FLEX_VALIDATION_RULE_NAME,
         R.ENABLED_FLAG--,    R.ERROR_SEGMENT_COLUMN_NAME"ERR SEG"
                       --,    TL.DESCRIPTION
                       --,    TL.ERROR_MESSAGE_TEXT"ERROR MESSAGE"
                       ,
         L.ENABLED_FLAG,
         L.INCLUDE_EXCLUDE_INDICATOR      "INC?",
         L.CONCATENATED_SEGMENTS_LOW      "FROM",
         L.CONCATENATED_SEGMENTS_HIGH     "TO",
         L.LAST_UPDATED_BY,
         L.LAST_UPDATE_DATE
    FROM FND_FLEX_VALIDATION_RULES     R,
         FND_FLEX_VDATION_RULES_TL     TL,
         FND_FLEX_VALIDATION_RULE_LINES L,
         FND_ID_FLEX_STRUCTURES_VL     FST
   WHERE     R.APPLICATION_ID = TL.APPLICATION_ID
         AND FST.ID_FLEX_NUM = R.ID_FLEX_NUM
         AND R.ID_FLEX_CODE = TL.ID_FLEX_CODE
         AND R.ID_FLEX_NUM = TL.ID_FLEX_NUM
         AND R.FLEX_VALIDATION_RULE_NAME = TL.FLEX_VALIDATION_RULE_NAME
         AND R.FLEX_VALIDATION_RULE_NAME = TL.FLEX_VALIDATION_RULE_NAME
         AND R.APPLICATION_ID = L.APPLICATION_ID
         AND R.ID_FLEX_CODE = L.ID_FLEX_CODE
         AND R.ID_FLEX_NUM = L.ID_FLEX_NUM
         AND R.FLEX_VALIDATION_RULE_NAME = L.FLEX_VALIDATION_RULE_NAME
         AND R.FLEX_VALIDATION_RULE_NAME = L.FLEX_VALIDATION_RULE_NAME
         AND R.APPLICATION_ID = 101
--     OPTIONAL FILTERS BELOW TO LIMIT QUERY TO SPECIFIC CVR OR LINES
--AND    R.ERROR_SEGMENT_COLUMN_NAME = 'SEGMENT5'
--AND     TL.ERROR_MESSAGE_TEXT LIKE '%PLEASE USE A VALID R%'
--AND    R.FLEX_VALIDATION_RULE_NAME LIKE 'BE GROUP ERROR%'
--AND     TL.ERROR_MESSAGE_TEXT LIKE '%94005%'
--AND     L.INCLUDE_EXCLUDE_INDICATOR = 'E'
ORDER BY 1,
         R.FLEX_VALIDATION_RULE_NAME,
         L.INCLUDE_EXCLUDE_INDICATOR DESC,
         L.CONCATENATED_SEGMENTS_LOW


GL CVR Cross Validation Rule Overview

/* CVR OVERVIEW (CROSS VALIDATION RULES )

PROVIDES VIEW OF HEADER LEVEL CROSS VALIDATION RULE DEFINITIONS TO
OBTAIN AN OVERVIEW OF RULES AND MESSAGES ACROSS MULTIPLE CHARTS OF ACCOUNTS*/

  SELECT FST.ID_FLEX_STRUCTURE_NAME         "COA",
         R.FLEX_VALIDATION_RULE_NAME        "RULE NAME",
         R.ENABLED_FLAG                     "ENB?",
         R.ERROR_SEGMENT_COLUMN_NAME        "ERROR SEG",
         LENGTH (TL.ERROR_MESSAGE_TEXT)     "ERROR LENGTH",
         TL.ERROR_MESSAGE_TEXT              "MESSAGE",
         TL.CREATION_DATE
    --SELECT COUNT(*), FST.ID_FLEX_STRUCTURE_NAME
    FROM FND_FLEX_VALIDATION_RULES R,
         FND_FLEX_VDATION_RULES_TL TL,
         FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     R.APPLICATION_ID = TL.APPLICATION_ID
         AND FST.ID_FLEX_NUM = R.ID_FLEX_NUM
         AND R.ID_FLEX_CODE = TL.ID_FLEX_CODE
         AND R.ID_FLEX_NUM = TL.ID_FLEX_NUM
         AND R.FLEX_VALIDATION_RULE_NAME = TL.FLEX_VALIDATION_RULE_NAME
         AND R.APPLICATION_ID = 101
--AND    SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('BE','LU','ES')  -- LIMITS RESULTS TO SPECIFIC CHARTS OF ACCOUNTS
--AND    LENGTH(TL.ERROR_MESSAGE_TEXT) > 150   --- THIS IS USED FOR CHECK FOR MESSAGES OVER 150 CHARACTERS THAT CAN CAUSE SQL ERRORS IN I-EXPENSES
ORDER BY 1, 2

GL Flexfield Security Rule Assignments

/* FLEXFIELD SECURITY RULE ASSIGNMENTS TO RESPONSIBILITIES
LISTS SECURITY RULE ASSIGNMENTS TO RESPONSIBILITIES*/

  SELECT A.APPLICATION_NAME, FVR.FLEX_VALUE_RULE_NAME, R.RESPONSIBILITY_KEY
    FROM FND_FLEX_VALUE_RULES      FVR,
         FND_FLEX_VALUE_RULE_USAGES RU,
         FND_RESPONSIBILITY        R,
         FND_APPLICATION_TL        A
   WHERE     FVR.FLEX_VALUE_RULE_ID = RU.FLEX_VALUE_RULE_ID
         AND RU.RESPONSIBILITY_ID = R.RESPONSIBILITY_ID
         AND RU.APPLICATION_ID = A.APPLICATION_ID
         AND FVR.FLEX_VALUE_RULE_NAME LIKE '%'
ORDER BY FLEX_VALUE_RULE_NAME

GL Flexfield Security Rule Definitions

/* FLEXFIELD SECURITY RULE DEFINITIONS
LISTS SECURITY RULE DEFINITIONS AND GL ACCOUNT RANGES*/

  SELECT A.APPLICATION_NAME                 "APPS",
         FS.SEGMENT_NAME,
         FVS.FLEX_VALUE_SET_NAME,
         FVR.FLEX_VALUE_RULE_NAME,
         FVR.PARENT_FLEX_VALUE_LOW          "PRNT L",
         FVR.PARENT_FLEX_VALUE_HIGH         "PRNT H",
         FVRL.INCLUDE_EXCLUDE_INDICATOR     "INC/EXCL",
         FVRL.FLEX_VALUE_LOW,
         FVRL.FLEX_VALUE_HIGH
    FROM FND_FLEX_VALUE_RULES     FVR,
         FND_FLEX_VALUE_SETS      FVS,
         FND_FLEX_VALUE_RULE_LINES FVRL,
         FND_ID_FLEX_SEGMENTS     FS,
         FND_APPLICATION_TL       A
   WHERE     FVR.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
         AND FVR.FLEX_VALUE_RULE_ID = FVRL.FLEX_VALUE_RULE_ID
         AND FS.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
         AND FS.APPLICATION_ID = A.APPLICATION_ID
ORDER BY A.APPLICATION_NAME,
         FS.SEGMENT_NAME,
         FVS.FLEX_VALUE_SET_NAME,
         FVR.FLEX_VALUE_RULE_NAME,
         FVR.PARENT_FLEX_VALUE_LOW,
         FVR.PARENT_FLEX_VALUE_HIGH,
         FVRL.FLEX_VALUE_LOW,
         FVRL.FLEX_VALUE_HIGH

GL FSG Report and Components Overview

/* FSG REPORTS AND COMPONENTS OVERVIEW

DETAILS DEFINITIONS OF FSG REPORTS BY COMPONENT, AND INCLUDES SEVERAL SMALL SCRIPTS FOR LISTING ALL COMPONENTS ACROSS DIFFERENT CHARTS OF ACCOUNTS.
CAN BE USED FOR SOX AND SYSTEM AUDITS. */

-- FSG REPORTS  --------------

  SELECT FST.ID_FLEX_STRUCTURE_NAME,
         R.NAME,
         R.REPORT_TITLE,
         R.DESCRIPTION,
         R.COLUMN_SET             "COLUMN SET",
         RW2.STRUCTURE_ID,
         RW2.DESCRIPTION          "COL DESC",
         R.ROW_SET                "ROW SET",
         RW.DESCRIPTION           "ROW DESC",
         R.REPORT_DISPLAY_SET     "DISPLAY SET",
         R.CONTENT_SET            "CONTENT SET",
         R.ROW_ORDER              "ROW ORDER",
         R.ROUNDING_OPTION        "RND",
         U.USER_NAME,
         U.DESCRIPTION,
         R.CREATION_DATE
    FROM RG_REPORTS_V            R,
         FND_ID_FLEX_STRUCTURES_V FST,
         FND_USER                U,
         RG_REPORT_AXIS_SETS_V   RW,
         RG_REPORT_AXIS_SETS_V   RW2
   WHERE     R.STRUCTURE_ID = FST.ID_FLEX_NUM
         AND R.ROW_SET_ID = RW.AXIS_SET_ID
         AND R.COLUMN_SET_ID = RW2.AXIS_SET_ID
         --AND SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('ES','BE','LU')
         AND R.CREATED_BY = U.USER_ID
ORDER BY 1, 2


-- FSG ROW SETS AND COLUMN SETS ----------------
  SELECT FST.ID_FLEX_STRUCTURE_NAME
             "COA",
         DECODE (RW.AXIS_SET_TYPE,  'R', 'ROW SET',  'C', 'COLUMN SET',  '##')
             "ROW/COLUMN",
         RW.NAME
             "SET NAME",
         RW.AXIS_SET_ID
    FROM RG_REPORT_AXIS_SETS_V RW, FND_ID_FLEX_STRUCTURES_V FST
   WHERE RW.STRUCTURE_ID = FST.ID_FLEX_NUM
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('ES','BE','LU')
ORDER BY 1, 2, 3

---- CONTENT SETS ------------------------

SELECT FST.ID_FLEX_STRUCTURE_NAME "COA", CS.NAME, CS.CONTENT_SET_ID
  FROM RG_REPORT_CONTENT_SETS CS, FND_ID_FLEX_STRUCTURES_V FST
 WHERE CS.STRUCTURE_ID = FST.ID_FLEX_NU
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('ES','BE','LU')


----- ROW ORDERS ---------------------------

  SELECT FST.ID_FLEX_STRUCTURE_NAME     "COA",
         RO.NAME                        "ROW ORDER",
         RO.DESCRIPTION                 "DESCRIPTION",
         RO.STRUCTURE_ID,
         RO.ROW_ORDER_ID
    FROM RG_ROW_ORDERS RO, FND_ID_FLEX_STRUCTURES_V FST
   WHERE RO.STRUCTURE_ID = FST.ID_FLEX_NUM
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('ES','BE','LU')
ORDER BY RO.NAME

GL Interface Details

/* GL INTERFACE DETAIL

SHOWS TRANSACTIONS LEVEL DETAIL WITH FULL ACCOUNTING AND STATUS INFORMATION FOR EACH LINE IN THE GL INTERFACE ACROSS MULTIPLE SETS OF BOOKS
CAN BE USED FOR SOX AND SYSTEM AUDITS.*/

  SELECT SOB.SHORT_NAME                 "BOOK",
         GLI.SET_OF_BOOKS_ID            "SOB ID",
         TRUNC (GLI.ACCOUNTING_DATE)    "GL DATE",
         GLI.CURRENCY_CODE              "CUR",
         GLI.USER_JE_CATEGORY_NAME      "JE CATEGOTY",
         GLI.USER_JE_SOURCE_NAME        "JE SOURCE",
         GLI.ENTERED_DR                 "ENT DR",
         GLI.ENTERED_CR                 "ENT CR",
         GLI.ACCOUNTED_DR               "ACC DR",
         GLI.ACCOUNTED_CR               "ACC CR",
            GLI.SEGMENT1
         || '.'
         || GLI.SEGMENT2
         || '.'
         || GLI.SEGMENT3
         || '.'
         || GLI.SEGMENT4
         || '.'
         || GLI.SEGMENT5
         || '.'
         || GLI.SEGMENT6
         || '.'
         || GLI.SEGMENT7
         || '.'
         || GLI.SEGMENT8
         || '.'
         || GLI.SEGMENT9
         || '.'
         || GLI.SEGMENT10               "ACCOUNT COMB.",
         GLI.REFERENCE1                 "REF 1",
         GLI.REFERENCE2                 "REF 2",
         GLI.REFERENCE4                 "REF 4",
         GLI.REFERENCE7                 "REF 7",
         GLI.REFERENCE10                "REF 10",
         GLI.WARNING_CODE,
         GLI.STATUS_DESCRIPTION,
         GLI.STATUS
    --SELECT GLI.REFERENCE10 "REF 10"
    --SELECT DISTINCT GLI.SEGMENT4--,GLI.SEGMENT2, GLI.SEGMENT3, SOB.SHORT_NAME, GLI.SET_OF_BOOKS_ID
    FROM GL_INTERFACE GLI, GL_SETS_OF_BOOKS SOB
   WHERE     SOB.SET_OF_BOOKS_ID(+) = GLI.SET_OF_BOOKS_ID
         --AND GLI.WARNING_CODE IS NOT NULL
         --AND GLI.STATUS <> 'P'
         AND GLI.USER_JE_SOURCE_NAME = 'PAYABLES'
--AND TRUNC(GLI.DATE_CREATED) > '01-DEC-2005'
--AND GLI.CURRENCY_CODE  = 'GBP'
--AND (GLI.ENTERED_DR <> GLI.ACCOUNTED_DR
--  OR GLI.ENTERED_CR <> GLI.ACCOUNTED_CR)
--AND GLI.USER_JE_CATEGORY_NAME = 'BILL'
--AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('BE')
--AND GLI.SEGMENT3 = '8181'
--AND GLI.STATUS_DESCRIPTION IS NOT NULL
ORDER BY 3

GL Interface Summary

/* GL INTERFACE SUMMARY

SHOWS SUMMARY BY SOURCE, BOOK, REQUEST_ID AND GROUP_ID OF THE TRANSACTIONS IN THE GL INTERFACE ACROSS MULTIPLE SETS OF BOOKS
THIS CAN BE USED FOR AD-HOC QUERIES SUCH AS MONTH AND OR TO INCLUDE IN AUTOMATED ORACLE ALERTS*/

  SELECT SOB.SHORT_NAME                  "BOOK NAME",
         GLI.USER_JE_SOURCE_NAME         "JRNL SOURCE",
         GLI.SET_OF_BOOKS_ID             "BOOKS ID"--,    TRUNC(ACCOUNTING_DATE)"GL DATE"
                                                   ,
         PERIOD_NAME                     "PERIOD",
         GLI.STATUS,
         GLI.GROUP_ID,
         GLI.REQUEST_ID,
         TRUNC (GLI.DATE_CREATED)        "CREATED DATE"--,GLI.DATE_CREATED
                                                       ,
         TRUNC (GLI.ACCOUNTING_DATE)     "GL DATE",
         COUNT (*)
    FROM GL_INTERFACE GLI, GL_SETS_OF_BOOKS SOB
   WHERE     SOB.SET_OF_BOOKS_ID(+) = GLI.SET_OF_BOOKS_ID
         --AND GLI.USER_JE_SOURCE_NAME = 'PEOPLESOFT HR'
         AND GLI.USER_JE_SOURCE_NAME = 'RECEIVABLES'
--AND TRUNC(GLI.DATE_CREATED) > '01-DEC-2005'
--AND GLI.USER_JE_SOURCE_NAME = 'PAYROLL'
--AND SUBSTR(SOB.SHORT_NAME,1,2) IN ('ES','BE','LU')
GROUP BY SOB.SHORT_NAME,
         GLI.USER_JE_SOURCE_NAME,
         GLI.SET_OF_BOOKS_ID,
         PERIOD_NAME,
         GLI.STATUS,
         GLI.GROUP_ID,
         TRUNC (GLI.DATE_CREATED),
         TRUNC (ACCOUNTING_DATE)                           --,GLI.DATE_CREATED
                                ,
         GLI.REQUEST_ID
--,GLI.DATE_CREATED
--ORDER BY GLI.DATE_CREATED

GL Mass Allocation Formula review script

/* MASS ALLOCATION FORMULA REVIEW SCRIPT

WILL SHOW THE DEFINITION OF MASS ALLOCATION BATCHES AND LINES ACROSS MULTIPLE BOOKS IN AN EASY TO READ FORMAT FOR REVIEW IN EXCEL
IT HAS BEEN WRITTEN FOR A 10 SEGMENT COA BUT CAN BE MODIFIED TO SUIT DIFFERENT STRUCTURES.*/

  SELECT FST.ID_FLEX_STRUCTURE_NAME    "CHART OF ACCOUNTS",
         GAB.VALIDATION_STATUS         "VALID?",
         GAB.NAME                      "ALLOCATION NAME",
         GAF.NAME                      "FORMULA NAME",
         GAF.FULL_ALLOCATION_FLAG      "FULL?"--,    GAF.VALIDATION_STATUS"VALID?"

                                              ,
         GAFL.LINE_NUMBER              "LINE #",
         DECODE (GAFL.LINE_NUMBER,
                 1, 'A',
                 2, 'B',
                 3, 'C',
                 4, 'T',
                 5, 'O',
                 'XXX')                "LINE",
         GAFL.AMOUNT                   "AMOUNT",
         GAFL.CURRENCY_CODE            "CURR",
            GAFL.SEGMENT1
         || '-'
         || GAFL.SEGMENT2
         || '-'
         || GAFL.SEGMENT3
         || '-'
         || GAFL.SEGMENT4
         || '-'
         || GAFL.SEGMENT5
         || '-'
         || GAFL.SEGMENT6
         || '-'
         || GAFL.SEGMENT7
         || '-'
         || GAFL.SEGMENT8
         || '-'
         || GAFL.SEGMENT9
         || '-'
         || GAFL.SEGMENT10             "ACCOUNT",
         GAFL.SEGMENT_TYPES_KEY        "SEGMENT",
         GAFL.RELATIVE_PERIOD          "PERIOD"--,    GAFL.TRANSACTION_CURRENCY"CURR"

                                               ,
         GAFL.ACTUAL_FLAG              "ACTUAL?",
         GAFL.AMOUNT_TYPE              "AMT TYPE"
    FROM GL_ALLOC_BATCHES         GAB,
         GL_ALLOC_FORMULAS        GAF,
         GL_ALLOC_FORMULA_LINES   GAFL,
         FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     GAB.ALLOCATION_BATCH_ID = GAF.ALLOCATION_BATCH_ID
         AND GAB.CHART_OF_ACCOUNTS_ID = FST.ID_FLEX_NUM
         AND GAF.ALLOCATION_FORMULA_ID = GAFL.ALLOCATION_FORMULA_ID
--AND SUBSTR(FST.ID_FLEX_STRUCTURE_CODE,1,2) IN ('BE','LU','ES')
ORDER BY 1,
         3,
         4,
         6

GL Mass Allocation Migration Script in Dataload Professional FLD format

/*  EXTRACT MASS ALLOCATIONS INTO A DATALOAD PROFESIONAL FORMAT FOR MIGRATION BETWEEN ENVIRONMENTS OR BOOKS

    THIS IS DESIGNED TO WORK WITH A 10 SEGMENT CHART OF ACCOUNTS, SO WILL NEED TO BE MODIFIED TO SUIT YOUR STRUCTURE
    THIS EXTRACT WILL ONLY WORK WITH THE FOLLOWING CONDITIONS
    1- THAT LINES B&C ARE ACCOUNTS RATHER THAN VALUES.  IF VALUES ARE USED THEN USE THE SECOND EXTRACT BELOW.
    2- THAT RELATIVE PERIOD IS CURRENT
    3- THAT AMOUNT TYPE IS ACTUAL   */
    
  SELECT GAB.NAME,
         GAF.NAME                                    "FORMULA NAME",
         'ALLOCATION',
         GAF.DESCRIPTION                             "FORMULA DESC",
         GAFL.SEGMENT1                               "S11",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 1, 1)       "T",
         GAFL.SEGMENT2                               "S12",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 3, 1)       "T",
         GAFL.SEGMENT3                               "S13",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 5, 1)       "T",
         GAFL.SEGMENT4                               "S14",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 7, 1)       "T",
         GAFL.SEGMENT5                               "S15",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 9, 1)       "T",
         GAFL.SEGMENT6                               "S16",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 11, 1)      "T",
         GAFL.SEGMENT7                               "S17",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 13, 1)      "T",
         GAFL.SEGMENT8                               "S18",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 15, 1)      "T",
         GAFL.SEGMENT9                               "S19",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 17, 1)      "T",
         GAFL.SEGMENT10                              "S110",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 19, 1)      "T",
         GAFL.CURRENCY_CODE                          "CURR",
         GAFL.AMOUNT_TYPE                            "AMT TYPE",
         GAFL2.SEGMENT1                              "S21",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL2.SEGMENT2                              "S22",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL2.SEGMENT3                              "S23",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL2.SEGMENT4                              "S24",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL2.SEGMENT5                              "S25",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL2.SEGMENT6                              "S26",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL2.SEGMENT7                              "S27",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL2.SEGMENT8                              "S28",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL2.SEGMENT9                              "S29",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL2.SEGMENT10                             "S210",
         SUBSTR (GAFL2.SEGMENT_TYPES_KEY, 19, 1)     "T",
         GAFL2.CURRENCY_CODE                         "CURR",
         GAFL2.AMOUNT_TYPE                           "AMT TYPE",
         GAFL3.SEGMENT1                              "S31",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL3.SEGMENT2                              "S32",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL3.SEGMENT3                              "S33",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL3.SEGMENT4                              "S34",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL3.SEGMENT5                              "S35",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL3.SEGMENT6                              "S36",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL3.SEGMENT7                              "S37",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL3.SEGMENT8                              "S38",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL3.SEGMENT9                              "S39",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL3.SEGMENT10                             "S310",
         SUBSTR (GAFL3.SEGMENT_TYPES_KEY, 19, 1)     "T",
         GAFL3.CURRENCY_CODE                         "CURR",
         GAFL3.AMOUNT_TYPE                           "AMT TYPE",
         GAFL4.SEGMENT1                              "S41",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL4.SEGMENT2                              "S42",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL4.SEGMENT3                              "S43",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL4.SEGMENT4                              "S44",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL4.SEGMENT5                              "S45",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL4.SEGMENT6                              "S46",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL4.SEGMENT7                              "S47",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL4.SEGMENT8                              "S48",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL4.SEGMENT9                              "S49",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL4.SEGMENT10                             "S410",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 19, 1)     "T",
         GAFL4.CURRENCY_CODE                         "CURR",
         GAFL5.SEGMENT1                              "S51",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL5.SEGMENT2                              "S52",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL5.SEGMENT3                              "S53",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL5.SEGMENT4                              "S54",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL5.SEGMENT5                              "S55",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL5.SEGMENT6                              "S56",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL5.SEGMENT7                              "S57",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL5.SEGMENT8                              "S58",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL5.SEGMENT9                              "S59",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL5.SEGMENT10                             "S510",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 19, 1)     "T"
    FROM GL_ALLOC_BATCHES         GAB,
         GL_ALLOC_FORMULAS        GAF,
         GL_ALLOC_FORMULA_LINES   GAFL,
         GL_ALLOC_FORMULA_LINES   GAFL2,
         GL_ALLOC_FORMULA_LINES   GAFL3,
         GL_ALLOC_FORMULA_LINES   GAFL4,
         GL_ALLOC_FORMULA_LINES   GAFL5,
         FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     GAB.ALLOCATION_BATCH_ID = GAF.ALLOCATION_BATCH_ID
         AND GAB.CHART_OF_ACCOUNTS_ID = FST.ID_FLEX_NUM
         AND GAF.ALLOCATION_FORMULA_ID = GAFL.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL2.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL3.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL4.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL5.ALLOCATION_FORMULA_ID
         AND GAFL.LINE_NUMBER = 1
         AND GAFL2.LINE_NUMBER = 2
         AND GAFL3.LINE_NUMBER = 3
         AND GAFL4.LINE_NUMBER = 4
         AND GAFL5.LINE_NUMBER = 5
         --AND SUBSTR(FST.ID_FLEX_STRUCTURE_CODE,1,2) IN ('DE')
         AND GAFL2.AMOUNT IS NULL
--AND GAB.NAME LIKE 'DE MAIN%'

ORDER BY 1, 2


---==========================================================================================================================

GL Mass Allocation Rule Migration Script in Dataload Classic Format

/*  EXTRACT MASS ALLOCATIONS INTO A DATALOAD PROFESIONAL FORMAT FOR MIGRATION BETWEEN ENVIRONMENTS OR BOOKS

    IT IS DESIGNED TO WORK WITH A 10 SEGMENT CHART OF ACCOUNTS, SO WILL NEED TO BE MODIFIED TO SUIT YOUR STRUCTURE
    THIS EXTRACT WILL ONLY WORK WITH THE FOLLOWING CONDITIONS
    1- THAT LINES B&C ARE VALUES NOT ACCOUNTS
    2- THAT RELATIVE PERIOD IS CURRENT
    3- THAT AMOUNT TYPE IS ACTUAL    */

  SELECT GAB.NAME,
         GAF.NAME                                    "FORMULA NAME",
         'ALLOCATION',
         GAF.DESCRIPTION                             "FORMULA DESC",
         GAFL.SEGMENT1                               "S11",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 1, 1)       "T",
         GAFL.SEGMENT2                               "S12",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 3, 1)       "T",
         GAFL.SEGMENT3                               "S13",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 5, 1)       "T",
         GAFL.SEGMENT4                               "S14",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 7, 1)       "T",
         GAFL.SEGMENT5                               "S15",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 9, 1)       "T",
         GAFL.SEGMENT6                               "S16",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 11, 1)      "T",
         GAFL.SEGMENT7                               "S17",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 13, 1)      "T",
         GAFL.SEGMENT8                               "S18",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 15, 1)      "T",
         GAFL.SEGMENT9                               "S19",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 17, 1)      "T",
         GAFL.SEGMENT10                              "S110",
         SUBSTR (GAFL.SEGMENT_TYPES_KEY, 19, 1)      "T",
         GAFL.CURRENCY_CODE                          "CURR",
         GAFL.AMOUNT_TYPE                            "AMT TYPE",
         GAFL2.AMOUNT                                "B-AMT",
         GAFL3.AMOUNT                                "C-AMT",
         GAFL4.SEGMENT1                              "S41",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL4.SEGMENT2                              "S42",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL4.SEGMENT3                              "S43",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL4.SEGMENT4                              "S44",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL4.SEGMENT5                              "S45",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL4.SEGMENT6                              "S46",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL4.SEGMENT7                              "S47",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL4.SEGMENT8                              "S48",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL4.SEGMENT9                              "S49",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL4.SEGMENT10                             "S410",
         SUBSTR (GAFL4.SEGMENT_TYPES_KEY, 19, 1)     "T",
         GAFL4.CURRENCY_CODE                         "CURR",
         GAFL5.SEGMENT1                              "S51",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 1, 1)      "T",
         GAFL5.SEGMENT2                              "S52",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 3, 1)      "T",
         GAFL5.SEGMENT3                              "S53",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 5, 1)      "T",
         GAFL5.SEGMENT4                              "S54",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 7, 1)      "T",
         GAFL5.SEGMENT5                              "S55",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 9, 1)      "T",
         GAFL5.SEGMENT6                              "S56",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 11, 1)     "T",
         GAFL5.SEGMENT7                              "S57",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 13, 1)     "T",
         GAFL5.SEGMENT8                              "S58",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 15, 1)     "T",
         GAFL5.SEGMENT9                              "S59",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 17, 1)     "T",
         GAFL5.SEGMENT10                             "S510",
         SUBSTR (GAFL5.SEGMENT_TYPES_KEY, 19, 1)     "T"
    FROM GL_ALLOC_BATCHES         GAB,
         GL_ALLOC_FORMULAS        GAF,
         GL_ALLOC_FORMULA_LINES   GAFL,
         GL_ALLOC_FORMULA_LINES   GAFL2,
         GL_ALLOC_FORMULA_LINES   GAFL3,
         GL_ALLOC_FORMULA_LINES   GAFL4,
         GL_ALLOC_FORMULA_LINES   GAFL5,
         FND_ID_FLEX_STRUCTURES_VL FST
   WHERE     GAB.ALLOCATION_BATCH_ID = GAF.ALLOCATION_BATCH_ID
         AND GAB.CHART_OF_ACCOUNTS_ID = FST.ID_FLEX_NUM
         AND GAF.ALLOCATION_FORMULA_ID = GAFL.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL2.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL3.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL4.ALLOCATION_FORMULA_ID
         AND GAF.ALLOCATION_FORMULA_ID = GAFL5.ALLOCATION_FORMULA_ID
         AND GAFL.LINE_NUMBER = 1
         AND GAFL2.LINE_NUMBER = 2
         AND GAFL3.LINE_NUMBER = 3
         AND GAFL4.LINE_NUMBER = 4
         AND GAFL5.LINE_NUMBER = 5
         AND SUBSTR (FST.ID_FLEX_STRUCTURE_CODE, 1, 2) IN ('DE')
         AND GAFL2.AMOUNT IS NOT NULL
--AND GAB.NAME LIKE 'DE MAIN%'
ORDER BY 1

GL ADI Journal Balances script

/* GL ADI JOURNAL OF OPENING BALANCES & MOVEMENTS

GIVES A TRIAL BALANCE IN ADI FORMAT FOR UPTO TEN SEGMENTS IN THE CHART OF ACCOUNTS WITH DEBIT AND CREDIT BALANCE.
THIS CAN BE USED TO EXTRACT GL BALANCES DATA FROM ONE ENVIRONMENT IN AND ADI JOURNAL FORMAT TO LOAD INTO ANOTHER ENVIRONMENT.
IT IS RECOMMENDED THAT THIS SCRIPT IS RUN FOR A SINGLE PERIOD AND BOOK FIRST TO GAUGE PERFORMANCE IN YOUR ENVIRONMENT.*/

  SELECT SOB.NAME,
         GB.PERIOD_NAME,
         GCC.SEGMENT1,
         GCC.SEGMENT2,
         GCC.SEGMENT3,
         GCC.SEGMENT4,
         GCC.SEGMENT5,
         GCC.SEGMENT6,
         GCC.SEGMENT7,
         GCC.SEGMENT8,
         GCC.SEGMENT9,
         GCC.SEGMENT10,
         (CASE
              WHEN SUM (NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)) >=
                   0
              THEN
                  (SUM (NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)))
              ELSE
                  0
          END)    "DEBIT",
         (CASE
              WHEN SUM (NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)) <=
                   0
              THEN
                  (  SUM (
                         NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0))
                   * -1)
              ELSE
                  0
          END)    "CREDIT"
    FROM GL_BALANCES GB, GL_CODE_COMBINATIONS GCC, GL_SETS_OF_BOOKS SOB
   WHERE     GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
         AND GB.ACTUAL_FLAG = 'A'
         --AND  GB.PERIOD_NAME = 'DEC-05'

         AND GB.CURRENCY_CODE = SOB.CURRENCY_CODE
         AND SUBSTR (SOB.SHORT_NAME, 1, 2) IN ('HK',
                                               'JP',
                                               'TH',
                                               'SG',
                                               'CN')
         AND GB.TEMPLATE_ID IS NULL
         AND GB.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
GROUP BY SOB.NAME,
         GB.ACTUAL_FLAG,
         GB.PERIOD_NAME,
         GCC.SEGMENT1,
         GCC.SEGMENT2,
         GCC.SEGMENT3,
         GCC.SEGMENT4,
         GCC.SEGMENT5,
         GCC.SEGMENT6,
         GCC.SEGMENT7,
         GCC.SEGMENT8,
         GCC.SEGMENT9,
         GCC.SEGMENT10,
         NVL (GB.PERIOD_NET_DR, 0),
         NVL (GB.PERIOD_NET_CR, 0)
  HAVING SUM (NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)) <> 0
ORDER BY 1,
         2,
         3,
         4,
         5,
         6,
         7,
         8,
         9

GL Autopost Definitions

/* GL AUTOPOST DEFINITIONS
LISTS THE AUTOPOST DEFINITIONS BY BOOK SHOW THE JOURNAL SOURCE AND CATEGORY*/

  SELECT SOB.NAME                           "BOOK",
         APS.AUTOPOST_SET_NAME              "SET NAME",
         APS.DESCRIPTION,
         APS.ENABLED_FLAG,
         APS.SUBMIT_ALL_PRIORITIES_FLAG     "SUBMIT ALL?",
         APO.ACTUAL_FLAG                    "ACTUAL FLAG",
         APO.PERIOD_NAME                    "PERIOD",
         APO.JE_SOURCE_NAME                 "SOURCE",
         APO.USER_JE_CATEGORY_NAME          "CATEGORY"
    FROM GL_AUTOMATIC_POSTING_SETS_V   APS,
         GL_AUTOMATIC_POSTING_OPTIONS_V APO,
         GL_SETS_OF_BOOKS              SOB
   WHERE     APO.AUTOPOST_SET_ID = APS.AUTOPOST_SET_ID
         AND APS.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
--AND SUBSTR(SOB.NAME,1,2) IN ('ES','LU','BE')

ORDER BY 1

HR Operating Unit and Legal Entity Configuration

/* LEGAL ENTITIERS & ORGANIZATIONS
GIVES AN OVERVIEW OF THE LEGAL ENTITY AND OPERATING UNIT CONFIGURATION ACROSS MULTIPLE OU
THIS IS USED WHEN IMPLEMENTING MULTIPLE OFFICES TO ENSURE CONSISTENT SETUP ACROSS COUNTRIES AND BETWEEN ENVIRONMENTS.
WHERE CLAUSE CAN BE ADDED OR COMMENTED OUT TO JUST LOOK AT SPECIFIC COUNTRIES.IF CONSISTENT NAMING CONVENTIONS HAVE BEEN USED.*/

  SELECT HRO.ORGANIZATION_ID,
         HRO.NAME,
         HOI.ORG_INFORMATION_CONTEXT,
         SOB2.NAME                "LE SET OF BOOKS"--,    HOI.ORG_INFORMATION1
                                                   ,
         HRO_LE.NAME              "OU LEGAL ENT",
         HOI.ORG_INFORMATION2     "LE VAT CODES"--,    HOI.ORG_INFORMATION3
                                                ,
         SOB.NAME                 "OU SET OF BOOKS"
    FROM HR_ALL_ORGANIZATION_UNITS_TL HRO,
         HR_ORGANIZATION_INFORMATION_V HOI,
         GL_SETS_OF_BOOKS             SOB,
         GL_SETS_OF_BOOKS             SOB2,
         HR_ALL_ORGANIZATION_UNITS_TL HRO_LE
   WHERE     HOI.ORG_INFORMATION_CONTEXT IN
                 ('LEGAL ENTITY ACCOUNTING', 'OPERATING UNIT INFORMATION')
         AND HRO.ORGANIZATION_ID = HOI.ORGANIZATION_ID
         AND TO_CHAR (SOB.SET_OF_BOOKS_ID(+)) = HOI.ORG_INFORMATION3
         AND TO_CHAR (SOB2.SET_OF_BOOKS_ID(+)) = HOI.ORG_INFORMATION1
         AND TO_CHAR (HRO_LE.ORGANIZATION_ID(+)) = HOI.ORG_INFORMATION2
--AND SUBSTR(HRO.NAME,1,2) IN ('BE','LU','ES')

ORDER BY 2, 3

Dataload .dld GL Cross Validation Rules

/* DATALOAD (DLD) FORMAT SQL EXTRACT OF CVR CROSS VALIDATION RULES
EXTRACTS CVR'S FROM ONE ENVIRONMENT IN A DATALOAD FORMAT READY TO LOAD INTO THE NEXT ENVIRONMENT USING DATALOAD CLASSIC.
NOTE : THE SEGMENTS LOW&HIGH SUBSTINGS WILL NEED UPDATING TO MATCH YOUR SPECIFIC CHART OF ACCOUNTS DEFINITIONS
 */
 
  SELECT FST.ID_FLEX_STRUCTURE_NAME
             "BOOKS",
         L.INCLUDE_EXCLUDE_INDICATOR
             "INC?",
         R.FLEX_VALIDATION_RULE_NAME
             "NAME",
         (CASE
              WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I'
              THEN
                  R.FLEX_VALIDATION_RULE_NAME
              ELSE
                  NULL
          END)
             "NAME",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE
              WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN TL.DESCRIPTION
              ELSE NULL
          END)
             "DESCRIPTION",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE
              WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN TL.ERROR_MESSAGE_TEXT
              ELSE NULL
          END)
             "MESSAGE",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE
              WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I'
              THEN
                  DECODE (R.ERROR_SEGMENT_COLUMN_NAME,
                          'SEGMENT1', 'ENTITY',
                          'SEGMENT2', 'OFFICE',
                          'SEGMENT3', 'GROUP',
                          'SEGMENT4', 'ACCOUNT',
                          'SEGMENT5', 'LOCAL',
                          'SEGMENT6', 'PARTNER',
                          'SEGMENT7', 'PROJECT',
                          'SEGMENT8', 'YEAR',
                          'XXXXX')
              ELSE
                  NULL
          END)
             "SEGMENT",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         (CASE WHEN L.INCLUDE_EXCLUDE_INDICATOR = 'I' THEN 'TAB' ELSE NULL END)
             "Z",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 0, 2)
             "1L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 0, 2)
             "1H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 4, 2)
             "2L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 4, 2)
             "2H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 7, 4)
             "3L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 7, 4)
             "3H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 12, 5)
             "4L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 12, 5)
             "4H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 18, 6)
             "5L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 18, 6)
             "5H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 25, 4)
             "6L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 25, 4)
             "6H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 30, 5)
             "7L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 30, 5)
             "7H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 36, 4)
             "8L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 36, 4)
             "8H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 41, 4)
             "9L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 41, 4)
             "9H",
         SUBSTR (L.CONCATENATED_SEGMENTS_LOW, 46, 4)
             "10L",
         SUBSTR (L.CONCATENATED_SEGMENTS_HIGH, 46, 4)
             "10H",
         'ENT',
         '*SL3',
         '*DN',
         'TAB',
         '*SL1'
    FROM FND_FLEX_VALIDATION_RULES     R,
         FND_FLEX_VDATION_RULES_TL     TL,
         FND_FLEX_VALIDATION_RULE_LINES L,
         FND_ID_FLEX_STRUCTURES_VL     FST
   WHERE     R.APPLICATION_ID = TL.APPLICATION_ID
         AND FST.ID_FLEX_NUM = R.ID_FLEX_NUM
         AND R.ID_FLEX_CODE = TL.ID_FLEX_CODE
         AND R.ID_FLEX_NUM = TL.ID_FLEX_NUM
         AND R.FLEX_VALIDATION_RULE_NAME = TL.FLEX_VALIDATION_RULE_NAME
         AND R.FLEX_VALIDATION_RULE_NAME = TL.FLEX_VALIDATION_RULE_NAME
         AND R.APPLICATION_ID = L.APPLICATION_ID
         AND R.ID_FLEX_CODE = L.ID_FLEX_CODE
         AND R.ID_FLEX_NUM = L.ID_FLEX_NUM
         AND R.FLEX_VALIDATION_RULE_NAME = L.FLEX_VALIDATION_RULE_NAME
         AND R.FLEX_VALIDATION_RULE_NAME = L.FLEX_VALIDATION_RULE_NAME
         AND R.APPLICATION_ID = 101
         AND R.ID_FLEX_CODE = 'GL#'
--AND    SUBSTR(FST.ID_FLEX_STRUCTURE_NAME,1,2) IN ('BE','LU')
--AND    R.ERROR_SEGMENT_COLUMN_NAME = 'SEGMENT5'
--AND     TL.ERROR_MESSAGE_TEXT LIKE '%LOCAL%'
--AND    SUBSTR(L.CONCATENATED_SEGMENTS_LOW,1,2)='ZZ'
ORDER BY 1,
         3,
         2 DESC,
         12,
         13,
         14,
         15,
         16,
         17,
         18,
         19,
         20,
         21,
         22,
         23,
         24,
         25,
         26,
         27,
         28,
         29,
         30


Dataload Professional .fld -- Daily Rates load

/* DAILY RATES DLD PROFESSIONAL LOAD (DATE RANGES )
EXTRACTS SPECIFIC DAILY RATES IN A DATALOAD PROFESSIONAL FILE FORMAT .FLD
TO BE USED IN CONJUNCTION WITH A PREDEFINED .FLD FILE
 */
 
  SELECT GLR.FROM_CURRENCY,
         GLR.TO_CURRENCY,
         GLR.CONVERSION_DATE           "FROM",
         GLR.CONVERSION_DATE           "TO",
         RT.USER_CONVERSION_TYPE,
         GLR.SHOW_CONVERSION_RATE      "FROM > TO",
         GLR.SHOW_INVERSE_CON_RATE     " TO > FROM(INVERSE)"
    FROM GL_DAILY_RATES_V GLR, FND_CURRENCIES C, GL_DAILY_CONVERSION_TYPES RT
   WHERE     GLR.FROM_CURRENCY = C.CURRENCY_CODE
         AND GLR.CONVERSION_TYPE = RT.CONVERSION_TYPE
         AND RT.USER_CONVERSION_TYPE LIKE 'CORPORATE'
--AND CONVERSION_DATE > TO_DATE('30-NOV-2002','DD-MON-YYYY')
--AND CONVERSION_DATE > TO_DATE('31-AUG-2006','DD-MON-YYYY')
--AND SUBSTR(GLR.CONVERSION_DATE,1,2) = '01'
--AND FROM_CURRENCY IN ('GBP')
--AND TO_CURRENCY NOT IN ('GBP')
--AND RT.USER_CONVERSION_TYPE LIKE 'THAI%'
ORDER BY 1, GLR.CONVERSION_DATE