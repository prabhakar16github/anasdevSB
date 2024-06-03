public class AttachedConfigTriggerHandler {
    
    public static void beforeInsertHandler(List<Attached_Configuration__c> triggerNew){}
    
    public static void beforeUpdateHandler(List<Attached_Configuration__c> triggerNew, Map<Id,Attached_Configuration__c> triggerOldMap){}
    
    public static void afterInsertHandler(List<Attached_Configuration__c> triggerNew){
        
        Map<String,Opportunity> oppMap = New Map<String,Opportunity>();
        Map<String,Lead> leadMap = New Map<String,Lead>();
        
        List<Lead> updateLeads = New List<Lead>();
        List<Opportunity> updateOpportunities = New List<Opportunity>();
        
        for(Attached_Configuration__c each : triggerNew){
            if(String.isNotBlank(each.Lead__c) && each.Configurable_Type__c == 'Merchant'){
                leadMap.put(each.Lead__c,null);
            }
            if(String.isNotBlank(each.Opportunity__c) && each.Configurable_Type__c == 'Merchant'){
                oppMap.put(each.Opportunity__c,null);
            }
            
            if(String.isNotBlank(each.Configurable_Type__c) && String.isNotBlank(each.Configurable_Identifier__c)
               && each.Configurable_Type__c == 'Merchant' && String.isNotBlank(each.Name)){
                   IntegrationUtility.sendPayLoadData(each, null, 'Attached_Configuration__c', 'Attached_Configuration__c');
               }
        }
        
        if(System.isBatch() || Test.isRunningTest()){
            if(!oppMap.isEmpty()){
                for(Opportunity eachOpp : [Select Id,Identifier__c,Escrow_Lock__c from Opportunity Where Id IN: oppMap.keyset()]){
                    oppMap.put(eachOpp.Id,eachOpp);
                }
            }
            if(!leadMap.isEmpty()){
                for(Lead eachLead : [Select Id,Identifier__c,isConverted,Escrow_Lock__c,Penny_Verification_Required__c from Lead Where Id IN: leadMap.Keyset()]){
                    leadMap.put(eachLead.Id,eachLead);
                }
            } 
            
            for(Attached_Configuration__c each : triggerNew){
                if(String.isNotBlank(each.Name) && each.Active__c){
                    if(each.Name == 'bank_detail_config'){
                        
                        if(leadMap.containsKey(each.Lead__c) && leadMap.get(each.Lead__c) != null
                           && !leadmap.get(each.Lead__c).isConverted){
                               Lead eachLead = leadmap.get(each.Lead__c);
                               eachLead.Escrow_Lock__c = each.Bank_Updatable__c;
                               updateLeads.add(eachLead);
                           }else if(oppMap.containsKey(each.Opportunity__c) && oppMap.get(each.Opportunity__c) != null){
                               Opportunity eachOpp = oppMap.get(each.Opportunity__c);
                               eachOpp.Escrow_Lock__c = each.Bank_Updatable__c;
                               updateOpportunities.add(eachOpp);
                           }
                        
                    }
                    
                    if(each.Name == 'onboarding_config'){
                        
                        if(leadMap.containsKey(each.Lead__c) && leadMap.get(each.Lead__c) != null
                           && !leadmap.get(each.Lead__c).isConverted){
                               Lead eachLead = leadmap.get(each.Lead__c);
                               eachLead.Penny_Verification_Required__c  = each.Penny_Verification_Required__c;
                               updateLeads.add(eachLead);
                           }
                    }
                }
            }
        }
        if(!updateOpportunities.isEmpty()) update updateOpportunities;
        if(!updateLeads.isEmpty()) update updateLeads;
    }
    
    public static void afterUpdateHandler(List<Attached_Configuration__c> triggerNew, Map<Id,Attached_Configuration__c> triggerOldMap){
        
        for(Attached_Configuration__c each : triggerNew){
            Attached_Configuration__c oldEach = triggerOldMap.get(each.Id);
            if(String.isNotBlank(each.Configurable_Type__c) && String.isNotBlank(each.Configurable_Identifier__c)
               && each.Configurable_Type__c == 'Merchant'){
                   IntegrationUtility.sendPayLoadData(each, oldEach, 'Attached_Configuration__c', 'Attached_Configuration__c');
               }
        }
    }
}