/*
* Name of the class : BatchClassToDeleteFiles
* Author's Name     : Anas Yar Khan  
* Created Date      : 25th Aug, 2022
* Description       : Generic batch class to delete the files
* Version.          : 1   
*/ 
public class BatchClassToDeleteFiles implements Database.Batchable<sObject>,Database.Stateful {
    
    /*********************************Member Variables**********************************/
    Integer count = 0;
    Decimal sizeInMB = 0;
    Map<Id,Decimal> mapUserToSize = new Map<Id,Decimal>();
    private String objectAPIName = '';
    private Map<String,String> mapObjectAPINameToDeleteQuery = new Map<String,String>();
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
	* objectAPIName : This parameter receive the API Name of the Object
	*/ 
    public BatchClassToDeleteFiles(String objectAPIName) {
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
    public void execute(Database.BatchableContext BC, List<ContentDocument> listRecordsToDelete) {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> setContentDocumentId = new Set<Id>();
            Map<Id,Integer> mapContentDocumentIdToContentSize = new Map<Id,Integer>();
            for(ContentDocument record : listRecordsToDelete) {
                setContentDocumentId.add(record.Id);
                mapContentDocumentIdToContentSize.put(record.Id,record.ContentSize);
            }     
            Map<Id,Set<Id>> mapContentDocumentIdToSetOfLinkedEntityId = new Map<Id,Set<Id>>();
            for(ContentDocumentLink docLink : [SELECT Id,ContentDocumentId,LinkedEntityId 
                                               FROM ContentDocumentLink 
                                               WHERE ContentDocumentId IN :setContentDocumentId]) {
                                                   Set<Id> setLinkedEntityIds = new Set<Id>();
                                                   if(mapContentDocumentIdToSetOfLinkedEntityId.containsKey(docLink.ContentDocumentId)) {
                                                       setLinkedEntityIds = mapContentDocumentIdToSetOfLinkedEntityId.get(docLink.ContentDocumentId);
                                                   }   
                                                   setLinkedEntityIds.add(docLink.LinkedEntityId);
                                                   mapContentDocumentIdToSetOfLinkedEntityId.put(docLink.ContentDocumentId,setLinkedEntityIds);    
                                               }
            
            Set<Id> setContentDocumentIdsToBeDeleted = new Set<Id>();
            if(mapContentDocumentIdToSetOfLinkedEntityId.keySet().size() > 0) {
                for(Id contentDocumentId : mapContentDocumentIdToSetOfLinkedEntityId.keySet()) {
                    Boolean isDeleteable = true;
                    Set<Id> setLinkedEntityId = new Set<Id>();
                    for(Id linkedEntityId : mapContentDocumentIdToSetOfLinkedEntityId.get(contentDocumentId)) {
                        setLinkedEntityId.add(linkedEntityId);
                        if(!isValidLinkedEntity(linkedEntityId)) {
                            isDeleteable = false;
                            break;
                        }			
                    } 
                    if(isDeleteable) {
                        setContentDocumentIdsToBeDeleted.add(contentDocumentId);
                        count++;
                        if(mapContentDocumentIdToContentSize.containsKey(contentDocumentId)) {
                            sizeInMB += (Decimal)mapContentDocumentIdToContentSize.get(contentDocumentId)/1000000; 
                            for(Id linkedEntityId : setLinkedEntityId) {
                                if(mapUserToSize.containsKey(linkedEntityId)) {
                                    mapUserToSize.put(linkedEntityId,mapUserToSize.get(linkedEntityId)+(Decimal)mapContentDocumentIdToContentSize.get(contentDocumentId)/1000000);    
                                }
                                else {
                                    mapUserToSize.put(linkedEntityId,(Decimal)mapContentDocumentIdToContentSize.get(contentDocumentId)/1000000);    
                                }
                            }
                        }
                    }
                }    
            }
            
            /*if(setContentDocumentIdsToBeDeleted.size() > 0) {
				List<ContentDocument> listContentDocumentToBeDeleted = [SELECT Id FROM ContentDocument WHERE Id IN :setContentDocumentIdsToBeDeleted];
				if(listContentDocumentToBeDeleted != NULL && listContentDocumentToBeDeleted.size() > 0) delete listContentDocumentToBeDeleted;
			}*/ 
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToDeleteFiles',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> listUser = [SELECT Id FROM User WHERE email= 'anas.khan@payu.in'];
        if(listUser != NULL && listUser.size() > 0) {
            mail.setTargetObjectId(listUser[0].Id);  
            mail.setSubject('Count of files');
            mail.saveAsActivity = false;
            // Body of email
            String body='';
            // org limits parameters
            body += 'Total Files that can be deleted--> '+ count+'\n';
            body += 'Total Size of the files that can be deleted--> '+ sizeInMB+'\n';
            body += 'User wise Content Size in MB--> '+ JSON.serialize(mapUserToSize) +'\n';
            mail.setPlainTextBody(body);
            // Send the email message
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }	    
    }
    /****************************Finish Method End ********************************/
    
    /****************************isValidLinkedEntity Method**************************************/
    private Boolean isValidLinkedEntity(String linkedEntityId){
        String keyPrefix = linkedEntityId.subString(0,3);
        if(keyPrefix.equals('005') || keyPrefix.equals('00D')){
            return true;
        }
        return false;
    }
    /****************************isValidLinkedEntity Method End**************************************/
}