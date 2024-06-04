/*
* Name of the class : PublishPricingUtility
* Author's Name     : Anas Yar Khan  
* Created Date      : 7th March, 2024
* Description       : Utility class for publish pricing records to Treasury
* Version.          : 1   
*/ 
public class PublishPricingUtility {
    //query of pricing records
    public static String query = 'SELECT Id,Temp_Id_Delete_TDR__c,Temp_Id_Delete_Conv__c ,Temp_Id_TDR__c,Temp_Id_Conv__c,Opportunity__r.Prod_Merchant_Id__c,Fee_Model__c,Commercial2__c,Opportunity__c,Transaction_Type__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,Master_Pricing_SF_Key__c,Valid_From__c,Convenience_Flat_Fee__c,Convenience__c,Rule_Id__c,Rule_Id_Conv__c,CreatedBy.Name,LastModifiedBy.Name,Version_Number__c FROM Pricing__c '; 
    
    //Map of PayUPGId to SF_Treasury_Transformer__c
    public static Map<String,SF_Treasury_Transformer__c> mapPayuPGIdToTransformer = getMapPayuPGIdToTransformer();
    
    //Function to populate the map of PayUPGId with SF_Treasury_Transformer__c
    public static Map<String,SF_Treasury_Transformer__c> getMapPayuPGIdToTransformer() {
        Map<String,SF_Treasury_Transformer__c> mapPayuPGIdToTransformer = new Map<String,SF_Treasury_Transformer__c>();
        for(SF_Treasury_Transformer__c transformer : [SELECT Id,IsOnus__c,Payment_Mode__c,Sub_Payment_Mode__c,SF_ID__c,Payment_Scheme__c,Payment_Entity__c,Card_Type__c FROM SF_Treasury_Transformer__c LIMIT 50000]){
            mapPayuPGIdToTransformer.put(transformer.SF_ID__c,transformer);
        }
        return mapPayuPGIdToTransformer;
    }
    
    //Method called from processTheRequestMethod
    public static RequestWrapperClass getBody(List<Pricing__c> listPricing,String action,Boolean isDeleteRequest) {
        DateTime currentDateTimeUTCFormat = PublishPricingUtility.getUTCDateTime(DateTime.now());
        String currentDateTimeUTCFormatString = currentDateTimeUTCFormat.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        RequestWrapperClass requestWrapper = new RequestWrapperClass();
        requestWrapper.requestId = EncodingUtil.convertToHex(Blob.valueOf(listPricing[0].Commercial2__c+currentDateTimeUTCFormatString));
        requestWrapper.userToken = UserInfo.getUserId();
        requestWrapper.action = action;
        for(Pricing__c pricing : listPricing) {
            List<String> availableTransactionType = new List<String>();
            if(pricing.Transaction_Type__c == 'TDR' || pricing.Transaction_Type__c == 'Convenience') {
                availableTransactionType.add(pricing.Transaction_Type__c);    
            }
            else {
                availableTransactionType.add('TDR'); 
                availableTransactionType.add('Convenience'); 
            }  
            createJSONRequest(requestWrapper,pricing,availableTransactionType,currentDateTimeUTCFormatString,isDeleteRequest); 
        } 
        return requestWrapper;
    }
    
    public static void createJSONRequest(RequestWrapperClass requestWrapper,Pricing__c pricing,List<String> availableTransactionType,String currentDateTimeUTCFormatString,Boolean isDeleteRequest) {
        for(String transactionType : availableTransactionType) {
            PricingRuleConfigurationDtoList pricingRecordDetails = new PricingRuleConfigurationDtoList();
            if(transactionType == 'TDR') {
                if(isDeleteRequest && String.isNotBlank(pricing.Temp_Id_Delete_TDR__c)) pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(pricing.Temp_Id_Delete_TDR__c);
                else if(!isDeleteRequest && String.isNotBlank(pricing.Temp_Id_TDR__c)) pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(pricing.Temp_Id_TDR__c); 
                
                if(String.isNotBlank(pricing.Rule_Id__c)) pricingRecordDetails.mappingId = Integer.valueOf(pricing.Rule_Id__c); 
                pricingRecordDetails.amountSlab = pricing.TDR_Amount__c;
                pricingRecordDetails.percentFee = pricing.TDR__c;
                pricingRecordDetails.flatFee = pricing.TDR_Flat_Fee__c;
                pricingRecordDetails.revenueModel = 'TDR';
            }
            else if(transactionType == 'Convenience') {
                if(isDeleteRequest && String.isNotBlank(pricing.Temp_Id_Delete_Conv__c)) pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(pricing.Temp_Id_Delete_Conv__c);
                else if(!isDeleteRequest && String.isNotBlank(pricing.Temp_Id_Conv__c)) pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(pricing.Temp_Id_Conv__c);
                
                if(String.isNotBlank(pricing.Rule_Id_Conv__c)) pricingRecordDetails.mappingId = Integer.valueOf(pricing.Rule_Id_Conv__c);
                pricingRecordDetails.amountSlab = pricing.Convenience_Amount__c;
                pricingRecordDetails.percentFee = pricing.Convenience__c;
                pricingRecordDetails.flatFee = pricing.Convenience_Flat_Fee__c;
                pricingRecordDetails.revenueModel = 'Conv Fee';
            }
            pricingRecordDetails.isActive = !isDeleteRequest;
            pricingRecordDetails.sfId = pricing.Id+'#'+transactionType;
            pricingRecordDetails.entityId =  Integer.valueOf(pricing.Opportunity__r.Prod_Merchant_Id__c);
            pricingRecordDetails.debitModel = pricing.Fee_Model__c;
            pricingRecordDetails.validFrom = pricing.Valid_From__c != NULL ? pricing.Valid_From__c : currentDateTimeUTCFormatString;
            pricingRecordDetails.addedBy = pricing.CreatedBy.Name;
            pricingRecordDetails.updatedBy = pricing.LastModifiedBy.Name;
            pricingRecordDetails.versionNumber = Integer.valueOf(pricing.Version_Number__c);
            if(mapPayuPGIdToTransformer.containsKey(pricing.Master_Pricing_SF_Key__c)) {
                SF_Treasury_Transformer__c sfTransformer = mapPayuPGIdToTransformer.get(pricing.Master_Pricing_SF_Key__c);
                if(String.isNotBlank(sfTransformer.Payment_Mode__c)) pricingRecordDetails.attributes.add(getAttributes('mode',sfTransformer.Payment_Mode__c));		    
                if(String.isNotBlank(sfTransformer.Sub_Payment_Mode__c)) pricingRecordDetails.attributes.add(getAttributes('ibiboCode',sfTransformer.Sub_Payment_Mode__c));
                if(String.isNotBlank(sfTransformer.Payment_Scheme__c)) pricingRecordDetails.attributes.add(getAttributes('scheme',sfTransformer.Payment_Scheme__c));
                if(sfTransformer.Payment_Entity__c != NULL) pricingRecordDetails.attributes.add(getAttributes('pgId',String.valueOf(sfTransformer.Payment_Entity__c)));
                if(String.isNotBlank(sfTransformer.IsOnus__c) && sfTransformer.IsOnus__c == '1') pricingRecordDetails.attributes.add(getAttributes('onus','on_us'));
                if(String.isNotBlank(sfTransformer.Card_Type__c)) pricingRecordDetails.attributes.add(getAttributes('cardType',sfTransformer.Card_Type__c));
            }
            requestWrapper.pricingRuleConfigurationDtoList.add(pricingRecordDetails);    
        }    
    }
    
    public static Attributes getAttributes(String key,String value) {
        Attributes att = new Attributes();
        att.pricingRuleKey = key;
        att.pricingRuleValue = value;
        return att;
    }
    
    public static DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(dt.year(),dt.month(),dt.day(),dt.hour()-5,dt.minute()-30,dt.second());
        return GMTDate;
    }
    
    //Method called from batch class execute method
    public static void processTheRequest(List<Pricing__c> listPricing,String action,String apiSettingName,String processName,Boolean checker,Boolean isDeleteRequest) {
        RequestWrapperClass requestWrapper = getBody(listPricing,action,isDeleteRequest);
        String requestBody = JSON.serialize(requestWrapper);
        try{
            String commId = '';
            if(String.isBlank(commId)) commId = listPricing[0].Commercial2__c;
            Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
            publishDetail.Commercial__c = commId;
            publishDetail.Process__c = processName;
            publishDetail.Merchant__c = listPricing[0].Opportunity__c;
            publishDetail.Type__c = 'TDR';
            publishDetail.Request_Count__c = requestWrapper.pricingRuleConfigurationDtoList.size();
            publishDetail.Request_Id__c = requestWrapper.requestId;
            publishDetail.Request_Body__c = requestBody;
            publishDetail.Checker__c = checker;
            publishDetail.Delete_Request__c = isDeleteRequest;
            if(String.isNotBlank(requestBody)){
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                if(access_token != NULL){
                    HttpResponse response = PricingIntegrationUtility.doCallout(apiSettingName,access_token,requestBody,processName);
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                        publishDetail.Sync_Status__c = 'Processing';
                        publishDetail.Status__c = 'Success';
                        
                    }else{
                        publishDetail.Message__c = 'API Callout Error';
                        publishDetail.Status__c = 'Error';
                    }
                    publishDetail.Response_Body__c = JSON.serialize(response.getBody()); 
                }else{
                    publishDetail.Message__c = 'Authorization Error';
                    publishDetail.Status__c = 'Error';
                    publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                }
            }else{
                publishDetail.Message__c = 'SF Data Error';
                publishDetail.Status__c = 'Error';
                publishDetail.Response_Body__c = 'SF Error : Pricing not found for the commercial.';
            }
            insert publishDetail;
        }catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c = requestBody,Process__c = processName,Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    
    public class RequestWrapperClass {
        public String userToken = '';
        public String requestId = '';                                   //Unique Identifier to identify the request
        public String action = '';
        public List<PricingRuleConfigurationDtoList> pricingRuleConfigurationDtoList = new List<PricingRuleConfigurationDtoList>();
    }
    
    public class PricingRuleConfigurationDtoList {
        public Integer pricingRuleConfigId;                              //Temp Id
        public Integer clientId = 1;                                     //Default 1
        public String sfId = '';										 //Pricing record Id
        public String subClientId = null;                                //Default null
        public Integer entityId;                                         //Merchant Id
        public String revenueModel = '';                                 //Transaction Type
        public String debitModel = '';                                   //Fee Model
        public Decimal amountSlab;  									 //Amount
        public String validFrom = '';                                    //Current date time in UTC format
        public String validTill = null;                                  //Default null
        public Integer fromTime = 0;                                     //Default 0
        public Integer tillTime = 2359;                                  //Default 2359
        public String dayOfWeek = null;                                  //Default null
        public Decimal percentFee = 0;                                   //Percent Fee
        public Decimal flatFee = 0;                                      //Flat Fee
        public Boolean isActive = true;                                  //Default true
        public Integer mappingId;                                        //Rule Id
        public String addedBy = '';                                      //Username of the user created the pricing record
        public String updatedBy = '';                                    //Username of the user edited the pricing record
        public String source = 'Salesforce';                             //Default Salesforce
        public Integer versionNumber;                                     //Version Number 
        public List<Attributes> attributes = new List<Attributes>();     //List to hold mode,sub payment mode,scheme,card type,onus,payment entity
    } 
    
    public class Attributes {
        public String pricingRuleKey = '';
        public String pricingRuleValue = '';
    }
}