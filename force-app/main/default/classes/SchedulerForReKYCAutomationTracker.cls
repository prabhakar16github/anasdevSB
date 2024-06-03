@isTest
public class SchedulerForReKYCAutomationTracker {
	@isTest
    static void testSchedulerExecution() {
        Test.startTest();
        SchedulerForReKYCAutomation obj = new SchedulerForReKYCAutomation(); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to update Account Name', sch,obj);
        Test.stopTest();
        /*List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name IN ('VKYC_REMINDER_TODAY_Scheduler')];
        System.assertEquals(1, cronTriggers.size(), 'Job scheduled');
        for (CronTrigger ct : cronTriggers) {
            System.schedule(ct.Id, ct.CronExpression, new SchedulerForReKYCAutomation());
        }*/
    }
}