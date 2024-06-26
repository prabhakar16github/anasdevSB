/*
* Name of the class : PublishPricingToTreasuryTempTableReject
* Author's Name     : Anas Yar Khan  
* Created Date      : 12th March, 2024
* Description       : Batch class to reject the pending pricing records from Temp table of Treasury
* Version.          : 1   
*/ 
public class PublishPricingToTreasuryTempTableReject implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    /*********************************Member Variables**********************************/
    private String commId;
    private Set<String> pricingIds;
    private String PROCESS_NAME = 'SaveBulkRules-CheckerTrueActionReject';
    private Set<Id> setPricingIds = new Set<Id>();
    /*********************************Member Variables End**********************************/
    
    /********************************Constructor 1***************************************
    * @param - commercialId 
    * @param type - String 
    * Calling from Pricing screen   
    */
    public PublishPricingToTreasuryTempTableReject(String commercialId){
        this.commId = commercialId;
    }
    /********************************Constructor 1 End***************************************/
    
    /********************************Constructor 2***************************************
    * @param - pricingIdSet
    * @param type - Set<String> 
    * Calling from Banking Ops screen
    */
    public PublishPricingToTreasuryTempTableReject(Set<String> pricingIdSet){
        this.pricingIds = pricingIdSet;
    }
    /********************************Constructor 2 End***************************************/
    
    /********************************Constructor 3***************************************
    * @param - commercialId & processName = SaveBulkRules-CheckerTrueActionRejectDelete
    * @param type - String & String
    * Calling from Pricing screen   
    */
    public PublishPricingToTreasuryTempTableReject(String commercialId,String processName){
        this.commId = commercialId;
        this.PROCESS_NAME = processName;
    }
    /********************************Constructor 3 End***************************************/
    
    /********************************Constructor 4***************************************
    * @param - pricingIdSet
    * @param type - Set<String> 
    * Calling from Banking Ops screen
    */
    public PublishPricingToTreasuryTempTableReject(Set<String> pricingIdSet,String processName){
        this.pricingIds = pricingIdSet;
        this.PROCESS_NAME = processName;
    }
    /********************************Constructor 4 End***************************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Set<String> statusValues = new Set<String>{'Pending with KAM','Pending with Banking ops','Pending with Bank','Pending with BH'};
        String STATUS_PUBLISHED = 'Live';
        String query = PublishPricingUtility.query;
        if(commId != NULL){
            query += 'WHERE Commercial2__c = :commId ';
        }else if(pricingIds != NULL && !pricingIds.isEmpty()){
            //query += 'WHERE Id IN :pricingIds ';//AND Commercial2__r.Status__c = :STATUS_PUBLISHED ';
            query += 'WHERE Id IN :pricingIds AND Commercial2__r.Status__c = :STATUS_PUBLISHED ';
        }
        //query += 'AND Banking_Ops_Status__c IN :statusValues';// AND Deleted__c = FALSE AND Need_To_Publish__c = TRUE AND Published__c = false';
        query += 'AND Deleted__c = false';
        
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*****************************************/
    
    /****************************Execute Method*****************************************/
    public void execute(Database.BatchableContext BC, List<Pricing__c> listPricing){
        for(Pricing__c pricing : listPricing) setPricingIds.add(pricing.Id);
        PublishPricingUtility.processTheRequest(listPricing,'reject','API_Callout_SaveBulkRulesCT',PROCESS_NAME,true);
    }
    /****************************Execute Method End*****************************************/
    
    /****************************Finish Method*****************************************/
    public void finish(Database.BatchableContext BC){
        if(PROCESS_NAME == 'SaveBulkRules-CheckerTrueActionRejectDelete') {
            Set<String> setRuleIds = new Set<String>();
            String commercialId = '';
            String opportunityId = '';
            Integer count = 0;
            for(Pricing__c price : [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Commercial2__r.Opportunity__c,Commercial2__c
                                    FROM Pricing__c 
                                    WHERE Id IN : setPricingIds 
                                    AND (Rule_Id__c != NULL OR Rule_Id_Conv__c != NULL)]) {
                                        if(count == 0) {
                                            opportunityId = price.Commercial2__r.Opportunity__c;
                                            commercialId = price.Commercial2__c;
                                            count = 1;
                                        }
                                        if(String.isNotBlank(price.Rule_Id__c)) setRuleIds.add(price.Rule_Id__c);
                                        if(String.isNotBlank(price.Rule_Id_Conv__c)) setRuleIds.add(price.Rule_Id_Conv__c);
                                    }
            if(setRuleIds.size() > 0 && String.isNotBlank(commercialId) && String.isNotBlank(opportunityId)) {
                String ruleIds = '[';
                for(String ruleId : setRuleIds) {
                    ruleIds += '\"'+ruleId+'\",';
                }
                ruleIds = ruleIds.removeEnd(',');
                ruleids += ']';
                RemovePricingFromTreasuryNew.deletePricing(ruleIds,commercialId,opportunityId);		    
    
            }
        }	    
    }
    /****************************Finish Method End*****************************************/
}