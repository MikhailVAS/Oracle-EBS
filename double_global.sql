/* Find all account by  transaction in double_global*/
SELECT                                                            --distinct
        ENTERED_AMOUNT,
        ACCOUNTED_AMOUNT,
        D_ACCOUNTING_DATE,
        C_ACCOUNTING_DATE,
        D_AN_DESC_1,
        C_AN_DESC_3,
        ENTERED_AMOUNT,
        g1.C_DOC_NUM,
        g1.d_DOC_NUM,
        g1.*
  FROM xxtg.xxtg_gl001_double_global g1
  WHERE 1 = 1 -- and ENTERED_AMOUNT in( 233.62, 518.24, 206.41, 359.65)
              -- and ACCOUNTED_AMOUNT in (472.08, 1734.54, 52.62, 58.06 )
              --and (C_DOC_NUM in ( '(32691879)') or d_DOC_NUM in ( '(32691879)')) -- Transaction Set ID or Header
              AND (C_DOC_ID IN ('34148105') OR d_DOC_ID IN ('34148105')) -- Transaction_ID or GL_HEADER (JE_HEADER_ID)
-- and (D_SEGMENT2 like '0028' or c_SEGMENT2 like '0028')
-- and (D_SEGMENT2 like '%014' or c_SEGMENT2 like '%014')
--and (D_SEGMENT2 like '4106' and c_SEGMENT2 like '1024')
-- and D_SEGMENT2 like '00%'
-- and c_SEGMENT2 like '00%'
-- and (D_AN_DESC_3 like ('%1006008345%') or c_AN_DESC_3 like ('%1006008345%'))
-- and D_ACCOUNTING_DATE = to_date ('01.07.2016','.dd.mm.yyyy')
-- and D_ACCOUNTING_DATE between to_date ('01.03.2018','.dd.mm.yyyy') and to_date ('31.03.2018','.dd.mm.yyyy')
ORDER BY                                                  
         g1.D_ACCOUNTING_DATE,
         g1.ENTERED_AMOUNT,
         g1.DOUBLE_GLOBAL_ID,
         g1.C_DOC_NUM
		 

/* Find all account by  Internal Order in double_global*/
SELECT                                                             
       g1.*
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE (   C_DOC_ID IN (SELECT TRANSACTION_ID
                          FROM inv.mtl_material_transactions mt
                         WHERE TRANSACTION_SOURCE_ID = '1489727' -- Source 256781.BeST Internal.ORDER ENTRY
                                                                )
        OR d_DOC_ID IN (SELECT TRANSACTION_ID
                          FROM inv.mtl_material_transactions mt
                         WHERE TRANSACTION_SOURCE_ID = '1489727' -- Source 256781.BeST Internal.ORDER ENTRY
                                                                ))		 
		 
/* Find all account by  transaction in double_global*/
  SELECT                                                            --distinct
         ENTERED_AMOUNT,
         D_ACCOUNTING_DATE,
         C_ACCOUNTING_DATE,
         D_AN_DESC_1,
         C_AN_DESC_3,
         ENTERED_AMOUNT,
         C_DOC_ID, --Transaction_ID
         D_DOC_ID, --Transaction_ID
         g1.C_DOC_NUM,  --Transaction Set ID or Header
         g1.d_DOC_NUM,  --Transaction Set ID or Header
         g1.*
    FROM xxtg.xxtg_gl001_double_global g1
   WHERE  (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))  -- Inventory
               and D_ACCOUNTING_DATE between to_date ('01.10.2019','.dd.mm.yyyy') and to_date ('31.10.2019','.dd.mm.yyyy') 


/* Check double_global DefShpSub
Firs   Dt Amount
Second Ct Amount */

SELECT                                                              
      SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND D_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.10.2019', '.dd.mm.yyyy')
                                 AND TO_DATE ('31.10.2019', '.dd.mm.yyyy')
UNION ALL 
SELECT                                                              
       SUM(ENTERED_AMOUNT)
  FROM xxtg.xxtg_gl001_double_global g1
 WHERE     (D_APPL_ID IN ('707') OR C_APPL_ID IN ('707'))         
       AND  c_SEGMENT2 LIKE '0028'
       AND D_ACCOUNTING_DATE BETWEEN TO_DATE ('01.10.2019', '.dd.mm.yyyy')
                                 AND TO_DATE ('31.10.2019', '.dd.mm.yyyy')


/* Formatted on (QP5 v5.326) Service Desk 469945 Mihail.Vasiljev */
UPDATE xxtg.xxtg_gl001_double_global
   SET c_AN_DESC_1 = 'Jawwal, Al-Bireh, Palestinian Territory'
 WHERE c_AN_DESC_1 LIKE ('%Jawwal%') AND c_AN_CODE_1 = '287299'
 
 /* Formatted on (QP5 v5.326) Service Desk 469945 Mihail.Vasiljev */
UPDATE xxtg.xxtg_gl001_double_global
   SET D_AN_DESC_1 = 'Jawwal, Al-Bireh, Palestinian Territory'
 WHERE D_AN_DESC_1 LIKE ('%Jawwal%') AND D_AN_CODE_1 = '287299'

 /* ##################################################### */
 /* SD 601442 OEBS DB - RUNNING UPDATE code - COST UPDATE */

  INSERT INTO XXTG_GL001_TMP_GLOBAL 
                SELECT 1 row_id,
                           aa.ae_header_id,
                           aa.ae_line_num,
                           aa.accounted_dr,
                           aa.accounted_cr,
                           aa.entered_dr,
                           aa.entered_cr,
                           aa.d_c,
                           aa.code_combination_id,
                           aa.accounting_class_code,
                           aa.currency_code,
                           aa.segment2,
                           aa.accounting_date,
                           aa.appl_id,
                           aa.source_id_int_1,
                           aa.entity_code,
                           decode(XXTG_XLA_DUAL_REC_PKG.check_attr (aa.segment2,1),'Y',xala.ac1,'') ac1,
                           decode(XXTG_XLA_DUAL_REC_PKG.check_attr (aa.segment2,2),'Y',decode(aa.segment2,'0806',(select gcc.segment7 from gl_code_combinations gcc where gcc.code_combination_id=aa.code_combination_id),xala.ac2),'') ac2,
                           decode(XXTG_XLA_DUAL_REC_PKG.check_attr (aa.segment2,3),'Y',xala.ac3,'') ac3,
                           decode(XXTG_XLA_DUAL_REC_PKG.check_attr (aa.segment2,4),'Y',xala.ac4,'') ac4,
                           XXTG_XLA_DUAL_REC_PKG.get_an_descr(aa.segment2,xala.ac1,1) descr1,
                           XXTG_XLA_DUAL_REC_PKG.get_an_descr(aa.segment2,decode(aa.segment2,'0806',(select gcc.segment7 from gl_code_combinations gcc where gcc.code_combination_id=aa.code_combination_id),xala.ac2),2) descr2,
                           XXTG_XLA_DUAL_REC_PKG.get_an_descr(aa.segment2,xala.ac3,3) descr3,
                           XXTG_XLA_DUAL_REC_PKG.get_an_descr(aa.segment2,xala.ac4,4) descr4,
                           apps.xxtg_inv008_pkg.get_doc_num(mtt.TRANSACTION_TYPE_NAME,mmt.transaction_set_id) doc_num,
                           mmt.transaction_date,
                           trim(mtt.description || ' ' || nvl(xdff.attribute1, '')|| ' ' || nvl(xdff.attribute2, '')) as  doc_desc,
                           aa.created_date,
                           mmt.creation_date,
                           aa.LEDGER_ID
                   FROM (select l.LEDGER_ID,
               l.ae_header_id,
               l.ae_line_num,
               l.accounted_dr,
               l.accounted_cr,
               l.entered_dr,
               l.entered_cr,
               DECODE (NVL (l.accounted_dr, 0), 0, 'C', 'D')d_c,
               l.code_combination_id,
               l.accounting_class_code,
               l.currency_code,
               gl.segment2,
               h.accounting_date,
               h.application_id,
               h.application_id appl_id,
               hae.source_id_int_1,
               hae.entity_code,
               h.completed_date,
               hae.creation_date created_date,
               h.attribute10
        from XXTG_XLA_HDR_TO_DR hae,
        xla_ae_headers h,
               xla_ae_lines                  l,
               gl_code_combinations          gl
        WHERE h.ae_header_id = hae.ae_header_id
            AND h.application_id = hae.application_id
            AND h.LEDGER_ID = l.LEDGER_ID
            AND h.ae_header_id = l.ae_header_id
            AND h.application_id = l.application_id
            AND gl.code_combination_id = l.code_combination_id
            AND hae.entity_code = 'MTL_ACCOUNTING_EVENTS'
          ---  AND h.ACCOUNTING_DATE >= l_gl_start_date
          ) aa, mtl_material_transactions mmt, mtl_transaction_types mtt,
                           xla_ae_line_acs xala, XXTG_INV_ADD_INFO_DFF_EXT xdff
                 WHERE 1=1--aa.source_id_int_1 in (select doc_id from xxtg_gl001_DOC_ID)
                     AND mmt.transaction_type_id=mtt.transaction_type_id
                     AND xala.ae_header_id(+) = aa.ae_header_id
                     AND xala.ae_line_num(+) = aa.ae_line_num
                     and xdff.dff_id1(+) = mmt.transaction_set_id
                     and segment2 not in ('0001','0003','0004','0005','0006','0007','0008','98','9998','0020','0014','0021','0024','0099','0009','T','0','0015','0010','0011','0013')
                     and  aa.segment2 not like '0__'
                         and ((aa.segment2 not like '4%' and aa.d_c = 'C') or ( aa.d_c = 'D'))
                         and ((aa.segment2 not like '90%'  and aa.d_c = 'D') or (aa.accounting_class_code!='INTERORG_PAYABLES') or ( aa.d_c = 'C'))
                         and aa.attribute10 is null
                      --15.10.2012--удаление задвоения счетов
--                      and ((aa.segment2 not like '90%' and aa.d_c = 'D' ) or (aa.segment2 not like '41%' and aa.d_c = 'C'))
--                     and ((aa.segment2 not like '41%' and aa.d_c = 'D' ) or (aa.segment2 not like '10%' and aa.d_c = 'C'))
                     --15.10.2012
                      and mmt.SOURCE_CODE = 'XXTGLayerCostUpdate'
                     AND mmt.transaction_id = aa.source_id_int_1;

DECLARE
   dummy NUMBER;
BEGIN
            XXTG_XLA_DUAL_REC_PKG.CREATE_DOUBLE_PROC(dummy);
   
END;     
               

  insert into XXTG_GL001_DOUBLE_GLOBAL(D_AE_HEADER_ID,C_AE_HEADER_ID,D_AE_LINE_NUM,C_AE_LINE_NUM,ACCOUNTED_AMOUNT,ENTERED_AMOUNT,D_CODE_COMBINATION_ID,C_CODE_COMBINATION_ID,
                                                                         D_ACCOUNTING_CLASS_CODE,C_ACCOUNTING_CLASS_CODE,D_SEGMENT2,C_SEGMENT2,D_ACCOUNTING_DATE,C_ACCOUNTING_DATE,D_APPL_ID,C_APPL_ID,D_DOC_ID,C_DOC_ID,
                                                                         D_ENTITY_CODE,C_ENTITY_CODE,CURRENCY_CODE,D_AN_CODE_1,D_AN_CODE_2,D_AN_CODE_3,D_AN_CODE_4,C_AN_CODE_1,C_AN_CODE_2,C_AN_CODE_3,C_AN_CODE_4,
                                                                         D_AN_DESC_1,D_AN_DESC_2,D_AN_DESC_3,D_AN_DESC_4,C_AN_DESC_1,C_AN_DESC_2,C_AN_DESC_3,C_AN_DESC_4,D_DOC_NUM,C_DOC_NUM,D_DOC_DATE,C_DOC_DATE,
                                                                         D_DOC_DESC,C_DOC_DESC,D_CREATED_DATE,C_CREATED_DATE,D_DOC_CREATION_DATE,C_DOC_CREATION_DATE,LEDGER_ID )
                select D_AE_HEADER_ID,C_AE_HEADER_ID,D_AE_LINE_NUM,C_AE_LINE_NUM,ACCOUNTED_AMOUNT,ENTERED_AMOUNT,D_CODE_COMBINATION_ID,C_CODE_COMBINATION_ID,
                         D_ACCOUNTING_CLASS_CODE,C_ACCOUNTING_CLASS_CODE,D_SEGMENT2,C_SEGMENT2,D_ACCOUNTING_DATE,C_ACCOUNTING_DATE,D_APPL_ID,C_APPL_ID,D_DOC_ID,C_DOC_ID,
                         D_ENTITY_CODE,C_ENTITY_CODE,CURRENCY_CODE,D_AN_CODE_1,D_AN_CODE_2,D_AN_CODE_3,D_AN_CODE_4,C_AN_CODE_1,C_AN_CODE_2,C_AN_CODE_3,C_AN_CODE_4,
                         D_AN_DESC_1,D_AN_DESC_2,D_AN_DESC_3,D_AN_DESC_4,C_AN_DESC_1,C_AN_DESC_2,C_AN_DESC_3,C_AN_DESC_4,D_DOC_NUM,C_DOC_NUM,D_DOC_DATE,C_DOC_DATE,
                         D_DOC_DESC,C_DOC_DESC,D_CREATED_DATE,C_CREATED_DATE,D_DOC_CREATION_DATE,C_DOC_CREATION_DATE,LEDGER_ID
                           from  XXTG_GL001_DOUBLE_GLOBAL_TMP;   
                    
    commit;                
 /* ##################################################### */