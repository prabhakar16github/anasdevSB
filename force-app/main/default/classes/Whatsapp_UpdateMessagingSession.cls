public class Whatsapp_UpdateMessagingSession {
    
    public class MessagingInput {
        @InvocableVariable(required=true)
        public String messagingSessionId;
        
        @InvocableVariable(required=true)
        public String CaseId;
        
    }
    
    public class MessagingOutput{
        @InvocableVariable(required=false)
        public Boolean isUpdated;
    }
    
    @InvocableMethod(label='Update Messaging Session')
    public static List<MessagingOutput> updateMsgSession(List<MessagingInput> inputs) {
        
        MessagingInput input = inputs[0];
        List<MessagingOutput> outputs = new List<MessagingOutput>();
        MessagingSession msgSes = new MessagingSession();
        system.debug('input.messagingSessionId='+input.messagingSessionId);
        List<MessagingSession> msgsession = [SELECT Id, Name, CaseId
                                             FROM MessagingSession
                                             WHERE id = :input.messagingSessionId
                                             LIMIT 1];
        
        if(msgsession != null && msgsession.size() > 0){
            msgSes.caseId = input.caseId;
            msgSes.Id = msgsession[0].id;
            GuestUserUtilityHelper.updateObject(msgSes);
            MessagingOutput output = new MessagingOutput();
            output.isUpdated = true;
            outputs.add(output);
            
        }
        return outputs;
    }
    
    
    
}