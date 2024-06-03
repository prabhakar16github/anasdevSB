/**
* @Name         PublishFallbackToTreasury_CTRL 
* @Author       Rohit Gupta
* @Created Date 22-Sep-2023
* @Group        FallBack 
* @Description  This class is used to send Fallback data to the Treasury.
*/
public class PublishFallbackToTreasury_CTRL {
    private String commId;
    private static FINAL String PROCESS_NAME = 'Fallback Fee';
    /***This method is to get the commercial id and if fallback need to publish are ture then send the data to treasury***/
    @AuraEnabled
    public static void fallbackToTreasury(String commId){
        List<Fallback_Charge__c> fallbackList = [SELECT Id,Commercial__c,Commercial__r.Merchant_MID__c,Commercial__r.Opportunity__c,Payment_Mode__c, Flat_Fee__c,Percentage__c,Rule_Id__c FROM Fallback_Charge__c WHERE Commercial__c =:commId AND Need_To_Publish__c = TRUE];
        List<FallBackFeePayload> payLoad = getPayloads(fallbackList);
        Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
        try{
            Map<Id,Fallback_Charge__c> fallbackMap = new Map<Id,Fallback_Charge__c>(fallbackList);
            if(fallbackList !=NULL && fallbackList.size()>0){
                publishDetail.Commercial__c = commId;
                publishDetail.Process__c = PROCESS_NAME;
                publishDetail.Merchant__c = fallbackList[0].Commercial__r.Opportunity__c;
                 publishDetail.Request_Count__c =payLoad.size();
                if(!payLoad.isEmpty()){
                    String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                    if(access_token != NULL){
                        HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_SaveBulkRules',access_token,JSON.serialize(payLoad),PROCESS_NAME);
                        publishDetail.Request_Count__c = payLoad.size();
                        List<ResponseWrapper> responseList = (List<ResponseWrapper>)JSON.deserialize(response.getBody(),List<ResponseWrapper>.class);
                        if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                            List<Fallback_Charge__c> fallBackRecordsToUpdate = new List<Fallback_Charge__c>();
                            for(ResponseWrapper wrp : responseList){
                                if(wrp.code == '2000' && wrp.status == 0 && wrp.result != NULL ){
                                    fallbackMap.get(wrp.result.pricingRecordId).put('Rule_Id__c',wrp.result.ruleId);
                                    fallbackMap.get(wrp.result.pricingRecordId).put('Published__c',true);
                                    fallbackMap.get(wrp.result.pricingRecordId).put('Need_to_Publish__c',False);
                                }
                                 if(!fallBackRecordsToUpdate.contains(fallbackMap.get(wrp.result.pricingRecordId))) {
                                	fallBackRecordsToUpdate.add(fallbackMap.get(wrp.result.pricingRecordId));    
                                }
                            }
                            if(!fallBackRecordsToUpdate.isEmpty()){
                                update fallBackRecordsToUpdate;
                            }
                            publishDetail.Status__c = 'Success';
                            publishDetail.Message__c = 'Successfully Published';
                        }
                        else{
                            publishDetail.Message__c = 'API Callout Error';
                            publishDetail.Status__c = 'Error';
                        }
                        if(publishDetail.Request_Body__c==null){
                            publishDetail.Request_Body__c = JSON.serialize(payLoad);
                        }
                        if(publishDetail.Response_Body__c==null){
                            publishDetail.Response_Body__c = response.getBody();    
                        }
                    }
                    else{
                        publishDetail.Message__c = 'Authorization Error';
                        publishDetail.Status__c = 'Error';
                        publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                    }
                }
                else{
                    publishDetail.Message__c = 'SF Data Error';
                    publishDetail.Status__c = 'Error';
                    publishDetail.Response_Body__c = 'SF Error : Pricing not found for the commercial.';
                }
                insert publishDetail;
            }
        }
        catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = 'Fallback Fee',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    /*******
     * Preparing the list of fallback which we need to send to treasury
	*********/
    private static List<FallBackFeePayload> getPayloads(List<Fallback_Charge__c> fallbackList){
        List<FallBackFeePayload> returnFallBackList = new List<FallBackFeePayload>();
        for(Fallback_Charge__c fallBack : fallbackList){
            FallBackFeePayload payLoadObj = new FallBackFeePayload();
            payLoadObj.tdrType= '0';
            payLoadObj.subPaymentMode = null;
            payLoadObj.percentageFee  = String.valueOf(fallBack.Percentage__c);
            payLoadObj.paymentScheme = null;
            payLoadObj.type   = 'TDR';
            payLoadObj.paymentMode =String.valueOf(fallBack.Payment_Mode__c);
            payLoadObj.paymentEntity = null;
            payLoadObj.merchantId =String.valueOf(fallBack.Commercial__r.Merchant_MID__c);
            payLoadObj.isOnus = null;
            payLoadObj.flatFee  =String.valueOf(fallBack.Flat_Fee__c);
            payLoadObj.debitModel = 'Net';
            payLoadObj.clientId = '1';
            payLoadObj.cardType = null;
            payLoadObj.moreThanAmount=null;
            payLoadObj.userUuid  = 'SF';
            payLoadObj.pricingRecordId = fallBack.Id;
            returnFallBackList.add(payLoadObj);
        }
        return returnFallBackList;
    }
    /** added by rohit Wrapper class to generate the Payload for platform fee that needs to be send in request body. */
    public class FallBackFeePayload{
        public String tdrType;
        public String subPaymentMode;
        public String percentageFee;
        public String paymentScheme;
        public String type;
        public String paymentMode;
        public String paymentEntity;
        public String merchantId;
        public String isOnus;
        public String flatFee;
        public String debitModel;
        public String clientId;
        public String cardType;
        public String moreThanAmount;
        public String userUuid;
        public String pricingRecordId;
        
    }/** END */
    /** Wrapper class to parse the response of saveBulkRules API. */
    public class ResponseWrapper{
        public String code;
        public String message;
        public Integer status;
        public ResponseResultWrapper result;
    }/** END */
    /** Wrapper class to parse the result object inside the response body. */
    public class ResponseResultWrapper{
        public String pricingRuleConfigId;
        public String pricingRecordId;
        public String ruleId;
    }/** END */
}