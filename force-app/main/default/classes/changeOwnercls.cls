public class changeOwnercls {
    public ApexPages.StandardSetController setCon;
    public list<opportunity> opp;
    public changeOwnercls(ApexPages.StandardSetController controller) {
        setCon = controller;  
    }
   public integer getMySelectedSize() {
        
        return setCon.getSelected().size();
    }
    public List<Opportunity> getSelectedOpps(){
        List<Opportunity> selectedOpps = New List<Opportunity>();
        for(Opportunity o : [Select ID,Name,AccountId,Lead_Type__c,Owner.Name,Team_Change_Approval_Status__c,KAM_Change_Approval__c from opportunity where Id IN:setCon.getSelected()]){
            selectedOpps.add(o);
        }
        return selectedOpps;   
    }
    // for approval
    @AuraEnabled(Cacheable = true)
    public static list<Opportunity> getDetailsOnApprovalPage(){
        try {
            Id userId = UserInfo.getUserId();
            return [SELECT Id,Prod_Merchant_Id__c,Name,Owner.Name,New_Opportunity_Owner_Requested__r.Name FROM Opportunity where KAM_Change_Request_Sent_To__r.Id = :userId AND KAM_Change_Approval__c = 'Pending'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
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
			Approval.ProcessResult[] processResults = Approval.process(requests);
            return '0';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
}