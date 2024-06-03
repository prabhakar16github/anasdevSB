public class UpdateDormancyDetailsBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        String APPROVED_AGG_STATUS = 'Approved';
        String CHILD_AGGREGATOR = 'child_aggregator';
        String AGG_STATUS_APPROVED = 'Approved';
        String query = 'SELECT Id,Last_txn_date__c,Days_Since_Last_Transaction__c,Dormancy_Date__c, Is_dormant__c,Agreement_Status__c,';
        query += ' Onboarding_Completed__c,Payload_header__c,Merchant_Account_Id__c,Identifier__c,ProductLabel__c FROM Opportunity';
        query += ' WHERE Last_txn_date__c!= NULL AND Days_Since_Last_Transaction__c > 270 AND Merchant_Type__c != :CHILD_AGGREGATOR';
        query += ' AND (Agreement_Status__c = :AGG_STATUS_APPROVED OR Onboarding_Completed__c = true) ORDER BY Days_Since_Last_Transaction__c  ';
        /** for testing */
        //query += 'DESC LIMIT 3';
        /** */
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,Boolean> crossSellDetailMap = new Map<Id,Boolean>();
        for(sObject sobj : scope){
            Opportunity opp = (Opportunity)sobj;
            crossSellDetailMap.put(opp.Id,false);
            
        }
        if(crossSellDetailMap.keySet().isEmpty()){
            return;
        }
        
        for(Cross_Sell__c cs : [SELECT Id,Name,Opportunity__c FROM Cross_Sell__c 
                                WHERE Opportunity__c IN :crossSellDetailMap.keySet() 
                                AND Name = 'Payout' 
                                AND RecordType.Name = 'Payout'
                                AND Active__c = true]){
            if(crossSellDetailMap.containsKey(cs.Opportunity__c)){
                crossSellDetailMap.put(cs.Opportunity__c, true);
            }
        }
        System.debug('>>>>>>crossSellDetailMap>>>>>>>>'+crossSellDetailMap);
        
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for(sObject sobj : scope){
            Opportunity opp = (Opportunity)sobj;
            if(crossSellDetailMap.get(opp.Id) && (opp.Agreement_Status__c != 'Approved' || !opp.Onboarding_Completed__c)){
                continue;
            }
            
            /** Case 1 - If Dormancy_Date is blank */
            if(opp.Dormancy_Date__c == NULL){
                opp.Dormancy_Date__c = opp.Last_txn_date__c.addMonths(12);
                if(opp.Dormancy_Date__c < System.today() && !opp.Is_dormant__c){
                    opp.Is_dormant__c = true;
                }
                oppListToUpdate.add(opp);
            }/** */
            
            /** Case 2 - If Dormancy_Date is not blank */
            else if(opp.Dormancy_Date__c != NULL && opp.Dormancy_Date__c < System.today() && !opp.Is_dormant__c){
                opp.Is_dormant__c = true;
                oppListToUpdate.add(opp);
            }/** */
        }
        System.debug('>>>>>>oppListToUpdate>>>>>>'+oppListToUpdate);
        if(!oppListToUpdate.isEmpty()){
            //update oppListToUpdate;
            Set<String> oppIds = new Set<String>();
            List<Database.SaveResult> updateResults = Database.update(oppListToUpdate, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    
                    String reocordId = updateResults.get(i).getId();
                    if(reocordId == oppListToUpdate[i].Id){
                        oppIds.add(reocordId);
                    }
                }
            }
            
            if(!oppIds.isEmpty()){
                System.enqueueJob(new PublishPayloadFromBatch(oppIds));
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){}
    
}