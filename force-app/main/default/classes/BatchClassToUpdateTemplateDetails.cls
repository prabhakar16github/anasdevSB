/*
* Name of the class : BatchClassToUpdateTemplateDetails
* Author's Name     : Anas Yar Khan  
* Created Date      : 21st Aug, 2023
* Description       : Batch Class to Update Template details as Active/Inactive
* Version.          : 1   
*/ 
public class BatchClassToUpdateTemplateDetails implements Database.Batchable<sObject> {
    
    /*********************************Member Variables**********************************/
    private String masterPricingDataRecordId = '';
    private Boolean currentStatus = false;
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToUpdateTemplateDetails(String masterPricingDataRecordId,Boolean currentStatus) {
        this.masterPricingDataRecordId = masterPricingDataRecordId;
        this.currentStatus = currentStatus;
        
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Deleted__c FROM Template_Details__c WHERE Master_Pricing_Data__c = \''+masterPricingDataRecordId+'\'';
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Template_Details__c> listRecordsToUpdate) {
        Savepoint sp = Database.setSavepoint();
        try {
            for(Template_Details__c td : listRecordsToUpdate) {
            	if(currentStatus) td.Deleted__c = true;
                else td.Deleted__c = false;
            }   
            
            update listRecordsToUpdate;
        }
        catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToUpdateTemplateDetails',Message__c = e.getMessage(),SF_Record_Name__c  = masterPricingDataRecordId,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}