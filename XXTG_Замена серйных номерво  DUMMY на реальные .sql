



-- Проверка 
SELECT * FROM inv.mtl_serial_numbers   WHERE SERIAL_NUMBER = '359145033996240';

-- Пример формулы для Excel
= "UPDATE inv.mtl_serial_numbers  SET SERIAL_NUMBER =  " & "'" & H2 & "'" &  " WHERE SERIAL_NUMBER = " & "'" & A2 & "'" &  ";"

-- Пример Обновление 

-- Service Desk 
Begin
UPDATE inv.mtl_serial_numbers  SET SERIAL_NUMBER =  '353443041958443' WHERE SERIAL_NUMBER = 'DUM507191';
-- .........................................................................
UPDATE inv.mtl_serial_numbers  SET SERIAL_NUMBER =  '356516026711742' WHERE SERIAL_NUMBER = 'DUM0000451172';
UPDATE inv.mtl_serial_numbers  SET SERIAL_NUMBER =  '356516026724547' WHERE SERIAL_NUMBER = 'DUM0000451174';
END;


-- Иногда пример удаления из строки первого и последнего символа 

SUBSTR('‡353443041958443‰',2,LENGTH('‡353443041958443‰')-1)  -- Result 353443041958443 
SUBSTR('‡‭DUM507191‬‡',2,LENGTH('‡‭DUM507191‡‬')-1);
 
 
