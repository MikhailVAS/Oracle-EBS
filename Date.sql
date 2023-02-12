

/* Instans Date*/
SELECT PROFILE_OPTION_VALUE
  FROM APPS.FND_PROFILE_OPTION_VALUES
 WHERE PROFILE_OPTION_ID = 125;

/* Formatted on 1/3/2023 1:39:49 PM (QP5 v5.388) Service Desk  Mihail.Vasiljev */
SELECT mmt.transaction_id        txn_id,
       mmt.transaction_date      txn_date,
       mmt.acct_period_id        txn_period_id,
       o.acct_period_id          org_period_id,
       o.period_start_date       st_date,
       o.schedule_close_date     cl_date
  FROM mtl_material_transactions mmt, org_acct_periods o
 WHERE     mmt.organization_id = o.organization_id
       AND TRUNC (o.schedule_close_date) >= TRUNC (mmt.transaction_date)
       AND TRUNC (o.period_start_date) <= TRUNC (mmt.transaction_date)
       AND mmt.transaction_date IS NOT NULL
       AND mmt.acct_period_id <> o.acct_period_id;