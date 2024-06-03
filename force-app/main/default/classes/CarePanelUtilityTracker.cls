@isTest
public class CarePanelUtilityTracker {
    @isTest
    public static void testmethod1(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.Identifier__c = '4375';
        insert oContact;
        
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
        System.debug('u>>>'+u);
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        oCase.Agent_Comments__c = 'Test';
        oCase.Expected_Closure_Date__c = Date.today();
        oCase.Identifier__c= '06ce-04da-e8b01683-12a3-ad3805a079aa';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.OwnerId = u.Id;
        insert oCase;
        
        Attachment att = New Attachment();
        att.ParentId=oCase.Id;
        att.Body = Blob.valueOf('test hjsagdysaud ');
        att.Name = 'test attachmment';
        insert att;
        List<Id> listOfCaseId = new List<Id>();
        listOfCaseId.add(oCase.Id);
        CarePanelUtility.preparepayload(listOfCaseId,'CarePanel','TAT_EXCEEDED');
        CarePanelUtility.createHTTPPublisher('String1','String2','String3',NULL,'Process1');
    } 
    
}