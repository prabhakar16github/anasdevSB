public class ApprovalRequestAutoApproveSchedule implements Schedulable {
  public void execute(SchedulableContext sc) {
        Set<String> setofAppName = new Set<String>();
        for(String objStr : Label.Account_approval_process_name.split(';')){
            setofAppName.add(objStr);
        }
        String strQuery = 'SELECT Id, ProcessInstance.Id,ProcessInstance.Status,  ProcessInstance.TargetObject.Name, ProcessInstance.ProcessDefinition.Name,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type'; 
                strQuery += ' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.Type= \'Account\' AND ProcessInstance.Status!= \'Approved\' AND ProcessInstance.Status!= \'Rejected\' AND ProcessInstance.ProcessDefinition.Name IN : setofAppName';
        
            Database.executebatch(new ApprovalRequestAutoApproveBatch(strQuery,setofAppName),25);
     }
  }