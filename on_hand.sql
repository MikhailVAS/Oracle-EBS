/* Formatted on 22.05.2022 20:55:40 (QP5 v5.326) Service Desk Mihail.Vasiljev */
DECLARE
    x_return_status         VARCHAR2 (50);
    x_msg_count             VARCHAR2 (50);
    x_msg_data              VARCHAR2 (50);
    v_inv_item_id           NUMBER;
    v_org_id                NUMBER;
    v_qty_on_hand           NUMBER;
    v_res_qty_on_hand       NUMBER;
    v_atreserve             NUMBER;
    v_attransact            NUMBER;
    v_qty_reserve           NUMBER;
    v_qty_sugstd            NUMBER;
    v_lot_control_code      BOOLEAN;
    v_serial_control_code   BOOLEAN;
BEGIN                                               -- Set the variable values
    v_inv_item_id := :item_id;
    v_org_id := :org_id;
    v_qty_on_hand := NULL;
    v_res_qty_on_hand := NULL;
    v_atreserve := NULL;
    v_lot_control_code := FALSE;
    v_serial_control_code := FALSE;                             -- org context
    fnd_client_info.set_org_context (1);                        -- Calling API
    inv_quantity_tree_pub.query_quantities (
        p_api_version_number    => 1.0,
        p_init_msg_lst          => 'F',
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_organization_id       => v_org_id,
        p_inventory_item_id     => v_inv_item_id,
        p_tree_mode             =>
            apps.inv_quantity_tree_pub.g_transaction_mode,
        p_is_revision_control   => FALSE,
        p_is_lot_control        => v_lot_control_code,
        p_is_serial_control     => v_serial_control_code,
        p_revision              => NULL,
        p_lot_number            => NULL,
        p_lot_expiration_date   => SYSDATE,
        p_subinventory_code     => NULL,
        p_locator_id            => NULL,
        p_onhand_source         => 3,
        x_qoh                   => v_qty_on_hand,
        x_rqoh                  => v_res_qty_on_hand,
        x_qr                    => v_qty_reserve,
        x_qs                    => v_qty_sugstd,
        x_att                   => v_attransact,
        x_atr                   => v_atreserve);
    COMMIT;
    DBMS_OUTPUT.put_line ('On-Hand Quantity: ' || v_qty_on_hand);
    DBMS_OUTPUT.put_line ('Quantity Reserved: ' || v_qty_reserve);
    DBMS_OUTPUT.put_line ('Quantity Suggested: ' || v_qty_sugstd);
    DBMS_OUTPUT.put_line ('Available to Transact: ' || v_attransact);
    DBMS_OUTPUT.put_line ('Available to Reserve: ' || v_atreserve);
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
END;