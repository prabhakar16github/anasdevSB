public class MasterPricingDataTriggerHandler {
    
    public static void afterUpdate(List<Master_Pricing_Data__c> triggerNew,Map<Id,Master_Pricing_Data__c> triggerOldMap) {
        
        Set<Id> setInactiveInstrumentIds = new Set<Id>();
        Set<Id> setActiveInstrumentIds = new Set<Id>();
        for(Master_Pricing_Data__c mpd : triggerNew) {
            if(mpd.Active_Instrument__c && mpd.Active_Instrument__c != triggerOldMap.get(mpd.Id).Active_Instrument__c) setActiveInstrumentIds.add(mpd.Id);
            else if(!mpd.Active_Instrument__c && mpd.Active_Instrument__c != triggerOldMap.get(mpd.Id).Active_Instrument__c) setInActiveInstrumentIds.add(mpd.Id);
        }
        
        if(setInactiveInstrumentIds.size() > 0) {
            Map<Id,Set<String>> mapOpportunityIdToRule = new Map<Id,Set<String>>();
            Map<Id,String> mapOpportunityIdToMID = new Map<Id,String>();
            Set<String> setRulesIdsV1 = new Set<String>();
            List<Pricing__c> listPricing = new List<Pricing__c>(); 
            for(Pricing__c price : [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Commercial2__c,Commercial2__r.Status__c,Opportunity__c,
                                    Opportunity__r.Prod_MID__c,Deleted__c,Published__c,Need_to_Publish__c 
                                    FROM Pricing__c 
                                    WHERE Master_Pricing_Data__c IN :setInactiveInstrumentIds]) {
                                        mapOpportunityIdToMID.put(price.Opportunity__c,price.Opportunity__r.Prod_MID__c);
                                        if(price.Commercial2__r.Status__c == 'Live' && price.Published__c) {
                                            Set<String> setRuleIds = new Set<String>();
                                            if(mapOpportunityIdToRule.containsKey(price.Opportunity__c)) setRuleIds = mapOpportunityIdToRule.get(price.Opportunity__c);
                                            setRuleIds.add(price.Rule_Id__c);
                                            setRuleIds.add(price.Rule_Id_Conv__c);
                                            mapOpportunityIdToRule.put(price.Opportunity__c,setRuleIds);
                                            setRulesIdsV1.add(price.Rule_Id__c);
                                            setRulesIdsV1.add(price.Rule_Id_Conv__c);
                                        }
                                        price.Deleted__c = true;
                                        price.Need_to_Publish__c = false;
                                        price.Rule_Id__c = '';
                                        price.Rule_Id_Conv__c = '';
                                        //price.Published__c = false;
                                        listPricing.add(price);
                                    }
            
            List<Template_Details__c> listTemplateDetailsToUpdate = new List<Template_Details__c>();
            for(Template_Details__c td : [SELECT Id,Deleted__c FROM Template_Details__c WHERE Master_Pricing_Data__c IN :setInactiveInstrumentIds]) {
                td.Deleted__c = true;
                listTemplateDetailsToUpdate.add(td);
            }
            if(listTemplateDetailsToUpdate.size() > 0) update listTemplateDetailsToUpdate;
            
            if(listPricing.size() > 0) {
                update listPricing;
                if(mapOpportunityIdToRule.keySet().size() > 0) 
                    //deleteRecordsFromTreasury(JSON.serialize(mapOpportunityIdToRule),JSON.serialize(mapOpportunityIdToMID)); 
                    deleteRecordsFromTreasuryV2(setRulesIdsV1);   
            }
        }
        
        if(setActiveInstrumentIds.size() > 0) {
            Set<String> setPricingIds = new Set<String>();
            List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
            for(Pricing__c price : [SELECT Id,Deleted__c,Need_to_Publish__c,Commercial2__c,Commercial2__r.Status__c,Published__c 
                                    FROM Pricing__c WHERE Master_Pricing_Data__c IN :setActiveInstrumentIds AND Deleted__c = true]) {
                                        if(price.Commercial2__r.Status__c == 'Live' && price.Published__c) {
                                            setPricingIds.add(price.Id);    
                                        } 
                                        price.Deleted__c = false;
                                        price.Need_to_Publish__c = true;
                                        listPricingToUpdate.add(price);
                                    }
            
            List<Template_Details__c> listTemplateDetailsToUpdate = new List<Template_Details__c>();
            for(Template_Details__c td : [SELECT Id,Deleted__c FROM Template_Details__c WHERE Master_Pricing_Data__c IN :setInactiveInstrumentIds AND Deleted__c = true]) {
                td.Deleted__c = false;
                listTemplateDetailsToUpdate.add(td);
            }
            if(listTemplateDetailsToUpdate.size() > 0) update listTemplateDetailsToUpdate;
            
            if(listPricingToUpdate.size() > 0) {
                update listPricingToUpdate;
                if(setPricingIds.size() > 0) Database.executeBatch(new PublishPricingToTreasury(setPricingIds),500);  
            }
        }
    }
    
    
    @future(callout=true) 
    public static void deleteRecordsFromTreasury(String mapOpportunityIdToRuleString,String mapOpportunityIdToMIDString) {
    Map<Id,Set<String>>	mapOpportunityIdToRule = (Map<Id,Set<String>>)JSON.deserialize(mapOpportunityIdToRuleString,Map<Id,Set<String>>.class);
    Map<Id,String>	mapOpportunityIdToMID = (Map<Id,String>)JSON.deserialize(mapOpportunityIdToMIDString,Map<Id,String>.class);
    for(Id opportunityId : mapOpportunityIdToRule.keySet()) {
    RemovePricingFromTreasury.deletePricing(String.join(mapOpportunityIdToRule.get(opportunityId),','),mapOpportunityIdToMID.get(opportunityId),opportunityId);
    }
    }
    
    
    @future(callout=true)
    public static void deleteRecordsFromTreasuryV2(Set<String> setRuleIds) {
        RemovePricingFromTreasury.deletePricing(String.join(setRuleIds,','),'-1',null) ;   
    }
}