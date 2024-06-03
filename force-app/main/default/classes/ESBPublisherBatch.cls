public with sharing class ESBPublisherBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts, Database.stateful{
    
    public List<Sobject> newList;
    public Map<Id, Sobject> oldMap;
    
    public Boolean isInsert = false;
    public Boolean isUpdate = false;
    public Boolean isDelete = false;
    public Boolean isTriggerExecuting = false;
    public String sobName;           
    public String payLoadSobName;   
    
    public ESBPublisherBatch(List<Sobject> theNewList, Map<Id, Sobject> theOldMap, Boolean triggerExecuting, Boolean insertTgr, Boolean updateTgr, Boolean deleteTgr, String theSobName, String thePayLoadSobName){
        
        newList = theNewList;
        oldMap = theOldMap;
        
        isInsert = insertTgr;
        isUpdate = updateTgr;
        isDelete = deleteTgr;
        isTriggerExecuting = triggerExecuting;
        
        sobName = theSobName; 
        payLoadSobName = thePayLoadSobName;       
    }
   
    public Iterable<SObject> start(Database.BatchableContext BC){
        return newList;
    }
    
    public void execute(Database.BatchableContext info, List<SObject> listToProcess){
        
        IntegrationUtility.isInsert = isInsert;
        IntegrationUtility.isUpdate = isUpdate;
        IntegrationUtility.isDelete = isDelete;  
        IntegrationUtility.isTriggerExecuting = isTriggerExecuting;  
        
        for(Sobject each : listToProcess){
            Sobject newSob = isDelete ? null : each;
            Sobject oldSob = !isDelete ? isInsert ? null : oldMap.get(each.Id) : each;            
            IntegrationUtility.sendPayLoadData(newSob, oldSob, sobName, payLoadSobName);
        }
        
        if(!IntegrationUtility.logList.isEmpty()) Database.insert(IntegrationUtility.logList, false);      
    }
    
    public void finish(Database.BatchableContext info){}
    
    public static void sendDataInBatch(String sobName, String payLoadSobName){
        System.debug('System.isBatch() ==> '+System.isBatch());
        if(Trigger.isExecuting && Trigger.isAfter && (AWSConsumerBatch.isFinishExecuted || !System.isBatch()) && !System.isFuture()){
            Database.executeBatch(new ESBPublisherBatch(Trigger.isDelete ? Trigger.old : Trigger.new, Trigger.isUpdate ? Trigger.oldMap : null, Trigger.isExecuting, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, sobName, payLoadSobName), 50);
        }
    }     
}