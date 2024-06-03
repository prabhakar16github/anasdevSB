@isTest
public class triggerPartPaymentLP_Trigger {

    @isTest
    public static void unitTest(){
        
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';
    partpayment.Post_Payment__c   = true;
    partpayment.IsNEFT__c  = false;    
   // partpayment.Generate_Payment_URL__c = true; 
   Test.startTest();         
    insert partpayment;
     Test.stopTest();   
    }
    
    @isTest
    public static void unitTest2(){       
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';
    partpayment.Post_Payment__c   = true;
   // partpayment.Generate_Payment_URL__c = true;
    partpayment.IsNEFT__c  = true; 
    Test.startTest();    
    insert partpayment; 
    Test.stopTest();    
    }
    
    @isTest
    public static void unitTest3(){
        
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';  
    partpayment.Generate_Payment_URL__c = true;  
   Test.startTest();     
    insert partpayment; 
    Test.stopTest();    
    }
    
    @isTest
    public static void unitTest4(){
        
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';          
    partpayment.Check_Transaction_Status__c  = true;
    Test.startTest();    
    insert partpayment; 
    Test.stopTest();    
    }
        @isTest
    public static void unitTest5(){        
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';          
    partpayment.Send_Payment_Details_to_Customer__c  = true;  
    Test.startTest();    
    insert partpayment; 
    Test.stopTest();    
    }
}