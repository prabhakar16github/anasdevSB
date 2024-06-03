@isTest
public class LazyPayPartPayment_Tracker {
    
    @isTest
    public static void unitTest1(){
    test.startTest(); 
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';  
    partpayment.Generate_Payment_URL__c = true; 
    partpayment.Amount__c = 3.3;
    insert partpayment;      
    LazypayPartPayment.PostPartPayment(partpayment.Id,'8077545665',10.0,'Test','payment','Repayment Amount','VPA','useragent','payuid', 'bankref');
    LazypayPartPayment.GetPaymentLink(partpayment.Id,3.3, 'txnid','productinfo' ,'firstname','email@email.com','9999998989','address1','city','state','country', 'zipcode','template_id','sms_template_id','validation_period','time_unit');   
    LazypayPartPayment.CheckPaymentLink(partpayment.ID, 'txnid');
    LazypayPartPayment.SendPaymentDetails(partpayment.id, 'mobile', 'amount', 'paylink', 'ftemobile'); 
    test.stopTest();    
    }    
    
    @isTest
    public static void unitTest2(){
    Test.startTest();
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601';  
    partpayment.Post_Payment__c = true;    
    partpayment.IsNEFT__c = false;    
    insert partpayment;     
    test.stopTest();    
    }
    
        @isTest
    public static void unitTest3(){
    Test.startTest();
    LP_Collection_PL_PartPayment__c partpayment = new LP_Collection_PL_PartPayment__c();
    partpayment.mobile__c = '8077656565';
    partpayment.LAN1__c = 3.3;
    partpayment.EMI1__c = 6.7;
    partpayment.Payment_for_EMI1__c = 8.9;
    partpayment.FTE_Mobile__c = '7578675601'; 
        partpayment.Post_Payment__c = true;    
     partpayment.IsNEFT__c  = true;      
   // partpayment.Generate_Payment_URL__c = true;
   // partpayment.Check_Transaction_Status__c  = true;    
   // partpayment.Send_Payment_Details_to_Customer__c  = true;    
    insert partpayment;    
 
    test.stopTest();    
    }
   
}