@isTest
public class Whatsapp_MessagingContentTypeTracker {
    
    @isTest
    public static void testData1(){
        
        MessagingEndUser msgEndUser = new MessagingEndUser();
        msgEndUser.MessagingChannelId = System.label.MessagingChannelId;
        msgEndUser.Name = 'test:+919999999999';
        msgEndUser.messageType = 'WhatsApp';
        msgEndUser.MessagingPlatformKey = 'test:+919999999999';
        insert msgEndUser;
        
        Test.startTest();
        Whatsapp_MessagingContentType.MessagingInput input = new Whatsapp_MessagingContentType.MessagingInput();
        input.endUserID = msgEndUser.id;
        
        List<Whatsapp_MessagingContentType.MessagingInput> listInput = new List<Whatsapp_MessagingContentType.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_MessagingContentType.getMessagingContent(listInput);
        
        test.StopTest();
    }

}