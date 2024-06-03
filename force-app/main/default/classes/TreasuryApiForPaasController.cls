/*
* Name of the class : TreasuryApiForPaasController
* Author's Name     : Rohit Gupta  
* Created Date      : 20th Dec, 2023
* Description       : Consume the existing treasury paas records based on revenue model.
* Version.          : 1   
*/ 
public class TreasuryApiForPaasController {
    public static Map<String,Id> mapRecordTypeNameToId = getmapRecordTypeNameToId();
    public static Date validFromDate;
    public static Time validFromTime;
    public static Time tillOrTime;
    public static Map<String,Id> getmapRecordTypeNameToId() {
        Map<String,Id> mapRecordTypeNameToId = new Map<String,Id>();   
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Other_Product_Pricing__c']) {
            mapRecordTypeNameToId.put(rt.DeveloperName,rt.Id);	    
        }
        return mapRecordTypeNameToId;
    }
    public static void getTimeValue(String timeField){
        Integer hours = Integer.valueOf(timeField.length() >= 2 ? timeField.left(2) : '0');
        Integer minutes = Integer.valueOf(timeField.length() == 4 ? timeField.right(2) : '0');
        tillOrTime = Time.newInstance(hours, minutes, 0, 0);
    }
    public static void getDateTimeField(String DatetimeField){
        Datetime utcDateTime = DateTime.valueOf(DatetimeField.replace('T',' '));
        // Set the UTC timezone
        Timezone utcTimeZone = Timezone.getTimeZone('UTC');
        utcDateTime = utcDateTime.addSeconds(utcTimeZone.getOffset(utcDateTime) / 1000);
        // Set the IST timezone
        Timezone istTimeZone = Timezone.getTimeZone('Asia/Kolkata');
        Datetime istDateTime = utcDateTime.addSeconds(istTimeZone.getOffset(utcDateTime) / 1000);
        validFromDate= istDateTime.date();
        validFromTime = istDateTime.time();
        
    }
    @AuraEnabled
    public static void getExistingRecords(Id recordId){
        List<Opportunity> oppList = [SELECT Id,Prod_MID__c,(SELECT Id,Aggregation_Period__c,Aggregation_Required__c,Amount_Slab__c,
                                                            Attributes__c,Published__c,Revenue_Model__c,Rule_Id__c,Shared_Fee__c,
                                                            Till_TIme__c,Valid_From__c,Valid_From_Time__c,Valid_Till__c,Valid_Till_Time__c
                                                            FROM Other_Product_Pricings__r) FROM Opportunity WHERE Id=:recordId AND Prod_MID__c !=NULL];
        
        Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
        TreasuryWrapper getOppCurrentRecords = getRecords(oppList[0].Prod_MID__c);
        SYstem.debug('getOppCurrentRecords:::::'+getOppCurrentRecords);
        try{
            publishDetail.Merchant__c = oppList[0].Id;
            publishDetail.Process__c = 'Get API For Paas';
            publishDetail.Request_Count__c = oppList.size();
            Map<String ,Other_Product_Pricing__c> otherNewRecordMap = new Map<String,Other_Product_Pricing__c>();  
            if(oppList !=NULL && oppList.size()>0){
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Treasury_Api_For_Paas_Token');
                if(access_token != NULL){
                    HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_TreasuryPaas',access_token,JSON.serialize(getOppCurrentRecords),'Get API For Paas');
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                        ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                        if(responseWrap.result !=NULL && responseWrap.code == '2000' && responseWrap.status == 0){
                            publishDetail.Status__c = 'Success';
                            publishDetail.Message__c = 'Successfully Published';
                            publishDetail.Response_Body__c = JSON.serialize(responseWrap.result);
                            publishDetail.Request_Body__c = JSON.serialize(getOppCurrentRecords);
                            for(ResponseResultWrapper resWrapper : responseWrap.result){
                                Other_Product_Pricing__c otherNewRecord = new Other_Product_Pricing__c();  
                                if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='instantSettlementTdr'){
                                    otherNewRecord.Debit_Model__c =  resWrapper.debitModel;
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Amount_Slab__c = Decimal.valueOf(resWrapper.amountSlab);
                                    otherNewRecord.Percent_Fee__c = Decimal.valueOf( resWrapper.percentFee);
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Published__c = true;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('Instant_Settlement');
                                    if(resWrapper.validFrom !=NULL){
                                        getDateTimeField(resWrapper.validFrom);
                                        otherNewRecord.Valid_From__c = validFromDate;
                                        otherNewRecord.Valid_From_Time__c = validFromTime;
                                    }
                                    if(resWrapper.tillTime  !=null){
                                        getTimeValue(resWrapper.tillTime);
                                        otherNewRecord.Till_TIme__c = tillOrTime;
                                    }
                                    if(resWrapper.fromTime !=null){
                                        getTimeValue(resWrapper.fromTime);
                                        otherNewRecord.From_TIme__c = tillOrTime;
                                    }
                                    if(resWrapper.validTill !=NULL){
                                        getDateTimeField(resWrapper.validTill);
                                        otherNewRecord.Valid_Till__c  = validFromDate;
                                        otherNewRecord.Valid_Till_Time__c = validFromTime;
                                    }
                                    otherNewRecord.Days_of_the_week__c = resWrapper.dayOfWeek;
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                                else if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='offerActivationFee'){
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.Published__c = true;
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('Offer_Engine');
                                    if(resWrapper.validFrom !=NULL){
                                        getDateTimeField(resWrapper.validFrom);
                                        otherNewRecord.Valid_From__c = validFromDate;
                                    }
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                                else if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='offerTDR'){
                                    otherNewRecord.Debit_Model__c =  resWrapper.debitModel;
                                    otherNewRecord.Percent_Fee__c = Decimal.valueOf( resWrapper.percentFee);
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Published__c = true;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('Offer_Engine');
                                    if(resWrapper.validFrom !=NULL){
                                        getDateTimeField(resWrapper.validFrom);
                                        otherNewRecord.Valid_From__c = validFromDate;
                                        otherNewRecord.Valid_From_Time__c = validFromTime;
                                    }
                                    if(Integer.valueOf(resWrapper.tillTime ) !=0){
                                        getTimeValue(resWrapper.tillTime);
                                        otherNewRecord.Till_TIme__c = tillOrTime;
                                    }
                                    if(Integer.valueOf(resWrapper.fromTime) !=0){
                                        getTimeValue(resWrapper.fromTime);
                                        otherNewRecord.From_TIme__c = tillOrTime;
                                    }
                                    if(resWrapper.validTill !=NULL){
                                        getDateTimeField(resWrapper.validTill);
                                        otherNewRecord.Valid_Till__c = validFromDate;
                                        otherNewRecord.Valid_Till_Time__c = validFromTime;
                                    }
                                    otherNewRecord.Days_of_the_week__c = resWrapper.dayOfWeek;
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                                else if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='MIN_BILL_OFFER_TDR'){
                                    otherNewRecord.Debit_Model__c =  resWrapper.debitModel;
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('Offer_Engine');
                                    otherNewRecord.Published__c = true;
                                    if(resWrapper.validFrom !=NULL){
                                        getDateTimeField(resWrapper.validFrom);
                                        otherNewRecord.Valid_From__c = validFromDate;
                                    }
                                    if(resWrapper.validTill !=NULL){
                                        getDateTimeField(resWrapper.validTill);
                                        otherNewRecord.Valid_Till__c = validFromDate;
                                    }
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                                else if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='CHECKOUT_EXPRESS_TDR'){
                                    otherNewRecord.Debit_Model__c =  resWrapper.debitModel;
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Published__c = true;
                                    otherNewRecord.Percent_Fee__c = Decimal.valueOf( resWrapper.percentFee);
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('Checkout_Express');
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                                else if(!otherNewRecordMap.containsKey(resWrapper.pricingRuleConfigId) && resWrapper.revenueModel=='SDK'){
                                    otherNewRecord.Revenue_Model__c =  resWrapper.revenueModel;
                                    otherNewRecord.Opportunity__c = oppList[0].Id;
                                    otherNewRecord.Rule_Id__c = resWrapper.pricingRuleConfigId;
                                    otherNewRecord.Published__c = true;
                                    otherNewRecord.Amount_Slab__c = Decimal.valueOf(resWrapper.amountSlab);
                                    otherNewRecord.Percent_Fee__c = Decimal.valueOf( resWrapper.percentFee);
                                    otherNewRecord.Flat_Fee__c = Decimal.valueOf(resWrapper.flatFee);
                                    otherNewRecord.RecordTypeId = mapRecordTypeNameToId.get('SDK');
                                    otherNewRecordMap.put( otherNewRecord.Rule_Id__c,otherNewRecord);
                                }
                            } 
                            if(otherNewRecordMap !=NULL){
                                upsert otherNewRecordMap.values() Rule_Id__c;
                                System.debug('otherNewRecordMap:::::'+otherNewRecordMap.values());
                            }
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
                insert publishDetail;
            } 
        }
        catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c =JSON.serialize(getOppCurrentRecords),Process__c ='Get API For Paas',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
            SYstem.debug('errorDetails:::::'+errorDetails);
        }
        
    }
    public static TreasuryWrapper getRecords(String mid){
        TreasuryWrapper wrp = new TreasuryWrapper();
        wrp.entityId ='181209'; //mid;
        return wrp;
    }
    public class TreasuryWrapper{
        public String clientId;
        public String subClientId;
        public String entityId;
    }
    /** Wrapper class to parse the response of TreasuryPass API. */
    public class ResponseWrapper{
        public String code;
        public String message;
        public Integer status;
        public List<ResponseResultWrapper> result;
    }/** END */
    /** Wrapper class to parse the result object inside the response body. */
    public class ResponseResultWrapper{
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
        public String aggregationRequired;
        public String percentFee;
        public String flatFee;
        public String isActive;
        public String sharedFee;
        public String feeBearerEntity;
        public String feeBearerEntityId;
        public String mappingId;
        public String addedOn;
        public String updatedOn;
        public String addedBy;
        public String updatedBy;
        public String isAggregationRequired;
        public String aggregationPeriod;
        public String gmvSlabValue;
        public String aggregatedRevenue;
        
    }/** END */
}