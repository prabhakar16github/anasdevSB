/**
* @Class Name   :   ReKYCAutomationBatch
* @Sch. Class.  :   SchedulerForReKYCAutomation
* @Description  :   Batch class to upsert next ReKYC Date 
* @Author       :   Saksham Rohilla(for SFI-1095)
*/

public class ReKYCAutomationBatch implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 
    private Integer N_Days;
    public ReKYCAutomationBatch(Integer N_Days){
        this.N_Days = N_Days;
    }
   public Database.QueryLocator start(Database.BatchableContext info){
       return Database.getQueryLocator(
            'SELECT Id FROM Opportunity WHERE Merchant_Type__c != \'child_aggregator\' AND ( Agreement_Status__c = \'Approved\' OR Onboarding_Completed__c = true) AND Next_ReKYC_date__c>=TODAY AND Next_ReKYC_date__c <= NEXT_N_DAYS:'+N_Days);
   }     
   public void execute(Database.BatchableContext info, List<Opportunity> scope){
       System.debug(scope.size());
       List<Opportunity> oppListToUpdate = new List<Opportunity>();
       List<Id> removePayoutIds = new List<Id>();
       List<Cross_Sell__c> payoutRecords = [Select Opportunity__c FROM Cross_Sell__c WHERE Opportunity__c IN :scope AND Name='Payout' AND Active__c =true AND (Opportunity__r.Onboarding_Completed__c!=true OR Opportunity__r.Agreement_Status__c !='Approved')];
       for(Cross_Sell__c record: payoutRecords){
           removePayoutIds.add(record.Opportunity__c);
       }
       List<Opportunity> newScope = [SELECT Id,Next_ReKYC_Date__c,Last_ReKYC_date__c,Settlement_Date__c,CreatedDate,Risk_Score__c FROM Opportunity WHERE Id IN :scope AND Id NOT IN :removePayoutIds];
       for(Opportunity opp:newScope) {
           Date oppDate;
           if(opp.Last_ReKYC_date__c!=NULL) oppDate = opp.Last_ReKYC_date__c;
           else if(opp.Settlement_Date__c != NULL) oppDate = opp.Settlement_Date__c;
           else oppDate = opp.CreatedDate.date();
           String addYearsForNextReKYC = System.Label.Risk_Category_Mapping;
           Map<String,Object> jsonObject = (Map<String,Object>)System.JSON.deserializeUntyped(addYearsForNextReKYC);
           Integer addYearsForHighRisk = (Integer)jsonObject.get('High');
           Integer addYearsForMediumRisk = (Integer)jsonObject.get('Medium');
           Integer addYearsForLowRisk = (Integer)jsonObject.get('Low');
           if(opp.Risk_Score__c>=100 || opp.Risk_Score__c == NULL){
               oppDate = oppDate.addYears(addYearsForHighRisk);
           }
           else if(opp.Risk_Score__c>=50){
               oppDate = oppDate.addYears(addYearsForMediumRisk);
           }
           else{
               oppDate = oppDate.addYears(addYearsForLowRisk);
           }
           opp.Next_ReKYC_Date__c = oppDate;
           oppListToUpdate.add(opp);
       }
       if(!oppListToUpdate.isEmpty()){
            //update oppListToUpdate;
            Set<String> oppIds = new Set<String>();
            List<Database.SaveResult> updateResults = Database.update(oppListToUpdate, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    
                    String recordId = updateResults.get(i).getId();
                    if(recordId == oppListToUpdate[i].Id){
                        oppIds.add(recordId);
                    }
                }
            }
            if(!oppIds.isEmpty()){
                System.enqueueJob(new PublishPayloadFromBatch(oppIds));
            }
        }
   }     
   public void finish(Database.BatchableContext info){     
       
   } 
}