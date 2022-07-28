
/* Status Inventory Period */
SELECT *
  FROM ORG_ACCT_PERIODS_V
 WHERE     (   (rec_type = 'ORG_PERIOD')
            OR (    rec_type = 'GL_PERIOD'
                AND period_set_name = 'XXTG_CALENDAR'
                AND accounted_period_type = '21'
                AND (PERIOD_YEAR, PERIOD_NAME) NOT IN
                        (SELECT PERIOD_YEAR, PERIOD_NAME
                           FROM ORG_ACCT_PERIODS
                          WHERE 1 = 1)
                AND end_date >= TO_DATE ('30-11-2020', 'DD-MM-YYYY')))
       AND PERIOD_NAME = 'AUG-20'


/* Проверка на не отпощеные записи*/
SELECT TRX.TRANSACTION_DATE,
       TRX.TRANSACTION_QUANTITY,
       EN.transaction_number,
       TRX.ORGANIZATION_ID,
       EV.*
  FROM xla.xla_events                 EV,
       xla.xla_transaction_entities   EN,
       inv.mtl_material_transactions  TRX
 --join xla.xla_transaction_entities EN on EN.entity_id = EV.entity_id
 --join inv.mtl_material_transactions TRX on EN.transaction_number = to_char(TRX.transaction_id)
 WHERE     event_status_code <> 'P'
       AND event_date BETWEEN TO_DATE ('01.08.2020', 'DD.MM.YYYY')
                          AND TO_DATE ('31.08.2020', 'DD.MM.YYYY')
       AND EV.application_id = 707
       AND EN.entity_id = EV.entity_id
       AND EN.transaction_number = TO_CHAR (TRX.transaction_id)
	   
--------------------------------
-- to clean interface
--------------------------------

select mti.* from inv.mtl_transactions_interface mti
where mti.transaction_date <= to_date('31.08.2020','dd.mm.yyyy')

delete from inv.mtl_transactions_interface mti -- Service Desk 308104
where mti.transaction_date <= to_date('31.08.2020','dd.mm.yyyy')

select * from inv.mtl_transaction_lots_interface mtli
where not exists (select * from inv.mtl_transactions_interface mti where mtli.transaction_interface_id = mti.transaction_interface_id)
and  LAST_UPDATE_DATE <= to_date('31.08.2020','dd.mm.yyyy')

delete from inv.mtl_transaction_lots_interface mtli -- Service Desk 308104
where not exists (select * from inv.mtl_transactions_interface mti where mtli.transaction_interface_id = mti.transaction_interface_id)
and  LAST_UPDATE_DATE <= to_date('31.08.2020','dd.mm.yyyy')

select * from inv.mtl_serial_numbers_interface msni
where not exists (select * from inv.mtl_transaction_lots_interface mtli where msni.transaction_interface_id = mtli.serial_transaction_temp_id)
and  LAST_UPDATE_DATE <= to_date('31.08.2020','dd.mm.yyyy')

delete from inv.mtl_serial_numbers_interface msni -- Service Desk 308104
where not exists (select * from inv.mtl_transaction_lots_interface mtli where msni.transaction_interface_id = mtli.serial_transaction_temp_id)
and  LAST_UPDATE_DATE <= to_date('31.08.2020','dd.mm.yyyy')

--------------------------------------
-- to clean pending transactions
--------------------------------------
select * from inv.mtl_material_transactions_temp mtt
where mtt.transaction_date <= to_date('31.08.2020','dd.mm.yyyy')

-- Service Desk 308104
delete from inv.mtl_material_transactions_temp mtt
where mtt.transaction_date <= to_date('31.08.2020','dd.mm.yyyy')

select * from inv.mtl_transaction_lots_temp mtlt
where not exists (select * from inv.mtl_material_transactions_temp mtt where mtt.transaction_temp_id = mtlt.transaction_temp_id)
and  CREATION_DATE <= to_date('31.08.2020','dd.mm.yyyy')

-- Service Desk 308104
delete from inv.mtl_transaction_lots_temp mtlt
where not exists (select * from inv.mtl_material_transactions_temp mtt where mtt.transaction_temp_id = mtlt.transaction_temp_id)
and  CREATION_DATE <= to_date('31.08.2020','dd.mm.yyyy')

select * from inv.mtl_serial_numbers_temp mst
where not exists (select * from inv.mtl_transaction_lots_temp mtlt where mtlt.serial_transaction_temp_id = mst.transaction_temp_id)
and  CREATION_DATE <= to_date('31.08.2020','dd.mm.yyyy')

-- Service Desk 308104
delete from inv.mtl_serial_numbers_temp mst
where not exists (select * from inv.mtl_transaction_lots_temp mtlt where mtlt.serial_transaction_temp_id = mst.transaction_temp_id)
and  CREATION_DATE <= to_date('31.08.2020','dd.mm.yyyy')


                   
 	
/* Formatted  (QP5 v5.326) Service Desk 308104 Mihail.Vasiljev */ 
UPDATE xla.xla_events EV
   SET EVENT_STATUS_CODE = 'P', PROCESS_STATUS_CODE = 'P'
WHERE EV.entity_id IN (SELECT entity_id
                          FROM xla.xla_transaction_entities
                         WHERE transaction_number IN ('36063750',
                                                      '36063805',
                                                      '36063806'))