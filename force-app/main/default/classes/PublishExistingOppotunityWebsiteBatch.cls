public class PublishExistingOppotunityWebsiteBatch implements Database.Batchable<string>,Database.AllowsCallouts, Database.stateful{
    
    public List<string> sObjectIds =new List<String>();
    public List<String> settlementStatusValues = new List<String>();
    Public Static Boolean isExecutionFinished = false;
    public string sObjectName = '';
    public Set<String> bankAccountIdSetUpdate = new Set<String>();
    public set<string> producerName = new set<String>();
    public List<string> updatedBankContractIds =new List<String>();
    public List<string> updatedBankContractAccountIds =new List<String>();
    public List<string> updatedWebContractIds =new List<String>();
    public List<string> updatedWebContractAccountIds =new List<String>();
    public set<string> oppIds = new set<String>();
    public set<string> accIds = new set<String>();
    public List<Id> updatedContractIds = new List<Id>();
    public List<string> updatedContractAccountIds = new List<String>();
    public List<string> updatedWebsiteDetailsIds = new List<String>();
    public List<Opportunity> updateWebAddendumOppId =new List<Opportunity>();
    
    
    public PublishExistingOppotunityWebsiteBatch(Set<String> updatedSObjectIds, string objName, set<string> setproducerName){
        this.sObjectIds = new List<String>(updatedSObjectIds);
        this.sObjectName = objName;
        this.producerName = setproducerName;
        String settleLabel = System.Label.Settlement_Status_Restricted;
        this.settlementStatusValues = settleLabel.split(',');
        this.bankAccountIdSetUpdate = updatedSObjectIds;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return new List<String>{'1'};
            }
    
    public void execute(Database.BatchableContext BC, List<String> strings) {        
        List<Opportunity> oppList = new List<Opportunity>();
        //JIRA966=====
        List<Opportunity> oppListtoRefreshAgreement = new List<Opportunity>();
        Map<String,String> oppIdwithChildId = new Map<String,String>();
        //==========
        List<Website_Details__c> websiteDetailsList = New List<Website_Details__c>();
        
        if(!sObjectIds.isEmpty() && sObjectIds.size()>0){
            if(sObjectName == 'Opportunity' ){
                for(Opportunity each : Database.query('SELECT Account.NDX_Score__c,Account.Pan_Verification_Status__c,Account.Document_Status__c,Account.Agreement_Status__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                    /*
                    if(each.Account.Ndx_Score__c > 0 && each.Account.Ndx_Score__c<50000 && 
                       (String.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || String.isNotBlank(each.Android_URL__c))
                       && each.Website_Remarks__c != 'Website URL updated by Sales Agent.' 
                       && each.Lead_Type__c=='Merchant' 
                       && (each.Website_Status__c =='Pending' || each.Website_Status__c=='Verification in Process')
                       && producerName.contains('MerchantOnboarding')){
                           each.Website_Status__c = 'Website OK';
                           oppList.add(each);                            
                       }*/
                    if(each.Account.Pan_Verification_Status__c=='Success' && (each.Document_Status_Document_Issue__c == 'Docs Approved')
                       && (each.Agreement_Status__c == 'Approved') && each.Website_Status__c=='Website OK'
                       && !settlementStatusValues.contains(each.Settlement_Status__c) && each.Integration_Type__c == 'Thirdparty'){
                           each.Settlement_Status__c = 'Active';
                           oppList.add(each);
                       }
                    if(each.Account.Pan_Verification_Status__c=='Success' && each.Document_Status_Document_Issue__c =='Docs Approved'
                       && each.Agreement_Status__c == 'Approved' && each.Integration_Type__c == 'Tools'
                       && !settlementStatusValues.contains(each.Settlement_Status__c)){
                           each.Settlement_Status__c = 'Active';
                           oppList.add(each);
                       }
                }
            }
            
            if(sObjectName == 'Bank_Account_Detail__c' && !producerName.contains('PayUmoney') && bankAccountIdSetUpdate.size()>0 && !bankAccountIdSetUpdate.isEmpty()){
                   System.debug('BankAccountTrigger Call :::::: ');
                   List<Contract> updatedContract = BankDetailTriggerHandler.updateagreementinOnlineCaseWithnewURL(bankAccountIdSetUpdate);
                   if(!updatedContract.isEmpty() && updatedContract.size()>0){
                       for(Contract eachContract : updatedContract){
                           updatedBankContractIds.add(eachContract.Id);
                           updatedBankContractAccountIds.add(eachContract.AccountId);
                       }
                   }
               }
            
            if(sObjectName == 'WebsiteOpportunity' ){
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                    system.debug('enterWebsite');
                    //Added to regenerate Aggrement on website change Jira966
                    if((String.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || String.isNotBlank(each.Android_URL__c))
                       && each.Lead_Type__c=='Merchant' 
                       && (each.Website_Status__c=='Verification in Process' || each.Website_Status__c=='Website Error' || each.Website_Status__c =='Pending' || each.Website_Status__c=='Website OK') 
                       && producerName.contains('MerchantOnboarding') 
                       && each.Website_updated_last__c
                      ){
                          oppListtoRefreshAgreement.add(each);                          
                      }
                }
            }	
            
            if(!oppListtoRefreshAgreement.isEmpty() && oppListtoRefreshAgreement.size() > 0){
                List<Contract> contractsToUpdate = OpportunityTriggerHandler.updateagreementWithNewWebURL(oppListtoRefreshAgreement,oppIdwithChildId);
                if(!contractsToUpdate.isEmpty() &&  contractsToUpdate.size() > 0){
                    for(Contract eachContract : contractsToUpdate){
                        updatedWebContractIds.add(eachContract.Id);
                        updatedWebContractAccountIds.add(eachContract.AccountId);
                    }
                } 
            }
            
            if(sObjectName == 'Contract'){
                for(Contract each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ' FROM Contract WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                    updatedContractIds.add(each.Id);
                    updatedContractAccountIds.add(each.AccountId);
                }
            }
            
            if(sObjectName == 'WebsiteAddendumOpportunity'){
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                    system.debug('enterWebsiteAddendum');
                    each.Website__c = each.New_Website_Url__c != null ? each.New_Website_Url__c : each.Website__c ;
                    updateWebAddendumOppId.add(each);
                }
            }
            
            if(sObjectName == 'Website_Details__c'){
                for(Website_Details__c each : Database.query('SELECT Opportunity__r.Skip_Website_Verification__c,Opportunity__r.Integration_Type__c,  ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Website_Details__c')), ',') + ' FROM Website_Details__c WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                    system.debug('######## website Details====== '+each.Website_Status__c);
                    /*if(String.isNotBlank(each.Website_Status__c)
                       && each.NDX_Score__c != null && each.NDX_Score__c > 0 && each.NDX_Score__c <= 50000){
                           if(each.Website_Status__c == 'Verification in Process' ){
                               each.Website_Status__c = 'Website OK';
                           		websiteDetailsList.add(each);	
                           } 
                        	updatedWebsiteDetailsIds.add(each.Id);
                       } 
                    else*/ if(String.isNotBlank(each.Website_Status__c) && each.Opportunity__r.Skip_Website_Verification__c && each.Opportunity__r.Integration_Type__c == 'ThirdParty'){
                           each.Website_Status__c = 'Website OK';
                           websiteDetailsList.add(each);
                           updatedWebsiteDetailsIds.add(each.Id);
                       }
                }
            }
        }
        
        if(!oppList.isEmpty() && oppList.Size()>0) update oppList;
        
        if(!updateWebAddendumOppId.isEmpty() && updateWebAddendumOppId.size() > 0) update updateWebAddendumOppId;
        
        if(!websiteDetailsList.isEmpty() && websiteDetailsList.size() > 0) update websiteDetailsList;
    }
    
    public void finish(Database.BatchableContext BC) {
        isExecutionFinished = true;
        if(!sObjectIds.isEmpty() && sObjectIds.Size()>0){         
            
            if(sObjectName == 'Opportunity'){
                for(Opportunity each : Database.query('SELECT Account.NDX_Score__c,Account.Pan_Verification_Status__c,Account.Document_Status__c,Account.Agreement_Status__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                
                    
                    IntegrationUtility.websiteOppIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead');                                                                        
                }  
            }
            if(sObjectName == 'Account' && !producerName.contains('PayUmoney')){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                
                    IntegrationUtility.contractAccountIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                                                                        
                }  
            }
        }
        if(sObjectName=='Bank_Account_Detail__c' && !producerName.contains('PayUmoney') && !updatedBankContractIds.isEmpty() && updatedBankContractIds.size()>0){
            
            for(Contract each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ' FROM Contract WHERE Id IN (\'' + String.join(new List<String>(updatedBankContractIds), '\',\'') + '\')')){                
                if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') &&
                   (each.Status.equalsIgnoreCase('Pending')|| each.Status.equalsIgnoreCase('Approved') || each.Status.equalsIgnoreCase('Declined'))){
                       {
                           IntegrationUtility.sendPayLoadData(each, null, 'Contract', 'Merchant_Document__c');
                       }
                   }  
            }
            if(!updatedBankContractAccountIds.isEmpty() && updatedBankContractAccountIds.size()>0){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(updatedBankContractAccountIds), '\',\'') + '\')')){                
                    IntegrationUtility.contractAccountIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                                                                        
                }
            }
        }
        
        if(sObjectName=='WebsiteOpportunity' && !producerName.contains('PayUmoney') && !updatedWebContractIds.isEmpty() && updatedWebContractIds.size()>0){
            
            for(Contract each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ' FROM Contract WHERE Id IN (\'' + String.join(new List<String>(updatedWebContractIds), '\',\'') + '\')')){                
                if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') &&
                   (each.Status.equalsIgnoreCase('Pending')|| each.Status.equalsIgnoreCase('Approved') || each.Status.equalsIgnoreCase('Declined'))){
                       {
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
        
        if(sObjectName == 'Contract' && updatedContractAccountIds.size() >0){
            for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(updatedContractAccountIds), '\',\'') + '\')')){                
                IntegrationUtility.contractAccountIds.add(each.Id);
                IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                                                                        
            }
        }
        
        if(sObjectName == 'WebsiteAddendumOpportunity' && updateWebAddendumOppId.size() >0){
            for(Opportunity each : Database.query('SELECT Account.NDX_Score__c,Account.Pan_Verification_Status__c,Account.Document_Status__c,Account.Agreement_Status__c, ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                
                    
                    IntegrationUtility.websiteOppIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead');                                                                        
                }
        }
        
        if(sObjectName == 'Website_Details__c' && !updatedWebsiteDetailsIds.isEmpty()){
            for(Website_Details__c each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Website_Details__c')), ',') + ' FROM Website_Details__c WHERE Id IN (\'' + String.join(new List<String>(updatedWebsiteDetailsIds), '\',\'') + '\')')){                    
                system.debug('######## website Details finish ====== '+each.Website_Status__c);
                if(String.isNotBlank(each.Website_Status__c) && each.Website_Status__c == 'Website OK'){
                    IntegrationUtility.websiteOppIds.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Website_Details__c', 'Website_Details__c');
                }
            }
        }
        
        List<AsyncApexJob> lstFailedJobs = [SELECT CreatedDate, ExtendedStatus, Status
                                            FROM AsyncApexJob 
                                            WHERE ApexClass.Name = : 'AWSConsumerBatch'
                                            AND JobType = 'BatchApex'
                                            AND (Status IN ('Holding', 'Queued','Preparing','Processing'))
                                            Order by CreatedDate DESC Limit 1];
       /* Batch_Setting__mdt bsMDT = [Select Id,Record_Limit__c,Re_Run_Apex_Job__c,Where_Clause__c from Batch_Setting__mdt 
                                    where DeveloperName=:'AWSConsumerBatch' LIMIT 1];
        if(!Test.isRunningTest()) {
            if(bsMDT.Re_Run_Apex_Job__c && lstFailedJobs.size()<2 && lstFailedJobs.isEmpty()){
                Database.executeBatch(new AWSConsumerBatch());
            }
        } */    
    }
}