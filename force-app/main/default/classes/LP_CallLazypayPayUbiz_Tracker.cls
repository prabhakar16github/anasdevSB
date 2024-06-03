@isTest
public class LP_CallLazypayPayUbiz_Tracker {
    @isTest
    public static void unitTest1(){
        
    LP_Collection_foreclosure__c  foreClosure = new LP_Collection_foreclosure__c();
    foreClosure.CustomerMobile__c = '8077535723';
    foreClosure.CustomerName__c  = 'Test Name';   
    foreClosure.Lazypay_Loan_ID__c = '1028833'; 
    foreClosure.Foreclosure_Enquiry__c = true;  
    Test.startTest();    
    insert foreClosure ;
    Test.stopTest();    
    }
    
    @isTest
    public static void unitTest2(){      
    LP_Collection_foreclosure__c  foreClosure = new LP_Collection_foreclosure__c();
    foreClosure.CustomerMobile__c = '8077535723';
    foreClosure.CustomerName__c  = 'Test Name';   
    foreClosure.Lazypay_Loan_ID__c = '1028833'; 
   // foreClosure.Foreclosure_Enquiry__c = true;
    foreClosure.Submit_for_Posting__c  = true;
    foreClosure.Is_Reliance_Collected__c = true ; 
    foreClosure.Reliance_Cheque_ID__c = '5008989'; 
    foreClosure.Amount__c = '123445';
    foreClosure.Transaction_Id__c = '6756565'; 
    foreClosure.CustomerZipCode__c = '262551';
    foreClosure.ValidationPeriod__c = '6';
    foreClosure.CustomerEmail__c  = 'TEst@test.com';  
    foreClosure.Product_Description__c  = 'Test'; 
    foreClosure.TimeUnit__c  = '6';        
    Test.startTest();    
    insert foreClosure ;
    Test.stopTest();    
    }
    
    @isTest
    public static void unitTest22(){      
    LP_Collection_foreclosure__c  foreClosure = new LP_Collection_foreclosure__c();
    foreClosure.CustomerMobile__c = '8077535723';
    foreClosure.CustomerName__c  = 'Test Name';   
    foreClosure.Lazypay_Loan_ID__c = '1028833'; 
    foreClosure.Reliance_Cheque_ID__c = '5008989'; 
    foreClosure.Amount__c = '123445';
    foreClosure.Transaction_Id__c = '6756565'; 
    foreClosure.CustomerZipCode__c = '262551';
    foreClosure.ValidationPeriod__c = '6';
    foreClosure.CustomerEmail__c  = 'TEst@test.com';  
    foreClosure.Product_Description__c  = 'Test'; 
    foreClosure.TimeUnit__c  = '6';
    foreClosure.Transaction_Status__c = 'success';    
    foreClosure.Submit_for_Posting__c  = true;  
    Test.startTest();    
    insert foreClosure ;
    Test.stopTest();    
    }
     @isTest
    public static void unitTest3(){      
    LP_Collection_foreclosure__c  foreClosure = new LP_Collection_foreclosure__c();
    foreClosure.CustomerMobile__c = '8077535723';
    foreClosure.CustomerName__c  = 'Test Name';   
    foreClosure.Lazypay_Loan_ID__c = '1028833';   
    foreClosure.Reliance_Cheque_ID__c = '5008989'; 
    foreClosure.Amount__c = '123445';
    foreClosure.Transaction_Id__c = '6756565'; 
    foreClosure.CustomerZipCode__c = '262551';
    foreClosure.ValidationPeriod__c = '6';
    foreClosure.CustomerEmail__c  = 'TEst@test.com';  
    foreClosure.Product_Description__c  = 'Test'; 
    foreClosure.TimeUnit__c  = '6';   
    foreClosure.Regenerate_Payment_Url__c = true;     
    Test.startTest();    
    insert foreClosure ;
    Test.stopTest();    
    }
    
    @isTest
    public static void unitTest4(){      
    LP_Collection_foreclosure__c  foreClosure = new LP_Collection_foreclosure__c();
    foreClosure.CustomerMobile__c = '8077535723';
    foreClosure.CustomerName__c  = 'Test Name';   
    foreClosure.Lazypay_Loan_ID__c = '1028833';   
    foreClosure.Reliance_Cheque_ID__c = '5008989'; 
    foreClosure.Amount__c = '123445';
    foreClosure.Transaction_Id__c = '6756565'; 
    foreClosure.CustomerZipCode__c = '262551';
    foreClosure.ValidationPeriod__c = '6';
    foreClosure.CustomerEmail__c  = 'TEst@test.com';  
    foreClosure.Product_Description__c  = 'Test'; 
    foreClosure.TimeUnit__c  = '6';  
    foreClosure.Transaction_Id__c = '9673654514PRT-30771';    
    foreClosure.Check_Transaction_status__c = true ;  
    Test.startTest();    
    insert foreClosure ;
    Test.stopTest();    
    }
}