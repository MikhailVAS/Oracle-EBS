This is the query to find out the purchase order number from requisition number

select  distinct pha.segment1 from po_headers_all pha,po_distributions_all pda,po_req_distributions_all rda,
po_requisition_headers_all rha,po_requisition_lines_all rla where
pha.po_header_id=pda.po_header_id and
pda.req_distribution_id=rda.distribution_id and
rda.requisition_line_id=rla.requisition_line_id and
rla.requisition_header_id=rha.requisition_header_id and
rha.segment1='&Requisition'

You can also find out the requisition number from purchase order number by using query given below

select distinct rha.segment1 from po_requisition_headers_all rha,po_requisition_lines_all rla,
po_req_distributions_all rda,po_distributions_all pda,po_headers_all pha where
rha.requisition_header_id=rla.requisition_header_id and
rla.requisition_line_id=rda.requisition_line_id and
rda.distribution_id=pda.req_distribution_id and
pda.po_header_id=pha.po_header_id and
pha.segment1='&PO_Number'