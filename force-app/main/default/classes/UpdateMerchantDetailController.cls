public class UpdateMerchantDetailController {
    
    @AuraEnabled
    public static WrapperData getMerchantDetails(Id recordId){
        WrapperData wrapperObj = New WrapperData();
        try{
            wrapperObj.opportunityObj = getOpportunityData(recordId);
            wrapperObj.accountObj = getAccountData(wrapperObj.opportunityObj.AccountId);
            wrapperObj.entityWrapList = getBusinessEntities();
            wrapperObj.addressOptions = getPickListValues('Address_Details__c', 'Type__c');
            wrapperObj.userObj = [Select Id,Is_Website_Update_Allow__c,Super_User__c,Profile.Name from User Where Id =: UserInfo.getUserId()];
        }catch(Exception ex){
            wrapperObj.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperObj;
    }
    
    public static Opportunity getOpportunityData(Id recordId){
        String oppQueryStr = 'SELECT Account.Business_Entity__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',');
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
    
    @AuraEnabled
    public static WrapperData updateMerchantData(string selectedType, string wrapperStr, string entityId, String addressType){
        WrapperData wrapperObj = New WrapperData();
        try{
            if(String.isNotBlank(wrapperStr)){
                wrapperObj = (WrapperData)JSON.deserialize(wrapperStr, WrapperData.class);
                List<Website_Details__c> websiteDetailList = New List<Website_Details__c>();
                List<Address_Details__c> addressDetailList = New List<Address_Details__c>();
                if(selectedType == 'WebsiteDetail'){
                    
                    websiteDetailList.add(WebsiteStatusMaintanenceController_Onb.createWebsiteDetails(wrapperObj.opportunityObj));
                    websiteDetailList[0].Website_Status__c = 'Pending';
                    websiteDetailList[0].Is_Website_Live__c = 'active';
                    insert websiteDetailList;
                }
                if(selectedType == 'EntityDetail'){
                    wrapperObj.opportunityObj.Business_Entity__c = entityId.subStringBefore('--');
                    update wrapperObj.opportunityObj;
                }
                
                if(selectedType == 'AddressDetail'){
                    addressDetailList = [Select Id,Active__c from Address_Details__c Where Active__c = True AND Opportunity__c =: wrapperObj.opportunityObj.Id AND Type__c =: addressType];
                    if(!addressDetailList.isEmpty()){
                        addressDetailList[0].Active__c = False;
                        update addressDetailList;
                    }
                    Address_Details__c addressObj = New Address_Details__c();
                    addressObj.City__c = wrapperObj.addressObj.City__c;
                    addressObj.State__c = wrapperObj.addressObj.State__c;
                    addressObj.Country__c = wrapperObj.addressObj.Country__c;
                    addressObj.Address_Line__c = wrapperObj.addressObj.Address_Line__c;
                    addressObj.Pincode__c = wrapperObj.addressObj.Pincode__c;
                    addressObj.Active__c = True;
                    addressObj.Type__c = addressType;
                    addressObj.Opportunity__c = wrapperObj.opportunityObj.Id;
                    addressObj.Account__c = wrapperObj.opportunityObj.AccountId;
                    insert addressObj;
                }
            }
        }catch(Exception ex){
            wrapperObj.errorResponse = ex.getMessage() +' at Line '+string.valueOf(ex.getLineNumber());
        }
        return wrapperObj;
    }
    
    public class WrapperData{
        @AuraEnabled
        public Account accountObj {get;set;}
        @AuraEnabled
        public Opportunity opportunityObj {get;set;}
        @AuraEnabled
        public Address_Details__c addressObj {get;set;}
        @AuraEnabled
        public string errorResponse {get;set;}
        @AuraEnabled
        public List<EntityWrapper> entityWrapList {get;set;}
        @AuraEnabled
        public List<String> addressOptions {get;set;}
        @AuraEnabled
        public User userObj {get;set;}
    }
    
    public class EntityWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
    }
}