global class whatsappOutboundUtilityBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    global List<string> recordId;
    
    global whatsappOutboundUtilityBatch(List<String> recordId){
        this.recordId = recordId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        string strQuery = 'SELECT Id, Mobile__c,templateId__c, First_Name__c,Last_Name__c  FROM Opportunity where id =:recordId' ;
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList){
        String devName = 'WhatsappOutbound';
        getWhatsappOutBoundResponse(devName,oppList);
    }
    
    
    global void finish(Database.BatchableContext bc){}
    
    
    public static void getWhatsappOutBoundResponse(String devName, List<Opportunity> oppList){
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c FROM Integration_Setting__mdt WHERE DeveloperName =: devName];
        System.debug('integration setting meta >>>>>>>>>>>>>>-------------'+insList);
        if(!insList.isEmpty() && insList.size()>0){                        
            
            String endPointUrl = insList[0].EndPointUrl__c; 
            String headers = insList[0].Headers__c;
            List<String> strList = insList[0].Body__c.Split(',');
            String key = strList[0];
            String salt = strList[1];
            String command = 'send_communication';
            String var1 = triggerWhatappUpdates(oppList[0]);
            String Body = String.join(new List<String>{key,command,var1,salt},'|');
            string str = EncodingUtil.convertToHex(crypto.generateDigest('SHA512', Blob.valueOf(Body)));
            
            List<String> StringList = new List<String>();
            
            StringList.add('command='+EncodingUtil.urlEncode(command, 'UTF-8'));
            StringList.add('key='+EncodingUtil.urlEncode(key, 'UTF-8'));
            StringList.add('hash='+EncodingUtil.urlEncode(str, 'UTF-8'));
            StringList.add('var1='+EncodingUtil.urlEncode(var1, 'UTF-8'));
            
            String requestBody  = string.join(StringList, '&');
            
            
            HttpRequest req = new HttpRequest();
            req.setHeader(headers.subStringBefore(':'),headers.subStringAfter(':')); 
            req.setMethod(insList[0].Method__c);
            req.setEndpoint(endPointUrl);
            req.setBody(requestBody);
            HttpResponse res = new system.http().send(req);
            system.debug('Response=='+res.getBody());
            system.debug('Response Status=='+ res.getStatus() +' '+ res.getStatusCode());
            
        }
        //return null;
    }
    
    public static String triggerWhatappUpdates(Opportunity opp){
        
        WhatsappSetting__mdt payloadMeta = [SELECT MasterLabel, WhatsApp_TemplateId__c, Sms_TemplateId__c, Channel__c, SMS_Payload__c, WhatsApp_Payload__c FROM WhatsappSetting__mdt where MasterLabel = :opp.TemplateId__c limit 1];
        
        String mobile = opp.Mobile__c;
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(mobile != null) gen.writeStringField('destination',mobile);
        if(payloadMeta.WhatsApp_TemplateId__c != null) gen.writeStringField('whatsAppTemplateId',payloadMeta.WhatsApp_TemplateId__c);
        if(payloadMeta.Sms_TemplateId__c != null) gen.writeStringField('smsTemplateId',payloadMeta.Sms_TemplateId__c);
        if(payloadMeta.Channel__c != null) gen.writeStringField('channel',payloadMeta.Channel__c);
        
        if(payloadMeta.SMS_Payload__c != null){
            list<string> smspayload = payloadMeta.SMS_Payload__c.Split(',');
            gen.writeFieldName('smsPayload');
            gen.writeStartObject();
            gen.writeObjectField('placeholders',smspayload);
            gen.writeEndObject();
        }
        
        if(payloadMeta.WhatsApp_TemplateId__c != null){
            list<string> whatsappayload = payloadMeta.WhatsApp_Payload__c.Split(',');
            String Name = opp.First_Name__c +' '+opp.Last_Name__c;
            List<string> merchantName = new List<string>{Name};
                gen.writeFieldName('whatsAppPayload');
            gen.writeStartObject();
            gen.writeObjectField('placeholders',merchantName);
            
            gen.writeEndObject();
        }
        
        gen.writeEndObject();
        
        String var = gen.getAsString() ;
        system.debug('var==='+var);
        return var;
    }
    
}