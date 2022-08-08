 /*===================== How To Diagnose An Issue In Requester Change Order Processing ==============*/ 
 
 /*  
In analyzing issues related to change order processing, its common to need to check 
some of the background data. The diagnostics above give much of this detail, 
however to verify all related data check the output of the following
seven queries (best viewed when in delimited format);

SELECT *
  FROM po_requisition_headers_all
 WHERE requisition_header_id IN (&list_of_reqhdr_id);

SELECT *
  FROM po_requisition_lines_all
 WHERE requisition_header_id IN (&list_of_reqhdr_id);

SELECT *
  FROM po_req_distributions_all
 WHERE requisition_line_id IN (&list_of_reqline_id_fromabovesql);

SELECT *
  FROM po_headers_all
 WHERE po_header_id IN (&list_of_pohdrid)
 select * from po_action_history where object_id in (&list_of_pohdrid)
 select * from po_change_requests where document_header_id in (&list_of_pohdr_id);

SELECT *
  FROM po_change_requests
 WHERE document_header_id IN (&list_of_reqhdr_id);
 */
 
 --REQUISITION / STANDARD PO (** WARNING: Do NOT use these DATAFIX commands if Encumbrance is enabled **)

/* 1 */
UPDATE po_headers_all
   SET authorization_status = 'APPROVED',
       approved_flag = 'Y',
       change_requested_by = ''
 WHERE po_header_id = &po_header_id;

--Note: Use the po_header_id and requisition_header_id of the document having the issue. Be careful to find the correct document id in case the same PO number or requisition number is being used by different operating units. 

/* 2 */
UPDATE po_change_requests
   SET request_status = 'REJECTED'
 WHERE document_header_id = &po_header_id AND document_type = 'PO';

/* 3 */
UPDATE po_requisition_headers_all
   SET change_pending_flag = 'N'
 WHERE requisition_header_id = &requisition_header_id;

/* 4 */
UPDATE po_action_history
   SET action_code = 'REJECT', note = 'updated by datafix script'
 WHERE     object_id = &po_header_id
       AND object_type_code = 'PO'
       AND object_sub_type_code = 'STANDARD'
       AND action_code IS NULL;

/* 5 */
SELECT change_request_group_id
  FROM po_change_requests
 WHERE     document_type = 'REQ'
       AND request_status = 'PENDING'
       AND document_header_id = &requisition_header_id;

--(NOTE: pass change request groupd id to the statements below.)

/* 6 */
UPDATE po_change_requests
   SET request_status = 'REJECTED'
 WHERE request_status = 'PENDING' AND change_request_group_id = &groupid;

--If the update above fails because the group_id was not able to be found it, run the following: 


UPDATE po_change_requests
   SET request_status = 'REJECTED', change_active_flag = 'N'
 WHERE     (   (    document_type = 'REQ'
                AND document_header_id = '&req_header_id')
            OR (document_type = 'PO' AND document_header_id = '&po_header_id'))
       AND request_status NOT IN ('ACCEPTED', 'REJECTED')
       AND initiator = 'REQUESTER';



--REQUISITION / BLANKET RELEASE (** WARNING: Do NOT use these DATAFIX commands if Encumbrance is enabled **)

/* 1. Pass the po_release_id of the autocreated release */
UPDATE po_releases_all
   SET authorization_status = 'APPROVED',
       approved_flag = 'Y',
       CHANGE_REQUESTED_BY = NULL
 WHERE po_release_id = &po_release_id;

/* 2. Pass the po_release_id */
UPDATE po_line_locations_all
   SET approved_flag = 'Y'
 WHERE     po_release_id = &po_release_id
       AND po_release_id IS NOT NULL
       AND approved_flag = 'R';

/* 3. Pass the po_release_id */
UPDATE po_action_history
   SET action_code = 'NO ACTION', note = 'updated by datafix script'
 WHERE     object_id = &po_release_id
       AND object_type_code = 'RELEASE'
       AND action_code IS NULL;

/* 4. Pass the po_release_id of the Release and the req header id of the backing req. */
UPDATE po_change_requests
   SET request_status = 'REJECTED', change_active_flag = 'N'
 WHERE     (   (    DOCUMENT_TYPE = 'REQ'
                AND DOCUMENT_HEADER_ID = '&req_header_id')
            OR (    DOCUMENT_TYPE = 'RELEASE'
                AND PO_RELEASE_ID = '&po_release_id'))
       AND REQUEST_STATUS NOT IN ('ACCEPTED', 'REJECTED')
       AND INITIATOR = 'REQUESTER';



/* 5. Pass the req header id */
UPDATE po_requisition_headers_all
   SET change_pending_flag = NULL
 WHERE requisition_header_id = &requisition_header_id;

--6. Abort any related errored workflows from the workflow status monitor.

--7. Verify that the Req/PO/Release are reset to original state and that any change/cancel action taken on this fixed requisition is completing successfully.

--DEBUG LOGGING
--Since most of the processing is done via calls from workflow processes, the collection of logs depends on what is being done at the time of failure:

/*===================================================================================================*/ 