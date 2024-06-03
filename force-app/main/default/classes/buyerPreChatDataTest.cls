@isTest(SeeAllData = true)
public class buyerPreChatDataTest {
    
    @isTest
    static void testTranscriptInput(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Opp test',
            Email = 'sauser000@test.com',
            Username = 'sauser000@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '9090909090',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        INSERT u;
        
        System.runAs(u){
            
           
            LiveChatVisitor oLCV = [SELECT Id, Name FROM LiveChatVisitor LIMIT 1];
            LiveChatButton oLCB = [SELECT Id, DeveloperName FROM LiveChatButton LIMIT 1];
            LiveChatDeployment oLCD = [SELECT Id, DeveloperName FROM LiveChatDeployment LIMIT 1];
            
            LiveChatTranscript oLCT = new LiveChatTranscript();
            
            oLCT = new LiveChatTranscript();
            oLCT.LiveChatButtonId = oLCB.Id;
            oLCT.LiveChatDeploymentId = oLCD.Id; 
            oLCT.ChatKey = 'TestChat123';
            oLCT.TransactionId__c = '123321123';
            oLCT.LiveChatVisitorId = oLCV.Id;
            Insert oLCT;
            
            Contact oContact = new Contact();
            oContact.FirstName = 'First';
            oContact.LastName = 'test';
            oContact.Email = 'test@test.com';
            oContact.Phone ='1234567890';
            INSERT oContact;
            
            Test.startTest();
            buyerPreChatData.TranscriptInput input = new buyerPreChatData.TranscriptInput();
            input.contactId = oContact.id;
            input.routableID = oLCT.id;
            
            List<buyerPreChatData.VisitorNameOutput> result = buyerPreChatData.getPreChatUserName(new List<buyerPreChatData.TranscriptInput>{input});
           
            System.assertEquals(oContact.FirstName, result[0].sFirstName, 'Contact names are mismatched');
            
            Test.stopTest();
        }
    }
    
}