CREATE OR REPLACE PACKAGE BODY APPS.xxtg_egr_ef_processing_pkg
AS
   /******************************************************************************
        NAME:                xxtg_egr_ef_processing_pkg
        PURPOSE:        Used in eFirm auto block vendor process
        Wiki:    https://wiki.life.com.by/pages/viewpage.action?pageId=95524611
        REVISIONS:
        Ver           Date           Author           Description
        ---------   ----------      ---------------  ------------------------------------
        1.0         23.10.2019      Mihail.Vasiljev      1. Created this package.
    ******************************************************************************/

Procedure get_data_from_egr
(
    p_errbuf             out nocopy varchar2
,   p_retcode            out nocopy varchar2
)    is
    v_proxy_str        VARCHAR2 (250);
    http_resp          UTL_HTTP.resp;
    http_req           UTL_HTTP.req;
    request_env        VARCHAR2 (32767);
    V_VALUE            VARCHAR2 (32767);
    vat_reg            VARCHAR2 (32767);
    l_step_start       NUMBER;
    l_step_end         NUMBER;
    ALL_VENDOR_COUNT   NUMBER;
    l_module      CONSTANT  varchar2(255):='apps.xxtg_egr_ef_processing_pkg.get_data_from_egr';
BEGIN

    EXECUTE immediate 'TRUNCATE table XXTG.EGR_INFO';

    /*========================== Initial proxy  =========================*/
    XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' Initial proxy ', l_module, 2);
    v_proxy_str :=
           'http://'
        || xxtg_fa_utility_pkg.get_param_VALUE ('XXTG_PROXY_ADDRESS')
        || '/';
    XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' v_proxy_str:' || v_proxy_str, l_module, 2);    
    UTL_HTTP.set_proxy (v_proxy_str, 'http://egr.gov.by');
    XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' Start', l_module, 2);

    SELECT COUNT(DISTINCT(VAT_REGISTRATION_NUM))
      INTO ALL_VENDOR_COUNT
        FROM (SELECT aps.VAT_REGISTRATION_NUM
               FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
              WHERE     aps.vendor_id = apss.vendor_id
                 AND END_DATE_ACTIVE IS NULL
                 AND aps.VAT_REGISTRATION_NUM IS NOT NULL --Исключаем МОЛ-ов и остальных без УНП
                 AND COUNTRY = 'BY'
              GROUP BY aps.VAT_REGISTRATION_NUM
               HAVING COUNT (aps.VAT_REGISTRATION_NUM) = 1);  --Исключаем дубликаты
    XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' ALL_VENDOR_COUNT: ' || ALL_VENDOR_COUNT, l_module, 2);
    l_step_start := 1;
    l_step_end := 200;

    WHILE (l_step_start < ALL_VENDOR_COUNT)
    LOOP
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' Looop l_step_start:' || l_step_start, l_module, 2);
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' Looop l_step_end:' || l_step_end, l_module, 2);
     
         /* ===================Special output for UTL_HTTP.begin_request===================
             Single line output separated by commas 100000000,100000001,100000002,....*/
        SELECT RTRIM (
                   XMLAGG (XMLELEMENT ("a", VAT_REGISTRATION_NUM || ',')).EXTRACT (
                       '//a[not(. = ./following-sibling::a)]/text()').getstringval (),
                   ',')
          INTO VAT_REG
              FROM (SELECT VAT_REGISTRATION_NUM, ROWNUM rn
                FROM (SELECT DISTINCT aps.VAT_REGISTRATION_NUM
                       FROM ap.ap_suppliers aps, ap.ap_supplier_sites_all apss
                      WHERE     aps.vendor_id = apss.vendor_id
                         AND aps.END_DATE_ACTIVE IS NULL
                         AND aps.VAT_REGISTRATION_NUM IS NOT NULL --Исключаем МОЛ-ов и остальных без УНП
                         AND apss.COUNTRY = 'BY'
                      GROUP BY aps.VAT_REGISTRATION_NUM
                       HAVING COUNT (aps.VAT_REGISTRATION_NUM) = 1 --Исключаем дубликаты
                      ORDER BY VAT_REGISTRATION_NUM))
              WHERE rn BETWEEN l_step_start AND l_step_end;
         /* =================================================================================*/
        VAT_REG := TRIM(VAT_REG);
        l_step_start := l_step_start + 200;
        
        IF l_step_end < ALL_VENDOR_COUNT THEN
          l_step_end := l_step_end + 200;
        ELSE
          l_step_end := ALL_VENDOR_COUNT;
        END IF;
        

--        DBMS_OUTPUT.put_line ('VAT_REG:' || VAT_REG);
        http_req :=
            UTL_HTTP.begin_request (
                   'http://egr.gov.by/egrn/API.jsp?NM='
                || VAT_REG
                || '&'
                || '&'
                || 'MASK=0101000000000000',
                'GET',
                UTL_HTTP.http_version_1_1);
        http_resp := UTL_HTTP.get_response (http_req);
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' status code:' || http_resp.status_code, l_module, 2);
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' reason phrase:' || http_resp.reason_phrase, l_module, 2);

        UTL_HTTP.read_line (http_resp, V_VALUE, TRUE);
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' Length:' || DBMS_LOB.getlength (V_VALUE), l_module, 2);
--        DBMS_OUTPUT.PUT_LINE (DBMS_LOB.SUBSTR (V_VALUE, 254, 1));
        /* Convert to view for easy parsing
		   Before: [{"NM":800009210,"DD":"23.11.2018"}
		   After : {800009210,23.11.2018}{800009315,} */
        V_VALUE :=
            REPLACE (
                REPLACE (
                    REPLACE (
                        REPLACE (
                          REPLACE (
                            REPLACE (REPLACE (V_VALUE, '"NM":', ''),
                                     '"DD":',
                                     ''),
                            '"',
                            ''),
                          'null',
                          ''),
                        ']',
                        ''),
                    '[',
                    ''),
                '},{',
                '}{');

      /* Parsing with an insert */   
       INSERT INTO XXTG.EGR_INFO
                 SELECT REGEXP_SUBSTR (str,'[^,]+',1,1)AS VAT_REGISTRATION_NUM,
                        REGEXP_SUBSTR (str,'[^,]+',1,2) AS DATE_BLOCK,
                        NULL,
                        SYSDATE,
                        NULL
                 FROM (    SELECT REGEXP_SUBSTR (V_VALUE,'[^}{]+',1,LEVEL) str
                          FROM DUAL
                 CONNECT BY REGEXP_INSTR (V_VALUE,'}{',1,LEVEL - 1) > 0); 
        COMMIT;
         UTL_HTTP.end_response (http_resp);
         XXTG_DEBUG_PKG.WRITE_LOG('******************************************************************************', l_module, 2);
       END LOOP;
         XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||'END_response', l_module, 2);

EXCEPTION
    WHEN UTL_HTTP.end_of_body
    THEN
        UTL_HTTP.end_response (http_resp);
        XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||'END_response_EXCEPTION', l_module, 2);
end get_data_from_egr;

Procedure upd_end_data_ap_suppliers(
p_errbuf             out nocopy varchar2,
p_retcode            out nocopy varchar2
)
   is
l_output   SYS_REFCURSOR;
l_module      CONSTANT  varchar2(255):='apps.xxtg_egr_ef_processing_pkg.upd_end_data_ap_suppliers';
BEGIN
    FOR r
        IN (SELECT ei.VAT_REGISTRATION_NUM, ei.DATE_BLOCK

              FROM XXTG.EGR_INFO ei, ap.ap_suppliers aps
             WHERE     ei.VAT_REGISTRATION_NUM = aps.VAT_REGISTRATION_NUM
                   AND DATE_BLOCK IS NOT NULL
                   AND VERIFIED IS NULL
                   AND aps.END_DATE_ACTIVE IS NULL)
    LOOP
            UPDATE ap.ap_suppliers sup
                SET sup.END_DATE_ACTIVE = TO_DATE (r.DATE_BLOCK, 'dd.mm.yyyy')
            WHERE sup.VAT_REGISTRATION_NUM = r.VAT_REGISTRATION_NUM;
    XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||' УНП '||r.VAT_REGISTRATION_NUM||' заблокировано от '||r.DATE_BLOCK, l_module, 2);        
    END LOOP;
    COMMIT;
end upd_end_data_ap_suppliers;

END xxtg_egr_ef_processing_pkg;
/
