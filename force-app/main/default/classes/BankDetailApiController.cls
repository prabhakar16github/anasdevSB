@RestResource(urlMapping='/initiateleadConversion/*')
global class BankDetailApiController {
    
    public static String responseJson = '';
    public static List<String> failedResponseList = new List<String>();
    
    @HttpPost
    global static void getBankDetails(){
        String bank_uuid;
        String lead_uuid;
        Map<String, String> returnDetail = new Map<String, String>();
        
        try{
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            
            returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
            system.debug('returnDetail=='+returnDetail);
            
            bank_uuid = returnDetail.get('uuid');
            lead_uuid = returnDetail.get('bank_detailable_uuid');
            
            if(String.isNotBlank(bank_uuid) && String.isNotBlank(lead_uuid)){
                List<Bank_Account_Detail__c> eachBank = upsertBankAccount(bank_uuid, lead_uuid, returnDetail);
                if(eachBank != null && !eachBank.isEmpty()) {
                    upsert eachBank;
                    
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('status','success');
                    gen.writeStringField('response','success');
                    gen.writeEndObject();
                    
                    responseJson = gen.getAsString();
                    
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(responseJson);
                    RestContext.response.statusCode = 200;
                }
            }
            
            if(String.isBlank(bank_uuid)){
                failedResponseList.add('uuid is blank.');
            }
            
            if(String.isBlank(lead_uuid)){
                failedResponseList.add('bank_detailable_uuid is blank.');
            }
            
            if(!failedResponseList.isEmpty())	failureResponse('FAILED', failedResponseList, bank_uuid, returnDetail);
        }
        
        catch(exception e){
            failedResponseList.add(e.getMessage());
            failedResponseList.add(e.getStackTraceString());
            failureResponse('FAILED', failedResponseList, bank_uuid, returnDetail);
        }
    }
    
    public static List<Bank_Account_Detail__c> upsertBankAccount(string uuid, string leadUUID, Map<String, String> returnJson){
        
        List<Lead> leadId = new List<Lead>();
        
        if(String.isNotBlank(leadUUID)){
            leadId = [Select Id, Name FROM Lead WHERE Identifier__c =: leadUUID Limit 1];
            
            if(leadId.size() == 0 || leadId.isEmpty()){
                failedResponseList.add('Merchant doesn\'t exist');
                failureResponse('FAILED', failedResponseList, uuid, returnJson);
                return null;
            }
        }
        
        List<Bank_Account_Detail__c> bankDetailList = new List<Bank_Account_Detail__c> ();
        
        bankDetailList = [SELECT Id, Name, Account_Holder_Name__c, Account_Number__c, Account_Type__c, Bank_Name__c,
                          IFSC_Code__c, Nodal_Code__c, Identifier__c, Lead__c, Lead__r.Identifier__c FROM Bank_Account_Detail__c
                          WHERE Identifier__c =: uuid Limit 1];
        
        if(bankDetailList.size()>0 && !bankDetailList.isEmpty() && String.isNotBlank(bankDetailList[0].Lead__r.Identifier__c) &&
           bankDetailList[0].Lead__r.Identifier__c != leadUUID){
               failedResponseList.add('Merchant doesn\'t match with Bank Details');
               failureResponse('FAILED', failedResponseList, uuid, returnJson);
               return null;
           }
        
        if(bankDetailList.size()>0 && !bankDetailList.isEmpty() && String.isNotBlank(bankDetailList[0].Lead__r.Identifier__c) && 
           bankDetailList[0].Lead__r.Identifier__c == leadUUID){
               for(Bank_Account_Detail__c bankDetail : bankDetailList){
                   bankDetail.Account_Holder_Name__c = returnJson.get('holder_name');
                   bankDetail.Account_Number__c = returnJson.get('bank_account_number');
                   bankDetail.Account_Type__c = returnJson.get('type');
                   bankDetail.Bank_Name__c = returnJson.get('name');
                   bankDetail.IFSC_Code__c = returnJson.get('ifsc_code');
                   bankDetail.Nodal_Code__c = returnJson.get('nodal_code');
                   bankDetail.Nodal_Status__c = returnJson.get('nodal_status');
                   bankDetail.Penny_Deposit_Method__c = returnJson.get('penny_deposit_method');
                   bankDetail.Penny_Attempt_Count__c = returnJson.get('penny_deposit_attempt_count') == null ? null : decimal.valueOf(returnJson.get('penny_deposit_attempt_count'));
                   bankDetail.Penny_Deposit_Status__c = returnJson.get('penny_deposit_status');
                   bankDetail.Verification_Status__c = returnJson.get('verification_status');
                   bankDetail.Active__c = returnJson.get('active') == 'true' ?  true : false;
               }
           }
        
        else{
            Bank_Account_Detail__c bankDetail = new Bank_Account_Detail__c();
            bankDetail.Identifier__c = uuid;
            bankDetail.Lead__c = leadId[0].id;
            bankDetail.Account_Holder_Name__c = returnJson.get('holder_name');
            bankDetail.Account_Number__c = returnJson.get('bank_account_number');
            bankDetail.Account_Type__c = returnJson.get('type');
            bankDetail.Bank_Name__c = returnJson.get('name');
            bankDetail.IFSC_Code__c = returnJson.get('ifsc_code');
            bankDetail.Nodal_Code__c = returnJson.get('nodal_code');
            bankDetail.Nodal_Status__c = returnJson.get('nodal_status');
            bankDetail.Penny_Deposit_Method__c = returnJson.get('penny_deposit_method');
            bankDetail.Penny_Attempt_Count__c = returnJson.get('penny_deposit_attempt_count') == null ? null : decimal.valueOf(returnJson.get('penny_deposit_attempt_count'));
            bankDetail.Penny_Deposit_Status__c = returnJson.get('penny_deposit_status');
            bankDetail.Verification_Status__c = returnJson.get('verification_status');
            bankDetail.Active__c = returnJson.get('active') == 'true' ?  true : false;
            bankDetailList.add(bankDetail);
        }
        if(!bankDetailList.isEmpty()){
            return bankDetailList;
        }
        return null;
    }
    
    public static void failureResponse(String strStatus, List<String> strMessage, String bnkUUID, Map<String, String> requestJson){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Process__c', 'Bank Detail API');
 		messages.put('Message__c', String.valueOf(strMessage));        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(bnkUUID)) messages.put('Identifier__c', bnkUUID);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);
        SystemUtility.errorHandler(null, messages);
        
        /*Error_Details__c errorDetailsObj = new Error_Details__c();
        errorDetailsObj.Severity__c = 'High';
        errorDetailsObj.Message__c = String.valueOf(strMessage);
        errorDetailsObj.Process__c = 'Bank Detail API';
        if(!requestJson.isEmpty())	errorDetailsObj.Request__c = JSON.serialize(requestJson);
        if(String.isNotBlank(bnkUUID))	errorDetailsObj.Identifier__c = bnkUUID;
        if(!userId.isEmpty() && userId.size()>0)	errorDetailsObj.OwnerId = userId[0].Id;
        insert errorDetailsObj;*/
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('status',strStatus);
        gen.writeFieldName('responses');
        gen.writeStartArray();
        for (integer i = 0; i < strMessage.size(); i++){
            gen.writeString(strMessage[i]);
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        responseJson = gen.getAsString();
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(responseJson);
        RestContext.response.statusCode = 404;
    }
}