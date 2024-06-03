public class WrapperBankAccountDetail {

    @AuraEnabled
    public Bank_Account_Detail__c bankDetails {get; Set;}
    
    @AuraEnabled
    public List<String> lstError {get; Set;}
    
    @AuraEnabled
    public Boolean isBankVerificationStatus {get; Set;}
    
    @AuraEnabled
    public Boolean isLeadNotExist {get; Set;}
}