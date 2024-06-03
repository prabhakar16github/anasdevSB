/**
* @Name         PublishPricingToTreasury 
* @Author       Prabhakar Joshi
* @Created Date 4-Jan-2023
* @Group        Pricing, Banking Ops
* @Description  This is a batch class to send the Approved pricing to the Treasury.
*/
public class PublishPricingToTreasury implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    public Integer noOfFailedRecords = 0;
    private String commId;
    private Set<String> pricingIds;
    private Map<String,SF_Treasury_Transformer__c> transformDataMap = getTransformData();
    private Map<String,Object> tdrTypeMap = (Map<String,Object>)JSON.deserializeUntyped(label.Pricing_TDR_Type_Mapping);
    private Map<String,String> transactionTypeMap = new Map<String,String>{'TDR'=>'TDR','Convenience'=>'Conv Fee','TDR + Convenience'=>'TDR Plus Conv Fee'};
    private static FINAL String PROCESS_NAME = 'saveBulkRules';

    /** 
     * Constructor 
     * @param - commercial Id 
     * @param type - String 
     * Calling from Pricing screen   
     */
    public PublishPricingToTreasury(String commercialId){
        this.commId = commercialId;
    }

    /** 
     * Constructor 
     * @param - pricing Ids  
     * @param type - Set<String> 
     * Calling from Banking Ops screen
     */
    public PublishPricingToTreasury(Set<String> pricingIdSet){
        this.pricingIds = pricingIdSet;
    }
    
    /** 
     * Private Method definition to get the Map of SF key & Transformer record. 
     * Calling from transformDataMap 
     */
    private static Map<String,SF_Treasury_Transformer__c> getTransformData(){
        Map<String,SF_Treasury_Transformer__c> transformMap = new Map<String,SF_Treasury_Transformer__c>();
        for(SF_Treasury_Transformer__c trans : [SELECT Id,Name,IsOnus__c,Payment_Mode__c,Sub_Payment_Mode__c,SF_ID__c,Payment_Scheme__c,Payment_Entity__c,Card_Type__c FROM SF_Treasury_Transformer__c LIMIT 50000]){
            transformMap.put(trans.SF_ID__c,trans);
        }
        return transformMap;
    }/** END */
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> statusValues = new Set<String>{'Approved','Approved with BH'};
        String STATUS_PUBLISHED = 'Live';//'Published';
        String query = 'SELECT Id,Name,Commercial2__c,Commercial2__r.Opportunity__c,Commercial2__r.Merchant_MID__c,Payment_Mode_Text__c,Fee_Model__c,Transaction_Type__c,';
        query += 'TDR_Amount__c,Master_Pricing_Data__r.Payment_Mode_Text__c,Payment_Mode__c,ONUS__c,TDR_Flat_Fee__c,TDR__c,Master_Pricing_SF_Key__c, ';
        query += 'Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,Published__c,Rule_Id__c,Rule_Id_Conv__c ';
        query += 'FROM Pricing__c WHERE Banking_Ops_Status__c IN :statusValues AND Deleted__c = FALSE AND Need_To_Publish__c = TRUE ';
        if(commId != NULL){
            query += 'AND Commercial2__c = :commId ';
        }else if(pricingIds != NULL && !pricingIds.isEmpty()){
            query += 'AND Id IN :pricingIds AND Commercial2__r.Status__c = :STATUS_PUBLISHED';
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Pricing__c> pricingRecords){
        System.debug('>>>>>>pricingRecords>>>>>>'+pricingRecords);
        List<PricingPayload> payLoad = getPayloads(pricingRecords);
        try{
            if(commId == NULL){
                commId = pricingRecords[0].Commercial2__c;
            }
            
            Map<Id,Pricing__c> pricingMap = new Map<Id,Pricing__c>(pricingRecords);
    
            Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
            publishDetail.Commercial__c = commId;
            publishDetail.Process__c = PROCESS_NAME;
            publishDetail.Merchant__c = pricingRecords[0].Commercial2__r.Opportunity__c;
            
            
            if(!payLoad.isEmpty()){
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_SaveBulkRules');
                
                if(access_token != NULL){
    
                    HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_SaveBulkRules',access_token,JSON.serialize(payLoad),PROCESS_NAME);
                    publishDetail.Request_Count__c = payLoad.size();
                    
                    List<ResponseWrapper> responseList = (List<ResponseWrapper>)JSON.deserialize(response.getBody(),List<ResponseWrapper>.class);
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                        
                        
                        List<Pricing__c> pricingRecordsToUpdate = new List<Pricing__c>();
                        
                        for(ResponseWrapper wrp : responseList){
                            if(wrp.result.pricingRecordId != NULL && pricingMap.get(wrp.result.pricingRecordId.split('@@')[0]) != NULL){
                                String transactionType = wrp.result.pricingRecordId.split('@@')[1];
                                wrp.result.pricingRecordId = wrp.result.pricingRecordId.split('@@')[0];
                                
                                
                                if(wrp.code == '2000' && wrp.status == 0 && wrp.result != NULL ){
                                    if(transactionType == 'TDR'){
                                        pricingMap.get(wrp.result.pricingRecordId).put('Rule_Id__c',wrp.result.ruleId);
                                    }else if(transactionType == 'Convenience'){
                                        pricingMap.get(wrp.result.pricingRecordId).put('Rule_Id_Conv__c',wrp.result.ruleId);     

                                    }
                                }
                                 
                                //pricingMap.get(wrp.result.pricingRecordId).put('Last_Status_Treasury__c',wrp.message);
                                if(!pricingRecordsToUpdate.contains(pricingMap.get(wrp.result.pricingRecordId))) {
                                	pricingRecordsToUpdate.add(pricingMap.get(wrp.result.pricingRecordId));    
                                }
                            }
                        }
                        if(!pricingRecordsToUpdate.isEmpty()){
                            updatePricingAsPublished(pricingRecordsToUpdate);
                        }
                        publishDetail.Status__c = 'Success';
                        publishDetail.Message__c = 'Successfully Published';
                    }else{
                        publishDetail.Message__c = 'API Callout Error';
                        publishDetail.Status__c = 'Error';
                        noOfFailedRecords += payLoad.size();
                    }
                    publishDetail.Request_Body__c = JSON.serialize(payLoad);
                    publishDetail.Response_Body__c = response.getBody();
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
            Error_Details__c errorDetails = new Error_Details__c(Request__c = JSON.serialize(payLoad),Process__c = 'saveBulkRules API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(noOfFailedRecords > 0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Notification : Publish Pricing Result');
            email.setSaveAsActivity(false);
            email.setPlainTextBody(noOfFailedRecords + ' records not Published due to some Integration error. Please contact Salesforce Admin & check the logs in Salesforce.');
            email.setTargetObjectId(UserInfo.getUserId());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
    
    /** 
     * Private method definition to get the payloads for request body.
     * Calling from execute method. 
     * @param : List of Pricing records to generate the payloads for request body. 
     */
    private List<PricingPayload> getPayloads(List<Pricing__c> pricingRecords){
        List<PricingPayload> payLoad = new List<PricingPayload>();
        List<String> transactionTypes = new List<String>();

        for(Pricing__c pr : pricingRecords){
            if(pr.Transaction_Type__c == 'TDR' || pr.Transaction_Type__c == 'Convenience'){
                payLoad.addAll(generatePayloads(new List<String>{pr.Transaction_Type__c},pr));
            }else if(pr.Transaction_Type__c == 'TDR + Convenience'){
                payLoad.addAll(generatePayloads(new List<String>{'TDR','Convenience'},pr));
            }
        }
        return payLoad;
    }/** END */


    /** 
     * Private method definition to generate the payloads for request body.
     * Calling from getPayloads method.
     * @param 1 : List of transaction type (TDR,Convenience) 
     * @param 2 : object of pricing record
     */
    private List<PricingPayload> generatePayloads(List<String> transactionType, Pricing__c pr){
        List<PricingPayload> payLoad = new List<PricingPayload>();
        for(String trans : transactionType){
            PricingPayload payLoadObj = new PricingPayload();
            payloadObj.userUuid = 'SF';
            payLoadObj.pricingRecordId = pr.Id+'@@'+trans;
            payLoadObj.clientId = '1';
            payLoadObj.merchantId = String.valueOf(pr.Commercial2__r.Merchant_MID__c);
            payLoadObj.paymentMode = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).Payment_Mode__c) : '';//'upi';//
            payLoadObj.debitModel = String.valueOf(pr.Fee_Model__c);
            payLoadObj.type = String.valueOf(transactionTypeMap.get(trans));
            payLoadObj.subPaymentMode = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).Sub_Payment_Mode__c) : '';
            payLoadObj.paymentScheme = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).Payment_Scheme__c) : '';
            payLoadObj.paymentEntity = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).Payment_Entity__c) : '';
            payLoadObj.isOnus = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).IsOnus__c) : '';
            payLoadObj.cardType = transformDataMap.get(pr.Master_Pricing_SF_Key__c) != NULL ? String.valueOf(transformDataMap.get(pr.Master_Pricing_SF_Key__c).Card_Type__c) : '';
            payLoadObj.tdrType = (String)tdrTypeMap.get(transactionTypeMap.get(trans)+'-'+pr.Fee_Model__c);
            
            if(trans == 'TDR'){
                payLoadObj.moreThanAmount = String.valueOf(pr.TDR_Amount__c);
                payLoadObj.flatFee = String.valueOf(pr.TDR_Flat_Fee__c);
                payLoadObj.percentageFee = String.valueOf(pr.TDR__c);
            }else if(trans == 'Convenience'){
                payLoadObj.moreThanAmount = String.valueOf(pr.Convenience_Amount__c);
                payLoadObj.flatFee = String.valueOf(pr.Convenience_Flat_Fee__c);
                payLoadObj.percentageFee = String.valueOf(pr.Convenience__c);
            }
            payLoad.add(payLoadObj);
        }
        return payLoad;
    }/** END */
    

    /** 
     * Private method definition to update the pricing.
     * @param : List of Pricing records to mark as Published. 
     */
    private static void updatePricingAsPublished(List<Pricing__c> pricingRecords){
        System.debug('>>>>>>>>>pricingRecords>>>>>>>>>'+pricingRecords);
        for(Pricing__c pr : pricingRecords){
            if((pr.Rule_Id__c != NULL || pr.Rule_Id_Conv__c != NULL) /*&& pr.Last_Status_Treasury__c.equals('Success')*/){
                pr.Published__c = true;
                pr.Need_to_Publish__c = FALSE;
            }
        }
        
        update pricingRecords;
    }/** END */
    
    /** Wrapper class to generate the Payload that needs to send in request body. */
    public class PricingPayload{
        public String pricingRecordId;
        public String clientId;
        public String merchantId;
        public String paymentMode;
        public String debitModel;
        public String type;
        public String moreThanAmount;
        public String subPaymentMode;
        public String paymentScheme;
        public String paymentEntity;
        public String isOnus;
        public String cardType;
        public String flatFee;
        public String percentageFee;
        public String tdrType;
        public String userUuid;
    }/** END */

    /** Wrapper class to parse the response of saveBulkRules API. */
    public class ResponseWrapper{
        public String code;
        public String message;
        public Integer status;
        public ResponseResultWrapper result;
        public String traceId;
    }/** END */

    /** Wrapper class to parse the result object inside the response body. */
    public class ResponseResultWrapper{
        public String Type;
        public String pricingRecordId;
        public String ruleId;
    }/** END */
}