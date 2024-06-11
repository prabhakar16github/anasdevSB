trigger ReleaseNoteTrigger on Release_Note__c (before update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            RiskMatrixDelegationUtility.updSettlementStatus(Trigger.New);
        }
    }
}