/*
* Name of the class : EmailMessageUIController
* Author's Name     : Anas Yar Khan  
* Created Date      : 12th Dec, 2022
* Description       : Apex Controller for LWC - EmailMessageUI | This LWC is used to fetch data from big object and shows data on the record page 
* Version.          : 1   
*/
public class EmailMessageUIController {
    /*
* Name of the function : getEmailMessageOnLoad
* Author's Name        : Anas Yar Khan  
* Created Date         : 12th Dec, 2022
* Description          : This method will call on load of the component and return all the email message records from the big objects for the parentId passed as a parameter 
* Version.             : 1  
* Parameters           : ParentId - parentId of the emailMessage
*/
    @AuraEnabled(cacheable=true)
    public static WrapperClass getEmailMessageOnLoad(String parentId) {
        WrapperClass wrpCls = new WrapperClass();
        try {
            String sObjectType = 'Email_Message_New_Big_Object__b';
            Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectSchema = schemaMap.get(sObjectType);
            Map<String,Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap(); 
            
            wrpCls.columnNames = '[';
            for(String fieldAPIName : Label.EmailMessageHeaders.split(',')) {
                if(fieldMap.containsKey(fieldAPIName)) {
                    wrpCls.columnNames += '{"label":"'+fieldMap.get(fieldAPIName).getDescribe().getLabel()+'","fieldName":"'+fieldAPIName+'","type" : "text"},';    
                }
            }
            wrpCls.columnNames += '{"type": "button-icon","typeAttributes": {"iconName": "utility:preview","name": "view","title": "view","variant": "bare"}},';
            wrpCls.columnNames += '{"type": "button-icon","typeAttributes": {"iconName": "utility:attach","name": "viewDoc","title": "edit","variant": "bare"}}';
            wrpCls.columnNames = wrpCls.columnNames.removeEnd(',');
            wrpCls.columnNames += ']';
            String query = 'SELECT '+Label.EmailMessageHeaders+' FROM Email_Message_New_Big_Object__b WHERE RelatedToId__c = \''+parentId + '\'';
            wrpCls.listData = Database.query(query);
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage() + '#' + e.getLineNumber();
        }
        return wrpCls;
    }
    
    public class WrapperClass {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String columnNames = '';
        @AuraEnabled public List<sObject> listData = new List<sObject>();
    } 
    
    @AuraEnabled(cacheable=true)
    public static AttachmentAndFileWrapper getAttachmentAndFiles(String recordId) {
        AttachmentAndFileWrapper wrpCls = new AttachmentAndFileWrapper();
        try {
            for(Intermediate_Object__c obj : [SELECT Attachments_Files_name_in_the_one_drive__c FROM Intermediate_Object__c WHERE Record_Id__c = :recordId]) {
                String attachmentsFilesName = obj.Attachments_Files_name_in_the_one_drive__c.stripHtmlTags();
                wrpCls.listDocuments.addAll(attachmentsFilesName.split(','));   
            }    
        }   
        catch(Exception e) {
            wrpCls.message = e.getMessage()+'#'+e.getLineNumber();     
        }
        return wrpCls;
    }
    
    public class AttachmentAndFileWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<String> listDocuments = new List<String>();
    }
    
    /*
    @AuraEnabled
    public static String downloadDoc(String fileName) {
        String message = 'SUCCESS';
        try {
            Map<Integer,One_Drive_Integration__mdt> mapIntegerToOneDriveIntegrationMetadata = new Map<Integer,One_Drive_Integration__mdt>();
            for(One_Drive_Integration__mdt customMetadataRecord : [SELECT Label,Tenant_Id__c,Client_Id__c,Client_Secret_Value__c,Grant_Type__c,Microsoft_User_Id__c,Scope__c
                                                                   FROM One_Drive_Integration__mdt 
                                                                   WHERE IsActive__c = true LIMIT 1]) {
                                                                       mapIntegerToOneDriveIntegrationMetadata.put(1,customMetadataRecord);
                                                                   } 
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
                    if(String.isNotBlank(accessToken)) {
                        String endpointUrl='https://graph.microsoft.com/v1.0/users/'+mapIntegerToOneDriveIntegrationMetadata.get(1).Microsoft_User_Id__c+'/drive/items/root:/'+fileName;
                        HttpRequest req1 = new HttpRequest();
                        req1.setEndpoint(endpointUrl);
                        req1.setMethod('GET');
                        req1.setHeader('Content-Encoding', 'UTF-8');
                        req1.setHeader('accept', 'application/json');
                        req1.setHeader('Authorization','Bearer ' + accessToken);
                        Http http = new Http();
                        HTTPResponse res = http.send(req1);
                        System.debug('res-->'+res);
                        if(res.getStatusCode() == 200) {
                            Map<String,Object> mapResponseMap2 = (Map<String,Object>)JSON.deserializeUntyped(String.valueOf(res.getBody()));
                            if(mapResponseMap2 != NULL && mapResponseMap2.keySet().size() > 0 && mapResponseMap2.containsKey('@microsoft.graph.downloadUrl')) {
                                message += '#'+(String)mapResponseMap2.get('@microsoft.graph.downloadUrl');
                            } 
                            else {
                            	message = 'Download Link not found';     
                            }
                        }
                        else {
                        	message = 'Getting error in Downloading Document';    
                        }
                    }
                }
            } 
            else {
                message = 'Getting error in Access Token';
            }
        }
        catch(Exception e) {
            message = e.getMessage()+'#'+e.getLineNumber(); 
        }
        return message;
    }
    */
}