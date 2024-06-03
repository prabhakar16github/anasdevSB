public class Delete_PayloadLogsData implements Database.batchable <sObject> {

        public Database.QueryLocator start(Database.BatchableContext BC){
        String query  = label.PayloadLogDataDeleteQuery;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext info, List<Payload_Log__c> scope){
        try{
            System.debug('Inside Scope : ' + scope);
            if(scope.size() >0){
              database.delete(scope,false);  
            }            
        }
        catch(Exception ex){
             System.debug('Exception : ' + ex.getMessage());
        }
    }    
    public void finish(Database.BatchableContext info){
            
    }
}