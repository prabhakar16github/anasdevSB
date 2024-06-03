/*
* Name of the class : CreateCommercialsForExistingMerchant
* Author's Name     : Anas Yar Khan  
* Created Date      : 8th Dec, 2023
* Description       : Batch class to create commercials for existing merchants
* Version.          : 1   
*/ 
public class CreateCommercialsForExistingMerchant implements Database.Batchable<sObject> {
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Prod_Merchant_Id__c FROM Opportunity WHERE Aggregator_UUID__c != \'11ed-e4ea-b74b48aa-929c-02e708f88ebc\' AND Prod_Merchant_Id__c != NULL'; 
        return Database.getQueryLocator(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<Opportunity> listOpportunity) {
        List<Commercial2__c> listCommercialsToInsert = new List<Commercial2__c>();
        for(Opportunity opp : listOpportunity) {
            Commercial2__c comm = new Commercial2__c();
            comm.Name = 'Existing Commercial for '+opp.Prod_Merchant_Id__c;
            comm.Opportunity__c = opp.Id;
            comm.Source__c = 'System Migrated';
            comm.Status__c = 'Draft';
            comm.Last_Edited_On__c = System.now();
            listCommercialsToInsert.add(comm);
        }
        
        if(listCommercialsToInsert.size() > 0) {
            Database.SaveResult[] saveResultList = Database.insert(listCommercialsToInsert,false);
            List<Error_Details__c> listErrorDetailsToInsert = new List<Error_Details__c>();
            for (Integer i=0;i<listCommercialsToInsert.size();i++) {
                Database.SaveResult sr = saveResultList[i];
                if (!sr.isSuccess()) {
                    Error_Details__c errorDetails = new Error_Details__c(Process__c = 'CreateCommercialsForExistingMerchant',Message__c = String.valueOf(sr.getErrors()),SF_Record_Name__c  = 'Commercial2__c',Severity__c = 'High', Request__c = String.valueOf(sr), Identifier__c = listCommercialsToInsert[i].Opportunity__c);
                    listErrorDetailsToInsert.add(errorDetails);    
                }
            }
            if(listErrorDetailsToInsert.size() > 0) insert listErrorDetailsToInsert;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
    
}