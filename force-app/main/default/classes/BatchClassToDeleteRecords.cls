/*
 * Name of the class : BatchClassToDeleteRecords
 * Author's Name     : Anas Yar Khan  
 * Created Date      : 25th Aug, 2022
 * Description       : Generic batch class to delete the data
 * Version.          : 1   
 */ 
public class BatchClassToDeleteRecords implements Database.Batchable<sObject> {
    
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private Map<String,String> mapObjectAPINameToDeleteQuery = new Map<String,String>();
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
     * objectAPIName : This parameter receive the API Name of the Object
     */ 
    public BatchClassToDeleteRecords(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Query_To_Delete_records__c
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true LIMIT 50000]) mapObjectAPINameToDeleteQuery.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord.Query_To_Delete_records__c);    
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(mapObjectAPINameToDeleteQuery.containsKey(objectAPIName)) {
            query = mapObjectAPINameToDeleteQuery.get(objectAPIName);
        }
        if(String.isNotBlank(query)) return Database.getQueryLocator(query);
        else return NULL;
    }
    /****************************Start Method End*************************************/
     
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listRecordsToDelete) {
    	Savepoint sp = Database.setSavepoint();
        try {
            delete listRecordsToDelete;
        }
        catch(Exception e) {
            SYstem.debug('e:::'+e.getMessage());
        	Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToDeleteRecords',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
			
            insert errorDetails;
        }
    }   
    /****************************Execute Method End*********************************/ 
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}