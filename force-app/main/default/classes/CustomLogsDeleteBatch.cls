public class CustomLogsDeleteBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Batch_Setting__mdt batchSetting = New Batch_Setting__mdt();
    public string sObjData ='';
    public CustomLogsDeleteBatch(string sObjectName){
        this.sObjData = sObjectName;
        batchSetting = [Select Id, Fields_To_Query__c, Record_Limit__c,Where_Clause__c from Batch_Setting__mdt where DeveloperName=:'CustomLogsDeleteBatch' LIMIT 1];
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        string queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' FROM '+sObjData;
        queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ?  ' Where '+batchSetting.Where_Clause__c : '';        
        queryResult += ' ORDER BY LastModifiedDate ASC';
        queryResult += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
        return Database.getQueryLocator(queryResult);        
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}