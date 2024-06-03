public class testingBatch implements Database.Batchable<Sobject>, Database.stateful{
    
 public Database.QueryLocator start(Database.BatchableContext BC){
     string query = 'Select id,status from Contract limit 1';
     return Database.getQueryLocator(query);
 }
    
    public void execute(Database.BatchableContext info, List<Contract> plan){
        /*list<Merchant_Plan__c> listPlan = new List<Merchant_Plan__c>();
        for(Merchant_Plan__c each : plan){
            system.debug('each status==='+ each.status__c);
            each.status__c = 'payment_completed';
           listPlan.add(each);
        }
        update listPlan;*/
        /*
        Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
        String PageName = Label.DocMasterList;
        String PageAssociation;
        List<Document_Master__c> docDetails = [Select Id,Name, Page_Association__c 
                                               FROM Document_Master__c where Page_Association__c = :PageName  order by Page_Association__c];
        List<Contract> AddendumList = new List<Contract>();
        set<String> setAddendumId = new Set<String>();
        String strEndPoint;
        List<Contract> updatedList = new List<Contract>();
        
        
            Contract Addendum = new Contract();
            Addendum.Contract_Type__c = 'Addendum';
            Addendum.Opportunity__c = '0060p000008przlAAA';
            Addendum.AccountId = '0010p00000btOdrAAE';
            Addendum.Name = 'Website Change Addendum';
            Addendum.Status = 'Approved';
            Addendum.Document_Master__c = (docDetails[0] != null) ? docDetails[0].Id : Addendum.Document_Master__c;
            Addendum.Active__c = true;
            Addendum.Document_Category__c = 'a080p00000Lz9dqAAB';
            Addendum.Document_Type__c = 'a0A0p000000j2ywEAA';
            Addendum.Document_Category_Name__c = 'Service Agreement';
            Addendum.Document_Type_Name__c = 'Addendum';
            Addendum.Document_Content_Type__c = mapContentType.get('pdf');
            Addendum.StartDate = date.today();
            Addendum.ContractTerm = 120;
            Addendum.KYC_Documentable_Type__c = 'Merchant';
            
        Insert Addendum;
        */
        
    }
    public void finish(Database.BatchableContext info){
        System.debug('>>>>>Calling Finish Method>>>>>');
        System.enqueueJob(new TestQueueableClass());
        //OpportunityTriggerHandler.sendSettlementStatusToBizTreasury(new Map<Id,String>{},new Map<id, double>{});
    }
}