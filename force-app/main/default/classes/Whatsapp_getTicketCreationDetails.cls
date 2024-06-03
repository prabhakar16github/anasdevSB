public class Whatsapp_getTicketCreationDetails {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public ID endUserID;
        @InvocableVariable(required=False)
        public string Issue;
        @InvocableVariable(required=False)
        public string subIssue;
        
        
    }
    
    public class MessagingOutput {
        @InvocableVariable(required=false)
        public string Mobile;
        @InvocableVariable(required=False)
        public string Issue;
        @InvocableVariable(required=False)
        public string subIssue;
        
        
    }
    
    
    @InvocableMethod(label='Find ticket creation for Messaging User')
    public static List<MessagingOutput> fetchMobileNumber(List<MessagingInput> inputs) {
        MessagingOutput output = new MessagingOutput();
        MessagingInput input = inputs[0];
        //Get the messaging end user record from the ID
            List<MessagingEndUser> messagingUsers = [SELECT Id, Name
                                                     FROM MessagingEndUser
                                                     WHERE Id = :input.endUserID
                                                     LIMIT 1];
            //Did we find the messaging user?
            if (!messagingUsers.isEmpty()) {
                output.mobile = messagingUsers[0].Name.split(':')[1];
                output.Issue = inputs[0].Issue;
                output.subIssue = inputs[0].subIssue;
                
                // Get the contact/lead/Opportunity based on the phone number
                system.debug('phoneNumber==='+output.mobile);
            }
        List<MessagingOutput> outputs = new List<MessagingOutput>();
        outputs.add(output);
        return outputs;        
    }
        

}