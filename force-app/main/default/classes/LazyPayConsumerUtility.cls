/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this class is used to get the response from ESB QUEUE and to publish the the data is esb 
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
public class LazyPayConsumerUtility {
    static String ACCESS_KEY;
    static String SECRET_KEY;
    public static String theEndPoint = ''; 
    
    public static void awsCreds(){
        if(String.isBlank(ACCESS_KEY) && String.isBlank(SECRET_KEY)){
            LazyPay_Credentials__c lpcred = LazyPay_Credentials__c.getInstance();
            ACCESS_KEY = lpcred.Access_Key__c;
            SECRET_KEY = lpcred.Secret_Key__c;
        }
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to prepare authorization and Signature of the http request
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static HttpResponse getAWSData(String devName, List<String> paramValue, Blob blobBody, String strBody, Sobject headParamSob){
         awsCreds();
         String signature_for_Auth  = '';
        if(test.isRunningTest()){
            strBody= '{"business_object":"Customer","producer":"LazyPay","current_data":{"payloadId":"73726","uuid":"1234","kycCaseId":"8989"}}';
        }else{
            strBody = strBody;
        }
            signature_for_Auth = generateSignature(strBody); 
          
       
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, SetCompressed__c, ServiceName__c, Region__c, IsAWS__c, EndPointUrl__c, Headers__c, Method__c 
                                                    FROM Integration_Setting__mdt 
                                                    WHERE DeveloperName =: devName];
        System.debug('Payload**' + strBody);
        
        if(!insList.isEmpty() && insList[0].IsAWS__c){                        
            String hashAlgo = 'HmacSHA256';  
            String endPointUrl = insList[0].EndPointUrl__c;                         
            
            if(paramValue != null && !paramValue.isEmpty()){
                endPointUrl = String.format(endPointUrl, paramValue);
                if(blobBody != null){
                    theEndPoint = endPointUrl;
                }            
            }
            
            Url theUrl = new Url(endPointUrl);
            String host = theUrl.getHost();
            String path = theUrl.getPath();
            String canonicalQueryString = theUrl.getQuery();
            String body = String.isBlank(insList[0].Body__c) ? '' : insList[0].Body__c;
            strBody = String.isBlank(strBody) ? '' : strBody;
            String currentDate = System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\'');
            String currentDateOnly = System.now().formatGMT('YYYYMMdd');                         
            
            String canonicalHeaders = String.join(new List<String>{'cache-control:no-cache',insList[0].Headers__c, 'host:' + host, 'x-amz-date:' + currentDate}, '\n') +  '\n';
            String signedHeaders = 'cache-control;content-type;host;x-amz-date';        
            String payloadHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.isNotBlank(body) ? body : strBody)));               
            String canonicalRequest = String.join(new List<String>{insList[0].Method__c, path, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash}, '\n');            
            String credScope = String.join(new List<String>{currentDateOnly, insList[0].Region__c, insList[0].ServiceName__c, 'aws4_request'}, '/');
            String canonicalHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest)));
            String stringToSign = String.join(new List<String>{'AWS4-HMAC-SHA256', currentDate, credScope, canonicalHash}, '\n');
            
      system.debug('canonicalRequest========='+canonicalRequest); 
            system.debug('stringToSign==========='+stringToSign);
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
            
            HttpRequest req = new HttpRequest();
            req.setEndPoint(endPointUrl);        
            
            if(String.isNotBlank(insList[0].Headers__c)){
                for(String each : insList[0].Headers__c.split(',')){
                    system.debug('each @@@@@@ '+each+' %%%%%% headParamSob ******** '+headParamSob);
                    String theParam = headParamSob == null ? each.subStringAfter(':') : String.valueOf(headParamSob.get(each.subStringAfter(':')));                    
                    system.debug('theParam ------------- '+theParam);
                    req.setHeader(each.subStringBefore(':'), theParam);
                }
            }
            
            req.setHeader('x-amz-date', currentDate);
            req.setHeader('host', host);
            //req.setHeader('service', insList[0].ServiceName__c);
            //req.setHeader('authorization', authHeader);
            System.debug('Signature*****'+ signature_for_Auth);
            req.setHeader('signature', signature_for_Auth);
            //req.setHeader('signature', authHeader); 
            req.setMethod(insList[0].Method__c);
            
           if((String.isNotBlank(body) || String.isNotBlank(strBody)) && insList[0].Method__c == 'POST'){
                req.setBody(String.isNotBlank(body) ? body : strBody);
            }else if(blobBody != null && (insList[0].Method__c == 'PUT' || insList[0].Method__c == 'POST')){
                req.setBodyAsBlob(blobBody);
            }
            system.debug('req=========='+req);
            system.debug('reqBody=========='+req.getBody());
            return new Http().send(req);
        }
        
        return null;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to  encode the endpoint
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static String uploadAndGetDocUrlS3(Sobject headParamSob, String mid, Blob targetBlob){        
        if(String.isNotBlank(theEndPoint)){
            theEndPoint = '';
        }        
        
        String md5Str = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', targetBlob));
        HttpResponse theResponse = LazyPayConsumerUtility.getAWSData('SendDocument', new List<String>{mid, md5Str}, targetBlob, '', headParamSob); 
        System.debug(theResponse.getbody()+'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+theResponse.getStatusCode());       
        if(theResponse != null && theResponse.getStatusCode() == 200 && String.isNotBlank(theEndPoint)){
            return theEndPoint.replace('?md5=', '/');    
        }
              
        return '';
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to  encode the msg
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static String encode(String theParam){
        return EncodingUtil.urlEncode(theParam, 'UTF-8');
    } 
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to  encode the msg for deletion process
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static String encodeForConsumedMessages(String theParam){
        string strEncode = EncodingUtil.urlEncode(theParam, 'UTF-8');
        strEncode.replace('+', '%20');
        strEncode.replace('%7E', '~');
        return strEncode;
    }
   /**
    @author:            Kapil Chauhan
    @company:           SaaSFocus
    @description:       Used to generate the signature for authentication
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static string generateSignature(String payload){
    Map<String,Object> payloadWithCurrentdata = (Map<String,Object>)JSON.deserializeUntyped(payload);
    Map<String,Object> payLoadMap = new Map<String,Object>();    
    if(payloadWithCurrentdata.containsKey('current_data')){
       payLoadMap = (Map<String,Object>)payloadWithCurrentdata.get('current_data');  
    }        
    String uuid = '';
    String kycCaseId = '';
    String product = '';     
    if(payLoadMap.containsKey('uuid')){
       uuid =  String.valueof(payLoadMap.get('uuid'));    
    }
    if(payLoadMap.containsKey('kycCaseId')){
       kycCaseId =  String.valueof(payLoadMap.get('kycCaseId'));   
    }
    if(payLoadMap.containsKey('product')){
       product =  String.valueof(payLoadMap.get('product'));   
    }
        
              
        
    String algorithmName  =  'HmacSHA256';
    String secretKey = label.KYC_SF_To_LazyPay_Secret_Key;
    String input = 'product=LazyPay&producer=Salesforce&uuid=' + uuid + '&kycCaseId=' + kycCaseId + '&product=' + product ;
    System.debug('Input ***' + input);    
    Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(input), Blob.valueOf(secretKey));
    String signature = EncodingUtil.convertToHex(hmacData);    
    System.debug('Generated Signature : ' + EncodingUtil.convertToHex(hmacData));
    return signature;    
    }

}