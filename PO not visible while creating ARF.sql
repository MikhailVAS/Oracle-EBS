/* Проверка на подстановку PO при создании ARF */
  SELECT pha.po_header_id,
         pha.segment1
             AS po_number,
         pv.vendor_name,
         pv.vat_registration_num,
         pha.vendor_id,
         ROUND (SUM ((pll.QUANTITY - pll.QUANTITY_RECEIVED) * pol.unit_price))
             AS open_amount,
         pha.currency_code,
         NULL
             payment_category,pha.TERMS_ID,pha.CLOSED_CODE
    FROM PO_HEADERS_ALL       pha,
         PO_LINES_ALL         pol,
         PO_LINE_LOCATIONS_ALL pll,
         ap_suppliers         pv
   WHERE     pha.po_header_id = pol.po_header_id
         AND pol.po_line_id = pll.po_line_id
         AND NVL (pll.cancel_flag, 'N') <> 'Y'
         AND 0 <
             (SELECT SUM (pll.QUANTITY - pll.QUANTITY_RECEIVED)
                FROM PO_LINES_ALL pol, PO_LINE_LOCATIONS_ALL pll
               WHERE     pha.po_header_id = pol.po_header_id
                     AND pol.po_line_id = pll.po_line_id
                     AND NVL (pll.cancel_flag, 'N') <> 'Y')
         AND pha.CLOSED_CODE = 'OPEN'                              -- OEBS-984
         AND EXISTS
                 (SELECT 1
                    FROM AP_TERMS_LINES tl
                   WHERE tl.DUE_DAYS = 0 AND tl.TERM_ID = pha.TERMS_ID) -- OEBS-984
         AND pv.VENDOR_ID = pha.VENDOR_ID
         AND VENDOR_NAME = 'Деловая сеть СП ООО' ---<<<< ИМЯ
GROUP BY pha.po_header_id,
         pha.segment1,
         pv.vendor_name,
         pv.vat_registration_num,
         pha.vendor_id,
         pha.currency_code,
         pha.TERMS_ID,
         pha.CLOSED_CODE