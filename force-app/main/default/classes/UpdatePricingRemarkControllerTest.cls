@isTest
public class UpdatePricingRemarkControllerTest {
    @testSetup static void BankingOpsModule(){
        List<Pricing__c> pricingList = new List<Pricing__c>();
        Pricing__c pricing = new Pricing__c();
        pricing.Banking_Ops_Status__c	 = 'Pending with KAM';
        pricing.Status__c  = 'Pending with KAM';
        pricing.Remarks__c = 'Test By Rohit';
        pricingList.add(pricing);
        Insert pricingList;
    }
    @istest static void testMethodOne(){
        List<Pricing__c> pricingList = [SELECT Id, Remarks__c FROM Pricing__c LIMIT 1];
        UpdatePricingRemarksChatterController.updateRemarks(pricingList);
    }
}