public class WrapperWebsitePage {
	@AuraEnabled
    public Website_Page__c WebsitePageObj {get; Set;}
    
    @AuraEnabled
    public List<string> lstWebsitePageStatus {get; Set;}
    
    @AuraEnabled
    public Boolean isEditAllow {get; Set;}
    
    @AuraEnabled
    public Boolean isOnlyViewAllow {get; Set;}
    
    //@AuraEnabled
    //public String strProfileName {get; Set;}
    
    @AuraEnabled
    public Boolean isSalesRemark {get; Set;}
    
    @AuraEnabled
    public Boolean isRiskRemark {get; Set;}
    
    @AuraEnabled
    public Boolean isStatus {get; Set;}
    
    @AuraEnabled
    public User userObj {get; Set;}
    
    @AuraEnabled
    public Boolean isInApprovalProcess {get; Set;}
    
    @AuraEnabled
    public Boolean isObjectEditable {get; Set;}
    
    @AuraEnabled
    public Boolean isURL {get; Set;}
    
    @AuraEnabled
    public Boolean pageDetails {get; Set;}
    
    @AuraEnabled
    public Opportunity OppObj {get; Set;}
    
    @AuraEnabled
    public Boolean checkNonCards {get;set;}
    
    @AuraEnabled
    public Comments__c latestCommentsObj {get;set;}
    
    @AuraEnabled
    public Website_Details__c websiteDetailsObj {get;set;}

   /* @AuraEnabled
    public List<String> riskRatingOptions {get;set;}*/
    
    @AuraEnabled
    public List<String> listAllRiskComments = new List<String>(); //Added By Kunal- SFI-279
}