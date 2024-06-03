public class getListOfMerchantDocController{
    
    public String strAccountId{get;set;}
    public WrapDataofDoc objWrapDataDoc{get;set;}
    
    public List<String> getlstofMercDoc(){
        List<String> lstData = new List<String>();
        Set<Id> entityId = new Set<Id>();
        
        if(!String.isBlank(strAccountId)){          
            if(strAccountId.startsWith('001')){
                for(Merchant_Document__c eachMerchantDoc : [SELECT id, Document_Category__c, Document_Category__r.Name, Name FROM Merchant_Document__c WHERE Account__c =: strAccountId]){
                    if(String.isNotBlank(eachMerchantDoc.Document_Category__c) && String.isNotBlank(eachMerchantDoc.Document_Category__r.Name)){
                        lstData.add(eachMerchantDoc.Document_Category__r.Name);
                    }
                }
            }
            else{
                for(Bank_Account_Detail__c eachBankList : [Select Id, Name, Lead__c, Lead__r.Business_Entity__c, Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Account.Business_Entity__c 
                                                           FROM Bank_Account_Detail__c 
                                                           WHERE Id =: strAccountId])
                {                    
                    if(String.isNotBlank(eachBankList.Opportunity__c) && String.isNotBlank(eachBankList.Opportunity__r.AccountId) && 
                       String.isNotBlank(eachBankList.Opportunity__r.Account.Business_Entity__c)){
                           entityId.add(eachBankList.Opportunity__r.Account.Business_Entity__c);
                       }
                    else if(String.isNotBlank(eachBankList.Lead__c) && String.isNotBlank(eachBankList.Lead__r.Business_Entity__c)){
                        entityId.add(eachBankList.Lead__r.Business_Entity__c);
                    }
                }
                
                if(!entityId.isEmpty()){                    
                    for(Document_Master__c eachDocmaster : [SELECT id , Document_Category__r.Name, Name FROM Document_Master__c WHERE 
                                                            Entity__c IN: entityId AND RecordTypeName__c = 'Merchant_Document' AND Active__c = True AND Document_For__c = 'Merchant'])
                    {
                        if(String.isNotBlank(eachDocmaster.Document_Category__c) && String.isNotBlank(eachDocmaster.Document_Category__r.Name))
                        {
                            lstData.add(eachDocmaster.Document_Category__r.Name);
                        }
                    }
                }
            }
        }
        return lstData;
    }
    
     public List<WrapDataofDoc> getListofFailedDocuments(){
        List<WrapDataofDoc> lstWrapData = new List<WrapDataofDoc>();
        List<Merchant_Document__c> lstData = new List<Merchant_Document__c>();        
        
        if(!String.isBlank(strAccountId)){          
            if(strAccountId.startsWith('001')){
                for(Merchant_Document__c objMerchantDoc : [SELECT id, Document_Category__c,Error__c, Solution__c, Onboarding_Status__c, Document_Category__r.Name, Name, Document_Type__r.Name FROM Merchant_Document__c WHERE Account__c =: strAccountId and Onboarding_Status__c = 'Declined']){
                    if(String.isNotBlank(objMerchantDoc .Document_Category__c) && String.isNotBlank(objMerchantDoc.Document_Category__r.Name)){
                          WrapDataofDoc objWrap = new WrapDataofDoc(); 
                          objWrap.objMD = objMerchantDoc ;
                          objWrap.Errorlst = (!string.isBlank(objMerchantDoc.Error__c))?objMerchantDoc.Error__c.split(';'): null;
                          objWrap.Resolutionlst = (!string.isBlank(objMerchantDoc.Solution__c))? objMerchantDoc.Solution__c.split(';'):null;
                          lstWrapData.add(objWrap);
                    }
                }
            }     
         }
         return lstWrapData;
    }
    
    public class WrapDataofDoc{
        public Merchant_Document__c objMD{get;set;}
        public List<String> Errorlst{get;set;}
        public List<String> Resolutionlst{get;set;}
    } 
}