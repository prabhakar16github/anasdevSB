/*
* Name of the class : PublishPricingToTreasuryTempTable
* Author's Name     : Anas Yar Khan  
* Created Date      : 12th March, 2024
* Description       : Batch class to push the pending pricing records to Treasury
* Version.          : 1   
*/ 
public class PublishPricingToTreasuryTempTable implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    /*********************************Member Variables**********************************/
    private String commId;
    private Set<String> pricingIds;
    private static FINAL String PROCESS_NAME = 'SaveBulkRules-CheckerFalseActionSave';
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor 1***************************************
	* @param - commercialId 
	* @param type - String 
	* Calling from Pricing screen   
	*/
    public PublishPricingToTreasuryTempTable(String commercialId){
        this.commId = commercialId;
    }
    /********************************Constructor 1 End***************************************
    
	/********************************Constructor 2***************************************
	* @param - pricingIdSet
	* @param type - Set<String> 
	* Calling from Banking Ops screen
	*/
    public PublishPricingToTreasuryTempTable(Set<String> pricingIdSet){
        this.pricingIds = pricingIdSet;
    }
    /********************************Constructor 2 End***************************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Set<String> statusValues = new Set<String>{'Pending with KAM','Pending with Banking ops','Pending with Bank','Pending with BH'};
        Set<String> statusValues = new Set<String>{'Approved','Approved with BH'};
		String STATUS_PUBLISHED = 'Live';
        String query = PublishPricingUtility.query;
        if(commId != NULL){
            query += 'WHERE Commercial2__c = :commId ';
        }else if(pricingIds != NULL && !pricingIds.isEmpty()){
            query += 'WHERE Id IN :pricingIds AND Commercial2__r.Status__c = :STATUS_PUBLISHED ';
        }
        query += 'AND Banking_Ops_Status__c IN :statusValues AND Deleted__c = false AND Need_To_Publish__c = true';
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*****************************************/
    
    /****************************Execute Method*****************************************/
    public void execute(Database.BatchableContext BC, List<Pricing__c> listPricing){
        PublishPricingUtility.processTheRequest(listPricing,'save','API_Callout_SaveBulkRulesCF',PROCESS_NAME,false);
    }
    /****************************Execute Method End*****************************************/
    
    /****************************Finish Method*****************************************/
    public void finish(Database.BatchableContext BC){
        
    }
    /****************************Finish Method End*****************************************/
}