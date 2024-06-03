/**
* @Class Name   :   SeniorManagementDetailTriggerHandler
* @Description  :   Handler class for SeniorManagementDetailTriggerHandler.
* @Auther       :   Prabhakar Joshi
* @Group        :   Onboarding  
*/
public class SeniorManagementDetailTriggerHandler {
    
    public static Boolean runningFromConsumerAPI = false;
    
    public void beforeInsert(List<Senior_Management_Detail__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Senior_Management_Detail__c');
        for(Senior_Management_Detail__c each : triggerNew){
            /** Getting unique identifier for record */
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
        }
    }
    
    public void afterInsert(List<Senior_Management_Detail__c> triggerNew){
        for(Senior_Management_Detail__c each : triggerNew){
            /** to publish the payload to ESB */
            this.publishToESB(each,NULL);
        } 
    }
    
    public void afterUpdate(List<Senior_Management_Detail__c> triggerNew,Map<Id,Senior_Management_Detail__c> oldMap){
        for(Senior_Management_Detail__c each : triggerNew){
            /** to publish the payload to ESB */
            this.publishToESB(each,oldMap.get(each.Id));
        }
    }
    
    /** 
    private method to publish the Senior_Management_Detail__c data to ESB.
    @param1 - new values
    @param2 - old values for update.
    */
    private void publishToESB(Senior_Management_Detail__c newObj,Senior_Management_Detail__c oldObj){
        if(!runningFromConsumerAPI){
            IntegrationUtility.checkMaintenance(newObj, oldObj, 'Senior_Management_Detail__c', 'Senior_Management_Detail__c');
        }
        
    }/** END */
}