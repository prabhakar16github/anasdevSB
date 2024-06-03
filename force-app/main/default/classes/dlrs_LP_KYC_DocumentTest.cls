/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_LP_KYC_DocumentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_LP_KYC_DocumentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new LP_KYC_Document__c());
    }
}