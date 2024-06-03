@isTest
public class ApproveBelowRatesRecordsControllerTest {
    
    @testSetup
    public static void testSetupData() {
        Payment_Gateway2__c pg = new Payment_Gateway2__c();
        pg.Name = 'Test Payment Gateway';
        pg.Type__c = 'PostApproved';
        insert pg;
        
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        insert comm;
        
        List<Pricing__c> listPricingToInsert = new List<Pricing__c>();
        
        Pricing__c price1 = new Pricing__c();
        price1.Commercial2__c = comm.Id;
        price1.Payment_Gateway2__c = pg.Id;
        price1.Banking_Ops_Status__c = 'Pending with BH';
        price1.Below_Rack_Rates__c = true;
        listPricingToInsert.add(price1);
        
        Pricing__c price2 = new Pricing__c();
        price2.Commercial2__c = comm.Id;
        price2.Payment_Gateway2__c = pg.Id;
        price2.Banking_Ops_Status__c = 'Approved';
        price2.Below_Rack_Rates__c = false;
        listPricingToInsert.add(price2);
        
        insert listPricingToInsert;
    }
    
    @isTest
    public static void ApproveBelowRatesRecords() {
        List<Commercial2__c> listCommercial = [SELECT Id FROM Commercial2__c LIMIT 1];
        List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c LIMIT 1];
        PageReference pageRef = Page.ApproveBelowRatesRecords;
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('commercialId',listCommercial[0].Id);
        ApexPages.currentPage().getParameters().put('pricingId1',listPricing[0].Id);
        ApexPages.currentPage().getParameters().put('pricingId2',listPricing[0].Id);
        ApproveBelowRatesRecordsController controller = new ApproveBelowRatesRecordsController();
        controller.approveAllFunction();
        controller.approveSingleRecord();
        controller.rejectAllFunction();
        controller.rejectSingleRecord();
        
    }
}