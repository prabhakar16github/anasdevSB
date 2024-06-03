/*
* Name of the class : BatchClassToRemoveDuplicateMIDs
* Author's Name     : Anas Yar Khan  
* Created Date      : 24th Aug, 2022
* Description       : Batch Class to remove duplicate MIDs
* Version.          : 1   
*/ 
public class BatchClassToRemoveDuplicateMIDs implements Database.Batchable<sObject> {
    /*********************************Member Variables**********************************/
    public static List<String> setAllowedObject = Label.AllowedObject.split(',');
        /*********************************Member Variables End*****************************/
        
        /****************************Start Method*****************************************/
        public Database.QueryLocator start(Database.BatchableContext BC) {
            String query = Label.BatchClassToRemoveDuplicateMIDsQuery;
            return Database.getQueryLocator(query);
        }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Temporary_Object__c> listSobject) {
        List<Integer> mids = new List<Integer>();
        for(Temporary_Object__c temp : listSobject) {
            mids.add(Integer.valueOf(temp.MID__c));    
        }  
        if(mids.size() > 0) {
            List<AggregateResult> listAggregateResult = [SELECT Count(Id),Name FROM Opportunity WHERE Product__c = 'a0U0p000001OWB6EAO' 
                                                         AND Prod_Merchant_Id__c in :mids
                                                         GROUP BY Name HAVING Count(Id) > 1];
            
            if(listAggregateResult != NULL && listAggregateResult.size() > 0) {
                for (Integer mid: mids){
                    String UUID = '';
                    for(Temporary_Object__c to : [SELECT Id, MID__c,UUID__c FROM Temporary_Object__c WHERE MID__c =:String.valueOf(mid)]) {
                        UUID = to.UUID__c;     
                    }
                    if(String.isNotBlank(UUID)) {
                        Id originalRecordId;
                        Set<Id> setRecordIdNeedToDeleted = new Set<Id>();
                        for(Opportunity opp : [SELECT Id,Identifier__c FROM Opportunity WHERE Product__c = 'a0U0p000001OWB6EAO' 
                                               AND Prod_Merchant_Id__c = :mid]) {
                                                   if(opp.Identifier__c == UUID) {
                                                       originalRecordId = opp.Id;     
                                                   }   
                                                   else {
                                                       
                                                       setRecordIdNeedToDeleted.add(opp.Id);    
                                                   }
                                               }
                        List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
                        List<SObject> listSobjectToUpdate = new List<SObject>();
                        if(originalRecordId != NULL) {
                            Opportunity opp = new Opportunity();
                            opp.Id = originalRecordId;
                            opp.Is_Duplicate__c = 'N';
                            listOpportunityToUpdate.add(opp);
                            if(setRecordIdNeedToDeleted.size() > 0) {
                                for(Id oppId : setRecordIdNeedToDeleted) {
                                    Opportunity opp1 = new Opportunity();
                                    opp1.Id = oppId;
                                    opp1.Is_Duplicate__c = 'Y';
                                    opp1.prod_merchant_id__c = mid * -1;
                                    listOpportunityToUpdate.add(opp1); 
                                    DescribeSObjectResult describeResult = Opportunity.SObjectType.getDescribe();
                                    for (ChildRelationship childRelation : describeResult.getChildRelationships()) {
                                        if(setAllowedObject.contains(String.valueOf(childRelation.getChildSObject()))) {
                                            if(childRelation.getChildSObject().getDescribe().isQueryable()){
                                                SObject[] sobjectRecords = Database.query('SELECT Id,'+childRelation.getField() +' FROM ' + childRelation.getChildSObject() + ' WHERE ' + childRelation.getField() + ' = :oppId');
                                                for (SObject sobj : sobjectRecords) {
                                                    sobj.put(childRelation.getField(),originalRecordId);
                                                    listSobjectToUpdate.add(sobj);
                                                    System.debug('Object to be updated'+sobj);
                                                }
                                            }    
                                        }
                                    }
                                }
                            }
                        }
                        if(listOpportunityToUpdate.size() > 0) {
                            update listOpportunityToUpdate;
                        }
                        if(listSobjectToUpdate.size() > 0) {
                            update listSobjectToUpdate;
                        }
                    }
                }
            }      
        }
        
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}