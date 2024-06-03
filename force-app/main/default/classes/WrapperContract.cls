public class WrapperContract {
	@AuraEnabled
    public contract contractObj {get; Set;}   
    
    @AuraEnabled
    public List<String> lstContractStatus {get; Set;}
    
    @AuraEnabled
    public Boolean isContDocuCategory {get; Set;}
	
    @AuraEnabled
    public Boolean isContDocuType {get; Set;}
	
    @AuraEnabled
    public Boolean isContDocFormat {get; Set;}
	
    @AuraEnabled
    public Boolean isContSalesRemark {get; Set;}
	
    @AuraEnabled
    public Boolean isContOnboardingRemark {get; Set;}
	
    @AuraEnabled
    public Boolean isContStatus {get; Set;}
    
    @AuraEnabled
    public Boolean isContApproved {get; Set;}
    
    @AuraEnabled
    public Boolean isContDeclined {get; Set;}
    
    @AuraEnabled
    public String strError {get; Set;}
    
    @AuraEnabled
    public List<Document_Category_Master__c> listDocumentCategoryMaster {get; Set;}
    
    @AuraEnabled
    public List<Category_Type_Mapping__c> listCategoryTypeMapping {get; Set;}
        
    @AuraEnabled
    public Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping {get; Set;}
    
    @AuraEnabled
    public List<string> lstDocumentReceived {get; Set;}
    
    @AuraEnabled
    public List<string> lstAllError {get; Set;}
    
    @AuraEnabled
    public Boolean isDocEditable {get; Set;}
    
    @AuraEnabled
    public Boolean isDocCateAvail {get; Set;}
    
    @AuraEnabled
    public Boolean isActive {get; Set;}
}