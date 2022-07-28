
SELECT organization_id, transaction_id, mtt.transaction_type_name, transaction_date
  FROM mtl_material_transactions mmt
  , mtl_transaction_types mtt
 WHERE transaction_date >= to_date('01102018', 'ddmmyyyy')
 and mmt.transaction_type_id = mtt.transaction_type_id
-- and (mtt.transaction_type_name in ('XXTG Sale from Srv Ctr', 'XXTG Ship Equipment Write Off', 'XXTG Sale from ScrapSub Stock', 'XXTG Ship Equipment Write Off', 'XXTG Internal Sales Write Off'))
-- and transaction_set_id in (34163334, 33986456)
 and exists (select 1  
from xla_events
where ENTITY_ID in (select ENTITY_ID from xla.xla_transaction_entities where entity_code='MTL_ACCOUNTING_EVENTS' 
and application_id = 707
and transaction_date = mmt.transaction_date 
and SOURCE_ID_INT_1 = mmt.transaction_id
and process_status_code = 'I'))