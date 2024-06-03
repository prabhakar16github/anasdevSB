public class createNewCase {
    
    public class MerchantIdInput {
    @InvocableVariable(required=true)
    public string sMID;
    @InvocableVariable(required=true)
    public string sProduct;
      
    @InvocableVariable(required=true)
    public string spageName;
      
  }
    
    public class VisitorOutput {
        @InvocableVariable
        public String caseNumber;
        
    }
    
    @InvocableMethod(label='Create New Case')
    public static void createCase(List<MerchantIdInput> merchantDetails){
        
        List<VisitorOutput> results = new List<VisitorOutput>();
        List<Integer> midList = new list<Integer>();
        List<String> productList = new List<String>();
        list<id> accIdList = new List<id>();
        List<Contact> conList = new List<Contact>();
        Map<String,String> accContactMap = new Map<String,String>();
        Map<String,String> accOppMap = new Map<String,String>();
        List<Case> caseList = new List<Case>();
        Map<String, String> queueNamewithID = (Map<String, String>)JSON.deserialize(System.label.ETC_Queue_Name_Id_Management, Map<String, String>.class);
        String pageName;        
        
        for (MerchantIdInput mDetail : merchantDetails) {
            Integer Mid = integer.valueOf(mDetail.sMID);
            midList.add(Mid);
            productList.add(mDetail.sProduct);
            pageName = mDetail.sPageName;
        }
        
        List<Opportunity> oppList = [Select id,AccountId,Email__c from Opportunity 
                                     where Prod_Merchant_Id__c IN :midList AND recordtype.name = 'Merchant' AND ProductLabel__c IN :productList];
            
        if(oppList.size() > 0 && oppList != null){
            for(Opportunity opp : oppList){
                accIdList.add(opp.AccountId);
                accOppMap.put(opp.AccountId,opp.id);
            }
        }
        if(accIdList.size() > 0 && accIdList != null){
            conList = [Select id,accountId from Contact where accountID in :accIdList];
            if(conList.size() > 0 && conList != null)
            for(Contact con : conList){
                accContactMap.put(con.AccountId,con.id);
            }
            
            for(String accId : accIdList ){
                Case newCase = new Case();
                newCase.AccountId = accId;
                newCase.ContactId = !accContactMap.isEmpty() ? accContactMap.get(accId) : newCase.ContactId;
                if(pageName == 'DocumentsPage'){
                	newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ETC_Merchant_Maintenance').getRecordTypeId();
                    newCase.OwnerId = queueNamewithID.get('Documentation Team For CS');
                    newCase.Subject = 'Escalation Case for Docs Team';
                }
                else if(pageName == 'websitePage'){
                    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ETC_Pre_Onboarding_Risk').getRecordTypeId();
                    newCase.OwnerId = queueNamewithID.get('ETC Pre-Onboarding Risk');
                    newCase.Subject = 'Escalation Case for Risk Team';
                }
                newCase.Opportunity__c = !accOppMap.isEmpty() ? accOppMap.get(accId) : newCase.Opportunity__c;
                newCase.Origin = 'Chat';
                
                
               
                caseList.add(newCase);
                system.debug('newCase.owner='+newCase.Owner.Name);
            }
            
            if(!caseList.isEmpty() && caseList != null) insert caseList;
            
            
        }
        
        
        
    }

}