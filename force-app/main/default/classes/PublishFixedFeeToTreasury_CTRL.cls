/**
* @Name         PublishFixedFeeToTreasury_CTRL 
* @Author       Rohit Gupta
* @Created Date 18-Sep-2023
* @Group        Fixed Pricing Fee 
* @Description  This class is used to send Fixed Pricing data to the Treasury.
*/
public class PublishFixedFeeToTreasury_CTRL {
    private String commId;
    //public List<AttributeWrapper> attributes;
    private static FINAL String PROCESS_NAME = 'Fixed Pricing Fee';
    private static Map<String,String> mapFeeTypeToRM = new Map<String,String>{'Setup Fee'=>'SETUP_FEE','AMC'=>'AMC','Affordibility VAS'=>'AFFORDABILITY_VAS_FEE'};
    
    public static void FixedFeeToTreasury(String commId){
        String fixedFlag = System.label.Fixed_Pricing_Flag;
        List<Fixed_Pricing1__c> fixedPricingList = [SELECT Id ,Amount__c,Debit_Model__c,End_Date__c,Version_Number__c,Fee_Type__c,Flat_Fee__c,LastModifiedBy.Name,CreatedBy.Name,Need_to_Publish__c,Payment_Frequency__c,Percentage__c,Published__c,Start_Date__c,Rule_Id__c ,Commercial__r.Merchant_MID__c,Commercial__r.Opportunity__c FROM Fixed_Pricing1__c WHERE Commercial__c   =:commId AND Need_To_Publish__c = TRUE];
        List<Fixed_Pricing1__c> fixedPricingListToUpdate = new List<Fixed_Pricing1__c>();
        Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
        Integer recordCount=0;
        List<Map<String,Object>> mapRequestloadList =  new List<Map<String,Object>>();
        List<Map<String,Object>> mapResponseloadList =  new List<Map<String,Object>>();
        if(fixedPricingList !=NULL && fixedPricingList.size()>0){
            publishDetail.Commercial__c  = commId;
            publishDetail.Process__c = 'Fixed Pricing Fee';
            publishDetail.Merchant__c = fixedPricingList[0].Commercial__r.Opportunity__c;
            publishDetail.Request_Count__c = fixedPricingList.size();
            for(Fixed_Pricing1__c fixed : fixedPricingList){
                FixedFeePayload payLoad = generatePayloadsForFixed(fixed);
                try{
                    if(payLoad !=NULL){
                        Map<String,Object> mapRequestPayload = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(payLoad));
                        mapRequestloadList.add(mapRequestPayload);
                        String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                        if(access_token != NULL){
                            HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoad),PROCESS_NAME);
                            ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                            if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                                Map<String,Object> mapReposePayload = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                                if(responseWrap.result.pricingRuleConfigId != NULL  && responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL){
                                    fixed.Rule_Id__c  = responseWrap.result.pricingRuleConfigId;
                                    fixed.Version_Number__c = responseWrap.result.versionNumber;
                                    fixedPricingListToUpdate.add(fixed);
                                    mapResponseloadList.add(mapReposePayload);
                                }
                            }else{
                                publishDetail.Message__c = 'API Callout Error';publishDetail.Status__c = 'Error';
                            }
                        }else{
                            publishDetail.Message__c = 'Authorization Error';
                            publishDetail.Status__c = 'Error';
                            publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                        }
                    }
                }
                catch(Exception e){
                    Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = 'Fixed Pricing Fee',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                    insert errorDetails;
                }
            }
            publishDetail.Request_Body__c = (String)JSON.serialize(mapRequestloadList);
            publishDetail.Response_Body__c =  (String)JSON.serialize(mapResponseloadList);
        }
        /***Below code will execute after publishing the Fixed fee to treasury ***/
        if(fixedPricingListToUpdate !=NULL && fixedPricingListToUpdate.size()>0){
            publishDetail.Status__c = 'Success';
            publishDetail.Message__c = 'Successfully Published';
            for(Fixed_Pricing1__c fixedUpdate : fixedPricingListToUpdate){
                if(fixedUpdate.Rule_Id__c  !=NULL ){
                    fixedUpdate.Need_to_Publish__c = False;
                    fixedUpdate.Published__c = True;
                }
            }
            update fixedPricingListToUpdate;
            if(publishDetail !=NULL){
                insert publishDetail;
            }
            
        }
    }
    private static FixedFeePayload generatePayloadsForFixed(Fixed_Pricing1__c fixedFee){
        // Get the current datetime
        Datetime currentDatetime = Datetime.now();
        String formateCurrentDate = currentDatetime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        // Add 1 day to daytime 
        Datetime futureDateTime = currentDatetime.addDays(1);
        String formateFutureDate = futureDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        FixedFeePayload payLoadObj = new FixedFeePayload();
        payLoadObj.clientId = '1';
        payLoadObj.entityId = String.valueOf(fixedFee.Commercial__r.Merchant_MID__c);
        payLoadObj.debitModel  = fixedFee.Debit_Model__c  !=NULL ? String.valueOf(fixedFee.Debit_Model__c  ) :'';
        payLoadObj.revenueModel   =  fixedFee.Fee_Type__c !=NULL ? String.valueOf(mapFeeTypeToRM.get(fixedFee.Fee_Type__c)) :'';
        payLoadObj.aggregationPeriod = fixedFee.Payment_Frequency__c !=NULL ? String.valueOf(fixedFee.Payment_Frequency__c) :'';
        payLoadObj.frequency = fixedFee.Payment_Frequency__c !=NULL ? String.valueOf(fixedFee.Payment_Frequency__c) :'';
        payLoadObj.fromTime  = null;
        payLoadObj.tillTime  = null;
        payLoadObj.validFrom = fixedFee.Start_Date__c   !=NULL ? String.valueOf(fixedFee.Start_Date__c   ) :formateCurrentDate;//String.valueOf(currentDatetime);
        payLoadObj.validTill = fixedFee.End_Date__c   !=NULL ? String.valueOf(fixedFee.End_Date__c   ) :formateFutureDate ;//String.valueOf(futureDateTime);
        payLoadObj.dayOfWeek  = null;
        payLoadObj.aggregationRequired  = false;
        payLoadObj.sharedFee  = null;
        payLoadObj.percentFee  =fixedFee.Percentage__c  !=NULL ? String.valueOf(fixedFee.Percentage__c ) :'0';
        payLoadObj.flatFee  = String.valueOf(fixedFee.Flat_Fee__c) ;
        payLoadObj.isActive  = true;
       	payLoadObj.addedBy  = fixedFee.CreatedBy.Name;
        payLoadObj.updatedBy   = fixedFee.LastModifiedBy.Name;
        payLoadObj.source = 'Salesforce';
        payLoadObj.versionNumber =  fixedFee.Version_Number__c !=NULL ? Integer.valueOf(fixedFee.Version_Number__c) :0;
        payLoadObj.mappingId = fixedFee.Rule_Id__c !=NULL ? String.valueOf(fixedFee.Rule_Id__c) :null;
        return payLoadObj;
    }
    /** added by rohit Wrapper class to generate the Payload for platform fee that needs to be send in request body. */
    public class FixedFeePayload{
        public String entityId;
        public String clientId;
        public String debitModel;
        public String revenueModel;
        public String aggregationPeriod;
        public String fromTime;
        public String tillTime;
        public String validFrom;
        public String validTill;
        public String dayOfWeek;
        public String frequency;
        public Boolean aggregationRequired;
        public String sharedFee;
        public String percentFee;
        public String flatFee;
        public Boolean isActive;
        public String addedBy;
        public String updatedBy;
        public String source;
        public Integer versionNumber;
        public String mappingId;
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
        public Integer versionNumber;
    }/** END */
}