trigger UpdatePricingRemarksTOChatter on Pricing__c (after update) {
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('UpdateRemarksChatter');
    if(trgSwitch != null && trgSwitch.Active__c){    
        If(Trigger.isUpdate){
        UpdatePricingRemarksChatterController.updateRemarks(Trigger.new);
        }
    }
}