XXTG_ITEM_CREATION_HDR

/* Item Creation Web Form */
SELECT HDR.*
  FROM XXTG_ITEM_CREATION_HDR HDR, XXTG_ITEM_CREATION_ATTR_VAL ATR
 WHERE HDR.HEADER_ID = ATR.HEADER_ID AND DESCRIPTION_EN LIKE '%Kasper%'

  SELECT *
    FROM FND_FLEX_VALUES_VL gtit
        ,XXTG_ASSIGNMENTS_LIST_VL usr
        ,XXTG_ITEM_CREATION_ATTR_VAL atr
        ,FND_USER fu
   WHERE 1=1
   AND VALUE_CATEGORY = 'XXTG_GROUP_OF_ITEM'
         AND FLEX_VALUE = atr.GROUP_OF_ITEMS
         AND usr.ASSIGNMENT_ID = gtit.ATTRIBUTE10
         AND fu.EMPLOYEE_ID = usr.PERSON_ID
--         AND atr.HEADER_ID = P_HEADER_ID;

/* Find Item not assigned organization by ID Item Creation Form*/
SELECT SEGMENT1, COUNT(ORGANIZATION_ID)
  FROM inv.mtl_system_items_b
 WHERE SEGMENT1 IN
           (SELECT HDR.ITEM_CODE
             FROM XXTG_ITEM_CREATION_HDR HDR, XXTG_ITEM_CREATION_ATTR_VAL ATR
            WHERE HDR.HEADER_ID = ATR.HEADER_ID AND HDR.FILE_ID = '1006561')
GROUP BY SEGMENT1
HAVING COUNT(ORGANIZATION_ID) < 6;

/* Item Creation from ORG Assigment */
DECLARE
    p_item_id            NUMBER := 1033848;
    P_PRIMARY_UOM_CODE   VARCHAR2 (100) := 'Each';

    l_api_version        NUMBER := 1.0;
    l_init_msg_list      VARCHAR2 (2) := FND_API.G_TRUE;
    l_commit             VARCHAR2 (2) := FND_API.G_FALSE;
    l_message_list       Error_Handler.Error_Tbl_Type;
    l_return_status      VARCHAR2 (2);
    l_msg_count          NUMBER := 0;
BEGIN
    FOR rec IN (SELECT ORGANIZATION_ID, ORGANIZATION_CODE
                  FROM mtl_parameters
                 WHERE ORGANIZATION_CODE IN ('BBW',
                                             'BDW',
                                             'BDW',
                                             'BFC',
                                             'BHW',
                                             'BSW'))
    LOOP
        EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG (
            P_API_VERSION         => l_api_version,
            P_INIT_MSG_LIST       => l_init_msg_list,
            P_COMMIT              => l_commit,
            P_INVENTORY_ITEM_ID   => p_item_id,
            P_ITEM_NUMBER         => NULL,
            P_ORGANIZATION_ID     => rec.ORGANIZATION_ID,
            P_ORGANIZATION_CODE   => NULL,
            P_PRIMARY_UOM_CODE    => P_PRIMARY_UOM_CODE,
            X_RETURN_STATUS       => l_return_status,
            X_MSG_COUNT           => l_msg_count);
        DBMS_OUTPUT.put_line ('=========================================');
        DBMS_OUTPUT.put_line ('Organization:  ' || rec.ORGANIZATION_CODE);
        DBMS_OUTPUT.put_line ('Return Status: ' || l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
            DBMS_OUTPUT.put_line (
                'EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG Error Messages :');
            Error_Handler.GET_MESSAGE_LIST (x_message_list => l_message_list);

            FOR i IN 1 .. l_message_list.COUNT
            LOOP
                DBMS_OUTPUT.put_line (l_message_list (i).MESSAGE_TEXT);
            END LOOP;
        END IF;
    --       LOG('=========================================');
    END LOOP;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line (
            'Error Asign_Item : ' || SUBSTR (SQLERRM, 1, 2000));
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

/* Add item in iProcurment */
begin

inv_item_events_pvt.invoke_icx_apis( p_entity_type       => 'ITEM',
                                     p_dml_type          => 'UPDATE',
                                     p_inventory_item_id => 1034829,
                                     p_item_description  => 'Наклейка самоклейка винил Светлогорск, ул. Батова 1 ТЦ Пассаж  1400*500',
                                     p_organization_id   => 82,
                                     p_master_org_flag   => 'Y',
                                     p_commit            => TRUE
                                  );

end;


