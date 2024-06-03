public class WrapperDocument {
    /** Added for V-KYC */
    @AuraEnabled
    public Video_KYC__c vkycObj = new Video_KYC__c();
    /** */
    @AuraEnabled
    public Boolean showStatusError {get; Set;}
    
	@AuraEnabled
    public List<WrapperContract> lstWrapperContract {get; Set;}
    
    @AuraEnabled
    public List<WrapperMerchantDocument> lstWrapperMerchantDocument {get; Set;}
    
    @AuraEnabled
    public Boolean isContractExist {get; Set;}
    
    @AuraEnabled
    public Boolean isMerchantDocExist {get; Set;}
    
    @AuraEnabled
    public Account accountObj {get; Set;}
    
    @AuraEnabled
    public Boolean isEditAllow {get; Set;}
    
    @AuraEnabled
    public Boolean isAllDocNotApproved {get; Set;}
    
    @AuraEnabled
    public User userObj {get; Set;}
    
    @AuraEnabled
    public Boolean isInApprovalProcess {get; Set;}
    
    @AuraEnabled
    public Opportunity optyObj {get; Set;}
    
    @AuraEnabled
    public Address_Details__c regdAddObj {get; Set;}
    
    @AuraEnabled
    public Address_Details__c operatingAddObj {get; Set;}
    
    @AuraEnabled
    public Bank_Account_Detail__c bankAcntObj {get; Set;}
    
    @AuraEnabled
    public String EStampNumber {get; Set;}
    
    @AuraEnabled
    public Boolean isPayoutEditAllow {get; Set;}
	
	@AuraEnabled
	public List<WrapperContract> lstWrapperPayoutContract {get; Set;}
    
    @AuraEnabled
    public List<Merchant_Auto_Approval_Details__c> merchantAADetailList {get; Set;}
    
}