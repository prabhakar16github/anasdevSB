/*
 * Name of the class : SchedulerForDormancyAndReKYCReminder
 * Author's Name     : Saksham Rohilla  
 * Description       : Scheduler class for DormancyAndReKYCReminder
 * Anonymous Window  : SchedulerForDormancyAndReKYCReminder.scheduleDormancyReminder();
					   SchedulerForDormancyAndReKYCReminder.scheduleReKYCReminder();
					   SchedulerForDormancyAndReKYCReminder.scheduleReKYCOverdueReminder();
 */ 
global class SchedulerForDormancyAndReKYCReminder implements Schedulable {
    global void execute(SchedulableContext sc) {
        String jobName = sc.getTriggerId();
        if (jobName.contains('DORMANCY_REMINDER')) {
            executeReminder('DORMANCY_REMINDER');
        } else if (jobName.contains('REKYC_REMINDER')) {
            executeReminder('REKYC_REMINDER');
        } else if (jobName.contains('REKYC_OVERDUE')) {
            executeReminder('REKYC_OVERDUE');
        }
    }
    @TestVisible
    private void executeReminder(String type) {
        DormancyandReKYCReminder obj = new DormancyandReKYCReminder(type);
        Database.executeBatch(obj);
    }
    public static void scheduleDormancyReminder() {
        System.schedule('DORMANCY_REMINDER_Scheduler', '0 30 10 * * ?', new SchedulerForDormancyAndReKYCReminder());
    }
    public static void scheduleReKYCReminder() {
        System.schedule('REKYC_REMINDER_Scheduler', '0 30 11 * * ?', new SchedulerForDormancyAndReKYCReminder());
    }
    public static void scheduleReKYCOverdueReminder() {
        System.schedule('REKYC_OVERDUE_Scheduler', '0 30 12 * * ?', new SchedulerForDormancyAndReKYCReminder());
    }
}