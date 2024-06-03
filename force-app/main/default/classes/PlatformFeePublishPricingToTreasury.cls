/**
* @Name         PlatformFeePublishPricingToTreasury 
* @Author       Rohit Gupta
* @Created Date 13-Sep-2023
* @Group        Platform Fee
* @Description  This is a batch class to send the Platform fee to the Treasury.
*/
public class PlatformFeePublishPricingToTreasury implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
	public Integer noOfFailedRecords = 0;
    private String commId;
    public List<AttributeWrapper> attributes;
    private static FINAL String PROCESS_NAME = 'Platform Fee';

    /** 
     * Constructor 
     * @param - commercial Id 
     * @param type - String 
     * Calling from PublishPricingToTreasury  
     */
    public PlatformFeePublishPricingToTreasury(String commercialId){
        this.commId = commercialId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String STATUS_PUBLISHED = 'Published';
        String query = 'SELECT Id,Commercial__c,Amount__c,Commercial__r.Opportunity__c,Commercial__r.Merchant_MID__c,Flat_Fee__c,Interval__c,Percentage__c,Name,Rule_Id__c,Type__c ';
        query += 'FROM Platform_Fee__c WHERE ';
        if(commId != NULL){
            query += 'Commercial__c  = :commId ';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Platform_Fee__c> platFromFeeList){
      System.debug('platFromFeeList:::::'+platFromFeeList);
        List<Platform_Fee__c> platFormList = new List<Platform_Fee__c>();
        for(Platform_Fee__c platFrom : platFromFeeList){
            PlatformFeePayload payLoad = generatePayloads(platFrom);
            System.debug('payLoad::::43::'+payLoad);
            try{
                Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
                publishDetail.Commercial__c = commId;
                publishDetail.Process__c = PROCESS_NAME;
                publishDetail.Merchant__c = platFrom.Commercial__r.Opportunity__c;
                if(payLoad !=NULL){
                    String access_token = PricingIntegrationUtility.getAccessToken('New_API_Get_Access_Token_Fetch');
                    if(access_token != NULL){
                        HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoad),'');
                        publishDetail.Request_Count__c = 1;
                        ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                        System.debug('body::::'+response.getBody());
                        System.debug('responseWrap:::::'+responseWrap);
                        if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                            if(responseWrap.result.pricingRuleConfigId != NULL ){
                                if(responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL ){
                                    platFrom.Rule_Id__c  = responseWrap.result.pricingRuleConfigId;
                                    platFormList.add(platFrom);
                                }
                            }
                            publishDetail.Status__c = 'Success';
                            publishDetail.Message__c = 'Successfully Published';
                        }
                        else{
                            publishDetail.Message__c = 'API Callout Error';
                            publishDetail.Status__c = 'Error';
                        }
                        publishDetail.Request_Body__c = JSON.serialize(payLoad);
                        publishDetail.Response_Body__c = response.getBody();
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
            catch(Exception e){
                Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = 'Platform API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                insert errorDetails;
            }
        }
        if(platFormList !=NULL && platFormList.size()>0){
            update platFormList;
        }
    }
    
    public void finish(Database.BatchableContext BC){
       
    }
    private static PlatformFeePayload generatePayloads(Platform_Fee__c platFromFee){
        List<AttributeWrapper> attributeList = new  List<AttributeWrapper>();
        PlatformFeePayload payLoadObj = new PlatformFeePayload();
        if(platFromFee.Amount__c !=NULL){
            attributeList.add(new AttributeWrapper('GmvSlab',String.valueOf(platFromFee.Amount__c)));
        }
        payLoadObj.clientId = '1';
        payLoadObj.merchantId = String.valueOf(platFromFee.Commercial__r.Merchant_MID__c);
        payLoadObj.debitModel  = '';
        payLoadObj.revenueModel   = 'Platform fees';
        payLoadObj.aggregationPeriod = 'daily';
        payLoadObj.fromTime  = null;
        payLoadObj.tillTime  = null;
        payLoadObj.validFrom = null;
        payLoadObj.validTill = null;
        payLoadObj.dayOfWeek  = String.valueOf(platFromFee.Interval__c);
        payLoadObj.aggregationRequired  = 'True';
        payLoadObj.sharedFee  = null;
        payLoadObj.percentFee  = platFromFee.Percentage__c !=NULL ? String.valueOf(platFromFee.Percentage__c ) :'';
        payLoadObj.flatFee  = platFromFee.Flat_Fee__c !=NULL ? String.valueOf(platFromFee.Flat_Fee__c ) :'';
        payLoadObj.isActive  = 'true';
        payLoadObj.addedBy  = 'Salesforce';
        payLoadObj.updatedBy   = 'Salesforce';
        payLoadObj.attributes = attributeList;
        
        return payLoadObj;
            
    }
    private static void updatePricingAsPublished(List<Pricing__c> pricingRecords){  
    }/** END */
    
	/** added by rohit Wrapper class to generate the Payload for fixed pricing that needs to be send in request body. */
    public class FixedPricingPayload{
    }/** END */
    /** added by rohit Wrapper class to generate the Payload for platform fee that needs to be send in request body. */
    public class PlatformFeePayload{
        public String merchantId;
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
        public String aggregationRequired;
        public String sharedFee;
        public String percentFee;
        public String flatFee;
        public String isActive;
        public String addedBy;
        public String updatedBy;
       	public List<AttributeWrapper> attributes;
        public String mappingId;
    }/** END */
    public class AttributeWrapper{
        public String attributeKey;
        public String attributeValue;
        public AttributeWrapper(String attributeKey,String attributeValue){
            this.attributeKey = attributeKey;
            this.attributeValue = attributeValue;
        }
    }
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
    }/** END */
}