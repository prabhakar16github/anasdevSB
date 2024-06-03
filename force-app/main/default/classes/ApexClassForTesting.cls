public class ApexClassForTesting {
    
    
    /** variables setting from constructor **/
    private string fileData; /** File content coming from GMVUploadEmailServiceController Email service class */
    private string fileName; /** File Name coming from GMVUploadEmailServiceController Email service class */
    private String enforcedById;/** userId of email sender */
    private String fromAddress;/** email address of email sender */
    /** */
    
    private Map<String,Object> fieldMapping;/** field mapping defined in 'CSV_Header_To_SF_Field_Mapping__mdt' metadata. */
    
    /** for CSV reading */
    private static FINAL String rowDelimiterMatcher = '@LINE_BREAK@'; 
    private static FINAL String uniqueDelimiter = '!@#&*:';
    /** */
    
    private static FINAL String PROCESS_NAME = 'Bulk_RiskHold';
    
    /** Map of boolean value */
    private static FINAL Map<String,Boolean> stringToBooleanMap = new Map<String,Boolean>{'Y'=>True,'N'=>False,'y'=>True,'n'=>False};
        
        /** Map of hold type & record type name */
        private static FINAL Map<String,String> holdTypeToRecordTypeMap = new Map<String,String>{'Post Hold'=>'Post Risk','Pre Hold'=>'Pre Risk','OB Hold'=>'Ob Risk'};
            
            
            
            String mailBody='';
    
    /** list for storing opportunity ids of incorrect MID****/
    List<String> oppList=new List<String>();//
    
    /** Constructor */
    public ApexClassForTesting(Blob fileContentBlob,String csvFileName,String fromUserId,String fromAddress){
        this.fileData = fileContentBlob.toString();
        this.fileData = this.fileData.replaceAll('(\r\n|\r)','\n');
        this.fileName = csvFileName;
        this.enforcedById = fromUserId;
        this.fromAddress = fromAddress;
        system.debug('<<<<<<fileData>>>'+fileData);
        List<CSV_Header_To_SF_Field_Mapping__mdt> metadataList = [SELECT Id,DeveloperName,Field_Mapping__c FROM CSV_Header_To_SF_Field_Mapping__mdt 
                                                                  WHERE DeveloperName = :PROCESS_NAME 
                                                                  LIMIT 1];
        if(!metadataList.isEmpty() && String.isNotBlank(metadataList[0].Field_Mapping__c)){
            fieldMapping = (Map<String,Object>)JSON.deserializeUntyped(metadataList[0].Field_Mapping__c);
        }else{
            Error_Details__c errorDetails = new Error_Details__c(Process__c = PROCESS_NAME,Message__c = 'CSV to SF field mapping is not present in the system.',Severity__c = 'High', Identifier__c = 'Field mapping missing');
            insert errorDetails;
        }
        
    }/** END */
    
    
    
    /** Execute */
    public void processFile(){
        
        
        try{
            List<String> scope = this.fileData.split('@LINE_BREAK@');
            System.debug('scope>>>>>'+scope);
            System.debug('scope>>>>>'+scope.size());
            List<Risk_status_Detail__c> sobjectListToUpsert = new List<Risk_status_Detail__c>();
            Map<Id,Risk_status_Detail__c> riskStatusMap = new Map<Id,Risk_status_Detail__c>();
            Map<String,String> oppIdToMidMAPFromCsv = new Map<String,String>();
            Map<String,String> oppIdToMidMAP = new Map<String,String>();
            
            
            for(Integer i=0;i<scope.size();i++){
                System.debug(' scope[i]>>>>>'+ scope[i]);
                if(i>0 && scope[i] != NULL){
                    List<String> fieldValueList = getValidData(scope[i]).split(',');
                    System.debug('fieldValueList>>>>>'+fieldValueList.size());
                    String mid;
                    String oppId;
                    
                    
                    if(String.isNotBlank(fieldValueList[0])){
                        mid=fieldValueList[0].replace('\n','');//
                        oppId=fieldValueList[1];
                        
                        oppIdToMidMAPFromCsv.put(oppId,mid);
                    }else{
                        oppIdToMidMAPFromCsv.put(oppId,NULL);
                        
                    }
                    
                }
                
            }
            
            if(oppIdToMidMAPFromCsv.keySet().size() > 0){
                for(Opportunity opp : [Select Id,Prod_MID__c FROM Opportunity where Id In :oppIdToMidMAPFromCsv.keySet()]){
                    oppIdToMidMAP.put(opp.Id,opp.Prod_MID__c);
                    
                }                
            }
            
            
            for(Integer i=0;i<scope.size();i++){
                
                if(i>0 && scope[i] != NULL){
                    
                    List<String> fieldValueList = getValidData(scope[i]).split(',');
                    String mid=fieldValueList[0].replace('\n','');//
                    String oppId=fieldValueList[1];//
                    String correctMID = '';
                    //List<Opportunity> correctData=[Select Prod_Merchant_Id__c FROM Opportunity where Id = :oppId];//
                    if(oppIdToMidMAP.containsKey(oppId)){
                        correctMID = oppIdToMidMAP.get(oppId);
                        
                    }
                    Boolean isMIDCorrect=false;//
                    if(mid == correctMID){//
                        isMIDCorrect=true;
                    }
                    
                    
                    Risk_status_Detail__c sObj = get_Risk_Object(fieldValueList);
                    
                    if(sObj != NULL && isMIDCorrect==true){
                        sobjectListToUpsert.add(sobj);
                    }
                    else if(isMIDCorrect==false){
                        oppList.add(oppId);
                        oppList.add(mid);
                    }
                    
                }
            }
            
            
            
            if(!sobjectListToUpsert.isEmpty()){
                
                Schema.SObjectField externalIdField = Risk_status_Detail__c.fields.Unique_Identifier__c ;
                List<Database.upsertResult> upsertResults = Database.upsert(sobjectListToUpsert, externalIdField,false);
                
                generateErrorLogsForFailedRecods(upsertResults,sobjectListToUpsert,oppIdToMidMAP);
                
            }
        }catch(Exception ex){
            Error_Details__c errorDetails = new Error_Details__c(Process__c = PROCESS_NAME,Message__c = ex.getMessage() + ' - '+ex.getLineNumber(),Severity__c = 'High', Identifier__c = fileName);
            insert errorDetails;
        }
    }/** Execute END */
    
    /** Finish */
    /*public void finish(Database.BatchableContext bc){
        String bodySentInMail='Mid,Opportunity,Change Status,fail reason\n';
        bodySentInMail+=mailBody;
        system.debug('<<<<<<mailBody>>>>>>'+mailBody);
        sendEmail(userinfo.getUserId(),'MID RISK CHANGE STATUS',bodySentInMail);
        
        
    }*/
    /** END */
    
    /**
* Method to manipulate the data row to avoid any data issue (e.g.- String ends with comma and comma in between quotes[" "] ).
* @param - csv data row in comma delimited string.
* return - csv row data after removing exceptionally possible data issue.
*/
    private String getValidData(String dataRow){
        Map<String,String> strMap = new Map<String,String>();
        system.debug('<<<<dataRow>>>'+dataRow);
        if(dataRow.endsWith(',')){
            dataRow += '-';
        }
        String tempStr = dataRow;
        system.debug('<<<<tempStr>>>'+tempStr);
        while(tempStr.contains('"')){
            String subStr = tempStr.substringBetween('"', '"');
            //  if(subStr !=null && subStr.length()>0){
            strMap.put('"'+subStr+'"',subStr.replaceAll(',',uniqueDelimiter));
            tempStr = tempStr.remove('"'+subStr+'"');
            // }
        }
        
        for(String key : strMap.keySet()){
            if(dataRow.contains(key)){
                dataRow = dataRow.replace(key,strMap.get(key));
            }
        }
        return dataRow;
    }/** END */
    
    /**
* Method to get the Risk Status Detail object 
* @param - List of csv rows with data
* return - instance of Risk Status Detail object 
*/
    private Risk_status_Detail__c get_Risk_Object( List<String> fieldValueList){
        Risk_status_Detail__c sobj = new Risk_status_Detail__c();
        for(String field : fieldMapping.keySet()){
            Map<String,Object> fieldDetailMap = (Map<String,Object>)fieldMapping.get(field);
            String fieldAPIName = (String)fieldDetailMap.get('fieldName');
            Integer fieldIndex = Integer.valueOf(fieldDetailMap.get('index'));
            String fieldType = (String)fieldDetailMap.get('type');
            if(fieldIndex != 0 && String.isNotBlank(fieldValueList[fieldIndex]) && fieldValueList[fieldIndex] != '-'){
                if(fieldValueList[fieldIndex].contains(uniqueDelimiter)){
                    fieldValueList[fieldIndex] = fieldValueList[fieldIndex].replace(uniqueDelimiter, ',');
                }
                if(fieldType == 'Number'){
                    sobj.put(fieldAPIName,Double.valueOf(fieldValueList[fieldIndex]) );
                }else if(fieldType == 'Date'){
                    sobj.put(fieldAPIName,Date.valueOf(fieldValueList[fieldIndex]) );
                }else if(fieldType == 'Boolean'){
                    sobj.put(fieldAPIName,Boolean.valueOf(stringToBooleanMap.get(fieldValueList[fieldIndex])) );
                }else{
                    sobj.put(fieldAPIName, String.valueOf(fieldValueList[fieldIndex]));
                }
                sobj.put('Unique_Identifier__c',sobj.get('Hold_Type__c')+'@@'+sobj.get('Opportunity__c'));
                sobj.put('RecordTypeId',getRecordTypeIdFromHoldType((String)sobj.get('Hold_Type__c')));
                sobj.put('Enforced_By__c',this.enforcedById);
            }
        }
        return sobj;
    }/** END */
    
    /** Private method to get the record type from hold type */
    private String getRecordTypeIdFromHoldType(String holdType){
        if(String.isNotBlank(holdType)){
            return Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get(holdTypeToRecordTypeMap.get(holdType)).getRecordTypeId();
        }
        return NULL;
    }/** END */
    
    /*
* Method to generate error logs for failed records while upsert.
* @param - upsertResult, List of record for upsert.
* return - void 
*/
    @TestVisible
    private void generateErrorLogsForFailedRecods(List<Database.upsertResult> upsertResults,List<Risk_status_Detail__c> sobjectListToUpsert,Map<String,String> oppIdToMidMAP){
        Map<String,List<String>> UniqueIdToErrorMap = new Map<String,List<String>>();
        String bodySuccess = '';
        String bodyFail = '';
        Map<Id,String> mapIdToMID = new Map<Id,String>();
        
        for(Integer i=0;i<upsertResults.size();i++){
            String prodMID = '';
            
            if(oppIdToMidMAP.containsKey(sobjectListToUpsert[i].Opportunity__c)){
                prodMID = oppIdToMidMAP.get(sobjectListToUpsert[i].Opportunity__c);
            }
            //List<Opportunity> Data = [Select Prod_Merchant_Id__c FROM Opportunity where Id = :sobjectListToUpsert[i].Opportunity__c];
            mapIdToMID.put(sobjectListToUpsert[i].Opportunity__c, prodMID);
            
        }
        
        for(Integer i=0;i<upsertResults.size();i++){
            if(!upsertResults[i].isSuccess()){
                List<String> listRecord = new List<String>();
                
                
                String uniqueId = sobjectListToUpsert[i].Hold_Type__c+'@@'+sobjectListToUpsert[i].Opportunity__c;
                String errMessage = String.valueOf(upsertResults[i].getErrors());
                string errString = errMessage.replaceAll('[\n\r ,]', '');    
                bodyFail+= mapIdToMID.get(sobjectListToUpsert[i].Opportunity__c) +','+sobjectListToUpsert[i].Opportunity__c +','+'Fail'+','+errString+'\n';               
                if(UniqueIdToErrorMap.containsKey(uniqueId)){
                    listRecord = UniqueIdToErrorMap.get(uniqueId);
                }
                
                
                listRecord.add(String.valueOf(upsertResults[i].getErrors()));
                UniqueIdToErrorMap.put(uniqueId ,listRecord);
            }
            else {
                
                bodySuccess+= mapIdToMID.get(sobjectListToUpsert[i].Opportunity__c) +','+sobjectListToUpsert[i].Opportunity__c +','+'Success'+'\n';
                
                
            }
        }
        for(Integer i=0;i<oppList.size();i=i+2){
            bodyFail+=oppList[i]+','+oppList[i+1]+','+'Fail'+','+'MID and Opportunity do not match in system'+'\n'; 
        }
        
        if(!UniqueIdToErrorMap.keySet().isEmpty()){
            Error_Details__c errorDetails = new Error_Details__c(Process__c = PROCESS_NAME,Message__c = 'Record Failed during upsert',Severity__c = 'High', Response__c = JSON.serialize(UniqueIdToErrorMap),Identifier__c = fileName);
            insert errorDetails;
        }
        mailBody+=bodySuccess+bodyFail;
        
    }
    /*****Method to send mail with attached CSV file*****/
    private void sendEmail(String recipient, String subject, String body) {
        
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(body);
        string csvname= 'Response of'+fileName;
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {fromAddress};
            String subject1 ='Response of'+fileName;
        email.setSubject(subject1);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Response of'+fileName);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        /*********************Sends the email message using the salesforce Messaging framework End*******************/ 
    }
    
}