@isTest(seeAllData = 'false')
public class WebChatGetTranscriptVariablesTracker {
    
    @isTest
    public static void testDataforLiveChatTranscript(){
        
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
        try{
            insert lct;
        }catch(Exception e){}
        system.debug('lct' + lct);
        
        test.startTest();
        //LiveChatTranscript newRec = [select id from LiveChatTranscript limit 1];
        
        WebChatGetTranscriptVariables.TranscriptInput input = new WebChatGetTranscriptVariables.TranscriptInput();
    	input.routableID = lct.id;

        List<WebChatGetTranscriptVariables.TranscriptInput> listInput = new List<WebChatGetTranscriptVariables.TranscriptInput>();
        listInput.add(input);
        
        WebChatGetTranscriptVariables.getUserName(listInput);
        
        test.stopTest();
        
    }

}