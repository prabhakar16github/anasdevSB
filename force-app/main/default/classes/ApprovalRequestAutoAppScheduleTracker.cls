@isTest
public class ApprovalRequestAutoAppScheduleTracker {
  @isTest
    Public static  void scheduleMethod(){
        Test.startTest();
        SchedulableContext sc;
        ApprovalRequestAutoApproveSchedule objschedule = new ApprovalRequestAutoApproveSchedule ();
        objschedule.execute(sc);
        Test.stopTest();
    }
}