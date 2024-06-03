public class Batch_ContractwithUpdatedWebsite implements Database.Batchable<String>, 
Database.AllowsCallouts, Database.stateful{
    
    public Static Boolean isAddendumBulkUploadBatch = false;
    public Map<string,String> oppIdwithChildId = new Map<String,String>();
    //public Map<string,Opportunity> setOppId = new Map<String,Opportunity>();
    public List<string> updatedWebContractIds =new List<String>();
    public List<string> updatedWebContractAccountIds =new List<String>();
    public Set<string> updateAddendumUrl = new Set<String>();
    public Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
    public Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();
    public Map<String,String> mapofContractWithopport = new Map<String,String>();
    public boolean isAddendum;
    
    public static boolean isExecutionFinished = false;
    
        
    public Batch_ContractwithUpdatedWebsite(Map<Id,Contract> mapOfIdContract,Map<Id,String> mapofContractWithAgreementVFpage,Map<String,String> mapofContractWithopport,Boolean isAddendum ) {
        this.mapOfIdContract = mapOfIdContract;
        this.mapofContractWithAgreementVFpage = mapofContractWithAgreementVFpage;
        this.mapofContractWithopport = mapofContractWithopport;
        this.isAddendum = isAddendum;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return new List<String>{'1'};
            }
    
    public void execute(Database.BatchableContext BC, List<String> strings) {
        List<Contract> lstContractUpdate = new List<Contract>();
        List<Account> accounttoUpdateList = new List<Account>();
        
        if(!mapOfIdContract.isEmpty()){
            /*if(isAddendum){
                for(Id objId:mapOfIdContract.keySet()){
                    system.debug('=objId====='+objId);
                    String strEndPoint ='';
                    Contract objContract = new Contract();
                    objContract = mapOfIdContract.get(objId);
                    system.debug(' mapofContractWithAgreementVFpage.get(objId)=='+mapofContractWithAgreementVFpage.get(objId));
                    system.debug('mapofContractWithopport=='+mapofContractWithopport.get(objId));
                    if(mapofContractWithAgreementVFpage.get(objId) != null && mapofContractWithopport.get(objId)!= null){
                        system.debug(' mapofContractWithAgreementVFpage.get(objId)=='+mapofContractWithAgreementVFpage.get(objId));
                        PageReference pageRef = new PageReference('/apex/' + mapofContractWithAgreementVFpage.get(objId));
                        system.debug('page=='+pageRef.getUrl());
                        pageRef.getParameters().put('id', mapofContractWithopport.get(objId));        
                        pageRef.getParameters().put('strIsFinal', 'true');
                        pageRef.getParameters().put('eStampNo', String.valueof(objContract.E_Stamp_Number__c));
                        Blob body;
                        system.debug('page=='+pageRef.getUrl());
                        
                        if(!Test.isRunningTest()){
                            body = pageRef.getContent();
                            strEndPoint = AWSUtility.uploadAndGetDocUrlS3(objContract, objContract.Account.Identifier__c, body);
                        }else if(Test.isRunningTest()){
                            strEndPoint = 'google.com';
                            body = Blob.valueOf('Test Data');
                        }                 
                        
                        system.debug('strEndPoint ************ '+strEndPoint);
                        if(String.isNotBlank(strEndPoint)){
                            objContract.URL__c = strEndPoint;
                            objContract.Upload_Date__c = System.today();
                            objContract.File_Size__c = String.valueOf(body.size());
                            
                            lstContractUpdate.add(objContract);
                            } 
                        }
                    }
                }
            
            else{*/
                for(Id objId:mapOfIdContract.keySet()){
                    system.debug('=objId====='+objId);
                    String strEndPoint ='';
                    Contract objContract = new Contract();
                    objContract = mapOfIdContract.get(objId);
                    if(mapofContractWithAgreementVFpage.get(objId) != null && mapofContractWithopport.get(objId)!= null){
                        PageReference pageRef = new PageReference('/apex/' + mapofContractWithAgreementVFpage.get(objId));
                        pageRef.getParameters().put('id', mapofContractWithopport.get(objId));        
                        pageRef.getParameters().put('strIsFinal', 'true');
                        pageRef.getParameters().put('eStampNo', String.valueof(objContract.E_Stamp_Number__c));
                        Blob body;
                        
                        if(!Test.isRunningTest()){
                            body = pageRef.getContent();
                            strEndPoint = AWSUtility.uploadAndGetDocUrlS3(objContract, objContract.Account.Identifier__c, body);
                        }else if(Test.isRunningTest()){
                            strEndPoint = 'google.com';
                            body = Blob.valueOf('Test Data');
                        }                 
                        
                        system.debug('strEndPoint ************ '+strEndPoint);
                        if(String.isNotBlank(strEndPoint)){
                            objContract.URL__c = strEndPoint;
                            objContract.Upload_Date__c = System.today();
                            objContract.File_Size__c = String.valueOf(body.size());
                            
                            lstContractUpdate.add(objContract);
                            
                            Account accObj = new Account(Id = objContract.AccountId);
                            if(accObj.Agreement_Status__c == 'Not Generated'){
                                accObj.Agreement_Status__c = 'Sent';
                                accounttoUpdateList.add(accObj);
                            } 
                        }
                    }
                } 
            }
            if(!lstContractUpdate.isEmpty())
                update lstContractUpdate;
            if(!accounttoUpdateList.isEmpty()) 
                update accounttoUpdateList;
        
        
        if(!lstContractUpdate.isEmpty() &&  lstContractUpdate.size() > 0){
            for(Contract eachContract : lstContractUpdate){
                updatedWebContractIds.add(eachContract.Id);
                updatedWebContractAccountIds.add(eachContract.AccountId);
            }
        } 
        
		/*List<Opportunity> oppListtoRefreshAgreement = new List<Opportunity>();
        Map<String,String> oppIdwithChildId = new Map<String,String>();
        for(Opportunity each : OppList){            
            
            if((String.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || String.isNotBlank(each.Android_URL__c))
               && each.Lead_Type__c=='Merchant' 
               && (each.Website_Status__c=='Verification in Process' || each.Website_Status__c=='Website OK' || each.Website_Status__c=='Website Error')
               && each.Website_updated_last__c){
                   oppListtoRefreshAgreement.add(each); 
                   String ChildOppId = setOppId.get(each.Id).id;
                   oppIdwithChildId.put(each.Id,ChildOppId);
               }
        }
        
        if(!oppListtoRefreshAgreement.isEmpty() && oppListtoRefreshAgreement.size() > 0){
            List<Contract> contractsToUpdate = OpportunityTriggerHandler.updateagreementWithNewWebURL(oppListtoRefreshAgreement,oppIdwithChildId);
            if(!contractsToUpdate.isEmpty() &&  contractsToUpdate.size() > 0){
                for(Contract eachContract : contractsToUpdate){
                    if(eachContract.Document_Type_Name__c == 'Addendum'){
                        updateAddendumUrl.add(eachContract.Id);
                    }else{
                    updatedWebContractIds.add(eachContract.Id);
                    updatedWebContractAccountIds.add(eachContract.AccountId);
                    }
                }
            } 
        }*/
    }
    
    public void finish(Database.BatchableContext BC){
       isExecutionFinished = true;
        if(!updatedWebContractIds.isEmpty() && updatedWebContractIds.size()>0){
            
            for(Contract each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ' FROM Contract WHERE Id IN (\'' + String.join(new List<String>(updatedWebContractIds), '\',\'') + '\')')){                
                if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') &&
                   (each.Status.equalsIgnoreCase('Pending')|| each.Status.equalsIgnoreCase('Approved') || each.Status.equalsIgnoreCase('Declined'))){
                       {
                           system.debug('enter IntegrationUtility');
                           IntegrationUtility.sendPayLoadData(each, null, 'Contract', 'Merchant_Document__c');
                       }
                   }  
            }
            if(!updatedWebContractAccountIds.isEmpty() && updatedWebContractAccountIds.size()>0){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(updatedWebContractAccountIds), '\',\'') + '\')')){                
                    IntegrationUtility.contractAccountIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                                                                        
                }
            }
        }
        else if(!updateAddendumUrl.isEmpty() && updateAddendumUrl.size() > 0){
            Database.executeBatch(new EMIDashboardAddendumBatch(updateAddendumUrl,'WebsiteChangeIndividualAddedndum',false));
        }
    }   
}