@isTest
private class LeadBankCheckScheuleTracker {

    @isTest
    private static void testmethodOne(){
        LeadBankVerificationCheckBatchScheduler sch = new LeadBankVerificationCheckBatchScheduler();
        String sch1 = '0 0 2 * * ?';
        test.startTest();
        system.schedule('Lead Bannk Verification status check', sch1, sch);
        Test.stopTest();
    } 
}