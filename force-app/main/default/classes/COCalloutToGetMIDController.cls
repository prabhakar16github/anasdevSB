public class COCalloutToGetMIDController {
    //private Set<Id> leadIds;
    private Id leadId;
    //private Integer batchSize;

    public COCalloutToGetMIDController(ApexPages.StandardController controller) {
       // leadIds = new Set<Id>();
        //batchSize = 50;
        leadId = controller.getId();
    }

    public void executeBatch() {

        //System.debug('leadIds : '+leadIds);
        
        /*if(leadIds.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No lead records selected'));
            return;
        }*/
        if(leadId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No lead records selected'));
            return;
        }
        
        //Set<Id> leadIds = new Set<Id>();
        List<Id> leadIds = new List<Id>();
        leadIds.add(leadId);
        
       System.debug('leadIds>>>>>>'+leadIds);
        
        /*List<Lead> leads = [SELECT Id, Name, Email, MobilePhone, FirstName, Product__c, Select_Product__c
                           FROM Lead
                           WHERE Id IN : leadIds];*/

        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIds, 1);
        Database.executeBatch(batch);
        
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch process initiated.'));
    }
}