/*
* Name of the class : AttachmentsFilesMigrationTo1DriveUtility
* Author's Name     : Anas Yar Khan  
* Created Date      : 19th Oct, 2022
* Description       : Utility class to push attachments/files to Microsoft one drive
* Version.          : 1   
*/
public class AttachmentsFilesMigrationTo1DriveUtility {
    /*
    * Name of the function : pushAttachmentsAndFilesToOneDrive
    * Author's Name        : Anas Yar Khan  
    * Created Date         : 19th Oct, 2022
    * Description          : This method is used to push attachments/files to Microsoft one drive
    * Version.             : 1  
    * Parameters           : title,fileExtension,body,mapFileExtensionToContentType,mapIntegerToOneDriveIntegrationMetadata
	*/
    public static String pushAttachmentsAndFilesToOneDrive(String title,String fileExtension,Blob body,Map<String,Object> mapFileExtensionToContentType,Map<Integer,One_Drive_Integration__mdt> mapIntegerToOneDriveIntegrationMetadata,String accessToken) {
        String attachmentBody = EncodingUtil.base64Encode(body);
        String contentType = getContentType(fileExtension,mapFileExtensionToContentType);
        String endpointUrl='https://graph.microsoft.com/v1.0/users/'+mapIntegerToOneDriveIntegrationMetadata.get(1).Microsoft_User_Id__c+'/drive/items/root:/{file}:/content';
    	String file=EncodingUtil.URLENCODE(title,'UTF-8').replace('+', '%20');
    	endpointUrl=endpointUrl.replace('{file}',file);
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('PUT'); 
        req.setHeader('Authorization','Bearer ' + accessToken);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type',contentType);
        req.setHeader('accept', 'application/json');
    	Http http = new Http();
    	req.setBodyAsBlob(body);
    	req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() == 201 || res.getStatusCode() == 200) return 'SUCCESS';
        else return 'ERROR';
    } 	
    
    /*
    * Name of the function : getContentType
    * Author's Name        : Anas Yar Khan  
    * Created Date         : 19th Oct, 2022
    * Description          : This method is used to get contentType from the fileExtension
    * Version.             : 1  
    * Parameters           : fileExtension,mapFileExtensionToContentType
	*/
    public static String getContentType(String fileExtension,Map<String,Object> mapFileExtensionToContentType) {
        String contentType = 'image/jpeg';
        if(String.isNotBlank(fileExtension)) {
            if(mapFileExtensionToContentType.containsKey(fileExtension)) contentType = (String)mapFileExtensionToContentType.get(fileExtension);	    
            else contentType = fileExtension;    
        }
        return contentType;
    }
}