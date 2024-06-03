/*
* Name of the class : BatchClassToUpdateFields
* Author's Name     : Anas Yar Khan  
* Created Date      : 28th April, 2023
* Description       : Generic batch class to update fields on the records
* Version.          : 1   
*/ 
public class BatchClassToUpdateFields implements Database.Batchable<sObject>{
    /*********************************Member Variables**********************************/
    private String query = '';
    private String objectAPIName = '';
    private String fieldValues = '';
    private Map<String,Object> mapFieldMapping = new Map<String,Object>();
    private Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private Schema.SObjectType objectSchema;
    Map<String,Schema.SObjectField> fieldMap;
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
    * query         : This parameter receive the query for which we need to update the fields
	* objectAPIName : This parameter receive the API Name of the Object
	* fieldValues   : This parameter receive the values of the fields to be updated in JSON format
	*/ 
    public BatchClassToUpdateFields(String query,String objectAPIName,String fieldValues) {
        this.query = query;
        this.objectAPIName = objectAPIName;
        this.fieldValues = fieldValues;
        objectSchema = schemaMap.get(objectAPIName);
        fieldMap = objectSchema.getDescribe().fields.getMap();
        mapFieldMapping = (Map<String,Object>)JSON.deserializeUntyped(fieldValues);
    }
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isNotBlank(query)) return Database.getQueryLocator(query);
        else return NULL;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listSobject) {
        Savepoint sp = Database.setSavepoint();
        try {
            if(mapFieldMapping.keySet().size() > 0 && String.isNotBlank(objectAPIName)) {
                List<Sobject> listsOjbectToUpdate = new List<Sobject>();
                for(sObject dataRecord : listSobject) {
                    sObject objectRecord = Schema.getGlobalDescribe().get(objectAPIName).newSObject();
                    objectRecord.Id = dataRecord.Id;
                    for(String objectFieldAPIName : mapFieldMapping.keySet()) {
                        Schema.DisplayType fieldDataType = fieldMap.get(objectFieldAPIName).getDescribe().getType();
                        if(fieldDataType == Schema.DisplayType.BOOLEAN) objectRecord.put(objectFieldAPIName,Boolean.valueOf(mapFieldMapping.get(objectFieldAPIName)));    
                        else objectRecord.put(objectFieldAPIName,String.valueOf(mapFieldMapping.get(objectFieldAPIName))); 
                    }
                    listsOjbectToUpdate.add(objectRecord);
                }   
                
                if(listsOjbectToUpdate.size() > 0) update listsOjbectToUpdate;
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToUpdateFields',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}