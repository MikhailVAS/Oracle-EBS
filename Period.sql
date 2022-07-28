/* Inventory Period*/
-- If Period Status is 'Y' and Closed Date is not NULL then the closing of the INV period failed.
  SELECT ood.organization_id
             "Organization ID",
         ood.organization_code
             "Organization Code",
         ood.organization_name
             "Organization Name",
         oap.period_name
             "Period Name",
         oap.period_start_date
             "Start Date",
         oap.period_close_date
             "Closed Date",
         oap.schedule_close_date
             "Scheduled Close",
         DECODE (oap.open_flag,
                 'P', 'P - Period Close is processing',
                 'N', 'N - Period Close process is completed',
                 'Y', 'Y - Period is open if Closed Date is NULL',
                 'Unknown')
             "Period Status"
    FROM APPS.org_acct_periods oap, APPS.org_organization_definitions ood
   WHERE     oap.organization_id = ood.organization_id
         --AND (TRUNC(SYSDATE) -- Comment line if a a date other than SYSDATE is being tested.
         --AND ('01-DEC-2014' -- Uncomment line if a date other than SYSDATE is being tested.
         --  BETWEEN TRUNC(oap.period_start_date) AND TRUNC (oap.schedule_close_date))
         AND oap.period_name = 'APR-20'
ORDER BY ood.organization_id, oap.period_start_date;


/* GL and PO Period */
  SELECT sob.name
             "Set of Books",
         fnd.product_code
             "Product Code",
         ps.PERIOD_NAME
             "Period Name",
         ps.START_DATE
             "Period Start Date",
         ps.END_DATE
             "Period End Date",
         DECODE (ps.closing_status,
                 'O', 'O - Open',
                 'N', 'N - Never Opened',
                 'F', 'F - Future Enterable',
                 'C', 'C - Closed',
                 'Unknown')
             "Period Status"
    FROM APPS.gl_period_statuses ps,
         APPS.GL_SETS_OF_BOOKS  sob,
         APPS.FND_APPLICATION_VL fnd
   WHERE     ps.application_id IN (101, 201)                      -- GL and PO
         AND sob.SET_OF_BOOKS_ID = ps.SET_OF_BOOKS_ID
         AND fnd.application_id = ps.application_id
         AND ps.adjustment_period_flag = 'N'
         AND (TRUNC (SYSDATE) -- Comment line if a a date other than SYSDATE is being tested.
                              --AND ('01-DEC-2014' -- Uncomment line if a date other than SYSDATE is being tested.
                              BETWEEN TRUNC (ps.start_date)
                                  AND TRUNC (ps.end_date))
ORDER BY ps.SET_OF_BOOKS_ID, fnd.product_code, ps.start_date;

/* Find Period_id */
SELECT *
  FROM APPS.org_acct_periods
 WHERE                                                --acct_period_id = 71015
       ORGANIZATION_ID = 84 AND PERIOD_NAME = 'MAR-20';

/* Update Period in Transactions */
UPDATE inv.mtl_material_transactions
   SET ACCT_PERIOD_ID = 70017
 WHERE TRANSACTION_SET_ID = 40814977
 
