public class AccountTriggerHandler {    
    
    public static boolean isInserted = false;
    public static Boolean executeTriggerHandler = true;
    
    /*----------------------------------------------------------------
Description: method call FROM Account trigger at before insert
-----------------------------------------------------------------*/ 
    public static void beforeInsertHandler(List<Account> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Account');
        Set<Id> setBusinessCategory = new Set<Id>();        
        List<Account> lstAcc = new List<Account>();
        
        Set<String> setLegalName = new Set<String>();
        Set<String> setPanNum = new Set<String>();
        Set<String> setClientNameId = new Set<String>();
        Map<Id, String> mapAccIdVsLP = new Map<Id, String>();
        Set<Id> subCategoryIds = new Set<Id>();
        
        for(Account each : triggerNew){
            updateType(each);
            // ========= Get the Identifier field value ===================         
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj); 
            
            // ======== update LOB status and Risk Auto Approved fields value
            String AccRTId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();            
            
            if(each.RecordTypeId != AccRTId
               && String.isNotEmpty(each.Transaction_Facility_Required__c)
               && each.Delivery_Duration__c != null && each.NDX_Score__c != null && each.Business_Category__c != null){
                   lstAcc.add(each);
                   setBusinessCategory.add(each.Business_Category__c);
               }
            
            updateAccountName(each, null, AccRTId);
            
            if(each.Type__c == 'Partner'){                
                if(String.isNotBlank(each.Legal_Name__c) && String.isNotBlank(each.PAN_Number__c)){
                    setLegalName.add(each.Legal_Name__c);
                    setPanNum.add(each.PAN_Number__c);
                }
            }
            //=============Commenting the Code as Wibmo team is not using the product==============
            /*if(each.Type__c == 'Wibmo'){              
                if(String.isNotBlank(each.Client_Name_New__c)){
                    setClientNameId.add(each.Client_Name_New__c); 
                } 
            }
            */
            //===============update delivery duration===============================//
            if(string.isNotBlank(each.Business_Category__c) && string.isNotBlank(each.Sub_Category__c)){
                subCategoryIds.add(each.Sub_Category__c);
            }           
            //==============update delivery end=====================================//
            
            //============update Document & Agreement status for skip Id==================
            if(each.Skip_Document_Verification__c){
                each.Document_Status__c = 'Docs Approved';
            }
            if(each.Skip_Agreement_Verification__c){
                each.Agreement_Status__c = 'Approved';
            }
            if(each.Document_Status__c == 'Docs Approved'){
                each.PAN_Verification_Status__c = 'Success';
            }
        }
        
        createAccountReseller(triggerNew, setLegalName, setPanNum);
        
        //==========Commenting the Code as Wibmo team is not using the Product======
        //if(!setClientNameId.isEmpty()) createParentAccountWibmo(triggerNew, setClientNameId);     
        
        if(!lstAcc.isEmpty())   updateLOBAndRiskAutoApproved(lstAcc, setBusinessCategory); 
        
        //===============update delovery duraion ====================
        if(!subCategoryIds.isEmpty()) updateDeliveryDuration(subCategoryIds,triggerNew);        
        // ===============delivery duration end
    }
    
    /*----------------------------------------------------------------
Description:    method to call at before update
-----------------------------------------------------------------*/
    public static void beforeUpdateHandler(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        Set<Id> setAccId = new Set<Id>();
        Map<Id, List<Opportunity>> mapAccIdVsListOpp = new Map<Id, List<Opportunity>>();
        List<Account> lstAcntWithoutMID = new List<Account>();
        Set<Id> setBusinessCategory = new Set<Id>();        
        List<Account> lstAcc = new List<Account>();
        Integer errorDocStatusCount = 0;
        Integer receivedDocStatusCount = 0;
        Integer approvedDocStatusCount = 0;
        Integer pendingDocStatusCount = 0;
        Map<Id,string> idWithDocStatusMap = new Map<Id,string>();
        Set<Id> subCategoryIds = new Set<Id>();
        Map<Id, List<Contract>> mapAccIdVsListContract = New Map<Id, List<Contract>>();
        Set<Id> contAccountIds = New Set<Id>();
        String AccRTId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        
        for(Account accObj : triggerNew){
            /***
* Commenting the code as currently we are not using aggregator
* 
if(accObj.Type__c != null && accObj.Type__c == 'Aggregator' && triggerOldMap.get(accObj.id).Type__c != 'Aggregator'){
setAccId.add(accObj.id);
}
*/
           /* //Prashant
            if(accObj.Skip_Document_Verification__c == null || triggerOldMap.get(accObj.id).Skip_Document_Verification__c != True ||
            accObj.Skip_Agreement_Verification__c == null || triggerOldMap.get(accObj.id).Skip_Agreement_Verification__c != True){
               setAccId.add(accObj.id);
               system.debug('@Prashant Testing'+setAccId);
            }
            //Prashant */
            
            if((system.isBatch() && accObj.Document_Status__c == 'Docs Approved' && 
                accObj.Document_Status__c != triggerOldMap.get(accObj.Id).Document_Status__c) || test.isRunningTest()){
                    accObj.All_Approved_KYC_Documentable_type__c = true;
                }
            /*****
* Commented the code by Shivdeep, as currently there is not required for this on report
* 
// Added for capturing days of Doc Recieved To Docs Error/Approved     
Integer count = 0;          
if(accObj.Document_Status__c == 'Docs Received' && triggerOldMap.get(accObj.id).Document_Status__c != 'Docs Received'){
accObj.Document_Received_Time__c = System.now();
if(accObj.Count_Document_Status_updated__c != null)
accObj.Count_Document_Status_updated__c += 1;  
else
accObj.Count_Document_Status_updated__c = 1;                     
}
if(accObj.Document_Received_Time__c != null && (accObj.Document_Status__c == 'Docs Approved' || accObj.Document_Status__c == 'Docs Error') && triggerOldMap.get(accObj.id).Document_Status__c == 'Docs Received'){
DateTime fromDt = (DateTime)Date.newinstance(accObj.Document_Received_Time__c.year(),accObj.Document_Received_Time__c.month(),accObj.Document_Received_Time__c.day()+1);
DateTime toDt = (DateTime)Date.newinstance(System.now().year(),System.now().month(),System.now().day()-1);
//System.now(); 

while (fromDt < toDt)
{
if (fromDt.format('EEE') != 'Sat' && fromDt.format('EEE') != 'Sun')
{
count = count + 1;
}
fromDt= fromDt.addDays(1);
}
accObj.Duration__c = count*24;
if((accObj.Document_Received_Time__c.format('EEE') == 'Sat' || accObj.Document_Received_Time__c.format('EEE') == 'Sun') &&
(System.now().format('EEE') != 'Sat' && System.now().format('EEE') != 'Sun'))
accObj.Duration__c = System.now().hour();
if((accObj.Document_Received_Time__c.format('EEE') != 'Sat' && accObj.Document_Received_Time__c.format('EEE') != 'Sun') &&
(System.now().format('EEE') == 'Sat' || System.now().format('EEE') == 'Sun'))
accObj.Duration__c = 24 - accObj.Document_Received_Time__c.hour();

if(accObj.Total_Duration__c != null)
accObj.Total_Duration__c += accObj.Duration__c;
else
accObj.Total_Duration__c = accObj.Duration__c;     

}
*/
            // ======== update LOB status and Risk Auto Approved fields value ============
            
            if(accObj.RecordTypeId != AccRTId
               && (accObj.Transaction_Facility_Required__c != triggerOldMap.get(accObj.id).Transaction_Facility_Required__c
                   || accObj.Delivery_Duration__c != triggerOldMap.get(accObj.id).Delivery_Duration__c || accObj.NDX_Score__c != triggerOldMap.get(accObj.id).NDX_Score__c || accObj.Business_Category__c != triggerOldMap.get(accObj.id).Business_Category__c)
               && String.isNotEmpty(accObj.Transaction_Facility_Required__c) && accObj.Delivery_Duration__c != null && accObj.NDX_Score__c != null && accObj.Business_Category__c != null)
            {
                lstAcc.add(accObj);
                setBusinessCategory.add(accObj.Business_Category__c);
            }
            
            //============ Used to update the Document status for longTail merchants============
            //============Commenting the Code due to Onboarding Revamp==================
            /*if(accObj.Total_Required_Merchant_Documents_New__c > 0 && accObj.Total_Required_Merchant_Documents__c >0 &&
               (accObj.Total_Docs_Onboarding_Status_Approved__c != triggerOldMap.get(accObj.id).Total_Docs_Onboarding_Status_Approved__c 
                || accObj.Total_Docs_Received_Status_Received__c != triggerOldMap.get(accObj.id).Total_Docs_Received_Status_Received__c 
                || accObj.Total_Docs_Onboarding_Status_Decline__c != triggerOldMap.get(accObj.id).Total_Docs_Onboarding_Status_Decline__c
                || accObj.Total_Docs_Onboarding_Status_Pending__c != triggerOldMap.get(accObj.id).Total_Docs_Onboarding_Status_Pending__c
                || accObj.Document_Status__c != triggerOldMap.get(accObj.id).Document_Status__c
               ) && accObj.Merchant_Business_Type__c=='LongTail' && !accObj.Skip_Document_Verification__c)
                
            {   
                if(accObj.Total_Required_Merchant_Documents__c >= accObj.Total_Required_Merchant_Documents_New__c &&
                   accObj.Total_Docs_Onboarding_Status_Decline__c > 0 
                   && accObj.Total_Docs_Onboarding_Status_Approved__c < accObj.Total_Required_Merchant_Documents_New__c
                   && accObj.Total_Docs_Onboarding_Approve_Receiced__c < accObj.Total_Required_Merchant_Documents_New__c
                   && accObj.Document_Status__c != 'Docs Approved'){
                       errorDocStatusCount++;
                       approvedDocStatusCount = 0;
                       receivedDocStatusCount = 0;
                       pendingDocStatusCount = 0;
                       system.debug('INSIDE Error');
                   } 
                else if(accObj.Total_Required_Merchant_Documents__c >= accObj.Total_Required_Merchant_Documents_New__c &&
                        accObj.Total_Docs_Onboarding_Status_Decline__c <= 0 
                        && accObj.Total_Docs_Received_Status_Received__c > 0
                        && accObj.Total_Docs_Onboarding_Status_Approved__c < accObj.Total_Required_Merchant_Documents_New__c
                        && (accObj.Total_Docs_Onboarding_Approve_Receiced__c >= accObj.Total_Required_Merchant_Documents_New__c
                            || accObj.Total_Docs_Received_Status_Received__c >= accObj.Total_Required_Merchant_Documents_New__c
                           )
                        && accObj.Total_Docs_Received_Status_Received__c > 0 && accObj.Document_Status__c != 'Docs Approved'){
                            errorDocStatusCount = 0;
                            approvedDocStatusCount = 0;
                            receivedDocStatusCount++;
                            pendingDocStatusCount = 0;
                            system.debug('INSIDE Received');
                        }
                else if (accObj.Total_Required_Merchant_Documents__c >= accObj.Total_Required_Merchant_Documents_New__c &&
                         accObj.Total_Docs_Onboarding_Status_Decline__c <= 0 
                         && accObj.Total_Docs_Onboarding_Status_Approved__c > 0
                         && (accObj.Total_Docs_Onboarding_Approve_Receiced__c >= accObj.Total_Required_Merchant_Documents_New__c
                             || accObj.Total_Docs_Onboarding_Status_Approved__c >= accObj.Total_Required_Merchant_Documents_New__c
                            )
                         && accObj.Document_Status__c != 'Docs Approved'){
                             errorDocStatusCount = 0;
                             approvedDocStatusCount ++;
                             receivedDocStatusCount = 0;
                             pendingDocStatusCount = 0;
                             system.debug('INSIDE Approved');
                         }
                else if (accObj.Total_Required_Merchant_Documents__c < accObj.Total_Required_Merchant_Documents_New__c ||
                         (accObj.Total_Docs_Onboarding_Status_Decline__c <= 0 
                          && accObj.Total_Docs_Onboarding_Status_Approved__c < accObj.Total_Required_Merchant_Documents_New__c
                          && accObj.Total_Docs_Onboarding_Approve_Receiced__c < accObj.Total_Required_Merchant_Documents_New__c 
                          && accObj.Total_Docs_Received_Status_Received__c < accObj.Total_Required_Merchant_Documents_New__c
                          && accObj.Document_Status__c != 'Docs Approved')){
                              errorDocStatusCount = 0;
                              approvedDocStatusCount =0;
                              receivedDocStatusCount = 0;
                              pendingDocStatusCount ++;
                              system.debug('INSIDE Pending');
                          }       
            }
            if(accObj.Skip_Document_Verification__c && accObj.Document_Status__c != 'Docs Approved'){
                accObj.Document_Status__c = 'Docs Approved';
            }
            if(accObj.Skip_Agreement_Verification__c && accObj.Agreement_Status__c != 'Approved'){
                accObj.Agreement_Status__c = 'Approved';
            }
            
            if(errorDocStatusCount > 0) accObj.Document_Status__c = 'Docs Error';
            else if(receivedDocStatusCount > 0) accObj.Document_Status__c = 'Docs Received';
            else if(approvedDocStatusCount > 0) accObj.Document_Status__c = 'Docs Approved';
            else if(pendingDocStatusCount > 0) accObj.Document_Status__c = 'Pending';
            */
            
            // ================Update Account Type AND Account Name===============
            updateAccountName(accObj, triggerOldMap.get(accObj.id), AccRTId);
            updateType(accObj);
            
            //=====update delivery duration==========
            if(string.isNotBlank(accObj.Business_Category__c) && string.isNotBlank(accObj.Sub_Category__c) &&
               (accObj.Sub_Category__c != triggerOldMap.get(accObj.id).Sub_Category__c)){
                   subCategoryIds.add(accObj.Sub_Category__c);
               }
            
            //=========== Update Pan Verification Status============
            //===========Commenting the Code due to Onboarding Revamp=================
            if(accObj.Document_Status__c != triggerOldMap.get(accObj.id).Document_Status__c && accObj.Document_Status__c == 'Docs Approved'
               && accObj.PAN_Verification_Status__c != 'Success'){
                   accObj.PAN_Verification_Status__c = 'Success';
               }
            
            // ========== Update Agreement agreement status when CO send status as Not Generated=======
            // ========== Commenting the code due to Onboarding Revamp=================
            /*if((accObj.Agreement_Status__c != triggerOldMap.get(accObj.id).Agreement_Status__c ||  
                accObj.Document_Status__c != triggerOldMap.get(accObj.id).Document_Status__c) 
               && accObj.Merchant_Business_Type__c == 'LongTail' && !accObj.Skip_Agreement_Verification__c){
                   contAccountIds.add(accObj.Id);
               }
			*/
        }
        
        if(!lstAcc.isEmpty())  updateLOBAndRiskAutoApproved(lstAcc, setBusinessCategory);
        
        /*
* Commenting the code as corrently we are getting MIDs from CO via ESB
* 
// ========= get the opportunities based on set of account
if(!setAccId.isEmpty())                 getOpportunitiesUnderAccount(setAccId, mapAccIdVsListOpp);

// ========= set the merchant id on each account and get the list of Account for which We don't get the Merchant Id
if(!mapAccIdVsListOpp.isEmpty())        getMerchantIdAgainstAccount(mapAccIdVsListOpp, triggerNew, lstAcntWithoutMID);

// ========= Call the Thrid Party API and get the merchant id for all account for which we don't get the Merchant Id
if(!lstAcntWithoutMID.isEmpty())        getMerchantFromThirdParty(triggerNew, lstAcntWithoutMID);
*/
        
        //==============update delivery duration=====================
        if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0){
            updateDeliveryDuration(subCategoryIds,triggerNew);
        }
        
        //==================Update account agreement status==================
        //================== Commenting the code due to Onboarding Revamp============
       /* if(!contAccountIds.isEmpty())    getContractsUnderAccount(contAccountIds,mapAccIdVsListContract);
        
        if(!mapAccIdVsListContract.isEmpty()) updateAccountAgreementStatus(triggerNew, mapAccIdVsListContract);
        */
        
        // ========= get the opportunities based on set of account
        /*
        if(!setAccId.isEmpty())         getOpportunitiesUnderAccount(setAccId, mapAccIdVsListOpp);
        if(!mapAccIdVsListOpp.isEmpty()) skipVerificationStatus(triggerNew,mapAccIdVsListOpp); */
    }
    
    /*----------------------------------------------------------------------------------------------
Description:    method to get agreements based on set of account
			: Also used in ContractTriggerHandler
----------------------------------------------------------------------------------------------*/
    public static void getContractsUnderAccount(Set<Id> setAccId, Map<Id, List<Contract>> mapAccIdVsListContract){
        for(Contract contractObj : [SELECT Id, AccountId, Status,Active__c,URL__c FROM Contract 
                                    WHERE Contract_Type__c = 'Agreement' AND AccountId in : setAccId]){
                                        if(mapAccIdVsListContract.containsKey(contractObj.AccountId)){
                                            
                                            List<contract> contObjList = mapAccIdVsListContract.get(contractObj.AccountId);
                                            contObjList.add(contractObj);
                                            mapAccIdVsListContract.put(contractObj.AccountId,contObjList);
                                        }
                                        else if(!mapAccIdVsListContract.containsKey(contractObj.AccountId)){
                                            mapAccIdVsListContract.put(contractObj.AccountId, new List<Contract>{ContractObj});
                                        }
                                    }
    }
       
        
/********
 * Commented as currently we are not using MID integration
 * Planning to use for ENT merchant        
        /*----------------------------------------------------------------------------------------------
Description:    method to get opportunities based on set of account where 
----------------------------------------------------------------------------------------------*/
  /*      public static void getOpportunitiesUnderAccount(Set<Id> setAccId, Map<Id, List<Opportunity>> mapAccIdVsListOpp){
            for(Opportunity oppObj : [SELECT Id, AccountId, Platform_new__c, Product__c, Product__r.Name, Merchant_Id__c,
                                      Blacklist__c, Blacklist_Comment__c 
                                      FROM Opportunity 
                                      WHERE (Platform_new__c =: 'PayU Money' OR Product__r.Name =: 'PayU Money') 
                                      AND Merchant_Id__c !=: null
                                      AND AccountId in : setAccId])
            {
                if(oppObj.Merchant_Id__c != null && mapAccIdVsListOpp.containsKey(oppObj.AccountId)){
                    mapAccIdVsListOpp.get(oppObj.AccountId).add(oppObj);
                }
                else if(oppObj.Merchant_Id__c != null && !mapAccIdVsListOpp.containsKey(oppObj.AccountId)){
                    mapAccIdVsListOpp.put(oppObj.AccountId, new List<Opportunity>());
                    mapAccIdVsListOpp.get(oppObj.AccountId).add(oppObj);
                }
            }
        }
       /* 
        // method to get the map of platform records based on set of id records 
        public static void getMerchantIdAgainstAccount(Map<Id, List<Opportunity>> mapAccIdVsListOpp, List<Account> listAccount, List<Account> lstAcntWithoutMID){
            for(Account accObj : listAccount){
                if(mapAccIdVsListOpp.containsKey(accObj.id) && !mapAccIdVsListOpp.get(accObj.id).isEmpty()){
                    //accObj.Partner_ID__c = string.valueOf(mapAccIdVsListOpp.get(accObj.id)[0].Merchant_Id__c); //updated by kashish as need to rethink for this in case of partner.    
                }
                if((mapAccIdVsListOpp.containsKey(accObj.id) && mapAccIdVsListOpp.get(accObj.id).isEmpty()) || !mapAccIdVsListOpp.containsKey(accObj.id)){
                    lstAcntWithoutMID.add(accObj);
                }
            }
        }
        
        //method to get merchant id through third party API call and assign to related  to account
        public static void getMerchantFromThirdParty(List<Account> listAccount, List<Account> lstAcntWithoutMID){
            // TO DO : API Call for Merchant ID  
        }
      ***********************
*/  
        public static void updateLOBAndRiskAutoApproved(List<Account> listAccount, Set<Id> setBusinessCategory){
            try{
                Map<Id, Business_Category__c> mapBusinessCategory = new Map<Id, Business_Category__c>();
                getBusinessCategoryRecord(setBusinessCategory, mapBusinessCategory);
                
                for(Account eachAcc : listAccount){
                    if(mapBusinessCategory.get(eachAcc.Business_Category__c).Doable__c
                       && eachAcc.Transaction_Facility_Required__c == 'Domestic' && eachAcc.Delivery_Duration__c > 0 
                       && eachAcc.NDX_Score__c > 0 && eachAcc.NDX_Score__c <= 140000){
                           eachAcc.Risk_Auto_Approved__c = true;
                           eachAcc.LOB_Status__c = 'Approved';
                       }
                    else{
                        eachAcc.Risk_Auto_Approved__c = false;
                        eachAcc.LOB_Status__c = 'Pending';
                    }
                }
            }catch(exception e){
                system.debug('Exception: '+e.getMessage());
                system.debug('Line No: '+e.getLineNumber());
            }
            
        }
        
        // Get the Business Category Records
        private static void getBusinessCategoryRecord(Set<Id> setBusinessCategory, Map<Id, Business_Category__c> mapBusinessCategory){
            mapBusinessCategory.putAll([SELECT Id, Doable__c
                                        From Business_Category__c
                                        WHERE Id IN : setBusinessCategory]);
        }
        
        public static void afterInsertHandler(List<Account> triggerNew){
            List<Account> accList = new List<Account>();
            
            Set<Id> entityId = new Set<Id>();
            Set<Id> accId = new Set<Id>();
            Set<String> acntType = new Set<String>();
            List<Document_Master__c> docMaster = new List<Document_Master__c>();
            List<Merchant_Document__c> oldMdList = new List<Merchant_Document__c>();
            
            for(Account each : TriggerNew){
                if(!System.isBatch() && each.Data_need_to_be_publish__c){
                    IntegrationUtility.checkMaintenance(each, null, 'Account', 'Account'); 
                }
                if(String.isNotBlank(each.Type__c) && each.Type__c.equalsIgnoreCase('Merchant'))
                {
                    accList.add(each);
                }
                
                if(String.isNotBlank(each.Business_Entity__c) && (!each.isConverted__c || (String.isNotBlank(each.Type__c) && each.Type__c == 'Partner'))){
                    entityId.add(each.Business_Entity__c);
                }
                accId.add(each.Id);
                if(String.isNotBlank(each.Type__c)) acntType.add(each.Type__c);
                
            }
            
            //=============Commenting this code as SF don't need to create the doc for Sales user.Onboarding Revamp JIRA-SFPI-1157=========
            /*if(!accId.isEmpty()){
                oldMdList = [SELECT Id, Category_Type_Id__c, Account__c, Document_Category__c FROM Merchant_Document__c 
                             WHERE Account__c IN : accId AND Active__c =: true AND KYC_Documentable_Type__c IN('Account','')];
            }
            
            if(!entityId.isEmpty() && !acntType.isEmpty()){
                docMaster = [SELECT Id, Name, Document_Type__c,Document_Type__r.Identifier__c,Document_Category__c, Document_Category__r.Identifier__c, Entity__c, 
                             Document_For__c FROM Document_Master__c
                             WHERE Entity__c IN: entityId AND RecordTypeName__c = 'Merchant_Document' AND Active__c = True 
                             AND Document_For__c IN: acntType];
                
            }
            createMerchantDocuments(triggerNew, docMaster, oldMdList);
            */
            
            isInserted = true;
            if(!accList.isEmpty()){
                buildAccTeamMemberAndTask(accList, null);
            }
            
        }
        
        public static void afterUpdateHandler(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
            List<Account> accList = new List<Account>();
            Set<Id> entityId = new Set<Id>();
            Set<Id> accId = new Set<Id>();
            //Set<String> setofAccId = new Set<String>();
            Set<String> acntType = new Set<String>();
            List<Document_Master__c> docMaster = new List<Document_Master__c>();
            List<Merchant_Document__c> oldMdList = new List<Merchant_Document__c>();
            Set<Id> accSettlementIds = new Set<Id>();
            List<Opportunity> opportunityList = new List<Opportunity>();
            Map<Id,Account> triggerNewMap = new Map<Id,Account>();
            
            List<Opportunity> accRiskAccountWithOpty = new List<Opportunity>();
            List<Opportunity> accNotRiskAccountWithOpty = new List<Opportunity>();
            
            //update for CS
            Set<Id> checkpreAccountIds = new Set<id>();
            List<Opportunity> checkpremiumOppList = new List<Opportunity>();
            List<Opportunity> premiumOppList = new List<Opportunity>();
            //==============
            
            Map<Id, List<Document_Website_Tracker__c>> DocWebMap = new Map<Id, List<Document_Website_Tracker__c>>();
            
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromNull = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromPending = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenApprovedFromRec = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenErrorFromRec = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromError = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromError = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastApproved = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastError = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastPending = new Map<Id, List<Document_Website_Tracker__c>>();
            Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastRecieved = new Map<Id, List<Document_Website_Tracker__c>>(); 
            Boolean boolDocWebMapWhenPendingFromNull = false;
            Boolean boolDocWebMapWhenRecFromPending = false;
            Boolean boolDocWebMapWhenApprovedFromRec = false;
            Boolean boolDocWebMapWhenErrorFromRec = false;
            Boolean boolDocWebMapWhenPendingFromError = false;
            Boolean boolDocWebMapWhenRecFromError = false;
            Boolean boolDocWebMapWhenLastApproved = false;
            Boolean boolDocWebMapWhenLastError = false;
            Boolean boolDocWebMapWhenLastPending = false;
            Boolean boolDocWebMapWhenLastRecieved = false;
            
            for(Account each : TriggerNew){
                triggerNewMap.put(each.Id,each);
                if(!System.isBatch() && each.Data_need_to_be_publish__c){
                    IntegrationUtility.checkMaintenance(each, TriggerOldMap.get(each.Id), 'Account', 'Account'); 
                }
                if(String.isNotBlank(each.Type__c) && each.Type__c.equalsIgnoreCase('Merchant') && 
                   (//(each.LOB_Status__c != triggerOldMap.get(each.Id).LOB_Status__c && (each.LOB_Status__c == 'Pending' || each.LOB_Status__c == 'Approved')) ||
                       (each.Document_Status__c != triggerOldMap.get(each.Id).Document_Status__c 
                        && (each.Document_Status__c == 'Docs Received' || each.Document_Status__c == 'Docs Approved'))))
                {
                    accList.add(each);
                }
                
                if(String.isNotBlank(each.Business_Entity__c) &&  
                   (!each.isConverted__c  || (String.isNotBlank(each.Type__c) && each.Type__c == 'Partner')) &&
                   each.Business_Entity__c != triggerOldMap.get(each.Id).Business_Entity__c
                  ){
                      entityId.add(each.Business_Entity__c);
                      system.debug('entityId=='+entityId);
                  }
                accId.add(each.Id);
                if(String.isNotBlank(each.Type__c)) acntType.add(each.Type__c);
                
                //DocWebMap.put(each.Id, null);
                
                //=============Commenting this code as SF don't need to create the doc for Sales user.Onboarding Revamp JIRA-SFPI-1157=========
               /* System.debug('###### each '+each.Document_Status__c +' agrr '+each.Agreement_Status__c + ' pan '+each.PAN_Verification_Status__c);
                if(each.Document_Status__c == 'Docs Approved' && each.Agreement_Status__c== 'Approved' && 
                   each.Pan_Verification_Status__c== 'Success' && each.Merchant_Business_Type__c=='LongTail' && 
                   (each.Document_Status__c != triggerOldMap.get(each.Id).Document_Status__c || 
                    each.Agreement_Status__c != triggerOldMap.get(each.Id).Agreement_Status__c || 
                    each.Pan_Verification_Status__c != triggerOldMap.get(each.Id).Pan_Verification_Status__c)){
                        accSettlementIds.add(each.Id);
                    }
                
                if(each.NDX_Score__c > 0 && each.NDX_Score__c<=50000 && each.Merchant_Business_Type__c=='LongTail' &&
                   (each.Monthly_Expected_Sale__c != triggerOldMap.get(each.Id).Monthly_Expected_Sale__c
                    || each.Delivery_Duration__c != triggerOldMap.get(each.Id).Delivery_Duration__c)){
                        accSettlementIds.add(each.Id);
                    }
                
                if(each.Document_Status__c != triggerOldMap.get(each.Id).Document_Status__c && each.Merchant_Business_Type__c=='LongTail'){
                    accSettlementIds.add(each.Id);
                }
                
                if((each.Agreement_Status__c != triggerOldMap.get(each.Id).Agreement_Status__c || each.LOB_Status__c != triggerOldMap.get(each.Id).LOB_Status__c)
                   && each.Agreement_Status__c == 'Sent' && (each.LOB_Status__c == 'Approved' || each.LOB_Status__c == 'Rejected')
                   && each.Merchant_Business_Type__c=='LongTail'){
                       accSettlementIds.add(each.Id);
                   }
                
                if(each.Merchant_Business_Type__c=='LongTail' && ((each.Document_Status__c != 'Docs Approved' && each.Document_Status__c != triggerOldMap.get(each.Id).Document_Status__c)
                                                                  || (each.Agreement_Status__c != 'Approved' && each.Agreement_Status__c != triggerOldMap.get(each.Id).Agreement_Status__c)
                                                                  || (each.Pan_Verification_Status__c != 'Success' && each.Pan_Verification_Status__c != triggerOldMap.get(each.Id).Pan_Verification_Status__c))){
                                                                      accSettlementIds.add(each.Id);
                                                                  }
                //================ Move this code to merchant level as we'll not use status in account, onboarding Revamp=====SFPI-1157======
                if(String.isNotBlank(each.Type__c) && each.Type__c.equalsIgnoreCase('Merchant') && 
                   each.Agreement_Status__c != triggerOldMap.get(each.Id).Agreement_Status__c 
                   && each.Document_Status__c == 'Docs Received' && each.Agreement_Status__c == 'Counter Signed Received' )
                {
                    checkpreAccountIds.add(each.id);
                }
*/
            }
            
            //=============Commenting this code as SF don't need to create the doc for Sales user.Onboarding Revamp JIRA-SFPI-1157=========
           /* if(!accId.isEmpty()){
                oldMdList = [SELECT Id, Category_Type_Id__c, Account__c, Document_Category__c FROM Merchant_Document__c 
                             WHERE Account__c IN : accId AND Active__c =: true AND KYC_Documentable_Type__c IN('Account','')];
            }
            
            if(!entityId.isEmpty() && !acntType.isEmpty()){
                docMaster = [SELECT Id, Name, Document_Type__c,Document_Type__r.Identifier__c,Document_Category__c, Document_Category__r.Identifier__c, Entity__c, Document_For__c FROM Document_Master__c
                             WHERE Entity__c IN: entityId AND RecordTypeName__c = 'Merchant_Document' AND Active__c = True AND Document_For__c IN: acntType];
                
            }
            system.debug('docMaster=='+docMaster);
            createMerchantDocuments(triggerNew, docMaster, oldMdList);
            */
            
            if(!accList.isEmpty()){
                buildAccTeamMemberAndTask(accList, triggerOldMap);
            }
            
            /* if(!isInserted){
BusinessHours busnHrs = [SELECT Id, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime FROM BusinessHours where Name='PayU OneCare Child'];

for(Account acc : [SELECT Id, Name, Document_Status__c, (SELECT Id, Name, Count_for_recheck__c, LastModifiedDate, Pending_state__c, Recieved_state__c, Approved_state__c, Error_state__c, Account__c, 
Time_b_w_Pending_and_Recieved__c, Time_b_w_Recieved_and_Error__c, Time_b_w_Recieved_and_Approved__c, Count_for_Recieved_after_Error__c, 
Time_b_w_Docs_Error_and_Recieved_min__c FROM Document_Trackers__r) FROM 
Account WHERE Id IN :DocWebMap.keySet()]){
String oldStatusVal = triggerOldMap.get(acc.Id).Document_Status__c;
system.debug('-->> 310 '+oldStatusVal+' '+acc.Document_Status__c+' '+acc.Document_Trackers__r);
if(!acc.Document_Trackers__r.isEmpty()){
DocWebMap.put(acc.Id, acc.Document_Trackers__r);
if(acc.Document_Status__c == 'Docs Approved' && acc.Document_Status__c != oldStatusVal){
DocWebMapWhenLastApproved.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Error' && oldStatusVal != acc.Document_Status__c){
DocWebMapWhenLastError.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Pending' && oldStatusVal != acc.Document_Status__c){
DocWebMapWhenLastPending.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Received' && acc.Document_Status__c != oldStatusVal){
DocWebMapWhenLastRecieved.put(acc.Id, acc.Document_Trackers__r);
}
if(acc.Document_Status__c == 'Pending' && (oldStatusVal == null || String.isEmpty(oldStatusVal))){
DocWebMapWhenPendingFromNull.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Received' && oldStatusVal == 'Pending'){
DocWebMapWhenRecFromPending.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Approved' && oldStatusVal == 'Docs Received'){
DocWebMapWhenApprovedFromRec.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Error' && oldStatusVal == 'Docs Received'){
DocWebMapWhenErrorFromRec.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Pending' && oldStatusVal == 'Docs Error'){
DocWebMapWhenPendingFromError.put(acc.Id, acc.Document_Trackers__r);
}if(acc.Document_Status__c == 'Docs Received' && oldStatusVal == 'Docs Error'){
DocWebMapWhenRecFromError.put(acc.Id, acc.Document_Trackers__r);
}
}else{
if(acc.Document_Status__c == 'Docs Approved' && oldStatusVal != acc.Document_Status__c){
boolDocWebMapWhenLastApproved = true;
}if(acc.Document_Status__c == 'Docs Error' && oldStatusVal != acc.Document_Status__c){
boolDocWebMapWhenLastError = true;
}if(acc.Document_Status__c == 'Pending' && oldStatusVal != acc.Document_Status__c){
boolDocWebMapWhenLastPending = true;
}if(acc.Document_Status__c == 'Docs Received' && oldStatusVal != acc.Document_Status__c){
boolDocWebMapWhenLastRecieved = true;
}
if(acc.Document_Status__c == 'Pending' && (oldStatusVal == null || String.isEmpty(oldStatusVal))){
boolDocWebMapWhenPendingFromNull = true;
}if(acc.Document_Status__c == 'Docs Received' && oldStatusVal == 'Pending'){
boolDocWebMapWhenRecFromPending = true;
}if(acc.Document_Status__c == 'Docs Approved' && oldStatusVal == 'Docs Received'){
boolDocWebMapWhenApprovedFromRec = true;
}if(acc.Document_Status__c == 'Docs Error' && oldStatusVal == 'Docs Received'){
boolDocWebMapWhenErrorFromRec = true;
}if(acc.Document_Status__c == 'Pending' && oldStatusVal == 'Docs Error'){
boolDocWebMapWhenPendingFromError = true;
}if(acc.Document_Status__c == 'Docs Received' && oldStatusVal == 'Docs Error'){
boolDocWebMapWhenRecFromError = true;
}
}
}

if(!DocWebMap.isEmpty()){
createUpdateDocumentWebsiteTracker(DocWebMapWhenPendingFromNull, DocWebMapWhenRecFromPending, DocWebMapWhenApprovedFromRec, DocWebMapWhenErrorFromRec, DocWebMapWhenPendingFromError, DocWebMapWhenRecFromError, 
boolDocWebMapWhenPendingFromNull, boolDocWebMapWhenRecFromPending, boolDocWebMapWhenApprovedFromRec, boolDocWebMapWhenErrorFromRec, boolDocWebMapWhenPendingFromError, boolDocWebMapWhenRecFromError,
DocWebMap, triggerNew, busnHrs, DocWebMapWhenLastApproved, DocWebMapWhenLastError, DocWebMapWhenLastPending , DocWebMapWhenLastRecieved, boolDocWebMapWhenLastApproved, boolDocWebMapWhenLastError, boolDocWebMapWhenLastPending, boolDocWebMapWhenLastRecieved);
}
}*/
                //===================//=============Commenting this code as SF don't need to create the doc for Sales user.Onboarding Revamp JIRA-SFPI-1157=========
            /*System.debug('####### accSettlementIds '+accSettlementIds);
            if(!accSettlementIds.isEmpty()) getOpportunities(accSettlementIds,opportunityList);
            System.debug('####### oppList '+opportunityList);
            if(!opportunityList.isEmpty()) updateMerchantSettlementStatus(opportunityList,triggerNewMap,triggerOldMap);
            
            //update for CS
            if(!checkpreAccountIds.isEmpty()) getOpportunities(checkpreAccountIds,checkpremiumOppList);
            if(!checkpremiumOppList.isEmpty()){
                for(Opportunity each : checkpremiumOppList){
                    if(each.isPremiumCustomer__c){
                        premiumOppList.add(each);
                    }
                }
                
                if(!premiumOppList.IsEmpty()) OpportunityTriggerHandler.createTasksForDocsTeam(premiumOppList,System.Label.Docs_Team_Task, '', 'High',true);
            }
                */
            //========
            //if(!accRiskAccountWithOpty.isEmpty() || !accNotRiskAccountWithOpty.isEmpty())  updateRelatedMerchants(accRiskAccountWithOpty, accNotRiskAccountWithOpty);
        }
        
        private static void buildAccTeamMemberAndTask(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
            List<AccountTeamMember> listAccMembers = new List<AccountTeamMember>();
            List<AccountShare> listAccSharing = new List<AccountShare>();
            List<Task> listTask = new List<Task>();
            Map<String, List<GroupMember>> mapGrpNameVsListGM = new Map<String, List<GroupMember>>();
            
            try{
                // get the list of Group of 'Risk Group', 'Onboarding Group' and 'Banking Group'
                getListGroup(mapGrpNameVsListGM);
                system.debug('mapGrpNameVsListGM ::::::::>> '+mapGrpNameVsListGM);
                
                //create new TeamMember and Task
                buildListAccTeamAndTask(triggerNew, listAccMembers, listAccSharing, listTask, mapGrpNameVsListGM, triggerOldMap);
                
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
        
        private static void buildListAccTeamAndTask(List<Account> listAcc, List<AccountTeamMember> listAccMembers, List<AccountShare> listAccSharing,
                                                    List<Task> listTask, map<String, List<GroupMember>> mapGrpNameVsListGM, Map<Id, Account> oldAccountMap)
        {
            String strUserId = '';
            
            List<AccountTeamMember> lstAccountTeamMember = [Select UserId, AccountId, TeamMemberRole 
                                                            FROM AccountTeamMember WHERE AccountId IN: listAcc 
                                                            AND (TeamMemberRole =: 'Risk User' OR TeamMemberRole =: 'Onboarding User' OR TeamMemberRole =: 'Banking User')];
            system.debug(lstAccountTeamMember .size()+' <<--- lstAccountTeamMember ===>>> '+lstAccountTeamMember);
            Map<Id,Set<Id>> map_AccountID_GroupIDs = new Map<Id,Set<Id>>();
            Map<Id, Map<String, AccountTeamMember>> mapAccIdVsMapATM = new Map<Id, Map<String, AccountTeamMember>>();
            
            for(AccountShare acntShareObj : [Select Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: listAcc]){
                
                if(map_AccountID_GroupIDs.isEmpty() && String.isNotBlank(acntShareObj.UserOrGroupId) && String.isNotBlank(acntShareObj.AccountId)){
                    map_AccountID_GroupIDs.put(acntShareObj.AccountId, new set<Id> {acntShareObj.UserOrGroupId});
                }
                if(String.isNotBlank(acntShareObj.AccountId) && !map_AccountID_GroupIDs.isEmpty() && map_AccountID_GroupIDs.containsKey(acntShareObj.AccountId) && String.isNotBlank(acntShareObj.UserOrGroupId)){
                    map_AccountID_GroupIDs.get(acntShareObj.AccountId).add(acntShareObj.UserOrGroupId);
                }else if(String.isNotBlank(acntShareObj.AccountId) && !map_AccountID_GroupIDs.isEmpty() && !map_AccountID_GroupIDs.containsKey(acntShareObj.AccountId) && String.isNotBlank(acntShareObj.UserOrGroupId)) {
                    map_AccountID_GroupIDs.put(acntShareObj.AccountId, new set<Id> {acntShareObj.UserOrGroupId});
                }
            }
            system.debug('map_AccountID_GroupIDs==='+map_AccountID_GroupIDs);
            
            for(AccountTeamMember atmObj : lstAccountTeamMember){
                if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(atmObj.AccountId)){
                    mapAccIdVsMapATM.get(atmObj.AccountId).put(atmObj.TeamMemberRole, atmObj);
                }else {                
                    mapAccIdVsMapATM.put(atmObj.AccountId, new Map<String, AccountTeamMember> {atmObj.TeamMemberRole => atmObj });
                }
            }        
            system.debug(mapAccIdVsMapATM.size()+'***** mapAccIdVsMapATM ****** '+mapAccIdVsMapATM);
            
            if(!mapGrpNameVsListGM.isEmpty()){
                for(Account accObj : listAcc){
                    
                    // =========== Risk Group ============
                    if(mapGrpNameVsListGM.containsKey('Risk Group') && accObj.Risk_User_Index__c != null){
                        
                        if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(accObj.Id) 
                           && !mapAccIdVsMapATM.get(accObj.Id).isEmpty() && mapAccIdVsMapATM.get(accObj.Id).containsKey('Risk User'))
                        {
                            strUserId = mapAccIdVsMapATM.get(accObj.Id).get('Risk User').UserId;                           
                        }else{
                            strUserId= mapGrpNameVsListGM.get('Risk Group')[Integer.valueOf(accObj.Risk_User_Index__c)].UserOrGroupId;                        
                            AccountTeamMember objAccMember = new AccountTeamMember();
                            AccountShare objAccShare = new AccountShare();
                            setupAccTeamSharing(accObj.Id, objAccMember, objAccShare, strUserId, 'Risk User', map_AccountID_GroupIDs);
                            if(objAccMember.UserId != null) listAccMembers.add(objAccMember);
                            if(objAccShare.UserOrGroupId != null) listAccSharing.add(objAccShare);
                        }
                        system.debug('***** Risk Group ****** ');
                        // commented out in update case with approved LOB status condition as Per JIRA SFPI-501
                        //if(String.isNotBlank(accObj.LOB_Status__c) && (oldAccountMap == null || accObj.LOB_Status__c != oldAccountMap.get(accObj.Id).LOB_Status__c)){                        
                        if(String.isNotBlank(accObj.LOB_Status__c) && oldAccountMap == null ){                        
                            /*if(accObj.LOB_Status__c == 'Pending'){
Task taskObj = new Task();
buildTask(accObj, taskObj, strUserId, 'LOB Verification Activity', 'Business category and sub category(line of business) to be approved of the merchant.');
if(taskObj.OwnerId != null)     listTask.add(taskObj); 
} Commented by Sumit banarji 27-Feb-2018 Jira Ticket : https://payuindia.atlassian.net/browse/SFPI-501*/
                            system.debug('***** Risk Group accObj.LOB_Status__c ****** '+accObj.LOB_Status__c);
                            //if(accObj.LOB_Status__c == 'Approved'){
                            //  Task taskObjWebsite = new Task();
                            //  buildTask(accObj, taskObjWebsite, strUserId, 'Pre-risk Verification', 'Merchants website to be verified.');
                            //  system.debug('***** Risk Group ****** taskObjWebsite **** '+taskObjWebsite);
                            //  if(taskObjWebsite.OwnerId != null)     listTask.add(taskObjWebsite); 
                            //}
                        }
                    }
                    
                    // =========== Onboarding Group ============
                    if(mapGrpNameVsListGM.containsKey('Onboarding Group') && accObj.Onboarding_User_Index__c != null){                    
                        if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(accObj.Id) 
                           && !mapAccIdVsMapATM.get(accObj.Id).isEmpty() && mapAccIdVsMapATM.get(accObj.Id).containsKey('Onboarding User')){
                               strUserId = mapAccIdVsMapATM.get(accObj.Id).get('Onboarding User').UserId;
                           }
                        else{
                            strUserId = mapGrpNameVsListGM.get('Onboarding Group')[Integer.valueOf(accObj.Onboarding_User_Index__c)].UserOrGroupId;
                            AccountTeamMember objAccMember = new AccountTeamMember();
                            AccountShare objAccShare = new AccountShare();
                            setupAccTeamSharing(accObj.Id, objAccMember, objAccShare, strUserId, 'Onboarding User', map_AccountID_GroupIDs);
                            if(objAccMember.UserId != null) listAccMembers.add(objAccMember);
                            if(objAccShare.UserOrGroupId != null) listAccSharing.add(objAccShare);
                        }
                        
                        if(accObj.Document_Status__c == 'Docs Received' && String.isNotBlank(accObj.Document_Status__c) &&
                           (oldAccountMap == null || accObj.Document_Status__c != oldAccountMap.get(accObj.Id).Document_Status__c)){
                               Task taskObj = new Task();
                               //buildTask(accObj, taskObj, strUserId, 'Document Verification Activity', 'Merchant documents to be verified.');
                               if(taskObj.OwnerId != null)     listTask.add(taskObj);
                           }
                        //=============Commented due tio onboarding Revamp as we are not using Account Doc Status.=====
                        /*
                        if(accObj.Document_Status__c == 'Exceptionally Approved' && String.isNotBlank(accObj.Document_Status__c) &&
                           (oldAccountMap == null || accObj.Document_Status__c != oldAccountMap.get(accObj.Id).Document_Status__c)){
                               Task taskObj = new Task();
                               //buildTask(accObj, taskObj, strUserId, 'AOF Form Verification', 'Please verify AOF form uploaded by Sales User.');
                               if(taskObj.OwnerId != null)     listTask.add(taskObj);
                           }*/
                    }
                    
                    //=================Commenting out as currently we are not using Banking Group==============
                    /*
                    // =========== Banking Group ============
                    if(mapGrpNameVsListGM.containsKey('Banking Group') && accObj.Banking_User_Index__c != null){
                        
                        if(!mapAccIdVsMapATM.isEmpty() && mapAccIdVsMapATM.containsKey(accObj.Id) 
                           && !mapAccIdVsMapATM.get(accObj.Id).isEmpty() && mapAccIdVsMapATM.get(accObj.Id).containsKey('Banking User')){
                               strUserId = mapAccIdVsMapATM.get(accObj.Id).get('Banking User').UserId;
                           }
                        else{
                            strUserId = mapGrpNameVsListGM.get('Banking Group')[Integer.valueOf(accObj.Banking_User_Index__c)].UserOrGroupId;
                            AccountTeamMember objAccMember = new AccountTeamMember();
                            AccountShare objAccShare = new AccountShare();
                            setupAccTeamSharing(accObj.Id, objAccMember, objAccShare, strUserId, 'Banking User', map_AccountID_GroupIDs);
                            if(objAccMember.UserId != null) listAccMembers.add(objAccMember);
                            if(objAccShare.UserOrGroupId != null) listAccSharing.add(objAccShare);                 
                        }
                        
                        if(accObj.Document_Status__c == 'Docs Approved' && String.isNotBlank(accObj.Document_Status__c) &&
                           (oldAccountMap == null || accObj.Document_Status__c != oldAccountMap.get(accObj.Id).Document_Status__c)){
                               Task taskObj = new Task();
                               //buildTask(accObj, taskObj, strUserId, 'PGs Activation Activity', 'Activate non pre-approved PGs for this merchant.');
                               if(taskObj.OwnerId != null)     listTask.add(taskObj);
                           }
                    }*/
                }
            }
        }
        
        @TestVisible
        private static void setupAccTeamSharing(String accId, AccountTeamMember objAccMember, AccountShare objAccShare, String strUserId, String strRole, Map<Id,Set<Id>> map_AccountID_GroupIDs){
            String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'Edit';
            //setup account team member
            objAccMember.AccountId = accId;
            objAccMember.TeamMemberRole = strRole;
            objAccMember.UserId = strUserId;
            
            //setup account team member sharing
            if(!map_AccountID_GroupIDs.isEmpty() && map_AccountID_GroupIDs.containsKey(accId)){
                if(!map_AccountID_GroupIDs.get(accId).contains(strUserId)){
                    objAccShare.AccountAccessLevel = accountAccessLevel;
                    objAccShare.OpportunityAccessLevel = OpportunityAccessLevel;
                    objAccShare.CaseAccessLevel = caseAccessLevel;
                    objAccShare.UserOrGroupId = strUserId;
                    objAccShare.AccountId = accId;
                }
            }
        }
        
    //=================Commenting out the code due to Onboarding Revamp===============
    /*    // Build Task
        @TestVisible
        private static void buildTask(Account accObj, Task taskObj, String strUserId, String strSubject, String comments){       
            taskObj.Status = 'Not Started';
            taskObj.Priority = 'High';
            taskObj.ActivityDate = Date.today();
            taskObj.WhatId = accObj.Id;
            taskObj.Subject = strSubject;
            taskObj.OwnerId = strUserId;
            taskObj.Description = comments;
        }
        
        private static void createMerchantDocuments(List<Account> triggerNew, List<Document_Master__c> docMaster, List<Merchant_Document__c> oldMdList){        
            Map<string,string> fieldWithMessage = new Map<string,string>();
            try{
                Set<String> identifier = new Set<String>();
                Set<String> docMasterIdentifier = new Set<String>();
                List<Merchant_Document__c> mdList = new List<Merchant_Document__c>();
                
                if(!docMaster.isEmpty()){
                    for(Document_Master__c dm : docMaster){
                        docMasterIdentifier.add(dm.Document_Category__c);
                    }
                }
                system.debug('docMasterIdentifier==='+docMasterIdentifier);
                if(!oldMdList.isEmpty() && !docMasterIdentifier.isEmpty()){
                    for(Merchant_Document__c md : oldMdList){
                        if(!docMasterIdentifier.contains(md.Document_Category__c)){
                            md.Active__c = false;
                            mdList.add(md);
                            system.debug('mdList+++++==='+mdList);
                        }
                        identifier.add(md.Category_Type_Id__c);
                    }
                }
                
                if(!docMaster.isEmpty()){
                    for(Account accObj : triggerNew){                
                        for(Document_Master__c eachDocument : docMaster){
                            if(accObj.Business_Entity__c == eachDocument.Entity__c && accObj.Type__c == eachDocument.Document_For__c){
                                String theIdentifier = eachDocument.Document_Category__r.Identifier__c;
                                system.debug(eachDocument.Document_Category__c + '+++++theIdentifier==='+theIdentifier);
                                if(!identifier.contains(theIdentifier)){
                                    Merchant_Document__c merchantDoc = new Merchant_Document__c();
                                    merchantDoc.Document_Category__c = eachDocument.Document_Category__c;
                                    merchantDoc.Document_Master_Id__c = eachDocument.Id;
                                    if(string.isNotBlank(eachDocument.Document_Type__c)) merchantDoc.Document_Type__c = eachDocument.Document_Type__c;
                                    merchantDoc.Account__c = accObj.Id;
                                    merchantDoc.Active__c = True;
                                    merchantDoc.KYC_Documentable_Type__c = 'Account';
                                    mdList.add(merchantDoc);
                                }
                            }                    
                        }
                    }                
                }
                
                system.debug('mdlist'+mdList);
                if(!mdList.isEmpty()){
                    upsert mdList;    
                }
            }catch(Exception ex){
                
                fieldWithMessage.put('Message__c',ex.getMessage());
                fieldWithMessage.put('Process__c','AccountAfterInsert');
                fieldWithMessage.put('Request__c','createMerchantDocuments');
                SystemUtility.errorHandler(ex,fieldWithMessage);
            }
        }
        */
        public static void updateAccountName(Account newData, Account oldData, string AccRTId){
            
            if(String.isNotBlank(newData.PAN_Number__c) && String.isNotBlank(newData.Legal_Name__c) &&
               (oldData == null || newData.PAN_Number__c != oldData.PAN_Number__c || newData.Legal_Name__c != oldData.Legal_Name__c)){
                   if(newData.RecordTypeId == AccRTId){
                       newData.Name = 'CR - ' + newData.Legal_Name__c + '-' + newData.PAN_Number__c;
                   }
                   else{
                      newData.Name = newData.Legal_Name__c + '-' + newData.PAN_Number__c;
                      //newData.Name = newData.Merchant_Account_Id__c; // Commented as we need to go to the previous flow (Account name should not be UUID which was made during Multi-Product) - Kunal
                   }
               }
            
            if(String.isBlank(newData.PAN_Number__c) && String.isNotBlank(newData.Legal_Name__c) &&
               (oldData == null || newData.Legal_Name__c != oldData.Legal_Name__c)){
                   if(newData.RecordTypeId == AccRTId){
                       newData.Name = 'CR - ' + newData.Legal_Name__c;
                   }
                   else{
                       newData.Name = newData.Legal_Name__c;
                       //newData.Name = newData.Merchant_Account_Id__c;// Commented as we need to go to the previous flow (Account name should not be UUID which was made during Multi-Product) - Kunal
                   }
               }
            
            if(String.isNotBlank(newData.PAN_Number__c) && String.isBlank(newData.Legal_Name__c) &&
               (oldData == null || newData.PAN_Number__c != oldData.PAN_Number__c)){
                   if(newData.RecordTypeId == AccRTId){
                       newData.Name = 'CR - ' + newData.PAN_Number__c;
                   }
                   else{
                       newData.Name = newData.PAN_Number__c;
                       //newData.Name = newData.Merchant_Account_Id__c; // Commented as we need to go to the previous flow (Account name should not be UUID which was made during Multi-Product) - Kunal
                   }
               }
            
            // Commented as we need to go to the previous flow (Account name should not be UUID which was made during Multi-Product) - Kunal
            /*if(String.isNotBlank(newData.Merchant_Account_Id__c) ){
                newData.Name = newData.Merchant_Account_Id__c;
            }*/
        }
        
        //called from DocDeferralApprovalComponent
        @AuraEnabled
        public static String updateDocStatus(Id recordId){
            String msg = '';
            List<Account> accList = [Select Id, Document_Status__c FROM Account WHERE Id =: recordId Limit 1];
            
            List<ProcessInstance> approvalList = [SELECT TargetObjectId, Status, CreatedDate, 
                                                  (SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                                   FROM Steps ORDER BY CreatedDate DESC) FROM ProcessInstance WHERE TargetObjectId =: recordId
                                                  ORDER BY CreatedDate DESC];
            
            try{
                
                if(!accList.isEmpty() && accList[0].Document_Status__c == 'Exceptional Approval Required'){
                    return 'Already_In_Approval';
                }
                else if(!accList.isEmpty() && accList[0].Document_Status__c == 'Exceptionally Approved'){
                    return 'Exceptionally_Approved';
                }
                else if(!approvalList.isEmpty() && approvalList[0].Status == 'Pending'){
                    return 'Already_In_One_Approval_Process';
                }
                else if(!accList.isEmpty() && accList[0].Document_Status__c == 'Docs Approved'){
                    return 'Approved';
                }
                else{
                    Account each = new Account(Id = recordId, Document_Status__c = 'Exceptional Approval Required');
                    if(!Test.isRunningTest()) update each;               
                    return 'Submitted_For_Approval';
                }                                    
            }        
            catch(DmlException e){
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                //we can get from DmlException
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                throw new AuraHandledException(msg);
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        public static void createAccountReseller(List<Account> triggerNew, Set<String> setLegalName, Set<String> setPanNum){
            system.debug('setLegalName'+setLegalName);
            system.debug('setPanNum'+setPanNum);
            Map<String, Id> mapLegalPanAcnt = new Map<String, Id>();
            
            if(!setLegalName.isEmpty() && !setPanNum.isEmpty()){            
                for(Account accntObj : [SELECT Id, Name, Legal_Name__c, PAN_Number__c 
                                        FROM Account 
                                        WHERE Type__c =: 'Merchant' 
                                        AND (Legal_Name__c IN: setLegalName AND PAN_Number__c IN: setPanNum)])
                {  
                    if(String.isNotBlank(accntObj.Legal_Name__c) && String.isNotBlank(accntObj.PAN_Number__c)) mapLegalPanAcnt.put(accntObj.Legal_Name__c+'##'+accntObj.PAN_Number__c, accntObj.Id);
                }
            }
            
            for(Account newAcnt : triggerNew){
                system.debug('++++>>>>'+newAcnt.Legal_Name__c+'##'+newAcnt.PAN_Number__c);
                if(newAcnt.Type__c == 'Partner' && !mapLegalPanAcnt.isEmpty() && mapLegalPanAcnt.containsKey(newAcnt.Legal_Name__c+'##'+newAcnt.PAN_Number__c)){
                    newAcnt.ParentId = mapLegalPanAcnt.get(newAcnt.Legal_Name__c+'##'+newAcnt.PAN_Number__c);                
                }
            }
        }        
        
        public static void updateType(Account newAccount){
            if('Account'.equals(newAccount.Type__c)){
                newAccount.Type__c = 'Merchant';
            }
        }  
        
    //=========Commenting out as we are not using the same==================
     /*   public static void createUpdateDocumentWebsiteTracker(Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromNull, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromPending, 
                                                              Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenApprovedFromRec, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenErrorFromRec, 
                                                              Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromError, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromError, 
                                                              Boolean boolDocWebMapWhenPendingFromNull, Boolean boolDocWebMapWhenRecFromPending, Boolean boolDocWebMapWhenApprovedFromRec, Boolean boolDocWebMapWhenErrorFromRec, 
                                                              Boolean boolDocWebMapWhenPendingFromError, Boolean boolDocWebMapWhenRecFromError, Map<Id, List<Document_Website_Tracker__c>> DocWebMap, List<Account> triggerNew,
                                                              BusinessHours busnHrs, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastApproved, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastError, 
                                                              Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastPending, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastRecieved, 
                                                              Boolean boolDocWebMapWhenLastApproved, Boolean boolDocWebMapWhenLastError, Boolean boolDocWebMapWhenLastPending, Boolean boolDocWebMapWhenLastRecieved){
                                                                  DocumentWebsiteTrackerTriggerHandler.createUpdateDocWebTrackerRecord(DocWebMapWhenPendingFromNull, DocWebMapWhenRecFromPending, DocWebMapWhenApprovedFromRec, DocWebMapWhenErrorFromRec, DocWebMapWhenPendingFromError,
                                                                                                                                       DocWebMapWhenRecFromError, boolDocWebMapWhenPendingFromNull, boolDocWebMapWhenRecFromPending, boolDocWebMapWhenApprovedFromRec, boolDocWebMapWhenErrorFromRec, boolDocWebMapWhenPendingFromError, 
                                                                                                                                       boolDocWebMapWhenRecFromError, DocWebMap, triggerNew, busnHrs, DocWebMapWhenLastApproved, DocWebMapWhenLastError, DocWebMapWhenLastPending , DocWebMapWhenLastRecieved, boolDocWebMapWhenLastApproved, boolDocWebMapWhenLastError, boolDocWebMapWhenLastPending, boolDocWebMapWhenLastRecieved);
                                                              }
        */
        public static List<Opportunity> getOpportunities(Set<Id> accountIds,List<Opportunity> opportunities){
            if(!accountIds.isEmpty()){
                for(Opportunity eachOpp : [Select Id,Settlement_Status__c,Website_Status__c,Website__c,IOS_URL__c,Android_URL__c,
                                           Risk_Unhold_Reason__c,Business_Category__c,
                                           Bank_Verification_Status__c,Stage_Closed_Won_Lost__c,MAF_Status__c,Credit_Underwriter_Check__c,
                                           Pricing_Negotiation_Validator__c,RecordType.Name,StageName,Risk_Level__c,
                                           Document_Status_Document_Issue__c,PAN_Verification_Status__c,(Select Id,Verification_Status__c,Active__c from Bank_Account_Details__r Where Active__c=True),
                                           LOB_Status_Sending__c,Risk_Hold_Reason__c,AccountId,Integration_Type__c,isPremiumCustomer__c 
                                           from Opportunity where AccountId IN: accountIds ORDER BY LastModifiedDate Desc]){
                                               opportunities.add(eachopp);
                                           }
                return opportunities;
            }
            return null;
        }
        /* will deploy in next phase
public static void updateRelatedMerchants(List<Opportunity> accRiskAccountWithOpty, List<Opportunity> accNotRiskAccountWithOpty){
List<Opportunity> optyToUpdate = new List<Opportunity>();
if(!accRiskAccountWithOpty.isEmpty()){
for(Opportunity opty : accRiskAccountWithOpty){
opty.Blacklist__c = true;
opty.Blacklist_Comment__c = Label.Merchant_Block_Comment+' through Account update';
optyToUpdate.add(opty);
}
}
if(!accNotRiskAccountWithOpty.isEmpty()){
for(Opportunity opty : accNotRiskAccountWithOpty){
opty.Blacklist__c = false;
opty.Blacklist_Comment__c = Label.Unblock_through_Account_update;
optyToUpdate.add(opty);
}
}

if(!optyToUpdate.isEmpty())  update optyToUpdate;
}
*/
    //========Commenting the code due to Onboarding Revamp - JIRA-SFPI-1157
       /* public static void updateMerchantSettlementStatus(List<Opportunity> oppList, Map<Id,Account> triggerNewMap, Map<Id,Account> triggerOldMap){
            Map<string,string> fieldWithMessage = new Map<string,string>();
            List<string> settlementStatusList = system.label.Settlement_Status_Restricted.split(',');
            String BusinessCategory = Label.Business_Category;
            List<String> BusinessCategorys = BusinessCategory.split(',');
            List<Opportunity> optlist = new List<Opportunity>();
            List<Bank_Account_Detail__c> bankUpdateOppList = new List<Bank_Account_Detail__c>();
            
            try{
                List<Opportunity> settlementOppList = new List<Opportunity>();
                Integer i = 0;
                if(!oppList.isEmpty()){
                    for(Opportunity eachOpp : oppList){ 
                        i++;
                        if(i<=5){
                            
                            if(triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c == 'Approved'
                               && triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Approved'
                               && triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c == 'Success'
                               && (triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c || 
                                   triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c != triggerOldMap.get(eachOpp.AccountId).Agreement_Status__c || 
                                   triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c != triggerOldMap.get(eachOpp.AccountId).Pan_Verification_Status__c)){
                                       if(eachOpp.Website_Status__c == 'Website OK' 
                                          && (!settlementStatusList.contains(eachOpp.Settlement_Status__c) || string.isBlank(eachOpp.Settlement_Status__c))){
                                              eachOpp.Settlement_Status__c = 'Active';
                                              eachOpp.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;
                                              
                                          }
                                       if(eachOpp.Bank_Verification_Status__c == 'Success' && eachOpp.Credit_Underwriter_Check__c 
                                          && eachOpp.MAF_Status__c == 'Received' && eachOpp.Pricing_Negotiation_Validator__c
                                          && eachopp.Stage_Closed_Won_Lost__c == false && eachopp.Website_Status__c == 'Website OK'
                                          && eachOpp.RecordType.Name == 'Merchant'){
                                              eachOpp.StageName = 'Activation';
                                          }
                                   }
                            
                            if((String.isNotBlank(eachOpp.Website__c) || String.isNotBlank(eachOpp.Android_URL__c) 
                                || String.isNotBlank(eachOpp.IOS_URL__c)) && triggerNewMap.get(eachOpp.AccountId).NDX_Score__c>0 
                               && triggerNewMap.get(eachOpp.AccountId).NDX_Score__c<=50000 && 
                               (triggerNewMap.get(eachOpp.AccountId).Monthly_Expected_Sale__c != triggerOldMap.get(eachOpp.AccountId).Monthly_Expected_Sale__c
                                || triggerNewMap.get(eachOpp.AccountId).Delivery_Duration__c != triggerOldMap.get(eachOpp.AccountId).Delivery_Duration__c)){
                                    if(eachOpp.Business_Category__c != null && BusinessCategorys.contains(eachOpp.Business_Category__c)){                                       
                                        if((!settlementStatusList.contains(eachOpp.Settlement_Status__c) || string.isBlank(eachOpp.Settlement_Status__c))) 
                                            //eachOpp.Website_Status__c = 'Verification in Process';
                                            optlist.add(eachOpp);
                                    }
                                    else{
                                        eachOpp.Website_Status__c = 'Website OK';
                                        eachOpp.Risk_Level__c = 'High-Auto Approved';   
                                    }                 
                                } 
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Error' && 
                               triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c){
                                   if(eachOpp.Document_Status_Document_Issue__c != 'Docs Approved') eachOpp.Document_Status_Document_Issue__c = 'Docs Error';
                               }
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Approved' && 
                               triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c){
                                   if(eachOpp.Document_Status_Document_Issue__c != 'Docs Approved') eachOpp.Document_Status_Document_Issue__c = 'Docs Approved';
                               }
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Received' &&
                               triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c){
                                   if(eachOpp.Document_Status_Document_Issue__c != 'Docs Approved') eachOpp.Document_Status_Document_Issue__c = 'Docs Received';
                               }
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Pending' &&
                               triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c){
                                   if(eachOpp.Document_Status_Document_Issue__c != 'Docs Approved') eachOpp.Document_Status_Document_Issue__c = 'Pending';
                               }
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).LOB_Status__c == 'Rejected' &&
                               eachOpp.LOB_Status_Sending__c != 'Rejected' &&
                               triggerNewMap.get(eachOpp.AccountId).LOB_Status__c != triggerOldMap.get(eachOpp.AccountId).LOB_Status__c){
                                   eachOpp.LOB_Status_Sending__c = 'Rejected';
                               }
                            
                            if(eachOpp.StageName != 'Live & Transacting' && eachOpp.StageName != 'Terminated' 
                               && triggerNewMap.get(eachOpp.AccountId).LOB_Status__c == 'Approved' 
                               && eachOpp.LOB_Status_Sending__c != 'Approved'
                               && triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c == 'Sent'
                               && (triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c != triggerOldMap.get(eachOpp.AccountId).Agreement_Status__c
                                   || triggerNewMap.get(eachOpp.AccountId).LOB_Status__c != triggerOldMap.get(eachOpp.AccountId).LOB_Status__c)){
                                       eachOpp.LOB_Status_Sending__c = 'Approved';
                                   }
                            
                            /*if(triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c != 'Approved'
&& triggerNewMap.get(eachOpp.AccountId).Document_Status__c != 'Docs Approved' && 
triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c != 'Success'
&& (triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c || 
triggerNewMap.get(eachOpp.AccountId).Agreement_Status__c != triggerOldMap.get(eachOpp.AccountId).Agreement_Status__c || 
triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c != triggerOldMap.get(eachOpp.AccountId).Pan_Verification_Status__c)
&& (!settlementStatusList.contains(eachOpp.Settlement_Status__c))){
eachOpp.Settlement_Status__c = 'Thirdparty Hold';
eachOpp.Risk_Hold_Reason__c = System.Label.Risk_Hold_Reason;
}*/
          /*                  
                            if(triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c
                               && (triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Approved' ||
                                   triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Received')){
                                       if(eachOpp.Credit_Underwriter_Check__c && eachOpp.MAF_Status__c == 'Received'
                                          && eachOpp.Pricing_Negotiation_Validator__c && eachOpp.Stage_Closed_Won_Lost__c == false
                                          && eachOpp.Website_Status__c == 'Website OK'){
                                              eachOpp.StageName = 'Onboarding';
                                          }
                                   }
                            
                            if(triggerNewMap.get(eachOpp.AccountId).Document_Status__c == 'Docs Approved'
                               && (triggerNewMap.get(eachOpp.AccountId).Document_Status__c != triggerOldMap.get(eachOpp.AccountId).Document_Status__c)
                               && eachOpp.Bank_Verification_Status__c !='Success' && !eachOpp.Bank_Account_Details__r.isEmpty() && eachOpp.Bank_Account_Details__r != null
                               && eachOpp.Bank_Account_Details__r.get(0) != null && eachOpp.Bank_Account_Details__r.get(0).Verification_Status__c != 'Success'
                              ){
                                  eachOpp.Bank_Account_Details__r.get(0).Verification_Status__c = 'Success';
                                  bankUpdateOppList.add(eachOpp.Bank_Account_Details__r.get(0));
                              }
                            
                            //Updated by Sneha to update Pan failure on opportunity
                            if(triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c != triggerOldMap.get(eachOpp.AccountId).Pan_Verification_Status__c
                               && eachOpp.PAN_Verification_Status__c !='Success' && triggerNewMap.get(eachOpp.AccountId).Pan_Verification_Status__c == 'Failed'){
                                   eachOpp.PAN_Verification_Status__c = 'Failed';
                               }
                            //======================================================
                            
                            settlementOppList.add(eachOpp);
                        }                   
                        
                    }
                }
                if(!settlementOppList.isEmpty()) update settlementOppList;
                if(!optlist.isEmpty()) {
                    //OpportunityTriggerHandler.createTasksForRiskTeam(optlist, Label.Business_Category_Task, '', 'Normal',false);
                }
            }catch(Exception ex){
                fieldWithMessage.put('Message__c',ex.getMessage());
                fieldWithMessage.put('Process__c','AccountAfterUpdate');
                fieldWithMessage.put('Request__c','updateMerchantSettlementStatus');
                SystemUtility.errorHandler(ex,fieldWithMessage);
            }
        }
        */

        public static void updateDeliveryDuration(Set<Id> subCategoryIds, List<Account> triggerNew){
            Map<Id,Sub_Category__c> subCategoryMap = new Map<Id,Sub_Category__c>();
            if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0){
                for(Sub_Category__c sbObj : [Select Id,Delivery_duration__c from Sub_Category__c where Id IN: subCategoryIds]){
                    if(sbObj.Delivery_duration__c != null){
                        subCategoryMap.put(sbObj.Id,sbobj);
                    }
                }
                if(!subCategoryMap.isEmpty() && subCategoryMap != null){
                    for(Account eachAccount : triggerNew){
                        if(subCategoryMap.containsKey(eachAccount.Sub_Category__c)){
                            if(eachAccount.Delivery_Duration__c==null || eachAccount.Delivery_Duration__c==0)
                                eachAccount.Delivery_Duration__c = subCategoryMap.get(eachAccount.Sub_Category__c).Delivery_duration__c;
                        }
                    }
                }
            }
        }
        
        //=================Update Account Agreement Status==================
        //================= Also used in ContractTriggerHandler===========
        
        public static void updateAccountAgreementStatus(List<Account> triggerNew, Map<Id,List<Contract>> mapAccIdVsListContract){
            for(Account accObj : triggerNew){
                Integer totalApproved = 0;
                    Integer totalDeclined = 0;
                    Integer totalCSR = 0;
                    Integer totalPending = 0;
                if(mapAccIdVsListContract.containsKey(accObj.Id) && !mapAccIdVsListContract.get(accObj.Id).isEmpty()){
                    
                    for(Contract contObj : mapAccIdVsListContract.get(accObj.Id)){
                        if((contObj.status == 'Approved' || contObj.status == 'Approved Activate') && contObj.Active__c){
                            totalApproved++;
                        }else if(contObj.status == 'Counter Signed Received' && contObj.Active__c){
                            totalCSR++;
                        }else if(contObj.status == 'Declined' && contObj.Active__c){
                            totalDeclined++;
                        }else if(contObj.status == 'Pending' || contObj.status == 'Draft Finalised' || contObj.status == 'Draft Sent'){
                            totalPending++;
                        }
                    }
                }
                if(totalCSR > 0) accObj.Agreement_Status__c = 'Counter Signed Received';
                else if(totalApproved > 0) accObj.Agreement_Status__c = 'Approved';
                else if(totalDeclined > 0) accObj.Agreement_Status__c = 'Rejected';
                else if(totalPending > 0) accObj.Agreement_Status__c = 'Sent';
                else accObj.Agreement_Status__c = 'Not Generated';
            }
        }
        
    
        //============= Commenting the Code as Wibmo Team is not using the Product==============
       /* public static void createParentAccountWibmo(List<Account> triggerNew, Set<String> setClientNameId){
            Map<String,String> clientIdVsAccIdMap = New Map<String,String>();
            if(!setClientNameId.isEmpty()){       
                for(Account accObj : [SELECT Id, Name,Client_Name_New__c FROM Account WHERE Type__c ='Wibmo' AND Client_Name_New__c =:setClientNameId AND ParentId = null]){
                    clientIdVsAccIdMap.put(accObj.Client_Name_New__c,accObj.Id);
                }
            }
            for(Account newAcnt : triggerNew){
                if(newAcnt.Type__c == 'Wibmo' && !clientIdVsAccIdMap.isEmpty() && clientIdVsAccIdMap.get(newAcnt.Client_Name_New__c) != NULL){
                    newAcnt.ParentId = clientIdVsAccIdMap.get(newAcnt.Client_Name_New__c);              
                }
            }
        }        
        */
        
        //=================Update Account Skip verification Status==================
        /*public static void skipVerificationStatus(List<Account> triggerNew, Map<Id,List<Opportunity>> mapAccIdVsListOpportunity){
            for(Account accObj : triggerNew){
                    Integer skipDocVerify = 0;
                    Integer skipAgreementVerify = 0;
                if(mapAccIdVsListOpportunity.containsKey(accObj.Id) && !mapAccIdVsListOpportunity.get(accObj.Id).isEmpty()){
                    
                    for(Opportunity oppObj : mapAccIdVsListOpportunity.get(accObj.Id)){
                        if(oppObj.Skip_Document_Verification__c){
                            skipDocVerify++;
                        }
                        if(oppObj.Skip_Agreement_Verification__c){
                            skipAgreementVerify++;
                        }
                    }
                }
                if(skipAgreementVerify > 0) accObj.Skip_Agreement_Verification__c = True;
                if(skipDocVerify > 0) accObj.Skip_Document_Verification__c = True;
            }
        }
        */
      /*  public static void getOpportunitiesUnderAccount(Set<Id> setAccId, Map<Id, List<Opportunity>> mapAccIdVsListOpp){
            for(Opportunity oppObj : [SELECT Id, AccountId, Platform_new__c, Product__c, Product__r.Name, Merchant_Id__c,
                                      Blacklist__c, Skip_Document_Verification__c,Skip_Agreement_Verification__c, Blacklist_Comment__c 
                                      FROM Opportunity 
                                      WHERE (Platform_new__c =: 'PayU Money' OR Product__r.Name =: 'PayU Money') 
                                      AND Merchant_Id__c !=: null
                                      AND AccountId in : setAccId])
            {
                if(oppObj.Merchant_Id__c != null && mapAccIdVsListOpp.containsKey(oppObj.AccountId)){
                    mapAccIdVsListOpp.get(oppObj.AccountId).add(oppObj);
                }
                else if(oppObj.Merchant_Id__c != null && !mapAccIdVsListOpp.containsKey(oppObj.AccountId)){
                    mapAccIdVsListOpp.put(oppObj.AccountId, new List<Opportunity>());
                    mapAccIdVsListOpp.get(oppObj.AccountId).add(oppObj);
                }
            }
        } */
        
       
    }