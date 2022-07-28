/* Необходимо удалить в розничных продажах по ФЛГ5 за 04.10.2018 № загрузки 756362
(!) Данный датафикс униферсальный и может так же удалить и обработанную загрузку, поэтому будь внимателен при использовании.*/
DECLARE
    l_file_id   NUMBER := &p_file_id;
BEGIN
    DELETE FROM XXTG.XXTG_INV_RETAIL_LINES_INT l
          WHERE l.file_id IN (SELECT h.file_id
                                FROM XXTG_INV_RETAIL_HEADERS_INT h
                               WHERE h.file_id = l_file_id);

    DBMS_OUTPUT.put_line (
           'Удалено строк в XXTG_INV_RETAIL_LINES_INT :'
        || SQL%ROWCOUNT);

    DELETE FROM XXTG.XXTG_INV_RETAIL_HEADERS_INT h
          WHERE h.file_id = l_file_id;

    DBMS_OUTPUT.put_line (
           'Удалено строк в XXTG_INV_RETAIL_HEADERS_INT :'
        || SQL%ROWCOUNT);

    COMMIT;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line (SQLCODE || ' ' || SQLERRM (SQLCODE));
END;