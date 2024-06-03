@isTest
public class OfflineOnboardingOpportunityTracker {

    
    @testSetup static void setupCommonData(){
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            //opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
            //opportunityObj.BusinessCategory__c = businessCategory.id;
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.Manual_Call_Response__c = 'CallStartTime:01-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:323';
            //opportunityObj.Partner_ID__c = Label.Shopmatric_UUID;
            opportunityObj.C2C_Call_Count__c=2;
            opportunityObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
            opportunityObj.Risk_Type_Multi_Select__c = 'Website URL';
            opportunityObj.Blacklist__c = true;
            opportunityObj.Agent_Details__c='Shivdeep test - 7877002681';
        	opportunityObj.Name = 'Test MID';
            insert opportunityObj;
    }

    @isTest
    static void testGetRelatedWebsiteDetails() {
        
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Website_Details__c> websiteDetails = OfflineOnboardingOpportunityController.getRelatedWebsiteDetails(oppIds);
        //System.assertEquals(1, websiteDetails.size());
    }

    @isTest
    static void testGetOperatingAddressDetails() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Address_Details__c> operatingAddressDetails = OfflineOnboardingOpportunityController.getOperatingAddressDetails(oppIds);
        //System.assertEquals(1, operatingAddressDetails.size());
    }

    @isTest
    static void testGetRegisteredAddressDetails() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Address_Details__c> registeredAddressDetails = OfflineOnboardingOpportunityController.getRegisteredAddressDetails(oppIds);
        //System.assertEquals(1, registeredAddressDetails.size());
    }

    @isTest
    static void testGetBankAccountDetails() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Bank_Account_Detail__c> bankAccountDetails = OfflineOnboardingOpportunityController.getBankAccountDetails(oppIds);
        //System.assertEquals(1, bankAccountDetails.size());
    }

    @isTest
    static void testGetContactDetails() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Contact> contactDetails = OfflineOnboardingOpportunityController.getContactDetails(oppIds);
        //System.assertEquals(1, contactDetails.size());
    }

    @isTest
    static void testGetUBODetails() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Ultimate_Beneficiary_Owner_UBO__c> uboDetails = OfflineOnboardingOpportunityController.getUBODetails(oppIds);
        //System.assertEquals(1, uboDetails.size());
    }

    @isTest
    static void testGetOpportunityStatuses() {
        List<Id> oppIds = new List<Id>{[SELECT Id FROM Opportunity WHERE Name = 'Test MID'].Id};
        List<Opportunity> opportunityStatuses = OfflineOnboardingOpportunityController.getOpportunityStatuses(oppIds);
        //System.assertEquals(1, opportunityStatuses.size());
    }



}