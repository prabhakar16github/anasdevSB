public class ContractTriggerHandler{  
    
    public static void beforeInsertHandler(List<Contract> triggerNew){  
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Contract'); 
        
        List<Contract> lstContract = new List<Contract>();
        Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
        Map<string,Opportunity> oppObjMap = new Map<string,Opportunity>();  
        set<contract> contractSet = new set<contract>();
        set<string> MIdProductLabelSet = new set<string>();
        set<string> prodNameSet = new set<string>();
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Map<Id,Integer> opMap = new Map<Id,Integer>();
        set<Integer> ProdMerchatIdSet = new set<Integer>(); 
        set<string> ProductLabelSet = new set<string>();
        
        //=========Updated for onboarding revamp if accountId is null========
        Set<Id> oppIds = New Set<Id>();
        Map<String,String> oppIdVsAccountId = New Map<String,String>();
        
        for(Contract contrObj : triggerNew){
            if(contrObj.Status == 'Draft Finalised'){
                //if(contrObj.Status == 'Draft Finalised' || contrObj.Status == 'Pending'){  
                lstContract.add(contrObj); 
            } 
            
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(contrObj, 'Identifier__c', enableUUIDObj);
            
            if(contrObj.StartDate == null){
                contrObj.StartDate = Date.Today();
            }
            if(contrObj.ContractTerm == null){
                contrObj.ContractTerm = 120; // Set it 10 years for now but in PayU Context Agreement End Date doesn't matter.
            }
            //Updated by Sneha for Bulk upload of Addendum
            if(String.isNotBlank(contrObj.MID__c) && String.isNotBlank(contrObj.Product_Label__c) &&
               String.isNotBlank(contrObj.Contract_Type__c)
               && contrObj.Contract_Type__c == 'Addendum' && contrObj.Bulk_Addendum__c == true && String.isNotBlank(contrObj.Document_Type_Name__c)){
                   MIdProductLabelSet.add(contrObj.MID__c+'-'+contrObj.Product_Label__c);
                   ProdMerchatIdSet.add(Integer.valueOf(contrObj.MID__c));  
                   ProductLabelSet.add(contrObj.Product_Label__c);
               }
            
            updateUrlUpdateCount(contrObj, null); 
            
            //==============Updated for Onboarding Revamp============
            if(String.isNotBlank(contrObj.Opportunity__c) && String.isBlank(contrObj.AccountId)) oppIds.add(contrObj.Opportunity__c);
        }
        
        
        if(!MIdProductLabelSet.isEmpty() && MIdProductLabelSet != null && !ProdMerchatIdSet.isEmpty() && ProdMerchatIdSet != null && !ProductLabelSet.isEmpty() && ProductLabelSet != null){
            system.debug('MIdProductLabelSet:'+MIdProductLabelSet);
            for(opportunity eachOpp : [select id, Account.Identifier__c,AccountId,Productlabel__c,MIDProductLabel__c, Prod_Merchant_Id__c  
                                       from opportunity where MIDProductLabel__c IN :MIdProductLabelSet AND Productlabel__c IN :ProductLabelSet AND Prod_Merchant_Id__c IN :ProdMerchatIdSet 
                                       AND RecordTypeId =: OpportunityRecordTypeId Order by lastModifiedDate desc]){
                                           oppObjMap.put(eachOpp.MIDProductLabel__c,eachOpp);
                                       }
        }
        
        system.debug('oppObjMap:'+oppObjMap);
        
        if(!oppObjMap.isEmpty()){
            for(Contract eachContract : triggerNew){
                if( String.isNotBlank(eachContract.Contract_Type__c) && eachContract.Contract_Type__c == 'Addendum'
                   && eachContract.Bulk_Addendum__c == true && String.isNotBlank(eachContract.Product_Label__c) && String.isNotBlank(eachContract.MID__c)){
                       eachContract.Active__c = true;
                       eachContract.Document_Category_Name__c = 'Service Agreement';
                       eachContract.Document_Type_Name__c = 'Addendum';
                       eachContract.Document_Content_Type__c = mapContentType.get('pdf');
                       eachContract.StartDate = date.today();
                       eachContract.ContractTerm = 120;
                       eachContract.KYC_Documentable_Type__c = 'Merchant';
                       string str = eachContract.MID__c +'-'+eachContract.Product_Label__c;
                       if( String.isNotBlank(str) && oppObjMap.containsKey(str) && eachContract.Product_Label__c == oppObjMap.get(str).Productlabel__c){
                           eachContract.Opportunity__c = oppObjMap.get(str).Id;
                           eachContract.AccountId = oppObjMap.get(str).AccountId;
                       }
                   }
            }        
        }
        
        if(!lstContract.isEmpty())        updateEStampValue(lstContract);
        
        //==========updated for onbaording Revamp =============
        if(!oppIds.isEmpty()){
            for(Opportunity eachOpp : [Select Id,AccountId from Opportunity Where Id IN: oppIds]){
                oppIdVsAccountId.put(eachOpp.Id,eachOpp.AccountId);
            }
        }
        
        if(!oppIdVsAccountId.isEmpty()){
            for(Contract eachCont : triggerNew){
                if(String.isNotBlank(eachCont.Opportunity__c) && oppIdVsAccountId.containsKey(eachCont.Opportunity__c) && oppIdVsAccountId.get(eachCont.Opportunity__c) != null){
                    eachCont.AccountId = oppIdVsAccountId.get(eachCont.Opportunity__c);
                }
            }
        }
    }
    
    public static void beforeUpdateHandler(List<Contract> triggerNew, Map<Id, Contract> triggerOldMap){  
        List<Contract> lstContract = new List<Contract>();
        
        //=========Updated for onboarding revamp if accountId is null========
        Set<Id> oppIds = New Set<Id>();
        Map<String,String> oppIdVsAccountId = New Map<String,String>();
        
        for(Contract contrObj : triggerNew){
            if(contrObj.Does_Not_Publish__c == triggerOldMap.get(contrObj.Id).Does_Not_Publish__c && contrObj.Does_Not_Publish__c)
                contrObj.Does_Not_Publish__c = false;
            if(contrObj.Status != triggerOldMap.get(contrObj.Id).Status && contrObj.Status == 'Draft Finalised'){
                lstContract.add(contrObj); 
            }
            Contract oldEachContract = triggerOldMap.get(contrObj.Id);   
            updateUrlUpdateCount(contrObj, oldEachContract);   
            
            //==============Updated for Onboarding Revamp============
            if(String.isNotBlank(contrObj.Opportunity__c) && String.isBlank(contrObj.AccountId)) oppIds.add(contrObj.Opportunity__c);
        }
        if(!lstContract.isEmpty())        updateEStampValue(lstContract);
        
        //==========updated for onbaording Revamp =============
        if(!oppIds.isEmpty()){
            for(Opportunity eachOpp : [Select Id,AccountId from Opportunity Where Id IN: oppIds]){
                oppIdVsAccountId.put(eachOpp.Id,eachOpp.AccountId);
            }
        }
        
        if(!oppIdVsAccountId.isEmpty()){
            for(Contract eachCont : triggerNew){
                if(String.isNotBlank(eachCont.Opportunity__c) && oppIdVsAccountId.containsKey(eachCont.Opportunity__c) && oppIdVsAccountId.get(eachCont.Opportunity__c) != null){
                    eachCont.AccountId = oppIdVsAccountId.get(eachCont.Opportunity__c);
                }
            }
        }
    }
    
    public static void afterInsertHandler(List<Contract> triggerNew){
        System.debug('INSIDE AFTER INSERT');
        System.debug('triggerNew----'+ triggerNew);
        List<Contract> conList = new List<Contract>();
        Set<Id> acntList = new Set<Id>();
        //List<String> accountIds = new List<String>();
        Set<Id> contractIds = new Set<Id>();
        Set<string> setContractId = new set<string>();
        map<string,contract> mapMIdProdContract = new map<string,Contract>();
        map<id,string> mapOppIdAccIdentifier = new map<id,string>();
        String strEndPoint = '';
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Set<String> accountIds = new Set<String>();
        
        Set<string> setWebsiteContractId = new set<string>();
        Set<string> setWebsiteOppContractId = new set<string>();
        List<Opportunity> updWebsiteOppList = new List<Opportunity>();
        Map<Id,List<Contract>> mapAccIdVsListContract = New Map<Id,List<Contract>>();
        Map<String, String> addendumNameVsPageAssociationMap = (Map<String, String>) JSON.deserialize(Label.LazypayAddendum, Map<String, String>.class);
        System.debug('@# addendumNameVsPageAssociationMap'+addendumNameVsPageAssociationMap);
        for(Contract each : TriggerNew){
            if(!each.Does_Not_Publish__c && String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') && !each.Does_Not_Publish__c
               && (each.Status.equalsIgnoreCase('Pending') || each.Status.equalsIgnoreCase('Counter Signed Received') || each.Status.equalsIgnoreCase('Approved') 
                   || each.Status.equalsIgnoreCase('Declined') || each.Status.equalsIgnoreCase('Approved Activate'))){
                       if(!System.isBatch() && each.Data_need_to_be_publish__c){
                           IntegrationUtility.checkMaintenance(each, null, 'Contract', 'Merchant_Document__c');
                       }
                   }
            /*
if(String.isNotBlank(each.Contract_Type__c) &&
each.Contract_Type__c == 'Addendum' && String.isNotBlank(each.MID__c) && String.isNotBlank(each.Product_Label__c) 
&& each.Bulk_Addendum__c == true && String.isNotBlank(each.Opportunity__c)){
setContractId.add(each.Id); 
}
*/
            
            /*System.debug('@@@'+String.isNotBlank(each.Contract_Type__c));
System.debug(each.Status == 'Pending');
System.debug(each.Contract_Type__c == 'Addendum');
System.debug(String.isNotBlank(each.Opportunity__c));
System.debug(addendumNameVsPageAssociationMap.get(each.Name) != null);
*/
            if(String.isNotBlank(each.Contract_Type__c) && each.Contract_Type__c == 'Addendum' && each.Status == 'Pending' 
               && !addendumNameVsPageAssociationMap.isEmpty() && addendumNameVsPageAssociationMap.containsKey(each.Name) && String.isNotBlank(each.Opportunity__c) && addendumNameVsPageAssociationMap.get(each.Name) != null){
                   setWebsiteContractId.add(each.Id); 
               }
            /* =================commented to deploy agreement changes
if(String.isNotBlank(each.Contract_Type__c) &&
each.Contract_Type__c == 'Addendum' && each.Status == 'Approved' 
&& each.Name == 'Website Change Addendum' && String.isNotBlank(each.Opportunity__c)){
setWebsiteOppContractId.add(each.Opportunity__c); 
}
*/
            
            if(String.isNotBlank(each.Type__c) && each.Type__c.equalsIgnoreCase('Final') &&
               String.isNotBlank(each.Status) && each.Status.equalsIgnoreCase('Counter Signed Received')){
                   conList.add(each);
                   acntList.add(each.AccountId);
               }
            
            
            
            if(string.isNotBlank(each.AccountId) && String.isNotBlank(each.Contract_Type__c) &&
               each.Contract_Type__c == 'Agreement') {
                   accountIds.add(each.AccountId);            
                   contractIds.add(each.id);
               }
            system.debug('accountIds+++'+accountIds);
            system.debug('contractIds+++'+contractIds);
        }
        
        
        system.debug('acntLIst=='+acntList);
        if(!conList.isEmpty() && !acntList.isEmpty() ){
            buildAccTeamMemberAndTask(conList, null, acntList);
        }
        
        System.debug('Call Prashant Method');
        Map<Id,Contract> triggerOldMap = new Map<Id,Contract>();
        //if(!contractIds.isEmpty() && !accountIds.isEmpty() ) update_Status(contractIds,accountIds,triggerOldMap);
        
        //==================Update account agreement status==================
        if(!accountIds.isEmpty()) updateAccountStatus(triggerNew,accountIds,true,false);
        /*
if(setContractId != null && setContractId.size() > 0){
//if(!Test.isRunningTest())
//Database.executeBatch(new EMIDashboardAddendumBatch(setContractId,'EMIDashboardAddendum_TP',false));
Database.executeBatch(new EMIDashboardAddendumBatch(setContractId,'EMIDashboardAddendum_TPv2',false));
//updatefileUrl(setContractId,'EMIDashboardAddendum_TP');
}
*/
        system.debug('@@@@@@@@@@ setWebsiteContractId '+setWebsiteContractId);
        if(setWebsiteContractId != null && setWebsiteContractId.size() > 0 && !System.isBatch() && !system.isFuture()){
            Database.executeBatch(new EMIDashboardAddendumBatch(setWebsiteContractId, addendumNameVsPageAssociationMap,false));
        }
        /* ========== commented to deploy greement changes=======
if(setWebsiteOppContractId != null && setWebsiteOppContractId.size() > 0){
system.debug('update opportunity with new website');
for(Opportunity Opp : [Select website__c,New_Website_url__c,Website_Status__c from Opportunity where id in :setWebsiteOppContractId]){
Opp.website__c = Opp.New_Website_url__c != null ?  Opp.New_Website_url__c :  Opp.website__c;
Opp.Website_Status__c = 'Verification in Process';
updWebsiteOppList.add(Opp);
}
}

if(updWebsiteOppList != null && updWebsiteOppList.size() > 0) update updWebsiteOppList;
*/
    }
    
    public static void afterUpdateHandler(List<Contract> triggerNew, Map<Id, Contract> triggerOldMap){
        List<Contract> conList = new List<Contract>();
        Set<Id> acntList = new Set<Id>();
        //List<String> accountIds = new List<String>();
        Set<Id> contractIds = new Set<Id>();
        List<Contract> addendumList = New List<Contract>();
        Set<String> setContractId = New Set<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> payoutContractIds = New Set<String>();
        Set<String> payoutOppIds = New Set<String>();
        List<Opportunity> payoutOpportunities = New List<Opportunity>();
        
        Set<string> setWebsiteOppContractId = new set<string>();
        List<Opportunity> updWebsiteOppList = new List<Opportunity>();
        
        for(Contract each : TriggerNew){
            if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') && 
               (each.Status.equalsIgnoreCase('Pending') || each.Status.equalsIgnoreCase('Counter Signed Received') || each.Status.equalsIgnoreCase('Approved') || each.Status.equalsIgnoreCase('Declined') || each.Status.equalsIgnoreCase('Approved Activate'))){
                   system.debug('check if called from no batch??');
                   if(!System.isBatch() && each.Data_need_to_be_publish__c){
                       system.debug('check if called from batch??');
                       IntegrationUtility.checkMaintenance(each, triggerOldMap.get(each.Id), 'Contract', 'Merchant_Document__c');
                   }
                   /*if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') && each.Bulk_Addendum__c &&
(each.Status.equalsIgnoreCase('Pending') || each.Status.equalsIgnoreCase('Approved'))
&& (each.URL__c != triggerOldMap.get(each.Id).URL__c || each.Active__c != triggerOldMap.get(each.Id).Active__c)
&& each.Contract_Type__c == 'Addendum'){
setContractId.add(each.Id);
}*/
               }
            /* =======commentd to deploy agreement changes======
if(String.isNotBlank(each.Contract_Type__c) &&
each.Contract_Type__c == 'Addendum' && each.Status == 'Approved' 
&& each.Name == 'Website Change Addendum' && String.isNotBlank(each.Opportunity__c)){
setWebsiteOppContractId.add(each.Opportunity__c); 
}
*/
            if((each.Type__c != triggerOldMap.get(each.Id).Type__c || each.Status != triggerOldMap.get(each.Id).Status) &&
               String.isNotBlank(each.Type__c) && String.isNotBlank(each.Status) &&
               each.Type__c.equalsIgnoreCase('Final') && each.Status.equalsIgnoreCase('Counter Signed Received')){
                   conList.add(each);
                   acntList.add(each.AccountId);
               }
            if(each.Status != triggerOldMap.get(each.Id).Status && each.Status=='Approved' && each.Source__c == 'Addendum'){
                addendumList.add(each);
            }
            if(string.isNotBlank(each.AccountId) && (each.Status != triggerOldMap.get(each.Id).Status ||
                                                     each.UrlUpdateCount__c != triggerOldMap.get(each.Id).UrlUpdateCount__c ||
                                                     each.Active__c != triggerOldMap.get(each.Id).Active__c) 
               && each.Contract_Type__c == 'Agreement'
              ){
                  accountIds.add(each.AccountId);
              }
            system.debug('accountIds+++'+accountIds);
            if(string.isNotBlank(each.Id) && each.Status != triggerOldMap.get(each.Id).Status ||
               each.UrlUpdateCount__c != triggerOldMap.get(each.Id).UrlUpdateCount__c){ 
                   contractIds.add(each.id);
               }
            system.debug('contractIds+++'+contractIds);
            
            if(each.Status != triggerOldMap.get(each.Id).Status && each.Status=='Approved' && each.Contract_Type__c == 'PayoutAgreement'){
                payoutContractIds.add(each.Id);
                if(String.isNotBlank(each.Opportunity__c)) payoutOppIds.add(each.Opportunity__c);
                
                Opportunity eachOpp = New Opportunity(Id=each.Opportunity__c,Payout_Activation_Status__c = 'approved');
                payoutOpportunities.add(eachOpp);
            }else if(each.Status != triggerOldMap.get(each.Id).Status && each.Status=='Declined' && each.Contract_Type__c == 'PayoutAgreement'){
                Opportunity eachOpp = New Opportunity(Id=each.Opportunity__c,Payout_Activation_Status__c = 'rejected');
                payoutOpportunities.add(eachOpp);
            }
            
            //==========Check URL update after update==============
            /*if(System.isBatch() && string.isNotBlank(each.AccountId) && each.Active__c == false && each.Status == 'Pending' &&
each.UrlUpdateCount__c != triggerOldMap.get(each.Id).UrlUpdateCount__c && each.Contract_Type__c == 'Agreement'
){
IntegrationUtility.isFutureUpdate = True;
IntegrationUtility.sendPayLoadData(each, triggerOldMap.get(each.Id), 'Contract', 'Merchant_Document__c');
}*/
            /*
if(setWebsiteOppContractId != null && setWebsiteOppContractId.size() > 0){
system.debug('update opportunity with new website');
for(Opportunity Opp : [Select website__c,New_Website_url__c,Website_Status__c from Opportunity where id in :setWebsiteOppContractId]){
Opp.website__c = Opp.New_Website_url__c != null ?  Opp.New_Website_url__c :  Opp.website__c;
Opp.Website_Status__c = 'Verification in Process';
updWebsiteOppList.add(Opp);
}
}

if(updWebsiteOppList != null && updWebsiteOppList.size() > 0) update updWebsiteOppList;
*/
        }
        system.debug('acntLIst=='+acntList);
        if(!conList.isEmpty() && !acntList.isEmpty()){
            buildAccTeamMemberAndTask(conList, null, acntList);
        }
        System.debug('Call Prashant Method from Update');
        //if(!contractIds.isEmpty() && !accountIds.isEmpty()) update_Status(contractIds,accountIds,triggerOldMap);
        if(!accountIds.isEmpty()) updateAccountStatus(triggerNew,accountIds,false,false);
        
        if(addendumList.size()>0){
            //createMMTaskCrossSell(addendumList);
        }
        if(system.isQueueable()){
            system.debug('##### under queuable');
            Set<string> accIds = New Set<string>();
            List<Address_Details__c> lstAddressUpdate = New List<Address_Details__c>();
            for(Contract each : TriggerNew){
                if(String.isNotBlank(each.URL__c) && each.Type__c.equalsIgnoreCase('Final') && 
                   (each.Status.equalsIgnoreCase('Pending') || each.Status.equalsIgnoreCase('Counter Signed Received') || each.Status.equalsIgnoreCase('Approved') || each.Status.equalsIgnoreCase('Declined') || each.Status.equalsIgnoreCase('Approved Activate'))){
                       accIds.add(each.AccountId);
                   }
            }
            system.debug('##### under queuable acc list '+accIds);
            if(!accIds.isEmpty()){
                for(Address_Details__c each : [Select Id,Status__c from Address_Details__c where Account__c IN:accIds]){
                    
                    Address_Details__c newAdd = New Address_Details__c(Id=each.Id);
                    newAdd.Status__c = false;
                    lstAddressUpdate.add(newAdd);
                    
                }
            }
            system.debug('##### under queuable add lst' +lstAddressUpdate);
            if(!lstAddressUpdate.isEmpty())
                update lstAddressUpdate;
        }
        
        System.debug('AWSConsumerBatch.isFinishExecuted>>>>>>>>>>>>>>>>>>>>>'+AWSConsumerBatch.isFinishExecuted);
        if(AWSConsumerBatch.isFinishExecuted) ESBPublisherBatch.sendDataInBatch('Contract', 'Merchant_Document__c');
        
        if(!payoutContractIds.isEmpty() && !payoutoppIds.isEmpty()) EnablePayoutOnMerchant(payoutContractIds,payoutoppIds);
        
        if(!payoutOpportunities.isEmpty()) update payoutOpportunities;
        /*if(setContractId != null && setContractId.size() > 0){
//if(!Test.isRunningTest())
Database.executeBatch(new EMIDashboardAddendumBatch(setContractId,'EMIDashboardAddendum_TP',true));
//updatefileUrl(setContractId,'EMIDashboardAddendum_TP');
}*/
    }
    
    public static void afterDeleteHandler(List<Contract> triggerOld){
        //List<String> accountIds = new List<String>();
        Set<Id> contractIds = new Set<Id>();
        set<String> accountIds = New Set<String>();
        
        for(Contract each : triggerOld){
            if(!each.Does_Not_Publish__c && each.Data_need_to_be_publish__c){
                if(each.Contract_Type__c == 'Agreement') accountIds.add(each.AccountId);
                contractIds.add(each.Id);
                IntegrationUtility.checkMaintenance(each, null, 'Contract', 'Merchant_Document__c'); 
            }
        }
        //if(!contractIds.isEmpty() && !accountIds.isEmpty()) update_Status(contractIds,accountIds,null);
        if(!accountIds.isEmpty()) updateAccountStatus(triggerOld,accountIds,false,true);
    }
    
    private static void buildAccTeamMemberAndTask(List<Contract> triggerNew, Map<Id, Contract> triggerOldMap, Set<Id> acntIds){
        List<AccountTeamMember> listAccMembers = new List<AccountTeamMember>();
        List<AccountShare> listAccSharing = new List<AccountShare>();
        List<Task> listTask = new List<Task>();
        Map<String, List<GroupMember>> mapGrpNameVsListGM = new Map<String, List<GroupMember>>();
        
        try{
            // get the list of Group of 'Risk Group', 'Onboarding Group' and 'Banking Group'
            getListGroup(mapGrpNameVsListGM);
            
            //create new TeamMember and Task
            buildListAccTeamAndTask(triggerNew, listAccMembers, listAccSharing, listTask, mapGrpNameVsListGM, triggerOldMap, acntIds);
            
            if(!listAccMembers.isEmpty())      insert listAccMembers;
            if(!listAccSharing.isEmpty())      insert listAccSharing;
            
            if(!listTask.isEmpty())     insert listTask;
        }
        catch(exception e){
            system.debug('Exception: '+e.getMessage());
        }
    }
    
    private static void getListGroup(map<String, List<GroupMember>> mapGrpNameVsListGM){
        for(Group groupObj : [SELECT id, name, (SELECT id, GroupId, UserOrGroupId FROM GroupMembers) 
                              FROM Group WHERE (Name =: 'Risk Group' OR Name =: 'Onboarding Group' OR Name =: 'Banking Group')])
        {
            if(groupObj.GroupMembers != null && !groupObj.GroupMembers.isEmpty()){
                mapGrpNameVsListGM.put(groupObj.Name, groupObj.GroupMembers);
            }
        }       
    }
    
    private static void buildListAccTeamAndTask(List<Contract> listCon, List<AccountTeamMember> listAccMembers, List<AccountShare> listAccSharing,
                                                List<Task> listTask, map<String, List<GroupMember>> mapGrpNameVsListGM, Map<Id, Contract> oldContractMap, 
                                                Set<Id> listAcc)
    {        
        List<Account> accountList = new List<Account>();
        String strUserId = '';
        accountList = [SELECT Id, Name, Type__c, OwnerId, Onboarding_User_Index__c FROM Account WHERE Id IN: listAcc];
        List<AccountTeamMember> lstAccountTeamMember = [Select UserId, AccountId, TeamMemberRole 
                                                        FROM AccountTeamMember WHERE AccountId IN: listAcc 
                                                        AND (TeamMemberRole =: 'Risk User' OR TeamMemberRole =: 'Onboarding User' OR TeamMemberRole =: 'Banking User')];
        
        Map<Id, Map<String, AccountTeamMember>> mapAccIdVsMapATM = new Map<Id, Map<String, AccountTeamMember>>();
        
        for(AccountTeamMember atmObj : lstAccountTeamMember){
            if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(atmObj.AccountId)){
                mapAccIdVsMapATM.get(atmObj.AccountId).put(atmObj.TeamMemberRole, atmObj);
            }else {                
                mapAccIdVsMapATM.put(atmObj.AccountId, new Map<String, AccountTeamMember> {atmObj.TeamMemberRole => atmObj });
            }
        }           
        system.debug(mapAccIdVsMapATM.size()+'***** mapAccIdVsMapATM ****** '+mapAccIdVsMapATM);
        
        if(!mapGrpNameVsListGM.isEmpty()){
            for(Contract con : listCon){
                for(Account accObj : accountList){
                    if((mapGrpNameVsListGM.containsKey('Onboarding Group') && accObj.Onboarding_User_Index__c != null && String.isNotBlank(accObj.Type__c) && 
                        (accObj.Type__c.equals('Merchant') || accObj.Type__c.equals('Partner'))) || Test.isRunningTest()){                    
                            if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(accObj.Id) 
                               && !mapAccIdVsMapATM.get(accObj.Id).isEmpty() && mapAccIdVsMapATM.get(accObj.Id).containsKey('Onboarding User')){
                                   strUserId = mapAccIdVsMapATM.get(accObj.Id).get('Onboarding User').UserId;
                               }
                            else{
                                strUserId = mapGrpNameVsListGM.get('Onboarding Group')[Integer.valueOf(accObj.Onboarding_User_Index__c)].UserOrGroupId;
                                AccountTeamMember objAccMember = new AccountTeamMember();
                                AccountShare objAccShare = new AccountShare();
                                setupAccTeamSharing(accObj.Id, objAccMember, objAccShare, strUserId, 'Onboarding User');
                                if(objAccMember.UserId != null) listAccMembers.add(objAccMember);
                                if(objAccShare.UserOrGroupId != null) listAccSharing.add(objAccShare);
                            }
                            
                            if(String.isNotBlank(con.Status) && con.Status == 'Counter Signed Received' &&
                               (oldContractMap == null || con.Status != oldContractMap.get(con.Id).Status)){
                                   Task taskObj = new Task();
                                   if(String.isNotBlank(accObj.Type__c) && accObj.Type__c.equals('Merchant')){
                                       buildTask(con, taskObj, strUserId, 'Agreement/Addendum Verification Activity', 'Countersigned agreement received from merchant to be validated.');
                                   }
                                   else if(String.isNotBlank(accObj.Type__c) && accObj.Type__c.equals('Partner')){
                                       buildTask(con, taskObj, accObj.OwnerId, 'Agreement/Addendum Verification Activity', 'Countersigned agreement received from merchant to be validated.');
                                   }
                                   if(taskObj.OwnerId != null)     listTask.add(taskObj);
                               }
                        }
                }
            }
        }
    }
    
    @TestVisible
    private static void setupAccTeamSharing(String accId, AccountTeamMember objAccMember, AccountShare objAccShare, String strUserId, String strRole){
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'Edit';
        //setup account team member
        objAccMember.AccountId = accId;
        objAccMember.TeamMemberRole = strRole;
        objAccMember.UserId = strUserId;
        
        //setup account team member sharing
        objAccShare.AccountAccessLevel = accountAccessLevel;
        objAccShare.OpportunityAccessLevel = OpportunityAccessLevel;
        objAccShare.CaseAccessLevel = caseAccessLevel;
        objAccShare.UserOrGroupId = strUserId;
        objAccShare.AccountId = accId;
    }
    
    // Build Task
    private static void buildTask(Contract conObj, Task taskObj, String strUserId, String strSubject, String comments){       
        taskObj.Status = 'Not Started';
        taskObj.Priority = 'High';
        taskObj.ActivityDate = Date.today();
        taskObj.WhatId = conObj.Id;
        taskObj.Subject = strSubject;
        taskObj.OwnerId = strUserId;
        taskObj.Description = comments;
    }
    
    public static void updateEStampValue(List<Contract> lstContract){
        List<E_Stamp_Master__c> lstEStampUpdate = new List<E_Stamp_Master__c>();
        List<E_Stamp_Master__c> lstEStamp = new List<E_Stamp_Master__c>();
        
        // =========== get the list of E Stamp Master recordbased on E Stamp number in Ascending order and Active is true and used is false and 
        lstEStamp = getEStampMaster();
        system.debug(lstEStamp.size()+' %%%%%%%%% lstEStamp ============= '+lstEStamp );
        
        integer count = 0;
        for(Contract contObj : lstContract){
            if(!lstEStamp.isEmpty() && count <= lstEStamp.size()){
                contObj.E_Stamp__c = lstEStamp.get(count).Id ;
                lstEStampUpdate.add(new E_Stamp_Master__c(Id=lstEStamp.get(count).Id, Used__c=true));
                count++;
            }             
        }
        
        if(!lstEStampUpdate.isEmpty())        update lstEStampUpdate;
    }
    
    public static List<E_Stamp_Master__c> getEStampMaster(){
        return [SELECT Id, EStamp_Number__c, Active__c, Used__c 
                FROM E_Stamp_Master__c 
                WHERE Active__c =: true 
                AND Used__c =: false 
                ORDER BY EStamp_Number__c ASC];
    }
    
    public static void updateUrlUpdateCount(Contract newContract, Contract oldContract){
        If(Trigger.isInsert && String.isNotBlank(newContract.URL__c)){
            newContract.UrlUpdateCount__c = 1;
        }
        else if(Trigger.isUpdate){
            If(String.isBlank(oldContract.URL__c) && String.isNotBlank(newContract.URL__c)){
                newContract.UrlUpdateCount__c = 1;
            }
            else if(newContract.UrlUpdateCount__c != null && newContract.UrlUpdateCount__c >= 1){
                newContract.UrlUpdateCount__c = newContract.UrlUpdateCount__c + 1;
            }
        }
    }  
    
    public static void update_Status(set<Id> ContrList,List<String> acntIds, Map<Id,Contract> triggerOldMap){
        try{
            Map<Id,Account> IdVsAccMap = new Map<Id,Account>();
            List<Account> updatedAccList = new List<Account>();
            List<Contract> listcontrt = [SELECT Id,Active__c,Status,Account.Agreement_Status__c,AccountId,URL__c, Data_need_to_be_publish__c 
                                         FROM Contract 
                                         WHERE Id IN:ContrList AND Contract_Type__c ='Agreement'
                                         ORDER BY LastModifiedDate desc];
            System.debug('update_Status listcontrt '+listcontrt);
            //List<Account> actlist =[Select id, Agreement_Status__c from account where id IN:acntIds];
            for(Account each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(acntIds), '\',\'') + '\')')){
                IdVsAccMap.put(each.Id,each);
            }
            //System.debug('update_Status actlist'+actlist);
            if(!listcontrt.isEmpty() && listcontrt.size() > 0 && !IdVsAccMap.isEmpty()) {
                for(Contract eachContract: listcontrt){
                    if(IdVsAccMap.containsKey(eachContract.AccountId)){
                        Account acc = IdVsAccMap.get(eachContract.AccountId);
                        
                        if(eachContract.Status.equalsIgnoreCase('Approved') && eachContract.Active__c == true 
                           && eachContract.Account.Agreement_Status__c != 'Approved' && String.isNotBlank(eachContract.URL__c)){
                               acc.Agreement_Status__c = 'Approved';
                           }else if(eachContract.Status.equalsIgnoreCase('Counter Signed Received') && eachContract.Active__c == true 
                                    && eachContract.Account.Agreement_Status__c != 'Approved' && String.isNotBlank(eachContract.URL__c)){
                                        acc.Agreement_Status__c = 'Counter Signed Received';
                                    }else if((eachContract.Status.equalsIgnoreCase('Sent') || (eachContract.Status.equalsIgnoreCase('Pending'))
                                              || (eachContract.Status.equalsIgnoreCase('Draft Sent'))) 
                                             && eachContract.Active__c == false && eachContract.Account.Agreement_Status__c != 'Approved' 
                                             && String.isNotBlank(eachContract.URL__c) && 
                                             (eachContract.Account.Agreement_Status__c== 'Not Generated' || (eachContract.Account.Agreement_Status__c== 'Counter Signed Received' && Userinfo.getUserId() != System.label.IntegrationUserId))){
                                                 acc.Agreement_Status__c = 'Sent';
                                             }else if(eachContract.Status.equalsIgnoreCase('Declined') && eachContract.Active__c == true 
                                                      && eachContract.Account.Agreement_Status__c != 'Approved' && String.isNotBlank(eachContract.URL__c)){
                                                          acc.Agreement_Status__c = 'Rejected';
                                                      } 
                        system.debug('#################### triggerOldMap '+triggerOldMap);
                        if(triggerOldMap.isEmpty()){
                            IntegrationUtility.contractAccountIds.add(acc.Id);
                            system.debug('#################### ');
                            if(eachContract.Data_need_to_be_publish__c){
                                IntegrationUtility.sendPayLoadData(acc, null, 'Account', 'Account');
                            }
                            
                        }
                        updatedAccList.add(acc);
                    }
                }
            }
            
            System.debug('update_Status updatedAccList '+updatedAccList);
            if(!updatedAccList.isEmpty()){
                update updatedAccList;
            }            
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getLineNumber());
            System.debug('ERROR:: '+ex.getMessage());
        }
    }  
    
    public static void updateAccountStatus(List<Contract> contractList, Set<String> accountIds,Boolean isInsertTrigger,Boolean isDeleteTrigger){
        Map<Id,Account> accountMap = New Map<Id,Account>();
        List<Account> updatedAccList = new List<Account>();
        Map<Id,List<Contract>> mapAccIdVsListContract = New Map<Id,List<Contract>>();
        try{
            if(!accountIds.isEmpty()){
                for(Account each : Database.query('SELECT (Select Id,Status,Active__c,URL__c from Contracts Where URL__c!=null And Contract_Type__c=\''+'Agreement'+'\' ORDER BY LastModifieddate Desc), ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(accountIds), '\',\'') + '\')')){
                    accountMap.put(each.Id,each);
                }
            }
            system.debug('#################### contractList '+contractList);
            if(!accountMap.isEmpty())    AccountTriggerhandler.getContractsUnderAccount(accountMap.keySet(),mapAccIdVsListContract);
            
            if(!mapAccIdVsListContract.isEmpty()) AccountTriggerhandler.updateAccountAgreementStatus(accountMap.values(), mapAccIdVsListContract);
            /*
if(!accountMap.isEmpty()){
for(Contract eachContract : contractList){
if(accountMap.containsKey(eachContract.AccountId)){
Account accObj = accountMap.get(eachContract.AccountId);
if(accObj.Agreement_Status__c != 'Approved' && String.isNotBlank(eachContract.URL__c) && eachContract.Contract_Type__c=='Agreement'){
if(eachContract.Status.equalsIgnoreCase('Approved') && eachContract.Active__c == true){
accObj.Agreement_Status__c = 'Approved';
}else if(eachContract.Status.equalsIgnoreCase('Counter Signed Received') && eachContract.Active__c == true){
accObj.Agreement_Status__c = 'Counter Signed Received';
}else if(eachContract.Status.equalsIgnoreCase('Declined') && eachContract.Active__c == true){
accObj.Agreement_Status__c = 'Rejected';
}else if((eachContract.Status.equalsIgnoreCase('Sent') || (eachContract.Status.equalsIgnoreCase('Pending'))
|| (eachContract.Status.equalsIgnoreCase('Draft Sent'))) && eachContract.Active__c == false && 
(accObj.Agreement_Status__c== 'Not Generated' || (accObj.Agreement_Status__c== 'Counter Signed Received' && Userinfo.getUserId() != System.label.IntegrationUserId))){
accObj.Agreement_Status__c = 'Sent';
}
system.debug('#################### isInsertTrigger '+isInsertTrigger);
if(isInsertTrigger || accObj.Agreement_Status__c == 'Sent'){
IntegrationUtility.contractAccountIds.add(accObj.Id);
system.debug('#################### ');
if(eachContract.Data_need_to_be_publish__c){
IntegrationUtility.sendPayLoadData(accObj, null, 'Account', 'Account');
}
}
system.debug('#################### isDeleteTrigger '+isDeleteTrigger);
if(isDeleteTrigger){
system.debug('#################### size '+accountMap.get(eachContract.AccountId).Contracts.size());
if(accountMap.get(eachContract.AccountId).Contracts.size()==0){
accObj.Agreement_Status__c = 'Not Generated';
}else if(accountMap.get(eachContract.AccountId).Contracts.size() >0){
if(accountMap.get(eachContract.AccountId).Contracts[0].Status=='Pending')
accObj.Agreement_Status__c = 'Sent';
if(accountMap.get(eachContract.AccountId).Contracts[0].Status=='Approved')
accObj.Agreement_Status__c = 'Approved';
}
}
updatedAccList.add(accObj);
}

}
}
}
*/
            if(!accountMap.values().isEmpty()) update accountMap.values();  
            
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getLineNumber());
            System.debug('ERROR:: '+ex.getMessage());
        }
    }
    
    public static void EnablePayoutOnMerchant(Set<String> payoutContractIds, Set<String> payoutoppIds){
        List<Cross_Sell__c> csList = New List<Cross_Sell__c>();
        Map<string,Cross_Sell__c> oppWithCrossSell = New Map<string,Cross_Sell__c>();
        for(Cross_Sell__c payoutCS : [Select Id,Opportunity__c, User_UUID__c from Cross_Sell__c Where Opportunity__c IN: payoutoppIds AND Custom_Product__r.Name ='Payout']){
            ///payoutCS.Enable_Date__c = System.now();
            oppWithCrossSell.put(payoutCS.Opportunity__c,payoutCS);
            // csList.add(payoutCS);
        }
        // if(!csList.isEmpty()) update csList;
        system.debug('##### EnablePayoutOnMerchant');
        // Get Authentication token for Admin User UUID 
        string accesstoken ='';
        if(!System.isBatch()) getAccessToken(accesstoken,payoutoppIds);
        
        
    }
    
    @future(Callout=true)
    public static void getAccessToken(string accesstoken, Set<String> payoutoppIds){
        if(!Test.isRunningTest()){
            accesstoken = IntegrationUtility.getAuthToken('Payout_Authentication');
        }else{
            accesstoken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
        }
        system.debug('###### accesstoken '+accesstoken);
        Map<string,Cross_Sell__c> oppIdWithCrossSellMap = New Map<String,Cross_Sell__c>();
        List<Cross_Sell__c> csObjList = New List<Cross_Sell__c>();
        Map<String,Opportunity> oppDataMap = New Map<string,Opportunity>();
        
        if(string.isNotBlank(accesstoken)){
            HttpResponse response = New HttpResponse();
            Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('Payout_get_user_uuid');
            HttpRequest req = new HttpRequest();
            for(Opportunity opp : [Select Id,Identifier__c,First_Name__c ,Last_Name__c,Email__c,Mobile__c,Prod_MID__c,(Select Id,User_UUID__c,Bank_Name__c,Merchant_Name__c,Opportunity_Identifier__c,Merchant_Email_Formula__c,Merchant_Mobile__c,Prod_Merchant_Id__c,Response__c,Enable_Date__c From Cross_Sells__r Where Custom_Product__r.Name ='Payout') from Opportunity where Id IN : payoutoppIds]){
                req.setEndpoint(theIntIns.EndPointUrl__c+opp.Identifier__c);
                req.setMethod(theIntIns.Method__c);
                req.setCompressed(theIntIns.SetCompressed__c);
                req.setHeader('Authorization', 'Bearer ' + accesstoken);
                if(opp.Cross_Sells__r != null) oppIdWithCrossSellMap.put(opp.Identifier__c,opp.Cross_Sells__r);
                oppDataMap.put(opp.Identifier__c,opp);
            }
            req.setTimeout(120000);
            if(!test.isRunningTest()) {
                response = new Http().send(req);
            }
            system.debug('###### response.getStatusCode '+response.getStatusCode());
            if(response.getStatusCode() == 200 || Test.isRunningTest()){
                Map<String, Object> theResMap ;
                if(!Test.isRunningTest()){
                    theResMap = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());
                }else{
                    theResMap = (Map<String, Object>)JSON.deserializeUntyped('{"merchants": [{"admin_user_uuid": "11eb-50c3-247600b4-9cc4-02f413145cce","uuid": "11eb-50c3-19ac023c-93c8-02053299b2da"}]}');
                }
                Object deserializedMerchantData = theResMap.get('merchants');
                String serializedMerchantData = JSON.serialize(deserializedMerchantData);
                List<Object> merchantDataListResponse = (List<Object>) JSON.deserializeUntyped(serializedMerchantData);
                string payoutAccessToken = '';
                
                for(Integer i=0;i<merchantDataListResponse.size();i++) {
                    String strLine = JSON.serialize(merchantDataListResponse[i]);
                    Map<String, Object> responseMapLine = (Map<String, Object>) JSON.deserializeUntyped(strLine);
                    system.debug('responseMapLine2200 : '+responseMapLine);
                    if(responseMapLine.containsKey('admin_user_uuid')){
                        system.debug('responseMapLine22 : '+responseMapLine.get('admin_user_uuid'));
                        system.debug('responseMapLine2222 : '+responseMapLine.get('uuid'));
                        system.debug('oppIdWithCrossSellMap : '+oppIdWithCrossSellMap);
                        if(responseMapLine.containsKey('uuid')){
                            if(!oppIdWithCrossSellMap.isEmpty()){
                                string merchantUUID = String.valueOf(responseMapLine.get('uuid'));
                                string merchantAdminUUID = String.valueOf(responseMapLine.get('admin_user_uuid'));
                                if(oppIdWithCrossSellMap.containsKey(merchantUUID)){
                                    Cross_Sell__c csObj = oppIdWithCrossSellMap.get(String.valueOf(responseMapLine.get('uuid')));
                                    csObj.User_UUID__c = merchantAdminUUID;
                                    
                                    // Call Payout Activation token API
                                    // payoutAccessToken = getPayoutActivationToken('Payout_Authentication_For_Activation');
                                    // system.debug('payoutAccessToken : '+payoutAccessToken);
                                    
                                    //if(String.isNotBlank(payoutAccessToken)){
                                    string responseBody = getPayoutActivationResponse(payoutAccessToken, oppDataMap, merchantAdminUUID, merchantUUID, csObj);
                                    system.debug('####responseBody : '+responseBody);
                                    csObj.Response__c = responseBody;
                                    csObj.Enable_Date__c = System.now();
                                    //}
                                    csObjList.add(csObj);
                                }
                            }
                        }
                    }
                }
            }
            if(!csObjList.isEmpty()) update csObjList;
        }
    }
    /*
public static string getPayoutActivationToken(string metaName){
Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting(metaName);
if(theIntIns != null){            
HttpResponse response = New HttpResponse();
HttpRequest req = new HttpRequest();

String endPointStr = theIntIns.EndPointUrl__c;        
req.setEndpoint(endPointStr);
req.setMethod(theIntIns.Method__c);
req.setCompressed(theIntIns.SetCompressed__c);
List<String> bodyParams = new List<String>();
if(String.isNotBlank(theIntIns.Body__c)){
for(String each : theIntIns.Body__c.split(',')){                     
String bodayParamVal = each.subStringAfter(':');                
if(String.isNotBlank(bodayParamVal)){
bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));  
}                     
}
}

if(String.isNotBlank(theIntIns.Headers__c)){
for(String each : theIntIns.Headers__c.split(',')){
req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
}
}

if(!bodyParams.isEmpty()){
req.setBody(String.join(bodyParams, '&')); 
}
req.setTimeout(120000);
System.debug('req>>>>>>>'+req);
if(!test.isRunningTest())   response = new Http().send(req);

if(!test.isRunningTest()){
if(response.getStatusCode() == 200){
Map<String, Object> theResMap = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());

if(theResMap.containsKey('access_token')){
return String.valueOf(theResMap.get('access_token'));
}
} 
}else{
return '2345dfgyh34567dfghj';
}
}
return '';
}
*/
    public static string getPayoutActivationResponse(string payoutAccessToken, Map<string,Opportunity> oppDataMap, string merchantAdminUUID, string identifier, Cross_Sell__c csObjData){
        List<Payload_Log__c> payloadLogList = New List<Payload_Log__c>();
        List<Error_Details__c> errorDetailsList = New List<Error_Details__c>();
        HttpResponse response = New HttpResponse();
        string responseBody = '';
        
        if(!oppDataMap.isEmpty()){
            if(!Test.isRunningTest()){
                payoutAccessToken = IntegrationUtility.getAuthToken('Payout_Authentication_For_Activation');
            }else{
                payoutAccessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }
            
            if(string.isNotBlank(payoutAccessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('Payout_Activation');
                response = IntegrationUtility.requestUtility(theIntIns, False, payoutAccessToken, csObjData, null, null);
                
                if(response != null && response.getStatusCode() == 200){
                    Payload_Log__c plLog = New Payload_Log__c(Payload__c = response.getBody(),Process__c = 'Payout Activation Merchant',Prod_MID__c = csObjData.Prod_Merchant_Id__c,Status__c = 'SUCCESS',SalesforceRecordId__c = csObjData.Id);
                    payloadLogList.add(plLog);
                    responseBody = response.getBody();
                }else{
                    Error_Details__c edLog = New Error_Details__c(Process__c = 'Payout Activation Merchant');
                    if(response != null && response.getBody() != null) {
                        edLog.Response__c = response.getBody();
                        responseBody = response.getBody();
                    }
                    errorDetailsList.add(edLog);
                }
            }
        }
        
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
        /*
List<String> bodyParams = new List<String>();

if(String.isNotBlank(theIntIns.Body__c)){
for(String each : theIntIns.Body__c.split(',')){ 
String bodayParamVal = '';
if(each.subStringAfter(':').contains(';')){
string merchantName = '';
for(String eachFor : each.subStringAfter(':').split(';')){
string merchantFirstName = '';
if(String.isNotBlank(String.valueOf(oppDataMap.get(identifier).get('First_Name__c')))){
merchantFirstName = String.valueOf(oppDataMap.get(identifier).get(eachFor.subStringBefore(';')));
}
if(String.isNotBlank(String.valueOf(oppDataMap.get(identifier).get('Last_Name__c')))){
merchantName = merchantFirstName + ' ' +String.valueOf(oppDataMap.get(identifier).get('Last_Name__c'));
}
}

if(String.isNotBlank(merchantName)){
bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(merchantName, 'UTF-8'));
}
}else if(each.subStringBefore(':') == 'bank'){
if(String.isNotBlank(csObjData.Bank_Name__c)){
bodayParamVal = csObjData.Bank_Name__c; 
}else{
bodayParamVal = 'citibank';
}
if(String.isNotBlank(bodayParamVal)){
bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));  
}
}
else if(String.isNotBlank(String.valueOf(oppDataMap.get(identifier).get(each.subStringAfter(':'))))){
bodayParamVal = String.valueOf(oppDataMap.get(identifier).get(each.subStringAfter(':')));                
if(String.isNotBlank(bodayParamVal)){
bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));  
}
}

}
}

if(String.isNotBlank(theIntIns.Headers__c)){
for(String each : theIntIns.Headers__c.split(',')){
if(each.subStringBefore(':') == 'uuid'){
req.setHeader(each.subStringBefore(':'), merchantAdminUUID);
}else
req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
}
}

if(String.isNotBlank(payoutAccessToken)){
req.setHeader('Authorization', 'Bearer ' + payoutAccessToken);
}

if(!bodyParams.isEmpty()){
req.setBody(String.join(bodyParams, '&')); 
}
system.debug('####bodyParams : '+bodyParams);
req.setTimeout(120000);
if(!test.isRunningTest()) response = new Http().send(req);

if(!test.isRunningTest()){
if(response.getStatusCode() == 200){
system.debug('####responseBody 333: '+response.getBody());
return response.getBody();
} 
}else{
return 'sfdgfhetrytucvb';
}
*/
        return responseBody;
    }
}