@isTest
public class Whatsapp_CreateCaseTracker {
    
    @isTest
    public static void testData1(){
        
        MessagingEndUser msgEndUser = new MessagingEndUser();
        msgEndUser.MessagingChannelId = System.label.MessagingChannelId;
        msgEndUser.Name = 'test:+919999999999';
        msgEndUser.messageType = 'WhatsApp';
        msgEndUser.MessagingPlatformKey = 'test:+919999999999';
        //msgEndUser.IsFullyOptedIn = true;
        insert msgEndUser;
        
        Test.startTest();
        Whatsapp_CreateCase.MessagingInput input = new Whatsapp_CreateCase.MessagingInput();
        input.Comments = 'test';
        input.Email = 'test@test.com';
        input.Issue = 'Account related';
        input.Mobile = '+919999999999';
        input.firstName = 'test';
        input.subIssue = 'Other';
        input.mid = '12345671';
        input.product = 'PayUBiz';
        input.isLoggedin = 'true';
        input.website = 'https://test@test.com';
        input.monthlyExpectedSales = 'Less than 50,000';
        
        
        List<Whatsapp_CreateCase.MessagingInput> listInput = new List<Whatsapp_CreateCase.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_CreateCase.createCase(listInput);
        
        test.StopTest();
    }

}