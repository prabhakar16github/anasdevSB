/*
* Name of the class : AttachmentsMigrationToOneDriveBatch
* Author's Name     : Anas Yar Khan  
* Created Date      : 19th Oct, 2022
* Description       : Generic batch class to push attachments to Microsoft one drive
* Version.          : 1   
*/ 
public class AttachmentsMigrationToOneDriveBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private Map<String,Object_to_Big_Object_Mapping__mdt> mapObjectAPINameToCustomMetadataRecord = new Map<String,Object_to_Big_Object_Mapping__mdt>();
    private Map<Integer,One_Drive_Integration__mdt> mapIntegerToOneDriveIntegrationMetadata = new Map<Integer,One_Drive_Integration__mdt>();
    Map<String,Object> mapFileExtensionToContentType = (Map<String,Object>)JSON.deserializeUntyped(Label.FileExtensionToContentType);
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
	* objectAPIName : This parameter receive the API Name of the Object
	*/ 
    public AttachmentsMigrationToOneDriveBatch(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Query_To_Push_Attachments_to_S3__c,Obj_Field_that_will_store_public_links__c	
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true LIMIT 50000]) mapObjectAPINameToCustomMetadataRecord.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord);
        for(One_Drive_Integration__mdt customMetadataRecord : [SELECT Label,Tenant_Id__c,Client_Id__c,Client_Secret_Value__c,Grant_Type__c,Microsoft_User_Id__c,Scope__c
                                                               FROM One_Drive_Integration__mdt 
                                                               WHERE IsActive__c = true LIMIT 1]) mapIntegerToOneDriveIntegrationMetadata.put(1,customMetadataRecord); 
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
            List<Attachment> listAttachment = [SELECT Id,Name,ContentType,Body,ParentId FROM Attachment WHERE ParentId IN :listSobject];
            if(listAttachment != NULL && listAttachment.size() > 0) {
                String clientid = EncodingUtil.urlEncode(mapIntegerToOneDriveIntegrationMetadata.get(1).Client_Id__c,'UTF-8');
                String clientSecret = EncodingUtil.urlEncode(mapIntegerToOneDriveIntegrationMetadata.get(1).Client_Secret_Value__c,'UTF-8');
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://login.microsoftonline.com/'+mapIntegerToOneDriveIntegrationMetadata.get(1).Tenant_Id__c+'/oauth2/v2.0/token');
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                String messageBody='client_id='+mapIntegerToOneDriveIntegrationMetadata.get(1).Client_Id__c+
                    '&scope='+mapIntegerToOneDriveIntegrationMetadata.get(1).Scope__c+
                    '&client_secret='+mapIntegerToOneDriveIntegrationMetadata.get(1).Client_Secret_Value__c+
                    '&grant_type='+mapIntegerToOneDriveIntegrationMetadata.get(1).Grant_Type__c;
                req.setHeader('Content-length', String.valueOf(messageBody.length()));
                req.setBody(messageBody);
                req.setTimeout(60000);
                Http callout = new Http();
                HttpResponse response = callout.send(req);
                if(response.getStatusCode() == 200) {
                    Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(String.valueOf(response.getBody()));
                    if(responseMap != NULL && responseMap.keySet().size() > 0 && responseMap.containsKey('access_token')) {
                        String accessToken = String.valueOf(responseMap.get('access_token'));
                        List<String> listPublicUrls = new List<String>();
                        for(Attachment att : listAttachment) {
                            String contentType = '';
                            if(String.isNotBlank(att.ContentType)) {
                                contentType = att.ContentType;
                                contentType = contentType.replaceAll('[^a-zA-Z0-9\\s+]', '');
                                contentType = contentType.replaceAll(' ','');   
                            }
                            String title = att.Name;
                            title = title.replaceAll('[^a-zA-Z0-9\\s+]', '');
                            title = title.replaceAll(' ','');
                            //title = title + '-' + att.ParentId + '-' + contentType;
                            title = att.ParentId + '-' + contentType + '-' +att.Name;
                            String statusMessage = AttachmentsFilesMigrationTo1DriveUtility.pushAttachmentsAndFilesToOneDrive(title,att.ContentType,att.Body,mapFileExtensionToContentType,mapIntegerToOneDriveIntegrationMetadata,accessToken);
                            if(String.isNotBlank(statusMessage) && statusMessage == 'SUCCESS') {
                                listPublicUrls.add(title);		    
                            }
                        }
                        if(listPublicUrls.size() > 0) {
                            /******************Only for email Message**********************/
                            List<Intermediate_Object__c> listIntermediateObject = [SELECT Id,Record_Id__c,Attachments_Files_name_in_the_one_drive__c FROM Intermediate_Object__c WHERE Record_Id__c = :listSobject[0].Id];
                            if(listIntermediateObject != NULL && listIntermediateObject.size() > 0) {
                            	List<String> listExistingUrls = listIntermediateObject[0].Attachments_Files_name_in_the_one_drive__c.split(',');	
                                listPublicUrls.addAll(listExistingUrls);
                                listIntermediateObject[0].Attachments_Files_name_in_the_one_drive__c = String.join(listPublicUrls,',');
                                update listIntermediateObject[0];
                            }
                            else {
                            	Intermediate_Object__c io = new Intermediate_Object__c();
                                io.Record_Id__c = listSobject[0].Id;
                                io.Attachments_Files_name_in_the_one_drive__c = String.join(listPublicUrls,',');
                                insert io;
                            }
                            /******************End for Email Message******************/
                            /*************for other Objects***************************/
                            /*if(String.isNotBlank((String)listSobject[0].get(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c))) {
                                String existingUrls = (String)listSobject[0].get(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c);
                                List<String> listExistingUrls = existingUrls.split(',');
                                listPublicUrls.addAll(listExistingUrls);
                            }
                            listSobject[0].put(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Obj_Field_that_will_store_public_links__c,String.join(listPublicUrls,','));
                            update listSobject[0];
							*/                                                     
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'AttachmentsMigrationToOneDriveBatch',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()),Request__c = String.valueOf(listSobject));
            insert errorDetails;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}