/*
* Name of the class : BatchToDeleteRecordsWithAttachmentFile
* Author's Name     : Anas Yar Khan
* Created Date      : 6th April, 2023
* Description       : Generic batch class to delete the records and its related Attachments/Files.
* Version.          : 1   
*/ 
public with sharing class BatchToDeleteRecordsWithAttachmentFile implements Database.Batchable<sObject> {
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private String queryStr = '';
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
	* objectAPIName : This parameter receive the API Name of the Object
	*/ 
    public BatchToDeleteRecordsWithAttachmentFile(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Query_To_Delete_records__c
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true 
                                                                      AND Object_API_Name__c = :objectAPIName LIMIT 1]){
                                                                          this.queryStr = customMetadataRecord.Query_To_Delete_records__c;
                                                                      }
    }
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isNotBlank(queryStr)){
            return Database.getQueryLocator(queryStr);
        }
        return NULL;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listRecordsToDelete) {
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String,Integer> mapIdToCount = new Map<String,Integer>();
            for(Sobject obj : listRecordsToDelete) 
                mapIdToCount.put(obj.Id,0);
            for(Attachment att : [SELECT Id,ParentId FROM Attachment WHERE ParentId IN :mapIdToCount.keySet()]) 
                mapIdToCount.put(att.ParentId,mapIdToCount.get(att.ParentId)+1);
            for(ContentDocumentLink cdl : [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :mapIdToCount.keySet()])
                mapIdToCount.put(cdl.LinkedEntityId,mapIdToCount.get(cdl.LinkedEntityId)+1);
            Set<Id> setRecordIdsToBeDeleted = new Set<Id>();
            for(Intermediate_Object__c intObj : [SELECT Id,Record_Id__c,Attachments_Files_name_in_the_one_drive__c 
                                                 FROM Intermediate_Object__c 
                                                 WHERE Record_Id__c IN :mapIdToCount.keySet()]) {
                                                     List<String> listContents = intObj.Attachments_Files_name_in_the_one_drive__c.split(',');
                                                     if(listContents.size() == mapIdToCount.get(intObj.Record_Id__c)) {
                                                         setRecordIdsToBeDeleted.add(intObj.Record_Id__c);    
                                                     } 
                                                 }
            
            for(String recordId : mapIdToCount.keySet()) {
                if(mapIdToCount.get(recordId) == 0) {
               		setRecordIdsToBeDeleted.add(recordId);     
                }
            }
            
            if(!setRecordIdsToBeDeleted.isEmpty()){
                Map<Id,Set<Id>> mapLinkedEntityIdToSetOfContentDocumentId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> mapContentDocumentIdToSetOfLinkedEntityId = new Map<Id,Set<Id>>();
                Set<Id> setAllContentDocumentIds = new Set<Id>();
                
                for(ContentDocumentLink docLink : [SELECT Id,ContentDocumentId,LinkedEntityId 
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId IN :setRecordIdsToBeDeleted]){
                                                       setAllContentDocumentIds.add(docLink.ContentDocumentId);
                                                       Set<Id> setContentDocumentIds = new Set<Id>();
                                                       if(mapLinkedEntityIdToSetOfContentDocumentId.containsKey(docLink.LinkedEntityId)) {
                                                           setContentDocumentIds = mapLinkedEntityIdToSetOfContentDocumentId.get(docLink.LinkedEntityId);
                                                       }   
                                                       setContentDocumentIds.add(docLink.ContentDocumentId);
                                                       mapLinkedEntityIdToSetOfContentDocumentId.put(docLink.LinkedEntityId,setContentDocumentIds);
                                                   }
                
                if(setAllContentDocumentIds.size() > 0) {
                    for(ContentDocumentLink docLink : [SELECT Id,ContentDocumentId,LinkedEntityId 
                                                       FROM ContentDocumentLink 
                                                       WHERE ContentDocumentId IN :setAllContentDocumentIds]) {
                                                           Set<Id> setLinkedEntityIds = new Set<Id>();
                                                           if(mapContentDocumentIdToSetOfLinkedEntityId.containsKey(docLink.ContentDocumentId)) {
                                                               setLinkedEntityIds = mapContentDocumentIdToSetOfLinkedEntityId.get(docLink.ContentDocumentId);
                                                           }   
                                                           setLinkedEntityIds.add(docLink.LinkedEntityId);
                                                           mapContentDocumentIdToSetOfLinkedEntityId.put(docLink.ContentDocumentId,setLinkedEntityIds);    
                                                       }
                }
                
                Set<Id> setContentDocumentIdsToBeDeleted = new Set<Id>();
                if(mapLinkedEntityIdToSetOfContentDocumentId.keySet().size() > 0 && mapContentDocumentIdToSetOfLinkedEntityId.keySet().size() > 0) {
                    for(Id recordId : mapLinkedEntityIdToSetOfContentDocumentId.keySet()) {
                        for(Id contentDocumentId : mapLinkedEntityIdToSetOfContentDocumentId.get(recordId)) {
                            if(mapContentDocumentIdToSetOfLinkedEntityId.containsKey(contentDocumentId)) {
                                Boolean isDeleteable = true;
                                for(Id linkedEntityId : mapContentDocumentIdToSetOfLinkedEntityId.get(contentDocumentId)) {
                                    if(!isValidLinkedEntity(recordId,linkedEntityId)) {
                                        isDeleteable = false;
                                        break;
                                    }			
                                } 
                                if(isDeleteable) setContentDocumentIdsToBeDeleted.add(contentDocumentId);
                            }    
                        }
                    }
                }
                
                if(setContentDocumentIdsToBeDeleted.size() > 0) {
                    List<ContentDocument> listContentDocumentToBeDeleted = [SELECT Id FROM ContentDocument WHERE Id IN :setContentDocumentIdsToBeDeleted];
                    if(listContentDocumentToBeDeleted != NULL && listContentDocumentToBeDeleted.size() > 0) delete listContentDocumentToBeDeleted;
                }            
                
                String queryToDelete = 'SELECT Id FROM '+objectAPIName+' WHERE Id IN :setRecordIdsToBeDeleted';
                delete Database.query(queryToDelete);
            }    
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchToDeleteRecordsWithAttachmentFile',Request__c=String.valueOf(listRecordsToDelete),Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High',Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
    
    /****************************isValidLinkedEntity Method**************************************/
    private Boolean isValidLinkedEntity(String recordId,String linkedEntityId){
        String keyPrefix = linkedEntityId.subString(0,3);
        if(keyPrefix.equals('005') || keyPrefix.equals('00D') || recordId == linkedEntityId){
            return true;
        }
        return false;
    }
    /****************************isValidLinkedEntity Method End**************************************/    
}