/**
* @Name         GetApiTreasuryDataController 
* @Author       Rohit Gupta
* @Created Date 05-April-2024
* @Description  This class is used to update or create Fixed pricing, Platform anmd TDR/Convenience data. we'll send entityId and 
revenue model comm seperated to treasury, will get the response and update or create on sf.
*/
public class GetApiTreasuryDataController{
    /******************Variables**************************/
    /* below map I have created because in sf revenue model picklist value are different from treasury side thats why 
we are mapping the values so that same will be update on sf as well.
***/
    private static Map<String,String> mapFeeTypeToRevenueModel = new Map<String,String>{'SETUP_FEE'=>'Setup Fee','AMC'=>'AMC','AFFORDABILITY_VAS_FEE'=>'Affordibility VAS','Conv Fee'=>'Convenience','TDR'=>'TDR'};
        public static Map<String,String> mapOfTransformerData = getMapTreasuryKeyToTreasuryDataId();
    public static Map<String,Master_Pricing_Data__c> mapOfMpdData = getMapSfKeyToMasterPricingData();
    public static String mId;
    public static String revenueModel;
    public static Integer pages=0;
    public static PricingWrapper pricingWrapper = new PricingWrapper();
    public static Id oppId;
    public static Id commId; 
    public static Integer countOfRecords =0;
    public static PublishpricingDetailsWrapper publishDetail = new PublishpricingDetailsWrapper();
    /************End******************/
    /**
* Below method is used to store  all the MPD data with primary key and mpd data records
**/
    public static Map<String,Master_Pricing_Data__c> getMapSfKeyToMasterPricingData() {
        Map<String,Master_Pricing_Data__c> mapOfPayuPgIdToMasterPricingData = new Map<String,Master_Pricing_Data__c>();
        for(Master_Pricing_Data__c mpd : [SELECT Id,Salesforce_Primary_Key__c,Payment_Mode__c,Payment_Option__c,
                                          Payment_Gateway__c,Pricing_Specification__c,ONUS_OFFUS__c
                                          FROM Master_Pricing_Data__c WHERE Active_Instrument__c =true LIMIT 50000]) {
                                              mapOfPayuPgIdToMasterPricingData.put(mpd.Salesforce_Primary_Key__c,mpd);	    
                                          }
        return mapOfPayuPgIdToMasterPricingData;
    }
    /**
* Below method is used to prepare all the sf treasury key with sf id
**/
    public static Map<String,String> getMapTreasuryKeyToTreasuryDataId() {
        Map<String,String> mapOfPayuPgIdToTreasuryKeyData = new Map<String,String>();
        for(SF_Treasury_Transformer__c trans :[SELECT Id, SF_ID__c, Payment_Mode__c, Sub_Payment_Mode__c, Payment_Scheme__c,
                                               Payment_Entity__c, Card_Type__c, IsOnus__c, PG_Name__c, PG_Type__c, Bank_Code__c 
                                               FROM SF_Treasury_Transformer__c]){
                                                   String key = trans.Payment_Mode__c;
                                                   key += String.isNotBlank(trans.Sub_Payment_Mode__c) ? '#'+trans.Sub_Payment_Mode__c:'#Blank';
                                                   key += String.isNotBlank(trans.Payment_Scheme__c) ? '#'+trans.Payment_Scheme__c:'#Blank';
                                                   key += String.isNotBlank(String.valueOf(trans.Payment_Entity__c)) ? '#'+trans.Payment_Entity__c:'#Blank';
                                                   key += String.isNotBlank(trans.IsOnus__c) ? '#'+String.valueOf(trans.IsOnus__c):'#'+0;
                                                   key += String.isNotBlank(trans.Card_Type__c) ? '#'+trans.Card_Type__c:'#Blank';
                                                   mapOfPayuPgIdToTreasuryKeyData.put(key.toLowerCase(),trans.SF_ID__c);
                                                   
                                               }
        return mapOfPayuPgIdToTreasuryKeyData;
    }
    /*This method will except the mid and revenue model as a parameter and send the data to processTreasuryData method 
which will make the wrapper and send to treasury in response will get the data*/
    @AuraEnabled
    public static PricingWrapper processTreasuryData(String entityId, String revenueModelCommSep) {
        // Querying the commercial to fetch the opportunity id and commId, we are using both ids while inserting the publish commercial records
        for(Commercial2__c comm :[SELECT Id,Opportunity__c  FROM Commercial2__c WHERE Merchant_MID__c  =: entityId]){
            oppId = comm.Opportunity__c;
            commId = comm.Id;
        }
        // Preparing the wrapper class to send it to treasury
        RevenueModelWrapper wrapper = new RevenueModelWrapper();
        wrapper.entityId = entityId;
        wrapper.clientId = '1';
        wrapper.isActive = true;
        wrapper.page = pages;
        wrapper.revenueModel =revenueModelCommSep;
        
        mId = entityId;// storing the enitity id in mid
        revenueModel =  wrapper.revenueModel; // storing the revenueModel 
        pages = wrapper.page + 1;// This is written for pagination means when processTreasuryData called then it will 
        //increase the page size to reach total pages size
        // Send the wrapper object to the treasury system and get the data
        PricingWrapper pricingWrap = sendToTreasury(wrapper);// from this line I am calling sendToTreasury method and passing 
        return pricingWrap;
    }
    // This method will convert the time field into IST time 
    public static Time getTimeValue(String timeField){
        Time tillOrTime; 
        Integer hours = Integer.valueOf(timeField.length() >= 2 ? timeField.left(2) : '0');
        Integer minutes = Integer.valueOf(timeField.length() == 4 ? timeField.right(2) : '0');
        tillOrTime = Time.newInstance(hours, minutes, 0, 0);
        return tillOrTime;
    }
    // This method will convert the UTC date field into IST 
    public static Date getDateTimeField(String DatetimeField){
        Date validFromDate;
        Datetime utcDateTime = DateTime.valueOf(DatetimeField.replace('T',' '));
        // Set the UTC timezone
        Timezone utcTimeZone = Timezone.getTimeZone('UTC');
        utcDateTime = utcDateTime.addSeconds(utcTimeZone.getOffset(utcDateTime) / 1000);
        // Set the IST timezone
        Timezone istTimeZone = Timezone.getTimeZone('Asia/Kolkata');
        Datetime istDateTime = utcDateTime.addSeconds(istTimeZone.getOffset(utcDateTime) / 1000);
        validFromDate= istDateTime.date();
        return validFromDate;
    }
    // Method to send the wrapper object to the external system
    private static PricingWrapper sendToTreasury(RevenueModelWrapper wrapper) {
        
        // Below map created if sfid not null we get from treasury in that case we get the data in map  
        Map<String,transformedPricingWrapper> mapOfTransform = new Map<String,transformedPricingWrapper>();
        // Implementation to send the wrapper object to the treasury system goes here
        try{
            publishDetail.mId  = oppId;
            publishDetail.commId  = commId; 
            publishDetail.process  = 'Get API Treasury Data';
            String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_BasedOnRevenueModel');
            if(access_token != NULL){
                HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_BasedOnRevenueModel',access_token,JSON.serialize(wrapper),'');
                if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                    ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                    if(responseWrap.result !=NULL && responseWrap.code == '2020' && responseWrap.status == 0){
                        Integer totalPages = responseWrap.result.totalPages;
                        publishDetail.status  = 'Success';
                        publishDetail.message  = 'Successfully Consumed';
						publishDetail.responseBody  += JSON.serialize(responseWrap.result.content) +pages+' Page data >>>';
                        //responseBodyFrmTreasury += JSON.serialize(responseWrap.result.content);
                        publishDetail.requestBody  =  JSON.serialize(wrapper);
                        countOfRecords += responseWrap.result.content.size();
                        for(ContentWrapper resWrapper : responseWrap.result.content){
                            if (resWrapper.revenueModel == 'SETUP_FEE' || resWrapper.revenueModel == 'AMC' || resWrapper.revenueModel == 'AFFORDABILITY_VAS_FEE') {
                                fixedPricingWrapper fixedWrapper = new fixedPricingWrapper();
                                fixedWrapper.debitModel =  resWrapper.debitModel;
                                fixedWrapper.ruleId = resWrapper.pricingRuleConfigId;
                                fixedWrapper.flatfee = Decimal.valueOf(resWrapper.flatFee);
                                fixedWrapper.published = true;
                                fixedWrapper.feeType =  mapFeeTypeToRevenueModel.get(resWrapper.revenueModel);
                                fixedWrapper.revenueModel = resWrapper.revenueModel;
                                fixedWrapper.addedBy = resWrapper.addedBy;
                                if(resWrapper.aggregationPeriod==null){
                                    fixedWrapper.paymentFrequency = resWrapper.frequency;
                                }
                                else
                                    fixedWrapper.paymentFrequency = resWrapper.aggregationPeriod;
                                fixedWrapper.versionNumber  = resWrapper.versionNumber;
                                fixedWrapper.source   = resWrapper.source;
                                if(resWrapper.validFrom !=NULL){
                                    fixedWrapper.startDate  = String.valueOf(getDateTimeField(resWrapper.validFrom));
                                }
                                if(resWrapper.validTill !=NULL){
                                    fixedWrapper.endDate  = String.valueOf(getDateTimeField(resWrapper.validFrom));
                                }
                                pricingWrapper.fixedWrapperList.add(fixedWrapper);
                            }
                            else if (resWrapper.revenueModel == 'Platform fees') {
                                platFormWrapper platformWrap = new platFormWrapper();
                                platformWrap.debitModel = resWrapper.debitModel;
                                platformWrap.ruleId = resWrapper.pricingRuleConfigId;
                                platformWrap.percentage = Decimal.valueOf( resWrapper.percentFee);
                                platformWrap.flatfee = Decimal.valueOf(resWrapper.flatFee);
                                platformWrap.published = true;
                                platformWrap.feeType  =  'GMV';
                                platformWrap.paymentFrequency  = resWrapper.aggregationPeriod;
                                platformWrap.versionNumber  = resWrapper.versionNumber;
                                platformWrap.source   = resWrapper.source;
                                platformWrap.revenueModel = resWrapper.revenueModel;
                                platformWrap.addedBy = resWrapper.addedBy;
                                if(resWrapper.validFrom !=NULL){
                                    platformWrap.startDate  =  String.valueOf(getDateTimeField(resWrapper.validFrom));
                                }
                                if(resWrapper.validTill !=NULL){
                                    platformWrap.endDate  = String.valueOf(getDateTimeField(resWrapper.validTill));
                                }
                                for(AttributeWrapper attribute : resWrapper.attributes) {
                                    if(attribute.pricingRuleKey == 'gmvSlab') {
                                        platformWrap.amount = Decimal.valueOf(attribute.pricingRuleValue);
                                    }
                                }
                                pricingWrapper.platformWrapperList.add(platformWrap);
                            }
                            else if(resWrapper.revenueModel == 'TDR' || resWrapper.revenueModel =='Conv Fee'){
                                Master_Pricing_Data__c mpdData = getMasterPricingData(resWrapper);
                                if(mpdData != null) {
                                    transformedPricingWrapper transFromWrap = new transformedPricingWrapper();
                                    transFromWrap.debitModel  = resWrapper.debitModel;
                                    transFromWrap.transactionType =  mapFeeTypeToRevenueModel.get(resWrapper.revenueModel);
                                    transFromWrap.pricingRuleConfigId = resWrapper.pricingRuleConfigId;
                                    if(resWrapper.revenueModel == 'TDR'){
                                        transFromWrap.tdrFlatFee  = Decimal.valueOf(resWrapper.flatFee);
                                        transFromWrap.tdrAmount = Decimal.valueOf(resWrapper.amountSlab);
                                        transFromWrap.tdrPercentFee   = String.valueOf( resWrapper.percentFee);
                                        transFromWrap.ruleId = resWrapper.pricingRuleConfigId;
                                    }
                                    if(resWrapper.revenueModel == 'Conv Fee'){
                                        transFromWrap.convenienceFlatFee   = Decimal.valueOf(resWrapper.flatFee);
                                        transFromWrap.convenienceAmount  = Decimal.valueOf(resWrapper.amountSlab);
                                        transFromWrap.conveniencePercentFee   = resWrapper.percentFee;
                                        transFromWrap.ruleIdConv = resWrapper.pricingRuleConfigId;
                                    }
                                    transFromWrap.source   = resWrapper.source;
                                    transFromWrap.clientId    = resWrapper.clientId;
                                    transFromWrap.subClientId    = resWrapper.subClientId;
                                    transFromWrap.ruleId = resWrapper.pricingRuleConfigId;
                                    transFromWrap.revenueModel = resWrapper.revenueModel;
                                    transFromWrap.versionNumber  = resWrapper.versionNumber ;
                                    transFromWrap.recordId = oppId;
                                    transFromWrap.addedBy = resWrapper.addedBy;
                                    transFromWrap.feeModel = resWrapper.debitModel;
                                    if(resWrapper.validFrom !=NULL){
                                        transFromWrap.validFrom = resWrapper.validFrom;
                                    }
                                    if(resWrapper.tillTime  !=null){
                                        transFromWrap.tillTime  = resWrapper.tillTime;
                                    }
                                    if(resWrapper.fromTime !=null){
                                        transFromWrap.fromTime  = resWrapper.fromTime;
                                    }
                                    if(resWrapper.validTill !=NULL){
                                        transFromWrap.validTill   = resWrapper.validTill;
                                    }
                                    transFromWrap.feeModel = resWrapper.debitModel;
                                    transFromWrap.paymentMode = mpdData.Payment_Mode__c;
                                    transFromWrap.paymentGateway =  mpdData.Payment_Gateway__c;
                                    transFromWrap.paymentOptions = mpdData.Payment_Option__c;
                                    transFromWrap.specifications =  mpdData.Pricing_Specification__c;
                                    transFromWrap.onusOffus = mpdData.ONUS_OFFUS__c;
                                    transFromWrap.mpdId = mpdData.Id;
                                    if(resWrapper.sfId !=null){
                                        transFromWrap.sfId = resWrapper.sfId.substringBefore('#'); 
                                    }
                                    pricingWrapper.transformedPricingWrapperPricingList.add(transFromWrap);
                                }
                            }
                        }
                        if(!mapOfTransform.isEmpty() && mapOfTransform.values() !=NULL){
                            pricingWrapper.transformedPricingWrapperPricingList.addAll(mapOfTransform.values());
                        }
                        if(totalPages > pages){
                            processTreasuryData(mId,revenueModel); 
                        }
                    }
                }
                else{
                    publishDetail.message  = 'API Callout Error';
                    publishDetail.status  = 'Error';
                }
            }
            else{
                publishDetail.message = 'Authorization Error';
                publishDetail.status = 'Error';
                publishDetail.responseBody  = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                
            } 
            //This below code is written to add publish pricing detail data 
            if(publishDetail != null){
                PricingWrapper.publishDetails = publishDetail;
            }
        }
        catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c =JSON.serialize(wrapper),Process__c ='Get API Treasury Data',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;// If error comes then inserting the proper response in Error_Details__c object
        }
        System.debug('transformer List:::'+ pricingWrapper.transformedPricingWrapperPricingList);
        return pricingWrapper;// returnig the final wrapper 
    }
    /****** Method to check if the paypgId for MPD  exists in Salesforce records if yes then return mpd data to the method where
its get called other wise return the untransform data***********/
    private static Master_Pricing_Data__c getMasterPricingData(ContentWrapper  resWrapper) {
        Map<String, String> mapOfKey = getValueByKey(resWrapper.attributes);// passing all the attribute to getValueByKey to get mapOf all the key and there value
        String keyForTreasury = mapOfKey.get('mode');
        keyForTreasury += String.isNotBlank(mapOfKey.get('ibiboCode')) ? '#'+mapOfKey.get('ibiboCode') :'#Blank';
        keyForTreasury += String.isNotBlank(mapOfKey.get('scheme')) ? '#'+mapOfKey.get('scheme') :'#Blank';
        keyForTreasury += String.isNotBlank(mapOfKey.get('pgId')) ? '#'+mapOfKey.get('pgId') :'#Blank';
        keyForTreasury += String.isNotBlank(mapOfKey.get('onus')) ? '#'+1:'#'+0;
        keyForTreasury += String.isNotBlank(mapOfKey.get('cardType')) ? '#'+mapOfKey.get('cardType') :'#Blank';
        if(mapOfTransformerData.containsKey(keyForTreasury.toLowerCase())){
            Master_Pricing_Data__c mpdData =  mapOfMpdData.get(mapOfTransformerData.get(keyForTreasury.toLowerCase()));
            return mpdData;
        }
        else{
            UntransformedPricingWrapper unTransFormData = new UntransformedPricingWrapper();
            unTransFormData.debitModel = resWrapper.debitModel;  
            unTransFormData.type = mapFeeTypeToRevenueModel.get(resWrapper.revenueModel);
            unTransFormData.paymentMode =mapOfKey.get('mode');
            unTransFormData.subPaymentMode =mapOfKey.get('ibiboCode');    
            unTransFormData.paymentScheme = mapOfKey.get('scheme');    
            unTransFormData.paymentEntity = mapOfKey.get('pgId');    
            untransFormData.cardType =mapOfKey.get('cardType');    
            unTransFormData.isOnus= mapOfKey.get('onus');    
            unTransFormData.moreThanAmount = resWrapper.amountSlab;    
            unTransFormData.flatFee = resWrapper.flatFee;     
            unTransFormData.percentageFee = resWrapper.percentFee;  
            pricingWrapper.UntransformedPricingWrapperPricingList.add(unTransFormData);
        }
        return null;
    }
    // Method to retrieve the value of a key from the attributes list
    private static Map<String,String>  getValueByKey(List<AttributeWrapper> attributes) {
        Map<String,String> mapOfTreasuryKey = new Map<String,String>();
        for(AttributeWrapper attribute : attributes) {
            mapOfTreasuryKey.put(attribute.pricingRuleKey,attribute.pricingRuleValue);
        }
        return mapOfTreasuryKey;
    }
    //This is the final wrapper class which we are returning
    public class PricingWrapper {
        public List<fixedPricingWrapper> fixedWrapperList = new List<fixedPricingWrapper>();
        public List<platFormWrapper> platformWrapperList = new List<platFormWrapper>();
        public List<transformedPricingWrapper > transformedPricingWrapperPricingList = new List<transformedPricingWrapper>();
        public List<UntransformedPricingWrapper > UntransformedPricingWrapperPricingList = new List<UntransformedPricingWrapper>();
        public PublishpricingDetailsWrapper publishDetails = new PublishpricingDetailsWrapper();
    }
    /********* This wrapper class is use to return transform data*************/ 
    public class transformedPricingWrapper {
        public String opp ;
        public String commId;
        public String debitModel;
        public String transactionType;
        public Decimal tdrFlatFee;
        public Decimal tdrAmount;
        public Decimal convenienceFlatFee;
        public Decimal convenienceAmount;
        public Decimal convenience;
        public String ruleIdConv;
        public String source;
        public String clientId;
        public String subClientId;
        public String ruleId;
        public Integer versionNumber;
        public String validFrom;
        public String tillTime;
        public String fromTime;
        public String validTill;
        public String paymentMode;
        public String recordId;
        public String paymentOptions;
        public String specifications ;
        public String paymentGateway;
        public String onusOffus;
        public String tdrPercentFee;
        public String conveniencePercentFee ;
        public String revenueModel;
        public String mpdId;
        public String feeModel;
        public String sfId;
        public String pricingRuleConfigId;
        public String addedBy;
    }
    /**************End************************/
    /********* This wrapper class is use to return Untransform data*************/ 
    public class UntransformedPricingWrapper {
        public String debitModel;
        public String type ;
        public String paymentMode;
        public String subPaymentMode;
        public String paymentScheme;
        public String paymentEntity;
        public String cardType;
        public String isOnus;
        public String moreThanAmount;
        public String flatFee;
        public String percentageFee;
    }
    /**************End************************/
    /********* This wrapper class is use to return fixed data*************/ 
    public class fixedPricingWrapper {
        public String debitModel;
        public String ruleId;
        public Decimal percentage;
        public Decimal flatfee;
        public Boolean published;
        public String feeType;
        public String paymentFrequency;
        public Integer versionNumber;
        public String source;
        public String startDate;
        public String endDate;
        public String revenueModel;
        public String addedBy;
    }
    /**************End************************/
    /********* This wrapper class is use to return Platform data*************/ 
    public class platFormWrapper{
        public String debitModel;
        public String ruleId;
        public Decimal percentage;
        public Decimal flatfee;
        public Boolean published;
        public String type;
        public String interval;
        public Integer versionNumber;
        public String source;
        public String startDate;
        public String endDate;
        public Decimal amount;
        public String feeType;
        public String paymentFrequency;
        public String revenueModel;
        public String addedBy;
    }
    /**************End************************/
    // Wrapper class for revenue model data
    public class RevenueModelWrapper {
        public String entityId;
        public String revenueModel;
        public String clientId;
        public Integer page;
        public Boolean isActive;
    }
    /** Wrapper class to parse the response of TreasuryPass API. */
    public class ResponseWrapper{
        public String code;
        public String message;
        public Integer status;
        public ResultWrapper result;
    }/** END */
    public class ResultWrapper{
        public Integer totalPages;
        public List<ContentWrapper> content;
    }/** END */
    public class AttributeWrapper{
        public String pricingRuleKey;
        public String pricingRuleValue;
    }
    public class PublishpricingDetailsWrapper{
        public String mId;
        public String commId;
        public String process;
        public String status;
        public String message;
        public String responseBody ='';
        public String requestBody;
        public Integer requestCount=0;
    }
    /** Wrapper class to parse the result object inside the response body. */
    public class ContentWrapper{
        public String pricingRuleConfigId;
        public String clientId;
        public String subClientId;
        public String entityId;
        public String revenueModel;
        public String debitModel;
        public String amountSlab;
        public String validFrom;
        public String validTill;
        public String tillTime;
        public String dayOfWeek;
        public String fromTime;
        public String frequency;
        public String percentFee;
        public String flatFee;
        public String mappingId;
        public String aggregationPeriod;
        public String source;
        public Integer versionNumber;
        public String sfId;
        public String addedBy;
        public List<AttributeWrapper> attributes;
        
    }/** END */
}