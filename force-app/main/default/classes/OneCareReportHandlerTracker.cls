/**
@company:       PayU 
@description:   This class is used in one care. it will call when case trigger will active for  
One care process.
@Created By:    Akash Pandey
@history:       <Date>                             
25-Sep-19
**/
@isTest
public class OneCareReportHandlerTracker {
    
    @testSetup
    public static void createCustomSetting(){
        test.startTest();
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Case', true);
        insert triggerSwitchObj ;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Child'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        Account acc1 = New Account();
        acc1.Name = 'testAccount';
        insert acc1;
        
        contact oContact1=new contact();
        oContact1.LastName='test';
        oContact1.AccountId = acc1.Id;
        oContact1.Email='test@test.com';
        oContact1.MobilePhone='1234567890';
        insert oContact1;
        
        Case oldCase =new Case();
        oldCase.Status='New';
        oldCase.OwnerId = u.Id;
        oldCase.LP_Sub_Status__c='Waiting On Technical Team';
        oldCase.Priority='Medium';
        oldCase.SuppliedEmail = 'test1@test.com';
        oldCase.SuppliedName = 'Test2';
        oldCase.LP_TAT__c = '3';
        oldCase.LP_Business_Vertical__c = 'PayU Money';
        oldCase.LP_Category__c = 'PayU Money';
        oldCase.ContactId=oContact1.id;
        oldCase.LOB_Name__c='PayU Money';
        oldCase.Comments = 'Testing comment';
        oldCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oldCase;
        
        Case oldCase2 =new Case();
        oldCase2.Status='New';
        oldCase2.OwnerId = u.Id;
        oldCase2.LP_Sub_Status__c='Waiting On Merchant';
        oldCase2.Priority='Medium';
        oldCase2.SuppliedEmail = 'test1@test.com';
        oldCase2.SuppliedName = 'Test';
        oldCase2.LP_TAT__c = '3';
        oldCase2.LP_Business_Vertical__c = 'PayU Money';
        oldCase2.LP_Category__c = 'PayU Money';
        oldCase2.ContactId=oContact1.id;
        oldCase2.LOB_Name__c='PayU Money';
        oldCase2.Comments = 'Testing comment';
        oldCase2.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oldCase2; 
        
        Case caseForaETC =new Case();
        caseForaETC.Status='New';
        caseForaETC.OwnerId = u.Id;
        caseForaETC.LP_Sub_Status__c='Waiting On Merchant';
        caseForaETC.Priority='Medium';
        caseForaETC.SuppliedEmail = 'test1@test.com';
        caseForaETC.SuppliedName = 'TestETC';
        caseForaETC.LP_TAT__c = '3';
        caseForaETC.LP_Business_Vertical__c = 'PayU Money';
        caseForaETC.LP_Category__c = 'PayU Money';
        caseForaETC.ContactId=oContact1.id;
        caseForaETC.LOB_Name__c='PayU Money';
        caseForaETC.Comments = 'Testing comment';
        //caseForaETC.Platform_e__c 'Waiting On Technical Team';
        caseForaETC.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId();
        insert caseForaETC; 
        
        
        
        Status_SLA__c  sla = new Status_SLA__c();
        sla.Case__c = oldCase2.Id;
        sla.OneCare_LOB_Name__c = oldCase2.LOB_Name__c;
        sla.Transferred_from_Other_Teams_Count__c = 1;
        sla.First_assigned_user__c = oldCase2.Owner__c;
        insert sla; 
        test.stopTest();
    }
    @isTest
    public static void StatusNewToOpen(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test' And Status=: 'New'];
        System.debug('Test oldCase'+oldCase);
        oldCase.Status = 'Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Transferred from Other Teams';
        Update oldCase;
        
    }
    /*@isTest
    public static void StatusNewToOpen2(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'TestETC' And Status=: 'New'];
        System.debug('Test oldCase StatusNewToOpen2'+oldCase);
        oldCase.Status = 'Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Transferred from Other Teams';
        Update oldCase;
        
    }*/
    @isTest
    public static void StatusOpenToPending(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test2' And Status=: 'New'];
        System.debug('Test oldCase'+oldCase);
        oldCase.Status = 'Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Response Received from Other Teams';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Resolved';
        oldCase.LOB_Name__c = 'PayU Now';
        Update oldCase;
    }
    @isTest
    public static void StatusOpenToPending2(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test2' And Status=: 'New'];
        System.debug('Test oldCase'+oldCase);
        oldCase.Status = 'Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'No Resolution From Other Teams';
        Update oldCase;
        oldCase.Status = 'Re-Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Response received from merchant';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'No Resolution From Other Teams';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
    }
    @isTest
    public static void StatusOpenToPending3(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test' And Status=: 'New'];
        System.debug('Test oldCase'+oldCase);
        oldCase.Status = 'Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Response received from merchant';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'No Resolution From Other Teams';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
        oldCase.Status = 'Response Received from Other Teams';
        Update oldCase;
        oldCase.Status = 'Pending';
        oldCase.LP_Sub_Status__c = 'Waiting On Merchant';
        Update oldCase;
    }
    
    @isTest
    public static void StatusOpenToResolved(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test' And Status=: 'New'];
        oldCase.Status = 'Open';
        System.debug('Test oldCase'+oldCase);
        Update oldCase;
        oldCase.Status = 'Resolved';
        Update oldCase;
        oldCase.Status = 'Re-Open';
        Update oldCase;
        oldCase.Status = 'Resolved';
        Update oldCase;
        oldCase.Status = 'Re-Open';
        Update oldCase;
        oldCase.Status = 'Pending';
        Update oldCase;
    }
    @isTest
    private static void coverCatchBlock(){
        Case oldCase = [SELECT Id,Status,comments,LOB_Name__c,RecordTypeId,LP_Sub_Status__c,LastModifiedDate From Case where SuppliedName =: 'Test' And Status=: 'New'];
        oldCase.LOB_Name__c = 'PayU Now';
        update oldCase;
        
    }
    @isTest
    private static void ckeckRecordType(){
       	//String McareRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        OneCareReportHandler.toCoverTestData();
    }
}