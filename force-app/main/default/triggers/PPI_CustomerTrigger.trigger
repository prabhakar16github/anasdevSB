trigger PPI_CustomerTrigger on PPI_Customer__c (before insert) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('PPI_Customer__c');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){   
        PPI_CustomerTriggerHandler handler = new PPI_CustomerTriggerHandler();

        switch on Trigger.OperationType  {

            when BEFORE_INSERT {
                handler.beforeInsert(trigger.new);
            }
        }
    }
}