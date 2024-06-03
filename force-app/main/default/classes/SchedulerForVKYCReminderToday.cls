/**
* @Name         SchedulerForVKYCReminderToday 
* @Author       Saksham Rohilla
* @Description  This is a Schedulable class to schedule the Alerts to Merchant For Video KYC Reminder
* Anonymous Window  : SchedulerForVKYCReminderToday.scheduleVKYCReminder();
*/
public class SchedulerForVKYCReminderToday Implements Schedulable {
	public void execute(SchedulableContext sc){
        Database.executeBatch(new VKYCReminderTodayBatch());
    }
    public static void scheduleVKYCReminder() {
        System.schedule('VKYC_REMINDER_TODAY_Scheduler', '0 30 8 * * ?', new SchedulerForVKYCReminderToday());
    }
}