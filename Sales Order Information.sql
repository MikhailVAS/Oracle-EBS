/* Sales Order Info */
  SELECT fu.user_name,
         fu.email_address,
         ooha.header_id,
         ooha.order_number,
         TO_DATE (ooha.creation_date, 'DD-MON-YYYY HH:MI:SS:'),
         hca.account_number     Customer_Number,
         hca.account_name       customer_name,
         otta.order_category_code "Order Type",
         ooha.demand_class_code,
         hou.name               Operating_Unit,
         qph.name               PriceList,
         ooha.flow_status_code  Order_Status,
         oola.line_id,
         oola.line_number,
         oola.ordered_item,
         oola.ordered_quantity,
         oola.unit_selling_price,
         oola.flow_status_code  Line_Status,
         mp.organization_code   warehouse
    FROM apps.oe_order_headers_all    ooha,
         apps.fnd_user                fu,
         apps.oe_order_lines_all      oola,
         apps.hr_operating_units      hou,
         apps.qp_list_headers_all     qph,
         apps.hz_cust_accounts_all    hca,
         apps.oe_transaction_types_all otta,
         apps.mtl_parameters          mp
   WHERE     1 = 1
         AND ooha.header_id = oola.header_id
         AND mp.organization_id = oola.ship_from_org_id
         AND hou.organization_id = ooha.org_id
         AND ooha.price_list_id = qph.list_header_id
         AND ooha.sold_to_org_id = hca.cust_account_id
         AND ooha.order_type_id = otta.transaction_type_id
         AND ooha.created_by = fu.user_id
         AND ooha.order_number = &Order_Number
ORDER BY 3 DESC;