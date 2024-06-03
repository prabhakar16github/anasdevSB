/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Merchant_DocumentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Merchant_DocumentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Merchant_Document__c());
    }
}