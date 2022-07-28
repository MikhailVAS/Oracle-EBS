/* Formatted on 12.03.2019 18:15:54 (QP5 v5.326) Service Desk 280834 Mihail.Vasiljev */
/* OM Order Line */
DECLARE
    CURSOR deleteProcess IS
        SELECT item_type, item_key
          FROM wf_items
         WHERE     end_date IS NULL
               AND (ITEM_TYPE = 'OEOL' OR PARENT_ITEM_TYPE = 'OEOL') /* OM Order Line*/
               AND BEGIN_DATE < SYSDATE - 80 --     and ITEM_KEY = 'put_here_item_key_for PO'
                                            ;
BEGIN
    FOR wfProcess IN deleteProcess
    LOOP
        wf_engine.AbortProcess (wfProcess.item_type, wfProcess.item_key);
        COMMIT;
    END LOOP;
END;


/* HUB Standard Approval Process */
DECLARE
    CURSOR deleteProcess IS
        SELECT item_type, item_key
          FROM wf_items
         WHERE     end_date IS NULL
               AND (ITEM_TYPE = 'XXHUBSTD' OR PARENT_ITEM_TYPE = 'XXHUBSTD') /*HUB Standard Approval Process*/
               --     and ITEM_KEY = 'put_here_item_key_for PO'
               AND BEGIN_DATE < SYSDATE - 80;
BEGIN
    FOR wfProcess IN deleteProcess
    LOOP
        wf_engine.AbortProcess (wfProcess.item_type, wfProcess.item_key);
        COMMIT;
    END LOOP;
END;


/* Expenses*/
DECLARE
    CURSOR deleteProcess IS
        SELECT *
          FROM wf_items
         WHERE     end_date IS NULL
               AND (ITEM_TYPE = 'APEXP' OR PARENT_ITEM_TYPE = 'APEXP') /*Expenses*/
               --and ROOT_ACTIVITY not like '%ERROR%'
               AND BEGIN_DATE < SYSDATE - 80;
BEGIN
    FOR wfProcess IN deleteProcess
    LOOP
        wf_engine.AbortProcess (wfProcess.item_type, wfProcess.item_key);
        COMMIT;
    END LOOP;
END;

/* XXTG ARF Approval */
DECLARE
    CURSOR deleteProcess IS
        SELECT *
          FROM wf_items
         WHERE     end_date IS NULL
               AND (ITEM_TYPE = 'XXOTFAPP' OR PARENT_ITEM_TYPE = 'XXOTFAPP') /*XXTG ARF Approval*/
               --and ROOT_ACTIVITY not like '%ERROR%'
               AND BEGIN_DATE < SYSDATE - 80;
BEGIN
    FOR wfProcess IN deleteProcess
    LOOP
        wf_engine.AbortProcess (wfProcess.item_type, wfProcess.item_key);
        COMMIT;
    END LOOP;
END;