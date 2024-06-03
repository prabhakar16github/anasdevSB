/**
* @Class Name   :   VideoKYCTriggerHandler
* @Description  :   Class to update time from UTC to IST.Fields are consumed from CO for Video KYC Object. 
* @Author       :   Saksham Rohilla(for SFI-1179)
Not needed
*/
public class VideoKYCTriggerHandler {
    public static void beforeInsertHandler(List<Video_KYC__c> triggerNew){
        /*String userTimeZone = UserInfo.getTimeZone().getID();
        TimeZone tz = TimeZone.getTimeZone(userTimeZone);
        for(Video_KYC__c each : triggerNew){
            if(each.Scheduled_At__c != null){
                    each.Scheduled_At__c = each.Scheduled_At__c.addSeconds(tz.getOffset(each.Scheduled_At__c)/1000);
                }
                if(each.Start_At__c != null){
                    each.Start_At__c = each.Start_At__c.addHours(5).addMinutes(30);
                }
                if(each.End_At__c != null){
                    each.End_At__c = each.End_At__c.addHours(5).addMinutes(30);
                }
                if(each.Updated_At__c != null){
                    each.Updated_At__c = each.Updated_At__c.addHours(5).addMinutes(30);
                }
                if(each.Review_Date__c != null){
                    each.Review_Date__c = each.Review_Date__c.addHours(5).addMinutes(30);
                }
                if(each.Capture_DateTime__c != null){
                    each.Capture_DateTime__c = each.Capture_DateTime__c.addHours(5).addMinutes(30);
                }
                if(each.Link_Created_At__c != null){
                    each.Link_Created_At__c = each.Link_Created_At__c.addHours(5).addMinutes(30);
                }
        }*/
    }
    public static void beforeUpdateHandler(List<Video_KYC__c> triggerNew, Map<Id,Video_KYC__c> triggerOldMap){
            /*for(Video_KYC__c each : triggerNew){
                Video_KYC__c oldEach = triggerOldMap.get(each.Id);
                if(each.Scheduled_At__c != null && each.Scheduled_At__c != oldEach.Scheduled_At__c){
                    each.Scheduled_At__c = each.Scheduled_At__c.addHours(5).addMinutes(30);
                }
                if(each.Start_At__c != null && each.Start_At__c != oldEach.Start_At__c){
                    each.Start_At__c = each.Start_At__c.addHours(5).addMinutes(30);
                }
                if(each.End_At__c != null && each.End_At__c != oldEach.End_At__c){
                    each.End_At__c = each.End_At__c.addHours(5).addMinutes(30);
                }
                if(each.Updated_At__c != null && each.Updated_At__c != oldEach.Updated_At__c){
                    each.Updated_At__c = each.Updated_At__c.addHours(5).addMinutes(30);
                }
                if(each.Review_Date__c != null && each.Review_Date__c != oldEach.Review_Date__c){
                    each.Review_Date__c = each.Review_Date__c.addHours(5).addMinutes(30);
                }
                if(each.Capture_DateTime__c != null && each.Capture_DateTime__c != oldEach.Capture_DateTime__c){
                    each.Capture_DateTime__c = each.Capture_DateTime__c.addHours(5).addMinutes(30);
                }
                if(each.Link_Created_At__c != null && each.Link_Created_At__c != oldEach.Link_Created_At__c){
                    each.Link_Created_At__c = each.Link_Created_At__c.addHours(5).addMinutes(30);
                }
            }*/
        }    
}