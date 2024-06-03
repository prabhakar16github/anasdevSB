public class BulkTeamChangeApprovalController {
    public ApexPages.StandardSetController setCon;
    public list<opportunity> opp;
    public BulkTeamChangeApprovalController(ApexPages.StandardSetController controller) {
        setCon = controller;  
    }
   public integer getMySelectedSize() {
        
        return setCon.getSelected().size();
    }
    // for request
    public List<Opportunity> getSelectedOpps(){
        List<Opportunity> selectedOpps = New List<Opportunity>();
        for(Opportunity o : [Select ID,Prod_Merchant_Id__c,Merchant_Business_Type__c,Team__c,New_Merchant_Business_Type_Requested__c,New_Team_Requested__c,KAM_Change_Approval__c,Team_Change_Approval_Status__c from opportunity where Id IN:setCon.getSelected()]){
            selectedOpps.add(o);
        }
        //selectedOpps = (List<Opportunity>)setCon.getSelected();
        return selectedOpps;
        
    }
    // for approval
    @AuraEnabled(Cacheable = true)
    public static list<Opportunity> getDetailsOnApprovalPage(){
        try {
            Id userId = UserInfo.getUserId();
            return [SELECT Id,Prod_Merchant_Id__c,Name,Team__c,Merchant_Business_Type__c,New_Team_Requested__c,New_Merchant_Business_Type_Requested__c FROM Opportunity where Team_Change_Requested_To__r.Id=:userId AND Team_Change_Approval_Status__c='Pending'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //removed cacheable = true below // getSelectedOppsFromLWC
    @AuraEnabled
    public static String actionOnSelectedOppsFromLWC(String recordIds,String response){
        try {
            List<String> lstrecordIds = recordIds.split(',');
            List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId IN :lstrecordIds 
            ];
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            
            for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction(response);
                req.setComments('');
                requests.add(req);
            }

			Approval.ProcessResult[] processResults = Approval.process(requests);return '0';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}