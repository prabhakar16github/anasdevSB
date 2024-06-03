public without sharing class CreateCaseFormController {

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeId(Boolean isLoggedInMerchant){
        try {
            String developerName = isLoggedInMerchant ? 'LoggedInMerchant' : 'LoggedOutMerchant';
            return SObjectType.Bot__c.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '---> ' +'I am at line ' + String.valueOf(e.getLineNumber()));
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMerchantDetails(String merchantId){
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('success', true);
        try {            
            List<Opportunity> oppList = [SELECT Id, MerchantName__c, Email__c, Mobile__c FROM Opportunity WHERE Prod_MID__c = :merchantId LIMIT 1];
            if(!oppList.isEmpty()) {
                returnMap.put('data', oppList[0]);
            } else {
                returnMap.put('success', false);
                returnMap.put('errorMessage', 'Invalid Merchant Id');
            }
        } catch (Exception e) {
            returnMap.put('success', false);
            returnMap.put('errorMessage', e.getMessage());
        }

        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> createCase(String inputJSON, String filesJSON) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isCaseCreated', false);  

        try {
            
            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(inputJSON);
            
            //Blob attachment = uploadFile();
            String body = getPayload(inputMap, filesJSON);
            //inputMap.put('attachments', filesList);
            string strAccessToken = getAccessToken();
            Integration_Setting__mdt setting = [SELECT Id, EndPointUrl__c, Headers__c, Method__c FROM Integration_Setting__mdt WHERE DeveloperName =:'CreateCaseFromChat']?.get(0);
            
            Http http = new Http();
            //  Compose the http request
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndPoint(setting.EndPointUrl__c);
            httpRequest.setMethod(setting.Method__c);
            
            httpRequest.setHeader('Content-Type','application/json');
            httpRequest.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            httpRequest.setHeader('Authorization','Bearer '+ strAccessToken);
            httpRequest.setHeader('Connection', 'keep-alive');
            httpRequest.setBody(body);
            httpRequest.setHeader('Content-Length',String.valueof(body.length()));

            
            HttpResponse response =  new HttpResponse();
            if(!Test.isRunningTest()){
            	response = http.send(httpRequest); 
            }else{
                response.setBody('{"URL":"www.google.com"}');
            }        
            string resp2 = 'Code: ' + response.getStatusCode()+ '-- Body: '+response.getBody();    
        
            system.debug(response);
            system.debug(response.getBody());
            system.debug(response.getStatusCode());
            returnMap.put('body', response.getBody());
            returnMap.put('status', response.getStatusCode());
            Integer responseCode = response.getStatusCode();
            
            if(responseCode == 422) {
                returnMap.put('message', 'please enter a valid email and try again');
            } else{
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(responseCode == 200 || responseCode == 201) {
                    returnMap.put('isCaseCreated', true);
                    returnMap.put('message', responseMap.get('id'));
                } else {
                    if(responseMap.containsKey('error')) {
                        returnMap.put('message', responseMap.get('error'));
                    } else if (responseMap.containsKey('messsage')) {
                        returnMap.put('message', responseMap.get('message'));
                    }
                }
            }            

            
         } catch (Exception e) {
            System.debug('Exception '+e);
            returnMap.put('message',  e.getMessage() + '---> ' +'I am at line ' + String.valueOf(e.getLineNumber()));
        }

        return returnMap;
     }

    @AuraEnabled
    public static Map<String, Object> createCases(String inputJSON, String filesJSON) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isCaseCreated', false);  

        try {

            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(inputJSON);
            //List<Object> filesList = (List<Object>)JSON.deserializeUntyped(filesJSON);
			//inputMap.put('attachments', filesList);
            string strAccessToken = getAccessToken();
            Integration_Setting__mdt setting = [SELECT Id, EndPointUrl__c, Headers__c, Method__c FROM Integration_Setting__mdt WHERE DeveloperName =:'CreateCaseFromChat']?.get(0);
            
            Http http = new Http();
            //  Compose the http request
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndPoint(setting.EndPointUrl__c);
            httpRequest.setMethod(setting.Method__c);
            if(String.isNotBlank(setting.Headers__c)){
                for(String each : setting.Headers__c.split(',')){
                    if(each.subStringBefore(':') == 'Authorization'){
                        string value = each.subStringAfter(':') + ' '+strAccessToken;
                        System.debug('Header1 '+each.subStringBefore(':') +' '+value);
                        httpRequest.setHeader(each.subStringBefore(':'),value);
                    }
                    else{
                        System.debug('Header2 '+each.subStringBefore(':') +' '+each.subStringAfter(':'));
                        httpRequest.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
                    }
                }
            }

            String contentType = HttpFormBuilderUtility.GetContentType();
			System.debug('Header3 '+contentType);
            //  Compose the form
            System.debug('inputMap '+inputMap);
            string form64 = composeForm(inputMap);
            System.debug('FORM 64: '+form64);

            blob formBlob = EncodingUtil.base64Decode(form64);
            System.debug('Header5 formBlob '+formBlob);
            string contentLength = string.valueOf(formBlob.size());
            System.debug('Header4 '+contentLength);
            String fomString = EncodingUtil.base64Encode(formBlob);
            System.debug('Header5 '+fomString);
            httpRequest.setBodyAsBlob(formBlob);
            httpRequest.setEndpoint(setting.EndPointUrl__c);
            httpRequest.setHeader('Connection', 'keep-alive');
            httpRequest.setHeader('Content-Length', contentLength);
            httpRequest.setHeader('Content-Type', contentType);
            httpRequest.setMethod('POST');

            HttpResponse response =  new HttpResponse();
            if(!Test.isRunningTest()){
            response = http.send(httpRequest); 
            }else{
                response.setBody('{"URL":"www.google.com"}');
            }        
            string resp2 = 'Code: ' + response.getStatusCode()+ '-- Body: '+response.getBody();    
        
            system.debug(response);
            system.debug(response.getBody());
            system.debug(response.getStatusCode());
            returnMap.put('body', response.getBody());
            returnMap.put('status', response.getStatusCode());
            Integer responseCode = response.getStatusCode();
            
            if(responseCode == 422) {
                returnMap.put('message', 'please enter a valid email and try again');
            } else{
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(responseCode == 200 || responseCode == 201) {
                    returnMap.put('isCaseCreated', true);
                    returnMap.put('message', responseMap.get('id'));
                } else {
                    if(responseMap.containsKey('error')) {
                        returnMap.put('message', responseMap.get('error'));
                    } else if (responseMap.containsKey('messsage')) {
                        returnMap.put('message', responseMap.get('message'));
                    }
                }
            }            

        } catch (Exception e) {
            System.debug('Exception '+e);
            returnMap.put('message',  e.getMessage() + '---> ' +'I am at line ' + String.valueOf(e.getLineNumber()));
        }

        return returnMap;
    }

    @AuraEnabled
    public static String getAccessToken() {
        try {
            Integration_Setting__mdt setting = [SELECT Id, EndPointUrl__c, Headers__c, Method__c, Body__c FROM Integration_Setting__mdt WHERE DeveloperName =:'ChatBotCaseAuthToken']?.get(0);
        
            HttpRequest request = new HttpRequest();
            request.setEndPoint(setting.EndPointUrl__c);
            request.setMethod(setting.Method__c);
            request.setBody(setting.Body__c);
            if(String.isNotBlank(setting.Headers__c)){
                /*for(String each : setting.Headers__c.split(',')){
                    request.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
                }*/
                for(String each : setting.Headers__c.split(',')){
                    String key = each.subStringBefore(':'); // Trim the header key
                    String value = each.subStringAfter(':');
                    request.setHeader(key,value);
                }
            }

            HttpResponse response = new Http().send(request);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) responseMap.get('access_token');
            System.debug('Access Token: ' + accessToken);

            return accessToken;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '---> ' +'I am at line ' + String.valueOf(e.getLineNumber()));
        }        
    }

    private static String composeForm(Map<String, Object> inputMap) {
        //  Compose the form
        String form64 = '';
        for (String key : inputMap.keySet()) {
            form64 += HttpFormBuilderUtility.WriteBoundary();
            form64 += HttpFormBuilderUtility.WriteBodyParameter(key, String.valueOf(inputMap.get(key)));
        }
        form64 += HttpFormBuilderUtility.WriteBoundary(HttpFormBuilderUtility.EndingType.CrLf);

        return form64;
    }
    
    private static String getPayload(Map<String, Object> inputMap, String filesJSON){
        String form64 = '';
        String boundary = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=';
        String lineBreaks = '\r\n\r\n';
        //------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"issueCategory\"\r\n\r\n'+cat+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"mobileNo\"\r\n\r\n'+mobn+
        for (String key : inputMap.keySet()) {
            form64 += boundary + key + lineBreaks + String.valueOf(inputMap.get(key)) + '\r\n';
        }
        if(String.isNotBlank(filesJSON)){
            List<Object> filesList = (List<Object>)JSON.deserializeUntyped(filesJSON);
            System.debug(filesList );
            for (Object obj : filesList) {
                map<String,Object> m = (map<String,Object>) obj;
                //System.debug('Obj '+m.get('fileName'));
                //System.debug('Obj '+m.get('fileBlob'));
                //System.debug('Obj '+m.get('fileType'));
                String fileName = String.valueOf(m.get('fileName'));
                Blob fileData = Blob.valueOf(String.valueOf(m.get('fileBlob')));
               //form64 += boundary + key + lineBreaks + String.valueOf(inputMap.get(key)) + '\r\n';
                String boundry = '----------------------------' + String.valueOf(System.currentTimeMillis());
                String header = '--' + boundry + '\r\nContent-Disposition: form-data; name="attachments"; filename="' + fileName + '"\r\nContent-Type: application/octet-stream\r\n\r\n';
                String footer = '\r\n--' + boundry + '--\r\n';
                
                form64 += header + EncodingUtil.base64Encode(fileData) + footer;
            }
        }
       
        form64 += '------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        return form64;
    }
    /*String boundary = '----------------------------' + String.valueOf(System.currentTimeMillis());
        String header = '--' + boundary + '\r\nContent-Disposition: form-data; name="file"; filename="' + fileName + '"\r\nContent-Type: application/octet-stream\r\n\r\n';
        String footer = '\r\n--' + boundary + '--\r\n';
        
        String body = header + EncodingUtil.base64Encode(fileData) + footer;*/
    //String payLoad = '{"issueCategory":"New Product Inquiry","issueSubCategory":"Accept payments on Mobile App","description":"Demo TEST","merchantName":"testingd test","email":"sfdcyams@gmail.com","mobileNo":"9876843210","expectedMonthlySales":"Less than 50,000","recaptchaKey":"03AFcWeA6IaG4diHyS3KkJ3QkM7UMy4v7rXsQA9O1lcawYKORDM3o8849Squ1_d5r4ZUqwhWXdfM233EiQkG4NaxaYUMir3IlED-HsUGqSxfq6dH-7ShIpiBoylY1dn5eekpMzaEnrm4WM9kvuE2d7_A9YqzKTMcoWeQkqP-K3php5iy2Zbsg-MDXHFgdsUn6Xhxlc7tS8inw4k52gWG_z5AocJ6d30zghWuS6dBQiI8L-hb7ihFeS64wZyNHOm_fKx7ks0Hp4QxJq5CdOb7Yp03C2ymZergnaVXKGMU2EAuyonC5xwIR78apYtaq5tIZMOeQdDZCrOI_Uyyq6O9DcfjAvc-ZTArGPI_FQniBQRdOa3tZGTLBMMjLl8ii04M-tbglAu9haB-7kfKEQCIks_FHwCxoNiLbJq8BMxKEKtbdxCIFSsHgfsxIk1JuvqKWbEOpHhICg72CHjCcFNO3UfGVKZ7DACBak6NGz4z4EiF1No7olzzZMAnt-niYYF0N0g93C-2gohV4Qwc2SAr0OFceV8uPVtidmXI7qtccg4By31xtq8VigcHkpKw5xAbnWsAJ8lfxKYUPiSX74fbVN0PqAXulrrRNrBFgqFMu1qiEXECcxv9j7ZkLjF2alm0WtaFYbzmyJila1hgh8lCxSULeEYFUwyuAmMw","website":"https://demo.in","merchantBucket":"Not Logged In"}';
    public static blob uploadFile(Blob file_body, String file_name){
        
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
            
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the \r\n to the Blob, so leave footer as it is.
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            // Prepend the CR LF to the footer
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        return bodyBlob;
        
    }   
}