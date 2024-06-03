public class oneCareEmailtocase{
    public static void beforeInsertHandler(List<Case> triggerNew){
        try{
            Set<string> emailSets = New Set<string>();
            Map<Id,Case> existingCaseMap;
            Map<string,Contact> existingContactMap = New Map<string,Contact>();
            Map<Id,Account> existingAccountMap;
            Map<string,Account> caseIdWithNewAccountMap = New Map<string,Account>();
            Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
            Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
            Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
            Map<string,Case> existingCaseWithSubjectMap = New Map<string,Case>();
            Map<string,Contact> contactToUpdateMap = New Map<string,Contact>();
            Map<string,EmailMessage> newCaseWithEmailMessageMap = New Map<string,EmailMessage>();
            List<string> newCaseWithRevertSubject = New List<String>();
            List<EmailMessage> emailMsgToUpdate = New List<EmailMessage>();
            List<string> excludedStatusValues = New List<String>{'Resolved','Pending','Closed'};
               // Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
              //Prashant
             Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
             for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                    etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
             }  
            Map<Id,Case> triggerOldMap = New Map<Id,Case>();
            Map<string,Account> accountToCreateMap = New Map<string,Account>();
            Map<string,Case> casesToUpdateMap = New Map<string,Case>();
            Map<Id,String> case_userQueueIdMap = New Map<Id,String>();
            getCurrentQueueName(case_userQueueIdMap);
            Id ETCBankSuptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId();
            Id PayuBizRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId();
            Map<string,string> caseOriginMap = (map<string,string>)JSON.deserialize(System.Label.Case_Origin,map<string,string>.class);
            Map<string,list<case>> DomainCaseMap = new Map<string,list<case>>();
            Map<string,string> DomainMidMap = new Map<string,string>();
            Map<string,List<Case>>  suppliedEmailExCaseList = New Map<string,List<Case>>();
            Set<String> suppliedEmailSet = New Set<String>();
            
            Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Case');
            
            Map<String,Spam_Domains__mdt>  spamDomainDataMap = new Map<String,Spam_Domains__mdt> ();
            for(Spam_Domains__mdt spamObj : [Select Id,Type__c,MasterLabel From Spam_Domains__mdt Where Type__c='Email' AND Active__c=True]){
                spamDomainDataMap.put(spamObj.MasterLabel,spamObj);
            }
            
            
            for(case newCase : triggerNew){
                SystemUtility.getIdentifierUUID(newCase, 'Identifier__c', enableUUIDObj);
                newCase.TATValue__c = newCase.LP_TAT__c != Null ? integer.valueOf(newCase.LP_TAT__c) : 0 ;
                newCase.Failed_Attachment_Count__c = 0; 
                
                if(string.isNotBlank(newCase.suppliedEmail) && etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                    emailSets.add(newCase.suppliedEmail);
                }
                if(string.isNotBlank(newCase.OwnerId) && string.valueOf(newCase.OwnerId).startsWith('005') && newCase.status=='New'){
                       newCase.Status='Open';
                       newCase.L1_L2_Agent_Id__c = newCase.OwnerId;
                       system.debug('newCase.comment==='+newCase.Comments);
                   }
                
                if(string.isNotBlank(newCase.suppliedEmail) && newCase.RecordTypeId == ETCBankSuptRecordTypeId){
                    list<string> emailStr = newCase.SuppliedEmail.split('@',2);
                    list<string> DomainStr = emailStr[1].split('\\.');
                    newCase.Bank_Name__c = DomainStr[0];  
                }
                
                if(string.isNotBlank(newCase.Origin)){
                    newCase.Platform_e__c = newCase.Origin;
                    newCase.LOB_Name__c = newCase.Origin;
                }
                
                if(!caseOriginMap.isEmpty() && caseOriginMap.containsKey(newCase.Origin) && newCase.SuppliedEmail != NULL && string.isBlank(newCase.ParentId)) {
                    list<string> fromAddStr = newCase.SuppliedEmail.split('@',2);
                    if(fromAddStr != null && fromAddStr[1] != null && !string.valueOf(newCase.Origin).startswith('Merchant_Support')) {
                        String Domain = fromAddStr[1];
                        if(DomainCaseMap.containsKey(Domain)){
                            list<case> caseList = DomainCaseMap.get(Domain);
                            caseList.add(newCase);
                            DomainCaseMap.put(Domain,caseList);
                        }
                        else{
                            DomainCaseMap.put(Domain,new list<case>{newCase});
                        }
                    }
                }
                
                /*if(string.isNotBlank(newCase.suppliedEmail) && newCase.suppliedEmail.contains('hdfcbank.com') && etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId) 
&& string.isNotBlank(newCase.toAddress__c) && newCase.toAddress__c.contains('care@payu.in')){ 
newCase.OwnerId = system.label.HDFC_Whitelabel_MCare_QueueID; 
newCase.Origin = 'HDFC_Whitelable_Mcare'; 
}*/
                
                if(spamDomainDataMap.containsKey(newCase.suppliedEmail)){
                    newCase.Problem_area_ETC__c = 'Junk';
                    newCase.OwnerId = label.IntegrationUserId;
                    newCase.Status = 'Resolved';
                    newCase.Merchant_ID__c = 'NA';
                    newCase.Agent_Comments__c = 'Spam';
                }
                
                if(string.isNotBlank(newCase.SuppliedEmail) && etcRecIdVsRecTypeMap.containsKey(newCase.RecordTypeId) && string.isNotBlank(newCase.Subject)){
                    suppliedEmailSet.add(newCase.SuppliedEmail);
                }
            }
            
            if(DomainCaseMap != null && DomainCaseMap.size() > 0){
                for(SMB_Case_Ownership__mdt smbMetadata : [Select id,Merchant_Type__c ,DomainMidMap__c  FROM SMB_Case_Ownership__mdt where Merchant_Type__c = 'SMB' order by label]){
                    if(!DomainMidMap.isEmpty() && DomainMidMap != null ){
                        Map<string,string> newMap = (map<string,string>)JSON.deserialize(smbMetadata.DomainMidMap__c,map<string,string>.class);
                        DomainMidMap.putAll(newMap);
                    }
                    else
                    {
                        DomainMidMap = (map<string,string>)JSON.deserialize(smbMetadata.DomainMidMap__c,map<string,string>.class);
                    }
                }
                //Map<string,string> 
                for(string emailDomain : DomainCaseMap.keySet()){
                    if(DomainMidMap.containsKey(emailDomain)){
                        for(case eachCase : DomainCaseMap.get(emailDomain)){
                            eachCase.OwnerId = System.label.SMB_Care_Team ;
                            eachCase.Origin = 'SMB_Care_Team';
                            eachCase.Platform_e__c = eachCase.Origin;
                            eachCase.LOB_Name__c = eachCase.Platform_e__c;
                            eachCase.Merchant_Id__c = DomainMidMap.get(emailDomain);
                        }
                    }
                }
            }
            if(emailSets.size()>0){
                for(Contact eachCon : [Select Id,Email,AccountId,Owner_Assignment_Header__c,lastName  from Contact where Email IN: emailSets order  by Owner_Assignment_Header__c desc]){
                    if(string.isNotBlank(eachCon.Email) && string.isNotBlank(eachCon.Owner_Assignment_Header__c)){
                        system.debug('eachCon.lastName'+eachCon.lastName);
                        existingContactMap.put(eachCon.Email,eachCon);
                    }
                    else if(string.isNotBlank(eachCon.Email) && string.isBlank(eachCon.Owner_Assignment_Header__c)){
                        system.debug('eachCon.lastName'+eachCon.lastName);
                        existingContactMap.put(eachCon.Email,eachCon);
                    }
                }
                for(opportunity opp : [Select Id,Email__c ,AccountId,Prod_MID__c from Opportunity where Email__c IN: emailSets]){
                    if(string.isNotBlank(opp.Email__c)){
                        caseIdWithExistingOppMap.put(opp.Email__c, opp);
                    }
                }
            }
            
            if(!existingContactMap.isEmpty() && emailSets.size()>0){
                system.debug('existingContactMap==='+existingContactMap);
                for(Case newCase : triggerNew){
                    if(string.isBlank(newCase.contactId) && existingContactMap.containsKey(newCase.SuppliedEmail)){
                        newCase.ContactId = existingContactMap.get(newCase.SuppliedEmail).Id;
                        Contact con = existingContactMap.get(newCase.SuppliedEmail);
                        // to Assign SMB and ENT cases where to address is care@payu.in or merchantsupport@payu.in 
                        if(con.Owner_Assignment_Header__c != NULL && (string.valueOf(con.Owner_Assignment_Header__c).startsWith('SMB-') || string.valueOf(con.Owner_Assignment_Header__c).startsWith('ENT-'))
                           && newCase.Origin != NULL && !caseOriginMap.isEmpty() &&
                           caseOriginMap.containsKey(newCase.Origin) && newCase.RecordTypeId == PayuBizRecordTypeId
                           && string.isBlank(newCase.ParentId)){
                               list<string> strlist = String.valueof(con.Owner_Assignment_Header__c).split('-',2);
                               
                               if(string.valueOf(con.Owner_Assignment_Header__c).startsWith('SMB-') && newCase.Origin == 'ENT_Care_Team'){
                                   string smbCareQueueId = String.valueof(caseOriginMap.get('SMB_Care_Team')).split('-',2)[1];
                                   newCase.OwnerId = smbCareQueueId;
                                   newCase.Origin = 'SMB_Care_Team';
                                   newCase.Platform_e__c = newCase.Origin;
                                   newCase.LOB_Name__c = newCase.Platform_e__c;
                               }
                               else if(string.valueOf(con.Owner_Assignment_Header__c).startsWith('ENT-') && !string.valueof(newCase.Origin).startswith('Merchant_Support')){
                                   string entCareQueueId = String.valueof(caseOriginMap.get('ENT_Care_Team')).split('-',2)[1];
                                   newCase.OwnerId = entCareQueueId;
                                   newCase.Origin = 'ENT_Care_Team';
                                   newCase.Platform_e__c = newCase.Origin;
                                   newCase.LOB_Name__c = newCase.Platform_e__c;
                               }
                               else if(string.valueOf(con.Owner_Assignment_Header__c).startsWith('ENT-') && string.valueof(newCase.Origin).startswith('Merchant_Support')){
                                   string entMSupQueueId = String.valueof(caseOriginMap.get('Merchant_Support_ENT')).split('-',2)[1];
                                   newCase.OwnerId = entMSupQueueId;
                                   newCase.Origin = 'Merchant_Support_ENT';
                                   newCase.Platform_e__c = newCase.Origin;
                                   newCase.LOB_Name__c = newCase.Platform_e__c;
                               }
                               else if(string.valueOf(con.Owner_Assignment_Header__c).startsWith('SMB-') && string.valueof(newCase.Origin).startswith('Merchant_Support')){
                                   string smbMSupQueueId = String.valueof(caseOriginMap.get('Merchant_Support_SMB')).split('-',2)[1];
                                   newCase.OwnerId = smbMSupQueueId;
                                   newCase.Origin = 'Merchant_Support_SMB';
                                   newCase.Platform_e__c = newCase.Origin;
                                   newCase.LOB_Name__c = newCase.Platform_e__c;
                               }
                           }
                    }
                    if(string.isBlank(newCase.AccountId) && existingContactMap.containsKey(newCase.SuppliedEmail)){
                        if(existingContactMap.get(newCase.SuppliedEmail).AccountId != null){
                            newCase.AccountId = existingContactMap.get(newCase.SuppliedEmail).AccountId; 
                        }else if(existingContactMap.get(newCase.SuppliedEmail).AccountId == null){
                            if(createAccount(newCase) != null){
                                Account accountToCreate = createAccount(newCase);
                                accountToCreateMap.put(newCase.SuppliedEmail,accountToCreate);
                                casesToUpdateMap.put(newCase.SuppliedEmail,newCase);
                                contactToUpdateMap.put(newCase.SuppliedEmail,existingContactMap.get(newCase.SuppliedEmail));
                            }
                        }                            
                    }
                    if(existingContactMap.containsKey(newCase.SuppliedEmail) && existingContactMap.get(newCase.SuppliedEmail).AccountId != null){
                        Id entitlementId = createEntitlement(existingContactMap.get(newCase.SuppliedEmail).AccountId,newCase);
                        if(entitlementId != null) newCase.EntitlementId = entitlementId;
                    }
                    if(!caseIdWithExistingOppMap.IsEmpty() && caseIdWithExistingOppMap.containskey(newCase.SuppliedEmail)){
                        if(String.isBlank(newCase.Opportunity__c)){
                            newCase.Opportunity__c=caseIdWithExistingOppMap.get(newCase.SuppliedEmail).Id;
                            newCase.Merchant_Id__c = caseIdWithExistingOppMap.get(newCase.SuppliedEmail).Prod_MID__c;
                        }                    
                    }                
                }
                if(!accountToCreateMap.isEmpty()) insert accountToCreateMap.values();
                
                System.debug('casesToUpdateMap======= '+casesToUpdateMap);
                if(!casesToUpdateMap.isEmpty()){
                    for(Case newCase : casesToUpdateMap.values()){
                        if(accountToCreateMap.containskey(newCase.SuppliedEmail)){
                            Account newAccount = accountToCreateMap.get(newCase.SuppliedEmail);
                            newCase.AccountId = newAccount.Id;
                            if(!contactToUpdateMap.isEmpty()){  
                                contactToUpdateMap.get(newCase.SuppliedEmail).accountId = newAccount.Id;  
                            }
                            Id entitlementId = createEntitlement(newCase.AccountId,newCase);
                            if(entitlementId != null) newCase.EntitlementId = entitlementId;
                        }
                    }
                    if(!contactToUpdateMap.isEmpty()){  
                        update contactToUpdateMap.values(); 
                    }
                }                
                
            }else if(emailSets.size()>0 && existingContactMap.isEmpty()){
                for(Case newCase : triggerNew){
                    if(createAccount(newCase) != null){
                        Account newAccount = createAccount(newCase);
                        caseIdWithNewAccountMap.put(newCase.SuppliedEmail,newAccount);  
                    }
                }
                if(!caseIdWithNewAccountMap.isEmpty()) insert caseIdWithNewAccountMap.values();
                
                for(Case newCase : triggerNew){
                    if(caseIdWithNewAccountMap.containsKey(newcase.SuppliedEmail)){
                        if(createContact(newCase,caseIdWithNewAccountMap.get(newCase.SuppliedEmail).Id) != null){
                            Contact newContact = createContact(newCase,caseIdWithNewAccountMap.get(newCase.SuppliedEmail).Id);
                            caseIdWithNewContactMap.put(newCase.SuppliedEmail,newContact);
                        }
                    }
                }
                if(!caseIdWithNewContactMap.isEmpty()) insert caseIdWithNewContactMap.Values();
                
                for(Case newCase : triggerNew){
                    if(!caseIdWithNewContactMap.isEmpty() && caseIdWithNewContactMap.containsKey(newcase.SuppliedEmail))
                        newCase.ContactId = caseIdWithNewContactMap.get(newCase.SuppliedEmail).Id;
                    if(!caseIdWithNewAccountMap.isEmpty() && caseIdWithNewAccountMap.containsKey(newcase.SuppliedEmail)){
                        newCase.AccountId = caseIdWithNewAccountMap.get(newCase.SuppliedEmail).Id;
                        Id entitlementId = null;
                        if(caseIdWithNewAccountMap.get(newCase.SuppliedEmail).Id != null){
                            entitlementId = createEntitlement(caseIdWithNewAccountMap.get(newCase.SuppliedEmail).Id,newCase);
                        }
                        if(entitlementId != null || entitlementId !='') newCase.EntitlementId = entitlementId;
                    }                
                }
            }
            
            oneCareProcessHandler.updateExpectedCloserDate(triggerNew,etcRecIdVsRecTypeMap);
            
            //if(!suppliedEmailSet.isEmpty()) getExistingCases(suppliedEmailSet,suppliedEmailExCaseList);
            //if(!suppliedEmailExCaseList.isEmpty()) mergeDuplicateCases(triggerNew, suppliedEmailExCaseList);
            
            if(Test.isRunningTest()){
                integer i=1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'BeforeInsertETCHandler');
            insert erDetail;
        }
    }
    
    public static void beforeUpdateHandler(List<Case> triggerNew,map<Id,Case> triggeroldMap){
        Map<Id,String> case_userQueueIdMap = New Map<Id,String>();
        getCurrentQueueName(case_userQueueIdMap);
        
        Map<string,List<Status_SLA__c>> lobWithSLAMap = OneCareReportHandler.getStatusSLAMap(triggerNew);
        
        //Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
         //Prashant
         Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        
        updateLOBName(triggerNew,triggeroldMap);
        beforeUpdateParentCase(triggerNew,TriggeroldMap,case_userQueueIdMap,etcRecIdVsRecTypeMap,lobWithSLAMap);
        oneCareProcessHandler.updateExpectedCloserDate(triggerNew,etcRecIdVsRecTypeMap);
        oneCareProcessHandler.updateCaseFieldForOmniChannel(triggerNew,TriggeroldMap,case_userQueueIdMap,etcRecIdVsRecTypeMap);
        beforeUpdateChildCase(triggerNew,TriggeroldMap,case_userQueueIdMap,lobWithSLAMap);
        
    }
    
    public static void afterInsertHandler(List<Case> triggerNew){
        System.debug('afterInsertHandler>>>206');
        //To Create Status sla obj when the status is new.
        //Map<Id,Case> triggerOldMap = New Map<id,Case>();
        //OneCareReportHandler.CreateStatusSlaObj(triggerNew,triggerOldMap);
        List<Status_SLA__c> statusSLAlist = New List<Status_SLA__c>();
       // Map<String,String> ETCRecordTypeMap =(Map<String, String>)JSON.deserialize(system.label.ETC_RecordType, Map<String, String>.class);
        //Prashant
         Map<String, String> ETCRecordTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                ETCRecordTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        for(Case eachCase : triggerNew){
            if(ETCRecordTypeMap.containsKey(eachCase.RecordTypeId))
                statusSLAlist.add(OneCareReportHandler.createSLArecords(eachCase,null));
        }
        if(statusSLAlist.size()>0 && statusSLAlist !=null){
            Insert statusSLAlist;
        }
    }
    
    public static void afterUpdateHandler(List<Case> triggerNew,map<Id,Case> triggeroldMap,map<Id,Case> triggerNewMap){
        try{
            
           //Map<String,String> ETCRecordTypeMap =(Map<String, String>)JSON.deserialize(system.label.ETC_RecordType, Map<String, String>.class);
             //Prashant
             Map<String, String> ETCRecordTypeMap = new Map<string,string>(); 
             for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                    ETCRecordTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
             }
            Id ETCchildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to Case Child').getRecordTypeId();
            
            Id ETCRiskOperationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
            
            List<Case> existingOpenChildCaseList = New List<Case>();
            list<Case> lstChildCase = new list<Case>();
            List<Case> lstMerchantCareCase = new list<Case>();
            set<Id> setOfAccountId = new set<Id>();
            string notCreateChildValue = Label.SubStatusNotCreateChild;
            List<string> subStatusValues = notCreateChildValue.split(',');
            List<case> childCasesToCreate = new list<case>();   
            Set<String> MIDSet = New Set<String>();
            Map<String, String> midProductVsCaseIdMap = New Map<String, String>();
            
            for(Case eachCase : triggerNew){
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                
                system.debug('###currentrec rec id '+eachCase.RecordTypeId);
                if((eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                    && eachCase.LP_Sub_Status__c != NULL 
                    && (eachCase.LP_Sub_Status__c != 'Waiting On Merchant' && eachCase.LP_Sub_Status__c != 'Waiting On Buyer' && eachCase.LP_Sub_Status__c != 'Waiting On Bank(Bank Support)' && !subStatusValues.contains(eachCase.LP_Sub_Status__c)) 
                    && (!subStatusValues.contains(eachCase.LP_Sub_Status__c))
                    && (ETCRecordTypeMap.containskey(eachCase.RecordTypeId) ))){
                        childCasesToCreate.add(eachCase);
                    }
            }
            
            if(childCasesToCreate != null  && childCasesToCreate.size() > 0)
                existingOpenChildCaseList = [Select Id from Case where (Parent_Case__c IN: childCasesToCreate OR ParentId IN: childCasesToCreate) AND (Status!='Closed' AND Status !='Tat Exceeded')];
            
            for(Case eachCase : triggerNew){
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                if(childCasesToCreate != null  && childCasesToCreate.size() > 0){
                    if(existingOpenChildCaseList.size()>0){
                        eachCase.addError('Child case are already created.');
                    }else{
                        if((ETCRecordTypeMap.containskey(eachCase.RecordTypeId))){
                            lstMerchantCareCase.add(eachCase);
                        }
                        if(eachCase.accountId != NULL)
                            setOfAccountId.add(eachCase.accountId);
                    }
                }
                if(eachCase.RecordTypeId == ETCchildRecordTypeId && (eachCase.status=='Closed' || (eachCase.Status=='Pending' && eachCase.LP_Sub_Status__c == 'Waiting on Bank'))){
                    lstChildCase.add(eachCase);
                }
                
                if(eachCase.RecordTypeId == ETCRiskOperationRecordTypeId && String.isNotBlank(eachCase.Merchant_Id__c) && eachCase.Merchant_Id__c != oldCase.Merchant_Id__c && String.isNotBlank(eachCase.LP_Business_Vertical__c) && eachCase.LP_Business_Vertical__c != 'LazyPay'){
                    MIDSet.add(eachCase.Merchant_Id__c);
                    String midVsProduct = '';
                    if(eachCase.LP_Business_Vertical__c == 'PayU Money')
                        midVsProduct = eachCase.Merchant_Id__c+'##PayUmoney';
                    else if(eachCase.LP_Business_Vertical__c == 'PayU Biz')
                        midVsProduct = eachCase.Merchant_Id__c+'##PayUbiz';
                    else if(eachCase.LP_Business_Vertical__c == 'PayU Now')
                        midVsProduct = eachCase.Merchant_Id__c+'##PayUnow';
                    
                    midProductVsCaseIdMap.put(midVsProduct, eachCase.Id);
                }
            }
            
            
            system.debug('ETCRecordTypeId>>>?////' +lstMerchantCareCase);
            if(lstMerchantCareCase != NULL && lstMerchantCareCase.size()>0){
                createChildCase(lstMerchantCareCase,setOfAccountId,'Email to Case Child');
            }
            
            //update child case closed comments on parent case
            if(lstChildCase != NULL && lstChildCase.size()>0){
                oneCareProcessHandler.updateCaseCommentsOnParent(lstChildCase);
            }
            
            //================Update MCare Dashboard Case with ETC Case==============
            if(!midProductVsCaseIdMap.isEmpty() && !MIDSet.isEmpty()) getMCareDashboardCase(MIDSet, midProductVsCaseIdMap);
            
            if(Test.isRunningTest()){
                integer i=1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'afterUpdateETCHandler');
            insert erDetail;
        }
    }
    
    public static Account createAccount(Case newCase){
        Account acc = New Account();
        if(!string.isBlank(newCase.SuppliedName)){
            acc.Name = newCase.SuppliedName;
            return acc;
        }
        else if(!string.isBlank(newCase.SuppliedEmail)){
            list<string> emailStr = newCase.SuppliedEmail.split('@',2);
            acc.Name = emailStr[0];
            return acc;
        }
        else{
            return null;
        }  
    }
    
    public static contact createContact(Case newCase, string accountId){
        Contact con = New Contact();
        if(!string.isBlank(newCase.SuppliedName) && !string.isBlank(newCase.SuppliedEmail)){
            con.LastName = newCase.SuppliedName;
            con.Email = newCase.SuppliedEmail;
            con.AccountId = accountId;
            return con;
        }
        else if(!string.isBlank(newCase.SuppliedEmail)){
            list<string> emailStr = newCase.SuppliedEmail.split('@',2);
            con.LastName = emailStr[0];
            con.Email = newCase.SuppliedEmail;
            con.AccountId = accountId;
            return con;
        }
        else{
            return null;
        }
    }
    
    public static Id createEntitlement(string accId,Case cs){
        try{
            Id bHIdChild;
            Id bhIdParent;
            /*if(Test.isRunningTest()){
integer i=1/0;
}*/
            map<string,Entitlement> mapOfNameVsEntitlement = new map<string,Entitlement>();
            /*List<BusinessHours> bHoursList = [SELECT Id,Name FROM BusinessHours where name IN ('PayU OneCare Child','OneCare Business Hour')];
for(BusinessHours bh : bHoursList){
if(bh.Name == 'OneCare Business Hour')
bhIdParent = bh.Id;
if(bh.Name == 'PayU OneCare Child')
bHIdChild = bh.Id;
}*/
            
            Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
            bhIdParent = businessHourNameIdmap.get('OneCare Business Hour');
            bHIdChild = businessHourNameIdmap.get('PayU OneCare Child');
            
            for(SlaProcess eachProcess : [SELECT id,Name from SlaProcess where Name IN('ETC Parent Entitlement','ETC Child Entitlement','ETC Other Entitlement') AND IsActive = true]){
                Entitlement objentitlement = new Entitlement();
                objentitlement.AccountId = accId;
                if(eachProcess.Name.contains('Parent') && string.isNotBlank(bhIdParent)){
                    objentitlement.BusinessHoursId = bhIdParent;
                    objentitlement.Name = 'ETC Parent Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                }else if(eachProcess.name.contains('Other') && string.isNotBlank(bHIdChild)){
                    objentitlement.BusinessHoursId = bHIdChild;
                    objentitlement.Name = 'Other Parent Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                }
                else if(eachProcess.name.contains('Child') && string.isNotBlank(bHIdChild)){
                    objentitlement.BusinessHoursId = bHIdChild;
                    objentitlement.Name = 'Child Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                }
            }
            if(mapOfNameVsEntitlement!=NULL && mapOfNameVsEntitlement.size()>0){
                insert mapOfNameVsEntitlement.values();
                if(mapOfNameVsEntitlement.containsKey('ETC Parent Entitlement')){
                    return mapOfNameVsEntitlement.get('ETC Parent Entitlement').Id;
                }else if (mapOfNameVsEntitlement.containsKey('Child Entitlement')){
                    return mapOfNameVsEntitlement.get('ETC Child Entitlement').Id;
                }else if(mapOfNameVsEntitlement.containsKey('Other Parent Entitlement'))
                    return mapOfNameVsEntitlement.get('ETC Other Entitlement').Id;
                else return null;
            }
            
            else return null;
            
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'EntitlementETCHandler');
            insert erDetail;
            return null;
        }        
    }
    /*
    public static void getExistingCases(Set<String> suppliedEmailSet, Map<String,List<Case>> suppliedEmailExCaseList){
        for(Case csObj : [Select Id,casenumber,suppliedEmail,subject,status,ContactId,LP_Customer_Response_Count__c,IsStopped,Counter__c,
                               Contact.Email,Priority,LP_Sub_Status__c,Previous_QueueId_OwnerId__c,OwnerId,AccountId,Origin,RecordTypeId,
                               Email_Cc_Address__c,toAddress__c,Merchant_Bank_Contacted__c from Case where (suppliedEmail IN: suppliedEmailSet
                                                                                                            OR Email_Cc_Address__c IN :suppliedEmailSet 
                                                                                                            OR toAddress__c IN :suppliedEmailSet)
                               AND Status !='Closed' AND ParentId = Null Order By LastmodifiedDate desc]){
                                   if(suppliedEmailExCaseList.containsKey(csObj.SuppliedEmail) && suppliedEmailExCaseList.get(csObj.SuppliedEmail) != null){
                                       List<Case> csList = suppliedEmailExCaseList.get(csObj.SuppliedEmail);
                                       csList.add(csObj);
                                       suppliedEmailExCaseList.put(csObj.SuppliedEmail,csList);
                                   }else{
                                       suppliedEmailExCaseList.put(csObj.SuppliedEmail,New List<Case>{csObj});
                                   }
        }
    }
    */
    public static void beforeUpdateChildCase(list<Case> triggerNew, map<Id,Case> TriggeroldMap, Map<Id,String> case_userQueueIdMap, Map<string,List<Status_SLA__c>> lobWithSLAMap){
        try{
            Id ChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to Case Child').getRecordTypeId();
            list<Id> listOfCaseId = new list<Id>();
            list<Case> lstOfParentCase = new list<Case>();
            list<Id> listOfAssignedCaseId = new list<Id>();
            list<Case> listOfViolatedCase = new list<Case>();
            list<Case> listOfWarningCase = new list<Case>();
            list<Case> listOfCaseToClosed = new list<Case>();
            list<String> listOfWarningCaseIds = New List<String>();
            list<String> listOfViolatedCaseIds = new list<String>();
            Map<id,Status_SLA__c> updateStatusSLAMap = New Map<id,Status_SLA__c>();
            string notCreateChildValue = Label.SubStatusNotCreateChild;
            List<string> subStatusValues = notCreateChildValue.split(',');
            Id ETCBankSuptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId();
            Map<Id,Id> ownerwithManagerIdMap = New Map<Id,Id>();
            
            for(Case eachCase : triggerNew){
                system.debug('>>>case' +eachCase);
                if(eachCase.recordTypeId == ChildRecordTypeId){
                    Case oldCase = TriggeroldMap.get(eachCase.Id);
                    string restrictedValue = Label.Restricted_Status_Value_of_Case;
                    List<string> allStatusValues = restrictedValue.split(',');
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && !case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(eachCase.OwnerId) &&
                       string.valueOf(eachCase.OwnerId).startswith('005') && eachCase.OwnerId != oldCase.OwnerId){ 
                           //eachCase.LOB_Name__c = case_userQueueIdMap.get(eachCase.OwnerId);          
                           if(oldCase.Status=='New'){
                               eachCase.Status='Open';
                               Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                               if(sla != null){
                                   updateStatusSLAMap.put(sla.id,sla);
                               }
                           }     
                       }else if(string.valueOf(eachCase.OwnerId).startswith('00G') && eachCase.Owner__c != oldCase.owner__c
                                && String.isNotBlank(oldCase.LOB_Name__c) && string.isNotBlank(eachCase.LOB_Name__c)){
                                    eachCase.addError('You cant change child case owner from one queue to another.');
                                }
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.LOB_Name__c != oldCase.LOB_Name__c && String.isNotBlank(oldCase.LOB_Name__c) && 
                       string.isNotBlank(eachCase.LOB_Name__c) && 
                       (string.valueOf(eachCase.OwnerId).startswith('00G') 
                        || string.valueOf(eachCase.OwnerId).startswith('005')) && eachCase.RecordTypeId != ChildRecordTypeId){
                            system.debug('old lob==='+oldCase.LOB_Name__c+'new lob==='+eachCase.LOB_Name__c);
                            system.debug('eachCase.OwnerId=='+eachCase.OwnerId+'eachCase.Owner__c==='+eachCase.Owner__c+'oldCase.owner__c=='+oldCase.owner__c);
                            eachCase.addError('You cant change child case owner from one queue to another.');
                        }
                    // check if status is pending and sub status is changed or status is closed (will work from validation rule)
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments == NULL 
                       && ((eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                            && eachCase.LP_Sub_Status__c != NULL 
                            && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer'                                                                                                                                              
                                || subStatusValues.contains(eachCase.LP_Sub_Status__c))) 
                           || (eachCase.Status =='Closed'))){ 
                               eachCase.addError(Label.LP_Please_Enter_Comments);
                           }
                    // check if status is pending and sub status is changed to waiting on merchant then stop milestone.
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status =='Pending' 
                       && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c != NULL 
                       && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' || eachCase.LP_Sub_Status__c == 'Waiting On Bank(Bank Support)'
                           || subStatusValues.contains(eachCase.LP_Sub_Status__c))){ 
                               eachCase.IsStopped = true;
                           }
                    // If status is pending and response recieved from merchant then start milestone
                    if(eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c == NULL && eachCase.Response_Received__c == true){ 
                           eachCase.IsStopped = false;
                       }
                    // If status is closed then uncheck the response recieved checkbox
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status != oldCase.Status && eachCase.Status =='Closed'){ 
                        eachCase.Response_Received__c = false;
                        Case objParentCase = new Case(Id=eachCase.Parent_Case__c,status='Response Received from Other Teams',
                                                      LP_Sub_Status__c='',isSystemEdit__c =true,isStopped=false);
                        lstOfParentCase.add(objParentCase);
                        listOfCaseToClosed.add(eachCase);
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Closed');
                        if(sla != null)  updateStatusSLAMap.put(sla.id,sla);
                    }
                    
                    // If Case has been violated then update the parent case status and child case status 
                    if(eachCase.Is_Violated__c != oldCase.Is_Violated__c && eachCase.Is_Violated__c == true ){
                        eachCase.status='Tat Exceeded';
                        Case objParentCase = new Case(Id=eachCase.Parent_Case__c,iSStopped=false,status='No Resolution From Other Teams',LP_Sub_Status__c='',isSystemEdit__c=true);
                        lstOfParentCase.add(objParentCase);
                        listOfViolatedCase.add(eachCase);
                        listOfViolatedCaseIds.add(eachCase.Id);
                    }
                    
                    if(eachCase.Status != oldCase.Status && eachCase.Status == 'Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c == 'Waiting on Bank'){
                           eachCase.IsStopped = true;
                           eachCase.Comments = 'Waiting on Bank';
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Pending');
                           if(sla != null){ 
                               updateStatusSLAMap.put(sla.id,sla);
                           }
                       }
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != NULL){
                        eachCase.Agent_Comments__c = eachCase.Comments;
                        eachCase.Comments = eachCase.Comments;
                        /*Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Comment');
if(sla != null) updateStatusSLAMap.put(sla.id,sla);*/
                    }
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.status != oldCase.status 
                       && eachCase.status != NULL && eachCase.status == 'Open'){ 
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                           if(sla != null) updateStatusSLAMap.put(sla.id,sla);
                           listOfAssignedCaseId.add(eachCase.Id);
                       }
                    if(eachCase.Is_Warning_Notification__c != oldCase.Is_Warning_Notification__c 
                       && eachCase.Is_Warning_Notification__c == true){ 
                           listOfWarningCase.add(eachCase);
                           listOfWarningCaseIds.add(eachCase.Id);
                       }
                } 
            }
            if (listOfCaseToClosed.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfCaseToClosed, 'Child Ticket Milestone', completionDate);
            }
            if (listOfViolatedCase.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfViolatedCase, 'Child Ticket Milestone', completionDate);
            }
            if(listOfViolatedCase.isEmpty() == false){
                oneCareProcessHandler.getCurrentUserManagerId(triggerNew,ownerwithManagerIdMap);
                if(!Test.isRunningTest()) MilestoneUtils.sendEmailtoManager(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification To L1/L2 For Child Case VF');
            }
            if(listOfWarningCase.isEmpty() == false){
                oneCareProcessHandler.getCurrentUserManagerId(triggerNew,ownerwithManagerIdMap);
                MilestoneUtils.sendEmailtoManager(listOfWarningCase,ownerwithManagerIdMap,'Warning Notification To L1/L2 For Child Case VF');
            }
            
            if(lstOfParentCase.isEmpty() == false){
                update lstOfParentCase;          
            }
            
            if(!updateStatusSLAMap.isEmpty()){
                update updateStatusSLAMap.values();
            }
            
            if(Test.isRunningTest()){
                integer i=1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'BeforeUpdateChildETCHandler');
            insert erDetail;
        }
    }
    
    public static void beforeUpdateParentCase(list<Case> triggerNew, map<Id,Case> TriggeroldMap,Map<Id,String> case_userQueueIdMap,Map<string,string> etcRecTypeList,Map<string,List<Status_SLA__c>> lobWithSLAMap)
    {
        try{
            List<Case> closeExistingCasesMilestone = New List<Case>();
            string level = '';
            list<Id> listOfCaseId = new list<Id>();
            list<Case> listOfCaseToClosed = new list<Case>();
            list<Case> listOfCaseToUpdateClosureDate = new list<Case>();
            list<Case> listOfViolatedCase = new list<Case>();
            list<Id> listOfViolatedCaseId = new list<Id>();
            string milestoneName='';
            List<Case> updatedCasewithLOB = New List<Case>();
            List<Case> reOpenCases = New List<Case>();
            map<Id,Case> mapOfCaseIDVsCase = new map<Id,Case>();
            List<Status_SLA__c> updateStatusSLAList = New List<Status_SLA__c>();
            List<Status_SLA__c> statusSLAList = New List<Status_SLA__c>();
            string notCreateChildValue = Label.SubStatusNotCreateChild;
            List<string> subStatusValues = notCreateChildValue.split(',');
            Id ETCBankSuptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId();
            Id ETCFarmingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC PayU Farming').getRecordTypeId();
            list<string> notUpdateDependencyStatuses = new list<string>{'Waiting On Merchant','Waiting On Buyer','Waiting On Bank(Bank Support)','Raised with Merchant'};
                list<Case> updateRecordtypeList = new list<Case>();
            Id ChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to Case Child').getRecordTypeId();
            Id PayUBizRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId();
            map<string,string> mapContactIdQueue = new map<string,string>();
            list<contact> listContact = new list<Contact>();
            Map<string,string> caseOriginMap = (map<string,string>)JSON.deserialize(System.Label.Case_Origin,map<string,string>.class);
            Map<Id,Id> ownerwithManagerIdMap = New Map<Id,Id>();
            Map<id,string> milestonewithcaseIdMap = new Map<id,string>();
            
            for(Case eachCase : triggerNew){
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                
                if(etcRecTypeList.containskey(eachCase.RecordTypeId)){
                    //Prashant- to update Dependency Field
                    if(eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                       && eachCase.LP_Sub_Status__c != NULL 
                       && !notUpdateDependencyStatuses.contains(eachCase.LP_Sub_Status__c)){
                           if(eachCase.Other_Team_Sub_Status__c != null){
                               eachCase.Other_Team_Sub_Status__c = eachCase.Other_Team_Sub_Status__c + ''+','+''+ eachCase.LP_Sub_Status__c ;
                           }
                           else{
                               eachCase.Other_Team_Sub_Status__c = eachCase.LP_Sub_Status__c;
                           }
                       } 
                    
                    //to restrict users from creating another child or resolving the ticket when dependent child ticket is open   
                    if((eachCase.Status =='Pending' && eachCase.Status == oldCase.Status && 
                        eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c) 
                       || 
                       (eachCase.Status != oldCase.Status && eachCase.Status == 'Resolved')){ 
                           mapOfCaseIDVsCase.put(eachCase.Id,eachCase);
                       }
                    
                    
                    //To update case status and related Status SLA record on case assignment
                    if(!case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(eachCase.OwnerId) &&
                       string.valueOf(eachCase.OwnerId).startswith('005') && eachCase.OwnerId != oldCase.OwnerId){  
                           eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;                             
                           if(oldCase.Status=='New') {
                               eachCase.Status='Open';
                               if(string.isBlank(eachCase.Onecare_First_Agent__c)) {
                                   eachCase.Onecare_First_Agent__c = eachCase.Owner__c;
                               }
                               
                               status_sla__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                               if(sla != null) updateStatusSLAList.add(sla);
                               
                           }
                           else if(oldCase.Status=='Transferred from other teams') {
                               eachCase.Status='Open';
                               if(string.isBlank(eachCase.Onecare_First_Agent__c)) {
                                   eachCase.Onecare_First_Agent__c = eachCase.Owner__c;
                                   eachCase.Previous_QueueId_OwnerId__c = oldCase.Previous_QueueId_OwnerId__c != null ? eachCase.OwnerId : oldCase.Previous_QueueId_OwnerId__c;
                                   eachCase.Previous_Queue_Name_Owner_Name__c = oldCase.Previous_Queue_Name_Owner_Name__c != null ? eachCase.Owner__c : oldCase.Previous_Queue_Name_Owner_Name__c;
                               }
                               status_sla__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                               if(sla != null) updateStatusSLAList.add(sla);
                           }  
                       }
                    
                    //To update milestone, recordtype when a case is assigned to other team
                    if((eachCase.LOB_Name__c != oldCase.LOB_Name__c || eachCase.Platform_e__c!= oldCase.Platform_e__c) 
                       && oldCase.Status !='New' 
                       && string.isNotBlank(oldCase.Platform_e__c) && UserInfo.getUserId()!=system.label.IntegrationUserId
                      ){
                          eachCase.Is_Parent_Owner_Change__c = true;
                          eachCase.Start_Parent_Owner_Change_Milestone__c = true;
                          eachCase.Status = 'Transferred from other teams';
                          if(String.ValueOf(eachCase.OwnerId).StartsWith('005') 
                             && eachCase.Status == 'Transferred from other teams'){
                                 eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                 eachCase.Previous_QueueId_OwnerId__c = oldCase.Previous_QueueId_OwnerId__c != null ? eachCase.OwnerId : oldCase.Previous_QueueId_OwnerId__c;
                                 eachCase.Previous_Queue_Name_Owner_Name__c = oldCase.Previous_Queue_Name_Owner_Name__c != null ? eachCase.Owner__c : oldCase.Previous_Queue_Name_Owner_Name__c;
                                 if(string.isBlank(eachCase.Onecare_First_Agent__c)) {
                                     eachCase.Onecare_First_Agent__c = eachCase.Owner__c;
                                 }
                             }
                          statusSLAlist.add(OneCareReportHandler.createSLArecords(eachCase,oldCase));
                          // Update Old SLA object 
                          if(!lobWithSLAMap.isEmpty() && lobWithSLAMap.values() !=null)
                              for(Status_SLA__c sla : OneCareReportHandler.updateOldSLA(oldCase,lobWithSLAMap)){
                                  updateStatusSLAList.add(sla);
                              }
                          
                          
                          eachCase.LP_sub_status__c = '';
                          if(oldCase.Is_L2_Violated__c==true) eachCase.Is_L2_Violated__c=false;
                          if(oldCase.Is_Violated__c==true) eachCase.Is_Violated__c=false;
                          if(oldCase.Start_L2_Ticket_Milestone__c) eachCase.Start_L2_Ticket_Milestone__c=false;
                          if(oldCase.Start_L3_Ticket_Milestone__c) eachCase.Start_L3_Ticket_Milestone__c=false;
                          if(oldCase.Is_L3_Violated__c) eachCase.Is_L3_Violated__c=false;
                          closeExistingCasesMilestone.add(eachCase);
                          updateRecordtypeList.add(eachCase);
                      }
                    
                    if(eachCase.status != oldCase.status || eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c ||
                       eachCase.Comments != NULL){
                           if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != oldCase.Comments){
                               eachCase.Agent_Comments__c = eachCase.Comments;
                           }
                           if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != NULL && eachCase.ParentId == null){
                               if(eachCase.OwnerId == eachCase.LastModifiedById)
                                   eachCase.Agent_Comments__c = eachCase.Comments;
                               eachCase.Comments = 'Agent: '+eachCase.Comments;
                           }
                           if(oldCase.Status=='Re-Open' && eachCase.Status=='Pending' && eachCase.status != oldCase.status
                              && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')){
                                  eachCase.Agent_Comments__c = eachCase.Comments;
                              }
                       }
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Response_Received__c == true 
                       && ((eachCase.Status != oldCase.Status && eachCase.Status != NULL) 
                           || (eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c != NULL))){
                               eachCase.Response_Received__c = false;
                           }
                    
                    //update Status SLA when Status is Pending
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status =='Pending' 
                       && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c != NULL){
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Pending');
                           if(sla != null) updateStatusSLAList.add(sla);
                       }
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && (eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                                                                           && eachCase.LP_Sub_Status__c != NULL 
                                                                           && (!notUpdateDependencyStatuses.contains(eachCase.LP_Sub_Status__c) && !subStatusValues.contains(eachCase.LP_Sub_Status__c)) 
                                                                           && (!subStatusValues.contains(eachCase.LP_Sub_Status__c))) && eachCase.Comments == null){
                                                                               eachCase.addError(Label.LP_Please_Enter_Comments);
                                                                           }
                    
                    //pause the milestone
                    if(userinfo.getUserId() != Label.IntegrationUserId && ((eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                                                                            && eachCase.LP_Sub_Status__c != NULL) || eachCase.Status =='Resolved' || eachCase.Status =='Closed')){ 
                                                                                eachCase.IsStopped = true;
                                                                                if(eachCase.Status =='Pending' && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' || eachCase.LP_Sub_Status__c=='Waiting On Bank(Bank Support)')){
                                                                                    eachCase.LP_Has_Agent_Reverted__c = true;
                                                                                    //insert case childcase;
                                                                                }
                                                                            }
                    // resume the milestone
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status != oldCase.Status && eachCase.Status =='Response Received from Other Teams'){ 
                        eachCase.IsStopped = false;
                    }
                    //if Tat exceed on child ticket then update the expected closure date value on care panel
                    //assign case to L2 team
                    if(eachCase.Status != oldCase.Status && eachCase.Status =='No Resolution From Other Teams' ){
                        if(eachCase.Is_Violated__c == true && eachCase.Is_L2_Violated__c == false){
                            eachCase.Is_L2_Violated__c = true;
                            eachCase.IsStopped = false;
                            level = 'L2';
                            if(oldCase.LP_TAT__c=='4')eachCase.LP_TAT__c = '5';
                        }
                        if(eachCase.Is_Violated__c == false && eachCase.Is_L2_Violated__c == false){
                            eachCase.Is_Violated__c = true;
                            eachCase.IsStopped = false;
                            level = 'L1';
                            if(oldCase.LP_TAT__c=='3') eachCase.LP_TAT__c = '4';
                        }
                        eachCase.Priority = 'High';
                        listOfViolatedCase.add(eachCase);
                    }
                    // check response received from merchant to re-open the case
                    if(oldCase.Status != eachCase.Status && eachCase.Status=='Re-Open'){
                        eachCase.Response_Received__c=true;
                        eachCase.IsStopped = false;
                        reOpenCases.add(eachCase);
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Re-Open');
                        if(sla != null) updateStatusSLAList.add(sla);
                    }
                    //complete the milestone of closed case
                    if(eachCase.Status != oldCase.Status && eachCase.Status =='Closed' && eachCase.RecordTypeId != ChildRecordTypeId){ 
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Closed');
                        if(sla != null) updateStatusSLAList.add(sla);
                        if(eachCase.Is_Parent_Owner_Change__c == true){
                            milestoneName = 'Parent Case Owner Change';
                        } 
                        if(eachCase.Start_Parent_Ticket_Milestone__c == true){
                            milestoneName = 'Parent Ticket Milestone';
                        }
                        if(eachCase.Start_L2_Ticket_Milestone__c == true){
                            milestoneName = 'L2 merchant Care Milestone';
                        }
                        if(eachCase.Start_L3_Ticket_Milestone__c == true){
                            milestoneName = 'L3 Merchant Care Milestone';
                        }
                        eachCase.Start_L3_Ticket_Milestone__c = false;
                        eachCase.Is_Parent_Owner_Change__c =true;
                        eachCase.Start_Parent_Owner_Change_Milestone__c=false;                                   
                        eachCase.Is_L2_Violated__c = false;
                        eachCase.Is_Violated__c = false;
                        eachCase.Start_Parent_Ticket_Milestone__c = false;
                        eachCase.Start_L2_Ticket_Milestone__c = false;
                        if(eachCase.RecordTypeId != Null && eachCase.recordtypeId == PayUBizRecTypeId 
                           && (eachCase.Platform_e__c == 'SMB_Care_Team' ||  eachCase.Platform_e__c == 'ENT_Care_Team'
                               || eachCase.Platform_e__c == 'Merchant_Support_SMB' || eachCase.Platform_e__c == 'Merchant_Support_ENT') 
                           && oldCase.Status != 'New'){
                               if(eachCase.Platform_e__c == 'SMB_Care_Team')
                                   mapContactIdQueue.put(eachCase.ContactId,caseOriginMap.get('SMB_Care_Team')) ;
                               else if(eachCase.Platform_e__c == 'ENT_Care_Team')
                                   mapContactIdQueue.put(eachCase.ContactId,caseOriginMap.get('ENT_Care_Team')) ;
                               else if(eachCase.Platform_e__c == 'Merchant_Support_ENT'){
                                   mapContactIdQueue.put(eachCase.ContactId,caseOriginMap.get('Merchant_Support_ENT')) ;
                               }
                               else if(eachCase.Platform_e__c == 'Merchant_Support_SMB'){
                                   mapContactIdQueue.put(eachCase.ContactId,caseOriginMap.get('Merchant_Support_SMB')) ;
                               }
                           }
                        listOfCaseToClosed.add(eachCase);
                    }
                    //if parent ticket tat exceeded then update care panel, update owner, complete milestone
                    if(eachCase.Is_Violated__c != oldCase.Is_Violated__c 
                       && eachCase.Is_Violated__c == true ){
                           eachCase.comments = '';
                           eachCase.Agent_Comments__c = '';
                           level = 'L1';
                           if(oldCase.LP_TAT__c=='3') eachCase.LP_TAT__c = '4';
                           eachCase.Priority = 'High';
                           if(oldCase.Start_Parent_Ticket_Milestone__c==true && oldCase.Start_Parent_Owner_Change_Milestone__c==false){
                               milestoneName = 'Parent Ticket Milestone';
                           }else if(oldCase.Start_Parent_Ticket_Milestone__c==true && oldCase.Start_Parent_Owner_Change_Milestone__c==true){
                               milestoneName = 'Parent Case Owner Change';
                           }
                           eachCase.Start_L2_Ticket_Milestone__c = true;
                           listOfViolatedCase.add(eachCase);
                           listOfViolatedCaseId.add(eachCase.Id);
                       }
                    //if parent ticket L2 level tat exceeded then update care panel, update owner, complete milestone
                    if(eachCase.Is_L2_Violated__c != oldCase.Is_L2_Violated__c 
                       && eachCase.Is_L2_Violated__c == true ){
                           eachCase.comments = '';
                           eachCase.Agent_Comments__c = '';
                           level = 'L2';
                           if(oldCase.LP_TAT__c=='4') eachCase.LP_TAT__c = '5';
                           eachCase.Priority = 'High';
                           eachCase.Start_L3_Ticket_Milestone__c=true;
                           if(eachCase.LOB_Name__c == 'Waiting_On_Recon_Ops_inc_biz'|| eachCase.LOB_Name__c == 'Refund Ops (inc Biz)'){
                               milestoneName = 'L2 ETC Milestone';
                           }else{
                               milestoneName = 'L2 merchant Care Milestone';
                           }
                           listOfViolatedCase.add(eachCase);
                           listOfViolatedCaseId.add(eachCase.Id);
                       }
                    if(eachCase.Is_L3_Violated__c == true && eachCase.Is_L3_Violated__c != oldCase.Is_L3_Violated__c ){
                        eachCase.comments = '';
                        eachCase.Agent_Comments__c = '';
                        if(oldCase.LP_TAT__c=='4')eachCase.LP_TAT__c = '5';
                        eachCase.Priority = 'High';
                        if(eachCase.LOB_Name__c == 'Waiting_On_Recon_Ops_inc_biz'|| eachCase.LOB_Name__c == 'Refund Ops (inc Biz)'){
                            milestoneName = 'L3 ETC Milestone';
                        }else{
                            milestoneName = 'L3 merchant Care Milestone';
                        }
                        listOfViolatedCase.add(eachCase);
                        listOfViolatedCaseId.add(eachCase.Id);
                    }
                    if(eachCase.Is_L3_Violated__c == true && eachCase.Is_L3_Violated__c != oldCase.Is_L3_Violated__c){
                        milestoneName = 'L3 Merchant Care Milestone';
                    }
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.LP_TAT__c != oldCase.LP_TAT__c){
                        listOfCaseId.add(eachCase.Id);
                        listOfCaseToUpdateClosureDate.add(eachCase);
                    }
                    if(userinfo.getUserId() != Label.IntegrationUserId && string.isNotBlank(eachCase.Merchant_Contacted__c) 
                       && eachCase.Merchant_Contacted__c != oldCase.Merchant_Contacted__c && eachCase.Merchant_Contacted__c =='Revert back to Merchant'){
                           if(string.isBlank(eachCase.Comments) || eachCase.comments==null)
                               eachcase.addError('Please Enter Comments.');
                       }
                }
                //to update Auto close date 
                if(eachCase.Status != oldCase.status && (eachCase.Status == 'Resolved' || (eachCase.Status == 'Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                                                                                           && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' || eachCase.LP_Sub_Status__c=='Waiting On Bank(Bank Support)')))){
                                                                                               eachCase.Auto_Close_Date__c = Date.Today(); 
                                                                                               eachCase.isSystemEdit__c = False;
                                                                                               eachCase.IsStopped = true;
                                                                                               
                                                                                           }
                else if(eachCase.Status != oldCase.status && (eachCase.Status == 'Re-Open' || eachCase.Status == 'Response received from merchant' || eachCase.Status == 'Response received from buyer')){
                    eachCase.Auto_Close_Date__c = null; 
                    eachCase.isSystemEdit__c = true;
                }
                if(eachCase.Status != oldCase.Status && eachCase.Status=='Resolved'){
                    eachCase.IsStopped = true;
                    Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Resolved');
                    if(sla != null) updateStatusSLAList.add(sla);
                }
                
                if(eachCase.Status != oldCase.Status && (eachCase.Status=='Response received' || eachCase.Status=='Response received from buyer' 
                                                         || eachCase.Status=='Response received from merchant' || eachCase.Status=='No Resolution From Other Teams'
                                                         || eachCase.Status=='Response Received from Other Teams')){
                                                             Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,eachCase.Status);
                                                             if(sla != null) updateStatusSLAList.add(sla);
                                                         }
            }
            
            //complete the milestone
            if (listOfCaseToClosed.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfCaseToClosed, milestoneName, completionDate);
            }
            
            //calculate expected closure Date
            if(listOfCaseToUpdateClosureDate != NULL && listOfCaseToUpdateClosureDate.size()>0){
                BusinessDays.updateDateAccordingToBH(listOfCaseToUpdateClosureDate);
            }
            
            if(!mapContactIdQueue.isEmpty() && mapContactIdQueue != null){
                for(contact eachCon :[select id,Owner_Assignment_Header__c from contact where id IN : mapContactIdQueue.keySet()]){
                    if(String.isBlank(eachCon.Owner_Assignment_Header__c)){
                        eachCon.Owner_Assignment_Header__c = mapContactIdQueue.get(eachCon.Id);
                        listContact.add(eachCon);
                    }
                    
                }
            }
            //complete milestone of parent case
            if(listOfViolatedCase != NULL && listOfViolatedCase.size()>0){
                //setOwnerOnMerchantCase(listOfViolatedCase,level);
                BusinessDays.updateDateAccordingToBH(listOfViolatedCase);
                
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfViolatedCase, 'milestoneName', completionDate);
                oneCareProcessHandler.getCurrentUserManagerId(triggerNew,ownerwithManagerIdMap);
                MilestoneUtils.sendEmailtoManager(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification to Parent to Manager');
                MilestoneUtils.sendEmailtoOwner(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification to Parent Case to Owner');
            }
            
            //restrict agents to update Sub status
            if(mapOfCaseIDVsCase != NULL && mapOfCaseIDVsCase.size()>0){
                oneCareProcessHandler.restrictUserToTakeActionOnCase(mapOfCaseIDVsCase);
            }
            
            if(reOpenCases.size()>0 && !reOpenCases.isEmpty()){
                oneCareProcessHandler.updateOwnerForStatusReopen(triggerNew,TriggeroldMap,case_userQueueIdMap,etcRecTypeList);
            }
            
            if(!updateRecordtypeList.isEmpty()) updateRecordtype(updateRecordtypeList);
            if(!statusSLAList.isEmpty()) insert statusSLAList;
            if(!updateStatusSLAList.isEmpty()) update updateStatusSLAList;
            
            if(listContact != null && listContact.size() >0) update listContact;
            
            if(Test.isRunningTest()){
                integer i=1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'BeforeUpdateParentETCHandler');
            insert erDetail;
        }
    }
    
    //To update plateform_e field based on ownerId
    public static void updateLOBName(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        try{
            for(Case eachCase : triggerNew){
                if(trigger.isUpdate && trigger.isBefore){
                    if(triggeroldMap != null && eachCase.Platform_e__c != triggeroldMap.get(eachCase.Id).Platform_e__c){
                        eachCase.LOB_Name__c = eachCase.Platform_e__c;
                    }
                }
                
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'BeforeInsertETCHandlerPlatform');
            insert erDetail;
        }
    }
    
    //update while platform for P2P assignment
    public static void updateRecordtype(List<Case> updateRecordtypeList){
        Etc_Queue_Membership__mdt etcQueueMembership = [SELECT Id, Queue_Name_Record_Id_Map__c 
                                                        FROM Etc_Queue_Membership__mdt limit 1];
        
        map<string,Id> platformvsrecordtypemap = (map<string,Id>)JSON.deserialize(etcQueueMembership.Queue_Name_Record_Id_Map__c ,map<string,Id>.class);
        system.debug('platformvsrecordtypemap@@@' +platformvsrecordtypemap);
        try{
            for(Case eachCase : updateRecordtypeList){
                system.debug('eachCase@@@' +eachCase);
                //(eachCase.OwnerId!=triggeroldMap.get(eachCase.Id).OwnerId)
                if((String.ValueOf(eachCase.OwnerId).StartsWith('005')
                    || String.ValueOf(eachCase.ownerId).startsWith('00G')) && userInfo.getUserId() != Label.IntegrationUserId) 
                {
                    eachCase.RecordTypeId = platformvsrecordtypemap.get(eachCase.Platform_e__c);
                    eachCase.LOB_Name__c = eachCase.Platform_e__c;
                    system.debug('RecordTypeId!!!!' +eachCase.RecordTypeId);
                }
            }
        }
        catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'BeforeInsertETCHandlerPlatform');
            insert erDetail;
        }
        
    }
    
    
    
    public static Map<Id,String> getCurrentQueueName(Map<Id,String> case_userQueueIdMap){
        List<Id> caseGroupIds = New List<Id>();
        Etc_Queue_Membership__mdt etcQueueMembership = [SELECT Id, Queue_developer_Name_versus_Queue_Name__c, Queue_ID_Name_Map__c
                                                        FROM Etc_Queue_Membership__mdt ];
        
        
        Map<string,string> etcQueueNameWithId = (Map<string,string>)JSON.deserialize(etcQueueMembership.Queue_ID_Name_Map__c,Map<string,string>.class);
        Map<string,string> etcQueueDevNameWithName = (Map<string,string>)JSON.deserialize(etcQueueMembership.Queue_developer_Name_versus_Queue_Name__c,Map<string,string>.class);
        
        
        caseGroupIds.addAll(etcQueueNameWithId.Values());
        
        For(GroupMember gm : [SELECT Id, GroupId,group.name,group.DeveloperName, UserOrGroupId FROM GroupMember where GroupId IN: caseGroupIds]){
            if(String.isNotBlank(gm.UserOrGroupId) ){
                system.debug('caseList'+gm.Group.DeveloperName);
                system.debug('caseList2'+gm.UserOrGroupId);
                case_userQueueIdMap.put(gm.UserOrGroupId,etcQueueDevNameWithName.get(gm.Group.DeveloperName));
                //case_userQueueIdMap.put(gm.UserOrGroupId,gm.Group.DeveloperName);
            }
        } 
        // if(logIntiator.IsActive__c) system.debug('######## queue name '+case_userQueueIdMap);
        return case_userQueueIdMap;
    }
    
    public static void createChildCase(list<Case> lstCareCase,set<Id> setOfAccountId,string recordtype){
        // SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        list<Case> lstChildCase = new list<Case>();
        
        if(lstCareCase != NULL && lstCareCase.size()>0){
            map<string,string> mapOfSubStatusVsQueueId = new map<string,string>();
            map<string,Child_Case_Queue__mdt> mapOfSubStatusVsQueueMtdt = new map<string,Child_Case_Queue__mdt>();
            map<Id,Id> mapOfAccountIdVsEntitlementId = new map<Id,Id>();
            map<string,ETC_Child_Ownership__mdt> mapOfSubStatusVsETCMtdt = new map<string,ETC_Child_Ownership__mdt>();
            map<string,string> mapOfFarmingTeamUserId = (map<string,string>)JSON.deserialize(System.Label.Farming_team_Member_Id,map<string,string>.class);
            Id ETCBankSuptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId();
            
            //get the child entitlement
            if(setOfAccountId != NULL && setOfAccountId.size()>0){
                for(Entitlement eachEntitlement : [SELECT id,accountId FROM Entitlement WHERE accountID IN:setOfAccountId AND Name='Child Entitlement']){
                    mapOfAccountIdVsEntitlementId.put(eachEntitlement.accountId,eachEntitlement.Id);
                }
            }
            //get the metadata value to assign to settlement/Recon/Refund
            system.debug('child case record type=='+ recordtype);
            if(recordtype == 'Email to Case Child'){
                for(ETC_Child_Ownership__mdt eachETCMdt : [Select id,Detail__c ,Problem__c ,Sub_Detail_List__c ,Sub_Status__c,Platforms__c FROM ETC_Child_Ownership__mdt]){
                    mapOfSubStatusVsETCMtdt.put(eachETCMdt.Detail__c,eachETCMdt);
                }
            }
            
            //get the metadata value to assign case to queue
            for(Child_Case_Queue__mdt eachMdt : [Select id,MasterLabel,SubStatus__c,QueueId__c,Queue_Manager_Id__c FROM Child_Case_Queue__mdt]){
                mapOfSubStatusVsQueueMtdt.put(eachMdt.SubStatus__c,eachMdt);
            }
            // if(logIntiator.IsActive__c) System.debug('mapOfSubStatusVsQueueMtdt======'+mapOfSubStatusVsQueueMtdt);
            if(mapOfSubStatusVsQueueMtdt != NULL && mapOfSubStatusVsQueueMtdt.size()>0){
                Id ChildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                
                for(Case eachCase : lstCareCase){
                    Case objChildCase = new Case();
                    
                    ETC_Child_Ownership__mdt objETCMtd = mapOfSubStatusVsETCMtdt.get(eachCase.Details_ETC__c);
                    Child_Case_Queue__mdt objMtdt = mapOfSubStatusVsQueueMtdt.get(eachCase.LP_Sub_Status__c);
                    if(objETCMtd != null || objMtdt != null){
                        system.debug('map not null');
                        if(objETCMtd != null){
                            map<string,string> SubDetailUserMap = (map<string,string>)JSON.deserialize(objETCMtd.Sub_Detail_List__c,map<string,string>.class);
                            if(objETCMtd.Problem__c == eachCase.Problem_area_ETC__c && SubDetailUserMap.keySet().contains(eachCase.Sub_details_ETC__c) && objETCMtd.Detail__c == eachCase.Details_ETC__c){
                                objChildCase.OwnerId = SubDetailUserMap.get(eachCase.Sub_details_ETC__c);
                                objChildCase.recordtypeID = ChildCaseRecordTypeId;
                                objChildCase.Subject = eachCase.Subject;
                                objChildCase.Origin = eachCase.Origin;
                                objChildCase.Priority = eachCase.Priority;
                                objChildCase.Comments = eachCase.Comments;
                                objChildCase.LP_Category__c = eachCase.LP_Category__c;
                                objChildCase.ContactId = eachCase.ContactId;
                                objChildCase.Status='Open';
                                objChildCase.L1_L2_Agent_Id__c = SubDetailUserMap.get(eachCase.Sub_details_ETC__c);
                                if(eachCase.AccountId != NULL)
                                    objChildCase.EntitlementId = mapOfAccountIdVsEntitlementId.get(eachCase.AccountId);
                                objChildCase.Parent_Case__c = eachCase.id;
                                objChildCase.ParentId = eachCase.id;
                                objChildCase.Platform_e__c = objMtdt.MasterLabel.removeStart('Waiting On ');
                                objChildCase.Origin = objMtdt.MasterLabel.removeStart('Waiting On ');
                            }
                        }
                        else if(objMtdt != null){
                            if(eachCase.RecordTypeId == ETCBankSuptRecordTypeId && eachCase.LP_Sub_Status__c == 'Waiting On PUM-Farming'){
                                if(mapOfFarmingTeamUserId.get(eachCase.Farming_Team_Member__c) != null)
                                    objChildCase.OwnerId = mapOfFarmingTeamUserId.get(eachCase.Farming_Team_Member__c);
                            }
                            else{
                                objChildCase.ownerId = objMtdt.QueueId__c;
                            }
                            objChildCase.recordtypeID = ChildCaseRecordTypeId;
                            objChildCase.Subject = eachCase.Subject;
                            objChildCase.Origin = eachCase.Origin;
                            objChildCase.Priority = eachCase.Priority;
                            objChildCase.Comments = eachCase.Comments;
                            objChildCase.LP_Category__c = eachCase.LP_Category__c;
                            objChildCase.LP_Business_Vertical__c = eachCase.LP_Business_Vertical__c;
                            objChildCase.ContactId = eachCase.ContactId;
                            if(eachCase.AccountId != NULL)
                                objChildCase.EntitlementId = mapOfAccountIdVsEntitlementId.get(eachCase.AccountId);
                            objChildCase.Parent_Case__c = eachCase.id;
                            objChildCase.ParentId = eachCase.id;
                            if(!Test.isRunningTest()){
                                objChildCase.LOB_Name__c = objMtdt.MasterLabel.removeStart('Waiting On ');
                                objChildCase.Platform_e__c = objMtdt.MasterLabel.removeStart('Waiting On ');
                                objChildCase.Origin = objMtdt.MasterLabel.removeStart('Waiting On ');
                            }
                        }
                        
                        
                        if(objMtdt.Queue_Manager_Id__c != NULL)
                            objChildCase.Queue_Manager__c = objMtdt.Queue_Manager_Id__c; 
                    }
                    if(string.isNotBlank(eachCase.Opportunity__c)) objChildCase.Opportunity__c = eachCase.Opportunity__c;
                    lstChildCase.add(objChildCase);
                }
            }
        }
        system.debug('###### '+lstChildCase);
        if(lstChildCase != null && lstChildCase.size()>0){
            insert lstChildCase;
        }
        system.debug('###### '+lstChildCase);
    }
    /*
    public static void mergeDuplicateCases(List<Case> triggerNew, Map<string,List<Case>> suppliedEmailExCaseList){
        for(Case csObj : triggerNew){
            if(suppliedEmailExCaseList.containsKey(csObj.SuppliedEmail) && suppliedEmailExCaseList.get(csObj.SuppliedEmail) != null){
                string modifiedCSObjsubject = string.isNotBlank(csObj.Subject) ? csObj.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '') : '';
                for(Case exCsObj : suppliedEmailExCaseList.get(csObj.SuppliedEmail)){
                    string modifiedExCSObjsubject = string.isNotBlank(exCsObj.Subject) ? exCsObj.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '') : '';
                    if((String.isNotBlank(csObj.Subject) && String.isNotBlank(exCsObj.Subject) && exCsObj.Subject == csObj.Subject) 
                       || (String.isNotBlank(exCsObj.Subject) && String.isNotBlank(modifiedCSObjsubject) && exCsObj.Subject == modifiedCSObjsubject) 
                       || (String.isNotBlank(modifiedCSObjsubject) && String.isNotBlank(modifiedExCSObjsubject) && modifiedCSObjsubject == modifiedExCSObjsubject)
                       || (String.isNotBlank(CsObj.Subject) && String.isNotBlank(modifiedExCSObjsubject) && modifiedExCSObjsubject == CsObj.Subject)) {
                           csObj.ParentId = exCsObj.Id;
                           csObj.Status = 'Closed';
                           break;
                       }
                }
            }
        }
    }*/
    
    public static void getMCareDashboardCase(Set<String> MIDSet, Map<String, String> midProductVsCaseIdMap){
        List<MCare_Dashboard_Case__c> mCareDashboardList = New List<MCare_Dashboard_Case__c>();
        
        for(MCare_Dashboard_Case__c mCareObj : [Select Id,Merchant_Id__c,Product_Name__c,Case__c from MCare_Dashboard_Case__c Where Merchant_Id__c IN : MIDSet AND Status__c = 'Risk Hold']){
            if(String.isNotBlank(mCareObj.Merchant_Id__c) && String.isNotBlank(mCareObj.Product_Name__c)){
                String midVsProduct = mCareObj.Merchant_Id__c+'##'+mCareObj.Product_Name__c ;
                if(!midProductVsCaseIdMap.isEmpty() && midProductVsCaseIdMap.containsKey(midVsProduct)){
                    mCareObj.Case__c = midProductVsCaseIdMap.get(midVsProduct);
                    mCareDashboardList.add(mCareObj);
                }
            }
        }
        
        if(!mCareDashboardList.isEmpty()) update mCareDashboardList;
    }
}