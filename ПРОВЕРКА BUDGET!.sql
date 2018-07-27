declare
l_ccid number;

L_Budget_Amount number;
L_Total_Open_Amount number;
L_Open_Req_Amount number;
L_Open_Po_Amount number;
L_Open_Rcv_Amount number; 
L_Open_Gl_Amount number;
L_Open_Inv_Amount number;
L_Open_Gl_Act_Amount number;
L_Open_Pe_Amount number;
L_Open_Transfer_Amount number;
L_Open_Pog_Amount number;
L_Open_Consignment_Amount number;

L_Status varchar2(1024);
L_Status_Desc varchar2(1024);
l_Remaining_Amount number;
Begin

SELECT code_combination_id
into l_ccid
  FROM apps.gl_code_combinations_kfv
 WHERE CONCATENATED_SEGMENTS = '01.9020.0.0.0.DGD000000.0.770_07_2_09_00_00.0.0.PL_770_07_2.0.0.0.0';
        
 
--l_ccid := 424117;
          
APPS.Xxtg_Req_Budget_Control_Pkg.Get_Budget_Amounts (
               P_Org_Id                => 101,--Org_Id,
               P_Code_Combination_Id   => l_ccid,-- Code_Combination_Id,
               P_Method_Name           => 'USTHESAP',--P_Method_Name, don�t change
               P_Budget_Year           => 2018, --P_Budget_Year,
               X_Budget_Amount         => L_Budget_Amount,
               X_Total_Used_Amount     => L_Total_Open_Amount,
               X_Open_Req_Amount       => L_Open_Req_Amount,
               X_Open_Po_Amount        => L_Open_Po_Amount,
               X_Open_Rcv_Amount       => L_Open_Rcv_Amount, 
               X_Open_Gl_Amount        => L_Open_Gl_Amount,
               X_Open_Inv_Amount       => L_Open_Inv_Amount,
               X_Actual_Gl_Amount      => L_Open_Gl_Act_Amount,
               X_Prepaid_Expenses      => L_Open_Pe_Amount,
               X_Budget_Transfers      => L_Open_Transfer_Amount,
               X_Pog                   => L_Open_Pog_Amount,
               X_Consignment           => L_Open_Consignment_Amount,  
               X_Status                => L_Status,
               X_Status_Desc           => L_Status_Desc);               
      l_Remaining_Amount :=             L_Budget_Amount - L_Total_Open_Amount;
Dbms_Output.Put_Line('L_Budget_Amount: '||L_Budget_Amount||'-L_Total_Open_Amount: '||L_Total_Open_Amount||'-Remaining_Amount: '||l_Remaining_Amount);      

end;