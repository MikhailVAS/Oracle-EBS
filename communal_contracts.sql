/* Formatted (QP5 v5.326) Service Desk 355939 Mihail.Vasiljev */
SELECT *
  FROM xxtg_communal_contracts
 WHERE     END_DATE_OF_AGREEMENT < TO_DATE ('01.01.2030', 'dd.mm.yyyy')
       AND EXPENSE_TYPE IN ('Коммунальные Услуги')
       AND TO_CHAR (END_DATE_OF_AGREEMENT, 'DD.MM') = '29.02';

  /* Formatted on (QP5 v5.326) Service Desk 355939 Mihail.Vasiljev */
UPDATE xxtg_communal_contracts
   SET END_DATE_OF_AGREEMENT =
           TO_DATE (TO_CHAR (END_DATE_OF_AGREEMENT, 'dd.mm.') || '2030',
                    'dd.mm.rrrr')
 WHERE    END_DATE_OF_AGREEMENT < TO_DATE ('01.01.2030', 'dd.mm.yyyy')
       AND EXPENSE_TYPE IN ('Коммунальные Услуги')
       AND END_DATE_OF_AGREEMENT NOT IN
               (TO_DATE ('29.02.2020', 'dd.mm.yyyy'));
               
  /* Formatted on (QP5 v5.326) Service Desk 355939 Mihail.Vasiljev */
UPDATE xxtg_communal_contracts
   SET END_DATE_OF_AGREEMENT =
           TO_DATE (TO_CHAR (END_DATE_OF_AGREEMENT, 'dd.mm.') || '2030',
                    'dd.mm.rrrr')
 WHERE    END_DATE_OF_AGREEMENT < TO_DATE ('01.01.2030', 'dd.mm.yyyy')
       AND EXPENSE_TYPE IN ('Коммунальные Услуги')
       AND END_DATE_OF_AGREEMENT  IN
               (TO_DATE ('29.02.2020', 'dd.mm.yyyy'));
                