declare
to_locator_id number;
l_msg_count             NUMBER;
l_locator_exists        VARCHAR2(1);
 l_keystat_val          BOOLEAN;
 l_init                 BOOLEAN;
 l_count          NUMBER;
 l_data              VARCHAR2(4000);
 x_return_status        varchar2(100);
 x_msg_data             varchar2(1024);
 
begin
FOR rec IN ( SELECT distinct mti.TRANSACTION_INTERFACE_ID, replace(decode(loc.ATTRIBUTE_CATEGORY, 'БС', loc.ATTRIBUTE_CATEGORY || ' №', 'Репитер', loc.ATTRIBUTE_CATEGORY || ' №', '') || loc.ATTRIBUTE1, '.', '\.') || '.' || nvl(v.attribute6, 'Прочие') || '.' || DESTINATION_SUBINVENTORY to_locator
                    , DESTINATION_SUBINVENTORY, TRANSFER_ORGANIZATION
              FROM wsh_new_deliveries        d,
                   wsh_delivery_assignments  wda,
                   wsh_delivery_details      dd,
                   mtl_txn_request_headers   moh,
                   mtl_txn_request_lines     mol,
                   PO_REQUISITION_HEADERS_ALL  prh,
                   PO_REQUISITION_LINES_ALL    prl,
                   oe_order_headers_all        oh,
                   oe_order_lines_all        ol,
                   OE_ORDER_SOURCES            os,
                   fnd_flex_values_vl v,
                   fnd_flex_value_sets s,
                   hr_locations loc,
                   MTL_TRANSACTIONS_INTERFACE mti
             WHERE  dd.SOURCE_CODE = 'OE'
                    AND (wda.TYPE IN ('S', 'O') OR wda.TYPE IS NULL)
                    AND NVL (d.shipment_direction, 'O') IN ('O', 'IO')
                    AND d.delivery_type = 'STANDARD'
                    AND wda.delivery_id = d.delivery_id
                    AND wda.DELIVERY_DETAIL_ID = dd.DELIVERY_DETAIL_ID
                    AND mol.line_id(+) = dd.move_order_line_id
                    AND moh.header_id(+) = mol.header_id
                    AND prh.TYPE_LOOKUP_CODE = 'INTERNAL'
                    AND NVL (prh.transferred_to_oe_flag, 'N') = 'Y'
                    AND prh.authorization_status = 'APPROVED'
                    AND os.name = 'Internal'
                    AND oh.SOURCE_DOCUMENT_TYPE_ID = os.ORDER_SOURCE_ID
                    AND oh.orig_sys_document_ref = prh.segment1
                    AND oh.SOURCE_DOCUMENT_ID = prh.REQUISITION_HEADER_ID
                    AND dd.SOURCE_HEADER_ID = oh.header_id
                    AND prl.REQUISITION_HEADER_ID = prh.REQUISITION_HEADER_ID
                    AND prl.REQUISITION_LINE_ID = ol.SOURCE_DOCUMENT_LINE_ID    
                    AND ol.HEADER_ID = oh.header_id
                    AND v.flex_value_set_id = s.flex_value_set_id
                    AND s.flex_value_set_name = 'XXTG_INT_REQ_REASONS'
                    AND v.flex_value = nvl(prl.ATTRIBUTE4, prh.ATTRIBUTE1)
                    AND loc.location_id = prl.DELIVER_TO_LOCATION_ID
                    AND mti.source_code = 'ORDER ENTRY'
                    AND mti.transaction_date > trunc(sysdate, 'YEAR')
                    AND ol.line_id = mti.source_line_id
                    AND mti.PROCESS_FLAG=3
                    AND mti.TRANSFER_ORGANIZATION = 1369
) LOOP
   
  INV_LOC_WMS_PUB.CREATE_LOCATOR(
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => x_msg_data,
            x_inventory_location_id     => to_locator_id,
            x_locator_exists            => l_locator_exists,
            p_organization_id           => 1369,
            p_organization_code         => 'BFC',
            p_concatenated_segments     => rec.to_locator,
            p_description               => substr(rec.to_locator, 50),
            p_inventory_location_type   => 3,         -- Storage locator
            p_picking_order             => NULL,
            p_location_maximum_units    => NULL,
            p_subinventory_code         => rec.DESTINATION_SUBINVENTORY,
            p_location_weight_uom_code  => NULL,
            p_max_weight                => NULL,
            p_volume_uom_code           => NULL,
            p_max_cubic_area            => NULL,
            p_x_coordinate              => NULL,
            p_y_coordinate              => NULL,
            p_z_coordinate              => NULL,
            p_physical_location_id      => NULL,
            p_pick_uom_code             => NULL,
            p_dimension_uom_code        => NULL,
            p_length                    => NULL,
            p_width                     => NULL,
            p_height                    => NULL,
            p_status_id                 => 1, -- Default status 'Active'
            p_dropping_order            => NULL
            );
    commit;           
           
    DBMS_OUTPUT.put_line (rec.to_locator || ' - ' || to_locator_id || '. Exists - ' || l_locator_exists || ', x_return_status=' || x_return_status);

    update MTL_TRANSACTIONS_INTERFACE
    set TRANSFER_LOCATOR = to_locator_id
    where TRANSACTION_INTERFACE_ID = rec.TRANSACTION_INTERFACE_ID;
   
    commit;
END LOOP;
commit;
                   
end;   

------------------------------
declare
to_locator_id number;
l_msg_count             NUMBER;
l_locator_exists        VARCHAR2(1);
 l_keystat_val          BOOLEAN;
 l_init                 BOOLEAN;
 l_count          NUMBER;
 l_data              VARCHAR2(4000);
 x_return_status        varchar2(100);
 x_msg_data             varchar2(1024);
 
begin
FOR rec IN ( SELECT distinct mti.TRANSACTION_INTERFACE_ID, replace(loc.ATTRIBUTE_CATEGORY || ' №' || loc.ATTRIBUTE1, '.', '\.') || '.' || v.attribute6 || '.' || DESTINATION_SUBINVENTORY to_locator
                    , DESTINATION_SUBINVENTORY, TRANSFER_ORGANIZATION
              FROM wsh_new_deliveries        d,
                   wsh_delivery_assignments  wda,
                   wsh_delivery_details      dd,
                   mtl_txn_request_headers   moh,
                   mtl_txn_request_lines     mol,
                   PO_REQUISITION_HEADERS_ALL  prh,
                   PO_REQUISITION_LINES_ALL    prl,
                   oe_order_headers_all        oh,
                   oe_order_lines_all        ol,
                   OE_ORDER_SOURCES            os,
                   fnd_flex_values_vl v,
                   fnd_flex_value_sets s,
                   hr_locations loc,
                   MTL_TRANSACTIONS_INTERFACE mti
             WHERE  dd.SOURCE_CODE = 'OE'
                    AND (wda.TYPE IN ('S', 'O') OR wda.TYPE IS NULL)
                    AND NVL (d.shipment_direction, 'O') IN ('O', 'IO')
                    AND d.delivery_type = 'STANDARD'
                    AND wda.delivery_id = d.delivery_id
                    AND wda.DELIVERY_DETAIL_ID = dd.DELIVERY_DETAIL_ID
                    AND mol.line_id(+) = dd.move_order_line_id
                    AND moh.header_id(+) = mol.header_id
                    AND prh.TYPE_LOOKUP_CODE = 'INTERNAL'
                    AND NVL (prh.transferred_to_oe_flag, 'N') = 'Y'
                    AND prh.authorization_status = 'APPROVED'
                    AND os.name = 'Internal'
                    AND oh.SOURCE_DOCUMENT_TYPE_ID = os.ORDER_SOURCE_ID
                    AND oh.orig_sys_document_ref = prh.segment1
                    AND oh.SOURCE_DOCUMENT_ID = prh.REQUISITION_HEADER_ID
                    AND dd.SOURCE_HEADER_ID = oh.header_id
                    AND prl.REQUISITION_HEADER_ID = prh.REQUISITION_HEADER_ID
                    AND prl.REQUISITION_LINE_ID = ol.SOURCE_DOCUMENT_LINE_ID    
                    AND ol.HEADER_ID = oh.header_id
                    AND v.flex_value_set_id = s.flex_value_set_id
                    AND s.flex_value_set_name = 'XXTG_INT_REQ_REASONS'
                    AND v.flex_value = nvl(prl.ATTRIBUTE4, prh.ATTRIBUTE1)
                    AND loc.location_id = prl.DELIVER_TO_LOCATION_ID
                    AND mti.source_code = 'ORDER ENTRY'
                    AND mti.transaction_date > trunc(sysdate, 'YEAR')
                    AND ol.line_id = mti.source_line_id
                    AND mti.PROCESS_FLAG=3
                    AND mti.TRANSFER_ORGANIZATION = 1369
) LOOP
   
  --  DBMS_OUTPUT.put_line (rec.to_locator || ' - ' || to_locator_id || '. Exists - ' || l_locator_exists);
  INV_LOC_WMS_PUB.CREATE_LOCATOR(
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => x_msg_data,
            x_inventory_location_id     => to_locator_id,
            x_locator_exists            => l_locator_exists,
            p_organization_id           => 1369,
            p_organization_code         => 'BFC',
            p_concatenated_segments     => rec.to_locator,
            p_description               => rec.to_locator,
            p_inventory_location_type   => 3,         -- Storage locator
            p_picking_order             => NULL,
            p_location_maximum_units    => NULL,
            p_subinventory_code         => rec.DESTINATION_SUBINVENTORY,
            p_location_weight_uom_code  => NULL,
            p_max_weight                => NULL,
            p_volume_uom_code           => NULL,
            p_max_cubic_area            => NULL,
            p_x_coordinate              => NULL,
            p_y_coordinate              => NULL,
            p_z_coordinate              => NULL,
            p_physical_location_id      => NULL,
            p_pick_uom_code             => NULL,
            p_dimension_uom_code        => NULL,
            p_length                    => NULL,
            p_width                     => NULL,
            p_height                    => NULL,
            p_status_id                 => 1, -- Default status 'Active'
            p_dropping_order            => NULL
            );
    commit;           
           
    DBMS_OUTPUT.put_line (rec.to_locator || ' - ' || to_locator_id || '. Exists - ' || l_locator_exists || ', x_return_status=' || x_return_status);

    update MTL_TRANSACTIONS_INTERFACE
    set TRANSFER_LOCATOR = to_locator_id
    where TRANSACTION_INTERFACE_ID = rec.TRANSACTION_INTERFACE_ID;
   
    commit;
END LOOP;
commit;
                   
end;   

