/**
* @Class Name   :   PPI_CustomerTriggerHandler
* @Description  :   Handler class for PPI_CustomerTrigger.
* @Auther       :   Prabhakar Joshi
* @Group        :   PPI Customer  
*/
public with sharing class PPI_CustomerTriggerHandler {
    
    /** Method for before insert event. */
    public void beforeInsert(List<PPI_Customer__c> triggerNew){
        /** Calling method to populate the Opportunity with PPI Customer Object. */
        this.populateMerchantFromClientId(triggerNew);
    }
    
    /**
     * Method to populate the Opportunity with PPI Customer Object.
     * @param - List of PPI_Customer__c records coming from trigger event.
     */
    private void populateMerchantFromClientId(List<PPI_Customer__c> triggerNew){
        Map<String,String> clientIdToMIDMap = (Map<String,String>)JSON.deserialize(System.label.PPI_Client_Id_To_MID_Mapping,Map<String,String>.class);
        Map<String,Id> merchantIdMap = new Map<String,Id>();
        
        for(Opportunity opp : [SELECT Id,Name FROM Opportunity WHERE Name IN :clientIdToMIDMap.values()]){
            merchantIdMap.put(opp.Name, opp.Id);
        }
        
        for(PPI_Customer__c co : triggerNew){
            if(String.isNotBlank(co.Client_Id__c)){
                co.Merchant__c = merchantIdMap.get(clientIdToMIDMap.get(co.Client_Id__c));
            }
        }
    }/** END */
}