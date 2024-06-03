/**
* @Name         PricingDataToTempByBakingOpsController 
* @Author       Rohit Gupta
* @Created Date 23-April-2024
* @Description  This class is used to get all the approved records and need to publish field should be true then send it 
to treasury temp table.
*/
public class PricingDataToTempByBakingOpsController {
    public static void afterUpdateHandler(List<Pricing__c> triggerNew,Map<Id,Pricing__c> triggerOldMap){
        try{
            // Created a map to store commercial id and there related pricing records Id
            Map<Id,Set<String>> commPricingMap = new Map<Id,Set<String>>();
            // Collecting relevent pricing records
            for(Pricing__c pricingNew : triggerNew){
                Pricing__c oldPricing = triggerOldMap.get(pricingNew.Id);
                if(pricingNew.Banking_Ops_Status__c != oldPricing.Banking_Ops_Status__c && pricingNew.Banking_Ops_Status__c=='Approved'){
                    Set<String> setPricingIds = new Set<String>();
                    if(commPricingMap.containsKey(pricingNew.Commercial2__c)) {
                        commPricingMap.get(pricingNew.Commercial2__c).add(pricingNew.Id);
                    } 
                    else{
                        commPricingMap.put(pricingNew.Commercial2__c, new Set<String>{pricingNew.Id}); 
                    }
                }
            } 
            // Process collected pricing records in batches
            if(!commPricingMap.isEmpty()){
                for(Id commercialId : commPricingMap.keySet()) {
                    // calling the batch class to send every commercial related pricing records to temp table
                    Database.executeBatch(new PublishPricingToTreasuryTempTable(commPricingMap.get(commercialId)),500);
                }
            }
        }
        catch(Exception e){
            System.debug('An Error Occured ::'+e.getMessage());
        }
    }
}