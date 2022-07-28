DROP TABLE BSTMVASILIEV.EGR_INFO;

CREATE TABLE BSTMVASILIEV.EGR_INFO
(
    VAT_REGISTRATION_NUM    VARCHAR2 (20) NOT NULL,
    DATE_BLOCK              VARCHAR2 (25),
    VERIFIED                VARCHAR2 (10),
    CREATION_DATE           DATE,
    DESCRIPTION             VARCHAR2 (50) 
);

TRUNCATE table BSTMVASILIEV.EGR_INFO

SELECT * FROM BSTMVASILIEV.EGR_INFO

/*=================== 20.10.19==========================*/
DECLARE
    v_proxy_str        VARCHAR2 (250);
    http_resp          UTL_HTTP.resp;
    http_req           UTL_HTTP.req;
    request_env        VARCHAR2 (32767);
    V_VALUE            VARCHAR2 (32767);
    vat_reg            VARCHAR2 (32767);
    l_step_start       NUMBER;
    l_step_end         NUMBER;
    ALL_VENDOR_COUNT   NUMBER;
BEGIN
    -- ============== Log
    -- XXTG_DEBUG_PKG.WRITE_LOG(to_char(SYSDATE, 'RRRR-MM-DD.HH24:MI:SS')||': В вставлено '||SQL%ROWCOUNT||' строк переноса ', l_module, 2);
    -- ============== Log
    /*  ============== Initial proxy  ============== */
    DBMS_OUTPUT.put_line ('Initial proxy');
    v_proxy_str :=
           'http://'
        || xxtg_fa_utility_pkg.get_param_VALUE ('XXTG_PROXY_ADDRESS')
        || '/';
    DBMS_OUTPUT.put_line ('v_proxy_str:' || v_proxy_str);
    UTL_HTTP.set_proxy (v_proxy_str, 'http://egr.gov.by');
    DBMS_OUTPUT.put_line ('Start');

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
    DBMS_OUTPUT.put_line ('ALL_VENDOR_COUNT: ' || ALL_VENDOR_COUNT);
    l_step_start := 1;
    l_step_end := 200;

    WHILE (l_step_start < ALL_VENDOR_COUNT)
    LOOP
        DBMS_OUTPUT.put_line ('Looop l_step_start:' || l_step_start);
        DBMS_OUTPUT.put_line ('Looop l_step_end:' || l_step_end);

        SELECT RTRIM (
                   XMLAGG (XMLELEMENT ("a", VAT_REGISTRATION_NUM || ',')).EXTRACT (
                       '//a[not(. = ./following-sibling::a)]/text()').getstringval (),
                   ',')
          INTO VAT_REG
          /* ===================War===================*/
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
         /* ===================War===================*/
        VAT_REG := TRIM(VAT_REG);
        l_step_start := l_step_start + 200;
        
        IF l_step_end < ALL_VENDOR_COUNT THEN
          l_step_end := l_step_end + 200;
        ELSE
          l_step_end := ALL_VENDOR_COUNT;
        END IF;
        

        DBMS_OUTPUT.put_line ('VAT_REG:' || VAT_REG);
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
        DBMS_OUTPUT.put_line ('status code:' || http_resp.status_code);
        DBMS_OUTPUT.put_line ('reason phrase:' || http_resp.reason_phrase);

--        LOOP
            UTL_HTTP.read_line (http_resp, V_VALUE, TRUE);
            DBMS_OUTPUT.PUT_LINE ('Length:' || DBMS_LOB.getlength (V_VALUE));
            DBMS_OUTPUT.PUT_LINE (DBMS_LOB.SUBSTR (V_VALUE, 254, 1));
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

               DBMS_OUTPUT.PUT_LINE (DBMS_LOB.SUBSTR (V_VALUE, 254, 1)); 
      /* Parsing with an insert */   
       INSERT INTO BSTMVASILIEV.EGR_INFO
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
--DBMS_OUTPUT.PUT_LINE ('=======================================================');
       END LOOP;
--         UTL_HTTP.end_of_body;
         DBMS_OUTPUT.put_line ('END_response');
--DBMS_LOCK.SLEEP(60);
--    END LOOP;
EXCEPTION
    WHEN UTL_HTTP.end_of_body
    THEN
        UTL_HTTP.end_response (http_resp);
        DBMS_OUTPUT.put_line ('End Response');
END;

--##############################################################################################

DECLARE
    l_output   SYS_REFCURSOR;
BEGIN
    FOR r
        IN (SELECT ei.VAT_REGISTRATION_NUM, ei.DATE_BLOCK
              --            INTO vat_num, date_block
              FROM BSTMVASILIEV.EGR_INFO ei, ap.ap_suppliers aps
             WHERE     ei.VAT_REGISTRATION_NUM = aps.VAT_REGISTRATION_NUM
                   AND DATE_BLOCK IS NOT NULL
                   AND VERIFIED IS NULL
                   AND aps.END_DATE_ACTIVE IS NULL)
    LOOP
            UPDATE ap.ap_suppliers sup
                SET sup.END_DATE_ACTIVE = TO_DATE (r.DATE_BLOCK, 'dd.mm.yyyy')
            WHERE sup.VAT_REGISTRATION_NUM = r.VAT_REGISTRATION_NUM;
    END LOOP;
    END;