public class UserConsentTriggerHandler {
    public static void beforeInsertHandler(List<User_Consent__c> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('User_Consent__c');
        
        for(User_Consent__c each : TriggerNew){         
            
            if(each.uuid__c != null && each.Identifier__c == null) {
                each.Identifier__c = each.uuid__c;
            }
        }
    }
}