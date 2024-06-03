/*
* Name of the class : BatchClassToMarkPricingAsDeletedFalse
* Author's Name     : Anas Yar Khan  
* Created Date      : 21st Aug, 2023
* Description       : Batch Class to Update Pricing records as Deleted = false
* Version.          : 1   
*/ 
global class BatchClassToMarkPricingAsDeletedFalse implements Database.Batchable<sObject>,Database.Stateful {
    
    /*********************************Member Variables**********************************/
    private String masterPricingDataRecordId = '';
    private Set<String> setPricingIds = new Set<String>();
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToMarkPricingAsDeletedFalse(String masterPricingDataRecordId) {
        this.masterPricingDataRecordId = masterPricingDataRecordId;
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Commercial2__c,Commercial2__r.Status__c,Opportunity__c,';
        query += 'Opportunity__r.Prod_MID__c,Deleted__c,Published__c,Need_to_Publish__c,Deleted_By_Instrument_as_Inactive__c,';
        query += 'Unpublished_by_Instrument_as_Inactive__c FROM Pricing__c WHERE Master_Pricing_Data__c = \''+masterPricingDataRecordId+'\' AND Deleted_By_Instrument_as_Inactive__c = true';
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Pricing__c> listRecordsToUpdate) {
        Savepoint sp = Database.setSavepoint();
        try {
            for(Pricing__c price : listRecordsToUpdate) {
                if(price.Commercial2__r.Status__c == 'Live' && price.Unpublished_by_Instrument_as_Inactive__c) {
                    setPricingIds.add(price.Id);    
                } 
                price.Deleted__c = false;
                price.Need_to_Publish__c = true;
                price.Unpublished_by_Instrument_as_Inactive__c = false;
                price.Deleted_By_Instrument_as_Inactive__c = false;
            }
            
            update listRecordsToUpdate;
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToMarkPricingAsDeletedFalse',Message__c = e.getMessage(),SF_Record_Name__c  = masterPricingDataRecordId,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new PublishPricingToTreasury(setPricingIds),100);
    }
    /****************************Finish Method End ********************************/
}