/*Lov PR in Cash Flow DCR Planed payment card*/

SELECT h.REQUISITION_HEADER_ID, h.segment1, h.description, l.need_by_date, l.REQUISITION_LINE_ID,
    poh.segment1 po_number, ven.vendor_name, poh.currency_code,  IVC.CONTRAT_NO CONTRACT_NO, ATR.NAME TERM_NAME, poh.comments po_description
,poh.PO_HEADER_ID, pol.QUANTITY*pol.UNIT_PRICE PO_AMOUNT, h.ATTRIBUTE8 tax_code
    FROM Po_Requisition_Lines_All l, Po_Requisition_Headers_All h
    , XXTG_CASH_FLOW_BUDGET_ITEM_V b1, XXTG_CASH_FLOW_BUDGET_ITEM_V b2
    , po_req_distributions_all prd  
    , PO.PO_HEADERS_ALL             POH
    , PO.PO_LINES_ALL               POL
    , PO.PO_DISTRIBUTIONS_ALL       POD
    , PO.PO_LINE_LOCATIONS_ALL      PLL
    , APPS.AP_TERMS_VL              ATR
    , APPS.PO_VENDORS               VEN
    , APPS.XXTG_INVOICE_CONTRACT_V  IVC        
    WHERE  h.Requisition_Header_Id = l.Requisition_Header_Id
    and h.AUTHORIZATION_STATUS(+) = 'APPROVED'
    and h.creation_date >= sysdate - 730
    and l.NEED_BY_DATE >= :XXTG_PLAN_DCR_HDR.CARD_DCR_PLN_DATE-93 
    and b1.BUDGET_CODE_ID = nvl(l.Attribute9, h.Attribute9)
    and prd.Requisition_line_Id = l.Requisition_line_Id
    and b2.BUDGET_CODE_ID = :XXTG_PLAN_DCR_HDR.DCR_BUDGET_ITEM_ID
    and b1.BUDGET_CODE = b2.BUDGET_CODE
    and POD.REQ_DISTRIBUTION_ID(+) = prd.DISTRIBUTION_ID
    AND POD.PO_LINE_ID = PLL.PO_LINE_ID(+)
    AND POD.PO_LINE_ID = POL.PO_LINE_ID(+)
    AND NVL(POL.CANCEL_FLAG, 'N') = 'N'
/*    and (nvl(POD.QUANTITY_BILLED,0) < nvl(POD.QUANTITY_DELIVERED,0) or nvl(POD.QUANTITY_BILLED,0) = 0)*/
    AND POD.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID(+)
    AND NVL(POH.TYPE_LOOKUP_CODE, 'STANDARD') = 'STANDARD'
    AND NVL(POH.AUTHORIZATION_STATUS, 'OPEN') not in ('CANCELLED','REJECTED','RETURNED')
    AND POH.PO_HEADER_ID(+) = POL.PO_HEADER_ID
    AND POH.TERMS_ID = ATR.TERM_ID(+)
    AND POH.VENDOR_ID = VEN.VENDOR_ID(+)    
    AND nvl(POH.VENDOR_ID, -1) = decode(:XXTG_PLAN_DCR_HDR.DCR_VENDOR_DESC, 'Multiple Vendor', nvl(POH.VENDOR_ID, -1), nvl(:XXTG_PLAN_DCR_HDR.DCR_VENDOR_ID, nvl(POH.VENDOR_ID, -1)))
    AND POH.ATTRIBUTE1 = to_char(IVC.CONTRACT_ID(+))
order by 2,4