public class SettlementMismatchSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        SettlementMismatchSchedulable.sendMail();
    }
    
    public static Blob createCSVContent(Risk_Status_Detail__c[] lstRecords){
        String csvStringContent;
        try{
            List<String> fields = new List<String>{'Id','Opportunity__c','Current_Status__c','Hold_Type__c','Risk_Hold_Reason__c','RecordTypeId','Opportunity__r', 'Prod MID', 'Settlement Status'};
            String csvHeader = String.join(fields, ',') + '\n';
            csvStringContent = csvHeader;
            Integer recordListSize = lstRecords.size();
            for(Integer i=0;i<recordListSize;i++){
                Risk_Status_Detail__c sObj = lstRecords[i];
                Map<String, Object> dataMap = sobj.getPopulatedFieldsAsMap();
                for(Integer j=0;j<fields.size();j++){
                    String fieldAPIName = fields[j];
                    
                    Object fieldValue = dataMap.get(fieldAPIName);
                    if(fieldAPIName == 'Opportunity__r') {
                        Opportunity oppRec = (Opportunity )fieldValue;
                        
                        System.debug(oppRec.Prod_MID__c + ' ' + oppRec.Settlement_Status__c);
						csvStringContent += String.valueOf(oppRec).escapeCsv();
						csvStringContent += ',';
                        csvStringContent += oppRec.Prod_MID__c == null ? ''.escapeCsv() : oppRec.Prod_MID__c.escapeCsv();
						csvStringContent += ',';
                        csvStringContent += oppRec.Settlement_Status__c == null ? ''.escapeCsv() : oppRec.Settlement_Status__c.escapeCsv();
						csvStringContent += ',';                        
                       // csvStringContent = csvStringContent + String.valueOf(fieldValue).escapeCsv()                        
                    }else if(fieldValue != null){
                        csvStringContent = csvStringContent + String.valueOf(fieldValue).escapeCsv();
                    }else{
                        csvStringContent = csvStringContent + ''.escapeCsv();  
                    }
                    csvStringContent += ',';
                }
                csvStringContent += '\n';
            }
        }catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
        }
        return Blob.valueOf(csvStringContent);
    }
    
    public static void sendMail() {
        List<Risk_Status_Detail__c> obrisk = ([SELECT Id,CreatedDate, LastModifiedDate,Opportunity__r.settlement_status__c, Current_Status__c, Hold_Type__c, Opportunity__c, Opportunity__r.On_Post_Risk_Hold__c,Opportunity__r.On_OB_Hold__c, Opportunity__r.On_Pre_Risk_Hold__c, Risk_Hold_Reason__c FROM Risk_status_Detail__c where Hold_Type__c ='OB Hold' and ((Opportunity__r.On_OB_Hold__c ='N' and Current_Status__c = 'On Hold') or (Opportunity__r.On_OB_Hold__c ='Y' and Current_Status__c = 'Not On Hold') ) and opportunity__r.Blacklist__c != true ]);
        List<Risk_Status_Detail__c> riskhold = ([SELECT Id,CreatedDate, LastModifiedDate,Opportunity__r.settlement_status__c, Current_Status__c, Hold_Type__c, Opportunity__c, Opportunity__r.On_Post_Risk_Hold__c,Opportunity__r.On_OB_Hold__c, Opportunity__r.On_Pre_Risk_Hold__c, Risk_Hold_Reason__c FROM Risk_status_Detail__c where Hold_Type__c ='Post Hold' and ((Opportunity__r.On_Post_Risk_Hold__c ='N' and Current_Status__c = 'On Hold') or (Opportunity__r.On_Post_Risk_Hold__c ='Y' and Current_Status__c = 'Not On Hold') )  and opportunity__r.Blacklist__c != true]);
        List<Risk_Status_Detail__c> preriskhold = ([SELECT Id,CreatedDate, LastModifiedDate, Opportunity__r.settlement_status__c, Current_Status__c, Hold_Type__c, Opportunity__c, Opportunity__r.On_Post_Risk_Hold__c, Opportunity__r.On_OB_Hold__c, Opportunity__r.On_Pre_Risk_Hold__c, Risk_Hold_Reason__c FROM Risk_status_Detail__c where Hold_Type__c ='Pre Hold' and ((Opportunity__r.On_Pre_Risk_Hold__c ='N' and Current_Status__c = 'On Hold') or (Opportunity__r.On_Pre_Risk_Hold__c ='Y' and Current_Status__c = 'Not On Hold') ) and opportunity__r.Blacklist__c != true]);
        List<Risk_Status_Detail__c> noactive = ([SELECT Id,CreatedDate, LastModifiedDate, Opportunity__r.settlement_status__c,opportunity__r.Blacklist__c, Current_Status__c, Hold_Type__c, Opportunity__r.prod_mid__c, Opportunity__r.On_Post_Risk_Hold__c, Opportunity__r.On_OB_Hold__c, Opportunity__r.On_Pre_Risk_Hold__c, Risk_Hold_Reason__c  FROM Risk_status_Detail__c where opportunity__R.settlement_status__c='Risk Hold' and Opportunity__r.On_Post_Risk_Hold__c = 'N' and Opportunity__r.On_OB_Hold__c = 'N' and Opportunity__r.On_Pre_Risk_Hold__c = 'N' and opportunity__r.Blacklist__c != true]);
        List<Risk_Status_Detail__c> wrongactive = ([SELECT Id,CreatedDate, LastModifiedDate, Opportunity__r.settlement_status__c, Current_Status__c, Hold_Type__c, Opportunity__r.prod_mid__c, Opportunity__r.On_Post_Risk_Hold__c, Opportunity__r.On_OB_Hold__c, Opportunity__r.On_Pre_Risk_Hold__c, Risk_Hold_Reason__c  FROM Risk_status_Detail__c where opportunity__R.settlement_status__c !='Risk Hold' AND (Opportunity__r.On_Post_Risk_Hold__c = 'Y' OR Opportunity__r.On_OB_Hold__c = 'Y' OR Opportunity__r.On_Pre_Risk_Hold__c = 'Y') and opportunity__r.Blacklist__c != true]);        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> csvAttcList = new List<Messaging.EmailFileAttachment>();
        
        //ob hold csv
        
        if(obrisk.size() > 0) {
        Messaging.EmailFileAttachment csvAttcObhold = new Messaging.EmailFileAttachment();
        csvAttcObhold.setFileName('obhold.csv');
        csvAttcObhold.setBody(createCSVContent(obrisk));
        csvAttcList.add(csvAttcObhold);   
        }
        
        //risk hold csv
        
        if(riskhold.size() > 0) {
		Messaging.EmailFileAttachment csvAttcriskhold = new Messaging.EmailFileAttachment();
        csvAttcriskhold.setFileName('riskhold.csv');
        csvAttcriskhold.setBody(createCSVContent(riskhold));
        csvAttcList.add(csvAttcriskhold);            
        }        
        
        //pre risk hold csv
        
        if(preriskhold.size() > 0) {
        Messaging.EmailFileAttachment csvAttcpreriskhold = new Messaging.EmailFileAttachment();
        csvAttcpreriskhold.setFileName('preriskhold.csv');
        csvAttcpreriskhold.setBody(createCSVContent(preriskhold));
        csvAttcList.add(csvAttcpreriskhold);   
        }		

        //no active csv
        
        if(noactive.size() > 0) {
        Messaging.EmailFileAttachment csvAttcnoactive = new Messaging.EmailFileAttachment();
        csvAttcnoactive.setFileName('noactive.csv');
        csvAttcnoactive.setBody(createCSVContent(noactive));
        csvAttcList.add(csvAttcnoactive);   
        }		

        //wrongactive csv
        
        if(wrongactive.size() > 0) {
        Messaging.EmailFileAttachment csvAttcwrongactive = new Messaging.EmailFileAttachment();
        csvAttcwrongactive.setFileName('wrongactive.csv');
        csvAttcwrongactive.setBody(createCSVContent(wrongactive));
        csvAttcList.add(csvAttcwrongactive);   
        }		
        
        User toUser = [Select Id From User Where Name = 'David Simon'];
     
        List<String> toMails = new List<String>();
		mail.targetobjectid = toUser.Id;
		mail.saveAsActivity = false;
        mail.setSubject('Daily Settlement Status Mismatch Details');
        String body = 'OB Risk -> ' + obrisk.size() + '<br>';
        body += 'Risk Hold -> ' + riskhold.size() + '<br>';
        body += 'Pre Risk Hold -> ' + preriskhold.size() + '<br>';
        body += 'Risk Opps with No Active Hold -> ' + noactive.size() + '<br>';
        body += 'Active Opps with Risk Hold -> ' + wrongactive.size() + '<br>';
        mail.setHtmlBody(body);
        mail.setFileAttachments(csvAttcList);
        Messaging.sendEmail(new List<Messaging.singleEmailMessage>{mail});
    }
    
}