/**
* @Name         PublishPlatformFeeToTreasury_CTRL 
* @Author       Rohit Gupta
* @Created Date 18-Sep-2023
* @Group        Platform 
* @Description  This class is used to send Platform data to the Treasury.
*/
public class PublishPlatformFeeToTreasury_CTRL {
    private String commId;
    public List<AttributeWrapper> attributes;
    private static FINAL String PROCESS_NAME = 'Platform Fee';
    /***This method is to get the commercial id and if platform need to publish are ture then send the data to treasury***/
   	@AuraEnabled
    public static void pricingToTreasury(String commId){
        List<Platform_Fee__c> platfromFeeList = [SELECT Id,Commercial__c,Start_Date__c,End_Date__c,Version_Number__c,LastModifiedBy.Name,CreatedBy.Name,Debit_Model__c ,Amount__c,Commercial__r.Opportunity__c,Commercial__r.Merchant_MID__c,Flat_Fee__c,Interval__c,Percentage__c,Name,Rule_Id__c,Type__c 
                                                 FROM Platform_Fee__c WHERE Commercial__c =:commId AND Need_To_Publish__c = TRUE];
        List<Platform_Fee__c> platformListToUpdate = new List<Platform_Fee__c>();
        Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
        Integer recordCount=0;
        List<Map<String,Object>> mapRequestloadList =  new List<Map<String,Object>>();
        List<Map<String,Object>> mapResponseloadList =  new List<Map<String,Object>>();
        List<Object> requestList = new List<Object>();
        List<Object> responseList = new List<Object>();
        if(platfromFeeList !=NULL && platfromFeeList.size()>0){
            publishDetail.Commercial__c = commId; 
            publishDetail.Process__c = PROCESS_NAME;
            publishDetail.Merchant__c = platfromFeeList[0].Commercial__r.Opportunity__c;
            for(Platform_Fee__c platFrom : platfromFeeList){
                PlatformFeePayload payLoad = generatePayloads(platFrom);
                try{
                    if(payLoad !=NULL){
                        // Below map I am using to get every request body which we are going to send to treasuary
                        Map<String,Object> mapRequestPayload = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(payLoad));
                        mapRequestloadList.add(mapRequestPayload);
                        String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                        if(access_token != NULL){
                            HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoad),'Platform Fee');
                            ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                            if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                                // Below map I am using to get every response body which we are receiving from treasuary
                                  Map<String,Object> mapReposePayload = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                                if(responseWrap.result.pricingRuleConfigId != NULL && responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL ){
                                        platFrom.Rule_Id__c  = responseWrap.result.pricingRuleConfigId;
                                    	platFrom.Version_Number__c = responseWrap.result.versionNumber;
                                        platformListToUpdate.add(platFrom);
                                        mapResponseloadList.add(mapReposePayload);
                                        recordCount++;
                                }
                            }
                            else{
                                publishDetail.Message__c = 'API Callout Error';
                                publishDetail.Status__c = 'Error';
                            }
                        }
                        else{
                            publishDetail.Message__c = 'Authorization Error';
                            publishDetail.Status__c = 'Error';
                            publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                        }
                    }
                }
                catch(Exception e){
                    Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = 'Platform API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                    insert errorDetails;
                }
            }
            publishDetail.Request_Body__c = (String)JSON.serialize(mapRequestloadList);
            publishDetail.Response_Body__c =  (String)JSON.serialize(mapResponseloadList);
            publishDetail.Request_Count__c =recordCount ;
            
            publishDetail.Status__c = 'Success';
            publishDetail.Message__c = 'Successfully Published';
            for(Platform_Fee__c  platform : platformListToUpdate){
                if(platform.Rule_Id__c !=NULL){
                    platform.Need_to_Publish__c = False;
                    platform.Published__c = True;
                }
            }
            update platformListToUpdate;
            if(publishDetail !=NULL ){
                insert publishDetail;
            }
        }
    }
    /*******
     * Preparing the list of Platform which we need to send treasury
	*********/
    private static PlatformFeePayload generatePayloads(Platform_Fee__c platFromFee){
         DateTime validFromDateTime;
         String validFormateDateTime;
         DateTime validTillDateTime;
         String validFormateTillDateTime;
         if(platFromFee.Start_Date__c !=NULL ){
            Date validFromDate = platFromFee.Start_Date__c;
            Time validFromTime = Time.newInstance(0,0,0,0);
            DateTime combinedDateTime = DateTime.newInstance(validFromDate,validFromTime);
            validFromDateTime =PublishOtherProductApi_CTRL.getUTCDateTime(combinedDateTime);
            validFormateDateTime = validFromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        }
         if(platFromFee.End_Date__c !=NULL ){
            Date validFromDate = platFromFee.End_Date__c;
            Time validFromTime = Time.newInstance(0,0,0,0);
            DateTime combinedDateTime = DateTime.newInstance(validFromDate,validFromTime);
            validTillDateTime =PublishOtherProductApi_CTRL.getUTCDateTime(combinedDateTime);
            validFormateTillDateTime = validTillDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        }
        List<AttributeWrapper> attributeList = new  List<AttributeWrapper>();
        PlatformFeePayload payLoadObj = new PlatformFeePayload();
        if(platFromFee.Amount__c !=NULL){
            attributeList.add(new AttributeWrapper('gmvSlab',String.valueOf(platFromFee.Amount__c)));
        }
        payLoadObj.clientId = '1';
        payLoadObj.entityId = String.valueOf(platFromFee.Commercial__r.Merchant_MID__c);
        payLoadObj.debitModel  = platFromFee.Debit_Model__c !=NULL ? String.valueOf(platFromFee.Debit_Model__c ) :'';
        payLoadObj.revenueModel   = 'Platform fees';	
        payLoadObj.aggregationPeriod = platFromFee.Interval__c  !=NULL ? String.valueOf(platFromFee.Interval__c  ) :'';
        payLoadObj.fromTime  = null;
        payLoadObj.tillTime  = null;
        payLoadObj.validFrom = platFromFee.Start_Date__c !=NULL ? validFormateDateTime :System.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        payLoadObj.validTill = platFromFee.End_Date__c !=NULL ? validFormateTillDateTime :'';
        payLoadObj.dayOfWeek  =null;
         if(platFromFee.Interval__c ==NULL)
            payLoadObj.aggregationRequired  = false;
        if(platFromFee.Interval__c !=NULL)
            payLoadObj.aggregationRequired  = True;
        payLoadObj.sharedFee  = null;
        payLoadObj.frequency = platFromFee.Interval__c !=NULL ? String.valueOf(platFromFee.Interval__c) :'';
        payLoadObj.percentFee  = platFromFee.Percentage__c !=NULL ? String.valueOf(platFromFee.Percentage__c ) :'0';
        payLoadObj.flatFee  = platFromFee.Flat_Fee__c !=NULL ? String.valueOf(platFromFee.Flat_Fee__c ) :'0';
        payLoadObj.isActive  = true;
        payLoadObj.addedBy  = platFromFee.CreatedBy.Name;
        payLoadObj.updatedBy   = platFromFee.LastModifiedBy.Name;
        payLoadObj.source = 'Salesforce';
        payLoadObj.versionNumber =  platFromFee.Version_Number__c !=NULL ? Integer.valueOf(platFromFee.Version_Number__c) :0;
        payLoadObj.attributes = attributeList;
        payLoadObj.mappingId = platFromFee.Rule_Id__c !=NULL ? String.valueOf(platFromFee.Rule_Id__c) :null;
        return payLoadObj;
    }
    /** added by rohit Wrapper class to generate the Payload for platform fee that needs to be send in request body. */
    public class PlatformFeePayload{
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
        public List<AttributeWrapper> attributes;
        public String source;
        public Integer versionNumber;
        public String mappingId;
    }/** END */
    public class AttributeWrapper{
        public String pricingRuleKey;
        public String pricingRuleValue;
        public AttributeWrapper(String pricingRuleKey,String pricingRuleValue){
            this.pricingRuleKey = pricingRuleKey;
            this.pricingRuleValue = pricingRuleValue;
        }
    }
    /** Wrapper class to parse the response of PLatform API. */
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