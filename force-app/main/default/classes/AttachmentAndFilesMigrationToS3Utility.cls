/*
* Name of the class : AttachmentAndFilesMigrationToS3Utility
* Author's Name     : Anas Yar Khan  
* Created Date      : 23rd Sep, 2022
* Description       : Utility class to push the attachments/files to S3
* Version.          : 1   
*/
public class AttachmentAndFilesMigrationToS3Utility {
    /*
    * Name of the function : pushAttachmentsAndFilesToS3
    * Author's Name        : Anas Yar Khan  
    * Created Date         : 23rd Sept, 2022
    * Description          : This method is used to push attachments/files to S3 bucket
    * Version.             : 1  
    * Parameters           : title,fileExtension,body,mapFileExtensionToContentType
	*/
    public static String pushAttachmentsAndFilesToS3(String title,String fileExtension,Blob body,Map<String,Object> mapFileExtensionToContentType) {
        String attachmentBody = EncodingUtil.base64Encode(body);
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String contentType = getContentType(fileExtension,mapFileExtensionToContentType);
        HttpRequest req  = new HttpRequest();
        req.setMethod('PUT');
        req.setEndpoint('callout:AWS_S3_Bucket'+'/'+title);
        req.setHeader('Content-Encoding','UTF-8');
        req.setHeader('Content-Type',contentType);
        req.setHeader('Connection','keep-alive');
        req.setHeader('Date',formattedDateString);
        req.setHeader('ACL','public-read-write');
        req.setHeader('Host','anas-tests-alesforce.s3.amazonaws.com');
        Blob blobToSend = EncodingUtil.base64Decode(attachmentBody);
        req.setBodyAsBlob(blobToSend);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() == 200) return 'SUCCESS';
        else return 'ERROR';
    } 	
    
    /*
    * Name of the function : getContentType
    * Author's Name        : Anas Yar Khan  
    * Created Date         : 23rd Sept, 2022
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