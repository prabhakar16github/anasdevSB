// Created by Arka Patra
public with sharing class WhatsappBot_GetTranscriptVariables {
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
    }
    
    public class WhatsappNumberOutput {
        @InvocableVariable(required=true)
        public String sWhatsappNumber;
    }
    
    @InvocableMethod(label='Whatsapp Number Fetch')
    public static List<WhatsappNumberOutput> getWhatsappNumber(List<TranscriptInput> transcripts) {
        List<WhatsappNumberOutput> phones = new List<WhatsappNumberOutput>();
        
        for(TranscriptInput transcript : transcripts) {
            // Query on transcript record based on the ID.
            system.debug('transcript.routableID = '+transcript.routableID);
            LiveChatTranscript transcriptRecord = [SELECT Name, Whatsapp_Number__c
                                                  FROM LiveChatTranscript
                                                  WHERE Id = :transcript.routableID
                                                  LIMIT 1];
            // Store Whatsapp Number in output variable
            if(transcriptRecord!=null){
                WhatsappNumberOutput phoneNo = new WhatsappNumberOutput();
                phoneNo.sWhatsappNumber = transcriptRecord.Whatsapp_Number__c;
                System.debug('OK');
                System.debug('Name = '+transcriptRecord.Name);
                System.debug('phoneNo = ' + transcriptRecord.Whatsapp_Number__c);
           	 	// Add the whatsapp number o the list of outputs.
                phones.add(phoneNo);
            }
            else{
                system.debug('null');
            }
        }
        return phones;
    }
}