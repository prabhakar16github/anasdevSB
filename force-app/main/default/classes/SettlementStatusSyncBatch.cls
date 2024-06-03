public with sharing class SettlementStatusSyncBatch implements Database.Batchable<sObject>, 
Database.AllowsCallouts, Database.stateful{
    
    public static Boolean startNextBatch = false;
    public Static Boolean isSettlementActivationBatch = false;
    public string batchSettingName = '';
    public Batch_Setting__mdt batchSetting;
    public Set<String> oppIds = new Set<String>();
        
    public SettlementStatusSyncBatch(string batchName){ 
        this.batchSettingName = batchName;
        batchSetting = [SELECT MasterLabel, Where_Clause__c,Record_Limit__c,Iteration_Count__c,Fields_To_Query__c,Re_Run_Apex_Job__c 
                                           FROM Batch_Setting__mdt WHERE MasterLabel =:this.batchSettingName LIMIT 1];
        
   }   

    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> settlementStatusLabelList = System.label.Settlement_Status_Restricted.split(',');
        string queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' FROM Opportunity WHERE Document_Status_Document_Issue__c=\''+'Docs Approved'+'\' AND Account.Pan_Verification_Status__c=\''+'Success'+'\' AND Agreement_Status__c=\''+'Approved'+'\'' ;        
        //queryResult += ' AND Settlement_Status__c NOT IN :('+settlementStatusLabelList+') ';
        queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';        
        queryResult += ' ORDER BY LastModifiedDate ASC';
        queryResult += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
        return Database.getQueryLocator(queryResult);        
    }
       
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        List<String> settlementStatusLabelList = System.label.Settlement_Status_Published.split(',');
        List<Opportunity> updatedList = new List<Opportunity>();
        
        if(!oppList.isEmpty() && oppList.size()>0){
            for(Opportunity eachOpp : oppList){
                if(eachOpp.ClearTaxCheck__c == FALSE){
                    eachOpp.ClearTaxCheck__c = TRUE;
                if(eachOpp.Document_Status_Document_Issue__c == 'Docs Approved' && eachOpp.Agreement_Status__c == 'Approved'
                   && eachOpp.Account.Pan_Verification_Status__c == 'Success'){
                       if(!settlementStatusLabelList.contains(eachOpp.Settlement_Status__c)){
                           if(eachOpp.Integration_Type__c == 'Thirdparty' && eachOpp.Website_Status__c=='Website OK'){
                               if(eachOpp.Settlement_Status__c != 'Active'){
                                   eachOpp.Settlement_Status__c = 'Active';
                                   updatedList.add(eachOpp);
                               }                           
                               if(eachOpp.Settlement_Status__c == 'Active') oppIds.add(eachOpp.Id);
                           }else if(eachOpp.Integration_Type__c == 'Tools' || eachOpp.Integration_Type__c == 'Not Selected'){
                               if(eachOpp.Settlement_Status__c != 'Active'){
                                   eachOpp.Settlement_Status__c = 'Active';
                                   updatedList.add(eachOpp);
                               }                           
                               if(eachOpp.Settlement_Status__c == 'Active') oppIds.add(eachOpp.Id);
                           }
                       }
                   }
                }
            }
            System.debug('oppIds.Size() 01 '+oppIds.Size());
            if(!updatedList.isEmpty()) Database.SaveResult[] settlementOppResult= Database.update(updatedList,false);
            
        }      
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('oppIds.Size() 02 '+oppIds.Size());
        if(!oppIds.isEmpty() && oppIds.size()>0){
            startNextBatch = true;
            
            while(oppIds.size()>0){
                System.debug('oppIds.Size() 03 '+oppIds.Size());
                Integer i = 0;
               isSettlementActivationBatch = true;
                Set<String> tempIds = new Set<String>();
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\') LIMIT 500')){                 
                    i++;                    
                    if(i<=6){ 
                        //IntegrationUtility.oppConvertedSet.add(each.Id);
                        //IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead');
                        
                        tempIds.add(each.Id);
                        oppIds.remove(each.Id);
                    }                                        
                } 
                if(!tempIds.isEmpty()){
                    Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(tempIds,'Opportunity',new Set<String>{'PayUmoney'}));
                    oppIds.removeAll(tempIds);   
                }
            }            
        }

        if(batchSetting.Re_Run_Apex_Job__c && startNextBatch){
            //if(!Test.isRunningTest()) Database.executeBatch(New SettlementStatusSyncBatch(this.batchSettingName),7);
        }
    }
}