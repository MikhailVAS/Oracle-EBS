 /* Вычисляет значения на форме Наличное/Доступное процедура inv_quantity_tree_pub.query_quantities,
  но внутри процедуры еще есть код который еще отдельно смотрит на APPS.MTL_RESERVATIONS по ID документа */
  
DELETE APPS.MTL_RESERVATIONS
 WHERE RESERVATION_ID = :RESERVATION_ID
 

SELECT *
  FROM MTL_ONHAND_QUANTITIES
 WHERE     INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013520419')
       AND SUBINVENTORY_CODE IN ('ФЛГ5_ЦО', 'ФЛГ11Scrap')
 

SELECT *
  FROM MTL_ONHAND_QUANTITIES_DETAIL
 WHERE     INVENTORY_ITEM_ID = (SELECT DISTINCT INVENTORY_ITEM_ID
                                  FROM inv.mtl_system_items_b a
                                 WHERE SEGMENT1 = '1013520419')
       AND SUBINVENTORY_CODE IN ('ФЛГ5_ЦО', 'ФЛГ11Scrap')


 /* Material Work Branch check API */
DECLARE
    v_api_return_status   VARCHAR2 (1);
    v_qty_oh              NUMBER;
    v_qty_res_oh          NUMBER;
    v_qty_res             NUMBER;
    v_qty_sug             NUMBER;
    v_qty_att             NUMBER;
    v_qty_atr             NUMBER;
    v_msg_count           NUMBER;
    v_msg_data            VARCHAR2 (1000);
    v_inventory_item_id   VARCHAR2 (250) := '1057817'; -- Item ID (SELECT DISTINCT INVENTORY_ITEM_ID FROM inv.mtl_system_items_b  WHERE SEGMENT1 = '1013071236')
    v_organization_id     VARCHAR2 (10) := '84';       -- Organization item ID
BEGIN
    inv_quantity_tree_grp.clear_quantity_cache;
    DBMS_OUTPUT.put_line ('Transaction Mode');
    DBMS_OUTPUT.put_line ('Onhand For the Item_ID :' || v_inventory_item_id);
    DBMS_OUTPUT.put_line ('Organization        :' || v_organization_id);
    apps.INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES (
        p_api_version_number    => 1.0,
        p_init_msg_lst          => apps.fnd_api.g_false,
        x_return_status         => v_api_return_status,
        x_msg_count             => v_msg_count,
        x_msg_data              => v_msg_data,
        p_organization_id       => v_organization_id,
        p_inventory_item_id     => v_inventory_item_id,
        p_tree_mode             =>
            apps.inv_quantity_tree_pub.g_transaction_mode,
        p_onhand_source         => 3,
        p_is_revision_control   => FALSE,
        p_is_lot_control        => FALSE,
        p_is_serial_control     => FALSE,
        p_revision              => NULL,
        p_lot_number            => NULL,
        p_subinventory_code     => NULL, 
        p_locator_id            => NULL,
        x_qoh                   => v_qty_oh,
        x_rqoh                  => v_qty_res_oh,
        x_qr                    => v_qty_res,
        x_qs                    => v_qty_sug,
        x_att                   => v_qty_att,
        x_atr                   => v_qty_atr);
    DBMS_OUTPUT.put_line ('on hand Quantity                :' || v_qty_oh);
    DBMS_OUTPUT.put_line ('Reservable quantity on hand     :' || v_qty_res_oh);
    DBMS_OUTPUT.put_line ('Quantity reserved               :' || v_qty_res);
    DBMS_OUTPUT.put_line ('Quantity suggested              :' || v_qty_sug);
    DBMS_OUTPUT.put_line ('Quantity Available To Transact  :' || v_qty_att);
    DBMS_OUTPUT.put_line ('Quantity Available To Reserve   :' || v_qty_atr);
END;