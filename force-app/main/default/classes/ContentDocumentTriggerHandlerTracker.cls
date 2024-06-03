/*
* Created Date: 26 Sep 2019
* Created By: Akash Pandey
* Description: This class is used to send the Attachment related data to the merchant from the Lightning view.
* */
@isTest
private class ContentDocumentTriggerHandlerTracker {
    @isTest
    private static void createData(){
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        List<Case> caseList = new List<Case>();
        Set<Id> casId = new Set<Id>();
        Case tempCase =new Case();
        tempCase.Status='New';
        tempCase.Priority='Medium';
        /*
        tempCase.LP_Sub_Status__c='Waiting On Technical Team';
        tempCase.SuppliedEmail = 'test1@test.com';
        tempCase.SuppliedName = 'test';
        */
        tempCase.LP_TAT__c = '3';
        tempCase.LP_Business_Vertical__c = 'PayU Money';
        tempCase.LP_Category__c = 'PayU Money';
        tempCase.ContactId=oContact.id;
        tempCase.LOB_Name__c='PayU Money';
        tempCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        caseList.add(tempCase);
        insert caseList;
        casId.add(caseList[0].Id);
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        list<Id> lstAttId = new list<Id>();
        for(ContentDocument conm : documents){
            lstAttId.add(conm.Id);
        }
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tempCase.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.startTest();
        ContentDocumentTriggerHandler.checkSizeAndType(documents);
        ContentDocumentTriggerHandler.getCaseOnInsert(documents);
        ContentDocumentTriggerHandler.preparePayloadForAttachment(lstAttId, casId, 'Test', 'Test');
        Test.stopTest();
    }
    
}