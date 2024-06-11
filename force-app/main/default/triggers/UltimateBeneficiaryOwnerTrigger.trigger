trigger UltimateBeneficiaryOwnerTrigger on Ultimate_Beneficiary_Owner_UBO__c (before insert,after Insert,after update) {
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('Ultimate_Beneficiary_Owner_UBO__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) UltimateBeneficiaryOwnerTrigHandler.beforeInsertHandler(Trigger.New);
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                UltimateBeneficiaryOwnerTrigHandler.afterInsertHandler(Trigger.New);
            }
        }
    }

}