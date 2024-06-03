/******************************************************************************************************************
 * Class : OfflineOnboardingOpportunityController
 * Author : Kunal Raj
 * Purpose : Component for Opportunity Nurturing of the Enterprise Offline Merchants
 ******************************************************************************************************************/

public class OfflineOnboardingOpportunityController {
    
    /*************************Fetching Active Website Details and putting it in lightning-record-edit-form**********/
    @AuraEnabled(cacheable=true)
    public static List<Website_Details__c> getRelatedWebsiteDetails(List<Id> oppId){
        return [SELECT Id, Name , Opportunity__c, Website_Status__c , Active__c, Website_URL__c, IOS_URL__c, Android_URL__c, Merchant_Platform__c  
                FROM Website_Details__c 
                WHERE Active__c = TRUE AND Opportunity__c  IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Active Operating Address and putting it in lightning-record-edit-form*******************************/
    @AuraEnabled(cacheable=true)
    public static List<Address_Details__c > getOperatingAddressDetails(List<Id> oppId){
        return [SELECT Id, Opportunity__c, Account__c, Address_Line__c, City__c, Pincode__c, State__c, Country__c, Active__c, Type__c
                FROM Address_Details__c 
                WHERE Type__c = 'Operating' AND Active__c = TRUE AND Opportunity__c  IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Active Registered Address and putting it in lightning-record-edit-form******************************/
    @AuraEnabled(cacheable=true)
    public static List<Address_Details__c > getRegisteredAddressDetails(List<Id> oppId){
        return [SELECT Id, Name , Opportunity__c, Account__c, Address_Line__c, City__c, Pincode__c, State__c, Country__c, Active__c, Type__c
                FROM Address_Details__c 
                WHERE Type__c = 'Registered' AND Active__c = TRUE AND Opportunity__c  IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Active Bank Account Details and putting it in lightning-record-edit-form*****************************/
    @AuraEnabled(cacheable=true)
    public static List<Bank_Account_Detail__c  > getBankAccountDetails(List<Id> oppId){
        return [SELECT Id, Name, Active__c, Account_Type__c, Account_Holder_Name__c, Account_Number__c, IFSC_Code__c, Bank_Name__c, Branch_Address__c, Opportunity__c
                FROM Bank_Account_Detail__c 
                WHERE Active__c = TRUE AND Opportunity__c  IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Active Authorized Contact and putting it in lightning-record-edit-form*******************************/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactDetails(List<Id> oppId){
        return [SELECT Id, Name, AccountId, Opportunity__c, MobilePhone, Email, PAN__c, Authorised_Signatory__c, Active__c
                FROM Contact  
                WHERE Active__c = TRUE AND Authorised_Signatory__c = TRUE AND Opportunity__c  IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching UBO and putting it in UBO Table**************************************************************/
	@AuraEnabled(cacheable=true)
    public static List<Ultimate_Beneficiary_Owner_UBO__c > getUBODetails(List<Id> oppId){
        return [SELECT Id, Name, Active__c, UBO_Name__c, Ownership__c, toLabel(Nationality__c), Merchant_UUID__c, Ownership_num__c, PAN__c, DOB__c, Address_Line__c, Pincode__c, State__c, City__c 
                FROM Ultimate_Beneficiary_Owner_UBO__c   
                WHERE Active__c = TRUE AND Merchant_UUID__c IN: oppId];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Statuses from Opportunity**************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Opportunity > getOpportunityStatuses(List<Id> oppId){
        return [SELECT Id, Agreement_Status__c, Document_Status_Document_Issue__c, Merchant_Platform__c, Business_Entity_Formula__c, BusinessCategory__c, Sub_Category__c, GST_Number__c, Monthly_Expected_Sale__c, Lead_Business_Name__c, Customer_Declaration_PEP__c, Jocata_System_Alerts__c, PEP_Status__c, Comment__c, Website__c, iOS_URL__c, Android_URL__c 
                FROM Opportunity   
                WHERE Active__c = TRUE AND Id IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    /*************************Fetching Senior Management from Opportunity**************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Senior_Management_Detail__c> getSeniorManagement(List<Id> oppId){
        return [SELECT Id, Name, Opportunity__c, Designation__c, DOB__c, Active__c 
                FROM Senior_Management_Detail__c   
                WHERE Active__c = TRUE AND Opportunity__c IN: oppId];
    }
    /*******************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static OfflineOnbWrapper getWrapperData(Id oppId){
        OfflineOnbWrapper result = new OfflineOnbWrapper();
        
        result.contact = [SELECT Id, Name, AccountId, Opportunity__c, MobilePhone, Email, PAN__c, Authorised_Signatory__c, Active__c
                FROM Contact  
                WHERE Active__c = TRUE AND Authorised_Signatory__c = TRUE AND Opportunity__c  =: oppId LIMIT 1];
        
        result.bank = [SELECT Id, Name, Active__c, Account_Type__c, Account_Holder_Name__c, Account_Number__c, IFSC_Code__c, Bank_Name__c, Branch_Address__c, Opportunity__c
                FROM Bank_Account_Detail__c 
                WHERE Active__c = TRUE AND Opportunity__c =: oppId LIMIT 1];
        
        return result;
        
    }
    
    
    /*************************Fetching FILES from Opportunity**************************************************************/
    
    /*@AuraEnabled(cacheable=true)
    public static List<ContentDocument > getOpportunityFiles(Id oppId){
        return [SELECT Id, Title, ContentSize FROM ContentDocumentLink WHERE LinkedEntityId =: oppId AND ContentDocument.latestPublishedVersionId != null];
    }*/
    /*******************************************************************************************************************/
	
    public class OfflineOnbWrapper {
        @AuraEnabled
        public Contact contact { get; set; }
        
        @AuraEnabled
        public Bank_Account_Detail__c bank { get; set; }
    }
}