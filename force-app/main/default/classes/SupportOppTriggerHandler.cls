public class SupportOppTriggerHandler {
    public static void beforeInsertHandler(List<Opportunity> triggerNew){}
    public static void beforeUpdateHandler(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id, Opportunity>  TriggerNewMap){
        }
    public static void afterInsertHandler(List<Opportunity> triggerNew){}
    public static void afterUpdateHandler(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap){
        
        Map<String,Opportunity> mapParentIdChildOpp = new Map<String,Opportunity>();
        
        for(Opportunity eachOpp : triggerNew){
            Opportunity oldOpp = triggerOldMap.get(eachOpp.Id);
            if(eachOpp.Website__c != null && eachOpp.Website__c != '' && eachOpp.Website__c != oldOpp.Website__c){
                mapParentIdChildOpp.put(eachOpp.Parent_Opportunity__c, eachOpp);
            }
        }
        
        
        if(!mapParentIdChildOpp.isEmpty()){
            updateParentOpportunity(mapParentIdChildOpp);
        }
    }
        
    
    public static void updateParentOpportunity(Map<String,Opportunity> mapParentIdChildOpp){
        
        List<Opportunity> parentOppUpdateList = new List<Opportunity>();
        Set<String> setofAccId = new Set<String>();
        map<String,List<Contract>> mapAccountwithContract = new map<String,List<Contract>>();
        List<Opportunity> oppList = [Select id, website__c,New_Website_Url__c,AccountId,VFPageKey__c ,Agreement_Regeneration__c ,Account.Agreement_Status__c, Account.Document_Status__c from Opportunity where id in :mapParentIdChildOpp.keySet()];
        Map<String,String> mapofContractWithopport = new Map<String,String>();
        Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();
        Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
        Set<opportunity> parentOpportunityList = new Set<opportunity>();
        List<Opportunity>  approvedOpportunityList = new List<Opportunity>();
        Set<String> updatedWebsiteURLoppIds = new Set<String>(); 
        Set<String> setproducerName = new Set<String>{'MerchantOnboarding'};
        
        
        for(Opportunity parentOpp : oppList){
            
            setofAccId.add(parentOpp.AccountId);
            /*if(parentOpp.Account.Agreement_Status__c != 'Approved' && parentOpp.Account.Agreement_Status__c != 'Counter Signed Received')
            	parentOpp.New_Website_Url__c = mapParentIdChildOpp.get(parentOpp.Id).website__c;
            else
                parentOpp.Website__c = mapParentIdChildOpp.get(parentOpp.Id).website__c;
            parentOppUpdateList.add(parentOpp);*/
            
        }
        
        if(!setofAccId.isEmpty()) OpportunityTriggerHandler.getContractfromAccount(setofAccId, mapAccountwithContract);
        
        for(opportunity eachOpp : oppList){
                
                if(eachOpp.AccountId != null && mapAccountwithContract.containsKey(eachOpp.AccountId) 
                   && mapAccountwithContract.get(eachOpp.AccountId) != null
                   && !mapAccountwithContract.get(eachOpp.AccountId).isEmpty()){
                       String VfpageName ='';
                       if(eachOpp.VFPageKey__c != null && VFPageWithData__c.getValues(eachOpp.VFPageKey__c) != null){
                           VfpageName = VFPageWithData__c.getValues(eachOpp.VFPageKey__c).VFPageName__c ;
                       }
                       if(Test.isRunningTest()) VfpageName = 'payUmoney-Merchant';
                       for(Contract objContract : mapAccountwithContract.get(eachOpp.AccountId)){
                           if((objContract.Status == 'Pending' || objContract.Status == 'Sent') && VfpageName != '' && objContract.Active__c == false
                              && eachOpp.Agreement_Regeneration__c){
                                  mapofContractWithopport.put(objContract.Id,eachOpp.Id); 
                                  mapOfIdContract.put(objContract.Id,objContract);
                                  mapofContractWithAgreementVFpage.put(objContract.Id,VfpageName);
                                  objContract.URL__c ='';
                                  objContract.Upload_Date__c = System.today();
                                  Break;
                              }
                           else if(objContract.Status == 'Approved Activate' || objContract.Status == 'Approved' || objContract.Status == 'Counter Signed Received'){
                               parentOpportunityList.add(eachOpp);
                           }
                       }
                       if(!mapofContractWithopport.isEmpty()) {
                           eachOpp.Website__c = mapParentIdChildOpp.get(eachOpp.Id).website__c;
                           parentOppUpdateList.add(eachOpp);
                           updatedWebsiteURLoppIds.add(eachOpp.id);
                           
                       }
                       else if(parentOpportunityList.size() >0 && parentOpportunityList!= null){
                           eachOpp.New_Website_Url__c = mapParentIdChildOpp.get(eachOpp.Id).website__c;
                           approvedOpportunityList.add(eachOpp);
                       }
                       
                       
                   }
            }
        
        if(parentOppUpdateList != null && parentOppUpdateList.size() > 0) {
            update parentOppUpdateList;
            
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(updatedWebsiteURLoppIds,'WebsiteOpportunity',setproducerName);
            Database.executeBatch(oppPublisherBatch);
            
        }
        else if(approvedOpportunityList != null && approvedOpportunityList.size() >0){
            update approvedOpportunityList;
            createNewAddendumforWebsiteUpdate(approvedOpportunityList);
        }
        
    }
    
   public static void createNewAddendumforWebsiteUpdate (List<Opportunity> parentOpportunityList) {
         Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
        String PageName = Label.DocMasterList;
        String PageAssociation;
        List<Document_Master__c> docDetails = [Select Id,Name, Page_Association__c 
                                               FROM Document_Master__c where Page_Association__c = :PageName  order by Page_Association__c];
        List<Contract> AddendumList = new List<Contract>();
        set<String> setAddendumId = new Set<String>();
        String strEndPoint;
        List<Contract> updatedList = new List<Contract>();
        
        for(Opportunity each : parentOpportunityList){
            Contract Addendum = new Contract();
            Addendum.Contract_Type__c = 'Addendum';
            Addendum.Opportunity__c = each.id;
            Addendum.AccountId = each.AccountId;
            Addendum.Name = 'Website Change Addendum';
            Addendum.Status = 'Pending';
            Addendum.Document_Master__c = (docDetails[0] != null) ? docDetails[0].Id : Addendum.Document_Master__c;
            Addendum.Active__c = true;
            Addendum.Document_Category__c = [select id from Document_Category_Master__c where Name = 'Service Agreement' limit 1].id;
            Addendum.Document_Type__c = [select id from Document_Type_Master__c where Name = 'Addendum' limit 1].id;
            Addendum.Document_Category_Name__c = 'Service Agreement';
            Addendum.Document_Type_Name__c = 'Addendum';
            Addendum.Document_Content_Type__c = mapContentType.get('pdf');
            Addendum.StartDate = date.today();
            Addendum.ContractTerm = 120;
            Addendum.KYC_Documentable_Type__c = 'Merchant';
            AddendumList.add(Addendum);
        }
        if(AddendumList != null && AddendumList.size() > 0) {
            Insert AddendumList;
        }
    } 
}