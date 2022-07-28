DECLARE
   PRAGMA AUTONOMOUS_TRANSACTION;
  
   l_po_num  VARCHAR2(25) := '36784';
   l_CONCATENATED_SEGMENTS VARCHAR2(150)  := '01.0806.0.0.0.DMN040200.0.740_07_06_00_00_00.0.0.A_2_250_01_04_1.0.0.0.0';
   L_Integ_Header_Id           NUMBER;
   L_Vendor_Code               VARCHAR2 (30 BYTE);
   L_Vendor_Name               VARCHAR2 (240 BYTE);
   L_Count                     NUMBER;
   L_All_Cancel_Line           NUMBER;
   L_Total_Amount              NUMBER;
   L_Byr_Amount                NUMBER;
   L_Currency_Amount           NUMBER;
   L_Error_Message             VARCHAR2 (2000 BYTE);
   L_Intg_Status               VARCHAR2 (20 BYTE);
   L_Galaktika_Currency_Code   VARCHAR2 (100 BYTE);
   L_Progress                  VARCHAR2 (100 BYTE);
   L_Currency_Code             VARCHAR2 (10 BYTE);
   L_Contract_Number           VARCHAR2 (240 BYTE);
   L_Lines_Status              VARCHAR2 (100 BYTE);
   L_Galaktika_Uom_Code        VARCHAR2 (100 BYTE);
   L_Ifrs_Code                 VARCHAR2 (25 BYTE);
   L_Local_Account             VARCHAR2 (25 BYTE);
   L_Budget_Code               VARCHAR2 (25 BYTE);
   L_Account                   VARCHAR2 (400 BYTE);
   L_Galaktika_Item_Code       VARCHAR2 (100 BYTE);
   L_Integ_Id                  NUMBER;
  
BEGIN

update  PO_REQUISITION_LINES_ALL 
set DESTINATION_CONTEXT = 'EXPENSE'
where LINE_LOCATION_ID in (select LINE_LOCATION_ID from PO_LINE_LOCATIONS_ALL where po_header_id in (select po_header_id from po_headers_all  where segment1 in (l_po_num)));
                       
       update po_distributions_all
       set  DESTINATION_CONTEXT = 'EXPENSE',
       DESTINATION_TYPE_CODE = 'EXPENSE',
       ACCRUE_ON_RECEIPT_FLAG = 'N'
       where po_distribution_id in (select po_distribution_id
  FROM po.po_distributions_all d
 WHERE po_header_id in (select po_header_id from po_headers_all  where segment1 in ( l_po_num)));
 
 commit;
   for po_cur in  (select * from po_headers_all where  Authorization_Status = 'APPROVED'
           AND Type_Lookup_Code = 'STANDARD' and po_header_id in (select po_header_id from po_headers_all  where segment1 in ( l_po_num)))
   loop
  
   begin
  
   delete from Xxtg_Life_Po_Integ_Line where po_header_id = po_cur.Po_Header_Id;
   delete from Xxtg_Life_Po_Integ_hdr where po_header_id = po_cur.Po_Header_Id;
   commit;
  
   L_Intg_Status := 'NEW';
   L_Error_Message := NULL;
   L_Progress := '00';
   SELECT COUNT (*)
     INTO L_Count
     FROM Po_Lines_All Pl, Mtl_System_Items_B Msib, Po_Distributions_All Pda
    WHERE     Pl.Po_Header_Id = po_cur.Po_Header_Id
          AND Pl.Item_Id = Msib.Inventory_Item_Id
          AND Msib.Organization_Id = 82
          AND NVL (Msib.Attribute21, 'N') = 'Y'
          AND Pda.Po_Header_Id = Pl.Po_Header_Id
          AND Pda.Po_Line_Id = Pl.Po_Line_Id
          AND Pda.Destination_Type_Code = 'EXPENSE'
          AND ROWNUM = 1;
   L_Progress :=  '01';
   IF po_cur.Vendor_Id IS NOT NULL
   THEN
      SELECT Vendor_Name, Segment1
        INTO L_Vendor_Name, L_Vendor_Code
        FROM Ap_Suppliers
       WHERE Vendor_Id = po_cur.Vendor_Id;
   END IF;
   L_Progress :=  '02';
   --   SELECT SUM (NVL (Unit_Price, 0) * NVL (Quantity, 0))
   --     INTO L_Total_Amount
   --     FROM Po_Lines_All
   --    WHERE Po_Header_Id = po_curPo_Header_Id;
   SELECT SUM (
               NVL (Pla.Unit_Price, 0)
             * NVL (Pda.Quantity_Ordered - Pda.Quantity_Cancelled, 0))
     INTO L_Total_Amount
     FROM Po_Lines_All Pla, Mtl_System_Items_B Msib, Po_Distributions_All Pda
    WHERE     Pla.Po_Header_Id = po_cur.Po_Header_Id
          AND Pla.Po_Line_Id = Pda.Po_Line_Id
          AND Pda.Po_Header_Id = Pla.Po_Header_Id
          AND NVL (Pda.Quantity_Ordered - Pda.Quantity_Cancelled, 0) > 0
          AND Pla.Item_Id = Msib.Inventory_Item_Id
          AND Msib.Organization_Id = 82
          AND NVL (Msib.Attribute21, 'N') = 'Y'
          AND Pda.Destination_Type_Code = 'EXPENSE';
   L_Progress :=  '03';
   L_Currency_Code := po_cur.Currency_Code;
   IF L_Currency_Code = 'BYR'
   THEN
      L_Currency_Code := 'BYN';
   END IF;
   IF (L_Currency_Code = 'BYN')
   THEN
      L_Byr_Amount := L_Total_Amount;
   ELSE
      L_Currency_Amount := L_Total_Amount;
   END IF;
   BEGIN
      SELECT Global_Attribute2
        INTO L_Galaktika_Currency_Code
        FROM Fnd_Currencies
       WHERE Currency_Code = L_Currency_Code AND Enabled_Flag = 'Y';
      IF L_Galaktika_Currency_Code IS NULL
      THEN
         L_Intg_Status := 'ERROR';
         L_Error_Message :=
            'Script Galaktika Currency Code Value Is Null!';
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         L_Intg_Status := 'ERROR';
         L_Error_Message :=
            'Script Oracle Currency Code Value Not Found!';
   END;
   L_Progress :=  '04';
   BEGIN
      SELECT Contrat_No
        INTO L_Contract_Number
        FROM Xxtg_Invoice_Contract_V
       WHERE Contract_Id = po_cur.Attribute1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         L_Contract_Number := NULL;
   END;
   L_Progress :=  '05';
   --   SELECT COUNT (*) -- Cancel Flag Y degilse, Authorization Status Degisiyor mu? @myilmazer
   --     INTO L_All_Cancel_Line
   --     FROM Po_Line_Locations_All
   --    WHERE Po_Header_Id = po_curPo_Header_Id AND NVL (Cancel_Flag, 'N') <> 'Y';
   SELECT COUNT (*) -- Cancel Flag Y degilse, Authorization Status Degisiyor mu? @myilmazer
     INTO L_All_Cancel_Line
     FROM Po_Lines_All Pl,
          Mtl_System_Items_B Msib,
          Po_Distributions_All Pda,
          Po_Line_Locations_All plla
    WHERE     Pl.Po_Header_Id = po_cur.Po_Header_Id
          AND Pl.Item_Id = Msib.Inventory_Item_Id
          AND Msib.Organization_Id = 82
          AND NVL (Msib.Attribute21, 'N') = 'Y'
          AND Pda.Po_Header_Id = Pl.Po_Header_Id
          AND Pda.Po_Line_Id = Pl.Po_Line_Id
          AND Pda.Destination_Type_Code = 'EXPENSE'
          AND pda.line_location_id = plla.line_location_id
          AND NVL (plla.Cancel_Flag, 'N') <> 'Y';
   IF L_All_Cancel_Line > 0
   THEN
      BEGIN
     
         SELECT COUNT (*)
           INTO L_Count
           FROM Xxtg_Life_Po_Integ_Hdr
          WHERE     Po_Header_Id = po_cur.Po_Header_Id
                AND Intg_Status IN ('NEW', 'ERROR')
                AND ROWNUM = 1;
         INSERT INTO Xxtg_Mustafa (Req_Header_Id, Custom_Text, Creation_Date)
                 VALUES (
                           po_cur.Po_Header_Id,
                           'Script Updating 1',
                           SYSDATE);
         SELECT Xxtg_Life_Po_Integ_Hdr_S.NEXTVAL INTO L_Integ_Id FROM DUAL;
         INSERT INTO Xxtg_Life_Po_Integ_Hdr
              VALUES ('INSERT',
                      L_Integ_Id,         -- Xxtg_Life_Po_Integ_Hdr_S.NEXTVAL,
                      po_cur.Po_Header_Id,
                      po_cur.Segment1,
                      po_cur.Vendor_Id,
                      L_Vendor_Code,
                      L_Vendor_Name,
                      po_cur.Creation_Date,
                      L_Contract_Number,                    -- Contract_Number
                      po_cur.Comments,
                      L_Galaktika_Currency_Code,         --po_curCurrency_Code,
                      L_Currency_Amount,                    -- Currency_Amount
                      L_Byr_Amount,                              -- Byr_Amount
                      L_Intg_Status,                                  --'NEW',
                      L_Error_Message,
                      NULL,
                      SYSDATE,
                      Fnd_Global.User_Id,
                      SYSDATE,
                      Fnd_Global.User_Id,
                      Fnd_Global.Login_Id);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO Xxtg_Mustafa (Req_Header_Id, Custom_Text, Creation_Date)
               VALUES (
                         po_cur.Po_Header_Id,
                         'Script  Inserting 1',
                         SYSDATE);
              END;
      FOR C1
         IN (SELECT DISTINCT
                    Pda.Po_Line_Id,
                    Pda.Quantity_Ordered - Pda.Quantity_Cancelled AS Quantity,
                    Pda.Code_Combination_Id,
                    Pda.Po_Distribution_Id,
                    Pla.Unit_Meas_Lookup_Code,
                    Pla.Line_Num,
                    Pla.Unit_Price,
                    Pla.Item_Id,
                    Pla.Closed_Code
               FROM Po_Distributions_All Pda,
                    Po_Lines_All Pla,
                    Mtl_System_Items_B Msib
              WHERE     Pda.Po_Header_Id = po_cur.Po_Header_Id
                    AND Pla.Po_Line_Id = Pda.Po_Line_Id
                    AND Pda.Po_Header_Id = Pla.Po_Header_Id
                    AND NVL (Pda.Quantity_Ordered - Pda.Quantity_Cancelled,
                             0) > 0
                    AND NVL (Pla.Cancel_Flag, 'N') = 'N'
                    AND Pda.Destination_Type_Code = 'EXPENSE'
                    AND Pla.Item_Id = Msib.Inventory_Item_Id
                    AND Msib.Organization_Id = 82
                    AND NVL (Msib.Attribute21, 'N') = 'Y')
      LOOP
         L_Lines_Status := C1.Closed_Code;
         IF C1.Code_Combination_Id IS NULL
         THEN
            L_Intg_Status := 'ERROR';
            L_Error_Message :=
               ' Script Oracle Code Combination Id Value Is Null!';
         END IF;

         SELECT Msib.Attribute14
           INTO L_Galaktika_Item_Code
           FROM Mtl_System_Items_B Msib
          WHERE     Msib.Inventory_Item_Id = C1.Item_Id
                AND Msib.Organization_Id = 82
                AND NVL (Msib.Attribute21, 'N') = 'Y';

         IF L_Galaktika_Item_Code IS NULL
         THEN
            L_Intg_Status := 'ERROR';
            L_Error_Message :=
               'Script Galaktika Item Code Value Is Null!';
         END IF;
         BEGIN
            SELECT Attribute2
              INTO L_Galaktika_Uom_Code
              FROM Mtl_Units_Of_Measure_Tl
             WHERE     Unit_Of_Measure = C1.Unit_Meas_Lookup_Code
                   AND Language = 'US';
            IF L_Galaktika_Uom_Code IS NULL
            THEN
               L_Intg_Status := 'ERROR';
               L_Error_Message :=
                  'Script Galaktika Unit Measure Lookup Code Value Is Null!';
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               L_Intg_Status := 'ERROR';
               L_Error_Message :=
                  'Script Oracle Unit Measure Lookup Code Value Not Found!';
         END;
         L_Progress :=  '06';
         IF C1.Code_Combination_Id IS NOT NULL
         THEN
            SELECT Concatenated_Segments,
                   Segment11,
                   Segment2,
                   Segment8
              INTO L_Account,
                   L_Ifrs_Code,
                   L_Local_Account,
                   L_Budget_Code
              FROM Gl_Code_Combinations_Kfv
             WHERE Code_Combination_Id = C1.Code_Combination_Id;
         END IF;
         L_Progress :=  '07';
         BEGIN
            SELECT COUNT (*)
              INTO L_Count
              FROM Xxtg_Life_Po_Integ_Line
             WHERE     Po_Line_Id = C1.Po_Line_Id
                   AND Intg_Status IN ('NEW', 'ERROR')
                   AND ROWNUM = 1;
            INSERT INTO Xxtg_Mustafa (Req_Header_Id,
                                      Req_Line_Id,
                                      Custom_Text,
                                      Creation_Date)
                 VALUES ( po_cur.Po_Header_Id,
                         C1.Po_Line_Id,
                         'Script Updating Line',
                         SYSDATE);
            IF L_Integ_Id IS NULL
            THEN
               SELECT MAX (Po_Integ_Id)
                 INTO L_Integ_Id
                 FROM Xxtg_Life_Po_Integ_Hdr
                WHERE Po_Header_Id = po_cur.Po_Header_Id;
            END IF;
            INSERT INTO Xxtg_Life_Po_Integ_Line
                    VALUES (
                              'INSERT',
                              L_Integ_Id,
                              po_cur.Po_Header_Id,
                              C1.Po_Line_Id,
                              C1.Line_Num,
                              C1.Po_Distribution_Id,
                              L_Galaktika_Item_Code,            --L_Item_Code,
                              C1.Item_Id,
                              L_Galaktika_Uom_Code, --po_curUnit_Meas_Lookup_Code,
                              C1.Quantity,                    --po_curQuantity,
                              C1.Unit_Price,
                              (C1.Quantity * C1.Unit_Price),
                              DECODE (NVL (L_Lines_Status, 'OPEN'),
                                      'OPEN', 'OPEN',
                                      'CANCEL'), -- po_curClosed_Code,                            -- Line_Status
                              L_Account,
                              L_Ifrs_Code,
                              L_Local_Account,
                              L_Budget_Code,
                              L_Intg_Status,                          --'NEW',
                              NULL,
                              L_Error_Message,                         --NULL,
                              NULL,
                              SYSDATE,
                              Fnd_Global.User_Id,
                              SYSDATE,
                              Fnd_Global.User_Id,
                              Fnd_Global.Login_Id);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              INSERT INTO Xxtg_Mustafa (Req_Header_Id,
                                         Req_Line_Id,
                                         Custom_Text,
                                         Creation_Date)
                    VALUES ( po_cur.Po_Header_Id,
                            C1.Po_Line_Id,
                            'Script Inserting Line',
                            SYSDATE);
      
         END;
      END LOOP;
   END IF;
   COMMIT;
 
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      INSERT INTO Xxtg_Mustafa (Req_Header_Id, Custom_Text, Creation_Date)
              VALUES (
                        po_cur.Po_Header_Id,
                           'Script Not Inserting No_Data_Found L_Progress:'
                        || L_Progress,
                        SYSDATE);
                       
--
      COMMIT;
   WHEN OTHERS
   THEN
      L_Error_Message :=
            SUBSTR ( (DBMS_UTILITY.Format_Error_Backtrace), 1, 1000)
         || '--'
         || SUBSTR ( (SQLERRM), 1, 500);
      INSERT INTO Xxtg_Mustafa (Req_Header_Id, Custom_Text, Creation_Date)
              VALUES (
                        po_cur.Po_Header_Id,
                           'Script Not Inserting '
                        || L_Error_Message,
                        SYSDATE);
--
      COMMIT;
       end ;
      end loop;
END;
/

