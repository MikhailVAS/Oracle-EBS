/* Find all lines in Price list */
SELECT *
  FROM APPS.QP_LIST_LINES
 WHERE LIST_HEADER_ID =
       (SELECT QPHB.LIST_HEADER_ID
          FROM QP_LIST_HEADERS_B QPHB, QP_LIST_HEADERS_TL QPHT
         WHERE     QPHB.LIST_HEADER_ID = QPHT.LIST_HEADER_ID
               AND NAME = 'Sale from ScrapSub Stock Price List (BYN)'
               AND LANGUAGE = 'US')
			   
/* Updating duplicate items that do not have an end date */
UPDATE APPS.QP_LIST_LINES
   SET END_DATE_ACTIVE = TO_DATE ('26.08.2019', 'dd.mm.yyyy')
 WHERE LIST_LINE_ID IN
           (SELECT LIST_LINE_ID
              FROM qp_list_lines_v
             WHERE     LIST_HEADER_ID =
                       (SELECT QPHB.LIST_HEADER_ID
                          FROM QP_LIST_HEADERS_B   QPHB,
                               QP_LIST_HEADERS_TL  QPHT
                         WHERE     QPHB.LIST_HEADER_ID = QPHT.LIST_HEADER_ID
                               AND NAME =
                                   'Sale from ScrapSub Stock Price List (BYN)'
                               AND LANGUAGE = 'US')
                   AND END_DATE_ACTIVE IS NOT NULL
                   AND PRODUCT_ATTR_VAL_DISP IN ('GM_5_d_Gold',
                                                 'GM_5_d_Space_Gray',
                                                 'LYO-L21-B',
                                                 'LYO-L21-W',
                                                 'PMT3508_4G_D_BK',
                                                 '001006',
                                                 '001008',
                                                 '01300300115',
                                                 '01300300116'))