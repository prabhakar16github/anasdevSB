@isTest
public class VideoKYCTriggerHandlerTracker {
    @isTest static void testHandler() {
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Video_KYC__c', true);
        insert triggerSwitchObj ; 
        List<Video_KYC__c> VKYCRecords = new List<Video_KYC__c>();
            Video_KYC__c obj = new Video_KYC__c(
                Scheduled_At__c = System.now(),
                Start_At__c = System.now(),
                End_At__c = System.now(),
                Updated_At__c = System.now(),
                Review_Date__c = System.now(),
                Capture_DateTime__c = System.now(),
                Link_Created_At__c = System.now()
            );
            VKYCRecords.add(obj);
            Test.startTest();
            insert VKYCRecords;
            Test.stopTest();
            List<Video_KYC__c> insertedRecords = [
                SELECT Id,Scheduled_At__c,Start_At__c,End_At__c,Updated_At__c,Review_Date__c,Capture_DateTime__c,Link_Created_At__c
                FROM Video_KYC__c WHERE Id IN :VKYCRecords
            ];
        for(Video_KYC__c rec : insertedRecords){
            System.assertEquals(rec.Scheduled_At__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.Start_At__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.End_At__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.Updated_At__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.Review_Date__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.Capture_DateTime__c.hour(),System.now().addHours(5).addMinutes(30).hour());
            System.assertEquals(rec.Link_Created_At__c.hour(),System.now().addHours(5).addMinutes(30).hour());
        }
        for(Video_KYC__c rec:insertedRecords){
            rec.Scheduled_At__c = rec.Scheduled_At__c.addHours(1);
            rec.Start_At__c = rec.Start_At__c.addHours(1);
            rec.End_At__c = rec.End_At__c.addHours(1);
            rec.Updated_At__c = rec.Updated_At__c.addHours(1);
            rec.Review_Date__c = rec.Review_Date__c.addHours(1);
            rec.Capture_DateTime__c = rec.Capture_DateTime__c.addHours(1);
            rec.Link_Created_At__c = rec.Link_Created_At__c.addHours(1);
        }
        update insertedRecords;
        for(Video_KYC__c rec : insertedRecords){
            System.assertEquals(rec.Scheduled_At__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.Start_At__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.End_At__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.Updated_At__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.Review_Date__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.Capture_DateTime__c.hour(),System.now().addHours(6).addMinutes(30).hour());
            System.assertEquals(rec.Link_Created_At__c.hour(),System.now().addHours(6).addMinutes(30).hour());
        }
    }
    
}