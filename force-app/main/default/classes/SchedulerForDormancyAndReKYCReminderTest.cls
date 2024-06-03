@isTest
public class SchedulerForDormancyAndReKYCReminderTest {
	@isTest
    static void testSchedulerExecution() {
        Test.startTest();
        SchedulerForDormancyAndReKYCReminder.scheduleDormancyReminder();
        SchedulerForDormancyAndReKYCReminder.scheduleReKYCReminder();
        SchedulerForDormancyAndReKYCReminder.scheduleReKYCOverdueReminder();
        Test.stopTest();
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name IN ('DORMANCY_REMINDER_Scheduler', 'REKYC_REMINDER_Scheduler', 'REKYC_OVERDUE_Scheduler')];
        System.assertEquals(3, cronTriggers.size(), 'All three jobs should be scheduled');
        for (CronTrigger ct : cronTriggers) {
            System.schedule(ct.Id, ct.CronExpression, new SchedulerForDormancyAndReKYCReminder());
        }
        executeReminder('DORMANCY_REMINDER');
        executeReminder('REKYC_REMINDER');
        executeReminder('REKYC_OVERDUE');
    }
    static void executeReminder(String reminderType) {
        SchedulerForDormancyAndReKYCReminder scheduler = new SchedulerForDormancyAndReKYCReminder();
        scheduler.executeReminder(reminderType);
    }
}