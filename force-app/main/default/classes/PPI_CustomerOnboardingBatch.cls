/**
* @Class Name   :   PPI_CustomerOnboardingBatch
* @Description  :   Batch class to upsert the PPI Customer Record from the encrypted CSV file coming from SFTP [Wibmo].
* @Auther       :   Prabhakar Joshi
* @Group        :   PPI Customer  
*/
public class PPI_CustomerOnboardingBatch implements Database.batchable<String>, Database.Stateful {
    
    private string fileData; /** File content coming from GMVUploadEmailServiceController Email service class */
    private string fileName; /** File Name coming from GMVUploadEmailServiceController Email service class */
    private Map<String,Object> fieldMapping;
    
    private static FINAL String rowDelimiterMatcher = '\n'; 
    private static FINAL String PROCESS_NAME = 'PPI_Customer_Onboarding';
    private static FINAL String uniqueDelimiter = '!@#&*:';
    
    /** Constructor */
    public PPI_CustomerOnboardingBatch(String fileData,String csvFileName){
        this.fileData = fileData;
        this.fileName = csvFileName;
        
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
    
    /** Start */
    public Iterable<String> start(Database.batchableContext batchableContext){ 
        if(!fieldMapping.keySet().isEmpty()){
            return new Utility_RowIterator(fileData, rowDelimiterMatcher);
        }else{
            return NULL;
        }
    }/** */
    
    /** Execute */
    public void execute(Database.BatchableContext batchableContext, List<String> scope){
        
        try{
            System.debug('scope>>>>>'+scope);
            System.debug('scope>>>>>'+scope.size());
            List<PPI_Customer__c> sobjectListToUpsert = new List<PPI_Customer__c>();
            for(Integer i=0;i<scope.size();i++){
                if(i > 0 && scope[i] != NULL){
                    List<String> fieldValueList = getValidData(scope[i]).split(',');
                    
                    PPI_Customer__c sObj = get_CO_Object(fieldValueList);
                    
                    if(sObj != NULL){
                        sobjectListToUpsert.add(sObj);
                    }
                }
            }
            System.debug('>>>>>>>>>>>>sobjectListToUpsert>>>>>>>>>>'+sobjectListToUpsert.size());
            
            if(!sobjectListToUpsert.isEmpty()){
                Schema.SObjectField externalIdField = PPI_Customer__c.fields.Customer_Id__c;
                List<Database.upsertResult> upsertResults = Database.upsert(sobjectListToUpsert, externalIdField,false);
                
                generateErrorLogsForFailedRecods(upsertResults,sobjectListToUpsert);
                
            }
        }catch(Exception ex){
            Error_Details__c errorDetails = new Error_Details__c(Process__c = PROCESS_NAME,Message__c = ex.getMessage() + ' - '+ex.getLineNumber(),Severity__c = 'High', Identifier__c = fileName);
            insert errorDetails;
        }
    }/** Execute END */
    
    /** Finish */
    public void finish(Database.BatchableContext bc){}
    /** END */
    
    /**
    * Method to manipulate the data row to avoid any data issue (e.g.- String ends with comma and comma in between quotes[" "] ).
    * @param - csv data row in comma delimited string.
    * return - csv row data after removing exceptionally possible data issue.
    */
    private String getValidData(String dataRow){
        Map<String,String> strMap = new Map<String,String>();
        
        if(dataRow.endsWith(',')){
            dataRow += '-';
        }
        String tempStr = dataRow;
        while(tempStr.contains('"')){
            String subStr = tempStr.substringBetween('"', '"');
            strMap.put('"'+subStr+'"',subStr.replaceAll(',',uniqueDelimiter));
            tempStr = tempStr.remove('"'+subStr+'"');
        }
        
        for(String key : strMap.keySet()){
            if(dataRow.contains(key)){
                dataRow = dataRow.replace(key,strMap.get(key));
            }
        }
        return dataRow;
    }/** END */
    
    /**
    * Method to get the Customer Onboarding object 
    * @param - List of csv rows with data
    * return - instance of Customer Onboarding object 
    */
    private PPI_Customer__c get_CO_Object( List<String> fieldValueList){
        PPI_Customer__c sobj = new PPI_Customer__c();
        
        for(String field : fieldMapping.keySet()){
            Map<String,Object> fieldDetailMap = (Map<String,Object>)fieldMapping.get(field);
            
            String fieldAPIName = (String)fieldDetailMap.get('fieldName');
            Integer fieldIndex = Integer.valueOf(fieldDetailMap.get('index'));
            String fieldType = (String)fieldDetailMap.get('type');
            
            if(String.isNotBlank(fieldValueList[fieldIndex]) && fieldValueList[fieldIndex] != '-'){
                if(fieldValueList[fieldIndex].contains(uniqueDelimiter)){
                    fieldValueList[fieldIndex] = fieldValueList[fieldIndex].replace(uniqueDelimiter, ',');
                }
                if(fieldType == 'Number'){
                    sobj.put(fieldAPIName,Double.valueOf(fieldValueList[fieldIndex]) );
                }else if(fieldType == 'Date'){
                    sobj.put(fieldAPIName,Date.valueOf(fieldValueList[fieldIndex]) );
                }else if(fieldType == 'Boolean'){
                    Map<String,Boolean> stringToBooleanMap = new Map<String,Boolean>{'Y'=>True,'N'=>False,'y'=>True,'n'=>False};
                    sobj.put(fieldAPIName,Boolean.valueOf(stringToBooleanMap.get(fieldValueList[fieldIndex])) );
                }else{
                    sobj.put(fieldAPIName, String.valueOf(fieldValueList[fieldIndex]));
                }
                sobj.put('Last_Updated_From__c',fileName);
            }
        }
        return sobj;
    }/** END */
    
    /**
    * Method to generate error logs for failed records while upsert.
    * @param - upsertResult, List of record for upsert.
    * return - void 
    */
    private void generateErrorLogsForFailedRecods(List<Database.upsertResult> upsertResults,List<PPI_Customer__c> sobjectListToUpsert){
        Map<String,List<String>> customerIdToErrorMap = new Map<String,List<String>>();
        for(Integer i=0;i<upsertResults.size();i++){
            if(!upsertResults[i].isSuccess()){
                List<String> listRecord = new List<String>();
                String customerId = String.isNotBlank(sobjectListToUpsert[i].Customer_Id__c) ? sobjectListToUpsert[i].Customer_Id__c : 'EmptyCustomerId';
                if(customerIdToErrorMap.containsKey(customerId)){
                    listRecord = customerIdToErrorMap.get(customerId);
                }
                if(customerId.equals('EmptyCustomerId')){
                    listRecord.add(String.valueOf(sobjectListToUpsert[i]));
                }else{
                    listRecord.add(String.valueOf(upsertResults[i].getErrors()));
                }
                
                customerIdToErrorMap.put(customerId,listRecord);
            }
        }
        
        if(!customerIdToErrorMap.keySet().isEmpty()){
            Error_Details__c errorDetails = new Error_Details__c(Process__c = PROCESS_NAME,Message__c = 'Record Failed during upsert',Severity__c = 'High', Response__c = JSON.serialize(customerIdToErrorMap),Identifier__c = fileName);
            insert errorDetails;
        }
    }/** END */
}/** Class END */