/*
* Name of the class : PublishPricingToTreasuryTempTableApprove
* Author's Name     : Anas Yar Khan  
* Created Date      : 12th March, 2024
* Description       : Batch class to push the pending pricing records to Treasury into Main table after approval
* Version.          : 1   
*/ 
public class PublishPricingToTreasuryTempTableApprove implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    /*********************************Member Variables**********************************/
    private String commId;
    private Set<String> pricingIds;
    private String processName = '';
    private Boolean isDeleteRequest = false;
    //private static FINAL String PROCESS_NAME = 'SaveBulkRules-CheckerTrueActionApprove'; update request
    //private static FINAL String PROCESS_NAME = 'DeleteBulkRules-CheckerTrueActionApproveDelete'; Delete request
    /*********************************Member Variables End**********************************/
    
    /********************************Constructor 1***************************************
	* @param - commercialId 
	* @param type - String 
	* Calling from Pricing screen   
	*/
    public PublishPricingToTreasuryTempTableApprove(String commercialId,String processName,Boolean isDeleteRequest){
        this.commId = commercialId;
        this.processName = processName;
        this.isDeleteRequest = isDeleteRequest;
    }
    /********************************Constructor 1 End***************************************/
    
    /********************************Constructor 2***************************************
	* @param - pricingIdSet
	* @param type - Set<String> 
	* Calling from Banking Ops screen
	*/
    public PublishPricingToTreasuryTempTableApprove(Set<String> pricingIdSet,String processName,Boolean isDeleteRequest){
        this.pricingIds = pricingIdSet;
        this.processName = processName;
        this.isDeleteRequest = isDeleteRequest;
    }
    /********************************Constructor 2 End***************************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = PublishPricingUtility.query;
        if(this.isDeleteRequest){
            query += 'WHERE Id IN :pricingIds AND (Temp_Id_Delete_TDR__c != NULL OR Temp_Id_Delete_Conv__c != NULL) AND Deleted__c = false';
        }else{
            //Set<String> statusValues = new Set<String>{'Pending with KAM','Pending with Banking ops','Pending with Bank','Pending with BH'};
            
            String STATUS_PUBLISHED = 'Live';
            
            if(commId != NULL){
                query += 'WHERE Commercial2__c = :commId ';
            }else if(pricingIds != NULL && !pricingIds.isEmpty()){
                //query += 'WHERE Id IN :pricingIds ';//AND Commercial2__r.Status__c = :STATUS_PUBLISHED ';
                query += 'WHERE Id IN :pricingIds AND Commercial2__r.Status__c = :STATUS_PUBLISHED ';
            }
            //query += 'AND Banking_Ops_Status__c IN :statusValues AND Deleted__c = FALSE';// AND Need_To_Publish__c = TRUE AND Published__c = false';
            query += 'AND Deleted__c = false';
        }
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*****************************************/
    
    /****************************Execute Method*****************************************/
    public void execute(Database.BatchableContext BC, List<Pricing__c> listPricing){
        if(this.isDeleteRequest){
            PublishPricingUtility.processTheRequest(listPricing,'approveDelete','API_Callout_SaveBulkRulesCT',this.processName,true,true);
        }else{
            PublishPricingUtility.processTheRequest(listPricing,'approve','API_Callout_SaveBulkRulesCT',this.processName,true,false);
        }
        
    }
    /****************************Execute Method End*****************************************/
    
    /****************************Finish Method*****************************************/
    public void finish(Database.BatchableContext BC){
        
    }
    /****************************Finish Method End*****************************************/
}