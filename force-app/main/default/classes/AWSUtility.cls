public class AWSUtility{    
     
    public static Boolean runningFromConsumerAPI = false;
    static String ACCESS_KEY;
    static String SECRET_KEY;
    
    public static String theEndPoint = ''; 
    
    public static void awsCreds(){
        if(String.isBlank(ACCESS_KEY) && String.isBlank(SECRET_KEY)){
            Credentials__c cred = Credentials__c.getInstance();
            ACCESS_KEY = cred.AWS_AccessKey__c;
            SECRET_KEY = cred.AWS_secretKey__c;
        }
    }
    
    public Integer getIterationCount(String className){
        List<Batch_Setting__mdt> bsList = [SELECT Id, Iteration_Count__c, DeveloperName FROM Batch_Setting__mdt WHERE DeveloperName =: className AND Iteration_Count__c != null];        
        if(!bsList.isEmpty()){
            return Integer.valueOf(bsList[0].Iteration_Count__c);
        }
        
        return 1;
    }
    
    public static HttpResponse getAWSData(String devName, List<String> paramValue, Blob blobBody, String strBody, Sobject headParamSob){
        awsCreds();
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, SetCompressed__c, ServiceName__c, Region__c,
                                                  IsAWS__c, EndPointUrl__c, Headers__c, Method__c FROM 
                                                  Integration_Setting__mdt WHERE DeveloperName =: devName];
        System.debug('insList >>>>>>>>>>>>>>-------------'+insList);
        if(!insList.isEmpty() && insList[0].IsAWS__c){                        
            String hashAlgo = 'HmacSHA256';  
            String endPointUrl = insList[0].EndPointUrl__c;                         
            
            if(paramValue != null && !paramValue.isEmpty()){
                endPointUrl = String.format(endPointUrl, paramValue);
                if(blobBody != null) theEndPoint = endPointUrl;           
            }
            
            Url theUrl = new Url(endPointUrl);
            String host = theUrl.getHost();
            system.debug('host=='+host);
            String path = theUrl.getPath();
            String canonicalQueryString = theUrl.getQuery();
            String body = String.isBlank(insList[0].Body__c) ? '' : insList[0].Body__c;
            strBody = String.isBlank(strBody) ? '' : strBody;
            
            HttpRequest req = new HttpRequest();
            String headers = insList[0].Headers__c;            
            String payloadHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', blobBody != null ? blobBody : (Blob.valueOf(String.isNotBlank(body) ? body : strBody))));               
            
            String currentDate = System.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
            String currentDateOnly = System.now().formatGMT('yyyyMMdd');                         
            Map<String, String> canonicalHeaderMap = new Map<String, String>{'host' => host, 'x-amz-date' => currentDate}; 
            canonicalHeaderMap.put('x-amz-content-sha256', payloadHash);
            if(String.isNotBlank(headers)){
                for(String each : headers.split(',')){ 
					String theParam = headParamSob == null ? each.subStringAfter(':') : String.valueOf(headParamSob.get(each.subStringAfter(':')));                     
                    system.debug('######## theParam-->'+theParam);
                    req.setHeader(each.subStringBefore(':'), theParam);                
                    canonicalHeaderMap.put(each.subStringBefore(':'), theParam);                                                            
                }
            }
            System.debug('canonicalHeaderMap-->'+canonicalHeaderMap);
            List<String> signedHeaderList = new List<String>(canonicalHeaderMap.keySet());   
                                              
            signedHeaderList.sort();
                        
            String signedHeaders = String.join(signedHeaderList, ';');   
            
            List<String> canonicalHeaderList = new List<String>();  
            
            for(String eachStr : signedHeaderList){
                canonicalHeaderList.add(eachStr + ':' + canonicalHeaderMap.get(eachStr));
            }   
            
            String canonicalHeaders = String.join(canonicalHeaderList, '\n') +  '\n';                               
            
            String canonicalRequest = String.join(new List<String>{insList[0].Method__c, path, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash}, '\n');            
            String credScope = String.join(new List<String>{currentDateOnly, insList[0].Region__c, insList[0].ServiceName__c, 'aws4_request'}, '/');
            String canonicalHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest)));
            String stringToSign = String.join(new List<String>{'AWS4-HMAC-SHA256', currentDate, credScope, canonicalHash}, '\n');
            System.debug(canonicalRequest+'>>>>>>>>>>>>>>-------------'+stringToSign);
            String kSecret = 'AWS4' + SECRET_KEY;
            Blob kDate = Crypto.generateMac(hashAlgo, Blob.valueOf(currentDateOnly), Blob.valueOf(kSecret));
            Blob kRegion = Crypto.generateMac(hashAlgo, Blob.valueOf(insList[0].Region__c), kDate);
            Blob kService = Crypto.generateMac(hashAlgo, Blob.valueOf(insList[0].ServiceName__c), kRegion);
            Blob kSigning = Crypto.generateMac(hashAlgo, Blob.valueOf('aws4_request'), kService);
            String signature = EncodingUtil.convertToHex(Crypto.generateMac(hashAlgo, Blob.valueOf(stringToSign), kSigning));
            
            String authHeader = 'AWS4-HMAC-SHA256 ';
            authHeader += 'Credential=' + String.join(new List<String>{ACCESS_KEY, currentDateOnly, insList[0].Region__c, insList[0].ServiceName__c, 'aws4_request'}, '/') + ', ';
            authHeader += 'SignedHeaders=' + signedHeaders + ', ';
            authHeader += 'Signature=' + signature;       
                        
            req.setEndPoint(endPointUrl);                    
            req.setHeader('x-amz-content-sha256', payloadHash);
            req.setHeader('x-amz-date', currentDate);
            req.setHeader('host', host);        
            req.setHeader('authorization', authHeader);             
            req.setMethod(insList[0].Method__c);
            
            if((String.isNotBlank(body) || String.isNotBlank(strBody)) && insList[0].Method__c == 'POST'){
                req.setBody(String.isNotBlank(body) ? body : strBody);
            }else if(blobBody != null && (insList[0].Method__c == 'PUT' || insList[0].Method__c == 'POST')){
                req.setBodyAsBlob(blobBody);
            }
            return new Http().send(req);
        }
        
        return null;
    }
         
    static Map<String, String> s3InfoMap = (Map<String, String>)JSON.deserialize(Label.S3Information, Map<String, String>.class);
           
    public static String uploadAndGetDocUrlS3(Sobject headParamSob, String mid, Blob targetBlob){        
        if(String.isNotBlank(theEndPoint)){
            theEndPoint = '';
        }        
        SECRET_KEY = s3InfoMap.get('secret_key');
        ACCESS_KEY = s3InfoMap.get('access_key');
        String md5Str = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', targetBlob));
        HttpResponse theResponse = AWSUtility.getAWSData('SendDocument', new List<String>{s3InfoMap.get('bucket'), s3InfoMap.get('region'), mid, md5Str}, targetBlob, '', headParamSob);         
        return theResponse.getStatusCode() == 200 ? s3InfoMap.get('host') + 'accounts/' + mid + '/documents/' + md5Str : '';
        //return theResponse.getStatusCode() == 200 ? s3InfoMap.get('host') + 'merchants/' + mid + '/documents/' + md5Str : '';
    }
    
    public static String encode(String theParam){
        return EncodingUtil.urlEncode(theParam, 'UTF-8');
    }  
    
    public static String uploadAndGetDocUrlS3Type(Sobject headParamSob, String mid, Blob targetBlob, String FolderName){        
        if(String.isNotBlank(theEndPoint)){
            theEndPoint = '';
        }        
        HttpResponse theResponse;
        SECRET_KEY = s3InfoMap.get('secret_key');
        ACCESS_KEY = s3InfoMap.get('access_key');
        String md5Str = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', targetBlob));
        if(FolderName == 'merchants') theResponse = AWSUtility.getAWSData('SendDocumentMerchant', new List<String>{s3InfoMap.get('bucket'), s3InfoMap.get('region'), mid, md5Str}, targetBlob, '', headParamSob);         
        else if(FolderName == 'onecare') theResponse = AWSUtility.getAWSData('SendDocumentCase', new List<String>{s3InfoMap.get('bucket'), s3InfoMap.get('region'), mid, md5Str}, targetBlob, '', headParamSob);
        else theResponse = AWSUtility.getAWSData('SendDocument', new List<String>{s3InfoMap.get('bucket'), s3InfoMap.get('region'), mid, md5Str}, targetBlob, '', headParamSob);
        return theResponse.getStatusCode() == 200 ? s3InfoMap.get('host') + FolderName+'/' + mid + '/documents/' + md5Str : '';
        
    }
}