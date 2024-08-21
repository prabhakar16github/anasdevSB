trigger RiskStatusDetailTrigger on Risk_status_Detail__c (before update,before insert, after update) {
    if (trigger.isBefore && trigger.isInsert) {
        RiskStatusDetailHandler.beforeInsertHandler(trigger.new);
    }
    if (trigger.isBefore && trigger.isUpdate) {
        RiskStatusDetailHandler.beforeUpdatePopulateUserAndDate(trigger.new, trigger.oldMap);
    }
    
    if (trigger.isAfter && trigger.isUpdate) {
        RiskStatusDetailHandler.afterInsertUpdateSettlementStatus(trigger.new);
    }
}