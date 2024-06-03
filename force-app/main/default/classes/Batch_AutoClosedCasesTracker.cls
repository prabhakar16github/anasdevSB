/*
 * Created Date: 4 oct 2019
 * Created By: Akash Pandey
 * Description: To cover the code coverage of Batch_AutoClosedCases and Queueable_AutoClosedCases class.
 * 
 * */
@isTest
public class Batch_AutoClosedCasesTracker {
    @isTest
    public static void fetchData(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'OneCareAutoCloseBatch';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        oCase.Priority='Medium';
        //oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.Auto_Close_Date__c  = Date.today()-1;
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.LOB_Name__c='Payu Money';
        oCase.AutoClosedBatch__c =true;
        oCase.Send_Reminder_Of_Autoclosed_case__c = true;
        oCase.TicketId__c = 'ES0018209202';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert oCase;
        System.debug('oCase Test'+oCase);
        Test.startTest();
        Batch_AutoClosedCases.totalDays_ForTestClass = 1; 
        Schedule_AutoClosedCases sc = new Schedule_AutoClosedCases();
        //sc.scheduleMe();
        String cron = '0 0 0 15 3 ? 2024';
        system.schedule('Lead Bannk Verification status check', cron, sc);
        Test.stopTest();
        
    }
    
    @isTest
    public static void fetchData2(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'OneCareAutoCloseBatch';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        oCase.Priority='Medium';
        //oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.Auto_Close_Date__c  = Date.today()-3;
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.LOB_Name__c='Payu Money';
        oCase.AutoClosedBatch__c =true;
        oCase.Send_Reminder_Of_Autoclosed_case__c = false;
        oCase.TicketId__c = 'ES0018209202';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert oCase;
        System.debug('oCase Test1'+oCase);
        Batch_AutoClosedCases.sendExceptionEmail(new DMLException(), 'Execute');
        Test.startTest();
        
        Batch_AutoClosedCases.totalDays_ForTestClass = 2; 
        //Batch_AutoClosedCases bc = new Batch_AutoClosedCases();
        Schedule_AutoClosedCases sc = new Schedule_AutoClosedCases();
        String cron = '0 0 0 15 3 ? 2024';
        system.schedule('Lead Bannk Verification status check', cron, sc);
        //Database.executeBatch(bc);
        Test.stopTest();
        
    }
    
    @isTest
    public static void fetchData3(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Resolved';
        //oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        oCase.Priority='Medium';
        //oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.Auto_Close_Date__c  = Date.today()-6;
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.LOB_Name__c='Payu Money';
        oCase.AutoClosedBatch__c =true;
        oCase.Send_Reminder_Of_Autoclosed_case__c = false;
        oCase.TicketId__c = 'ES0018209202'; 
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert oCase;
        
        System.debug('oCase Test1'+oCase);
        Test.startTest();
        
        Batch_AutoClosedCases.totalDays_ForTestClass = 3; 
        Schedule_AutoClosedCases sc = new Schedule_AutoClosedCases();
        String cron = '0 0 0 15 3 ? 2024';
        system.schedule('Lead Bannk Verification status check', cron, sc);
        //Database.executeBatch(bc);
        Test.stopTest();
        
    }

}