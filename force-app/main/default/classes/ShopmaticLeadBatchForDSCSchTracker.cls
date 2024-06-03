@isTest
private class ShopmaticLeadBatchForDSCSchTracker {

    @isTest
    private static void testmethodOne(){
        ShopmaticLeadBatchForDSCScheduler sch = new ShopmaticLeadBatchForDSCScheduler();
        String sch1 = '0 0 2 * * ?';
        test.startTest();
        system.schedule('Bank Verification status check for Shopmatic leads', sch1, sch);
        Test.stopTest();
    } 
}