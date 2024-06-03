@isTest
private class OneCareCaseReportBulkUpdateSchlTracker{

    @isTest
    private static void testmethodOne(){
        OneCareCaseReportBulkUpdateScheduler sch = new OneCareCaseReportBulkUpdateScheduler();
        String sch1 = '0 0 2 * * ?';
        test.startTest();
        system.schedule('Case report field update', sch1, sch);
        Test.stopTest();
    } 
}