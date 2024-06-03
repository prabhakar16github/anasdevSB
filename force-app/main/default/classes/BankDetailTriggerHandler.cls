public class BankDetailTriggerHandler {    
    
    public static Set<Id> setBankDeatilId;  
    public static Boolean runningFromConsumerAPI = false;
    
    public static void beforeInsertHandler(List<Bank_Account_Detail__c> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Bank_Account_Detail__c');        
        List<Bank_Account_Detail__c> lstBankAccDetails = new List<Bank_Account_Detail__c>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        
        for(Bank_Account_Detail__c each : TriggerNew){  
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
            
            if(each.Account_Number__c != null && each.IFSC_Code__c != null){
                each.Account_Number_IFSC_Code__c = each.Account_Number__c + '~' + each.IFSC_Code__c;
            }                   
            
            populateActiveBaList(each, null, lstBankAccDetails, mapOpportunity, mapLead);
            
            if(String.isNotBlank(each.Nodal_Code__c) || String.isNotBlank(each.NEFT_Nodal_Code__c)){
                each.Nodal_Status__c = 'Activated';
            }
            //===============Check branch Address with ASCII chracter==============
            if(String.isNotBlank(each.Branch_Address__c) && !each.Branch_Address__c.isAsciiPrintable()){
                each.Branch_Address__c = each.Branch_Address__c.replaceall('[^\\x00-\\x7F]', '');
            }
        } 
        
        if(!lstBankAccDetails.isEmpty()) processActiveBA(lstBankAccDetails, mapOpportunity, mapLead);
        /******* Written by rohit :  Before inserting bank Account Details It will check if Opportunity is not null OR Lead 
         * is not then the from Opp or lead I'm getting the Prod_Merchant__Id and updating on New_Product_Merchant_Id__c 
		*********/
        /*
        Map<Id,Opportunity> oppMapForProdId;
        Map<Id,Lead> leadMapForProdId;
        if(mapOpportunity.KeySet() !=NULL){
            oppMapForProdId = new Map<Id,Opportunity>([SELECT Id,Prod_Merchant_Id__c FROM Opportunity WHERE Id IN: mapOpportunity.KeySet()]);
        }
        if(mapLead.keySet()!=NULL){
             leadMapForProdId = new Map<Id,Lead>([SELECT Id,Prod_Merchant_Id__c FROM Lead WHERE Id IN: mapLead.KeySet()]);
        }
        for(Bank_Account_Detail__c bankDs : triggerNew){
            if(bankDs.Opportunity__c !=NULL)
                 bankDs.New_Product_Merchant_Id__c  = oppMapForProdId.get(bankDs.Opportunity__c).Prod_Merchant_Id__c;
            else
              bankDs.New_Product_Merchant_Id__c  = leadMapForProdId.get(bankDs.Opportunity__c).Prod_Merchant_Id__c;  
        }
        */
        /**************End*****************/
    }        
    
    public static void beforeUpdateHandler(List<Bank_Account_Detail__c> triggerNew, Map<Id, Bank_Account_Detail__c> triggerOldMap){      
        List<Bank_Account_Detail__c> lstBankAccDetails = new List<Bank_Account_Detail__c>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(); 
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        Set<String> setofOppId = new Set<String>();
        Set<String> setofBankId = new Set<String>();
        Map<String,Integer> mapofStringWithBD = new Map<String,Integer>();
        Set<Id> supportOppIds = New Set<Id>();
        
        for(Bank_Account_Detail__c each : TriggerNew){
            Bank_Account_Detail__c oldEach = triggerOldMap.get(each.Id);
            setofBankId.add(each.Id);
            
            if(each.Active__c && each.Verification_Status__c == 'Success' && String.isNotBlank(each.Opportunity__c) &&
               each.Verification_Status__c != triggerOldMap.get(each.Id).Verification_Status__c){
                   setofOppId.add(each.Opportunity__c);
               }
            
            if(each.Account_Number__c != null && each.IFSC_Code__c != null 
               && (each.Account_Number__c != oldEach.Account_Number__c || each.IFSC_Code__c != oldEach.IFSC_Code__c)){
                   each.Account_Number_IFSC_Code__c = each.Account_Number__c + '~' + each.IFSC_Code__c;
               }
            
            populateActiveBaList(each, oldEach, lstBankAccDetails, mapOpportunity, mapLead);            
            
            if((each.Nodal_Code__c != oldEach.Nodal_Code__c) || (each.NEFT_Nodal_Code__c != oldEach.NEFT_Nodal_Code__c)){
                if(String.isNotBlank(each.Nodal_Code__c) && String.isNotBlank(each.NEFT_Nodal_Code__c)){
                    each.Nodal_Status__c = 'Activated';
                }
                if(String.isBlank(each.Nodal_Code__c) && String.isBlank(each.NEFT_Nodal_Code__c)){
                    each.Nodal_Status__c = '';
                }
                if(String.isNotBlank(each.Nodal_Code__c) && String.isBlank(each.NEFT_Nodal_Code__c) || String.isBlank(each.Nodal_Code__c) && String.isNotBlank(each.NEFT_Nodal_Code__c)){
                    each.Nodal_Status__c = 'Activated';
                }
            }
            
            if(String.isNotBlank(each.Opportunity__c) && each.Verification_Status__c != oldEach.Verification_Status__c 
               && each.Active__c && each.Verification_Status__c == 'Success' && string.isNotBlank(each.New_Account_Holder_Name__c)
               && string.isNotBlank(each.New_Account_Number__c) && string.isNotBlank(each.New_IFSC_Code__c)){
                   supportOppIds.add(each.Opportunity__c);
               }
            
            //===============Check branch Address with ASCII chracter==============
            if(String.isNotBlank(each.Branch_Address__c) && each.Branch_Address__c != oldEach.Branch_Address__c && !each.Branch_Address__c.isAsciiPrintable()){
                each.Branch_Address__c = each.Branch_Address__c.replaceall('[^\\x00-\\x7F]', '');
            }
        }
        
        if(setofOppId.size() > 0)
            for(Bank_Account_Detail__c objBankDetails:[SELECT Id, Active__c, Opportunity__c FROM Bank_Account_Detail__c WHERE Active__c = false AND Opportunity__c IN :setofOppId AND Id NOT IN :setofBankId]){
                if(mapofStringWithBD.get(objBankDetails.Opportunity__c) == null)
                    mapofStringWithBD.put(objBankDetails.Opportunity__c,1);
                else if(mapofStringWithBD.get(objBankDetails.Opportunity__c) != null){
                    mapofStringWithBD.put(objBankDetails.Opportunity__c,mapofStringWithBD.get(objBankDetails.Opportunity__c)+1);
                }
            }
        
        for(Bank_Account_Detail__c objBankAcc: TriggerNew){
            
            if(String.isNotBlank(objBankAcc.Opportunity__c) && mapofStringWithBD.get(objBankAcc.Opportunity__c) != Null && mapofStringWithBD.get(objBankAcc.Opportunity__c) > 0 && objBankAcc.Active__c && 
               objBankAcc.Verification_Status__c == 'Success' && objBankAcc.Verification_Status__c != triggerOldMap.get(objBankAcc.Id).Verification_Status__c){
                   objBankAcc.Bank_Account_Verified_Last__c = true;
               }
            else
                objBankAcc.Bank_Account_Verified_Last__c = false;
        }
        
        if(!lstBankAccDetails.isEmpty()) processActiveBA(lstBankAccDetails, mapOpportunity, mapLead);
        
        if(!supportOppIds.isEmpty()) updateSupportOppBankDetail(triggerNew,supportOppIds);
    }
    
    public static void afterInsertHandler(List<Bank_Account_Detail__c> triggerNew){
        Map<String, Map<String, String>> performaMap = new Map<String, Map<String, String>>();        
        Set<Id> leadIds = New Set<Id>();
        Set<Id> convertedLeadIds = New Set<Id>();
        //To blacklist the Merchant
        Map<Id,Bank_Account_Detail__c> oppIdVsBankDetailMap = new Map<Id,Bank_Account_Detail__c>();
        
        //================escrow lock update==========
        Map<String,Bank_Account_Detail__c> escrowOppWithBankDetailMap = New Map<String,Bank_Account_Detail__c>();
        // used for bank parent status update
        List<Bank_Account_Detail__c> bankDetailList = New List<Bank_Account_Detail__c>();
        Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
        Map<Id,Lead> leadMap = New Map<id,Lead>();
        
        for(Bank_Account_Detail__c each : triggerNew){
            if(Trigger.isExecuting && each.Data_need_to_be_publish__c && !runningFromConsumerAPI) 
                IntegrationUtility.checkMaintenance(each, null, 'Bank_Account_Detail__c', 'Bank_Account_Detail__c'); 
       
            //======= Request for nodal code==============
            if(String.isNotBlank(each.Account_Holder_Name__c) && String.isNotBlank(each.Account_Number__c) && String.isNotBlank(each.IFSC_Code__c)
               && String.isNotBlank(each.Identifier__c) && String.isNotBlank(each.ProductLabel__c) 
               && (String.isNotBlank(each.Opportunity__c) || String.isNotBlank(each.Lead__c)) 
               && String.isNotBlank(each.Loan_Product__c) && !each.Preforma_Processed__c) {
                   requestPerformaMap(performaMap, each);
               }
            
            //Prashant 	
            If(each.Penny_Deposit_Status__c == 'Success' && string.isNotBlank(each.Lead__c) 
               && string.isBlank(each.Opportunity__c) && each.Active__c){	
                   system.debug('Inside condition');	
                   leadIds.add(each.Lead__c);        	
               } 
            /*
if(each.Verification_Status__c == 'Success' && each.Active__c
&& string.isNotBlank(each.Lead__c) && string.isBlank(each.Opportunity__c)){
convertedLeadIds.add(each.Id);
}*/
            if(String.isNotBlank(each.Account_Number_IFSC_Code__c) && each.Opportunity__c != null ){
                oppIdVsBankDetailMap.put(each.Opportunity__c,each);
            }
            
            //================escrow lock update==========
            if(String.isNotBlank(each.Request_Type__c) && String.isNotBlank(each.Opportunity__c)) 
                escrowOppWithBankDetailMap.put(String.ValueOf(each.Opportunity__c),each);
            
            // update parent status
            getParentDetails(each,null,bankDetailList,opportunityMap,leadMap);
            
        }	
        if(leadIds.size()>0){	
            createTasksForSalesTeam(leadIds, 'Penny Verification Success', 'Please connect with Merchant as He is not able to verify his penny deposit amount.', 'Normal');	
            
        } 
        /*
if(convertedLeadIds.size()>0){
updateLeadBankStatus(convertedLeadIds);
}*/
        //============request for nodal code=================
        If(!performaMap.isEmpty()) requestPerformaHandler(performaMap);  
        
        //===============To blacklist the Merchant=============
        
        if(oppIdVsBankDetailMap.size() > 0){
            pre_OnboardingBlacklistController.checkBankAccountDetails(oppIdVsBankDetailMap);
        }
        
        //================escrow lock update==========
        //if(!escrowOppWithBankDetailMap.isEmpty()) updateEscrowOppData(escrowOppWithBankDetailMap);
        
        // update parent status
        if(!bankDetailList.isEmpty() && bankDetailList.size()>0) updateParentStatus(bankDetailList,opportunityMap,leadMap);
    }
    
    public static void afterUpdateHandler(List<Bank_Account_Detail__c> triggerNew, Map<Id, Bank_Account_Detail__c> triggerOldMap){
        Map<String, Map<String, String>> performaMap = new Map<String, Map<String, String>>();        
        Set<Id> setOptyId = new Set<Id>();
        Map<Id, Bank_Account_Detail__c> mapBankDetail = new Map<Id, Bank_Account_Detail__c>();
        Map<Id, Opportunity> mapOpty = new Map<Id, Opportunity>();
        List<Contract> lstContractInsert = new List<Contract>();
        Set<Id> leadIds = New Set<Id>();
        Set<Id> convertedLeadIds = New Set<Id>();
        Set<Id> updateopp = New Set<Id>();
        //To blacklist the Merchant
        Map<Id,Bank_Account_Detail__c> oppIdVsBankDetailMap = new Map<Id,Bank_Account_Detail__c>();
        //================escrow lock update==========
        Map<String,Bank_Account_Detail__c> escrowOppWithBankDetailMap = New Map<String,Bank_Account_Detail__c>();
        Map<Id,Bank_Account_Detail__c> oppIdVsBankMap = new Map<Id,Bank_Account_Detail__c>();
        
        // used for bank parent status update
        List<Bank_Account_Detail__c> bankDetailList = New List<Bank_Account_Detail__c>();
        Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
        Map<Id,Lead> leadMap = New Map<id,Lead>();
        
        for(Bank_Account_Detail__c each : triggerNew){
            Bank_Account_Detail__c oldEach = triggerOldMap.get(each.Id);
            if(!LeadConvertBatch.isLeadConversionBatch && each.Data_need_to_be_publish__c && !runningFromConsumerAPI) 
                IntegrationUtility.checkMaintenance(each, oldEach, 'Bank_Account_Detail__c', 'Bank_Account_Detail__c');
        
            //======= Request for nodal code==============
            if(String.isNotBlank(each.Account_Holder_Name__c) && String.isNotBlank(each.Account_Number__c) && String.isNotBlank(each.IFSC_Code__c)
               && String.isNotBlank(each.Identifier__c) && String.isNotBlank(each.ProductLabel__c) 
               && (String.isNotBlank(each.Opportunity__c) || String.isNotBlank(each.Lead__c)) 
               && String.isNotBlank(each.Loan_Product__c) && !each.Preforma_Processed__c) {
                   requestPerformaMap(performaMap, each);
               }
            
            //Prashant
            If(each.Penny_Deposit_Status__c != oldEach.Penny_Deposit_Status__c && each.Penny_Deposit_Status__c == 'Success'	
               && string.isNotBlank(each.Lead__c) && string.isBlank(each.Opportunity__c) && each.Active__c){	
                   leadIds.add(each.Lead__c);                	
               }
            /*
// Update Lead status after bank verify
if(each.Verification_Status__c != oldEach.Verification_Status__c && each.Verification_Status__c == 'Success'
&& string.isNotBlank(each.Lead__c) && string.isBlank(each.Opportunity__c) && each.Active__c){
convertedLeadIds.add(each.Lead__c);
} */
            //===============To blacklist the Merchant=============
            if(String.isNotBlank(each.Account_Number_IFSC_Code__c) && each.Opportunity__c != null &&each.Opportunity__c !=oldEach.Opportunity__c){
                oppIdVsBankDetailMap.put(each.Opportunity__c,each);
            }
            //Added by Shivani on 11-08-2020--Update escrow lock on opportunity//
            //================escrow lock update==========
            if(String.isNotBlank(each.Request_Type__c) && String.isNotBlank(each.Opportunity__c) 
               && (each.Request_Type__c!= oldEach.Request_Type__c || each.Active__c != oldEach.Active__c)) {
                   escrowOppWithBankDetailMap.put(String.ValueOf(each.Opportunity__c),each);
               }
            
            
            if(each.Active__c == true && each.Active__c != oldEach.Active__c){
                oppIdVsBankMap.put(each.Opportunity__c,each);
            }else if(each.Active__c == false && each.Active__c != oldEach.Active__c){
                oppIdVsBankMap.put(each.Opportunity__c,each);
            }
            
            // Update Opportunity Status after Bank Verify
            // update parent status
            getParentDetails(each,oldEach,bankDetailList,opportunityMap,leadMap);
            /*
if(each.Active__c && each.Verification_Status__c == 'Success' && each.Verification_Status__c != oldEach.Verification_Status__c && each.Opportunity__c != NULL){
mapBankDetail.put(each.Id, each);
setOptyId.add(each.Opportunity__c);
}
}
System.debug('setOptyId ==> '+setOptyId);

if(!setOptyId.isEmpty()) getBankFromOpty(setOptyId, mapOpty);
System.debug('mapOpty ==> '+mapOpty);

if(!mapBankDetail.isEmpty() && !mapOpty.isEmpty()){
for(String eachBank : mapBankDetail.keySet()){ 
if(mapBankDetail.get(eachBank).Opportunity__c != null 
&& mapOpty.containsKey(mapBankDetail.get(eachBank).Opportunity__c) 
&& mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Bank_Account_Details__r != null
&& mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Bank_Account_Details__r.size() > 0
&& mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Contracts__r != null
&& !mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Contracts__r.isEmpty())
{   
Boolean isApprovedWExist = false;
for(Contract eachCont : mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Contracts__r){
if(eachCont.Status == 'Approved'){
isApprovedWExist = true;
}
}

if(!isApprovedWExist){
Contract contObj = mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).Contracts__r[0].clone(false, true, false, false);
contObj.E_Stamp__c = mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).E_Stamp__c != null ? mapOpty.get(mapBankDetail.get(eachBank).Opportunity__c).E_Stamp__c : null;
System.debug('contObj ==> '+contObj);
lstContractInsert.add(contObj);
}                   
}                
}
System.debug(lstContractInsert.size()+' <== lstContractInsert ==> '+lstContractInsert);
if(!lstContractInsert.isEmpty()) insert lstContractInsert;*/
        }
        //===============To blacklist the Merchant=============
        if(oppIdVsBankDetailMap.size() > 0){
            pre_OnboardingBlacklistController.checkBankAccountDetails(oppIdVsBankDetailMap);
        }
        if(leadIds.size()>0){	
            createTasksForSalesTeam(leadIds, 'Penny Verification Success', 'Please connect with Merchant as He is not able to verify his penny deposit amount.', 'Normal');	
        }
        /*
if(convertedLeadIds.size()>0){
updateLeadBankStatus(convertedLeadIds);
}
*/
        //================escrow lock update==========
        //if(!escrowOppWithBankDetailMap.isEmpty()) updateEscrowOppData(escrowOppWithBankDetailMap);
        //===update bank accountv details===
        //if(!oppIdVsBankMap.isEmpty()){updateOppFields(oppIdVsBankMap);
        //}
        
        // update parent status
        if(!bankDetailList.isEmpty() && bankDetailList.size()>0) updateParentStatus(bankDetailList,opportunityMap,leadMap);
        
    }       
    /*
public static void getBankFromOpty(Set<Id> setOptyId, Map<Id, Opportunity> mapOpty){
mapOpty.putAll([SELECT Id, E_Stamp__c,
(SELECT Id, Active__c FROM Bank_Account_Details__r WHERE Active__c = false), 
(SELECT Id, Status, Name, AccountId, Opportunity__c, Type__c, Active__c, Contract_Type__c, StartDate, ContractTerm 
FROM Contracts__r ORDER By CreatedDate DESC)
FROM Opportunity WHERE Id in : setOptyId]);
}
*/    
    public static void populateActiveBaList(Bank_Account_Detail__c each, Bank_Account_Detail__c oldEach, List<Bank_Account_Detail__c> lstBankAccDetails, Map<Id, Opportunity> mapOpportunity, Map<Id, Lead> mapLead){
        if(validateActiveBA(each, oldEach)){
            lstBankAccDetails.add(each);
            if(each.Opportunity__c != null) mapOpportunity.put(each.Opportunity__c, null);
            if(each.Lead__c != null) mapLead.put(each.Lead__c, null);
        }                
    }
    
    public static Boolean validateActiveBA(Bank_Account_Detail__c each, Bank_Account_Detail__c oldEach){
        return (each.Active__c && (each.Opportunity__c != null || each.Lead__c != null)) && 
            (Trigger.isInsert || 
             (Trigger.isUpdate && 
              (setBankDeatilId == null || (setBankDeatilId != null && !setBankDeatilId.contains(each.Id)))
              && ((each.Opportunity__c != oldEach.Opportunity__c && each.Opportunity__c != null) || each.Lead__c != oldEach.Lead__c || each.Active__c != oldEach.Active__c)
             ));
    }
    
    public static void processActiveBA(List<Bank_Account_Detail__c> lstBankAccDetails, Map<Id, Opportunity> mapOpportunity, Map<Id, Lead> mapLead){
        if(!mapOpportunity.isEmpty()) mapOpportunity.putAll([SELECT Id, (SELECT Id, Active__c, Prod_Merchant_Id__c  FROM Bank_Account_Details__r WHERE Active__c = true) FROM Opportunity WHERE Id IN : mapOpportunity.keyset()]);
        if(!mapLead.isEmpty()) mapLead.putAll([SELECT Id, isConverted, ConvertedOpportunityId, (SELECT Id, Active__c FROM Bank_Account_Details__r WHERE Active__c = true) FROM Lead WHERE Id IN : mapLead.keyset()]);
        Map<Id, Bank_Account_Detail__c> bankDetailsMap = New Map<Id, Bank_Account_Detail__c>();
        for(Bank_Account_Detail__c each : lstBankAccDetails){
            if(each.Opportunity__c != null && mapOpportunity.containskey(each.Opportunity__c) && mapOpportunity.get(each.Opportunity__c) != null && !mapOpportunity.get(each.Opportunity__c).Bank_Account_Details__r.isEmpty()){
                //if(!Test.isRunningTest()) each.Opportunity__c.addError('Opportunity has already an active bank account details records.');
            	for(Bank_Account_Detail__c existingBankDetail : mapOpportunity.get(each.Opportunity__c).Bank_Account_Details__r){
                    existingBankDetail.Active__c = false;
                    bankDetailsMap.put(existingBankDetail.Id, existingBankDetail);
                }
            }else if(each.Lead__c != null && mapLead.containskey(each.Lead__c) && mapLead.get(each.Lead__c) != null && !mapLead.get(each.Lead__c).IsConverted && !mapLead.get(each.Lead__c).Bank_Account_Details__r.isEmpty()){
                //if(!Test.isRunningTest()) each.Lead__c.addError('Lead has already an active bank account details records.');
                for(Bank_Account_Detail__c existingBankDetail : mapLead.get(each.Opportunity__c).Bank_Account_Details__r){
                    existingBankDetail.Active__c = false;
                    bankDetailsMap.put(existingBankDetail.Id, existingBankDetail);
                }
            }
        }
        if(!bankDetailsMap.isEmpty()) update bankDetailsMap.values();
    }    
    
    public static void afterDeleteHandler(List<Bank_Account_Detail__c> triggerOld){
        /* for(Bank_Account_Detail__c each : triggerOld){
IntegrationUtility.checkMaintenance(each, null, 'Bank_Account_Detail__c', 'Bank_Account_Detail__c'); 
} */   
    }
    
    public static void requestPerformaMap(Map<String, Map<String, String>> performaMap, Bank_Account_Detail__c newRec){
        if((Test.isRunningTest() || 'YES'.equals(Label.PreformaSwitch)) && String.isNotBlank(newRec.Performa_Request__c) 
           && String.isNotBlank(newRec.ProductLabel__c) && String.isNotBlank(newRec.Loan_Product__c) && !newRec.Preforma_Processed__c){
               if(performaMap.containsKey(newRec.ProductLabel__c)){
                   performaMap.get(newRec.ProductLabel__c).put(newRec.Id, newRec.Performa_Request__c);    
               }else{
                   performaMap.put(newRec.ProductLabel__c, new Map<String, String>{newRec.Id => newRec.Performa_Request__c});    
               }            
           }          
    }    
    
    public static void requestPerformaHandler(Map<String, Map<String, String>> performaMap){
        if(!performaMap.isEmpty()){
            if(Trigger.isExecuting){
                if(!System.isBatch() && !System.isFuture()){
                    requestPerforma(JSON.serialize(performaMap));
                }                
            }else{
                requestPerforma(performaMap);
            }
        }
    }
    
    @future(callout = true)    
    public static void requestPerforma(String jsonStr){
        system.debug('requestPerforma@@@@');
        Map<String, Map<String, String>> performaMap = (Map<String, Map<String, String>>)JSON.deserialize(jsonStr, Map<String, Map<String, String>>.class);        
        requestPerforma(performaMap);
        
    }
    
    public static void requestPerforma(Map<String, Map<String, String>> performaMap){ 
        system.debug('requestPerforma###');
        String moneyAuthToken = IntegrationUtility.getAuthToken('PreformaAuth'); 
        //if(Test.isRunningTest()) moneyAuthToken = '235345345436';
        if(String.isNotBlank(moneyAuthToken)){                    
            Integration_Setting__mdt performaReq = IntegrationUtility.getIntSetting('performaRequestor');
            
            if(performaReq != null){  
                List<Bank_Account_Detail__c> detailsToUpdate = new List<Bank_Account_Detail__c>();  
                
                for(String each : performaMap.keyset()){
                    String requestBody = '{"processPreformatRequestList":[' + String.join(performaMap.get(each).values(), ',') + ']}';                                             
                    HttpResponse performaResponse = IntegrationUtility.requestUtility(performaReq, false, moneyAuthToken, null, new List<String>{each}, requestBody);                    
                    System.debug(moneyAuthToken + '---->>>>>>>>>>>>---' + performaResponse.getStatusCode() + '--------'+ requestBody + performaResponse.getBody());
                    if(performaResponse.getStatusCode() == 200){
                        for(String eachId : performaMap.get(each).keySet()){
                            detailsToUpdate.add(new Bank_Account_Detail__c(Id=eachId, Preforma_Processed__c=true));
                        }
                    }
                }
                if(!detailsToUpdate.isEmpty() && System.isFuture()) update detailsToUpdate;                    
                
            }                         
        }        
    } 
    
    public static List<Sobject> updateagreementinOnlineCaseWithnewURL(Set<String> setofBankId){
        
        Set<String> setofAccId = new Set<String>();
        List<Contract> lstContractUpdate = new List<Contract>();
        Map<Id, Bank_Account_Detail__c> mapBankDetail = new Map<Id, Bank_Account_Detail__c>();
        Map<String,String> mapofContractWithopport = new Map<String,String>();
        Map<String,List<Contract>> mapAccountwithContact = new Map<String,List<Contract>>();
        Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
        Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();
        List<String> lstofBankId ;
        List<Account> accounttoUpdateList = new List<Account>();
        
        if(setofBankId != null && setofBankId.size() > 0)
            lstofBankId = new List<String>(setofBankId);
        if(lstofBankId != null && lstofBankId.size() > 0)
            for(Bank_Account_Detail__c objBankDetails: Database.Query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(lstofBankId), '\',\'') + '\')')){
                system.debug('====objBankDetails======='+objBankDetails);
                if(objBankDetails.Bank_Account_Verified_Last__c && String.isNotBlank(objBankDetails.AccountId__c) && objBankDetails.Agreement_Regeneration__c){                
                    setofAccId.add(objBankDetails.AccountId__c);
                    mapBankDetail.put(objBankDetails.Id, objBankDetails);
                }
            }
        
        system.debug('===mapBankDetail===='+mapBankDetail);
        if(!setofAccId.isEmpty()) getBankFromAccount(setofAccId, mapAccountwithContact);
        system.debug('====mapOpty====='+mapAccountwithContact);
        if(!mapBankDetail.isEmpty() && !mapAccountwithContact.isEmpty()){
            for(String eachBank : mapBankDetail.keySet()){ 
                system.debug('===='+mapAccountwithContact.get(mapBankDetail.get(eachBank).AccountId__c));   
                if(String.isNotBlank(mapBankDetail.get(eachBank).AccountId__c) 
                   && mapAccountwithContact.containsKey(mapBankDetail.get(eachBank).AccountId__c) 
                   && mapBankDetail.get(eachBank).Bank_Account_Verified_Last__c
                   && mapAccountwithContact.get(mapBankDetail.get(eachBank).AccountId__c) != null
                   && !mapAccountwithContact.get(mapBankDetail.get(eachBank).AccountId__c).isEmpty())
                {
                    String VfpageName ='';
                    if(mapBankDetail.get(eachBank).VFPageKey__c != null && VFPageWithData__c.getValues(mapBankDetail.get(eachBank).VFPageKey__c) != null){
                        VfpageName = VFPageWithData__c.getValues(mapBankDetail.get(eachBank).VFPageKey__c).VFPageName__c ;
                    }
                    if(Test.isRunningTest()) VfpageName = 'payUmoney-Merchant';
                    system.debug('=======VfpageName ======'+VfpageName );    
                    for(Contract objContact : mapAccountwithContact.get(mapBankDetail.get(eachBank).AccountId__c)){
                        if((objContact.Status == 'Pending' || objContact.Status == 'Sent') && VfpageName != '' && objContact.Active__c == false){
                            mapofContractWithopport.put(objContact.Id,mapBankDetail.get(eachBank).Opportunity__c); 
                            mapOfIdContract.put(objContact.Id,objContact );
                            mapofContractWithAgreementVFpage.put(objContact.Id,VfpageName);
                            objContact.URL__c ='';
                            objContact.Upload_Date__c = System.today();
                            Break;
                        }
                    }                   
                }                
            }
            System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate);
        }
        if(!mapOfIdContract.isEmpty()){
            for(Id objId:mapOfIdContract.keySet()){
                system.debug('=objId====='+objId);
                String strEndPoint ='';
                Contract objContract = new Contract();
                objContract = mapOfIdContract.get(objId);
                if(mapofContractWithAgreementVFpage.get(objId) != null && mapofContractWithopport.get(objId)!= null){
                    PageReference pageRef = new PageReference('/apex/' + mapofContractWithAgreementVFpage.get(objId));
                    pageRef.getParameters().put('id', mapofContractWithopport.get(objId));        
                    pageRef.getParameters().put('strIsFinal', 'true');
                    pageRef.getParameters().put('eStampNo', String.valueof(objContract.E_Stamp_Number__c));
                    Blob body;
                    
                    if(!Test.isRunningTest()){
                        body = pageRef.getContent();
                        strEndPoint = AWSUtility.uploadAndGetDocUrlS3(objContract, objContract.Account.Identifier__c, body);
                    }else if(Test.isRunningTest()){
                        strEndPoint = 'google.com';
                        body = Blob.valueOf('Test Data');
                    }                 
                    
                    system.debug('strEndPoint ************ '+strEndPoint);
                    if(String.isNotBlank(strEndPoint)){
                        objContract.URL__c = strEndPoint;
                        objContract.Upload_Date__c = System.today();
                        objContract.File_Size__c = String.valueOf(body.size());
                        
                        lstContractUpdate.add(objContract);
                        
                        Account accObj = new Account(Id = objContract.AccountId);
                        if(accObj.Agreement_Status__c == 'Not Generated'){
                            accObj.Agreement_Status__c = 'Sent';
                            accounttoUpdateList.add(accObj);
                        } 
                    }
                }
            }
        }
        System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate); 
        System.debug(accounttoUpdateList.size()+' <== accounttoUpdateList ==> '+accounttoUpdateList);   
        if(!lstContractUpdate.isEmpty())
            update lstContractUpdate;
        if(!accounttoUpdateList.isEmpty()) 
            update accounttoUpdateList;
        return lstContractUpdate;
    }  
    
    
    public static void getBankFromAccount(Set<String> setAccountId, Map<String,List<Contract>> mapAccountwithContact){
        
        for(Contract objContract:[SELECT Id, Status, Account.Agreement_Status__c,AccountId, E_Stamp__c, Document_Master__c, Type__c, Document_Category__c,  
                                  Document_Category__r.Name, Contract_Type__c, Offline_Generation__c, Pricebook2Id, Active__c,Account.Identifier__c,
                                  Document_Content_Type__c, File_Size__c, URL__c, OwnerExpirationNotice, Document_Type__c, 
                                  Document_Category_Name__c, Document_Type_Name__c, StartDate, ContractTerm, E_Stamp_Number__c 
                                  FROM Contract WHERE AccountId IN : setAccountId 
                                  AND (Account.Agreement_Status__c = 'Not Generated' OR Account.Agreement_Status__c = 'Pending'
                                       OR Account.Agreement_Status__c = 'Sent' OR Account.Agreement_Status__c = 'Rejected' 
                                       OR Account.Agreement_Status__c = 'Draft In Process' 
                                       OR Account.Agreement_Status__c = 'Counter Signed Received')
                                  AND Contract_Type__c = 'Agreement' AND Status IN('Pending','Sent')
                                  ORDER BY LastModifiedDate DESC]){
                                      
                                      if(String.isBlank(objContract.Document_Type_Name__c)){
                                          objContract.Document_Type_Name__c = 'Agreement';
                                      }
                                      if(String.isBlank(objContract.Document_Category_Name__c)){
                                          objContract.Document_Category_Name__c = 'Service Agreement';
                                      }
                                      if(mapAccountwithContact.get(String.valueof(objContract.AccountId)) != null){
                                          List<Contract> lstCont = mapAccountwithContact.get(String.valueof(objContract.AccountId));
                                          lstCont.add(objContract);
                                          mapAccountwithContact.put(String.valueof(objContract.AccountId),lstCont);
                                      }
                                      else if(mapAccountwithContact.get(String.valueof(objContract.AccountId)) == null){
                                          List<Contract> lstCont = new List<Contract>();
                                          lstCont.add(objContract);
                                          mapAccountwithContact.put(String.valueof(objContract.AccountId),lstCont);
                                      }  
                                  }
    } 
    
    //Prashant ---- create task for Sales team after penny deposite success in lead
    public static void createTasksForSalesTeam(Set<Id> leadIds, String subject, String comment, String priority){	
        
        List<task> tasks = new List<task>();	
        List<Lead> listlead= new List<Lead>();	
        String integrationUserId = Label.IntegrationUserId;	
        List<Lead> leadlist =[select id,OwnerId,Round_Robin_Identifier__c from Lead where id IN:leadIds];	
        List<Group> lstGroupObj = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: Label.Other_Queue_Name AND Type =:'Queue' LIMIT 1];	
        
        for(Lead eachLead : leadlist){ 	
            system.debug('INSIDE LOOP'+String.valueof(eachLead.OwnerId).startsWith('00G'));	
            if(String.valueof(eachLead.OwnerId).startsWith('00G')){                	
                Task task = new Task(whoId = eachLead.Id , Subject = subject, Status = 'Not Started', 	
                                     ActivityDate = system.today(), Priority = priority,Description = comment);	
                
                if(lstGroupObj != null && !lstGroupObj.isEmpty() && lstGroupObj[0].GroupMembers != null && !lstGroupObj[0].GroupMembers.isEmpty()){	
                    Integer userIndex = Math.mod(Integer.valueOf(eachLead.Round_Robin_Identifier__c), lstGroupObj[0].GroupMembers.Size());	
                    system.debug('userIndex ===== '+userIndex);	
                    system.debug('userIndex value ===== '+lstGroupObj[0].GroupMembers.get(userIndex).UserOrGroupId);	
                    task.OwnerId = lstGroupObj[0].GroupMembers.get(userIndex).UserOrGroupId;	
                    system.debug('task owner id'+task.OwnerId);	
                }                   	
                tasks.add(task);	
                eachLead.OwnerId = task.OwnerId;	
                system.debug('Lead Owner id'+eachLead.OwnerId);	
                listlead.add(eachLead);	
            }	
            else if(eachLead.OwnerId == integrationUserId ){	
                Task task = new Task(whoId = eachLead.Id , Subject = subject, Status = 'Not Started', ActivityDate = system.today(), Priority = priority,	
                                     Description = comment);	
                
                if(lstGroupObj != null && !lstGroupObj.isEmpty() && lstGroupObj[0].GroupMembers != null && !lstGroupObj[0].GroupMembers.isEmpty()){	
                    Integer userIndex = Math.mod(Integer.valueOf(eachLead.Round_Robin_Identifier__c), lstGroupObj[0].GroupMembers.Size());	
                    task.OwnerId = lstGroupObj[0].GroupMembers.get(userIndex).UserOrGroupId;	
                }                   	
                tasks.add(task);	
                eachLead.OwnerId = task.OwnerId;	
                system.debug('Lead Owner id'+eachLead.OwnerId);	
                listlead.add(eachLead);	
            }	
            else if(String.valueof(eachLead.OwnerId).startsWith('005') && eachLead.OwnerId != integrationUserId ){	
                Task task = new Task(whoId = eachLead.Id , OwnerId = eachLead.OwnerId, Subject = subject, Status = 'Not Started', ActivityDate = system.today(), Priority = priority,	
                                     Description = comment);	
                tasks.add(task);	
            }	
        }	
        system.debug('Task  Value'+tasks);	
        if(!tasks.isEmpty() && tasks.size()>0) insert tasks;	
        //if(!listlead.isEmpty() && listlead.size()>0) Update listlead;	
    } 	
    //Prashant 
    //Prashant  
    
    /* create single mrthod for both object
//Prashant 
public static void updatelead(Set<Id> leadIds, Set<Id> Bankid){
List<Lead> listleadid = [select id from lead where id IN:leadIds];
List<Bank_Account_Detail__c> listbank = [select id from Bank_Account_Detail__c where id IN:Bankid];
List<Lead> Updateleadlist = new List<Lead>();
for(Lead eachLead : listleadid){
for(Bank_Account_Detail__c eachbank :listbank){
//Update Bank Verification Status
if(eachbank.Active__c == true && string.isNotBlank(eachbank.Lead__c) && eachbank.Lead__r.IsConverted != true &&(eachbank.Verification_Status__c == 'Pending' || eachbank.Verification_Status__c == 'Success' || eachbank.Verification_Status__c == 'Verification Attempts Exhausted') ){
eachLead.Bank_Verification_Status__c = eachbank.Verification_Status__c;
eachLead.MAF_Status__c ='Received';
}
//Update Penny Deposit Status and Nodal Status
if(eachbank.Active__c == true && string.isNotBlank(eachbank.Lead__c) && eachbank.Lead__r.IsConverted != true &&(eachbank.Penny_Deposit_Status__c == 'Pending' || eachbank.Penny_Deposit_Status__c == 'Success' || eachbank.Penny_Deposit_Status__c == 'Failed' || eachbank.Penny_Deposit_Status__c == 'Not Initiated') 
&&(eachbank.Nodal_Status__c == 'Activated' || eachbank.Nodal_Status__c == 'Not Activated' || eachbank.Nodal_Status__c == 'Activation In Progress') ){
//  eachLead.Nodal_Status__c = eachbank.Nodal_Status__c;
// eachLead.Penny_Deposit_Status__c = eachbank.Penny_Deposit_Status__c;
}

}
Updateleadlist.add(eachLead);
}
if(!Updateleadlist.isEmpty() && Updateleadlist.size()>0) Update Updateleadlist;
} 
//Prashant
public static void updateOppotunity(Set<Id> OppIds, Set<Id> Bankid){
List<Opportunity> listopp = [select id from Opportunity where id IN:OppIds];
List<Bank_Account_Detail__c> listbank = [select id from Bank_Account_Detail__c where id IN:Bankid];
List<Opportunity> Updateopplist = new List<Opportunity>();
for(Opportunity eachopp : listopp){
for(Bank_Account_Detail__c eachbank :listbank){
//Update Bank Verification Status
if(eachbank.Active__c == true && string.isNotBlank(eachbank.Opportunity__c) &&(eachbank.Verification_Status__c == 'Pending' || eachbank.Verification_Status__c == 'Success' || eachbank.Verification_Status__c == 'Verification Attempts Exhausted') ){
eachopp.Bank_Verification_Status__c = eachbank.Verification_Status__c;
//eachLead.MAF_Status__c ='Received';
}
//Update Penny Deposit Status and Nodal Status
if(eachbank.Active__c == true && string.isNotBlank(eachbank.Opportunity__c) &&(eachbank.Penny_Deposit_Status__c == 'Pending' || eachbank.Penny_Deposit_Status__c == 'Success' || eachbank.Penny_Deposit_Status__c == 'Failed' || eachbank.Penny_Deposit_Status__c == 'Not Initiated') 
&&(eachbank.Nodal_Status__c == 'Activated' || eachbank.Nodal_Status__c == 'Not Activated' || eachbank.Nodal_Status__c == 'Activation In Progress') ){
// eachopp.Nodal_Status__c = eachbank.Nodal_Status__c;
//   eachopp.Penny_Deposit_Status__c = eachbank.Penny_Deposit_Status__c;
}

//Update Email from Opportunity/Lead on Bank account detail
if(string.isNotBlank(eachbank.Opportunity__c) && eachopp.ProductLabel__c == 'PayUmoney' && string.isNotBlank(eachbank.ProductLabel__c) && (eachbank.Merchant_Email__c !=eachopp.Email__c) ){
eachbank.Merchant_Email__c = eachopp.Email__c;
}

}
Updateopplist.add(eachopp);
}
if(!Updateopplist.isEmpty() && Updateopplist.size()>0) Update Updateopplist;
} 
//Prashant*/
    /*
public static void updateLeadBankStatus(Set<Id> convertedLeadIds){
List<Lead> updatedBankLeadList = new List<Lead>();
if(!convertedLeadIds.isEmpty()){
for(Lead eachLead : [Select Id,Bank_Verification_Status__c FROM Lead WHERE Id IN:convertedLeadIds 
AND Bank_Verification_Status__c != 'Success' AND ISConverted=false]){

eachLead.Bank_Verification_Status__c = 'Success';
updatedBankLeadList.add(eachLead);

}
}
if(!updatedBankLeadList.isEmpty() && updatedBankLeadList.size()>0) update updatedBankLeadList;
}*/
    //==weekend loan==JIRA-821
    /*public static void updateEscrowOppData(Map<String,Bank_Account_Detail__c> escrowOppWithBankDetailMap){
List<opportunity> updatedOppdList = new List<opportunity>(); 
if(!escrowOppWithBankDetailMap.isEmpty()){
for(Opportunity eachopp:[select id,Escrow_Lock__c from Opportunity WHERE Id IN: escrowOppWithBankDetailMap.KeySet()]){
If(escrowOppWithBankDetailMap.containsKey(eachopp.Id) && escrowOppWithBankDetailMap.get(eachopp.Id).Request_Type__c=='Escrow Plug-in' 
&& escrowOppWithBankDetailMap.get(eachopp.Id).Active__c== true){
eachopp.Escrow_Lock__c = True;
}else if(escrowOppWithBankDetailMap.containsKey(eachopp.Id) && ((escrowOppWithBankDetailMap.get(eachopp.Id).Request_Type__c=='Escrow Plug out' 
&& escrowOppWithBankDetailMap.get(eachopp.Id).Active__c== True) || escrowOppWithBankDetailMap.get(eachopp.Id).Active__c== False)){
eachopp.Escrow_Lock__c = False;
}
updatedOppdList.add(eachopp);
}
}
if(!updatedOppdList.isEmpty() && updatedOppdList.size()>0) update updatedOppdList;
}*/
    //===update bank details info======//JIRA-821-14-08-20
    /* public static void updateOppFields(Map<Id,Bank_Account_Detail__c> idVsBankMap){
List<Opportunity> oppListUpdated = new List<Opportunity>();
List<Bank_Account_Detail__c> bankList = idVsBankMap.values();
Set<Id> oppIdSet = idVsBankMap.keySet();
List<Opportunity> oppList = [Select id,Current_Bank_Account__c,Previous_Bank_Account__c FROM Opportunity where Id IN:oppIdSet];
if(oppList.size()>0 && !oppList.isEmpty() ){
for(Opportunity op: oppList){
if(idVsBankMap.containsKey(op.Id)){
Bank_Account_Detail__c bankObj = idVsBankMap.get(op.Id);
if(bankObj.Active__c == true){
op.Current_Bank_Account__c = bankObj.Account_Number_IFSC_Code__c;
}else if(bankObj.Active__c == false){
op.Previous_Bank_Account__c  = bankObj.Account_Number_IFSC_Code__c;
}
}
oppListUpdated.add(op);
}
if(oppListUpdated.size()>0){
update oppListUpdated;
}
}
}
*/
    public static Boolean validateBankStatusChanges(Bank_Account_Detail__c each, Bank_Account_Detail__c oldEach){
        //Boolean checkParentObjId = String.isNotBlank(each.Opportunity__c) ? true : String.isNotBlank(each.Lead__c) ? true : false;
        if(each != null && each.Active__c && (each.Lead__c != null || each.Opportunity__c != null) && ((Trigger.isInsert &&
                                                                                                        (String.isNotBlank(each.Penny_Deposit_Status__c) 
                                                                                                         || String.isNotBlank(each.Verification_Status__c)
                                                                                                         || String.isNotBlank(each.Nodal_Status__c))
                                                                                                       ) 
                                                                                                       || (Trigger.isUpdate && oldEach != null && (
                                                                                                           (each.Nodal_Status__c != oldEach.Nodal_Status__c && String.isNotBlank(each.Nodal_Status__c)) 
                                                                                                           || (each.Penny_Deposit_Status__c != oldEach.Penny_Deposit_Status__c && String.isNotBlank(each.Penny_Deposit_Status__c)) 
                                                                                                           || (each.Verification_Status__c != oldEach.Verification_Status__c && String.isNotBlank(each.Verification_Status__c))
                                                                                                           || (each.Opportunity__c != oldEach.Opportunity__c && each.Opportunity__c != null)
                                                                                                           || (each.Lead__c != oldEach.Lead__c && each.Lead__c != null) 
                                                                                                           || each.Active__c != oldEach.Active__c || each.Request_Type__c != oldEach.Request_Type__c)
                                                                                                           && (setBankDeatilId == null || (setBankDeatilId != null && !setBankDeatilId.contains(each.Id)))
                                                                                                           
                                                                                                          ))){
                                                                                                              return true;
                                                                                                          }else
                                                                                                              return false;
    }
    
    public static void getParentDetails(Bank_Account_Detail__c each, Bank_Account_Detail__c oldEach, 
                                        List<Bank_Account_Detail__c> bankDetailList, Map<Id,Opportunity> opportunityMap,
                                        Map<Id,Lead> leadMap){
                                            try{
                                                if(validateBankStatusChanges(each,oldEach)){
                                                    
                                                    bankDetailList.add(each);
                                                    if(each.Opportunity__c != null) opportunityMap.put(each.Opportunity__c, null);
                                                    if(each.Lead__c != null) leadMap.put(each.Lead__c, null);
                                                }
                                            }catch(Exception ex){
                                                Map<String, String> messages = new Map<String, String>();
                                                messages.put('Severity__c', 'High');
                                                messages.put('Process__c', 'Bank getParentDetails');
                                                messages.put('Message__c', ex.getMessage());
                                                SystemUtility.errorHandler(null, messages);
                                            }
                                        }
    
    public static void updateParentStatus(List<Bank_Account_Detail__c> bankDetailList, Map<Id,Opportunity> opportunityMap,Map<Id,Lead> leadMap){
        try{
            if(!opportunityMap.isEmpty()) opportunityMap.putAll([SELECT Id,Nodal_Status__c , Settlement_Status__c,Penny_Deposit_Status__c ,
                                                                 Bank_Verification_Status__c,Current_Bank_Account__c ,Previous_Bank_Account__c ,
                                                                 (SELECT Id, Active__c FROM Bank_Account_Details__r WHERE Active__c = true) FROM Opportunity WHERE Id IN : opportunityMap.keyset()]);
            if(!leadMap.isEmpty()) leadMap.putAll([SELECT Id, Nodal_Status__c ,Skip_Verification__c ,Penny_Verification_Required__c,Penny_Deposit_Status__c ,Settlement_Status__c,Bank_Verification_Status__c ,isConverted, ConvertedOpportunityId,(SELECT Id, Active__c FROM Bank_Account_Details__r WHERE Active__c = true) FROM Lead WHERE Id IN : leadMap.keyset() AND isConverted=False]);
            
            List<Lead> updateLeadList = New List<Lead>();
            List<Opportunity> updateOpportunityList = New List<Opportunity>();
            
            for(Bank_Account_Detail__c each : bankDetailList){
                if(!leadMap.isEmpty() && each.Lead__c != null && leadMap.containsKey(each.Lead__c) && leadMap.get(each.Lead__c) != null && !leadMap.get(each.Lead__c).IsConverted){
                    if(each.Active__c ){
                        Lead eachLead = leadMap.get(each.Lead__c);
                        eachLead.Nodal_Status__c = each.Nodal_Status__c;
                        eachLead.Penny_Deposit_Status__c = each.Penny_Deposit_Status__c;
                        eachLead.Bank_Verification_Status__c = each.Verification_Status__c;
                        /* if(each.Nodal_Status__c=='Activated' && each.Verification_Status__c == 'Success' && String.isBlank(eachLead.Settlement_Status__c)) 
eachLead.Settlement_Status__c = 'Thirdparty Hold';*/
                        if(!eachLead.Penny_Verification_Required__c) eachLead.Skip_Verification__c  = True;
                        updateLeadList.add(eachLead);
                    }else if(!each.Active__c && leadMap.get(each.Lead__c).Bank_Account_Details__r.isEmpty()){
                        Lead eachLead = leadMap.get(each.Lead__c);
                        eachLead.Nodal_Status__c = 'Not Activated';
                        eachLead.Penny_Deposit_Status__c = 'Not Initiated';
                        eachLead.Bank_Verification_Status__c = 'Pending';
                        /*if((String.isBlank(eachLead.Settlement_Status__c) || eachLead.Settlement_Status__c == 'Active')) 
eachLead.Settlement_Status__c = 'Thirdparty Hold';*/
                        updateLeadList.add(eachLead);
                    }
                }else if(!opportunityMap.isEmpty() && each.Opportunity__c != null && opportunityMap.containsKey(each.Opportunity__c) && opportunityMap.get(each.Opportunity__c) != null){
                    
                    if(each.Active__c ){
                        Opportunity eachOpp = opportunityMap.get(each.Opportunity__c);
                        eachOpp.Nodal_Status__c = each.Nodal_Status__c;
                        eachOpp.Penny_Deposit_Status__c = each.Penny_Deposit_Status__c;
                        eachOpp.Bank_Verification_Status__c = each.Verification_Status__c;
                        /* if(each.Nodal_Status__c=='Activated' && each.Verification_Status__c == 'Success' 
&& String.isBlank(eachOpp.Settlement_Status__c)) 
eachOpp.Settlement_Status__c = 'Thirdparty Hold';*/
                        eachOpp.Current_Bank_Account__c = each.Account_Number_IFSC_Code__c;
                        if(each.Request_Type__c=='Escrow Plug-in') eachOpp.Escrow_Lock__c = true;
                        else eachOpp.Escrow_Lock__c = false;
                        updateOpportunityList.add(eachOpp);
                    }else if(!each.Active__c && opportunityMap.get(each.Opportunity__c).Bank_Account_Details__r.isEmpty()){
                        
                        Opportunity eachOpp = opportunityMap.get(each.Opportunity__c);
                        eachOpp.Nodal_Status__c = 'Not Activated';
                        eachOpp.Penny_Deposit_Status__c = 'Not Initiated';
                        eachOpp.Bank_Verification_Status__c = 'Pending';
                        eachOpp.Previous_Bank_Account__c = each.Account_Number_IFSC_Code__c;
                        /*if((String.isBlank(eachOpp.Settlement_Status__c) || eachopp.Settlement_Status__c == 'Active')) 
eachOpp.Settlement_Status__c = 'Thirdparty Hold';*/
                        updateOpportunityList.add(eachOpp);
                    }
                }
            }           
            
            if(!updateLeadList.isEmpty() && updateLeadList.size()>0) update updateLeadList;
            if(!updateOpportunityList.isEmpty() && updateOpportunityList.size()>0) update updateOpportunityList;
        }catch(Exception ex){
            Map<String, String> messages = new Map<String, String>();
            messages.put('Severity__c', 'High');
            messages.put('Process__c', 'Bank updateParentStatus');
            messages.put('Message__c', ex.getMessage());
            SystemUtility.errorHandler(null, messages);
        }
    }
    
    public static void updateSupportOppBankDetail(List<Bank_Account_Detail__c> triggerNew, Set<Id> oppIds){
        Id supportppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        Id merchantOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Id sellerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        Map<Id,Opportunity> supportOppMap = New Map<Id,Opportunity>();
        Map<Id,Opportunity> merchantOppMap = New Map<Id,Opportunity>();
        List<Bank_Account_Detail__c> oldBankDataList = New List<Bank_Account_Detail__c>();
        List<Bank_Account_Detail__c> clonedBankDataList = New List<Bank_Account_Detail__c>();
        
        for(Opportunity oppObj : [Select Id,Parent_Opportunity__c from Opportunity Where Id IN: oppIds AND RecordTypeId =:supportppRecordTypeId]){
            supportOppMap.put(oppObj.Id,oppObj);
            merchantOppMap.put(oppObj.Parent_Opportunity__c,null);
        }
        
        if(!merchantOppMap.isEmpty()){
            for(Bank_Account_Detail__c oldBankObj : [Select Id,Active__c from Bank_Account_Detail__c Where Opportunity__c IN: merchantOppMap.keySet()]){
                oldBankObj.Active__c = False;
                oldBankDataList.add(oldBankObj);
            }
        }
        
        if(!oldBankDataList.isEmpty()) update oldBankDataList;
        
        if(!supportOppMap.isEmpty()){
            for(Bank_Account_Detail__c bankObj : triggerNew){
                if(supportOppMap.containsKey(bankObj.Opportunity__c)){
                    Bank_Account_Detail__c newBankObj = bankObj.clone();
                    newBankObj.Opportunity__c = supportOppMap.get(bankObj.Opportunity__c).Parent_Opportunity__c;
                    newBankObj.Account_Holder_Name__c = bankObj.New_Account_Holder_Name__c;
                    newBankObj.Account_Number__c = bankObj.New_Account_Number__c;
                    newBankObj.IFSC_Code__c = bankObj.New_IFSC_Code__c;
                    newBankObj.Bank_Name__c = bankObj.New_Bank_Name__c;
                    newBankObj.Identifier__c = null;
                    clonedBankDataList.add(newBankObj);
                }
            }
        }
        if(!clonedBankDataList.isEmpty()) Insert clonedBankDataList;
    }
}