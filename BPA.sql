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

