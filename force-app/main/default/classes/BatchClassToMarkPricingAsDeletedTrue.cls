/*
* Name of the class : BatchClassToMarkPricingAsDeletedTrue
* Author's Name     : Anas Yar Khan  
* Created Date      : 21st Aug, 2023
* Description       : Batch Class to Update Pricing records as Deleted = true
* Version.          : 1   
*/ 
global class BatchClassToMarkPricingAsDeletedTrue implements Database.Batchable<sObject>,Database.Stateful {
    
    /*********************************Member Variables**********************************/
    private String masterPricingDataRecordId = '';
    global Map<Id,Set<String>> mapOpportunityIdToSetOfRuleIds = new Map<Id,Set<String>>();
    global Map<Id,String> mapOpportunityIdToMID = new Map<Id,String>();
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToMarkPricingAsDeletedTrue(String masterPricingDataRecordId) {
        this.masterPricingDataRecordId = masterPricingDataRecordId;
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Commercial2__c,Commercial2__r.Status__c,Opportunity__c,';
        query += 'Opportunity__r.Prod_MID__c,Deleted__c,Published__c,Need_to_Publish__c,Deleted_By_Instrument_as_Inactive__c,';
        query += 'Unpublished_by_Instrument_as_Inactive__c FROM Pricing__c WHERE Master_Pricing_Data__c = \''+masterPricingDataRecordId+'\' AND Deleted__c = false';
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Pricing__c> listRecordsToUpdate) {
        Savepoint sp = Database.setSavepoint();
        try {
            for(Pricing__c price : listRecordsToUpdate) {
                mapOpportunityIdToMID.put(price.Opportunity__c,price.Opportunity__r.Prod_MID__c);
                if(price.Commercial2__r.Status__c == 'Live' && price.Published__c) {
                    Set<String> setRuleIds = new Set<String>();
                    if(mapOpportunityIdToSetOfRuleIds.containsKey(price.Opportunity__c)) setRuleIds = mapOpportunityIdToSetOfRuleIds.get(price.Opportunity__c);
                    if(String.isNotBlank(price.Rule_Id__c)) setRuleIds.add(price.Rule_Id__c);
                    if(String.isNotBlank(price.Rule_Id_Conv__c)) setRuleIds.add(price.Rule_Id_Conv__c);
                    mapOpportunityIdToSetOfRuleIds.put(price.Opportunity__c,setRuleIds);
                    price.Unpublished_by_Instrument_as_Inactive__c = true;
                }
                price.Deleted__c = true;
                price.Need_to_Publish__c = false;
                price.Rule_Id__c = '';
                price.Rule_Id_Conv__c = '';
                price.Published__c = false;
                price.Deleted_By_Instrument_as_Inactive__c = true;
            }
            
            update listRecordsToUpdate;
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToMarkPricingAsDeletedTrue',Message__c = e.getMessage(),SF_Record_Name__c  = masterPricingDataRecordId,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        //TODO - Change the batch size 
    	Database.executeBatch(new BatchClassToRemoveDataFromTreasury(mapOpportunityIdToSetOfRuleIds,mapOpportunityIdToMID),1);	
    }
    /****************************Finish Method End ********************************/
}