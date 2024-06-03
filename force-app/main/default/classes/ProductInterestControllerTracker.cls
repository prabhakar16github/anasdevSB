@isTest
public class ProductInterestControllerTracker {

    @isTest
    static void testGetRelatedProductInterest() {
        // Create test data
        Opportunity opp = new Opportunity(Name='Test Opp', StageName = 'Test', CloseDate=Date.today());
        insert opp;

        Merchant_Product_Interest__c mpi = new Merchant_Product_Interest__c(MID__c = opp.Id, Active__c = '1');
        insert mpi;

        // Call the controller method
        List<Merchant_Product_Interest__c> result = ProductInterestController.getRelatedProductInterest(new List<Id>{opp.Id});
        List<Merchant_Product_Interest__c> result_2 = ProductInterestController.getRelatedProductInterestForStack(new List<Id>{opp.Id});

        // Assert the result
        System.assertEquals(0, result.size());
        System.assertEquals(0, result_2.size());
        //System.assertEquals(mpi.Id, result[0].Id);
    }

    @isTest
    static void testGetActiveProductInterest() {
        
        String activeSfId = '[{PayUPG_1077::0::0::0::0::0::0::2022-08-09::0::No_Insights},{PayUPG_1075::0::0::0::0::0::0::2022-08-09::0::No_Insights},{PayUPG_1076::0::0::0::0::0::0::2022-08-09::0::No_Insights},{PayUPG_1074::0::0::0::0::0::0::2022-08-09::0::No_Insights}]';
        String inactiveSfId = '[{PayUPG_1105::No_Insight},{PayUPG_1109::No_Insight},{PayUPG_1112::No_Insight}]';
        
        // Create test data
        Opportunity opp = new Opportunity(Name='Test Opp', StageName = 'Test', CloseDate=Date.today());
        insert opp;
        
        Merchant_Product_Interest__c mpi = new Merchant_Product_Interest__c(MID__c = opp.Id, Active__c = '2');
        insert mpi;
        
        Product_Bundle_Detail__c pbd = new Product_Bundle_Detail__c (Product_Bundle_ID__c	 = 'ABC 1');
        insert pbd;

        Merchant_Product_Interest__c mpi2 = new Merchant_Product_Interest__c(MID__c = opp.Id, Active__c = '2', Active_SF_IDs__c = activeSfId, Product_Bundle_Detail__c  = pbd.Id);
        insert mpi2;
        
        Merchant_Product_Interest__c mpi3 = new Merchant_Product_Interest__c(MID__c = opp.Id, Active__c = '2', Non_Active_SF_IDs__c = inactiveSfId, Product_Bundle_Detail__c  = pbd.Id);
        insert mpi3;
        
        
        //String interestId = [SELECT Id FROM Merchant_Product_Interest__c WHERE Id = mpi.Id LIMIT 1];
        
        

        // Call the controller method
        List<Merchant_Product_Interest__c> result = ProductInterestController.getActiveProductInterest(new List<Id>{opp.Id});
        List<Merchant_Product_Interest__c> result_2 = ProductInterestController.getActiveProductInterestForStack(new List<Id>{opp.Id});
        List<Opportunity> oppList = ProductInterestController.getOppGMVFields(new List<Id>{opp.Id});
        
        
        ProductInterestController.getInterestFields(mpi.Id);
        ProductInterestController.getJSONData(activeSfId);
        ProductInterestController.getJSONDataForInactive(inactiveSfId);
        ProductInterestController.getActiveInstrumentBundle(mpi2.Id);
        ProductInterestController.getInActiveInstrumentBundle(mpi3.Id);
        //ProductInterestController.getOppGMVFields(oppList);
        

        // Assert the result
        System.assertEquals(0, result.size());
        System.assertEquals(0, result_2.size());
        
        //System.assertEquals(mpi.Id, result[0].Id);
    }

    @isTest
    static void testUpdateProductInterest() {
        // Create test data
        Opportunity opp = new Opportunity(Name='Test Opp', StageName = 'Test', CloseDate=Date.today());
        insert opp;

        Merchant_Product_Interest__c mpi = new Merchant_Product_Interest__c(MID__c = opp.Id, Active__c = '1');
        insert mpi;

        // Call the controller method
        mpi.Active__c = '2';
        String jsonStr = JSON.serialize(mpi);
        ProductInterestController.updateProductInterest(jsonStr);

        // Assert the result
        Merchant_Product_Interest__c updatedMpi = [SELECT Active__c FROM Merchant_Product_Interest__c WHERE Id = :mpi.Id];
        System.assertEquals('2', updatedMpi.Active__c);
    }
}