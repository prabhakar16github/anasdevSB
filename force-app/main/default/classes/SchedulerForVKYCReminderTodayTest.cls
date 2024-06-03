@isTest
public class SchedulerForVKYCReminderTodayTest {
	@isTest
    static void testSchedulerExecution() {
        Test.startTest();
        SchedulerForVKYCReminderToday.scheduleVKYCReminder();
        Test.stopTest();
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name IN ('VKYC_REMINDER_TODAY_Scheduler')];
        System.assertEquals(1, cronTriggers.size(), 'Job scheduled');
        for (CronTrigger ct : cronTriggers) {
            System.schedule(ct.Id, ct.CronExpression, new SchedulerForVKYCReminderToday());
        }
    }
}