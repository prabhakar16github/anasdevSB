public class VKYC_DetailsController {
    @AuraEnabled
    public static Vkyc_Wrapper getVKYC_details(String oppId){
        if(String.isBlank(oppId)){
            return NULL;
        }
        
        Vkyc_Wrapper wrp;
        for(Video_KYC__c vkyc : [SELECT Id,Name,Opportunity__c,Capture_Link__c,toLabel(Status__c), Link_Created_At__c,CreatedDate  
                                 FROM Video_KYC__c 
                                 WHERE Opportunity__c = :oppId 
                                 AND Active__c = true
                                 AND Capture_Link__c != NULL
                                 ORDER By LastModifiedDate DESC 
                                 LIMIT 1]){
                                     wrp = new Vkyc_Wrapper();
                                     wrp.vkycObj = vkyc;
                                     if(vkyc.Link_Created_At__c != NULL){
                                         Integer daysDifference = vkyc.Link_Created_At__c.date().daysBetween(System.now().date());
                                         if(vkyc.Status__c == 'Pending' && daysDifference > 14){
                                             wrp.isValidLink = false;
                                         }
                                     }
                                     
                                 }
        
        return wrp;
        
    }
    
    @AuraEnabled
    public static String getCurrentUserProfile(){
        String profileName = '';
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1];
        if(!profileList.isEmpty()){
            profileName =  profileList[0].Name;
        }
        return profileName;
    }
    
    @AuraEnabled
    public static String generateLinkForVKYC(String oppId){
        if(String.isBlank(oppId)){
            return 'Error with opportunity Id';
        }
        
        String identifier = '';
        for(Opportunity opp : [SELECT Id,Identifier__c FROM Opportunity WHERE Id = :oppId AND Identifier__c != NULL LIMIT 1]){
            identifier = opp.Identifier__c;
        }
        
        if(String.isBlank(identifier)){
            return 'Error with identifier/UUID : Internal Salesforce Error';
        }
        
        Integration_Setting__mdt apiDetail = IntegrationUtility.getIntSetting('VKYC_Link_Generate_API');
        if(apiDetail == NULL || String.isBlank(apiDetail.EndPointUrl__c)){
            return 'Error with endPoint URL : Internal Salesforce Error';
        }
        
        if(String.isBlank(apiDetail.Method__c)){
            return 'Error with API method : Internal Salesforce Error';
        }
        
        String ACCESS_TOKEN = !Test.isRunningTest() ? IntegrationUtility.getAuthToken('VKYC_Link_Generate_Auth') : '2ec99b26f0536a6bea12a9a46dd587330f551d87750ad19bee82d9458b816844';
        if(String.isBlank(ACCESS_TOKEN)){
            return 'Authentication Error !!';
        }
        
        String endPointURL = getValidEndPoint(apiDetail.EndPointUrl__c, identifier);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointURL);
        request.setMethod(apiDetail.Method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        request.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()) {
            response = http.send(request);
        }else {
            String testResponseBody = '{"uuid":"11ee-7d58-1e1bfdbc-a7d0-02053299b2da","status":"link_generated","profile_id":"c7af44cc-69b8-4b9d-ab63-cfa596f09b9f","capture_link":"https://capture.kyc.idfy.com/captures?t=i3-7Bo_44aXs","scheduled_at":null,"start_time":null,"end_time":null,"capture_expires_at":null}';
            response.setBody(testResponseBody);
            response.setStatusCode(200);
        }
        if(response.getStatusCode() == 200 && response != NULL && String.isNotBlank(response.getBody())){
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(responseMap.get('status') != NULL && (String)responseMap.get('status') == 'link_generated'){
                return 'Link Updated Successfully';
            }
        }/*else if(response.getStatusCode() == 404){
            return 'Error : Not Found';
        }*/else if(response.getStatusCode() == 422 || response.getStatusCode() == 404){
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(responseMap.get('error_message') != NULL){
                return 'Error : '+response.getStatus()+' - '+(String)responseMap.get('error_message');
            }
        }
        //String response = '{"uuid": "11ee-634a-1f36ba84-9fbd-6261d1688b6a","status": "link_generated","profile_id": "01ab1bc1-b2b3-4ee7-9655-4bf1a9a34b1d","capture_link": "https://capture.kyc.idfy.com/captures?t=eXKjs9iYbmrZ","scheduled_at": null,"start_time": null,"end_time": null,"capture_expires_at": null}';
        //Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        return NULL;
    }
    
    private static String getValidEndPoint(String apiURL, String identifier){
        //String apiURL = 'https://test10-onboarding.payu.in/api/v3/product_accounts/{identifier}/vkyc/create_profile';
        String subString = apiURL.substringBetween('{','}');
        apiURL = apiURL.replace(subString,identifier).remove('{').remove('}');
        return apiURL;
    }
    
    @AuraEnabled
    public static String sendEmailWithVkycLink(String oppId,String vkycObjStr){
        try{
            if(String.isBlank(oppId)){
                return 'Error with opportunity Id.';
            }
            if(String.isBlank(vkycObjStr)){
                return 'Error with V-KYC details.';
            }
            
            Video_KYC__c vkycObj = (Video_KYC__c)JSON.deserialize(vkycObjStr,Video_KYC__c.class);
            List<EmailTemplate> vkycPendingTemplate = getEmailTemplate();
            if(vkycPendingTemplate.isEmpty()){
                return 'Email Template Error';
            }
            
            String orgWideAddressId = getOrgWideAddressId();
            if(orgWideAddressId == NULL){
                return 'Error with OrgWideEmailAddress';
            }
            
            Set<Id> accIds = new Set<Id>();
            for(Opportunity opp : [SELECT Id,AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1]){
                accIds.add(opp.AccountId);
            }
            if(accIds.isEmpty()){
                return 'Error with Account';
            }
            
            Set<Id> conIds = new Set<Id>();
            for(Contact con : [SELECT Id,Name,Email,AccountId FROM Contact 
                               WHERE AccountId IN :accIds
                               AND Active__c = true 
                               AND Authorised_Signatory__c = true 
                               AND Email != NULL
                               ORDER BY LastModifiedDate DESC LIMIT 1]){
                                   conIds.add(con.Id);
                               }
            if(conIds.isEmpty()){
                return 'Error with Authorized Signatory Details.';
            }
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Id conId : conIds){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(orgWideAddressId); 
                email.setTargetObjectId(conId); 
                email.setSaveAsActivity(false); 
                email.setTemplateID(vkycPendingTemplate[0].Id);
                email.setWhatid(vkycObj.Id);
                mails.add(email);
            }
            
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);
            }
            return 'Success';
        }catch(Exception ex){
            return 'Error : '+ex.getMessage();
        }
        
    }
    
    private static List<EmailTemplate> getEmailTemplate(){
        return [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                FROM EmailTemplate 
                WHERE DeveloperName = 'Video_KYC_Pending_Template' 
                LIMIT 1];
    }
    
    private static String getOrgWideAddressId(){
        String FROM_ADDRESS_FOR_Email = 'no_reply@payu.in';
        List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                                                    FROM OrgWideEmailAddress 
                                                    WHERE Address = :FROM_ADDRESS_FOR_Email 
                                                    LIMIT 1];
        if(!orgAddressList.isEmpty()){
            return orgAddressList[0].Id;
        }
        return NULL;
    }
    
    public class Vkyc_Wrapper{
        @AuraEnabled
        public Video_KYC__c vkycObj = new Video_KYC__c();
        @AuraEnabled
        public boolean isValidLink = true;
    }
}