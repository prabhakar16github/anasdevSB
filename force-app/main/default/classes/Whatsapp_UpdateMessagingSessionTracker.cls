@isTest
public class Whatsapp_UpdateMessagingSessionTracker {
    @isTest
    public static void testData1(){
        
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
        tempCase.LP_TAT__c = '3';
        tempCase.LP_Business_Vertical__c = 'PayU Money';
        tempCase.LP_Category__c = 'PayU Money';
        tempCase.ContactId=oContact.id;
        tempCase.LOB_Name__c='PayU Money';
        tempCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert tempCase;
        
        MessagingEndUser msgEndUser = new MessagingEndUser();
        msgEndUser.MessagingChannelId = System.label.MessagingChannelId;
        msgEndUser.Name = 'test:+919999999999';
        msgEndUser.messageType = 'WhatsApp';
        msgEndUser.MessagingPlatformKey = 'test:+919999999999';
        insert msgEndUser;
        MessagingSession msgSession = new MessagingSession();
        msgSession.MessagingEndUserId = msgEndUser.id;
        msgSession.MessagingChannelId = System.label.MessagingChannelId;
        msgSession.Status = 'Ended';
        //msgSession.CaseId = tempCase.id;
        insert msgSession;
        
        test.startTest();
        Whatsapp_UpdateMessagingSession.MessagingInput input = new Whatsapp_UpdateMessagingSession.MessagingInput();
        input.messagingSessionId = msgSession.id;
        input.CaseId = tempCase.id;
        
        
        List<Whatsapp_UpdateMessagingSession.MessagingInput> listInput = new List<Whatsapp_UpdateMessagingSession.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_UpdateMessagingSession.updateMsgSession(listInput);
        test.stopTest();
    }
    
    
    
}