public class WrapperSendAgreement {
	
    @AuraEnabled
    public Opportunity oppObj {get; Set;}
    
    @AuraEnabled
    public Account accObj {get; Set;}
    
    @AuraEnabled
    public List<Document_Master__c> lstDocMasterAddendum {get; Set;}
    
    @AuraEnabled
    public List<Document_Master__c> lstDocMasterAgreement {get; Set;}
    
    @AuraEnabled
    public List<Document_Master__c> lstDocMasterPayoutAgreement {get; Set;}
    
    @AuraEnabled
    public List<Document_Type_Master__c> lstDocTypeAddendum {get; Set;}
    
    @AuraEnabled
    public boolean isContractAvail {get; Set;}
    
    @AuraEnabled
    public Contact authSignContact {get; Set;}

    @AuraEnabled
    public Contract optyRelatedContract {get; Set;}
    
    @AuraEnabled
    public Contract optyRelatedPayoutContract {get; Set;}
    
    @AuraEnabled
    public boolean isSendingMail {get; Set;}
    
    @AuraEnabled
    public Contract counterSignedContract {get; Set;}
    
    @AuraEnabled
    public List<Fee_Master__c> lstFeeMaster {get; Set;}
    
    @AuraEnabled
    public List<Cross_Sell__c> lstCrossSell {get; Set;}
}