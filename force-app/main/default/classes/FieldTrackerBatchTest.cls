@isTest
private class FieldTrackerBatchTest {
	@isTest
    private static void testFieldTrackerBatch() {
        Database.executeBatch(new FieldTrackerBatch('Opportunity'),2000);
    }
}