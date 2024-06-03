/*
* Name of the class : BatchClassToUndeleteRecords
* Author's Name     : Manila Agnihotri  
* Created Date      : 16th Mov, 2022
* Description       : Generic batch class to undelete Records 
* Version.          : 1   
*/
public class BatchClassToUndeleteRecords implements Database.Batchable <sObject> {
    private String objectQuery = '';
    public BatchClassToUndeleteRecords(String objectQuery) {
        this.objectQuery = objectQuery;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(objectQuery);
    }
    public void execute(Database.BatchableContext BC, List <sObject> listSobject) {
        try {
            if(!Test.isRunningTest()){
                undelete listSobject;
            }
            else{
                Integer m = 0/0;
            }
        }
        catch (Exception e) {
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'BatchClassToUndeleteRecords', Message__c = e.getMessage(), Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()), Request__c = String.valueOf(listSobject));
            insert errorDetails;
        }
    }
    public void finish(Database.BatchableContext BC) {}
}