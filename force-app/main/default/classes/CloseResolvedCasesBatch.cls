/*
 Class Name : CloseResolvedCasesBatch
 Description : Batch is used to close the resolved cases after 3 days 
 */ 
public class CloseResolvedCasesBatch implements Database.batchable <sObject>,Database.Stateful,Database.AllowsCallouts{
    
      public Database.QueryLocator start(Database.BatchableContext BC){
        String query = label.Resolved_Since_Query;
          
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            System.debug('Data size :' + scope.size());
            List<Case> casesToUpdate = new List<Case>();            
            for(Case obj : scope){
                if(obj.Status == 'Resolved'){
                   obj.Status = 'Closed';
                   System.debug('Status is REsolved:'); 
                   casesToUpdate.add(obj); 
                }
            }
           Trigger_Switch__c objTriggerSwitch = Trigger_Switch__c.getValues('Case');
           objTriggerSwitch.active__c = false; 
           Database.update(casesToUpdate, false);
           objTriggerSwitch.active__c = true;  
           
        }
        catch(Exception ex){
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'SendEmailBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
    }
    
    public void finish(Database.BatchableContext info){
     
       
    }

}