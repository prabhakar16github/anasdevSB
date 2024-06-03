/*
* Name of the class : BatchClassToRemoveDataFromTreasury
* Author's Name     : Anas Yar Khan  
* Created Date      : 21st Aug, 2023
* Description       : Batch Class to Update Pricing records as Deleted = true
* Version.          : 1   
*/ 
public class BatchClassToRemoveDataFromTreasury implements Database.Batchable<Id>,Database.AllowsCallouts {
    
    /*********************************Member Variables**********************************/
    private Map<Id,Set<String>> mapOpportunityIdToSetOfRuleIds = new Map<Id,Set<String>>();
    private Map<Id,String> mapOpportunityIdToMID = new Map<Id,String>();
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToRemoveDataFromTreasury(Map<Id,Set<String>> mapOpportunityIdToSetOfRuleIds,Map<Id,String> mapOpportunityIdToMID) {
        this.mapOpportunityIdToSetOfRuleIds = mapOpportunityIdToSetOfRuleIds;
        this.mapOpportunityIdToMID = mapOpportunityIdToMID;
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Iterable<Id> start(Database.BatchableContext BC) {
        return new List<Id>(mapOpportunityIdToSetOfRuleIds.keySet());    
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Id> mapKeySet) {
        for(Id opportunityId : mapKeySet) {
            RemovePricingFromTreasury.deletePricing(String.join(mapOpportunityIdToSetOfRuleIds.get(opportunityId),','),mapOpportunityIdToMID.get(opportunityId),opportunityId);
        } 	  
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
    	
    }
    /****************************Finish Method End ********************************/
}