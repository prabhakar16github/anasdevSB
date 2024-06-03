public class buyerPreChatData {
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID contactId;
        
        @InvocableVariable(required=true)
        public ID routableID;
        
        /*@InvocableVariable(required=true)
        public String dashboardTicketID;*/
    }
    
    public class VisitorNameOutput {
        @InvocableVariable(required=true)
        public String sFirstName;
        
        @InvocableVariable(required=true)
        public String sTransactionId;
        
        @InvocableVariable
        public String sEmail;
        
        @InvocableVariable
        public String sPhone;
        
        @InvocableVariable
        public String sTicketId;
    }
    
    @InvocableMethod(label='Get Pre Chat User Name')
    public static List<VisitorNameOutput> getPreChatUserName(List<TranscriptInput> transcripts) {
        
        List<VisitorNameOutput> names = new List<VisitorNameOutput>();
        system.debug('transcripts '+transcripts);
        
        for (TranscriptInput transcript : transcripts) {
            
            // Query for the transcript record based on the ID
            LiveChatTranscript transcriptRecord = [SELECT Name, FirstName__c, TransactionId__c
                                                        FROM LiveChatTranscript 
                                                        WHERE Id = :transcript.routableID 
                                                        LIMIT 1];
            
            Contact transcriptContactRecord = [SELECT Name, FirstName, LastName, Email, Phone
                                        FROM Contact 
                                        WHERE Id = :transcript.contactId 
                                        LIMIT 1];
            
           // list<case> caseLst = new list<case>();
           /* Integer limitRows = Limits.getQueryRows() - Limits.getLimitQueryRows();
            List<Case> caseDetails = [SELECT Id, TicketId__c
                                      FROM Case
                                      //WHERE LP_Transaction_ID__c = '123321'
                                      WHERE LP_Transaction_ID__c = :transcriptRecord.TransactionId__c
                                      AND LP_Transaction_ID__c != NULL
                                      AND IsClosed = FALSE
                                      LIMIT :limitRows];*/
            
             List<Case> caseDetails = [SELECT Id, TicketId__c
                                      FROM Case
                                      WHERE LP_Transaction_ID__c = :transcriptRecord.TransactionId__c
                                      AND IsClosed = FALSE
                                      LIMIT 50000];
            
                
            System.debug('transcriptContactRecord '+transcriptContactRecord);
            
            // Store the first name in an output variable
            VisitorNameOutput nameData = new VisitorNameOutput();
            nameData.sFirstName = transcriptContactRecord.FirstName;
            nameData.sEmail = transcriptContactRecord.Email;
            nameData.sPhone = transcriptContactRecord.Phone;
            nameData.sTransactionId = transcriptRecord.TransactionId__c;
            nameData.sTicketId = caseDetails.isEmpty()? Null : casedetails[0].TicketId__c;
            
            /*if (!caseDetails.isEmpty()) {
               nameData.sTicketId = casedetails[0]?.TicketId__c;
            } else {
            nameData.sTicketId = casedetails[0]?.TicketId__c;
            }*/
            // Add the name to the list of outputs
            names.add(nameData);
            
            System.debug('names'+names);
        }
        
        return names;
    }
}