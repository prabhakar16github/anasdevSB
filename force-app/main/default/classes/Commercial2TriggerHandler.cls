public class Commercial2TriggerHandler {
    public static void beforeInsert(List<Commercial2__c> triggerNew){
        Map<Id,Boolean> mapOpportunityIdToCommercialInsertionAllowed = new Map<Id,Boolean>(); 
        for(Commercial2__c commercial : triggerNew) {
            if(commercial.Opportunity__c != NULL) {
                if(mapOpportunityIdToCommercialInsertionAllowed.containsKey(commercial.Opportunity__c)) {
                    mapOpportunityIdToCommercialInsertionAllowed.put(commercial.Opportunity__c,false);
                    continue;
                }  
                mapOpportunityIdToCommercialInsertionAllowed.put(commercial.Opportunity__c,true);
            }
        }
        
        if(mapOpportunityIdToCommercialInsertionAllowed.keySet().size() > 0) {
            for(Commercial2__c commercial : [SELECT Id,Opportunity__c FROM Commercial2__c 
                                             WHERE Opportunity__c IN :mapOpportunityIdToCommercialInsertionAllowed.keySet()]) {
                                                 mapOpportunityIdToCommercialInsertionAllowed.put(commercial.Opportunity__c,false);    
                                             }
        }
        
        for(Commercial2__c commercial : triggerNew) {
            if(commercial.Opportunity__c != NULL && mapOpportunityIdToCommercialInsertionAllowed.containsKey(commercial.Opportunity__c) && !mapOpportunityIdToCommercialInsertionAllowed.get(commercial.Opportunity__c)) {
                commercial.addError('Commercial already exist for this Merchant');
            }
        }
    }
}