

-- Проверка 

SELECT * 
FROM xxtg_gl001_double_global dg
where 
c_doc_id=1631621 


SELECT * FROM xxtg_gl001_double_global dg WHERE dg.D_DOC_NUM LIKE '%Бухгалтерская справка  01112015005'

SELECT * FROM xxtg_gl001_double_global dg WHERE dg.D_DOC_NUM ='Исправление аналитики по бухг.справке 01112015005 (4)'

SELECT * FROM APPS.gl_je_lines WHERE je_header_id=1631621  --and je_line_num=2


--- Загрузка Анлаитики по Кт в ручной журнал

-- Service Desk 144170	Head
UPDATE xxtg_gl001_double_global SET 
   c_an_code_1='14637',
   c_an_code_2='1006003',
   c_an_code_3='10101',
   c_an_desc_1='- Неверное значение : 14637',
   c_an_desc_2='Литература и бланки (сч.10)',
   c_an_desc_3='50025 226910 Контрольный (ид.) знак '|| CHR(039) || 'Моб.Тел.' || CHR(039) || '(импорт), 17х18'
WHERE  c_doc_id=1631621 

-- Service Desk 144170	Line
UPDATE APPS.gl_je_lines SET 
   attribute1='14637',
   attribute2='1006003',
   attribute3='10101'
WHERE je_header_id=1631621  and je_line_num=2