public with sharing class LeadConvertBatch implements Database.Batchable<sObject>, 
Database.AllowsCallouts, Database.stateful{
    
    
    //Map<string,string> leadIdWithOldStatusMap = new Map<string,string>();
    Set<String> successLeadIds = new Set<String>();
    public static Boolean startNextBatch = false;
    public Static Boolean isLeadConversionBatch = false;
    Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Where_Clause__c,Record_Limit__c,Iteration_Count__c,Re_Run_Apex_Job__c, 
                                       Fields_To_Query__c FROM Batch_Setting__mdt WHERE MasterLabel = 'LeadConvertBatch' LIMIT 1];
   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' ,(SELECT Id FROM Bank_Account_Details__r WHERE Active__c=TRUE AND Verification_Status__c=\''+'Success'+'\' ORDER BY LastModifiedDate) FROM Lead WHERE IsConverted=FALSE AND PAN_Number__c != NULL AND PAN_Holder_Name__c != NULL AND Legal_Name__c != NULL AND Product__c != NULL AND Prod_Merchant_Id__c != NULL AND Business_Entity__c != NULL ';
        queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';        
        queryResult += ' ORDER BY LastModifiedDate ASC';
        queryResult += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
        return Database.getQueryLocator(queryResult);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        System.debug('######## '+scope.size());
        Map<Id,Lead> leadsToConvertMap = new Map<Id,Lead>();
        if(!scope.isEmpty()){  
            /* List<String> accIds = new List<string>();
List<String> oppIds = new List<string>();
startNextBatch = true;
isLeadConversionBatch = true;


for(Lead leadObj : scope){
Boolean error = false;
if(!'Partner'.equals(leadObj.Lead_Type__c)){   
if(leadObj.Bank_Account_Details__r.size() == 0){
leadObj.Lead_Conversion_Failure_Message__c = 'No Bank Account Detail found.'; 
error = true;
}
if(leadObj.Bank_Account_Details__r.size()>0 && leadObj.Bank_Verification_Status__c != 'Success'){
leadObj.Bank_Verification_Status__c = 'Success';                        
}

}
if(!error && leadObj.Bank_Verification_Status__c == 'Success'){
leadObj.Status = 'Qualified';
leadsToConvertMap.put(leadObj.Id,leadObj);
}
}

if(!leadsToConvertMap.isEmpty() && leadsToConvertMap.size()>0) {
Database.SaveResult[] convertedLeadResult= Database.update(leadsToConvertMap.values(),false);

for(Database.SaveResult dResult : convertedLeadResult){
if(dResult.isSuccess()){
successLeadIds.add(dResult.getId());                                       
}
}
}*/
            isLeadConversionBatch = true;
            //LeadTriggerHandler.convertTheLeadAU(scope,new Map<Id,Lead>(scope),null);
            for(Lead each : scope){
                successLeadIds.add(each.Id);
            }
        }
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        Set<String> accIds = new Set<String>();
        Set<String> oppIds = new Set<String>();
        List<Lead> failedLeadListToUpdate = new List<Lead>();
        
        if(!successLeadIds.isEmpty() && successLeadIds.size()>0){
            isLeadConversionBatch = true;
            startNextBatch = true;
            while(successLeadIds.size()>0 && startNextBatch){
                Integer i = 0;
                Set<String> tempIds = new Set<String>();
                for(Lead each : Database.query('SELECT '+batchSetting.Fields_To_Query__c+' FROM Lead WHERE Id IN (\'' + String.join(new List<String>(successLeadIds), '\',\'') + '\')')){           
                    
                    if(each.isConverted){
                        i++;
                        //if(String.isNotBlank(each.ConvertedOpportunityId)) oppIds.add(each.ConvertedOpportunityId);                   
                        
                        //if(String.isNotBlank(each.ConvertedAccountId)) accIds.add(each.ConvertedAccountId);
                        if(i<=6){
                            tempIds.add(each.Id);
                        	
                        }
                    }
                    successLeadIds.remove(each.Id);
                }
                if(!tempIds.isEmpty()){
                    Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(tempIds,'Lead',new Set<String>{'Salesforce'}));
                    successLeadIds.removeAll(tempIds);   
                }else
                    startNextBatch = false;
            }
        }      
        /*
        
        if(!accIds.isEmpty()){
            Integer i = 0;
            while(accIds.size()>0){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(accIds), '\',\'') + '\')')){                                    
                    i++;
                    if(i<=5){
                        IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');
                        accIds.remove(each.Id);
                    }
                }
            }            
        }
        
        if(!oppIds.isEmpty()){
            Integer i = 0;
            while(oppIds.size()>0){
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')')){                    
                    i++;
                    if(i<=5){
                        IntegrationUtility.oppConvertedSet.add(each.Id);
                        IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead');
                        oppIds.remove(each.Id);
                    }
                    
                } 
            }
            
        }
        if(!IntegrationUtility.logList.isEmpty()) Database.insert(IntegrationUtility.logList, false);
        */
        if(batchSetting.Re_Run_Apex_Job__c && startNextBatch){
            //if(!Test.isRunningTest()) Database.executeBatch(New LeadConvertBatch(),5);
        }else if(batchSetting.Re_Run_Apex_Job__c){
            //if(!Test.isRunningTest()) Database.executeBatch(New LeadConvertBatch(),5);
        }
    }
}