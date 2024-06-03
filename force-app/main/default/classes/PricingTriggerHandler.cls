/*
* Name of the Class   : PricingTriggerHandler
* Author's Name       : Anas Yar Khan  
* Description         : Handler class for PricingTrigger
* Version.            : 1  
*/
public class PricingTriggerHandler {
    
    /*
* Name of the function   : afterUpdate
* Author's Name          : Anas Yar Khan  
* Description            : This method will call on the after update event
* Version.            : 1  
*/
    public static void afterUpdate(List<Pricing__c> triggerNew,Map<Id,Pricing__c> triggerOldMap) {
        List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
        for(Pricing__c pricing : triggerNew) {
            if(pricing.Fee_Model__c != triggeroldMap.get(pricing.Id).Fee_Model__c 
               || pricing.Transaction_Type__c != triggeroldMap.get(pricing.Id).Transaction_Type__c 
               || pricing.TDR__c != triggerOldMap.get(pricing.Id).TDR__c
               || pricing.TDR_Amount__c != triggerOldMap.get(pricing.Id).TDR_Amount__c 
               || pricing.TDR_Flat_Fee__c != triggerOldMap.get(pricing.Id).TDR_Flat_Fee__c
               || pricing.Convenience__c != triggerOldMap.get(pricing.Id).Convenience__c
               || pricing.Convenience_Amount__c != triggerOldMap.get(pricing.Id).Convenience_Amount__c 
               || pricing.Convenience_Flat_Fee__c != triggerOldMap.get(pricing.Id).Convenience_Flat_Fee__c) {
                   Pricing__c pricingDummy = new Pricing__c();
                   pricingDummy.Id = pricing.Id;
                   pricingDummy.Need_to_Publish__c = true;
                   listPricingToUpdate.add(pricingDummy);
               }
        }
        
        if(listPricingToUpdate.size() > 0) update listPricingToUpdate;    
    }
}