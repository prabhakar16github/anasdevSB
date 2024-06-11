/**
* @Trigger Name	: SeniorManagementDetailTrigger
* @Description 	: Trigger for Senior_Management_Detail__c.
* @Auther       : Prabhakar Joshi
* @Group       	: Onboarding  
*/
trigger SeniorManagementDetailTrigger on Senior_Management_Detail__c (before insert,after insert,after update) {
    /** Getting trigger switch setting */
	Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Senior_Management_Detail__c');
    
    /** checking the config for trigger - Active/Inactive */
    if(trgSwtchObj != null && trgSwtchObj.Active__c){   
        SeniorManagementDetailTriggerHandler handler = new SeniorManagementDetailTriggerHandler();
        
        switch on Trigger.OperationType  {
            when BEFORE_INSERT{
                handler.beforeInsert(trigger.new);
            }
            when AFTER_INSERT {
                handler.afterInsert(trigger.new);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(trigger.new,trigger.oldMap);
            }
        }
    }
}