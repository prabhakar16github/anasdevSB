@isTest
public class Whatsapp_getTicketCreationDetailsTracker {
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
        Whatsapp_getTicketCreationDetails.MessagingInput input = new Whatsapp_getTicketCreationDetails.MessagingInput();
        input.endUserID = msgEndUser.id;
        input.Issue = 'Account related';
        input.subIssue = 'Other';
        
        
        List<Whatsapp_getTicketCreationDetails.MessagingInput> listInput = new List<Whatsapp_getTicketCreationDetails.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_getTicketCreationDetails.fetchMobileNumber(listInput);
        
        test.StopTest();
    }
    /*@isTest
    public static void testData2(){
        
        Test.startTest();
        Whatsapp_generateOptionIndex.MessagingInput input = new Whatsapp_generateOptionIndex.MessagingInput();
        input.OptionIndex = '6';
        
        
        List<Whatsapp_generateOptionIndex.MessagingInput> listInput = new List<Whatsapp_generateOptionIndex.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_generateOptionIndex.generateOptionIndex(listInput);
        
        test.StopTest();
    }*/
    
}