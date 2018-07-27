/* Проверка на незакрытые заявки , пример '31155675', - Шепелюк, Вера Сергеевна  */
  SELECT DISTINCT
         FU.USER_ID,
         mt.TRANSACTION_SET_ID,
         mt.TRANSACTION_DATE,
         msib.SEGMENT1,
         fu.USER_NAME ,
         CASE mt.ORGANIZATION_ID 
            WHEN 82 THEN 'BMW: Склад Бест' 
            WHEN 83 THEN 'BBW: Дилеры'
            WHEN 84 THEN 'BDW: Головной офис Бест'
            WHEN 85 THEN 'BHW: Организаци ведения ТМЦ'
            WHEN 86 THEN 'BSW: Подрядчики'
            ELSE 'Other warehouse'
         END as Наименованеи_склада
    FROM inv.mtl_material_transactions mt,
         APPS.fnd_user               fu,
         APPS.PER_PEOPLE_F           PER,
         inv.mtl_system_items_b      msib
   WHERE     mt.TRANSACTION_SET_ID IN ('31251697',
                                       '31298087',
                                       '31082037',
                                       '31239370',
                                       '31239424',
                                       '31233002',
                                       '31305364',
                                       '31269861',
                                       '31269603',
                                       '31155675',
                                       '31269874',
                                       '31233019')
         AND fu.EMPLOYEE_ID = PER.PERSON_ID(+)
         AND FU.USER_ID = mt.CREATED_BY
         AND msib.inventory_item_id = mt.INVENTORY_ITEM_ID
ORDER BY 2

Вот и подошел срок очищать зону отгрузки за предыдущий месяц накануне закрытия периода:
- допроводить незавершенные заявки
- скрывать и возвращать отгрузки, которые не планируеться допроводить прошлым месяцем

По факту завершения сообщайте о финале работ. Заранее спасибо за оперативность.

П.С. Не забывайте, пожалуйста, корректно скрывать все “неверные” и корректирующие транзакции на каждом складе.
