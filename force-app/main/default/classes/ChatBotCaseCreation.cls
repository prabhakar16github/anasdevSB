public class ChatBotCaseCreation {
    
    public class TicketInfo {
        
        @InvocableVariable
        public string sName;
        
        @InvocableVariable
        public string sEmail;
        
        @InvocableVariable
        public string sComments;
        
        @InvocableVariable
        public string sMonthlyExpectedSales;
        
        @InvocableVariable
        public string RoutableId;
        
    }
    
    public class TicketIdInfo {
        @InvocableVariable
        public String sErrorMsg;
        
    }
    
    
    @InvocableMethod(label='IssueSubIssue Validation')
    public static List<TicketIdInfo> createCase(List<TicketInfo> merchantDetails){
        
         List<TicketIdInfo> TicketInfoOut = new List<TicketIdInfo>();
        
        system.debug('routableid=='+merchantDetails[0].RoutableId);
        
        if(!String.isBlank(merchantDetails[0].RoutableId)){
           List<Bot__c> botRec = [Select Issue__c, Sub_Issue__c from Bot__c where Chat_Transcript_Id__c = :merchantDetails[0].RoutableId order by createdDate desc Limit 1];
           TicketIdInfo TicketIdInfoOutRec = new TicketIdInfo();
            
            if(botRec.isEmpty()){
                
                TicketIdInfoOutRec.sErrorMsg = 'Please select Issue/Sub Category Issue first';
            }
            
            else{
                system.debug('enter first if');
                system.debug('botRec Issue=='+botRec[0].Issue__c);
                system.debug('bot Rec sub Issue=='+botRec[0].Sub_Issue__c);
                LiveChatTranscript transcriptRecord = [SELECT Name,Issue__c, Sub_Issue__c FROM LiveChatTranscript 
                                                  WHERE Id = :merchantDetails[0].RoutableId
                                               	  LIMIT 1];
                if(botRec[0].Issue__c != null && !String.isBlank(botRec[0].Issue__c)
                   && botRec[0].Sub_Issue__c != null && !String.isBlank(botRec[0].Sub_Issue__c)) {
                       transcriptRecord.Issue__c = botRec[0].Issue__c;
                       transcriptRecord.Sub_Issue__c = botRec[0].Sub_Issue__c;
                       update transcriptRecord;
                       TicketIdInfoOutRec.sErrorMsg = '';
                   }
                
                else{
                    TicketIdInfoOutRec.sErrorMsg = 'Please select Issue/Sub Category Issue first';
                }
                
            }
            
            TicketInfoOut.add(TicketIdInfoOutRec);
            
        }
        
        return TicketInfoOut;
        
        
    }

}