/*
* Name of the class : FilesMigrationToS3Batch
* Author's Name     : Anas Yar Khan  
* Created Date      : 31th Aug, 2022
* Description       : Generic batch class to push the files to S3
* Version.          : 1   
*/ 
public class FilesMigrationToS3Batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private Map<String,Object_to_Big_Object_Mapping__mdt> mapObjectAPINameToCustomMetadataRecord = new Map<String,Object_to_Big_Object_Mapping__mdt>();
    Map<String,Object> mapFileExtensionToContentType = (Map<String,Object>)JSON.deserializeUntyped(Label.FileExtensionToContentType);
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public FilesMigrationToS3Batch(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Query_To_Push_Attachments_to_S3__c,Obj_Field_that_will_store_public_links__c	
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true LIMIT 50000]) mapObjectAPINameToCustomMetadataRecord.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord);
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(mapObjectAPINameToCustomMetadataRecord.containsKey(objectAPIName)) {
            query = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Query_To_Push_Attachments_to_S3__c;
        }
        if(String.isNotBlank(query)) return Database.getQueryLocator(query);
        else return NULL;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Sobject> listSobject) {
        try {
            List<String> listPublicUrls = new List<String>();
            Set<Id> setContentDocumentIds = new Set<Id>();
            for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :listSobject[0].Id]) {
                setContentDocumentIds.add(cdl.ContentDocumentId);
            }
            if(setContentDocumentIds.size() > 0) {
                for(ContentVersion cv : [SELECT Title,VersionData,FileExtension FROM ContentVersion WHERE ContentDocumentId IN :setContentDocumentIds AND isLatest = true]) {
                    String contentType = '';
                    if(String.isNotBlank(cv.FileExtension)) {
                        contentType = cv.FileExtension;
                        contentType = contentType.replaceAll('[^a-zA-Z0-9\\s+]', '');
                        contentType = contentType.replaceAll(' ','');   
                    }
                    String title = cv.Title;
                    title = title.replaceAll('[^a-zA-Z0-9\\s+]', '');
                    title = title.replaceAll(' ','');
                    title = title + '-' +listSobject[0].Id + '-'+ contentType;
                    String statusMessage = AttachmentAndFilesMigrationToS3Utility.pushAttachmentsAndFilesToS3(title,cv.FileExtension,cv.VersionData,mapFileExtensionToContentType);
                    if(String.isNotBlank(statusMessage) && statusMessage == 'SUCCESS') {
                    	listPublicUrls.add(title);	    
                    }     
                }
            }
            if(listPublicUrls.size() > 0) {
                if(String.isNotBlank((String)listSobject[0].get(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c))) {
                    String existingUrls = (String)listSobject[0].get(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c);
                	List<String> listExistingUrls = existingUrls.split(',');
                    listPublicUrls.addAll(listExistingUrls);
                }
                listSobject[0].put(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c,String.join(listPublicUrls,','));
                update listSobject[0];                                                      
            }
        }
        catch(Exception e) {
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'FilesMigrationToS3Batch',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()),Request__c = String.valueOf(listSobject));
            insert errorDetails;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}