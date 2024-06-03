/**
* @Name         PublishOtherProductApi_CTRL 
* @Author       Rohit Gupta
* @Created Date 11-Oct-2023
* @Group        Other Prodcut Pricing
* @Description  This class is used to send Other Prodcut Pricing data to the Treasury.
*/
public class PublishOtherProductApi_CTRL {
   // Below map is to get the Name of recordtype for particular other product pricing record
   public static Map<String,Id> mapRecordTypeNameToId = OtherProductPricingComponentController.getmapRecordTypeNameToId();
    /*
* Description       : PublishOtherProductApi_CTRL  method is to get the other prodcut pricing id and process for sending the data to treasury
* Version.          : 1   
*/
    public static void otherProductPricingToTreasury(String oppId,String productName){
        // Getting all the Other Product Pricing records which all have need to publish checkbox as True for the current MID
        List<Other_Product_Pricing__c> otherPricingList =   [SELECT Id, Debit_Model__c, Amount_Slab__c, Valid_From__c, Valid_Till__c,
                                                             Percent_Fee__c, Flat_Fee__c, Shared_Fee__c, Frequency__c, GMV_Slab__c,
                                                             Count_Slab__c, Revenue_Slab__c,RecordType.Name,Revenue_Model__c,Opportunity__c, Client_Id__c, Sub_Client_Id__c,
                                                             Entity_id__c, From_TIme__c, Till_TIme__c, Days_of_the_week__c,
                                                             Aggregation_Required__c, Aggregation_Period__c, Fee_Bearer_Entity__c,
                                                             Fee_Bearer_Entity_Id__c, Rule_Id__c, PG_Id__c, Mode__c, Ibibo_Code__c, Scheme__c,
                                                             Card_Type__c, ONUS__c,Valid_Till_Time__c,Valid_From_Time__c, Refund_Mode__c, Need_to_Publish__c, Published__c,Attributes__c FROM
                                                             Other_Product_Pricing__c WHERE Opportunity__c=: oppId AND RecordTypeId=:mapRecordTypeNameToId.get(productName) AND  Need_to_Publish__c= True AND Entity_Id__c != NULL];
        Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
        List<Map<String,Object>> mapRequestloadList =  new List<Map<String,Object>>();
        List<Map<String,Object>> mapResponseloadList =  new List<Map<String,Object>>();
        List<Other_Product_Pricing__c> otherPricingListToUpdate = new List<Other_Product_Pricing__c>();
        if(otherPricingList !=NULL && otherPricingList.size()>0){
            publishDetail.Merchant__c = oppId;
            publishDetail.Process__c = otherPricingList[0].RecordType.Name +' Product Publish API';
            publishDetail.Merchant__c = otherPricingList[0].Opportunity__c;
            publishDetail.Request_Count__c = otherPricingList.size();
            for(Other_Product_Pricing__c otherProduct : otherPricingList){
                // calling the generatePayloadsForOtherProduct to get the payload to send to treasury
                OtherPricingPayload payLoad = generatePayloadsForOtherProduct(otherProduct,true);
                try{
                    if(payLoad !=NULL){
                        Map<String,Object> mapRequestPayload = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(payLoad));
                        mapRequestloadList.add(mapRequestPayload);
                        String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                        if(access_token != NULL){
                            HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoad),'Other Product Pricing');
                            ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                            if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                                publishDetail.Status__c = 'Success';
                                publishDetail.Message__c = 'Successfully Published';
                                Map<String,Object> mapReposePayload = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                                if(responseWrap.result.pricingRuleConfigId != NULL  && responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL){
                                    otherProduct.Rule_Id__c  = responseWrap.result.pricingRuleConfigId;
                                    otherProduct.Need_to_Publish__c = false;
                                    otherProduct.Published__c = true;
                                    otherProduct.Last_Published_On__c = System.now();
                                    otherPricingListToUpdate.add(otherProduct);
                                    mapResponseloadList.add(mapReposePayload);
                                }
                            }else{
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
                    // If any error, we'll get the creating error record in sf.
                    Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = otherPricingList[0].RecordType.Name +' Product Publish API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                    insert errorDetails;
                }
            }
            publishDetail.Request_Body__c = JSON.serialize(mapRequestloadList);
            publishDetail.Response_Body__c = JSON.serialize(mapResponseloadList);
            update otherPricingListToUpdate;
            insert publishDetail; 
        }
    } 
           /*
* Description       : editProductPricingFromTreasury  method is used to send Edited commercial pricing record to treasury
* Version.          : 1   
*/
    @future(callout=true)
    public static void editProductPricingFromTreasury(String commercialId){
         List<Other_Product_Pricing__c> otherPricingList = [SELECT Id, Debit_Model__c, Amount_Slab__c, Valid_From__c, Valid_Till__c,
                                                             Percent_Fee__c, Flat_Fee__c, Shared_Fee__c, Frequency__c, GMV_Slab__c,
                                                             Count_Slab__c, Revenue_Slab__c,RecordType.Name,Revenue_Model__c,Opportunity__c, Client_Id__c, Sub_Client_Id__c,
                                                             Entity_id__c, From_TIme__c, Till_TIme__c, Days_of_the_week__c,
                                                             Aggregation_Required__c, Aggregation_Period__c, Fee_Bearer_Entity__c,
                                                             Fee_Bearer_Entity_Id__c, Rule_Id__c, PG_Id__c, Mode__c, Ibibo_Code__c, Scheme__c,Attributes__c,
                                                             Card_Type__c, ONUS__c,Valid_Till_Time__c,Valid_From_Time__c, Refund_Mode__c, Need_to_Publish__c, Published__c FROM
                                                             Other_Product_Pricing__c WHERE Id=:commercialId AND Rule_Id__c !=NULL AND Entity_Id__c != NULL];
        if(otherPricingList !=NULL && otherPricingList.size()>0){
            OtherPricingPayload payLoadForDelete = generatePayloadsForOtherProduct(otherPricingList[0],true);
            try{
                Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
                publishDetail.Merchant__c = otherPricingList[0].Opportunity__c;
                publishDetail.Process__c = otherPricingList[0].RecordType.Name +' Product Edit API';
                publishDetail.Request_Count__c = otherPricingList.size();
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                if(String.isNotBlank(access_token)){
                    HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoadForDelete),'Other Product Pricing');
                    ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                    publishDetail.Message__c = responseWrap.message;
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK' && responseWrap.result.pricingRuleConfigId != NULL  && responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL){
                        publishDetail.Status__c = 'Success';
                        otherPricingList[0].Need_to_Publish__c = false;
                        otherPricingList[0].Published__c = True;
                        otherPricingList[0].Last_Published_On__c = System.now();
                        update otherPricingList;
                    }else{
                        publishDetail.Status__c = 'Error';
                    }
                    publishDetail.Request_Body__c =JSON.serialize(payLoadForDelete);
                    publishDetail.Response_Body__c = response.getBody();
                }else{
                    publishDetail.Message__c = 'Authorization Error';
                    publishDetail.Status__c = 'Error';
                    publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                }
                insert publishDetail;}catch(Exception e){
                Error_Details__c errorDetails = new Error_Details__c(Request__c =JSON.serialize(payLoadForDelete),Process__c = otherPricingList[0].RecordType.Name +' Product Edit API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                insert errorDetails;
            }
        }
    }
       /*
* Description       : deleteProductPricingFromTreasury  method is to delete or deactivate the other prodcut pricing record from treasury
* Version.          : 1   
*/
    @future(callout=true)
    public static void deleteProductPricingFromTreasury(String commercialId){
         List<Other_Product_Pricing__c> otherPricingList = [SELECT Id, Debit_Model__c, Amount_Slab__c, Valid_From__c, Valid_Till__c,
                                                             Percent_Fee__c, Flat_Fee__c, Shared_Fee__c, Frequency__c, GMV_Slab__c,
                                                             Count_Slab__c, Revenue_Slab__c,RecordType.Name,Revenue_Model__c,Opportunity__c, Client_Id__c, Sub_Client_Id__c,
                                                             Entity_id__c, From_TIme__c, Till_TIme__c, Days_of_the_week__c,
                                                             Aggregation_Required__c, Aggregation_Period__c, Fee_Bearer_Entity__c,Attributes__c,
                                                             Fee_Bearer_Entity_Id__c, Rule_Id__c, PG_Id__c, Mode__c, Ibibo_Code__c, Scheme__c,
                                                             Card_Type__c, ONUS__c,Valid_Till_Time__c,Valid_From_Time__c, Refund_Mode__c, Need_to_Publish__c, Published__c FROM
                                                             Other_Product_Pricing__c WHERE Id=:commercialId AND Rule_Id__c !=NULL];
        if(otherPricingList !=NULL && otherPricingList.size()>0){
            OtherPricingPayload payLoadForDelete = generatePayloadsForOtherProduct(otherPricingList[0],false);
            try{
                Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
                publishDetail.Merchant__c = otherPricingList[0].Opportunity__c;
                publishDetail.Process__c = otherPricingList[0].RecordType.Name +' Product Delete API';
                publishDetail.Request_Count__c = otherPricingList.size();
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                if(String.isNotBlank(access_token)){
                    HttpResponse response = PricingIntegrationUtility.doCallout('New_API_Callout_Platform',access_token,JSON.serialize(payLoadForDelete),'Other Product Pricing');
                    ResponseWrapper responseWrap = (ResponseWrapper)JSON.deserialize(response.getBody(),ResponseWrapper.class);
                    publishDetail.Message__c = responseWrap.message;
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK' && responseWrap.result.pricingRuleConfigId != NULL  && responseWrap.code == '2000' && responseWrap.status == 0 && responseWrap.result != NULL){
                        publishDetail.Status__c = 'Success';
                        otherPricingList[0].Rule_Id__c  = '';
                        otherPricingList[0].Need_to_Publish__c = false;
                        otherPricingList[0].Published__c = false;
                        update otherPricingList;
                    }else{
                        publishDetail.Status__c = 'Error';
                    }
                    publishDetail.Request_Body__c =JSON.serialize(payLoadForDelete);
                    publishDetail.Response_Body__c = response.getBody();
                }else{
                    publishDetail.Message__c = 'Authorization Error';
                    publishDetail.Status__c = 'Error';
                    publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                }
                insert publishDetail;}catch(Exception e){
                Error_Details__c errorDetails = new Error_Details__c(Request__c =JSON.serialize(payLoadForDelete),Process__c = otherPricingList[0].RecordType.Name +' Product Delete API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
                insert errorDetails;
            }
        }
    }
    /*
* Description       : This method is used to prepare the payload that needs to be sent to treasury
* Version.          : 1   
*/
    private static OtherPricingPayload generatePayloadsForOtherProduct(Other_Product_Pricing__c otherProduct,Boolean isActive){
        DateTime validFromDateTime;
        DateTime validTillDateTime;
        String validFormateDateTime;
        String validFormateTillTime;
        String currentDate;
        // below label is to create for mapping the api name of filed and paramenter key which we need to send to treasury
        String transformerBasedValue = System.label.Transaction_Based_Parameters;
        Map<String, Object> jsonDataMap = (Map<String,Object>)JSON.deserializeUntyped(transformerBasedValue);
        List<AttributeWrapper> attributeList = new  List<AttributeWrapper>();
        // below if condition is to prepare the attribute list which we need to send to treasury
        if(otherProduct.Card_Type__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('Card_Type__c')),otherProduct.Card_Type__c));
        }
        if(otherProduct.Ibibo_Code__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('Ibibo_Code__c')),otherProduct.Ibibo_Code__c));
        }
        if(otherProduct.Mode__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('Mode__c')),otherProduct.Mode__c));
        }
        if(otherProduct.Scheme__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('Scheme__c')),otherProduct.Scheme__c));
        }
        if(otherProduct.PG_Id__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('PG_Id__c')),otherProduct.PG_Id__c));
        }
        if(otherProduct.ONUS__c !=NULL){
            attributeList.add(new AttributeWrapper(String.valueOf(jsonDataMap.get('ONUS__c')),otherProduct.ONUS__c));
        }
        if(otherProduct.Valid_From__c !=NULL ){
            Date validFromDate = otherProduct.Valid_From__c;
            Time validFromTime;
            if(otherProduct.Valid_From_Time__c !=NULL){validFromTime = otherProduct.Valid_From_Time__c ;
            }
            else{
                validFromTime = Time.newInstance(0,0,0,0);
            }
            DateTime combinedDateTime = DateTime.newInstance(validFromDate,validFromTime);
            validFromDateTime =getUTCDateTime(combinedDateTime);
            validFormateDateTime = validFromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            //currentDate = ;
        }
        if(otherProduct.Valid_Till__c !=NULL){
            Date  validTillDate = otherProduct.Valid_Till__c;
            Time validTillTime;
            if(otherProduct.Valid_Till_Time__c !=NULL){validTillTime = otherProduct.Valid_Till_Time__c ;
            }
            else{
                validTillTime = Time.newInstance(0,0,0,0);
            }
            DateTime combinedDateTime = DateTime.newInstance(validTillDate,validTillTime);
            validTillDateTime = getUTCDateTime(combinedDateTime);
            validFormateTillTime = validTillDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        }
        String fromTime;
        String tillTIme;
        if(otherProduct.From_TIme__c !=NULL){fromTime =String.valueOf(otherProduct.From_TIme__c.hour()) + String.valueOf(otherProduct.From_TIme__c.minute()).leftpad(2,'0');
        }
         if(otherProduct.Till_TIme__c !=NULL){tillTIme =String.valueOf(otherProduct.Till_TIme__c.hour()) + String.valueOf(otherProduct.Till_TIme__c.minute()).leftpad(2,'0');
        }
        OtherPricingPayload payLoadObj = new OtherPricingPayload();
        payLoadObj.clientId = '1';
        payLoadObj.entityId = String.valueOf(otherProduct.Entity_Id__c);
        payLoadObj.debitModel  = otherProduct.Debit_Model__c  !=NULL ? String.valueOf(otherProduct.Debit_Model__c  ) :'';
        payLoadObj.revenueModel   =  otherProduct.Revenue_Model__c !=NULL ? String.valueOf(otherProduct.Revenue_Model__c) :'';
        payLoadObj.aggregationPeriod =otherProduct.Aggregation_Period__c !=NULL ? String.valueOf(otherProduct.Aggregation_Period__c) :null; 
        payLoadObj.fromTime  = otherProduct.From_TIme__c  !=NULL ? fromTime :String.valueOf(0);
        payLoadObj.tillTime  = otherProduct.Till_TIme__c  !=NULL ? tillTIme :String.valueOf(2359);
        payLoadObj.validFrom = otherProduct.Valid_From__c !=NULL ? validFormateDateTime : System.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        payLoadObj.validTill = otherProduct.Valid_Till__c !=NULL ? validFormateTillTime :null;
        payLoadObj.dayOfWeek  =otherProduct.Days_of_the_week__c !=NULL ? String.valueOf(otherProduct.Days_of_the_week__c) :null;
        if(otherProduct.Aggregation_Period__c ==null)
            payLoadObj.aggregationRequired  = false;
        else
            payLoadObj.aggregationRequired  = true;
        payLoadObj.sharedFee  =otherProduct.Shared_Fee__c !=NULL ? String.valueOf(otherProduct.Shared_Fee__c) :'0';
        payLoadObj.percentFee  =otherProduct.Percent_Fee__c  !=NULL ? String.valueOf(otherProduct.Percent_Fee__c) :'0';
        payLoadObj.flatFee  =otherProduct.Flat_Fee__c  !=NULL ? String.valueOf(otherProduct.Flat_Fee__c) :'0';
        payLoadObj.isActive  = isActive;
        payLoadObj.amountSlab = otherProduct.Amount_Slab__c  !=NULL ? String.valueOf(otherProduct.Amount_Slab__c) :'0';
        payLoadObj.addedBy  = 'Salesforce';
        payLoadObj.updatedBy   = 'Salesforce';
        payLoadObj.mappingId = otherProduct.Rule_Id__c !=NULL ? String.valueOf(otherProduct.Rule_Id__c) :null;
        payLoadObj.frequency = otherProduct.Frequency__c !=NULL ? String.valueOf(otherProduct.Frequency__c ) :null;
        payLoadObj.gmvSlabValue = otherProduct.GMV_Slab__c !=NULL ? String.valueOf(otherProduct.GMV_Slab__c ) :null;
        payLoadObj.feeBearerEntity = otherProduct.Fee_Bearer_Entity__c !=NULL ? String.valueOf(otherProduct.Fee_Bearer_Entity__c) :null;
        payLoadObj.feeBearerEntityId = otherProduct.Fee_Bearer_Entity_Id__c  !=NULL ? String.valueOf(otherProduct.Fee_Bearer_Entity_Id__c ) :null;
        payLoadObj.attributes =  otherProduct.Attributes__c != NULL ? (List<AttributeWrapper>)JSON.deserialize(otherProduct.Attributes__c,List<AttributeWrapper>.class) : attributeList;

        return payLoadObj;
    }
    
    // Convertime the Datetime field to UTC formate
    public static DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour()-5,
            dt.minute()-30,
            dt.second());
        return GMTDate;
    }
    public class DeletePricingPayload{
        public String clientId; 
        public String revenueModel;
        public Boolean isActive;
        public String mappingId;
    }
    /** added by rohit Wrapper class to generate the Payload for platform fee that needs to be send in request body. */
    public class OtherPricingPayload{
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
        public String amountSlab;
        public String gmvSlabValue;
        public String feeBearerEntity;
        public String feeBearerEntityId;
        public List<AttributeWrapper> attributes;
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