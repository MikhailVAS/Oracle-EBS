/* Просьба выгрузить отчет из Оракл - Контроль задолженности дилеров 
   -Dealer Reports - Dealer Balance Report (FINANCE)
   по задолженности дилеров на 23.12.2019г. */
SELECT v.*,
       order_return + order_return_correction     AS order_returns,
       msi.secondary_inventory_name
  FROM apps.xxtg_dealer_balance_v  v
       LEFT JOIN inv.mtl_secondary_inventories msi
           ON     v.customer_id = msi.attribute5
              AND UPPER (msi.secondary_inventory_name) NOT LIKE '%_ИНВ'
              AND msi.attribute12 = 'N'
              AND msi.organization_id NOT IN (86);

SELECT *
  FROM dealer_sales#SM ds, dealer_sales_changes#SM dc
 WHERE 1 = 1 AND ds.sale_id = dc.sale_id AND ds.IMEI = '86986041195487';

 

SELECT sal1.*
  FROM dealer_sales#SM sal1
 WHERE 1 = 1 AND sal1.IMEI = '86986041195487';