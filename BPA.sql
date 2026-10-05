SELECT
   pha.segment1 "BLANKET AGREEMENT NUMBER"
   ,pha.revision_num
   ,pha.creation_date "AGREEMENT CREATION DATE"
   ,plc.displayed_field "AGREEMENT TYPE"
   ,pha.authorization_status "APPROVAL STATUS"
   ,pha.blanket_total_amount "AMOUNT"
   ,pha.approved_date
   ,NVL(INITCAP(pha.closed_code),'Open') "AGREEMENT STATUS"
   ,pla.line_num "PO LINE NUMBER"
   ,pla.creation_date "LINE CREATION DATE"
   ,NVL(pla.closed_code,'Open') "LINE STATUS"
   ,hou.name "ORGANIZATION NAME"
   ,pov.segment1 "VENDOR NUMBER"
   ,pov.VENDOR_NAME
   ,pov.VENDOR_TYPE_LOOKUP_CODE "VENDOR TYPE"
   ,pvs.VENDOR_SITE_CODE
   ,pha.currency_code
   ,ppf.full_name "BUYER NAME"
   ,pha.attribute_category "CATEGORY"
   ,pha.attribute1
   ,msi.segment1 "LINE ITEM"
   ,msi.description "ITEM DESCRIPTION"
   ,mcb.segment1||'.'||mcb.segment2||'.'||mcb.segment3||'.'||mcb.segment1 "ITEM CATEGORY"
   ,pla.quantity "BA QUANTITY"
   ,pla.unit_meas_lookup_code "UOM"
   ,pla.unit_price
FROM
   apps.po_headers_all pha
   ,apps.po_lines_all pla
   ,apps.po_lookup_codes plc
   ,apps.po_vendors pov
   ,apps.po_vendor_sites_all pvs
   ,apps.per_all_people_f ppf
   ,apps.hr_operating_units hou
   ,apps.mtl_system_items_b msi 
   ,apps.mtl_categories_b mcb
WHERE 1 = 1
AND   pha.po_header_id = pla.po_header_id
AND   pha.type_lookup_code = plc.lookup_code
AND   pha.vendor_id = pov.vendor_id
AND   pov.vendor_id = pvs.vendor_id
AND   pha.vendor_site_id =pvs.VENDOR_SITE_ID
AND   pha.agent_id = ppf.person_id
AND   (SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date  )
AND   pha.org_id = hou.organization_id
AND   pla.item_id = msi.inventory_item_id
AND   msi.organization_id = 83
AND   pla.category_id = mcb.category_id
AND   plc.lookup_type = 'AGREEMENT_TYPE'
AND   pha.type_lookup_code = 'BLANKET'
AND   NVL(pha.closed_code,'OPEN') = 'OPEN'
AND   pha.authorization_status = 'APPROVED'
AND pov.VENDOR_NAME = 'Dummy Supplier'
ORDER BY pha.segment1

/* All BPA line count*/
  SELECT pha.segment1 bpa_num, pha.creation_date, COUNT (*) line_count
    FROM po.po_headers_all pha, po.po_lines_all pla
   --       , apps.po_vendors pv -- use for use for 11i
   --       , apps.po_vendor_site_all pvsa -- use for 11i
   WHERE     pha.po_header_id = pla.po_header_id
         AND pha.type_lookup_code = 'BLANKET'
         AND pha.closed_code IS NULL
GROUP BY pha.segment1, pha.creation_date;


SELECT 
    pha.segment1 AS blanket_po_num,
    pra.release_num,
    (SELECT DISTINCT a.SEGMENT1 
                                  FROM inv.mtl_system_items_b a
                                 WHERE  INVENTORY_ITEM_ID  = POL.ITEM_ID) AS Item,
                                 POL.ITEM_DESCRIPTION,
--    plla.line_location_id,
    plla.quantity AS released_quantity,
    plla.QUANTITY_RECEIVED AS QUANTITY_RECEIVED,
--    plla.ship_to_location_id,
    POL.UNIT_PRICE AS "Price IN BPA PO",
    pllA.PRICE_OVERRIDE AS "Price in PO_Release",
--    POL.*
--    plla.*
FROM 
    po_headers_all pha,
    PO_LINES_ALL POL,
    po_releases_all pra,
    po_line_locations_all plla
WHERE 
    pha.po_header_id = pra.po_header_id
    AND pra.po_release_id = plla.po_release_id
    AND pha.PO_HEADER_ID = POL.PO_HEADER_ID
AND POL.PO_LINE_ID = plla.PO_LINE_ID
    AND pha.po_HEADER_ID IN (SELECT po_header_id
                          FROM PO.po_headers_all
                         WHERE segment1 IN ('61375'))
                         ORDER BY pra.release_num

