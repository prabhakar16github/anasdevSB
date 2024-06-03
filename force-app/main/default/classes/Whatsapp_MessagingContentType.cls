public class Whatsapp_MessagingContentType {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public String endUserID;
    }
    
    public class MessagingOutput {
        @InvocableVariable(required=false)
        public String sContentType;
        
    }
    
    @InvocableMethod(label='Find Content Type for Messaging Session')
    public static List<MessagingOutput> getMessagingContent(List<MessagingInput> inputs) {
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        MessagingOutput output = new MessagingOutput();
        List<MessagingOutput> outputList = new List<MessagingOutput>();
        
        
       
        for (MessagingInput input : inputs) {
            system.debug('inputs==='+input.endUserID);
            
            if(input.endUserID != null && string.isNotBlank(input.endUserID)){
                output.sContentType = 'text message' ;
            }
            else{
                output.sContentType = 'Attachment';
            }
        }
        
        outputList.add(output);
        
        return outputList;
    }
    
}