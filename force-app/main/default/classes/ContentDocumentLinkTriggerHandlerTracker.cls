/*
* Created Date: 3 Jan 2022
* Created By: Sneha Sahi
* Description: This class is used to send the Attachment from Messaging Session to related Case.
* */
@isTest
private class ContentDocumentLinkTriggerHandlerTracker {
    @isTest
    private static void createData(){
        
        MessagingEndUser msgEndUser = new MessagingEndUser();
        msgEndUser.MessagingChannelId = System.label.MessagingChannelId;
        msgEndUser.Name = 'test:+919999999999';
        msgEndUser.messageType = 'WhatsApp';
        msgEndUser.MessagingPlatformKey = 'test:+919999999999';
        insert msgEndUser;
        
        
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case tempCase =new Case();
        tempCase.Status='New';
        //tempCase.LP_Sub_Status__c='Waiting On Technical Team';
        tempCase.Priority='Medium';
        //tempCase.SuppliedEmail = 'test1@test.com';
        //tempCase.SuppliedName = 'test';
        tempCase.LP_TAT__c = '3';
        tempCase.LP_Business_Vertical__c = 'PayU Money';
        tempCase.LP_Category__c = 'PayU Money';
        tempCase.ContactId=oContact.id;
        tempCase.LOB_Name__c='PayU Money';
        tempCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert tempCase;
        
        MessagingSession msgSession = new MessagingSession();
        msgSession.MessagingEndUserId = msgEndUser.id;
        msgSession.MessagingChannelId = System.label.MessagingChannelId;
        msgSession.Status = 'Ended';
        msgSession.CaseId = tempCase.id;
        insert msgSession;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //System.assertEquals(documents.size(), 1);
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = msgSession.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;Test.stopTest();
    }
	
}