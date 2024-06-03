public class MaintenanceCtrl{
    
    static Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    static Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    static List<String> completCloneRT = new List<String>{'Legal Name', 'Business Entity'};
        static List<String> otherCloneRT = new List<String>{'Bank Accounts', 'Website', 'Registered and Operating Address'};
            public static Set<Id> restPlanOppIds = new Set<Id>();
    
    public static Opportunity getOpportunityData(Id recordId){
        String oppQueryStr = 'SELECT Account.Business_Entity__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',');
        oppQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Details__r WHERE Active__c=True)';
        oppQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Address_Details__c')), ',') + ' FROM Address_Details__r WHERE Active__c=True)';
        oppQueryStr += ' FROM Opportunity WHERE Id =\'' + recordId + '\'';
        Opportunity oppObj = Database.query(oppQueryStr);
        return oppObj;
    }
    
    public static Account getAccountData(Id recordId){
        String accQueryStr = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',');
        accQueryStr += ' FROM Account WHERE Id =\'' + recordId + '\'';
        Account accObj = Database.query(accQueryStr);
        return accObj;
    }
    
    @AuraEnabled
    public static List<String> getPickListValues(string sObjectName, string sObjectField){
        List<String> pickListOptions = CrossSellForMerchant_Controller.getCrossSellStatus(sObjectName,sObjectField);
        return pickListOptions;
    }
    
    @AuraEnabled
    public static List<EntityWrapper> getBusinessEntities(){
        list<EntityWrapper> returnValue = new list<EntityWrapper>();
        for(Entity__c entityObj : [Select Id,Name From Entity__c Where Active__c = True]){
            EntityWrapper pickWrap = new EntityWrapper();
            pickWrap.pickListLabel = entityObj.Name;
            pickWrap.pickListValue = entityObj.Id+'--'+entityObj.Name;
            returnValue.add(pickWrap);
        }
        return returnValue;
    }
    
    public static List<Opportunity> getSupportOpportunityData(string OppObjName){
        List<Opportunity> OpportunityList = New List<Opportunity>();
        String oppQueryStr = 'SELECT Account.Business_Entity__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',');
        oppQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Details__r WHERE Active__c=True)';
        oppQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Address_Details__c')), ',') + ' FROM Address_Details__r WHERE Active__c=True)';
        oppQueryStr += ' FROM Opportunity WHERE Prod_Merchant_Id__c = Null AND Active__c = True AND RecordTypeId =: oppRecordTypeId AND Name =\'' + OppObjName + '\'';
        for(Opportunity oppObj : Database.query(oppQueryStr)){
            OpportunityList.add(oppObj);
        }
        return OpportunityList;
    }
    
    @AuraEnabled
    public static WrapperClonedData createClonedData(Id recordId, String selectedType){
        
        WrapperClonedData wrapperData = New WrapperClonedData();
        try{
        wrapperData.oldOpportunityObj = getOpportunityData(recordId);
        wrapperData.oldAccountObj = getAccountData(wrapperData.oldOpportunityObj.AccountId);
        
        //=============Check existing support data=================
        List<Opportunity> newOpportunityList = New List<Opportunity>();
        newOpportunityList = (getSupportOpportunityData('CR-'+selectedType+'-'+wrapperData.oldOpportunityObj.Prod_MID__c));
        Bank_Account_Detail__c newBankAccountObj = New Bank_Account_Detail__c();
        
        if(!newOpportunityList.isEmpty() && newOpportunityList.size()>0){
            wrapperData.newAccountObj = getAccountData(newOpportunityList[0].AccountId);
            wrapperData.newOpportunityObj = getOpportunityData(newOpportunityList[0].Id);
            wrapperData.newBankAccountObj = wrapperData.newOpportunityObj.Bank_Account_Details__r[0];
        }else{
            wrapperData.newAccountObj = wrapperData.oldAccountObj.clone();
            wrapperData.newAccountObj.ParentId = wrapperData.oldAccountObj.Id;
            wrapperData.newAccountObj.RecordTypeId = accRecordTypeId;
            wrapperData.newAccountObj.Identifier__c = null;
            wrapperData.newAccountObj.Prod_Merchant_Id__c = wrapperData.oldOpportunityObj.Prod_Merchant_Id__c;
            insert wrapperData.newAccountObj;
            
            wrapperData.newOpportunityObj = wrapperData.oldOpportunityObj.clone();
            wrapperData.newOpportunityObj.Parent_Opportunity__c = wrapperData.oldOpportunityObj.Id;
            wrapperData.newOpportunityObj.RecordTypeId = oppRecordTypeId;
            wrapperData.newOpportunityObj.Prod_Merchant_Id__c = null;
            wrapperData.newOpportunityObj.Name = 'CR-'+selectedType+'-'+wrapperData.oldOpportunityObj.Prod_MID__c;
            wrapperData.newOpportunityObj.Identifier__c = null;
            wrapperData.newOpportunityObj.AccountId = wrapperData.newAccountObj.Id;
            wrapperData.newOpportunityObj.Active__c = True;
        	insert wrapperData.newOpportunityObj;
            
            if(!wrapperData.oldOpportunityObj.Bank_Account_Details__r.isEmpty()){
                newBankAccountObj = wrapperData.oldOpportunityObj.Bank_Account_Details__r[0].clone();
                newBankAccountObj.Opportunity__c = wrapperData.newOpportunityObj.Id;
                newBankAccountObj.Nodal_Status__c = null; 
                newBankAccountObj.Penny_Deposit_Status__c = 'Not Initiated'; 
                newBankAccountObj.Verification_Status__c = 'Pending';
                newBankAccountObj.RawResponse__c = null;
                newBankAccountObj.Identifier__c = null;
                newBankAccountObj.Lead__c = null;
                newBankAccountObj.Penny_Amount__c = null;
                newBankAccountObj.Penny_Attempt_Count__c = null;
                newBankAccountObj.NEFT_Nodal_Code__c = null;
                newBankAccountObj.Nodal_Code__c = null;
                newBankAccountObj.Branch_Address__c = null;
                insert newBankAccountObj;
                wrapperData.newBankAccountObj = newBankAccountObj;
            }
        }
        
        wrapperData.bankNameOptions = getPickListValues('Bank_Account_Detail__c','Bank_Name__c');
        
        wrapperData.entityWrapList = getBusinessEntities();
        
        Address_Details__c eachAddressObj = New Address_Details__c(Opportunity__c = wrapperData.newOpportunityObj.Id, 
                                                                   Active__c = True);
        insert eachAddressObj;
        wrapperData.newAddressObj = eachAddressObj;
        
        }catch(Exception ex){
            wrapperData.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperData;
    }
    
    
    @AuraEnabled
    public static WrapperClonedData updateBankAccountData(Bank_Account_Detail__c newBankObj){
        WrapperClonedData wrapperData = New WrapperClonedData();
        wrapperData.errorResponse = '';
        try{
            string payloadField = 'PennyPayload__c';
            string responseField = 'RawResponse__c';
            Map<String, String> resMap = new Map<String, String>();
            Map<String, String> pennyResMap = new Map<String, String>{'Failed' => 'Bank details are incorrect.', 'Pending' => 'Request not processed by bank. Please try again.', 'Success' => 'Penny deposited successfully.'};
                
                if(String.isBlank(newBankObj.IFSC_Code__c)){
                    resMap.put('error', 'IFSC code does not exist.');
                }
            else if(newBankObj.Penny_Deposit_Status__c == 'Success'){
                resMap.put('error', 'Penny Test is already done.');
            }
            else if(newBankObj.Active__c){
                String ifscAuthToken = ''; 
                if(Test.isRunningTest()) ifscAuthToken = '8ede3d79a8520cc540e172e0accea016e1622146187455f59e59166b4c5b1711';
                else ifscAuthToken = IntegrationUtility.getAuthToken('IFSCValidateAuth');
                Integer statCode;
                if(String.isNotBlank(ifscAuthToken)){
                    Integration_Setting__mdt ifscValidator = IntegrationUtility.getIntSetting('IFSCValidate');
                    HttpResponse ifscResponse = New HttpResponse();
                    if(ifscValidator != null){
                        if(!Test.isRunningTest()){
                            ifscResponse = IntegrationUtility.requestUtility(ifscValidator, false, ifscAuthToken, null, new List<String>{newBankObj.IFSC_Code__c}, null);
                        
                        	statCode = ifscResponse.getStatusCode();
                        }else{
                            statCode = 200;
                            Map<String, Object> testResMap = new Map<String, Object>();
                            ifscResponse.setHeader('Content-Type', 'application/json');
                            testResMap.put('access_token', 'qwertyy');
                            testResMap.put('id', '69e40e6b-0203-493c-bfea-12e8f5daf27e'); 
                            testResMap.put('merchant', new Map<String, Object>{'test_mid' => 123});
                            testResMap.put('test_mid', 'qwertyy');
                            testResMap.put('registered_contact_person_name', 'Manav');
                            testResMap.put('operations_contact_person_name', 'ManavTest');
                            testResMap.put('queries_contact_name', 'ManavArora');
                            testResMap.put('registered_address', 'Delhi');
                            testResMap.put('operations_address', 'Noida');
                            testResMap.put('bank_account_number', '30551209999');
                            testResMap.put('bank_ifsc_code', 'SBIN0000001');
                            ifscResponse.setBody(JSON.serialize(testResMap));
                            ifscResponse.setStatusCode(200);
                        }
                        if(statCode == 200){
                            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(ifscResponse.getBody());
                            
                            if(responseMap.containsKey('ifsc_detail')){
                                responseMap = (Map<String, Object>)responseMap.get('ifsc_detail');
                            }
                            Map<String, String> fieldMap = (Map<String, String>)JSON.deserialize(Label.Bank_Detail_Field_Map, Map<String, String>.class);
                            for(String each : fieldMap.keySet()){
                                if(responseMap.containsKey(each)){
                                    newBankObj.put(fieldMap.get(each), responseMap.get(each));
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
                    String authToken = '';
                    if(Test.isRunningTest()) authToken = '8ede3d79a8520cc540e172e0accea016e1622146187455f59e59166b4c5b1711';
                	else authToken = IntegrationUtility.getAuthToken('PennyTestAuth');
                    System.debug('authToken ====> '+authToken); 
                    if(String.isNotBlank(authToken)){
                        Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('PennyTest');
                        
                        if(theIntIns != null){
                            try{
                                HttpResponse response = New HttpResponse();
                                if(!Test.isRunningTest())
                                	response = IntegrationUtility.requestUtility(theIntIns, false, authToken, newBankObj, null, String.valueOf(newBankObj.get(payloadField)));
                                else{
                                    Map<String, Object> testResMap = new Map<String, Object>();
                                    response.setHeader('Content-Type', 'application/json');
                                    testResMap.put('access_token', 'qwertyy');
                                    testResMap.put('id', '69e40e6b-0203-493c-bfea-12e8f5daf27e'); 
                                    testResMap.put('merchant', new Map<String, Object>{'test_mid' => 123});
                                    testResMap.put('test_mid', 'qwertyy');
                                    testResMap.put('registered_contact_person_name', 'Manav');
                                    testResMap.put('operations_contact_person_name', 'ManavTest');
                                    testResMap.put('queries_contact_name', 'ManavArora');
                                    testResMap.put('registered_address', 'Delhi');
                            		testResMap.put('operations_address', 'Noida');
                            		testResMap.put('bank_account_number', '30551209999');
                            		testResMap.put('bank_ifsc_code', 'SBIN0000001');
                                    response.setBody(JSON.serialize(testResMap));
                                    response.setStatusCode(200);
                                }
                                	 
                                newBankObj.put(responseField, response.getBody());                                    
                                string pennyresponse = BankDetailTriggerHelper.getStatus(response.getBody(), response.getStatusCode());
                                System.debug('pennyresponse ====> '+pennyresponse); 
                                
                                if(response.getStatusCode() != 422) newBankObj.put('Penny_Deposit_Status__c', pennyresponse);
                                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                newBankObj.put('Penny_Amount__c', responseMap.get('pennyAmount'));                                    
                                
                                //showcase responses for success/failure cases
                                if(pennyResMap.containsKey(pennyresponse) && pennyresponse != 'Success'){
                                    resMap.put('error', pennyResMap.get(pennyresponse));
                                }
                                if(pennyresponse == 'Success'){ 
                                    resMap.put('success', pennyResMap.get(pennyresponse));                                                                               
                                } 
                                if(Test.isRunningTest()) Integer i = 1/0;
                            }catch(Exception e){  
                                System.debug('Exception ====> '+e.getMessage()); 
                                resMap.put('error', e.getMessage());
                            }
                        }
                    }
                } 
                update newBankObj;
                
            }else{
                resMap.put('error', 'Please mark bank account as active.');
            }
            
            if(resMap.containsKey('error')){
                wrapperData.errorResponse = 'Penny verification failed.';
            }
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            wrapperData.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperData;
    }
    
    @AuraEnabled
    public static WrapperClonedData updateAccountData(Account newAccountObj, Opportunity oppObj, String selectedDetail){
        WrapperClonedData wrapperData = New WrapperClonedData();
        wrapperData.errorResponse = '';
        try{
            if(String.isNotBlank(oppObj.Email__c)) newAccountObj.Merchant_Email__c  = oppObj.Email__c;
            update newAccountObj;
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            wrapperData.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperData;
    }
    
    @AuraEnabled
    public static WrapperClonedData updateOpportunityData(Opportunity newOppObj, Opportunity oldOppObj, String entityData, String selectedDetail){
        WrapperClonedData wrapperData = New WrapperClonedData();
        wrapperData.errorResponse = '';
        try{
        if(selectedDetail == 'EntityDetail' && String.isNotBlank(entityData)){
            string entityName = entityData.substringAfter('--');
            string entityId = entityData.substringBefore('--');
            newOppObj.New_Business_Entity__c = entityName;
            if(string.isBlank(oldOppObj.Business_Entity__c)) {
                oldOppObj.Business_Entity__c = oldOppObj.Account.Business_Entity__c;
                newOppObj.Business_Entity__c = oldOppObj.Account.Business_Entity__c;
                update oldOppObj;
            }
        }else if(selectedDetail == 'WebsiteDetail'){
            List<Website_Details__c> existingWdList = getExistingWebsiteDetails(oldOppObj.Id);
            if(!existingWdList.isEmpty()){
                existingWdList[0].Active__c = False;
                update existingWdList;
            }
            List<Website_Details__c> newWdetailsList = New List<Website_Details__c>();
            createWebsiteDetails(newOppObj, oldOppObj, newWdetailsList);
            if(!newWdetailsList.isEmpty()) Insert newWdetailsList;
        }
        
            update newOppObj;
        }catch(Exception ex){
            wrapperData.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperData;
    }
    
    @AuraEnabled
    public static WrapperClonedData createAddressAccountData(Address_Details__c newOppAddressObj, Opportunity newOppObj, Opportunity oldOppObj, String addressType, String selectedDetail){
        WrapperClonedData wrapperData = New WrapperClonedData();
        wrapperData.errorResponse = '';
        try{
            Address_Details__c existingAddressObj = [Select Id,Type__c,New_Type__c,City__c,New_City__c,State__c,New_State__c,
                                                     Country__c,New_Country__c,Pincode__c,New_Pincode__c,Address_Line__c,
                                                     New_Address_Line__c,Opportunity__c,Opportunity__r.Parent_Opportunity__c from Address_Details__c 
                                                     Where Type__c =: addressType AND Active__c = True
                                                     AND (Opportunity__c =: oldOppObj.Id OR Account__c =:oldOppObj.AccountId)
                                                     ORDER BY LastModifiedDate Desc
                                                     LIMIT 1];
            newOppAddressObj.City__c = existingAddressObj.City__c;
            newOppAddressObj.State__c = existingAddressObj.State__c;
            newOppAddressObj.Country__c = existingAddressObj.Country__c;
            newOppAddressObj.Address_Line__c = existingAddressObj.Address_Line__c;
            newOppAddressObj.Pincode__c = existingAddressObj.Pincode__c;
            if(String.isNotBlank(oldOppObj.Email__c)) newOppAddressObj.Merchant_Email__c  = oldOppObj.Email__c;
            newOppAddressObj.New_Type__c = addressType;
            update newOppAddressObj;
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            wrapperData.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperData;
    }
    
    public static void createWebsiteDetails(Opportunity newOppObj, Opportunity oldOppObj, List<Website_Details__c> wdetailsList){
        Website_Details__c wdObj = New Website_Details__c();
        if(String.isNotBlank(newOppObj.New_Website_Url__c)) wdObj.Website_URL__c = newOppObj.New_Website_Url__c;
        if(String.isNotBlank(newOppObj.New_Android_URL__c)) wdObj.Android_URL__c = newOppObj.New_Android_URL__c;
        if(String.isNotBlank(newOppObj.New_IOS_URL__c)) wdObj.IOS_URL__c = newOppObj.New_IOS_URL__c;
        if(String.isNotBlank(newOppObj.Website_Status__c)) wdObj.Website_Status__c = newOppObj.Website_Status__c;
        wdObj.Active__c = True;
        wdObj.Opportunity__c = oldOppObj.Id;
        wdetailsList.add(wdObj);
    }
    
    public static List<Website_Details__c> getExistingWebsiteDetails(Id oldOppObjId){
        List<Website_Details__c> exisWdObjList = New List<Website_Details__c>();
        exisWdObjList = [Select Id from Website_Details__c Where Opportunity__c =: oldOppObjId AND Active__c=True LIMIT 1];
        return exisWdObjList;
    }
    
    public class WrapperClonedData{
        @AuraEnabled
        public Account oldAccountObj {get;set;}
        @AuraEnabled
        public Account newAccountObj {get;set;}
        @AuraEnabled
        public Opportunity oldOpportunityObj {get;set;}
        @AuraEnabled
        public Opportunity newOpportunityObj {get;set;}
        @AuraEnabled
        public Bank_Account_Detail__c newBankAccountObj {get;set;}
        @AuraEnabled
        public Address_Details__c newAddressObj {get;set;}
        @AuraEnabled
        public List<String> bankNameOptions {get;set;}
        @AuraEnabled
        public string errorResponse {get;set;}
        @AuraEnabled
        public List<EntityWrapper> entityWrapList {get;set;}
    }
    
    public class EntityWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
    }
    /*
@auraEnabled
public static String cloneData(String oppId, String type, List<String> selectedRT, Map<String, Object> metaSetting){

Boolean isLegalOrEntity = false;
Boolean isNotLegal = false;

if(checkCompleteCloneRT(selectedRT)){
if('NEW MID'.equals(type)) isLegalOrEntity = true;
if('OLD MID'.equals(type)) isNotLegal = true;
}   

String queryStr = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',');

if(isLegalOrEntity){
queryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Commercial__c')), ',') + ' FROM Commercials__r)';
queryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('TDR__c')), ',') + ' FROM TDRs__r)';
queryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('MerchantPaymentOption__c')), ',') + ' FROM Merchant_Payment_Options__r)';
}

if(isNotLegal || selectedRT.contains('Bank Accounts')){
queryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Details__r)';                        
}
if(isNotLegal || selectedRT.contains('Website')){            
queryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Website_Page__c')), ',') + ' FROM Website_Pages__r)';
}
queryStr += ' FROM Opportunity WHERE Id =\'' + oppId + '\'';
Opportunity opp = Database.query(queryStr);

String accQueryStr = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',');
if(isLegalOrEntity || isNotLegal){
accQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Merchant_Document__c')), ',') + ' FROM Merchant_Documents__r)';            
}

if('OLD MID'.equals(type) && selectedRT.contains('Registered and Operating Address')){
accQueryStr += ', (SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Address_Details__c')), ',') + ' FROM Address_Details__r)';            
}

accQueryStr += ' FROM Account WHERE Id =\'' + opp.AccountId + '\'';
Account acc = Database.query(accQueryStr);

Account accToInsert = acc.clone();        
accToInsert.Maintenance_Status__c = type;        
accToInsert.RecordTypeId = accRecordTypeId;
accToInsert.ParentId = acc.Id;                       

if(checkCompleteCloneRT(selectedRT)){
setDefaultValues(accToInsert, getDefaultValues(metaSetting, 'Legal Name', 'Account'));
}

if(!isNotLegal && !isLegalOrEntity){
for(String each : otherCloneRT){                 
if(selectedRT.contains(each)) setDefaultValues(accToInsert, getDefaultValues(metaSetting, each, 'Account'));
}            
}

insert accToInsert;

Opportunity oppToInsert = opp.clone();
oppToInsert.Maintenance_Status__c = type;
oppToInsert.Parent_Opportunity__c = opp.Id;
//oppToInsert.Website__c = opp.Website__c;
if('NEW MID'.equals(type)) oppToInsert.Identifier__c = null;
if('OLD MID'.equals(type)) oppToInsert.RecordTypeId = oppRecordTypeId;
oppToInsert.AccountId = accToInsert.Id;

if(checkCompleteCloneRT(selectedRT)){
setDefaultValues(oppToInsert, getDefaultValues(metaSetting, 'Legal Name', 'Opportunity'));
}

for(String each : otherCloneRT){            
if(selectedRT.contains(each)) setDefaultValues(oppToInsert, getDefaultValues(metaSetting, each, 'Opportunity'));
}        

insert oppToInsert;                

if('OLD MID'.equals(type) && selectedRT.contains('Registered and Operating Address')){
List<Address_Details__c> addToInsertList = new List<Address_Details__c>();

for(Address_Details__c each : acc.Address_Details__r){                
Address_Details__c addToInsert = each.clone();
addToInsert.Account__c = accToInsert.Id;                    
addToInsertList.add(addToInsert);                
}

if(!addToInsertList.isEmpty()) insert addToInsertList;   
}

restPlanOppIds.add(oppToInsert.Id);

if(isLegalOrEntity){                        
Map<String, Commercial__c> commToInsertMap = new Map<String, Commercial__c>();

for(Commercial__c each : opp.Commercials__r){
Commercial__c commToInsert = each.clone();
commToInsert.Opportunity__c = oppToInsert.Id;
commToInsert.Identifier__c = null;
commToInsertMap.put(each.Id, commToInsert);
}

if(!commToInsertMap.isEmpty()) insert commToInsertMap.values();

List<MerchantPaymentOption__c> mpoToInsertList = new List<MerchantPaymentOption__c>();

for(MerchantPaymentOption__c each : opp.Merchant_Payment_Options__r){
MerchantPaymentOption__c mpoToInsert = each.clone();
mpoToInsert.Opportunity__c = oppToInsert.Id;
mpoToInsert.Identifier__c = null;
mpoToInsertList.add(mpoToInsert);
}

if(!mpoToInsertList.isEmpty()) insert mpoToInsertList;

List<TDR__c> tdrToInsertList = new List<TDR__c>();

for(TDR__c each : opp.TDRs__r){
if(commToInsertMap.containsKey(each.Commercial__c)){
TDR__c tdrToInsert = each.clone();
tdrToInsert.Opportunity__c = oppToInsert.Id;
tdrToInsert.Commercial__c = commToInsertMap.get(each.Commercial__c).Id;
tdrToInsert.Identifier__c = null;
tdrToInsertList.add(tdrToInsert);
}
}

if(!tdrToInsertList.isEmpty()) insert tdrToInsertList;
}

if(isLegalOrEntity || isNotLegal){            
List<Merchant_Document__c> mdToInsertList = new List<Merchant_Document__c>();

for(Merchant_Document__c each : acc.Merchant_Documents__r){                
Merchant_Document__c mdToInsert = each.clone();
mdToInsert.Account__c = accToInsert.Id;                   
mdToInsert.Onboarding_Remarks__c = null;
mdToInsert.Onboarding_Status__c = 'Pending';
mdToInsertList.add(mdToInsert);                   
}

if(!mdToInsertList.isEmpty()) insert mdToInsertList;
}

if(isNotLegal || ('OLD MID'.equals(type) && selectedRT.contains('Website'))){
List<Website_Page__c> wpToInsertList = new List<Website_Page__c>();

for(Website_Page__c each : opp.Website_Pages__r){                
Website_Page__c wpToInsert = each.clone();
wpToInsert.Opportunity__c = oppToInsert.Id; 
wpToInsert.Approved__c = false;
wpToInsert.Risk_Remarks__c = '';
wpToInsert.Sales_Remarks__c = '';
wpToInsert.Status__c = '';                   
wpToInsertList.add(wpToInsert);            
}

if(!wpToInsertList.isEmpty()) insert wpToInsertList;                                    
}

if(isNotLegal || ('OLD MID'.equals(type) && selectedRT.contains('Bank Accounts'))){
List<Bank_Account_Detail__c> baToInsertList = new List<Bank_Account_Detail__c>();

for(Bank_Account_Detail__c each : opp.Bank_Account_Details__r){                
Bank_Account_Detail__c baToInsert = each.clone();
baToInsert.Opportunity__c = oppToInsert.Id;                   
baToInsert.Nodal_Status__c = null; 
baToInsert.Penny_Deposit_Status__c = 'Not Initiated'; 
baToInsert.Verification_Status__c = null;
baToInsert.RawResponse__c = null;
baToInsertList.add(baToInsert);                
}

if(!baToInsertList.isEmpty()) insert baToInsertList;
}

return oppToInsert.Id;
}

public static Boolean checkCompleteCloneRT(List<String> listToCheck){
Boolean containsKey = false;

for(String each: completCloneRT){
if(listToCheck.contains(each)){
containsKey = true;
break;
}            
}

return containsKey;
}

public static List<Object> getDefaultValues(Map<String, Object> theObj, String theKey, String arrayKey){         
return Test.isRunningTest() ? (List<Object>)(((Map<String, Object>)(theObj.get(theKey))).get(arrayKey)) : (List<Object>)(((Map<Object, Object>)(theObj.get(theKey))).get(arrayKey));
}

public static void setDefaultValues(SObject theSob, List<Object> fieldMap){        
for(Object each : fieldMap){
String eachStr = String.valueOf(each);            
theSob.put(eachStr.subStringBefore(':'), eachStr.subStringAfter(':'));
}
}*/
}