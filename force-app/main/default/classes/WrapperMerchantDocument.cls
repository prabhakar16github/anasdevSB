public with sharing class WrapperMerchantDocument {

	@AuraEnabled
    public Merchant_Document__c merchantDocumentObj {get; Set;}
    
    @AuraEnabled
    public List<string> lstSalesReceivedStatus {get; Set;}
    
    @AuraEnabled
    public List<string> lstOnboardingStatus {get; Set;}
    
    @AuraEnabled
    public List<string> lstDocumentType {get; Set;}
    
    @AuraEnabled
    public List<Document_Category_Master__c> listDocumentCategoryMaster {get; Set;}
    
    @AuraEnabled
    public List<Category_Type_Mapping__c> listCategoryTypeMapping {get; Set;}
    
    @AuraEnabled
    public List<string> lstExpApprovalStatus {get; Set;}
        
    @AuraEnabled
    public Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping {get; Set;}
    
    @AuraEnabled
    public Boolean isDocCateAvail {get; Set;}
    
    @AuraEnabled
    public Account accountObj {get; Set;}
    
    @AuraEnabled
    public Boolean isNew {get; Set;}	
	
    @AuraEnabled
    public Boolean isDocuCategory {get; Set;}
	
    @AuraEnabled
    public Boolean isDocuType {get; Set;}
	
    @AuraEnabled
    public Boolean isDocFormat {get; Set;}
	
    @AuraEnabled
    public Boolean isSalesRemark {get; Set;}
	
    @AuraEnabled
    public Boolean isOnboardingRemark {get; Set;}
	
    @AuraEnabled
    public Boolean isOnboardingStatus {get; Set;}
    
    @AuraEnabled
    public Boolean isExpiryDate {get; Set;}
    
    @AuraEnabled
    public String strError {get; Set;}
    
    @AuraEnabled
    public Boolean isApproved {get; Set;}
    
    @AuraEnabled
    public List<string> lstAllError {get; Set;}
    
    @AuraEnabled
    public Boolean isDocEditable {get; Set;}
    
    @AuraEnabled
    public Boolean isActive {get; Set;}
    
    @AuraEnabled
    public User userObj {get; Set;}
    
}