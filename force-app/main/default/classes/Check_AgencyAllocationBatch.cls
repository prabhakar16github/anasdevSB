public class Check_AgencyAllocationBatch implements Database.batchable <sObject>{
        
    public Database.QueryLocator start(Database.BatchableContext BC){
         
        String query = label.Agency_Allocation_Query;
        System.debug('query >>' + query );
           return Database.getQueryLocator(query);          
    }    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            List<Case> listToUpdate = new List<Case>();
            System.debug('Inside Scope : ' + scope);
            if(scope.size() >0){
               for(Case obj : scope){
                   /*if(obj.LP_AgencyAllocation_Flag__c  == false){
                       obj.LP_AgencyAllocation_Flag__c = true;
                       listToUpdate.add(obj); 
                   }*/ //POOja
               }
            } 
           database.update(listToUpdate);
        }
        catch(Exception ex){
            System.debug('Exception : ' + ex.getMessage());
         }
    }         
    public void finish(Database.BatchableContext info){
            
    }
}