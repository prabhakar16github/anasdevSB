public class CommentsTriggerHandler {
    
    public static void beforeInsertHandler(List<Comments__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Comments__c');
        
        for(Comments__c commentObj : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(commentObj, 'Identifier__c', enableUUIDObj);
        }
    }
    
    public static void beforeUpdateHandler(List<Comments__c> triggerNew, Map<Id,Comments__c> triggerOldMap){
        
    }
    
    public static void afterInsertHandler(List<Comments__c> triggerNew){
        for(Comments__c commentObj : triggerNew){
            if(!system.isBatch() && commentObj.Data_need_to_be_publish__c){
                IntegrationUtility.sendPayLoadData(commentObj, null, 'Comments__c', 'Comments__c'); 
            }
        }
    }
    
    public static void afterUpdateHandler(List<Comments__c> triggerNew, Map<Id,Comments__c> triggerOldMap){
        for(Comments__c commentObj : triggerNew){
            Comments__c oldCommentObj = triggerOldMap.get(commentObj.Id);
            if(!system.isBatch() && commentObj.Data_need_to_be_publish__c){
                IntegrationUtility.sendPayLoadData(commentObj, oldCommentObj, 'Comments__c', 'Comments__c'); 
            }
        }
    }
}