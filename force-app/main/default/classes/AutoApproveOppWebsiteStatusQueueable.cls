public class AutoApproveOppWebsiteStatusQueueable implements Queueable,Database.AllowsCallouts{
	
    //Opportunity newOpp = New Opportunity();
    //Opportunity oldOpp = New Opportunity();
    List<Opportunity> optyList = new List<Opportunity>();
    
    /*public AutoApproveOppWebsiteStatusQueueable(Opportunity eachOpp, Opportunity oldEachOpp){
        this.newOpp = eachOpp;
        this.oldOpp = oldEachOpp;
    }*/
    
    public AutoApproveOppWebsiteStatusQueueable(List<Opportunity> enqueueList){
        this.optyList = enqueueList;
    }
    
    public void execute(QueueableContext context){
        List<Opportunity> updateableOpportunities = new List<Opportunity>();
        /*system.debug('######## 1 '+this.newOpp);
        if(this.newOpp != null){
            if(!this.newOpp.Re_Published__c) newOpp.Re_Published__c = true;
            else this.newOpp.Re_Published__c = false;
            //IntegrationUtility.sendPayLoadData(this.newOpp, this.oldOpp, 'Opportunity', 'Lead');
            update this.newOpp;
        }
        system.debug('######## 2 '+this.newOpp);*/
        
        //for bulk
        if(!this.optyList.isEmpty() && this.optyList != null){
            for(Opportunity opp : optyList){
                    opp.Risk_Level__c = 'High-Auto Approved';
                    opp.Website_Status__c = 'Website OK';
                	updateableOpportunities.add(opp);
                }
            }
        update updateableOpportunities;
        }
}