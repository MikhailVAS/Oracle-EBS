Internal Req

/* Formatted on 10/26/2021 10:36:13 AM (QP5 v5.326) Service Desk  Mihail.Vasiljev */
SELECT DISTINCT prh.segment1
           ir_number,
       prh.creation_date
           ir_date,
       ppf.full_name
           requestor,
       hl.location_code,
       ood.organization_code
           destination_org_code,
       ood.organization_name
           destination_org_name,
       ood1.organization_code
           source_org_code,
       ood1.organization_name
           source_org_name,
       prh.authorization_status
           ir_status    ,
           prh.ATTRIBUTE1,
           Prh.DESCRIPTION,
           prh.ATTRIBUTE_CATEGORY
FROM   po_requisition_headers_all prh,
po_requisition_lines_all prl,
per_all_people_f ppf,
hr_locations hl,
org_organization_definitions ood,
org_organization_definitions ood1
WHERE 1=1
AND   prh.segment1                     =   '115735' --Internal Req
AND   prh.requisition_header_id        =   prl.requisition_header_id
AND   prl.to_person_id                 =   ppf.person_id
AND   ppf.effective_end_date           >   sysdate
AND   prl.deliver_to_location_id       =   hl.location_id(+)
AND   prl.destination_organization_id  =   ood.organization_id
AND   prl.source_organization_id       =   ood1.organization_id
--AND prh.creation_date BETWEEN TO_DATE ('01.01.2021 00:00:00', 'dd.mm.yyyy hh24:mi:ss')  AND TO_DATE ('31.12.2021 23:59:00', 'dd.mm.yyyy hh24:mi:ss') 

/*  Change of payment terms in internal requisition(QP5 v5.388) Service Desk 666305 Mihail.Vasiljev */
UPDATE po_requisition_headers_all
   SET ATTRIBUTE7 = '11285'
 WHERE segment1 IN ('128744', '128745')

/* Find Internal Requisition by material transaction  */
SELECT ORIG_SYS_DOCUMENT_REF     AS "Internal Req"
  FROM oe_order_headers_all oeh, mtl_material_transactions mmt
 WHERE     mmt.TRANSACTION_SOURCE_ID = oeh.SOURCE_DOCUMENT_ID
       AND mmt.transaction_id = '47242030'

CREATE TABLE XXTG.ABC(
    ITEM VARCHAR2(50) NOT NULL, 
    SYBINVENTORY VARCHAR2(50) NOT NULL,
    LOT VARCHAR2(50) NOT NULL,
    DATE_RICEIPT date 
);

/* Delete Last simbol in item*/
UPDATE XXTG.ABC
   SET ITEM = SUBSTR (ITEM, 1, LENGTH (ITEM) - 1) 

/* Find all IR by Item,Lot,Subinv */
SELECT TT.ITEM,
       TT.SYBINVENTORY,
       TT.LOT,
       TT.DATE_RICEIPT,
       (SELECT LISTAGG (oeh.ORIG_SYS_DOCUMENT_REF, ', ')
                   WITHIN GROUP (ORDER BY oeh.ORIG_SYS_DOCUMENT_REF)
                   AS IR
          FROM MTL_MATERIAL_TRANSACTIONS  MMT,
               MTL_TRANSACTION_LOT_VAL_V  MTLV,
               MTL_SYSTEM_ITEMS_B         MSIB,
               oe_order_headers_all       oeh
         WHERE     MMT.ORGANIZATION_ID = MSIB.ORGANIZATION_ID
               AND MMT.INVENTORY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
               AND mmt.TRANSACTION_SOURCE_ID = oeh.SOURCE_DOCUMENT_ID
               AND MMT.TRANSACTION_ID = MTLV.TRANSACTION_ID(+)
               AND MSIB.SEGMENT1 = TT.ITEM
               AND MMT.SUBINVENTORY_CODE = TT.SYBINVENTORY
               AND MTLV.LOT_NUMBER = TT.LOT
--               AND MMT.TRANSACTION_DATE = TT.DATE_RICEIPT
                                           )
           AS IR
  FROM XXTG.ABC TT

/* Formatted on 1/30/2019 4:34:50 PM (QP5 v5.227.12220.39754)*/
SELECT nd.NAME,
       nd.SOURCE_HEADER_ID ,
       nd.*,
       wdd.*,
       wda.*
  FROM APPS.wsh_delivery_details wdd,
       APPS.wsh_delivery_assignments wda,
       apps.wsh_new_deliveries nd
 WHERE        wda.delivery_detail_id = wdd.delivery_detail_id
          AND WDA.DELIVERY_ID = nd.DELIVERY_ID
       -- AND wdd.DELIVERY_DETAIL_ID in (555779,558771) -- Сведения
       AND nd.NAME = 'ИА 0169246' -- Имя доставки 
 
/*header_id берем из предыдущего запроса */
SELECT La.shipped_quantity, -- Сколько Отгружено
       La.ordered_quantity, -- Сколько заказано 
       La.line_number,
       h.order_number,
       La.*
  FROM ont.OE_ORDER_LINES_all La, ont.oe_order_headers_all h
 WHERE 1 = 1 AND La.header_id = H.HEADER_ID AND La.header_id = 279673
 
 
 /*https://support.oracle.com/epmos/
 faces/DocumentDisplay?_afrLoop=456553295078151&id=754276.1&_afrWindowMode=0&_adf.ctrl-state=c25acj0oz_4*/
 
 /* Trip Stop падает с ошибкой и не переводит с DefShpSub на Склад */
UPDATE wsh_delivery_Details
   SET oe_interfaced_flag = 'Y'
WHERE source_line_id IN
           (  SELECT dd.source_line_id line_id
                FROM wsh_delivery_Details      dd,
                     wsh_delivery_assignments_v da,
                     wsh_delivery_legs         dg,
                     wsh_new_deliveries        dl,
                     wsh_trip_stops            st,
                     oe_order_lines_all        ol
               WHERE     st.stop_id = dg.pick_up_stop_id
                     AND st.batch_id =
                         (SELECT batch_id
                            FROM wsh_trip_stops
                           WHERE trip_id = :trip_idd AND batch_id IS NOT NULL)
                     AND st.stop_location_id = dl.initial_pickup_location_id
                     AND dg.delivery_id = dl.delivery_id
                     AND dl.delivery_id = da.delivery_id
                     AND da.delivery_detail_id = dd.delivery_detail_id
                     --  and nvl ( dd.oe_interfaced_flag , 'N' )  <> 'Y'
                     AND dd.source_code = 'OE'
                     AND dd.released_status <> 'D'
                     AND ol.line_id = dd.source_line_id
                     AND dd.client_id IS NULL -- LSP PROJECT : Should not perform OM interface for LSP orders
            GROUP BY dd.source_header_id,
                     dd.source_line_id,
                     dd.top_model_line_id,
                     dd.ship_set_id,
                     dd.arrival_set_id,
                     dl.initial_pickup_date,
                     dd.requested_quantity_uom,
                     dd.requested_quantity_uom2,
                     ol.flow_status_code,
                    ol.ordered_quantity,
                     ol.ordered_quantity2,
                     ol.org_id);


/* Formatted AM (QP5 v5.326) Service Desk 318501  Mihail.Vasiljev */
/* Не комплектуется заказ */
UPDATE APPS.MTL_TXN_REQUEST_LINES
   SET QUANTITY = QUANTITY_DETAILED,
       QUANTITY_DETAILED = QUANTITY_DETAILED,
       PRIMARY_QUANTITY = QUANTITY_DETAILED,
       SECONDARY_QUANTITY = QUANTITY_DETAILED
 WHERE line_id IN
           (SELECT c.line_id --, h.REQUEST_NUMBER, c.header_id,  c.PRIMARY_QUANTITY, c.quantity, c.quantity_detailed
              FROM APPS.mtl_txn_request_lines    c,
                   APPS.mtl_txn_request_headers  h
             WHERE     1 = 1
                   AND quantity_detailed > 0
                   AND ROUND (c.QUANTITY, 5) !=
                       ROUND (c.quantity_detailed, 5)
                   AND c.DATE_REQUIRED > SYSDATE - 200
                   AND h.header_id = c.header_id);
				   
/* Find all info in value set by value set name */
SELECT ffvs.flex_value_set_id,
       ffvs.flex_value_set_name,
       ffvs.description     set_description,
       ffvs.validation_type,
       ffv.flex_value_id,
       ffv.flex_value,
       ffvt.flex_value_meaning,
       ffvt.description     value_description
  FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
 WHERE     ffvs.flex_value_set_id = ffv.flex_value_set_id
       AND ffv.flex_value_id = ffvt.flex_value_id
       AND ffvt.language = 'RU'--USERENV ('LANG')
       AND ffvs.flex_value_set_id =
           (SELECT DISTINCT FLEX_VALUE_SET_ID
              FROM applsys.fnd_flex_value_sets fvs
             WHERE fvs.flex_value_set_name =
                   NVL (UPPER ('' || :FLEX_FIELD_VALUE_NAME || ''), -- for example XXTG_INT_REQ_REASONS
                        flex_value_set_name));
--                        AND ffvt.description LIKE '%Выдача%' 

/*  Formatted (QP5 v5.294) Service Desk 418686 Mihail.Vasiljev */
UPDATE PO.PO_REQUISITION_HEADERS_all
   SET ATTRIBUTE1 = 'MOVE_TO_MRP'
-- select ATTRIBUTE1 from PO.PO_REQUISITION_HEADERS_all
 WHERE 1 = 1 AND SEGMENT1 IN (102236)

/*  Formatted (QP5 v5.294) Service Desk 418686 Mihail.Vasiljev  */
UPDATE po.PO_REQUISITION_LINES_all
   SET REFERENCE_NUM = 'MOVE_TO_MRP',
                               ATTRIBUTE_CATEGORY = NULL, ATTRIBUTE4 = NULL
 -- select REFERENCE_NUM, ATTRIBUTE_CATEGORY, ATTRIBUTE4 from po.PO_REQUISITION_LINES_all
 WHERE REQUISITION_HEADER_ID IN (SELECT REQUISITION_HEADER_ID
                                   FROM PO.PO_REQUISITION_HEADERS_all
                                  WHERE SEGMENT1 IN (102236))