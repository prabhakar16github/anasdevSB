public class Pricing_PublishOtherPricingToTreasury {
    private String objectAPIName;
    private Boolean checker;
    private String action;
    private String oppId;
    private Boolean isDeleteRequest;
    private Set<String> pricingIds;
    
    private Map<String,String> mapObjectToQuery = new Map<String,String>{
        'Fixed_Pricing1__c@@maker' => 'SELECT Id, Amount__c, Commercial__c, Debit_Model__c, End_Date__c, Fee_Type__c, Flat_Fee__c, Need_to_Publish__c, Payment_Frequency__c, Percentage__c, Published__c, Rule_Id__c, Start_Date__c, Version_Number__c, Source__c, Added_By__c, Temp_Id__c, Client_Id__c, Sub_Client_Id__c, Valid_From__c, Valid_Till__c, From_Time__c, Till_Time__c, Day_of_Week__c, Aggregation_Required__c, Max_Cap_TDR_Charge__c, Min_Cap_TDR_Charge__c, Shared_Fee__c, Fee_Bearer_Entity__c, Fee_Bearer_Entity_Id__c, Added_On__c, Aggregation_Period__c, GmvSlabValue__c, Deleted__c, Status__c, Aggregated_Revenue__c, Count_Slab_Value__c, Bearer_of_Charges__c, MID__c, OpportunityId__c FROM Fixed_Pricing1__c WHERE OpportunityId__c = \'<MID>\' AND Status__c = \'Approved (Awaiting Publishing)\' AND Need_To_Publish__c = true AND Deleted__c = false',
        'Fixed_Pricing1__c@@checker' => 'SELECT Id, Amount__c, Commercial__c, Debit_Model__c, End_Date__c, Fee_Type__c, Flat_Fee__c, Need_to_Publish__c, Payment_Frequency__c, Percentage__c, Published__c, Rule_Id__c, Start_Date__c, Version_Number__c, Source__c, Added_By__c, Temp_Id__c, Client_Id__c, Sub_Client_Id__c, Valid_From__c, Valid_Till__c, From_Time__c, Till_Time__c, Day_of_Week__c, Aggregation_Required__c, Max_Cap_TDR_Charge__c, Min_Cap_TDR_Charge__c, Shared_Fee__c, Fee_Bearer_Entity__c, Fee_Bearer_Entity_Id__c, Added_On__c, Aggregation_Period__c, GmvSlabValue__c, Deleted__c, Status__c, Aggregated_Revenue__c, Count_Slab_Value__c, Bearer_of_Charges__c, MID__c, OpportunityId__c FROM Fixed_Pricing1__c WHERE Id IN <idSet>',
        'Platform_Fee__c@@maker' => 'SELECT Id,Commercial__c,Type__c,Interval__c,Amount__c,Flat_Fee__c,Percentage__c,Rule_Id__c,Published__c,Need_to_Publish__c,Start_Date__c,End_Date__c,Debit_Model__c,Version_Number__c,Source__c,Added_By__c,Temp_Id__c,Added_On__c,Aggregated_Revenue__c,Aggregation_Period__c,Aggregation_Required__c,Bearer_of_Charges__c,Client_Id__c,Count_Slab_Value__c,Day_of_Week__c,Deleted__c,Error_Message__c,Fee_Bearer_Entity_Id__c,Fee_Bearer_Entity__c,From_Time__c,GMV_Slab_Value__c,MID__c,Max_Cap_TDR_Charge__c,Min_Cap_TDR_Charge__c,OpportunityId__c,Rejection_Reason__c,Shared_Fee__c,Status__c,Sub_Client_Id__c,Till_Time__c,Valid_From__c,Valid_Till__c FROM Platform_Fee__c WHERE OpportunityId__c = \'<MID>\' AND Status__c = \'Approved (Awaiting Publishing)\' AND Need_To_Publish__c = true AND Deleted__c = false',
        'Platform_Fee__c@@checker' => 'SELECT Id,Commercial__c,Type__c,Interval__c,Amount__c,Flat_Fee__c,Percentage__c,Rule_Id__c,Published__c,Need_to_Publish__c,Start_Date__c,End_Date__c,Debit_Model__c,Version_Number__c,Source__c,Added_By__c,Temp_Id__c,Added_On__c,Aggregated_Revenue__c,Aggregation_Period__c,Aggregation_Required__c,Bearer_of_Charges__c,Client_Id__c,Count_Slab_Value__c,Day_of_Week__c,Deleted__c,Error_Message__c,Fee_Bearer_Entity_Id__c,Fee_Bearer_Entity__c,From_Time__c,GMV_Slab_Value__c,MID__c,Max_Cap_TDR_Charge__c,Min_Cap_TDR_Charge__c,OpportunityId__c,Rejection_Reason__c,Shared_Fee__c,Status__c,Sub_Client_Id__c,Till_Time__c,Valid_From__c,Valid_Till__c FROM Platform_Fee__c WHERE Id IN <idSet>'
    };

    
    private Map<Boolean,String> mapCheckerToIntegrationSetting = new Map<Boolean,String>{true => 'API_Callout_SaveBulkRulesCT', false => 'API_Callout_SaveBulkRulesCF'};
    private Map<String,String> mapFeeTypeToRM = new Map<String,String>{'Setup Fee'=>'SETUP_FEE','AMC'=>'AMC','Affordibility VAS'=>'AFFORDABILITY_VAS_FEE'};
    
    
    /** @Constructor 
     * calling from 'PricingModuleComponentController' 
     */
    public Pricing_PublishOtherPricingToTreasury(String objectAPIName, Boolean checker, String action, String oppId, Boolean isDeleteRequest){
        this.objectAPIName = objectAPIName;
        this.checker = checker;
        this.action = action;
        this.oppId = oppId;
        this.isDeleteRequest = isDeleteRequest;
    }/** */

    /** @Constructor 
     * calling from checker screen 'Pricing_CheckerViewCompController' 
     */
    public Pricing_PublishOtherPricingToTreasury(String objectAPIName, Boolean checker, String action, Set<String> pricingIds, Boolean isDeleteRequest,String oppId){
        this.objectAPIName = objectAPIName;
        this.checker = checker;
        this.action = action;
        this.isDeleteRequest = isDeleteRequest;
        this.pricingIds = pricingIds;
        this.oppId = oppId;
    }
    
    
    public void processTheRequest() {
        
        String requestBody = '';
        String processName = '';
        try{
            String key = objectAPIName;
            key += checker ? '@@checker' : '@@maker';
            
            if(mapObjectToQuery.containsKey(key)){
                String query = '';
                if(checker){
                    String pricingIdStr = '(';
                    for(String str : pricingIds){
                        pricingIdStr += '\''+str+'\''+',';
                    }
                    pricingIdStr = pricingIdStr.removeEnd(',');
                    pricingIdStr += ')';
                    query = mapObjectToQuery.get(key).replace('<idSet>', pricingIdStr);
                } 
                else {
                    query = mapObjectToQuery.get(key).replace('<MID>', oppId);
                }
                
                
                if(!isDeleteRequest){
                    processName = 'SaveBulkRules-Checker'+checker+'Action'+action+objectAPIName;
                }else{
                    processName = 'DeleteBulkRules-Checker'+checker+'Action'+action+objectAPIName;
                }
                
                List<Sobject> sobjList = Database.query(query);
                if(!sobjList.isEmpty()){

                    List<Commercial2__c> commList = [SELECT Id FROM Commercial2__c WHERE Opportunity__c = :oppId LIMIT 1];
                    RequestWrapperClass requestWrapper = getBody(sobjList,action,isDeleteRequest,processName,oppId,checker);
                    requestBody = JSON.serialize(requestWrapper);
                    
                    Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
                    publishDetail.Object_API_Name__c = objectAPIName;
                    publishDetail.Commercial__c = commList[0].Id;
                    publishDetail.Merchant__c = oppId;
                    publishDetail.Process__c = processName;
                    publishDetail.Type__c = 'TDR';
                    publishDetail.Request_Count__c = requestWrapper.pricingRuleConfigurationDtoList.size();
                    publishDetail.Request_Id__c = requestWrapper.requestId;
                    publishDetail.Request_Body__c = requestBody;
                    publishDetail.Checker__c = checker;
                    publishDetail.Delete_Request__c = isDeleteRequest;
                    if(String.isNotBlank(requestBody)){
                        String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                        if(access_token != NULL){
                            HttpResponse response = PricingIntegrationUtility.doCallout(mapCheckerToIntegrationSetting.get(checker),access_token,requestBody,processName);
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
                }
            }
        }catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c = requestBody,Process__c = processName,Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    
    //Method called from processTheRequestMethod
    public RequestWrapperClass getBody(List<SObject> listPricing,String action,Boolean isDeleteRequest,String processName,String oppId, Boolean checker) {
        
        DateTime currentDateTimeUTCFormat = PublishPricingUtility.getUTCDateTime(DateTime.now());
        String currentDateTimeUTCFormatString = currentDateTimeUTCFormat.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        RequestWrapperClass requestWrapper = new RequestWrapperClass();
        requestWrapper.requestId = EncodingUtil.convertToHex(Blob.valueOf(oppId+currentDateTimeUTCFormatString+processName));
        requestWrapper.userToken = UserInfo.getUserId();
        requestWrapper.action = action;
        for(SObject pricing : listPricing) {
            createJSONRequest(requestWrapper,pricing,currentDateTimeUTCFormatString,isDeleteRequest,processName,checker); 
        } 
        return requestWrapper;
    }
    
    
    public void createJSONRequest(RequestWrapperClass requestWrapper,SObject pricing,String currentDateTimeUTCFormatString,Boolean isDeleteRequest,String processName,Boolean checker) {
         
        PricingRuleConfigurationDtoList pricingRecordDetails = new PricingRuleConfigurationDtoList();
        if(objectAPIName == 'Fixed_Pricing1__c'){
            Fixed_Pricing1__c fixedPricing = (Fixed_Pricing1__c)pricing;
            if(String.isNotBlank(fixedPricing.Temp_Id__c)){
                pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(fixedPricing.Temp_Id__c);
            } 
            pricingRecordDetails.clientId = Integer.valueOf(fixedPricing.Client_Id__c);
            
            if(String.isNotBlank(fixedPricing.Sub_Client_Id__c)){
                pricingRecordDetails.subClientId = fixedPricing.Sub_Client_Id__c;
            } 
            pricingRecordDetails.entityId = Integer.valueOf(fixedPricing.MID__c);
            pricingRecordDetails.revenueModel = mapFeeTypeToRM.get(fixedPricing.Fee_Type__c);
            pricingRecordDetails.debitModel = fixedPricing.Debit_Model__c;
            pricingRecordDetails.amountSlab = fixedPricing.Amount__c;
            if(String.isNotBlank(fixedPricing.Valid_From__c)){
                pricingRecordDetails.validFrom = fixedPricing.Valid_From__c;
            }else{
                DateTime dt = getUTCDateTime(Datetime.newInstance(fixedPricing.Start_Date__c,Datetime.now().time()));
                String startDateTimeUTCFormatString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                pricingRecordDetails.validFrom = startDateTimeUTCFormatString;
            }
            if(String.isNotBlank(fixedPricing.Valid_Till__c)){
                pricingRecordDetails.validTill = fixedPricing.Valid_Till__c;
            }else if(fixedPricing.End_Date__c != NULL){
                DateTime dt = getUTCDateTime(Datetime.newInstance(fixedPricing.End_Date__c,Datetime.now().time()));
                String startDateTimeUTCFormatString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                pricingRecordDetails.validTill = startDateTimeUTCFormatString;
            }
            pricingRecordDetails.fromTime = Integer.valueOf(fixedPricing.From_Time__c);
            pricingRecordDetails.tillTime = Integer.valueOf(fixedPricing.Till_Time__c);
            if(String.isNotBlank(fixedPricing.Day_of_Week__c)){
                pricingRecordDetails.dayOfWeek = fixedPricing.Day_of_Week__c;
            } 
            if(String.isNotBlank(fixedPricing.Payment_Frequency__c)){
                pricingRecordDetails.frequency = fixedPricing.Payment_Frequency__c;
            } 
            pricingRecordDetails.aggregationRequired = fixedPricing.Aggregation_Required__c;
            pricingRecordDetails.percentFee = fixedPricing.Percentage__c;
            pricingRecordDetails.flatFee = fixedPricing.Flat_Fee__c;

            if(fixedPricing.Max_Cap_TDR_Charge__c != NULL){
                pricingRecordDetails.maxCapTdrCharge = fixedPricing.Max_Cap_TDR_Charge__c;
            } 
            if(fixedPricing.Min_Cap_TDR_Charge__c != NULL){
                pricingRecordDetails.minCapTdrCharge = fixedPricing.Min_Cap_TDR_Charge__c;
            } 
            pricingRecordDetails.isActive = !isDeleteRequest;
            pricingRecordDetails.sharedFee = fixedPricing.Shared_Fee__c;
            if(String.isNotBlank(fixedPricing.Fee_Bearer_Entity__c)){
                pricingRecordDetails.feeBearerEntity = fixedPricing.Fee_Bearer_Entity__c;
            } 
            pricingRecordDetails.feeBearerEntityId = Integer.valueOf(fixedPricing.Fee_Bearer_Entity_Id__c);
            if(String.isNotBlank(fixedPricing.Rule_Id__c)){
                pricingRecordDetails.mappingId = Integer.valueOf(fixedPricing.Rule_Id__c);
            }
            
            if(String.isNotBlank(fixedPricing.Added_On__c)){
                pricingRecordDetails.addedOn = fixedPricing.Added_On__c;
            }else{
                pricingRecordDetails.addedOn = currentDateTimeUTCFormatString;
            }
            pricingRecordDetails.addedBy = fixedPricing.Added_By__c;

            if(checker){
                pricingRecordDetails.updatedBy = UserInfo.getName();
            } 
            if(String.isNotBlank(fixedPricing.Aggregation_Period__c)){
                pricingRecordDetails.aggregationPeriod = fixedPricing.Aggregation_Period__c;
            } 
            pricingRecordDetails.sfId = fixedPricing.Id+'#'+fixedPricing.Fee_Type__c;
            if(fixedPricing.GmvSlabValue__c != NULL){
                pricingRecordDetails.gmvSlabValue = fixedPricing.GmvSlabValue__c;
            } 
            if(fixedPricing.Aggregated_Revenue__c != NULL){
                pricingRecordDetails.aggregatedRevenue = fixedPricing.Aggregated_Revenue__c;
            }  
            if(fixedPricing.Count_Slab_Value__c != NULL){
                pricingRecordDetails.countSlabValue = fixedPricing.Count_Slab_Value__c;
            }  
            if(String.isNotBlank(fixedPricing.Bearer_of_Charges__c)){
                pricingRecordDetails.bearerOfCharges = fixedPricing.Bearer_of_Charges__c;
            }  
            pricingRecordDetails.versionNumber = Integer.valueOf(fixedPricing.Version_Number__c);
            pricingRecordDetails.source = fixedPricing.Source__c;
        }else if(objectAPIName == 'Platform_Fee__c'){
            
            Platform_Fee__c platformFee = (Platform_Fee__c)pricing;
            pricingRecordDetails = this.getRequestForPlatformFee(platformFee);
            
        }
        requestWrapper.pricingRuleConfigurationDtoList.add(pricingRecordDetails); 
    }

    /** Method to generate request for Platform Fee */
    private PricingRuleConfigurationDtoList getRequestForPlatformFee(Platform_Fee__c platformFee){

        DateTime currentDateTimeUTCFormat = PublishPricingUtility.getUTCDateTime(DateTime.now());
        String currentDateTimeUTCFormatString = currentDateTimeUTCFormat.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        
        PricingRuleConfigurationDtoList pricingRecordDetails = new PricingRuleConfigurationDtoList();
        
        if(String.isNotBlank(platformFee.Temp_Id__c)){
            pricingRecordDetails.pricingRuleConfigId = Integer.valueOf(platformFee.Temp_Id__c);
        } 
        pricingRecordDetails.clientId = Integer.valueOf(platformFee.Client_Id__c);
        
        if(String.isNotBlank(platformFee.Sub_Client_Id__c)){
            pricingRecordDetails.subClientId = platformFee.Sub_Client_Id__c;
        } 
        pricingRecordDetails.entityId = Integer.valueOf(platformFee.MID__c);
        pricingRecordDetails.revenueModel = 'Platform fees';//mapFeeTypeToRM.get(platformFee.Type__c);

        pricingRecordDetails.debitModel = platformFee.Debit_Model__c;
        //pricingRecordDetails.amountSlab = platformFee.Amount__c;
        if(String.isNotBlank(platformFee.Valid_From__c)){
            pricingRecordDetails.validFrom = platformFee.Valid_From__c;
        }else if(platformFee.Start_Date__c != NULL){
            
                DateTime dt = getUTCDateTime(Datetime.newInstance(platformFee.Start_Date__c,Datetime.now().time()));
                String startDateTimeUTCFormatString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                pricingRecordDetails.validFrom = startDateTimeUTCFormatString;
        }
        if(String.isNotBlank(platformFee.Valid_Till__c)){
            pricingRecordDetails.validTill = platformFee.Valid_Till__c;
        }else if(platformFee.End_Date__c != NULL){
            DateTime dt = getUTCDateTime(Datetime.newInstance(platformFee.End_Date__c,Datetime.now().time()));
            String startDateTimeUTCFormatString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            pricingRecordDetails.validTill = startDateTimeUTCFormatString;
        }

        pricingRecordDetails.fromTime = platformFee.From_Time__c != NULL ? Integer.valueOf(platformFee.From_Time__c) : NULL;
        pricingRecordDetails.tillTime = platformFee.Till_Time__c != NULL ? Integer.valueOf(platformFee.Till_Time__c) : NULL;
        pricingRecordDetails.dayOfWeek = platformFee.Day_of_Week__c ?? NULL;
        pricingRecordDetails.frequency = platformFee.Interval__c ?? NULL;
        pricingRecordDetails.aggregationRequired = String.isNotBlank(platformFee.Interval__c) ? true : false;
        pricingRecordDetails.percentFee = platformFee.Percentage__c;
        pricingRecordDetails.flatFee = platformFee.Flat_Fee__c;
        pricingRecordDetails.maxCapTdrCharge = platformFee.Max_Cap_TDR_Charge__c ?? NULL;
        pricingRecordDetails.minCapTdrCharge = platformFee.Min_Cap_TDR_Charge__c ?? NULL;
        pricingRecordDetails.isActive = !isDeleteRequest;
        pricingRecordDetails.sharedFee = platformFee.Shared_Fee__c;
        pricingRecordDetails.feeBearerEntity = platformFee.Fee_Bearer_Entity__c ?? NULL;
        pricingRecordDetails.feeBearerEntityId = platformFee.Fee_Bearer_Entity_Id__c != NULL ? Integer.valueOf(platformFee.Fee_Bearer_Entity_Id__c) : NULL;
        
        if(String.isNotBlank(platformFee.Rule_Id__c)){
            pricingRecordDetails.mappingId = Integer.valueOf(platformFee.Rule_Id__c);
        }
        
        if(String.isNotBlank(platformFee.Added_On__c)){
            pricingRecordDetails.addedOn = platformFee.Added_On__c;
        }else{
            pricingRecordDetails.addedOn = currentDateTimeUTCFormatString;
        }
        pricingRecordDetails.addedBy = platformFee.Added_By__c;

        if(checker){
            pricingRecordDetails.updatedBy = UserInfo.getName();
        } 
        pricingRecordDetails.aggregationPeriod = platformFee.Aggregation_Period__c ?? NULL;
        pricingRecordDetails.sfId = platformFee.Id+'#'+platformFee.Type__c;
        pricingRecordDetails.gmvSlabValue = platformFee.GMV_Slab_Value__c ?? NULL;
        pricingRecordDetails.aggregatedRevenue = platformFee.Aggregated_Revenue__c ?? NULL;
        pricingRecordDetails.countSlabValue = platformFee.Count_Slab_Value__c ?? NULL;
        pricingRecordDetails.bearerOfCharges = platformFee.Bearer_of_Charges__c ?? NULL;
        pricingRecordDetails.versionNumber = platformFee.Version_Number__c != NULL ? Integer.valueOf(platformFee.Version_Number__c) : NULL;
        pricingRecordDetails.source = platformFee.Source__c;

        String attributeKey = '';
        if(platformFee.Type__c == 'GMV'){
            attributeKey = 'gmvSlab';
            
        }else if(platformFee.Type__c == 'Transaction Count'){
            attributeKey = 'countSlab';
        }
        pricingRecordDetails.attributes.add(new Attributes(attributeKey,platformFee.Amount__c));
        
        return pricingRecordDetails;
    }
    
    public DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(dt.year(),dt.month(),dt.day(),dt.hour()-5,dt.minute()-30,dt.second());
        return GMTDate;
    }
    
    public class RequestWrapperClass {
        public String userToken = '';
        public String requestId = '';                                   //Unique Identifier to identify the request
        public String action = '';
        public List<PricingRuleConfigurationDtoList> pricingRuleConfigurationDtoList = new List<PricingRuleConfigurationDtoList>();
    }
    
    public class PricingRuleConfigurationDtoList {
        public Integer pricingRuleConfigId;// Temp Id          
        public Integer clientId ;                                       
        public String subClientId;                                     
        public Integer entityId;// MID                                       
        public String revenueModel;                                
        public String debitModel;                                  
        public Decimal amountSlab;  									
        public String validFrom;                                    
        public String validTill;                               
        public Integer fromTime;                                  
        public Integer tillTime;                                 
        public String dayOfWeek;                              
        public String frequency;
        public Boolean aggregationRequired;
        public Decimal percentFee;                              
        public Decimal flatFee;             
        public Decimal maxCapTdrCharge;
        public Decimal minCapTdrCharge;
        public Boolean isActive; 
        public Decimal sharedFee; 
        public String feeBearerEntity; 
        public Integer feeBearerEntityId; 
        public Integer mappingId;// RUle Id
        public String addedOn;
        public String addedBy;
        public String updatedBy;
        public String aggregationPeriod;
        public String sfId = '';										 
        public Decimal gmvSlabValue;										
        public Decimal aggregatedRevenue;										
        public Decimal countSlabValue;										
        public String bearerOfCharges;										
        public Integer versionNumber;                                    
        public String source = '';                            
        public String requestedBy = 'Salesforce';    
        public List<Attributes> attributes = new List<Attributes>();       
    } 

    public class Attributes {
        public String pricingRuleKey = '';
        public Decimal pricingRuleValue = 0;

        public Attributes(String pricingRuleKey,Decimal pricingRuleValue){
            this.pricingRuleKey = pricingRuleKey;
            this.pricingRuleValue = pricingRuleValue;
        }
    }
}