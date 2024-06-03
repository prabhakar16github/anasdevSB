public class WebChatGetTranscriptVariables {
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
        
        @InvocableVariable
        public string msat;
        
        @invocableVariable(required=true)
        public String chatStart;
        
        /*@invocableVariable
        public String Intent;*/
        
    }
    
    public class VisitorNameOutput {
        @InvocableVariable
        public String sFirstName ;
        
        @InvocableVariable
        public String sMID;
        
        @InvocableVariable
        public String sProduct ;
        
        @InvocableVariable
        public String spageName;
    }
    
    @InvocableMethod(label='Get User Name')
    public static List<VisitorNameOutput> getUserName(List<TranscriptInput> transcripts) {
        
      // List<TranscriptInput> transcripts = new List<TranscriptInput>();
      // TranscriptInput obj = new TranscriptInput();
      // obj.routableID=(ID)'5700p00000011ENAAY';
      // obj.chatStart = 'true';
      // transcripts.add(obj);
        
        List<VisitorNameOutput> names = new List<VisitorNameOutput>();
        Map<String,TranscriptInput> routableIdTranscriptMap = new Map<String,TranscriptInput>();
        List<LiveChatTranscript> ChatTranscriptList = new List<LiveChatTranscript>();
        
        for (TranscriptInput transcript : transcripts) {
            system.debug('transcript.routableID =='+transcript.routableID);
            routableIdTranscriptMap.put(transcript.routableID,transcript);
            
        }
        
        // Query for the transcript record based on the ID Product__c,MID__c
        LiveChatTranscript transcriptRecord = [SELECT Name,FirstName__c,Product__c,MID__c,pageName__c,MSAT__c
                                               FROM LiveChatTranscript
                                               WHERE Id = :routableIdTranscriptMap.keySet()
                                               LIMIT 1];
        if(transcriptRecord != null){
            // Store the first name in an output variable
            //if(routableIdTranscriptMap.get(transcriptRecord.Id).chatStart){
                VisitorNameOutput nameData = new VisitorNameOutput();
                system.debug('transcriptRecord.FirstName__c=='+transcriptRecord.FirstName__c);
                nameData.sFirstName = transcriptRecord.FirstName__c;
                nameData.sMID = transcriptRecord.MID__c;
                nameData.sProduct = transcriptRecord.Product__c;
                nameData.spageName = transcriptRecord.pageName__c;
                
                // Add the name to the list of outputs
                names.add(nameData);
                system.debug('nameData==='+nameData.sFirstName);
            //}
            if(routableIdTranscriptMap.get(transcriptRecord.Id).chatStart == 'false'){
                transcriptRecord.MSAT__c = routableIdTranscriptMap.get(transcriptRecord.Id).msat;
                ChatTranscriptList.add(transcriptRecord);
            }
        }
        if(ChatTranscriptList != null && ChatTranscriptList.size() >0 ){
            update ChatTranscriptList;
        }
        System.debug(names);
        return names;
        
    }   
}