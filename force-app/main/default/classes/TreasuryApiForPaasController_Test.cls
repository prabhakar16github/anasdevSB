@isTest
public class TreasuryApiForPaasController_Test {
    @testSetup
    public static void testDataSetup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Bank_Category__c bc = new Bank_Category__c();
        bc.Name = 'Donation';
        insert bc;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Bank_Category__c = bc.Id;
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 123456;
        insert opp;
        List<Other_Product_Pricing__c> listOtherProductPricing = new List<Other_Product_Pricing__c>();
        Other_Product_Pricing__c other = new Other_Product_Pricing__c();
        other.Opportunity__c = opp.Id;
        other.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Instant_Settlement');
        other.Client_Id__c = '1';
        other.Revenue_Model__c = 'instantSettlementTdr';
        other.Debit_Model__c = 'Net';
        other.Amount_Slab__c = 10;
        other.Flat_Fee__c = 12;
        other.Rule_Id__c ='12345';
        listOtherProductPricing.add(other);
        
        Other_Product_Pricing__c other1 = new Other_Product_Pricing__c();
        other1.Opportunity__c = opp.Id;
        other1.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Offer_Engine');
        other1.Client_Id__c = '1';
        other1.Revenue_Model__c = 'offerTDR';
        other1.Debit_Model__c = 'Net';
        other1.Flat_Fee__c = 12;
        listOtherProductPricing.add(other1);
        
        Other_Product_Pricing__c other2 = new Other_Product_Pricing__c();
        other2.Opportunity__c = opp.Id;
        other2.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Offer_Engine');
        other2.Client_Id__c = '1';
        other2.Revenue_Model__c = 'offerActivationFee';
        other2.Debit_Model__c = 'Net';
        other2.Flat_Fee__c = 12;
        other2.Valid_From__c = Date.newInstance(2024,11,11);
        listOtherProductPricing.add(other2);
        
        insert listOtherProductPricing;
        
    }
    public static testMethod void TreasuryApiForPaasController(){
         List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        TreasuryApiForPaasController.getExistingRecords(listOpportunity[0].Id);
    }
}