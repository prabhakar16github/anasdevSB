global class ApprovalRequestAutoApproveBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String strQuery;
    public Set<String> setOfAppName;
    
    public ApprovalRequestAutoApproveBatch(String strquery,Set<String> setofAppName){
        this.strQuery = strquery;
        this.setOfAppName = setofAppName;
        this.strQuery += ' AND ProcessInstance.ProcessDefinition.Name IN : setOfAppName';
        system.debug('=====strQuery======'+strQuery);
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
         
        /*return Database.getQueryLocator([SELECT Id, ProcessInstance.Id,ProcessInstance.Status,  ProcessInstance.TargetObject.Name, ProcessInstance.ProcessDefinition.Name,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type 
                               FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.Type='Account' AND ProcessInstance.Status!= 'Approved' AND ProcessInstance.Status!= 'Rejected' AND 
                               ProcessInstance.ProcessDefinition.Name IN : setofapprovalPname]);
        */
        system.debug('=====strQuery======'+strQuery);
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.BatchableContext info, List<ProcessInstanceWorkitem> lstProcessIns){
        for(ProcessInstanceWorkitem objPI :lstProcessIns){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Approved by SaasFocus Admin');
                req.setAction('Approve');        
                req.setWorkitemId(objPI.Id);
                try{
                    Approval.ProcessResult result =  Approval.process(req);
                }                            
                catch(exception e){
                    Error_Details__c objErrorLog = new Error_Details__c(Message__c = 'MESSAGE: '+ e.getMessage() + '\n\n', Request__c = 'ApprovalRequestAutoApproveBatch',
                    Process__c = objPI.ProcessInstance.Id, StackTrace__c = 'STACK TRACE: '+ e.getStackTraceString());
                    insert objErrorLog ;
                    system.debug('ProcessInstance.Id'+objPI.ProcessInstance.Id);
                }
        }
    }
    
    global void finish(Database.BatchableContext info){
    
    }
}