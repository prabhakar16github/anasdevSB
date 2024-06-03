public class BankDetailTriggerHelper{
    @auraEnabled
    public static String pennyTestUtility(String queryStr, String payloadField, String responseField){
        Map<String, String> resMap = new Map<String, String>();        
        List<Bank_Account_Detail__c> recList = Database.query(queryStr);                
        
        if(!recList.isEmpty()){
            Bank_Account_Detail__c newRec = recList[0];
            
            if(String.isBlank(newRec.IFSC_Code__c)){
                resMap.put('error', 'IFSC code does not exist.');
            }
            else if(newRec.Penny_Deposit_Status__c == 'Success'){
                resMap.put('error', 'Penny Test is already done.');
            }
            else if(newRec.Active__c){
                String ifscAuthToken = IntegrationUtility.getAuthToken('IFSCValidateAuth');   
                system.debug('ifscAuthToken ###=> '+ifscAuthToken);
                Integer statCode;
                if(String.isNotBlank(ifscAuthToken)){
                    Integration_Setting__mdt ifscValidator = IntegrationUtility.getIntSetting('IFSCValidate');
                    system.debug('ifscValidator @@@@@==> '+ifscValidator);
                    if(ifscValidator != null){
                        HttpResponse ifscResponse = IntegrationUtility.requestUtility(ifscValidator, false, ifscAuthToken, null, new List<String>{newRec.IFSC_Code__c}, null);
                        system.debug('IFSC Valodatort response ifscResponse @@@@@==> '+ifscResponse);
                        statCode = ifscResponse.getStatusCode();
                        if(statCode == 200){
                            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(ifscResponse.getBody());
                            
                            if(responseMap.containsKey('ifsc_detail')){
                                responseMap = (Map<String, Object>)responseMap.get('ifsc_detail');
                            }
                            Map<String, String> fieldMap = (Map<String, String>)JSON.deserialize(Label.Bank_Detail_Field_Map, Map<String, String>.class);
                            for(String each : fieldMap.keySet()){
                                if(responseMap.containsKey(each)){
                                    newRec.put(fieldMap.get(each), responseMap.get(each));
                                }
                            }
                        }else{
                            resMap.put('error', (statCode == 404) ? 'IFSC code is not valid.' : ifscResponse.getBody());
                        }
                    }
                }
                System.debug('resMap 1 ====> '+resMap);
                if(statCode == 200){            
                    Boolean addressIssue = false;
                    
                    if(String.isNotBlank(newRec.Opportunity__c) && String.isNotBlank(newRec.Opportunity__r.AccountId)){                    
                        //if(!getAddressDetailsFromOpty(newRec.Opportunity__r.AccountId)) addressIssue = true;
                        addressIssue = false;
                    }else if(String.isNotBlank(newRec.Lead__c) && String.isNotBlank(newRec.Lead__r.Product__c) && !(newRec.Lead__r.ProductLabel__c == 'PayUnow' ||
                        (newRec.Lead__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(newRec.Lead__r.Integration_Type__c) || newRec.Lead__r.Integration_Type__c == 'Tools'))))
                    {
                        if(!getAddressDetailsFromLead(newRec.Lead__c)) addressIssue = true;
                    }
    
                    if(addressIssue){
                        resMap.put('warning', 'Please check if Registered and Operating address is created and is marked active.');
                    }else{
                        String authToken = IntegrationUtility.getAuthToken('PennyTestAuth');
                        System.debug('authToken ====> '+authToken); 
                        if(String.isNotBlank(authToken)){
                            Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('PennyTest');
                            
                            if(theIntIns != null){
                                try{
                                    HttpResponse response = IntegrationUtility.requestUtility(theIntIns, false, authToken, newRec, null, String.valueOf(newRec.get(payloadField)));
                                    String theResponse = response.getBody();  
                                    System.debug('theResponse ====> '+theResponse);

                                    //RawResponseClass RawResponseCls = (RawResponseClass) JSON.deserialize(theResponse, RawResponseClass.class); 
                                    //System.debug('RawResponseCls ====> '+RawResponseCls);
                                    
                                    newRec.put(responseField, theResponse);                                    
                                    string pennyresponse = getStatus(theResponse, response.getStatusCode());
                                    System.debug('pennyresponse ====> '+pennyresponse); 
                                    
                                    if(response.getStatusCode() != 422) newRec.put('Penny_Deposit_Status__c', pennyresponse);
                                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(theResponse);
                                    newRec.put('Penny_Amount__c', responseMap.get('pennyAmount'));                                    
                                    if(response.getStatusCode() == 422){
                                        newRec.Penny_Deposit_Method__c = 'NEFT';
                                        newRec.Penny_Deposit_Status__c = 'Not Initiated';
                                    }
                                    System.debug('newRec ====> '+newRec); 
                                    update newRec; 
                                    
                                    //showcase responses for success/failure cases
                                    if(pennyResMap.containsKey(pennyresponse) && pennyresponse != 'Success'){
                                        resMap.put('error', pennyResMap.get(pennyresponse));
                                    }
                                    if(pennyresponse == 'Success'){ 
                                        resMap.put('success', pennyResMap.get(pennyresponse));                                                                               
                                    }else if(response.getStatusCode() == 422){
                                        //resMap.put('error', RawResponseCls.message);
                                        String responseMessage = (String) responseMap.get('message');
                                        if(String.isNotBlank(responseMessage)) resMap.put('error', responseMessage);
                                    }                                    
                                }catch(Exception e){  
                                    System.debug('Exception ====> '+e.getMessage()); 
                                    resMap.put('error', e.getMessage());
                                }
                            }
                        }
                    } 
                }                   
            }else{
                resMap.put('error', 'Please mark bank account as active.');
            }
        }
        System.debug('resMap ====> '+resMap);
        return JSON.serialize(resMap);
    }
    
    static Map<Integer, String> resParserMap = new Map<Integer, String>{200 => 'Success', 422 => 'errorData,impsErrorCode:Pending;Failed'};
    static Map<String, String> pennyResMap = new Map<String, String>{'Failed' => 'Bank details are incorrect.', 'Pending' => 'Request not processed by bank. Please try again.', 'Success' => 'Penny deposited successfully.'};
    
    public static String getStatus(String resStr, Integer theStatusCode){
        String responsePath = '';
        if(resParserMap.containsKey(theStatusCode)){
            responsePath = resParserMap.get(theStatusCode);
            if(String.isEmpty(responsePath)){
                return 'Pending';
            }
        }
        
        if(String.isNotBlank(responsePath) && responsePath.contains(':')){        
            Map<String, Object> theDataToProcess = (Map<String, Object>)JSON.deserializeUntyped(resStr);
            List<String> thePath = responsePath.subStringBefore(':').split(',');
            Integer i = 1;
            
            for(String each : thePath){
                if(theDataToProcess.containsKey(each)){
                    Object theTempData = theDataToProcess.get(each);
                    if(i < thePath.size()){
                        if(theDataToProcess.get(each) != null){
                            theDataToProcess = (Map<String, Object>)theTempData;
                        }
                    }else{
                        return (theTempData == null) ? responsePath.subStringAfter(':').subStringBefore(';') : responsePath.subStringAfter(':').subStringAfter(';');                       
                    }
                }
                i++;
            }
        }else{
            return responsePath;
        }        
        return null;    
    }      
    
    public static Boolean getAddressDetailsFromLead(Id leadId){
        Lead leadObj = [SELECT Id, (SELECT Id, Type__c FROM Address_Details__r WHERE (Type__c =: 'Registered' OR Type__c =: 'Operating') AND Active__c =: true) FROM Lead WHERE Id =: leadId];
        Boolean isRegistered = false;
        Boolean isOperating = false;
        Boolean bothExist = false;
        
        if(!leadObj.Address_Details__r.isEmpty()){
            for(Address_Details__c eachAddDetails : leadObj.Address_Details__r){
                if(eachAddDetails.Type__c == 'Registered'){
                    isRegistered = true;
                }else if(eachAddDetails.Type__c == 'Operating'){
                    isOperating = true;
                }                
                if(isRegistered && isOperating){
                    bothExist = true;
                    break;
                }                 
            }
            return bothExist;
        }
        return false; 
    }
    
    /*public class RawResponseClass {        
        public Long timestamp;
        public Integer status;
        public String error;
        //public String exception;
        public String message;
        public String path;
        public String errorCode;
        public ErrorData errorData;
        
        
    }
    public class ErrorData {
        public String yesBankStatus;
        public String yesBankResponse;
        public Object utrNumber;
        public Object utrStatus;
        public String requestUUID;
        public Object impsErrorCode;
        public String pennyAmount;
    }*/
}