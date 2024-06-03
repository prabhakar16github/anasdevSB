// created by Arka Patra
public with sharing class WhatsappBot_MessagingContact {
    
    public class MessagingInput {
    @InvocableVariable(required=false)
    public ID endUserID;
    }
    
    public class MessagingOutput {
    @InvocableVariable(required=false)
    public String sContactName;
    }
    
    private static String scrubPhoneNumber(String rawNumber) {
        if (rawNumber==null){
            return null;
        }
        
        // Remove all non-digit values.
        String scrubbedNumber = rawNumber.replaceAll('[^0-9]','');
        return scrubbedNumber;
    }
    
    @InvocableMethod(label='Find Contact for Messaging Whatsapp')
    public static List<MessagingOutput> getUserName(List<MessagingInput> inputs) {
        List<MessagingOutput> outputs = new List<MessagingOutput>();
        for(MessagingInput input : inputs){
            // Create a variable to store the user name.
            String name = 'Stranger';
            
            // Get messaging end user record from ID.
            List<MessagingEndUser> messagingUsers = [SELECT Id, Name
                                                    FROM MessagingEndUser
                                                    WHERE Id = :input.endUserID
                                                    LIMIT 1];
            
            // Did we find an existing user?
            if(!messagingUsers.isEmpty()){
                // Strip out any invalid values from the phone number.
                String phoneNumber = scrubPhoneNumber(messagingUsers[0].Name);
                
                // Get the contact based on the phone nummber.
                List<Contact> contacts = [SELECT Name
                                         FROM Contact
                                         WHERE Phone = :phoneNumber
                                         LIMIT 1];
                
                // Did we find the contact?
                if(!contacts.isEmpty()){
                    // Grab the name of the contact.
                    name = contacts[0].Name;
                }
            }
            
            // Store the name in an output variable.
            MessagingOutput output = new MessagingOutput();
            output.sContactName = name;
            
            // Add the name to the list of outputs.
            outputs.add(output);
        }
        return outputs;
    }
}