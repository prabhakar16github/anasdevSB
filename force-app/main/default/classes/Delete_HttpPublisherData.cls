public class Delete_HttpPublisherData implements Database.batchable <sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //String query  = label.HttpPublisherDataDeleteQuery;
        String query = label.HttpPublisherDataDeleteQuery;
        System.debug('query >>' + query );
           return Database.getQueryLocator(query);          
    }    
    public void execute(Database.BatchableContext info, List<LP_HTTP_Publisher__c> scope){
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