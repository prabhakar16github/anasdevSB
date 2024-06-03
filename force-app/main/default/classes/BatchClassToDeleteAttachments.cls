/*
* Name of the class : BatchClassToDeleteAttachments
* Author's Name     : Anas Yar Khan  
* Created Date      : 25th Feb, 2023
* Description       : Generic batch class to delete the attachments
* Version.          : 1   
*/ 
public class BatchClassToDeleteAttachments implements Database.Batchable<sObject> {
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private Map<String,String> mapObjectAPINameToDeleteQuery = new Map<String,String>();
    /*********************************Member Variables End*****************************/
    
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToDeleteAttachments(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Query_To_Delete_records__c
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true LIMIT 50000]) mapObjectAPINameToDeleteQuery.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord.Query_To_Delete_records__c);    
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(mapObjectAPINameToDeleteQuery.containsKey(objectAPIName)) {
            query = mapObjectAPINameToDeleteQuery.get(objectAPIName);
        }
        if(String.isNotBlank(query)) return Database.getQueryLocator(query);
        else return NULL;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listRecordsToDelete) {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<String> setAllObjId = new Set<String>();
            for(Sobject obj : listRecordsToDelete) setAllObjId.add(obj.Id);
            Set<String> setIntermediateObjectRecordId = new Set<String>();
            Map<String,String> mapRecordIdToIntermediateRecordId = new Map<String,String>();
            for(Intermediate_Object__c intObj : [SELECT Id,Record_Id__c FROM Intermediate_Object__c WHERE Record_Id__c IN :setAllObjId]) {
            	setIntermediateObjectRecordId.add(intObj.Record_Id__c); 
                mapRecordIdToIntermediateRecordId.put(intObj.Record_Id__c,intObj.Id);
            }
            if(setIntermediateObjectRecordId.size() > 0) {
                delete [SELECT Id FROM Attachment WHERE ParentId IN :setIntermediateObjectRecordId];
                List<Intermediate_Object__c> listIntermediateObjectToUpdate = new List<Intermediate_Object__c>();
                for(String recordId : setIntermediateObjectRecordId) {
                    Intermediate_Object__c obj = new Intermediate_Object__c();
                    obj.Id = mapRecordIdToIntermediateRecordId.get(recordId);
                    obj.Attachment_Deleted__c = true;
                    listIntermediateObjectToUpdate.add(obj);
                }
                
                if(listIntermediateObjectToUpdate.size() > 0) update listIntermediateObjectToUpdate;
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToDeleteAttachments',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}