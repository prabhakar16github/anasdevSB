@isTest(seeAllData='false')
public class WhatsappBot_TestTranscriptVariables {
  @isTest
  public static void testLiveChatTranscript(){
        
        /*
            insert Live Chat Visitor
        */
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
        /*
            insert Live Chat Transcript
        */
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
      	lct.Whatsapp_Number__c = '1223434343';
        try{
            insert lct;
        }catch(Exception e){}
        system.debug('lct' + lct);
        
        test.startTest();
        //LiveChatTranscript newRec = [select id from LiveChatTranscript limit 1];
        
        WhatsappBot_GetTranscriptVariables.TranscriptInput input = new WhatsappBot_GetTranscriptVariables.TranscriptInput();
    	input.routableID = lct.id;

        List<WhatsappBot_GetTranscriptVariables.TranscriptInput> listInput = new List<WhatsappBot_GetTranscriptVariables.TranscriptInput>();
        listInput.add(input);
        
        WhatsappBot_GetTranscriptVariables.getWhatsappNumber(listInput);
        
        test.stopTest();
        
    }
}