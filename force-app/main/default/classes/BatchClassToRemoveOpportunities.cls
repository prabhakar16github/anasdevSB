/*
* Name of the class : BatchClassToRemoveOpportunities
* Author's Name     : Anas Yar Khan  
* Created Date      : 21th Oct, 2022
* Description       : Batch class to remove duplicate BFL Opportunities
* Version.          : 1   
*/
global class BatchClassToRemoveOpportunities implements Database.Batchable<AggregateResult> {
    /*********************************Member Variables**********************************/
    private String query = '';
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public BatchClassToRemoveOpportunities(String query) {
        this.query = query;
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        return new AggregateResultIterable(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        Set<Id> setAccountId = new Set<Id>();
        for(sObject sObj : scope)  {
            AggregateResult ar = (AggregateResult)sObj;
            setAccountId.add((Id)ar.get('AccountId'));    
        }
        System.debug('setAccountId-->'+setAccountId);
        if(setAccountId.size() > 0) {
            Map<Id,Opportunity> mapIdToOpportunity = new Map<Id,Opportunity>([SELECT Id,Merchant_Account_Id__c 
                                                                              FROM Opportunity 
                                                                              WHERE AccountId IN :setAccountId 
                                                                              AND Aggregator_UUID__c = '11ed-e4ea-b74b48aa-929c-02e708f88ebc']);
            
            System.debug('mapIdToOpportunity-->'+mapIdToOpportunity);
            if(mapIdToOpportunity != NULL && mapIdToOpportunity.keySet().size() > 0) {
                Map<Id,Lead> mapOpportunityIdToLeadId = new Map<Id,Lead>();
                for(Lead ld : [SELECT Id,Merchant_Account_Id__c,Active__c,Average_Ticket_Size__c,BusinessCategory__c,Business_Entity__c,Client_Name_New__c,Company_Registration_No__c,
                               Country__c,Date_of_Incorporation__c,Date_of_Registration__c,Delivery_Duration__c,Device__c,EOTP_Verified__c,
                               Expected_Approval_Rate__c,Expected_Monthly_Txn_Count__c,Legal_Name__c,LOB_Status__c,
                               Merchant_Business_Type__c,Merchant_Trading_Name__c,Prod_Merchant_Id__c,Monthly_Expected_Sale__c,
                               MOTP_Verified__c,Online_Lead__c,Business_Category_Other__c,Sub_Category_Other__c,Partner_UUID__c,
                               Product_Service_Description__c,Quality_Score__c,Registration_URL__c,Risk_Auto_Approved__c,Sub_Category__c,
                               TAN_Number__c,Tenure_In_Business__c,Tenure_In_PayU__c,Website__c,Transaction_Facility_Required__c,Wallet_Share__c,Website,ConvertedOpportunityId
                               FROM Lead WHERE ConvertedOpportunityId IN :mapIdToOpportunity.keySet()]) {
                                   mapOpportunityIdToLeadId.put(ld.ConvertedOpportunityId,ld);	   
                               }
                if(mapOpportunityIdToLeadId.keySet().size() > 0) {
                    Map<Id,Account> mapOpportunityIdToAccount = new Map<Id,Account>();
                    for(Id oppId : mapIdToOpportunity.keySet()) {
                        Opportunity opp = mapIdToOpportunity.get(oppId);
                        Account acc = new Account();
                        
                        acc.Merchant_Account_Id__c = opp.Merchant_Account_Id__c;
                        if(mapOpportunityIdToLeadId.containsKey(oppId)) {
                            Lead ld = mapOpportunityIdToLeadId.get(oppId);
                            acc.Name = ld.Legal_Name__c;
                            acc.Average_Ticket_Size__c  = ld.Average_Ticket_Size__c ;
                            acc.Business_Category__c   = ld.BusinessCategory__c    ;
                            acc.Business_Entity__c  = ld.Business_Entity__c  ;
                            acc.Company_Registration_No__c = ld.Company_Registration_No__c ;
                            acc.Market__c  = ld.Country__c ;
                            acc.Date_of_Incorporation__c = ld.Date_of_Incorporation__c ;
                            acc.Date_of_Registration__c = ld.Date_of_Registration__c ;
                            acc.Delivery_Duration__c = ld.Delivery_Duration__c ;
                            acc.Device__c = ld.Device__c ;
                            acc.EOTP_Verified__c = ld.EOTP_Verified__c ;
                            acc.Expected_Monthly_Txn_Count__c = ld.Expected_Monthly_Txn_Count__c ;
                            acc.Expected_Approval_Rate__c = ld.Expected_Approval_Rate__c ;
                            acc.Legal_Name__c = ld.Legal_Name__c ;
                            //acc.New_Legal_Name__c = ld.New_Legal_Name__c ;
                            acc.LOB_Status__c = ld.LOB_Status__c ;
                            //system.debug(acc.Merchant_Account_Identifier__c);
                            //acc.Merchant_Account_Identifier__c = ld.Merchant_Account_Identifier__c;
                            acc.Merchant_Account_Id__c = ld.Merchant_Account_Id__c ;
                            acc.Merchant_Business_Type__c = ld.Merchant_Business_Type__c ;
                            acc.Merchant_Trading_Name__c = ld.Merchant_Trading_Name__c ;
                            acc.Prod_Merchant_Id__c = ld.Prod_Merchant_Id__c ;
                            acc.Monthly_Expected_Sale__c = ld.Monthly_Expected_Sale__c ;
                            acc.MOTP_Verified__c = ld.MOTP_Verified__c ;
                            acc.isConverted__c = ld.Online_Lead__c ;
                            acc.Business_Category_Other__c = ld.Business_Category_Other__c ;
                            acc.Sub_Category_Other__c = ld.Sub_Category_Other__c ;
                            acc.Partner_UUID__c = ld.Partner_UUID__c ;
                            acc.Product_Service_Description__c = ld.Product_Service_Description__c ;
                            acc.Quality_Score__c = ld.Quality_Score__c ;
                            //acc.Region__c = ld.Region__c ;
                            acc.Registration_URL__c = ld.Registration_URL__c ;
                            acc.Risk_Auto_Approved__c = ld.Risk_Auto_Approved__c ;
                            acc.Sub_Category__c = ld.Sub_Category__c ;
                            acc.TAN_Number__c = ld.TAN_Number__c ;
                            acc.Tenure_In_Business__c = ld.Tenure_In_Business__c ;
                            acc.Tenure_In_PayU__c = ld.Tenure_In_PayU__c ;
                            acc.Transaction_Facility_Required__c= ld.Transaction_Facility_Required__c; 
                            acc.Wallet_Share__c = ld.Wallet_Share__c ;
                            acc.Website__c = ld.Website__c ;
                            acc.Website= ld.Website; 
                        }
                        mapOpportunityIdToAccount.put(oppId,acc);
                    }
                    System.debug('mapOpportunityIdToAccount-->'+mapOpportunityIdToAccount);
                    if(mapOpportunityIdToAccount.keySet().size() > 0) {
                        insert mapOpportunityIdToAccount.values();
                        
                        List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
                        for(Id oppId : mapOpportunityIdToAccount.keySet()) {
                            Opportunity opp = new Opportunity();
                            opp.Id = oppId;
                            opp.AccountId = mapOpportunityIdToAccount.get(oppId).Id;
                            listOpportunityToUpdate.add(opp);
                        }   
                        System.debug('listOpportunityToUpdate-->'+listOpportunityToUpdate);
                        if(listOpportunityToUpdate.size() > 0) {
                            update listOpportunityToUpdate;
                        }
                        /*
                        Map<String,Id> mapProductIdentifierToContactId = new Map<String,Id>();
                        for(Contact con : [SELECT Id,Product_Account_Identifier__c FROM Contact WHERE AccountId IN :setAccountId]) {
                            mapProductIdentifierToContactId.put(con.Product_Account_Identifier__c,con.Id);    
                        }
                        Map<String,Id> mapAccountIdentifierToAccountId = new Map<String,Id>();
                        for(Opportunity opp : [SELECT Id,AccountId,Identifier__c FROM Opportunity WHERE Identifier__c IN :mapProductIdentifierToContactId.keySet()]) {
                            mapAccountIdentifierToAccountId.put(opp.Identifier__c,opp.AccountId);   
                        }
                        
                        List<Contact> listContactToUpdate = new List<Contact>();
                        for(String key : mapProductIdentifierToContactId.keySet()) {
                            Contact con = new Contact();
                            con.Id = mapProductIdentifierToContactId.get(key);
                            con.AccountId = null;
                            listContactToUpdate.add(con);
                        }
                        if(listContactToUpdate.size() > 0) {
                            update listContactToUpdate;
                        }
                        
                      	listContactToUpdate = new List<Contact>();
                        for(String key : mapProductIdentifierToContactId.keySet()) {
                            Contact con = new Contact();
                            con.Id = mapProductIdentifierToContactId.get(key);
                            con.AccountId = mapAccountIdentifierToAccountId.get(key);
                            listContactToUpdate.add(con);
                        }
                        if(listContactToUpdate.size() > 0) {
                            update listContactToUpdate;
                        }*/
                    }
                }
            }
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    global void finish(Database.BatchableContext bc){
        
    }
    /****************************Finish Method End ********************************/
}