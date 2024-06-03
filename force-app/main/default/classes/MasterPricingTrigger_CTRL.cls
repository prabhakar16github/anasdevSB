public class MasterPricingTrigger_CTRL {
    public static void primeryKeyUpdateData(List<Master_Pricing_Data__c> masterPricingList,Map<Id,Master_Pricing_Data__c> triggerOldMap){
        // Collect unique parent IDs
        Set<Id> productBundleId = new Set<Id>();
        Map<Id, String> mapOfInActiveMasterIdToKeys = new Map<Id, String>();
        Set<Id> prodBundleIdForChildInactive = new Set<Id>();
        for (Master_Pricing_Data__c masterData : masterPricingList) {
            if(masterData.Active_Instrument__c){
                productBundleId.add(masterData.Product_Bundle_Detail__c);
            }
            else if(!masterData.Active_Instrument__c && masterData.Active_Instrument__c != triggerOldMap.get(masterData.Id).Active_Instrument__c){
                prodBundleIdForChildInactive.add(masterData.Product_Bundle_Detail__c); 
            } 
        }
        if(productBundleId.size()>0){
            List<Product_Bundle_Detail__c> productBundleUpdate = [SELECT Id, Pricing_Info_Json__c FROM Product_Bundle_Detail__c WHERE Id IN :productBundleId];
            // Map to store parent ID and concatenated keys
            Map<Id, String> prodBundleIdToKeys = new Map<Id, String>();
            // Update the map with existing keys
            for (Product_Bundle_Detail__c pbd : productBundleUpdate) {
                prodBundleIdToKeys.put(pbd.Id, pbd.Pricing_Info_Json__c);
            }
            // Update the map with new keys
            for (Master_Pricing_Data__c mpd : masterPricingList) {
                    if (prodBundleIdToKeys.containsKey(mpd.Product_Bundle_Detail__c)) {
                        prodBundleIdToKeys.put(mpd.Product_Bundle_Detail__c, prodBundleIdToKeys.get(mpd.Product_Bundle_Detail__c) + ',' + mpd.Salesforce_Primary_Key__c);
                    } else {
                        prodBundleIdToKeys.put(mpd.Product_Bundle_Detail__c, mpd.Salesforce_Primary_Key__c);
                    } 
            }
            // Update parent records
            List<Product_Bundle_Detail__c> parentsToUpdateFinal = new List<Product_Bundle_Detail__c>();
            for (Id parentId : prodBundleIdToKeys.keySet()) {
                Product_Bundle_Detail__c parent = new Product_Bundle_Detail__c(Id = parentId, Pricing_Info_Json__c = prodBundleIdToKeys.get(parentId));
                parentsToUpdateFinal.add(parent);
            }
            update parentsToUpdateFinal;
        }
        if(prodBundleIdForChildInactive.size()>0){
            List<Product_Bundle_Detail__c> productBundleUpdate = [SELECT Id, Pricing_Info_Json__c FROM Product_Bundle_Detail__c WHERE Id IN :prodBundleIdForChildInactive];
            Map<Id, String> prodBundleIdToKeys = new Map<Id, String>();
            for (Product_Bundle_Detail__c pbd : productBundleUpdate) {
                prodBundleIdToKeys.put(pbd.Id, pbd.Pricing_Info_Json__c);
            }
            for (Master_Pricing_Data__c mpd : masterPricingList) {
                    if (prodBundleIdToKeys.containsKey(mpd.Product_Bundle_Detail__c)) {
                        String[] keys = prodBundleIdToKeys.get(mpd.Product_Bundle_Detail__c).split(',');
                        List<String> updatedKeys = new List<String>();
                        for (String key : keys) {
                            if (!key.equals(mpd.Salesforce_Primary_Key__c)) {
                                updatedKeys.add(key);
                            }
                        }
                        prodBundleIdToKeys.put(mpd.Product_Bundle_Detail__c, String.join(updatedKeys, ','));
                    }
            }
            List<Product_Bundle_Detail__c> parentsToUpdateFinal = new List<Product_Bundle_Detail__c>();
            for (Id parentId : prodBundleIdToKeys.keySet()) {
                Product_Bundle_Detail__c parent = new Product_Bundle_Detail__c(Id = parentId, Pricing_Info_Json__c = prodBundleIdToKeys.get(parentId));
                parentsToUpdateFinal.add(parent);
            }
            update parentsToUpdateFinal;
        }
    }
}