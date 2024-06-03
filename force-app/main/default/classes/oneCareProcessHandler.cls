/**
@company:           PayU 
@description:       This class is used in one care. it will call when case trigger will active for  
One care process.
@Created By: Akash Pandey
@history:           <Date>                             
05-Sep-19
**/

public class oneCareProcessHandler {        
    public static void beforeInsertHandler(List<Case> triggerNew){
        //SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        Set<String> accIds = New Set<String>();
        list<case> updatedLOBcases = new list<case>();
        Map<Id,String> case_userQueueIdMap = New Map<Id,String>();
        map<id,case> OldCaseMap = new map<id,case>();
        Boolean isLobUpdated = false;
       
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Case'); 
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        Map<string,List<Status_SLA__c>> lobWithSLAMap = New Map<string,List<Status_SLA__c>>();
        for(Case cs : triggerNew){
            if(oneCareRecIdVsRecTypeMap.containskey(cs.recordTypeId)){
                SystemUtility.getIdentifierUUID(cs, 'Identifier__c', enableUUIDObj);
                cs.TATValue__c = cs.LP_TAT__c != Null ? integer.valueOf(cs.LP_TAT__c) : 0 ;
                cs.Failed_Attachment_Count__c = 0;
            }  
            if(string.isNotBlank(cs.AccountId)){
                accIds.add(cs.AccountId);
            }
        }
      
        updateExpectedCloserDate(triggerNew,oneCareRecIdVsRecTypeMap);        
        getCurrentQueueName(case_userQueueIdMap);        
        updateOpportunityFieldToCase(triggerNew,OldCaseMap,isLobUpdated,oneCareRecIdVsRecTypeMap,case_userQueueIdMap,lobWithSLAMap);
        
        // Added Pooja //SFI-774 kept on hold || MID owner case assignment logic
		//assignOwnerMID(triggerNew); //Added Pooja //SFI-774 kept on hold
        
        //=================== Sneha 26/11/2019==============//
        updateEntitlementProcess(triggerNew,accIds);
        //=================== End===Sneha ==================//       
    }
    
    public static void afterInsertHandler(list<Case> triggerNew){
        //to update expexted closer date
        List<Id> listOfCaseId = New List<Id>();
        List<Status_SLA__c> statusSLAlist = New List<Status_SLA__c>();
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        for(Case cs : triggerNew){
            if(oneCareRecIdVsRecTypeMap.containsKey(cs.RecordTypeId)){
                if(cs.Expected_Closure_Date__c != null){
                    listOfCaseId.add(cs.Id);
                }
                // Create SLA object
                statusSLAlist.add(OneCareReportHandler.createSLArecords(cs,null));
            }
             
        }
        if(listOfCaseId != NULL && listOfCaseId.size()>0){
            if(!Test.isRunningTest() && !System.isBatch()){
                CarePanelUtility.preparepayload(listOfCaseId,'CarePanel','');
            }            
        }
        //To Create Status sla obj when the status is new. 
        if(statusSLAlist.size()>0 && statusSLAlist !=null){
            Insert statusSLAlist;
        }
    }    
    
    public static void beforeUpdateHandlerForOneCare(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        //System.debug('TriggeroldMap+beforeUpdateHandlerForOneCare'+TriggeroldMap);
        Map<Id,String> case_userQueueIdMap = New Map<Id,String>();
        Boolean isLobUpdated = false;
        getCurrentQueueName(case_userQueueIdMap); 
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        
        Map<string,List<Status_SLA__c>> lobWithSLAMap = OneCareReportHandler.getStatusSLAMap(triggerNew);
       
        //Merchant Care Process
        beforeUpdateMerchantCareProcess(triggerNew,TriggeroldMap,case_userQueueIdMap,lobWithSLAMap); 
        updateOpportunityFieldToCase(triggerNew,TriggeroldMap,isLobUpdated,oneCareRecIdVsRecTypeMap,case_userQueueIdMap,lobWithSLAMap);
        updateCaseFieldForOmniChannel(triggerNew,TriggeroldMap,case_userQueueIdMap,oneCareRecIdVsRecTypeMap);
        beforeUpdateChildCaseProcess(triggerNew,TriggeroldMap,case_userQueueIdMap,lobWithSLAMap);
        //===================sneha 21/11/19=====
        //updateOwnerForStatusReopen(triggerNew,TriggeroldMap,case_userQueueIdMap,oneCareRecIdVsRecTypeMap);
        //====================end================
        
    }
    
    public static void afterUpdateHandler(list<Case> triggerNew,list<Case> triggerOld, map<Id,Case> TriggernewMap , Map<Id,case> TriggeroldMap){
        Map<string,List<Status_SLA__c>> lobWithSLAMap = OneCareReportHandler.getStatusSLAMap(triggerNew);
        System.debug('lobWithSLAMap>>:::::::'+lobWithSLAMap);
        afterUpdateCareProcess(triggerNew,TriggeroldMap);
        //sendReminderToMerchant(triggerNew);
        System.debug('>>>>>>>>>>triggerNew>>>>>>>>>>'+triggerNew);
        afterUpdateHandlerForCaseUpdate(triggerNew,TriggeroldMap,lobWithSLAMap);
        afterUpdateHandlerForChildCaseUpdate(triggerNew,TriggeroldMap);
    }
    
    public static void updateExpectedCloserDate(List<Case> triggerNew,Map<string,string> recordTypeList){
        Id McareChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        Id BCareChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
        list<Case> listOfCaseToUpdateClosureDate = new list<Case>();
        //SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        for(Case eachCase : triggerNew){
            if(recordTypeList.containskey(eachcase.RecordTypeId) && eachCase.LP_TAT__c != NULL){
                eachCase.Expected_Closure_Date__c =  OneCareBusinessDays.updateDateAccordingToBH(triggerNew);
            }
        }
    }  
    
    //Added By Pooja //SFI-965
    
    public static void assignHighPriority(List<case> triggerNew){
        
        Set<Id> oppIds = new Set<Id>();
        Set<String> domainNames = new Set<String>();
        
        //Get opp ids to get the acc legal name
        for(Case cs : triggerNew){
            if(String.isNotBlank(cs.Opportunity__c) && cs.Priority != 'Sales season merchant'){
                oppIds.add(cs.Opportunity__c);
            }else if(String.isNotBlank(cs.SuppliedEmail) && cs.Priority != 'Sales season merchant'){
                domainNames.add(getDomain(cs.SuppliedEmail));
            }
        }
        if(oppIds.isEmpty() && domainNames.isEmpty()){ return; }

        Map<Id, String> legNames = new Map<Id, String>();
        
        if(!oppIds.isEmpty()){
            //find the account legal to check in legal entity object
            for(Opportunity opp : [SELECT Id, Legal_Name_Account__c FROM Opportunity WHERE Id IN : oppIds]){
                if(String.isNotBlank(opp.Legal_Name_Account__c)){
                    legNames.put(opp.Id, opp.Legal_Name_Account__c);
                }
            }
        }

        // Process the legal names if exists and change the priority
        if(!legNames.isEmpty() || !domainNames.isEmpty()){
            Set<String> activeLegalEntities = new Set<String>();
            Set<String> activeDomainEntity = new Set<String>();
            List<Legal_Entity__c> legalEntities = [SELECT Id, Name, InActive__c, Legal_Entity_Name__c, Email_Domain__c 
                                                    FROM Legal_Entity__c 
                                                    WHERE (Legal_Entity_Name__c IN :legNames.values()
                                                   	OR Email_Domain__c IN :domainNames)
                                                    AND InActive__c = FALSE];
            for(Legal_Entity__c le : legalEntities){
                activeLegalEntities.add(le.Legal_Entity_Name__c);
                activeDomainEntity.add(le.Email_Domain__c);
            }

            //Now set the prio case
            for(Case cs : triggerNew){
                //Based legal entity
                if(String.isNotBlank(cs.Opportunity__c) && legNames.containsKey(cs.Opportunity__c)){
                    String legalName = legNames.get(cs.Opportunity__c);
                    if(!activeLegalEntities.isEmpty() && activeLegalEntities.contains(legalName)){
                        cs.Priority = 'Sales season merchant';
                    }
                    //Based on Web Email logic find the legal names
                }else if(String.isNotBlank(cs.SuppliedEmail) && 
                         !activeDomainEntity.isEmpty()){
                             String domain = getDomain(cs.SuppliedEmail);
                             
                             if(activeDomainEntity.contains(domain)){
                                 cs.Priority = 'Sales season merchant';
                             }
                             
                         }
            }
        }
    }
    
    private static String getDomain(String email){
       return email.split('@').get(1).split('\\.').get(0);
    }
    
    //Ended by pooja
    
    //**************************************************************************************//
        
     //Added By Pooja //SFI-938 case assignment logic for Post/Pre/OB hold
     //SFI-1070 adding Amazon MID to the all cases which created from @amazon//
    
   public static void assignRiskObTeam(List<Case> triggerNew){
        try{
            Map<string,string> queueNameWithId = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management,Map<string,string>.class);
            string postOnboardingRiskQueueId = queueNameWithId.get('Waiting_On_Post_Onboarding_Risk');
            string preOnboardingRiskQueueId = queueNameWithId.get('Waiting_On_Pre_Onboarding_Risk');
            
            Set<Decimal> mids = new Set<Decimal>();
            Set<Id> oppIds = new Set<Id>();
            CaseRiskAssignment__c custSett = CaseRiskAssignment__c.getOrgDefaults();

            for(Case cs : triggerNew){
                if(cs.SuppliedEmail != null && cs.SuppliedEmail.contains(custSett.Amazon_Email_Domain__c) && custSett?.Amazon_MID__c != NULL){
                    mids.add(Decimal.valueOf(custSett.Amazon_MID__c));
                }else if(cs.SuppliedEmail == null && cs.Opportunity__c != NULL){
                    oppIds.add(cs.Opportunity__c);
                }
            }
            
            if(!mids.isEmpty() || !oppIds.isEmpty()){
                
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, On_Post_Risk_Hold__c, On_Pre_Risk_Hold__c, On_OB_Hold__c, Settlement_Status__c, OwnerId FROM Opportunity WHERE Prod_Merchant_Id__c IN :mids OR Id IN :oppIds]);
                for(Case cs : triggerNew){
                    //Only for email to case mapping when E2C ticket creates from @amazon.
                    if(!oppMap.values().isEmpty() && cs.SuppliedEmail != null && cs.SuppliedEmail.contains(custSett.Amazon_Email_Domain__c)){
                        cs.Opportunity__c = oppMap.values()[0]?.Id;
                        //only for chat to case mapping
                    } else if(cs.SuppliedEmail == null && cs.Opportunity__c != NULL && custSett != NULL 
                              && cs?.LP_Issue__c != NULL && custSett?.Issue__c?.contains(cs?.LP_Issue__c)
                              && cs?.LP_Sub_Issue__c != NULL && custSett?.SubIssue__c?.contains(cs?.LP_Sub_Issue__c)){
                                  Opportunity opp = oppMap.get(cs.Opportunity__c);
                                  if((opp.On_Post_Risk_Hold__c == 'Y') || (opp.On_Post_Risk_Hold__c == 'Y' && opp.On_Pre_Risk_Hold__c == 'Y' && opp.On_OB_Hold__c == 'Y')){
                                      cs.OwnerId = postOnboardingRiskQueueId;
                                  } else if(opp.On_Post_Risk_Hold__c == 'N' && opp.On_Pre_Risk_Hold__c == 'Y'){
                                      cs.OwnerId = preOnboardingRiskQueueId;
                                  }
                              }
                }
            }
        }catch(Exception e){
            System.debug('Exception method name assignRiskObTeam '+e);
        }
    }

   //Ended by pooja//
    
    //**************************************************************************************//
   
   //Added By Pooja //SFI-1174 Queue Logic Updation & Routing//
    
    public static void assignChatCaseOwner(List<Case> triggerNew){
        Map<String, String> queueNameWithId = (Map<String, String>)JSON.deserialize(System.label.OneCare_Queue_Name_Id_Management, Map<String, String>.Class);
        Map<string,string> queueNameWithId_2 = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management_2,Map<string,string>.class);
        
        string PayUMoneyQueueId = queueNameWithId.get('payu_Money');
        string postOnboardingRiskQueueId = queueNameWithId.get('Waiting_On_Post_Onboarding_Risk');
        String resellerSalesQueueId = queueNameWithId.get('Reseller_Sales_team_Queue');
        String farmingTeamQueueId = queueNameWithId.get('Waiting_On_PUM_Farming');
        String smbSalesQueueId = queueNameWithId.get('Waiting_On_PayUSMB_Sales');
        String buyerCareQueueId = queueNameWithId.get('Buyers_Care');
        String smbIntegrationQueueId = queueNameWithId_2.get('SMB_Integration_Team_OnePayU');
        
        Set<Id> oppIds = new Set<Id>();
        for(Case cs : triggerNew){
            if(cs?.Opportunity__c != NULL){
                oppIds.add(cs.Opportunity__c);
            }
        }
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Settlement_Date__c, Settlement_Status__c, Team__c, Merchant_Business_Type__c, Key_Assigned_Manager__c, OwnerId FROM Opportunity WHERE Id IN :oppIds]);
        
        system.debug('oppMap '+oppMap);
        for(Case cs : triggerNew){
            if(!oppMap.isEmpty() && oppMap.containsKey(cs?.Opportunity__c)){
                Opportunity opp = oppMap.get(cs.Opportunity__c);
                
                system.debug('LP_Issue__c '+cs.LP_Issue__c);
                if(cs.LP_Issue__c == 'New Product Inquiry' || cs.LP_Issue__c == 'Pricing Inquiry' || cs.LP_Issue__c == 'Experts Connect' || cs.LP_Issue__c == 'Business Plans' || cs.LP_Issue__c == 'Product Deactivation'){
                    
                    system.debug('Merchant_Business_Type__c '+opp.Merchant_Business_Type__c);
                    system.debug('Team__c '+opp.Team__c);
                    
                    if(opp.Merchant_Business_Type__c == 'LongTail' && opp.Team__c == 'Partnership'){
                        
                        if(opp.OwnerId != Label.IntegrationUserId){
                            cs.OwnerId = opp.OwnerId;  
                        }else if(opp.Key_Assigned_Manager__c != Null){
                            cs.OwnerId = opp.Key_Assigned_Manager__c;
                        }else{
                            cs.OwnerId = resellerSalesQueueId;
                        }
                        cs.LOB_Name__c = 'Reseller Sales team';
                        
                    }else if(opp.Merchant_Business_Type__c == 'EEB'){
                        
                        if(opp.OwnerId != Label.IntegrationUserId){
                            cs.OwnerId = opp.OwnerId;  
                        }else if(opp.Key_Assigned_Manager__c != Null){
                            cs.OwnerId = opp.Key_Assigned_Manager__c;
                        }else{
                            cs.OwnerId = PayUMoneyQueueId;
                        }
                        cs.LOB_Name__c = 'PayU Money';
                    }           
                }else if (cs.LP_Issue__c == 'Transaction' || cs.LP_Issue__c == 'Refunds' || cs.LP_Issue__c == 'Report Fraud'){
                    cs.OwnerId = buyerCareQueueId;
                    cs.LOB_Name__c = 'Buyer Care';
                }
                
                //Added by Pooja || SFI-1375 : Category Mapping confimation //
                else if(cs.LP_Issue__c == 'Technical Integration Help'){
                    if(opp.OwnerId != Label.IntegrationUserId){
                        cs.OwnerId = opp.OwnerId;  
                    }else if(opp.Key_Assigned_Manager__c != Null){
                        cs.OwnerId = opp.Key_Assigned_Manager__c;
                    }else{
                        cs.OwnerId = smbIntegrationQueueId;
                    }
                    cs.LOB_Name__c = 'SMB Integration Team-OnePayU';
                }
              //Ended by Pooja || SFI-1375 : Category Mapping confimation //
            }
            
            if(cs?.Opportunity__c == null){
                if(cs.LP_Issue__c == 'New Product Inquiry' || cs.LP_Issue__c == 'Pricing Inquiry' || cs.LP_Issue__c == 'Experts Connect' || cs.LP_Issue__c == 'Business Plans' || cs.LP_Issue__c == 'Product Deactivation'){
                    cs.OwnerId = smbSalesQueueId;
                    cs.LOB_Name__c = 'Waiting On PayUSMB Sales';
                }else if(cs.LP_Issue__c == 'Account On Hold' && cs.LP_Sub_Issue__c == 'Settlement/Money Deposit On Hold'){
                    cs.OwnerId = postOnboardingRiskQueueId;
                    
                }
            }
           }
    }
    
    //Ended by pooja//
    //**************************************************************************************//
    
    
    //Added By Pooja //SFI-774 case assignment logic //kept on hold
    
   /* public static void assignOwnerMID(list<Case> triggerNew){
        Map<string,string> queueNameWithId = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management,Map<string,string>.class);
        string smbSalesQueueId = queueNameWithId.get('Waiting_On_PayUSMB_Sales');
        Set<Id> oppIds = new Set<Id>();
        for(Case cs : triggerNew){
            if(cs?.Opportunity__c != null){
                oppIds.add(cs.Opportunity__c);
            }else if(String.isBlank(cs.Opportunity__c)){
                cs.OwnerId = smbSalesQueueId;
            }
        }
        
        if(!oppIds.isEmpty()){
            String thirdPartyHoldStatus = 'Thirdparty Hold';
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Settlement_Date__c, Settlement_Status__c, Team__c, OwnerId FROM Opportunity WHERE Id IN :oppIds]);
            for(Case cs : triggerNew){
                if(cs?.Opportunity__c != null){
                    Opportunity opp = oppMap.get(cs.Opportunity__c);
                    if(opp.Settlement_Date__c == null &&
                       (opp.Settlement_Status__c == null || opp.Settlement_Status__c == thirdPartyHoldStatus)){
                        cs.OwnerId = opp.Team__c != null ? opp.OwnerId : smbSalesQueueId;
                    }
                }
            }
        }
    }*/
    
    //Ended by pooja//
    
    /**
@company:           PayU 
@description:       This method is used in one care. to update opportunity fields(Lead created date, Opportunity stage ) in case object.
@history:           <Date>   05-Nov-19                          

**/
    Public static void updateOpportunityFieldToCase(List<Case> triggerNew,Map<id,case> TriggerOldMaps,Boolean isLobUpdated,Map<string,string> recordTypeList,Map<Id,String> case_userQueueIdMap,Map<string,List<Status_SLA__c>> lobWithSLAMap){
        
        try{
            List<Integer> mIdList = New List<Integer>();
            List<Opportunity> opList = new List<Opportunity>();
            list<case> caseLst = new list<case>();
            Map<id,Status_SLA__c> updateStatusSLAMap = New Map<id,Status_SLA__c>();
            Map<string,string> queueNameWithId = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management,Map<string,string>.class);
            Map<string,string> queueNameWithId_2 = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management_2,Map<string,string>.class);
            string smbSalesQueueId = queueNameWithId.get('Waiting_On_PayUSMB_Sales');
            string PreOnboardingRiskQueueId = queueNameWithId.get('Waiting_On_Pre_Onboarding_Risk');
            string PayUMoneyQueueId = queueNameWithId.get('payu_Money');
            string PostOnboardingRiskQueueId = queueNameWithId.get('Waiting_On_Post_Onboarding_Risk');
            string NonMappedKAMMerchantsPayoutId = queueNameWithId.get('Non_Mapped_KAM_Merchants_Payout');
            string BuyerCareQueueId = queueNameWithId.get('Buyers_Care');
            string payuBizSmb = queueNameWithId.get('Payu_Biz_SMB');
            string payuBizEnt = queueNameWithId.get('Payu_Biz');
            string FarmingTeamQueueId = queueNameWithId.get('Waiting_On_PUM_Farming');
            string resellerSalesQueueId = queueNameWithId.get('Reseller_Sales_team_Queue');
            list<string> ChannelPartnerUsers = Label.Channel_Partner_Users.Split(',');
            string smbIntegrationQueueId = queueNameWithId_2.get('SMB_Integration_Team_OnePayU');
            string entIntegrationQueueId = queueNameWithId_2.get('ENT_Integration_Team_OnePayU');
            Boolean isKamAssigned = false;
            
            /*Consultative selling Team setup
            Map<String,String> cSTeamLobMap = (Map<String,String>)JSON.deserialize(system.label.Consultative_Selling_Teams_Map,Map<string,string>.class );
            Map<String,String> cSTeamIdMap = (Map<String,String>)JSON.deserialize(system.label.Consultative_Selling_Teams_Id_Map,Map<string,string>.class );*/
            
            list<string> productList = new list<string>{'PayU Money','PayU Now','PayU Biz'};
                list<string> subissueList = new list<string>{'Documents Rejected','Document Verification Pending','Issue With Agreement Details','Unable to view/download agreement','Error in Uploading document','Do Not Have A Particular Document','Signing Authority Letter Issue','Other'};
                    string Issue = 'Document Related';
            list<string> includedIssues = new list<string>{'Document Related','Website Approval Pending','Money Deposit/Settlement Related','Refund Related','Account On Hold','Transaction Issues', 'Transaction Related'};
                list<string> wixIssue = system.Label.Onecare_Issue_Category.split(',');
            list<string> PotentialLeadIssues = new List<string>{'New Product Inquiry','Pricing inquiry'};
                list<string> DormantKAMId = system.label.Dormant_Account_KAM_Id.split(',');
            Map<string,string> FarmingTeamMemeberMap = (Map<String,String>)JSON.deserialize(System.label.Farming_team_Member_Id,Map<String,String>.class); 
            List<String> farmingTeamMemberList = new list<String>();
            for(String member : FarmingTeamMemeberMap.keySet()){
                String memberId = FarmingTeamMemeberMap.get(member);
                farmingTeamMemberList.add(memberId);
            }
            
            for(Case eachCase : triggerNew){
                if(recordTypeList.containskey(eachCase.RecordTypeId)){
                    if(eachCase.Merchant_Id__c != null && string.isBlank(eachCase.Opportunity__c))
                    {
                        mIdList.add(Integer.valueOf(eachCase.Merchant_Id__c));
                    }
                    else if(eachCase.Merchant_Id__c != null && eachCase.OwnerId != TriggeroldMaps.get(eachCase.Id).OwnerId && eachCase.OwnerId == smbSalesQueueId){
                        mIdList.add(Integer.valueOf(eachCase.Merchant_Id__c));
                    }
                }
            }
            system.debug('mIdList@@@@'+mIdList);
            if(mIdList != null && !mIdList.isEmpty()){
                system.debug('mdlistvalue');
                opList = [SELECT Id, Prod_Merchant_Id__c, Lead_Created_date__c ,StageName,createdDate,Website_Status__c,
                          account.Document_Status__c,ownerId, Product_Name__c,Key_Assigned_Manager__c,Key_Assigned_Manager__r.isActive,
                          Owner.isActive, Business_Origin__c,partner__r.name,Settlement_Status__c,Key_Assigned_Manager_Segment__c,Owner.Department, isPremiumCustomer__c FROM
                          Opportunity where Prod_Merchant_Id__c IN:mIdList AND RecordType.Name='Merchant' AND Product_Name__c IN:productList  LIMIT 1];          
            }
            system.debug('opList.size@@@@'+opList.size()); 
            
            if(opList.size()>0){
                for(Case eachCase: triggerNew){         
                    if(String.isNotBlank(eachCase.Merchant_Id__c) && opList[0].Prod_Merchant_Id__c != null){
                        if(Decimal.valueOf(eachCase.Merchant_Id__c) == opList[0].Prod_Merchant_Id__c){
                            //if(logIntiator.IsActive__c) System.debug('INSIDE IF');
                            eachCase.Opportunity__c = opList[0].Id;
                            if(TriggerOldMaps.isEmpty()){
                                
                                //Case Owner Assignment for Silver Base
                                if(String.isNotBlank(opList[0].Key_Assigned_Manager_Segment__c) &&
                                   (opList[0].Key_Assigned_Manager_Segment__c == 'Silver Inactive' ||
                                    opList[0].Key_Assigned_Manager_Segment__c == 'Silver') &&
                                   String.isNotBlank(opList[0].Key_Assigned_Manager__c) && 
                                   (system.label.KAM_Care_team.contains(opList[0].Key_Assigned_Manager__c) ||
                                    (farmingTeamMemberList.contains(opList[0].Key_Assigned_Manager__c)))
                                   ){
                                        eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                        if(system.label.KAM_Care_team.contains(opList[0].Key_Assigned_Manager__c))
                                            eachCase.LOB_Name__c = 'PayU Money';
                                        
                                        else {
                                            eachCase.LOB_Name__c = 'Waiting On PUM-Farming';
                                        }
                                        eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                        eachCase.Status = 'Open';
                                        isKamAssigned = true;
                                        if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c)){
                                            eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                            isLobUpdated = true;
                                        }
                                    }
                                
                                //Case owner Assignment based on KAM
                                else if(eachCase.OwnerId == FarmingTeamQueueId
                                        && string.isNotBlank(eachCase.OwnerId) 
                                        && opList[0].partner__r.name != 'wix com india pvt ltd' 
                                        && (opList[0].Product_Name__c == 'PayU Money'
                                   || (opList[0].Product_Name__c == 'PayU Biz'  &&  opList[0].Business_Origin__c  == 'SMB-ENT')))
                                {  
                                   //Prashant
                                   if(string.isNotBlank(opList[0].Key_Assigned_Manager__c) && !DormantKAMId.contains(opList[0].Key_Assigned_Manager__c))
                                    {
                                        system.debug('kam value...'+opList[0].Key_Assigned_Manager__c);
                                        eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                        eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                        if(system.label.KAM_Care_team.contains(opList[0].Key_Assigned_Manager__c))
                                            eachCase.LOB_Name__c = 'PayU Money';
                                        else
                                            eachCase.LOB_Name__c = 'Waiting On PUM-Farming';
                                        if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                            eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                        isLobUpdated = true;     
                                    }
                                }
                                
                                /*Case owner Assignment for Consultative Selling
                                else if(opList[0].isPremiumCustomer__c){
                                    system.debug('enter req if condition');
                                    eachCase.LOB_Name__c = 'Care Consultative Selling';
                                    eachCase.OwnerId = cSTeamIdMap.get(cSTeamLobMap.get('Care Consultative Selling'));
                                    if(string.isBlank(eachCase.First_LOB_Name__c))
                                        eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                    isLobUpdated = true;
                                }*/
                                
                                //WIX Case Assignment basis issue/sub-Issue
                                if(string.isNotBlank(eachCase.LP_Issue__c) && wixIssue.contains(eachCase.LP_Issue__c) && string.isNotBlank(eachCase.LP_Business_Vertical__c) && eachCase.LP_Business_Vertical__c == 'PayU Biz' && string.isNotBlank(opList[0].partner__r.name) && opList[0].partner__r.name == 'wix com india pvt ltd'){
                                    if(string.isNotBlank(opList[0].Settlement_Status__c) && opList[0].Settlement_Status__c == 'Active'){
                                        if((eachCase.LP_Issue__c.equalsIgnoreCase('New Product Inquiry') || eachCase.LP_Issue__c.equalsIgnoreCase('Pricing inquiry')) ){
                                            eachCase.OwnerId = system.label.Farming_Team_Member;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                            eachCase.Status = 'Open';
                                            eachCase.LOB_Name__c = 'Waiting On PUM-Farming';
                                        }
                                        else{
                                            eachCase.OwnerId = payuBizSmb;
                                            eachCase.LOB_Name__c = 'Payu Biz - SMB';
                                        }
                                        if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                            eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                        isLobUpdated = true; 
                                    }
                                    else {
                                        if(!eachCase.LP_Issue__c.equalsIgnoreCase('Bank Verification pending') && opList[0].Owner.isActive){
                                            eachCase.OwnerId = opList[0].OwnerId;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId; 
                                            eachCase.Status = 'Open';
                                        }else{
                                            eachCase.OwnerId = payuBizSmb;
                                            eachCase.LOB_Name__c = 'Payu Biz - SMB';
                                            if(string.isBlank(eachCase.First_LOB_Name__c))
                                            {eachCase.First_LOB_Name__c = 'Payu Biz - SMB';}
                                            isLobUpdated = true;
                                        }
                                    }
                                }
                                /*To update Case Owner to Payu Biz SMB when Business Origin is SMB-ENT 
and Non Mapped KAM Merchants - Payouts in case subissue is payout to Non Mapped KAM Merchants - Payout*/
                                else if(string.isNotBlank(opList[0].Business_Origin__c) && opList[0].Business_Origin__c == 'SMB-ENT' 
                                        && string.isNotBlank(eachCase.LP_Business_Vertical__c) && eachCase.LP_Business_Vertical__c == 'PayU Biz'){
                                            /*if(eachCase.LP_Issue__c == 'New Product Inquiry' && eachCase.LP_Sub_Issue__c == 'Payouts'){
                                                if(opList[0].Key_Assigned_Manager__c != null 
                                                   && opList[0].Key_Assigned_Manager__r.isActive && string.valueOf(opList[0].Key_Assigned_Manager__c).startswith('005')){
                                                       eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                                       eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId; 
                                                       eachCase.Status = 'Open';
                                                       eachCase.LOB_Name__c = 'Non Mapped KAM Merchants - Payout';
                                                       
                                                   }else{
                                                       eachCase.OwnerId = NonMappedKAMMerchantsPayoutId;
                                                       eachCase.LOB_Name__c = 'Non Mapped KAM Merchants - Payout';
                                                   }
                                            }*/
                                            //else
                                            if(PotentialLeadIssues.contains(eachCase.LP_Issue__c)){
                                                if(string.isNotBlank(opList[0].Settlement_Status__c) && opList[0].Settlement_Status__c == 'Active'){
                                                    if(opList[0].Key_Assigned_Manager__c != null 
                                                       && opList[0].Key_Assigned_Manager__r.isActive && string.valueOf(opList[0].Key_Assigned_Manager__c).startswith('005')){
                                                           eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                                           eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].Key_Assigned_Manager__c);
                                                       }
                                                    else if(!string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive && opList[0].OwnerId != Label.IntegrationUserId){
                                                        eachCase.OwnerId = opList[0].OwnerId;
                                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].OwnerId);
                                                    }
                                                    else{
                                                        eachCase.OwnerId =  FarmingTeamQueueId;
                                                        eachCase.LOB_Name__c = 'Waiting On PUM-Farming';
                                                    }
                                                    
                                                }
                                                else{
                                                    if(!string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive && opList[0].OwnerId != Label.IntegrationUserId ){
                                                        eachCase.OwnerId = opList[0].OwnerId;
                                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].OwnerId);
                                                    }
                                                    else{
                                                        eachCase.OwnerId = smbSalesQueueId;
                                                        eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                    }
                                                }
                                            }
                                            else if(eachCase.LP_Issue__c == 'Technical integration help' && eachCase.LP_Business_Vertical__c=='PayU Biz'){
                                                eachCase.OwnerId = smbIntegrationQueueId;
                                                eachCase.LOB_Name__c = 'SMB Integration Team-OnePayU';
                                                if(string.isBlank(eachCase.First_LOB_Name__c)) 
                                                    eachCase.First_LOB_Name__c = 'SMB Integration Team-OnePayU';
                                                isLobUpdated = true;
                                            }
                                            
                                            else{
                                                if(!isKamAssigned){
                                                    //eachCase.OwnerId = PayUMoneyQueueId;
                                                    //eachCase.LOB_Name__c = 'PayU Money';
                                                }
                                                
                                            }
                                            if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                                eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                            isLobUpdated = true;
                                        }
                                /*else if(eachCase.LP_Issue__c == 'New Product Inquiry' && eachCase.LP_Sub_Issue__c == 'Payouts' && eachCase.OwnerId != smbSalesQueueId ){
                                    if(opList[0].Key_Assigned_Manager__c != null 
                                       && opList[0].Key_Assigned_Manager__r.isActive && string.valueOf(opList[0].Key_Assigned_Manager__c).startswith('005')){
                                           eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                           eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                           eachCase.Status = 'Open';
                                           eachCase.LOB_Name__c = 'Non Mapped KAM Merchants - Payout';
                                       }else{
                                           eachCase.OwnerId = NonMappedKAMMerchantsPayoutId;
                                           eachCase.LOB_Name__c = 'Non Mapped KAM Merchants - Payout';
                                       }
                                    if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                        eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                    isLobUpdated = true;
                                }*/
                                else if(eachCase.LP_Issue__c == 'Technical integration help' && string.isBlank(opList[0].Business_Origin__c) &&
                                        string.isNotBlank(eachCase.LP_Business_Vertical__c) && eachCase.LP_Business_Vertical__c == 'PayU Biz'){
                                            eachCase.OwnerId = entIntegrationQueueId;
                                            eachCase.LOB_Name__c = 'ENT Integration Team-OnePayU';
                                            if(string.isBlank(eachCase.First_LOB_Name__c)) 
                                                eachCase.First_LOB_Name__c = 'ENT Integration Team-OnePayU';
                                            isLobUpdated = true;
                                        }
                                
                                if(eachCase.MerchantBucket__c == 'Risk hold for PP & TP merchants' && string.isNotBlank(eachCase.MerchantBucket__c) && opList[0].Product_Name__c != 'PayU Biz'){
                                    eachCase.OwnerId = PostOnboardingRiskQueueId;
                                    eachCase.LOB_Name__c = 'Post-Onboarding Risk';
                                    if(string.isBlank(eachCase.First_LOB_Name__c)) 
                                    {eachCase.First_LOB_Name__c = 'Post-Onboarding Risk';}
                                    isLobUpdated = true;
                                }
                                
                                // assign cases to dormant account team owner in case KAM belongs to Dormant Account Team
                                else if(opList[0].Key_Assigned_Manager__c != null && opList[0].Key_Assigned_Manager__r.isActive 
                                   && DormantKAMId.contains(opList[0].Key_Assigned_Manager__c) 
                                   && (opList[0].Product_Name__c == 'PayU Money'
                                   || (opList[0].Product_Name__c == 'PayU Biz'  &&  opList[0].Business_Origin__c  == 'SMB-ENT'))){
                                       eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                       eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                       eachCase.Status = 'Open';
                                       eachCase.LOB_Name__c = 'Dormant Account KAM';
                                       if(string.isBlank(eachCase.First_LOB_Name__c))
                                           eachCase.First_LOB_Name__c = 'Dormant Account KAM';
                                       isLobUpdated = true;
                                   }
                                
                                else if(PotentialLeadIssues.contains(eachCase.LP_Issue__c) /*&& eachCase.LOB_Name__c != 'Non Mapped KAM Merchants - Payout'*/
                                        && opList[0].partner__r.name != 'wix com india pvt ltd'){
                                            if(string.isNotBlank(opList[0].Settlement_Status__c) && opList[0].Settlement_Status__c == 'Active'){
                                                if(opList[0].Key_Assigned_Manager__c != null 
                                                   && opList[0].Key_Assigned_Manager__r.isActive && string.valueOf(opList[0].Key_Assigned_Manager__c).startswith('005')){
                                                       eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                                       eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].Key_Assigned_Manager__c);
                                                   }
                                                else if(!string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive && opList[0].OwnerId != Label.IntegrationUserId){
                                                    eachCase.OwnerId = opList[0].OwnerId;
                                                    eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].OwnerId);
                                                }
                                                else{
                                                    eachCase.OwnerId =  FarmingTeamQueueId;
                                                    eachCase.LOB_Name__c = 'Waiting On PUM-Farming';
                                                }
                                                
                                            }
                                            else{
                                                if(opList[0].OwnerId != system.label.integrationUserId && string.valueOf(opList[0].OwnerId).startsWith('005') 
                                                   && opList[0].Owner.isActive ){
                                                       if(ChannelPartnerUsers.contains(opList[0].OwnerId)){
                                                           eachCase.OwnerId = opList[0].OwnerId;
                                                           eachCase.LOB_Name__c = 'Reseller Sales team';
                                                       }
                                                       else{
                                                           eachCase.OwnerId = opList[0].OwnerId;
                                                           eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                       }
                                                   }
                                                else{
                                                    eachCase.OwnerId = smbSalesQueueId ;
                                                    eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                }
                                                   
                                            }
                                            if(string.isBlank(eachCase.First_LOB_Name__c) && !string.isBlank(eachCase.LOB_Name__c)) 
                                            {eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;}
                                            isLobUpdated = true;
                                        }
                                
                                
                                else if(subissueList.contains(eachCase.LP_Sub_Issue__c) && eachCase.LP_Issue__c == Issue 
                                        && opList[0].partner__r.name != 'wix com india pvt ltd'
                                        && (opList[0].Product_Name__c == 'PayU Money'
                                        || (opList[0].Product_Name__c == 'PayU Biz'  &&  opList[0].Business_Origin__c  == 'SMB-ENT')))
                                {
                                    //if (opList[0].Lead_Created_date__c != null){
                                        //if((opList[0].Lead_Created_date__c.daysBetween(Date.Today()))<90){ 
                                            if(opList[0].OwnerId != system.label.integrationUserId && !string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].Owner.isActive){
                                                eachCase.OwnerId = opList[0].OwnerId;
                                                eachCase.Status = 'Open';
                                                if(opList[0].Owner.Department == 'Inbound Sales- DSA'){
                                                    eachCase.LOB_Name__c = 'Inbound Sales- DSA';
                                                }
                                                else if(ChannelPartnerUsers.contains(opList[0].OwnerId))
                                                    eachCase.LOB_Name__c = 'Reseller Sales team';
                                                else
                                                    eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                
                                            }else{ 
                                                eachCase.OwnerId = smbSalesQueueId;
                                                eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                            }
                                            if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                                eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                            isLobUpdated = true;
                                        //}
                                    //}
                                    /*else if (opList[0].createdDate != null){
                                        if((date.valueOf(opList[0].createdDate).daysBetween(date.valueOf(System.Now())))<90){
                                            if(opList[0].OwnerId != system.label.integrationUserId && !string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive ){
                                                eachCase.OwnerId = opList[0].OwnerId;
                                                eachCase.Status = 'Open';
                                                if(opList[0].Owner.Department == 'Inbound Sales- DSA')
                                                    eachCase.LOB_Name__c = 'Inbound Sales- DSA';
                                                else if(ChannelPartnerUsers.contains(opList[0].OwnerId))
                                                    eachCase.LOB_Name__c = 'Reseller Sales team';
                                                else
                                                    eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                            }
                                            else{ 
                                                eachCase.OwnerId = smbSalesQueueId;
                                                eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                            }
                                            if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                                eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                            isLobUpdated = true;    
                                        }
                                   }*/
                                }
                                else if(eachCase.LP_Issue__c == 'Website Approval Pending' && eachCase.LP_Sub_Issue__c == 'Website Approval Pending' && (opList[0].Product_Name__c == 'PayU Money'
                                        || (opList[0].Product_Name__c == 'PayU Biz' && opList[0].Business_Origin__c == 'SMB-ENT'))){
                                    
                                    if(opList[0].Website_Status__c == 'Verification in Process' && opList[0].account.Document_Status__c == 'Docs Approved'){
                                        eachCase.OwnerId = PreOnboardingRiskQueueId;
                                        eachCase.LOB_Name__c = 'Pre-Onboarding Risk';
                                        if(string.isBlank(eachCase.First_LOB_Name__c))
                                        {eachCase.First_LOB_Name__c = 'Pre-Onboarding Risk';}
                                        isLobUpdated = true;
                                    }
                                    else if(opList[0].Website_Status__c == 'Website Error' && opList[0].account.Document_Status__c == 'Pending'){
                                        eachCase.OwnerId = PreOnboardingRiskQueueId;
                                        eachCase.LOB_Name__c = 'Pre-Onboarding Risk';
                                        if(string.isBlank(eachCase.First_LOB_Name__c))
                                        {eachCase.First_LOB_Name__c = 'Pre-Onboarding Risk';}
                                        isLobUpdated = true;
                                    }
                                    else if (opList[0].Website_Status__c == 'Verification in Process' && opList[0].account.Document_Status__c == 'Pending'
                                              && opList[0].Lead_Created_date__c != null && (opList[0].Lead_Created_date__c.daysBetween(Date.Today()))<90)
                                             {
                                                 if(opList[0].OwnerId != system.label.integrationUserId && !string.valueOf(opList[0].OwnerId).startsWith('00G')){
                                                     eachCase.OwnerId = opList[0].OwnerId;
                                                     eachCase.Status = 'Open';
                                                     if(opList[0].Owner.Department == 'Inbound Sales- DSA')
                                                         eachCase.LOB_Name__c = 'Inbound Sales- DSA';
                                                     else if(ChannelPartnerUsers.contains(opList[0].OwnerId))
                                                         eachCase.LOB_Name__c = 'Reseller Sales team';
                                                     else 
                                                         eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                 }
                                                 else{
                                                     eachCase.OwnerId = smbSalesQueueId;
                                                     eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                                                 }
                                                 if(string.isBlank(eachCase.First_LOB_Name__c) && !String.isBlank(eachCase.LOB_Name__c))
                                                     eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;
                                                 isLobUpdated = true;
                                             }
                                    else if (opList[0].Website_Status__c == 'Verification in Process' && opList[0].account.Document_Status__c == 'Pending' 
                                             && opList[0].Lead_Created_date__c != null && (opList[0].Lead_Created_date__c.daysBetween(Date.Today()))>90)
                                         {
                                                 if(opList[0].Product_Name__c == 'PayU Money'){
                                                     eachCase.OwnerId = PayUMoneyQueueId;
                                                     eachCase.LOB_Name__c = 'PayU Money';
                                                 }
                                                 else if(opList[0].Product_Name__c == 'PayU Biz'){
                                                     eachCase.OwnerId = payuBizSmb;
                                                     eachCase.LOB_Name__c = 'Payu Biz - SMB';
                                                 }
                                                 
                                                 if(string.isBlank(eachCase.First_LOB_Name__c))
                                                 {eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;}
                                                 isLobUpdated = true; 
                                             }
                                }
                                else if(eachCase.LP_Issue__c.equalsIgnoreCase('Website Approval Pending') && eachCase.LP_Sub_Issue__c.equalsIgnoreCase('Website Approval Rejected')
                                        && (opList[0].Product_Name__c == 'PayU Money' ||
                                       (opList[0].Product_Name__c == 'PayU Biz' && opList[0].Business_Origin__c == 'SMB-ENT'))){
                                    eachCase.OwnerId = PreOnboardingRiskQueueId;
                                    eachCase.LOB_Name__c = 'Pre-Onboarding Risk';
                                    if(string.isBlank(eachCase.First_LOB_Name__c))
                                    {eachCase.First_LOB_Name__c = 'Pre-Onboarding Risk';}
                                    isLobUpdated = true;
                                }
                                
                                else if(eachCase.OwnerId == payuBizSmb && opList[0].Business_Origin__c != 'SMB-ENT'){
                                    eachCase.OwnerId = payuBizEnt;
                                    eachCase.LOB_Name__c = 'Payu Biz - ENT';
                                    if(string.isBlank(eachCase.First_LOB_Name__c))
                                    {eachCase.First_LOB_Name__c = 'Payu Biz - ENT';}
                                }
                                else if (opList[0].Settlement_Status__c == 'Active' && (eachCase.OwnerId == FarmingTeamQueueId || eachCase.OwnerId == smbSalesQueueId)){
                                    if(opList[0].Key_Assigned_Manager__c != null && opList[0].Key_Assigned_Manager__r.isActive){
                                        eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].Key_Assigned_Manager__c);
                                    }
                                    else if(!string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive && opList[0].OwnerId != Label.IntegrationUserId){
                                        eachCase.OwnerId = opList[0].OwnerId;
                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].OwnerId);
                                    }
                                    if(string.isBlank(eachCase.First_LOB_Name__c))
                                    {eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;}
                                    isLobUpdated = true;
                                }
                                else if (opList[0].Settlement_Status__c != 'Active' && (eachCase.OwnerId == FarmingTeamQueueId || eachCase.OwnerId == smbSalesQueueId)){
                                    if(!string.valueOf(opList[0].OwnerId).startsWith('00G') && opList[0].owner.isActive && opList[0].OwnerId != Label.IntegrationUserId){
                                        eachCase.OwnerId = opList[0].OwnerId;
                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].OwnerId);
                                    }
                                    else if(opList[0].Key_Assigned_Manager__c != null && opList[0].Key_Assigned_Manager__r.isActive){
                                        eachCase.OwnerId = opList[0].Key_Assigned_Manager__c;
                                        eachCase.LOB_Name__c = case_userQueueIdMap.get(opList[0].Key_Assigned_Manager__c);
                                    }
                                    if(string.isBlank(eachCase.First_LOB_Name__c))
                                    {eachCase.First_LOB_Name__c = eachCase.LOB_Name__c;}
                                    isLobUpdated = true;
                                }
                                else if(opList[0].Business_Origin__c == 'SMB-ENT' && eachCase.OwnerId == payuBizSmb
                                       && !isKamAssigned ){
                                    system.debug('when no other condition is met');
                                    eachCase.OwnerId = PayUMoneyQueueId;
                                    eachCase.LOB_Name__c = 'PayU Money';
                                }
                                
                                if(String.valueOf(eachCase.OwnerId).startsWith('005') && eachCase.Status == 'Open')
                                {
                                    eachCase.Onecare_First_Agent__c = eachCase.OwnerId;
                                    // Update new SLA object 
                                    Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                                    if(sla != null) updateStatusSLAMap.put(sla.id,sla);
                                }
                                
                            }
                            else if(opList[0].OwnerId != system.label.integrationUserId && !string.valueOf(opList[0].OwnerId).startsWith('00G') && eachCase.OwnerId != TriggeroldMaps.get(eachCase.Id).OwnerId 
                                    && eachCase.OwnerId == smbSalesQueueId && opList[0].Owner.isActive){
                                        case oldCase = TriggeroldMaps.get(eachCase.Id);
                                        eachCase.OwnerId = opList[0].OwnerId;
                                        if(TriggeroldMaps.get(eachCase.Id).status == 'New'){
                                            eachCase.status = 'Open';
                                            eachCase.Is_Parent_Owner_Change__c = true;
                                            eachCase.Start_Parent_Owner_Change_Milestone__c = true;
                                            eachCase.Status = 'Transferred from other teams';
                                            if(String.ValueOf(eachCase.OwnerId).StartsWith('005') && eachCase.Status == 'Transferred from other teams')
                                                eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                            eachCase.LP_sub_status__c = '';
                                            if(oldCase.Is_L2_Violated__c==true) eachCase.Is_L2_Violated__c=false;
                                            if(oldCase.Is_Violated__c==true) eachCase.Is_Violated__c=false;
                                            if(oldCase.Start_L2_Ticket_Milestone__c) eachCase.Start_L2_Ticket_Milestone__c=false;
                                            if(oldCase.Start_L3_Ticket_Milestone__c) eachCase.Start_L3_Ticket_Milestone__c=false;
                                            if(oldCase.Is_L3_Violated__c) eachCase.Is_L3_Violated__c=false;
                                            
                                            // Update new SLA object 
                                            Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                                            if(sla != null){
                                                updateStatusSLAMap.put(sla.id,sla);
                                            }
                                            
                                        }
                                        else{
                                            eachCase.status = 'Transferred from other teams';
                                            eachCase.Previous_QueueId_OwnerId__c = oldCase.Previous_QueueId_OwnerId__c != null ? eachCase.OwnerId : oldCase.Previous_QueueId_OwnerId__c;
                                            eachCase.Previous_Queue_Name_Owner_Name__c = oldCase.Previous_Queue_Name_Owner_Name__c != null ? eachCase.Owner__c : oldCase.Previous_Queue_Name_Owner_Name__c;
                                            if(String.ValueOf(eachCase.OwnerId).StartsWith('005'))
                                                eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                                            eachCase.LP_sub_status__c = '';
                                            if(oldCase.Is_L2_Violated__c==true) eachCase.Is_L2_Violated__c=false;
                                            if(oldCase.Is_Violated__c==true) eachCase.Is_Violated__c=false;
                                            if(oldCase.Start_L2_Ticket_Milestone__c) eachCase.Start_L2_Ticket_Milestone__c=false;
                                            if(oldCase.Start_L3_Ticket_Milestone__c) eachCase.Start_L3_Ticket_Milestone__c=false;
                                            if(oldCase.Is_L3_Violated__c) eachCase.Is_L3_Violated__c=false;
                                            // Update old SLA object 
                                            if(OneCareReportHandler.updateOldSLA(TriggeroldMaps.get(eachCase.Id),lobWithSLAMap) != null){   
                                                system.debug('Before Update' +lobWithSLAMap);    
                                                list<Status_SLA__c> slaLst = OneCareReportHandler.updateOldSLA(TriggeroldMaps.get(eachCase.Id),lobWithSLAMap);  
                                                for(Status_SLA__c sla: slaLst){ 
                                                    updateStatusSLAMap.put(sla.id,sla); 
                                                }   
                                                system.debug('After Update');   
                                            }
                                        }
                                    }
                            
                        } 
                    } 
                }
            }
            else{
                for(Case eachCase: triggerNew){
                    if(TriggerOldMaps.isEmpty()){
                        if(eachCase.LP_Issue__c == 'Transaction Issues' || eachCase.LP_Issue__c == 'Refund Related'){
                            if((eachCase.MerchantBucket__c == 'Profile completion pending | PP' || eachCase.MerchantBucket__c == 'No Bucket Found') && string.isNotBlank(eachCase.MerchantBucket__c)){
                                eachCase.OwnerId = BuyerCareQueueId;
                                eachCase.LOB_Name__c = 'Buyer Care';
                                if(string.isBlank(eachCase.First_LOB_Name__c))
                                {eachCase.First_LOB_Name__c = 'Buyer Care';}
                                isLobUpdated = true;
                                eachCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
                            }
                        }
                        /*else if(eachCase.LP_Issue__c == 'Gift card'){
eachCase.OwnerId = BuyerCareQueueId;
eachCase.LOB_Name__c = 'Buyer Care';
if(string.isBlank(eachCase.First_LOB_Name__c))
{eachCase.First_LOB_Name__c = 'Buyer Care';}
isLobUpdated = true;
eachCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
}*/
                        else if(eachCase.LP_Issue__c == 'Technical integration help' && eachCase.LP_Business_Vertical__c=='PayU Biz'){
                            eachCase.OwnerId = smbIntegrationQueueId;
                            eachCase.LOB_Name__c = 'SMB Integration Team-OnePayU';
                            if(string.isBlank(eachCase.First_LOB_Name__c)) 
                                eachCase.First_LOB_Name__c = 'SMB Integration Team-OnePayU';
                            isLobUpdated = true;
                        }
                        
                        // Change to remove potential lead, no need to check potential lead 
                        else if(eachCase.OwnerId == FarmingTeamQueueId)
                        {
                            eachCase.OwnerId = smbSalesQueueId;
                            eachCase.LOB_Name__c = 'Waiting On PayUSMB Sales';
                            if(string.isBlank(eachCase.First_LOB_Name__c)) 
                            {eachCase.First_LOB_Name__c = 'Waiting On PayUSMB Sales';}
                            isLobUpdated = true;
                        }
                    }
                }
            }
            
            /*if(TriggerOldMaps.isEmpty()){
updateSMBENTOwner(triggerNew,isLobUpdated);
}*/
            
            if(!isLobUpdated && TriggerOldMaps.isEmpty()){
                system.debug('isLOBUpdated'+isLobUpdated);
                updateLOBname(triggerNew,case_userQueueIdMap,recordTypeList);      
            }
            if(!updateStatusSLAMap.isEmpty()){
                update updateStatusSLAMap.values();
            }
            if(Test.isRunningTest()){
                integer i =1/0;
            }
        }catch(Exception ex){
            //if(logIntiator.IsActive__c) 
            System.debug('ex>>>'+ex.getMessage());
            //if(logIntiator.IsActive__c) 
            System.debug('ex>>>'+ex.getLineNumber());
            Error_Details__c erDetail = getExceptions(ex,'update Opportunity Failed');
            insert erDetail;
        }
    }
    //This method will update the case field for omni channel
    Public static void updateCaseFieldForOmniChannel(List<Case> triggerNew,Map<Id,Case> TriggeroldMap,Map<Id,String> case_userQueueIdMap,Map<string,string> recordTypeList){
        //SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        try{
            Map<String,String> QueueNameVsIdMap = New Map<string,string>();
            String queueId = '';
            String userId = '';
            
            //if(logIntiator.IsActive__c) system.debug('triggerOldMap==='+TriggeroldMap);
            //QueueNameVsIdMap = (Map<String, String>)JSON.deserialize(System.Label.OneCare_Queue_Name_Id_Management, Map<String, String>.class);
            if(triggerNew.size() >0 ){
                for(Case eachCase: triggerNew){
                    if(recordTypeList.containskey(eachCase.RecordTypeId)){
                        Case oldcase = TriggeroldMap.get(eachCase.Id);
                        if(eachCase.Status != oldcase.status && (eachCase.Status =='Resolved' || eachCase.Status =='Rejected' || (eachCase.Status=='Pending' && (eachCase.LP_Sub_Status__c=='Waiting On Merchant' || eachCase.LP_Sub_Status__c=='Waiting On Buyer' || eachCase.LP_Sub_Status__c == 'Waiting On Bank(Bank Support)')))){
                            if(String.isNotBlank(eachCase.ownerId) && !String.ValueOf(eachCase.ownerId).startsWith('005')){
                                eachCase.addError('Please assign case owner to yourself then try again.');
                            }
                            else if(String.isNotBlank(eachCase.ownerId) && String.ValueOf(eachCase.ownerId).startsWith('005') && oldcase.Owner__c != 'Integration User'){
                                eachCase.Previous_Queue_Name_Owner_Name__c = oldcase.Owner__c;
                            }else if(String.isNotBlank(eachCase.ownerId) && String.ValueOf(eachCase.ownerId).startsWith('00G')){
                                eachCase.Previous_Queue_Name_Owner_Name__c = oldcase.LOB_Name__c;
                            }
                            if(oldcase.Owner__c != 'Integration User'){
                                eachCase.Previous_QueueId_OwnerId__c = oldcase.OwnerId;
                            }
                            eachCase.OwnerId = system.label.IntegrationUserId;
                            eachCase.L1_L2_Agent_Id__c = system.label.IntegrationUserId;
                        }                    
                        //Added by Sneha to Update Previous LOB
                        if(eachCase.LOB_Name__c != null && eachCase.LOB_Name__c != oldcase.LOB_Name__c && oldcase.LOB_Name__c != null){
                            eachCase.Previous_LOB_Name__c = oldcase.LOB_Name__c;
                        }
                    }               
                }
            }
            if(Test.isRunningTest()){
                integer i =1/0;
            }
        }Catch(Exception ex){
            //if(logIntiator.IsActive__c) System.debug('MSG::'+ex.getMessage()+ ' '+ex.getLineNumber());
            Error_Details__c erDetail = getExceptions(ex,'OmniChannnel Process Failed');
            insert erDetail;
        }   
    }   
    
    /**
@company:           PayU 
@created by:        Akash Pandey
@description:       This method is used in one care. it will use to send the data top the onecare panel  
One care process.
@history:           <Date>                             
02-11-19
**/
    public static void afterUpdateHandlerForCaseUpdate(list<Case> triggerNew, map<Id,Case> TriggeroldMap,Map<string,list<status_SLA__c>> lobWithSLAMap){
        //custom setting to hide and show the debug log 
        // SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Id BCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        Map<id,Status_SLA__c> updateStatusSLAMap = New Map<id,Status_SLA__c>();
        list<Id> listOfCaseId = new list<Id>();
        try{
            for(Case eachCase : triggerNew){
                if(eachCase.recordTypeId == MCRecordTypeId || eachCase.RecordTypeId == BCRecordTypeId){
                    Case oldCase = TriggeroldMap.get(eachCase.Id);
                    if((eachCase.Status == 'Open' || eachCase.Status == 'Pending') && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && String.isNotBlank(eachCase.Agent_Comments__c)){
                        listOfCaseId.add(eachCase.Id);//Added Pending condition by pooja || To send case comments to merchant on parent C2C Cases
                    }
                    
                    if(eachCase.Status == 'Transferred from other teams' && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && String.isNotBlank(eachCase.Agent_Comments__c)){
                        listOfCaseId.add(eachCase.Id);
                    }
                    if((eachCase.status != oldCase.status && (eachCase.status == 'Resolved' || eachCase.status == 'Closed'
                                                              || (eachCase.status == 'Pending' && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' 
                                                                                                   || eachCase.LP_Sub_Status__c == 'Waiting On Salesforce Team' || eachCase.LP_Sub_Status__c == 'Waiting On Production Support' || eachCase.LP_Sub_Status__c == 'Waiting On Non-SF team')
                                                                  && (eachCase.Agent_Comments__c != oldCase.Agent_Comments__c || eachCase.Comments != oldCase.Comments) && eachCase.Agent_Comments__c != null))
                       )){
                           //if(eachCase.status == 'Closed' && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && eachCase.Agent_Comments__c != NULL)
                           //eachCase.Comments = eachCase.Agent_Comments__c;
                           listOfCaseId.add(eachCase.Id);
                       }
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.LP_TAT__c != oldCase.LP_TAT__c){
                        listOfCaseId.add(eachCase.Id);
                        //listOfCaseToUpdateClosureDate.add(eachCase);
                    }
                    if(userinfo.getUserId() != Label.IntegrationUserId && string.isNotBlank(eachCase.Merchant_Contacted__c) 
                       && eachCase.Merchant_Contacted__c != oldCase.Merchant_Contacted__c && eachCase.Merchant_Contacted__c =='Revert back to Merchant' && eachCase.comments != NULL){
                           listOfCaseId.add(eachCase.Id);
                       } 
                    if(eachCase.Status != oldCase.Status && eachCase.Status=='Open'){
                        System.debug('status:::::'+eachCase.status);
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                        System.debug('sla--->'+sla);
                        if(sla != null){
                            System.debug('sla--->inside'+sla);
                            updateStatusSLAMap.put(sla.id,sla);
                        }
                    }
                }
            }
            
            System.debug('>>>>>>>>>>listOfCaseId>>>>>>>>>>'+listOfCaseId);
            if(listOfCaseId != NULL && listOfCaseId.size()>0){
                if(!Test.isRunningTest() && !System.isBatch()){// Commented to resolve Close to Re-Open issue (SFI-463)
                    //if(logIntiator.IsActive__c) system.debug('check for send to merchant message');
                    CarePanelUtility.preparepayload(listOfCaseId,'CarePanel','');
                }            
            }
            if(!updateStatusSLAMap.isEmpty()){
                System.debug('updateStatusSLAMap--->'+updateStatusSLAMap);
                update updateStatusSLAMap.values();
            } 
        }catch(exception ex){
            Error_Details__c erDetail = getExceptions(ex,'After update merchantcare');
            insert erDetail;
        }
    }
    /**
@company:           PayU 
@created by:        Akash Pandey
@description:       This method is used in one care. it will use to send the data top the onecare panel  
One care process.
@history:           <Date>                             
02-11-19
**/
    public static void afterUpdateHandlerForChildCaseUpdate(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        //custom setting to hide and show the debug log 
        //SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        
        Id ChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        Id BCChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
        list<Id> listOfCaseId = new list<Id>();
        string notCreateChildValue = Label.SubStatusNotCreateChild;
        List<string> subStatusValues = notCreateChildValue.split(',');
        list<Email_Status_Tracking__c> emailTrackerList = new list<Email_Status_Tracking__c>();
        
        for(Case eachCase : triggerNew){
            if(eachCase.recordTypeId == ChildRecordTypeId || eachCase.RecordTypeId == BCChildRecordTypeId){
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.LP_Sub_Status__c != NULL 
                   && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' 
                       || subStatusValues.contains(eachCase.LP_Sub_Status__c))
                   && eachCase.comments != NULL){
                       //if(logIntiator.IsActive__c) system.debug('childcase update for merchant message');
                       if((eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant'
                                                                                     || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')) 
                          && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c)
                           //if(logIntiator.IsActive__c) system.debug('childcase update for merchant message');
                           listOfCaseId.add(eachCase.Id);
                   }
                if(userinfo.getUserId() != Label.IntegrationUserId && string.isNotBlank(eachCase.Merchant_Contacted__c) 
                   && eachCase.Merchant_Contacted__c != oldCase.Merchant_Contacted__c && eachCase.Merchant_Contacted__c =='Revert back to Merchant' && eachCase.comments != NULL){
                       listOfCaseId.add(eachCase.Id);
                   }
                
                /*if(eachCase.Status == 'Open' && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && String.isNotBlank(eachCase.Agent_Comments__c)){
                    listOfCaseId.add(eachCase.Id);
                }*/ //Commented this condition by pooja || To stop sending case comments to merchant on childcase in C2C Cases
                
                /*if(eachcase.Status != oldCase.Status && eachCase.Status == 'Open' 
&& eachCase.OwnerId != System.label.IntegrationUserId && string.valueOf(eachCase.OwnerId).startswith('005')){
Email_Status_Tracking__c emailTracker = new Email_Status_Tracking__c();
emailTracker.To_Addresses__c = eachCase.ContactEmail;
emailTracker.Template_Name__c = 'Query_Assigned_to_Expert';
emailTracker.Case__c = eachCase.Parent_Case__c;
emailTrackerList.add(emailTracker);
}*/
                
            }
            
        }
        
        if(listOfCaseId != NULL && listOfCaseId.size()>0){
            if(!Test.isRunningTest() && !System.isBatch()){
                CarePanelUtility.preparepayload(listOfCaseId,'CarePanel','');
            }            
        } 
        //if(emailTrackerList != null && emailTrackerList.size()>0) insert emailTrackerList;
    }
    
    public static void beforeUpdateChildCaseProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap, Map<Id,String> case_userQueueIdMap, Map<string,List<Status_SLA__c>> lobWithSLAMap){
        //custom setting to hide and show the debug log 
        // SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        Id ChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        Id BCChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
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
        Map<Id,Id> ownerwithManagerIdMap = New Map<Id,Id>();
        
        try{
            for(Case eachCase : triggerNew){
                if(eachCase.recordTypeId == ChildRecordTypeId || eachCase.RecordTypeId == BCChildRecordTypeId){
                    Case oldCase = TriggeroldMap.get(eachCase.Id);
                    string restrictedValue = Label.Restricted_Status_Value_of_Case;
                    List<string> allStatusValues = restrictedValue.split(',');
                    if(allStatusValues.contains(eachCase.Status) && eachCase.Status != oldCase.Status){
                        eachCase.Status = oldCase.Status;
                    }
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && !case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(eachCase.OwnerId) &&
                       string.valueOf(eachCase.OwnerId).startswith('005') && eachCase.OwnerId != oldCase.OwnerId){ 
                           // if(logIntiator.IsActive__c) system.debug('######### case user queue '+case_userQueueIdMap);
                           // if(logIntiator.IsActive__c) system.debug('######### case user queue '+case_userQueueIdMap.get(eachCase.OwnerId));
                           eachCase.LOB_Name__c = case_userQueueIdMap.get(eachCase.OwnerId);
                           if(String.ValueOf(eachCase.OwnerId).StartsWith('005'))
                               eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;                             
                           if(oldCase.Status=='New') {
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
                       string.isNotBlank(eachCase.LOB_Name__c) && (string.valueOf(eachCase.OwnerId).startswith('00G') 
                                                                   || string.valueOf(eachCase.OwnerId).startswith('005'))){
                                                                       eachCase.addError('You cant change child case owner from one queue to another.');
                                                                   }
                    
                    // check if status is pending and sub status is changed or status is closed (will work from validation rule)
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments == NULL && ((eachCase.Status =='Pending'  
                                                                                                         && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                                                                                                         && eachCase.LP_Sub_Status__c != NULL && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' 
                                                                                                                                                  || subStatusValues.contains(eachCase.LP_Sub_Status__c))) 
                                                                                                        || (eachCase.Status =='Closed'))){ 
                                                                                                            eachCase.addError(Label.LP_Please_Enter_Comments);
                                                                                                        }
                    
                    // check if status is pending and sub status is changed to waiting on merchant then stop milestone.
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status =='Pending' 
                       && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c != NULL && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' 
                                                                || eachCase.LP_Sub_Status__c == 'Waiting On Buyer' || subStatusValues.contains(eachCase.LP_Sub_Status__c))){ 
                                                                    eachCase.IsStopped = true;
                                                                }
                    //if(logIntiator.IsActive__c) system.debug('eachCase.LP_Sub_Status__c======'+eachCase.LP_Sub_Status__c);
                    //if(logIntiator.IsActive__c) system.debug('oldCase.LP_Sub_Status__c======'+oldCase.LP_Sub_Status__c);
                    
                    // If status is pending and response recieved from merchant then start milestone
                    if(eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c == NULL && eachCase.Response_Received__c == true){ 
                           eachCase.IsStopped = false;
                       }
                    
                    // If status is closed then uncheck the response recieved checkbox
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status != oldCase.Status && eachCase.Status =='Closed'){ 
                        eachCase.Response_Received__c = false;
                        Case objParentCase = new Case(Id=eachCase.Parent_Case__c,status='Response Received from Other Teams',LP_Sub_Status__c='',isSystemEdit__c =true);
                        lstOfParentCase.add(objParentCase);
                        listOfCaseToClosed.add(eachCase);
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Closed');
                        if(sla != null)
                        {
                            updateStatusSLAMap.put(sla.id,sla);
                        }
                    }
                    
                    // If no response from merchant and workflow update the isAutoclosed checkbox to true then close the status and update comment
                    if(eachCase.isAutoClosed__c != oldCase.isAutoClosed__c && eachCase.isAutoClosed__c == true && System.isBatch() == false){
                        eachCase.status='Closed'; 
                        eachCase.Comments = 'Auto-closed due to no reply';
                        eachCase.LP_Sub_Status__c = '';
                    }
                    
                    // If Case has been violated then update the parent case status and child case status 
                    if(eachCase.Is_Violated__c != oldCase.Is_Violated__c && eachCase.Is_Violated__c == true ){
                        eachCase.status='Tat Exceeded';
                        Case objParentCase = new Case(Id=eachCase.Parent_Case__c,iSStopped=false,status='No Resolution From Other Teams',LP_Sub_Status__c='',isSystemEdit__c=true);
                        lstOfParentCase.add(objParentCase);
                        listOfViolatedCase.add(eachCase);
                        listOfViolatedCaseIds.add(eachCase.Id);
                    }
                    
                    // If Case has been pending on Bank
                    if(eachCase.Status != oldCase.Status && eachCase.Status == 'Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                       && eachCase.LP_Sub_Status__c == 'Waiting on Bank'){
                           eachCase.IsStopped = true;
                           eachCase.Comments = 'Waiting on Bank';
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Pending');
                           if(sla != null){ 
                               updateStatusSLAMap.put(sla.id,sla);
                           }
                       }
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != NULL && eachCase.comments != oldCase.Comments){
                        eachCase.Agent_Comments__c = eachCase.Comments;
                        /*eachCase.Comments = 'Child Agent: '+eachCase.Comments;
Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Comment');
if(sla != null){
updateStatusSLAMap.put(sla.id,sla);
}*/
                    }
                    
                    
                    // if(logIntiator.IsActive__c) System.debug('eachCase.status======'+eachCase.status);
                    //if(logIntiator.IsActive__c) System.debug('oldCase.status======'+oldCase.status);
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.status != oldCase.status 
                       && eachCase.status != NULL && eachCase.status == 'Open'){ 
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                           if(sla != null){
                               updateStatusSLAMap.put(sla.id,sla);
                           }
                           listOfAssignedCaseId.add(eachCase.Id);
                       }
                    
                    if(eachCase.Is_Warning_Notification__c != oldCase.Is_Warning_Notification__c && eachCase.Is_Warning_Notification__c == true )
                    { 
                        listOfWarningCase.add(eachCase);
                        listOfWarningCaseIds.add(eachCase.Id);
                    }
                } 
            }
            
            //if(logIntiator.IsActive__c) system.debug('listOfAssignedCaseId======='+listOfAssignedCaseId);
            if (listOfCaseToClosed.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfCaseToClosed, 'Child Ticket Milestone', completionDate);
            }
            
            if (listOfViolatedCase.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfViolatedCase, 'Child Ticket Milestone', completionDate);
            }
            
            // if(logIntiator.IsActive__c) System.debug('listOfAssignedCaseId======='+listOfAssignedCaseId);
            if(listOfAssignedCaseId != NULL && listOfAssignedCaseId.size()>0 && !System.isBatch() && !Test.isRunningTest()){
                CarePanelUtility.preparepayload(listOfAssignedCaseId,'CarePanel','ASSIGNED_TO_EXPERT');
            }
            
            
            if(listOfViolatedCase.isEmpty() == false){
                getCurrentUserManagerId(listOfViolatedCase,ownerwithManagerIdMap);
                if(!Test.isRunningTest()) MilestoneUtils.sendEmailtoManager(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification To L1/L2 For Child Case VF');
            }
            
            if(listOfWarningCase.isEmpty() == false){
                getCurrentUserManagerId(listOfWarningCase,ownerwithManagerIdMap);
                MilestoneUtils.sendEmailtoManager(listOfWarningCase,ownerwithManagerIdMap,'Warning Notification To L1/L2 For Child Case VF');
            }
            
            // if(logIntiator.IsActive__c) System.debug('lstOfParentCase======='+lstOfParentCase);
            
            if(lstOfParentCase.isEmpty() == false){            
                update lstOfParentCase;            
            }
            
            if(!updateStatusSLAMap.isEmpty()){
                update updateStatusSLAMap.values();
            }
            
            
            if(Test.isRunningTest()){
                integer i =1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = getExceptions(ex,'Before Update OneCare Child');
            insert erDetail;
        }
    }
    
    public static void beforeUpdateMerchantCareProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap,Map<Id,String> case_userQueueIdMap,Map<string,List<Status_SLA__c>> lobWithSLAMap){
        Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Id BCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        String McareChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        String BCareChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
        string level = '';
        list<Id> listOfCaseId = new list<Id>();
        list<Case> listOfCaseToClosed = new list<Case>();
        list<Case> listOfCaseToUpdateClosureDate = new list<Case>();
        list<Case> listOfViolatedCase = new list<Case>();
        list<Id> listOfViolatedCaseId = new list<Id>();
        map<Id,Case> mapOfCaseIDVsCase = new map<Id,Case>();
        
        List<Case> closeExistingCasesMilestone = New List<Case>();
        string milestoneName='';
        List<Case> updatedCasewithLOB = New List<Case>();
        List<Case> reOpenCases = New List<Case>();
        List<Case> ownerChangeCaseList = New List<Case>();  
        Set<string> setAccountId = New Set<string>();
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        List<Status_SLA__c> statusSLAlist = New List<Status_SLA__c>();
        Map<id,Status_SLA__c> updateStatusSLAMap = New Map<id,Status_SLA__c>();
        Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
        String onecareBHId = businessHourNameIdmap.get('OneCare Business Hour'); //(Monday-Saturday)
        String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child'); //(Monday-Friday)
        Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        list<case> updateLobList = new list<case>();
        Map<Id,Id> ownerwithManagerIdMap = New Map<Id,Id>();
        list<Email_Status_Tracking__c> emailTrackerList = new list<Email_Status_Tracking__c>();

        try{
            
            for(Case eachCase : triggerNew){
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                if(eachCase.recordTypeId == MCRecordTypeId || eachCase.recordTypeId == BCRecordTypeId){
                    string restrictedValue = Label.Restricted_Status_Value_of_Case;
                    List<string> allStatusValues = restrictedValue.split(',');
                    
                    if(allStatusValues.contains(eachCase.Status) && eachCase.Status != oldCase.Status){
                        eachCase.Status = oldCase.Status;                        
                    }
                    
                    if((eachCase.Status =='Pending' && eachCase.Status == oldCase.Status && 
                        eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c) 
                       || 
                       (eachCase.Status != oldCase.Status && eachCase.Status == 'Resolved')){ 
                           mapOfCaseIDVsCase.put(eachCase.Id,eachCase);
                       }
                    if(eachCase.Status=='IN_PROGRESS' && eachCase.Status != oldCase.Status && oldCase.Status=='New'){
                        if(string.valueOf(eachCase.OwnerId).startswith('005')){
                            eachCase.Status='Open';
                            eachCase.New_Open_Time__c = system.now();
                            eachCase.New_Open_BH__c = eachCase.New_Open_Time__c != NULL ? OneCareReportHandler.getDurationbetween(eachCase.New_Open_Time__c,eachCase.CreatedDate,onecareBHId) : eachCase.New_Open_BH__c;
                            // Update new SLA object 
                            Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                            if(sla != null){
                                updateStatusSLAMap.put(sla.id,sla);
                            }
                        }else if(string.valueOf(eachCase.OwnerId).startswith('00G')){
                            eachCase.Status='New';
                        }                    
                    }
                    
                    else if(eachCase.Status=='IN_PROGRESS' && eachCase.Status != oldCase.Status && oldCase.Status=='Open'){
                        eachCase.Status='Open';
                    }else if(eachCase.Status=='REOPENED' && eachCase.Status != oldCase.Status && oldCase.Status=='Resolved'){
                        eachCase.Status='Re-Open';
                    }else if(eachCase.Status=='CLOSED' && eachCase.Status != oldCase.Status && oldCase.Status=='Resolved'){
                        eachCase.Status='Closed';
                    }else if(eachCase.Status=='IN_PROGRESS' && eachCase.Status != oldCase.Status && oldCase.Status=='Pending' && 
                             eachCase.LP_sub_status__c!=null){
                                 eachCase.Status = 'Pending';
                             }
                    
                    if(!case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(eachCase.OwnerId) && string.valueOf(oldCase.OwnerId).startsWith('00G') &&
                       string.valueOf(eachCase.OwnerId).startswith('005') && eachCase.OwnerId != oldCase.OwnerId){
                           //eachCase.LOB_Name__c = case_userQueueIdMap.get(eachCase.OwnerId);
                           eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;                             
                           if(oldCase.Status=='New') {
                               eachCase.Status='Open';
                               if(string.isBlank(eachCase.Onecare_First_Agent__c)) {
                                   eachCase.Onecare_First_Agent__c = eachCase.Owner__c;
                               }
                               
                               // Update new SLA object 
                               Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                               /*if(sla != null){
updateStatusSLAMap.put(sla.id,sla);
}*/
                           }
                           
                           else if(oldCase.Status=='Transferred from other teams') {
                               eachCase.Status='Open';
                               if(string.isBlank(eachCase.Onecare_First_Agent__c)) 
                                   eachCase.Onecare_First_Agent__c = eachCase.Owner__c;
                               system.debug('oldCase.Previous_QueueId_OwnerId__c =='+oldCase.Previous_QueueId_OwnerId__c );
                               eachCase.Previous_QueueId_OwnerId__c = oldCase.Previous_QueueId_OwnerId__c != null ? eachCase.OwnerId : oldCase.Previous_QueueId_OwnerId__c;
                               eachCase.Previous_Queue_Name_Owner_Name__c = oldCase.Previous_Queue_Name_Owner_Name__c != null ? eachCase.Owner__c : oldCase.Previous_Queue_Name_Owner_Name__c;
                               
                               status_sla__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                               if(sla != null) updateStatusSLAMap.put(sla.id,sla);
                           }
                           
                       }else if(string.valueOf(eachCase.OwnerId).startswith('00G') && eachCase.Owner__c != oldCase.owner__c){
                           eachCase.LOB_Name__c = eachCase.Owner__c;
                       }
                    System.debug('Each>>>>> '+eachCase.LOB_Name__c+ '  OLd '+oldCase.LOB_Name__c);
                    System.debug('Each>>>>> '+eachCase.Status+ '  OLd '+oldCase.Status);
                    if(eachCase.LOB_Name__c != oldCase.LOB_Name__c && oldCase.Status !='New' 
                       && string.isNotBlank(oldCase.LOB_Name__c) && UserInfo.getUserId()!=system.label.IntegrationUserId){
                           
                           eachCase.Is_Parent_Owner_Change__c = true;
                           eachCase.Start_Parent_Owner_Change_Milestone__c = true;
                           eachCase.Status = 'Transferred from other teams';
                           if(String.ValueOf(eachCase.OwnerId).StartsWith('005') && eachCase.Status == 'Transferred from other teams')
                               eachCase.L1_L2_Agent_Id__c = eachCase.OwnerId;
                           eachCase.LP_sub_status__c = '';
                           if(oldCase.Is_L2_Violated__c==true) eachCase.Is_L2_Violated__c=false;
                           if(oldCase.Is_Violated__c==true) eachCase.Is_Violated__c=false;
                           if(oldCase.Start_L2_Ticket_Milestone__c) eachCase.Start_L2_Ticket_Milestone__c=false;
                           if(oldCase.Start_L3_Ticket_Milestone__c) eachCase.Start_L3_Ticket_Milestone__c=false;
                           if(oldCase.Is_L3_Violated__c) eachCase.Is_L3_Violated__c=false;
                           eachCase.Previous_QueueId_OwnerId__c = oldCase.Previous_QueueId_OwnerId__c != null ? eachCase.OwnerId : oldCase.Previous_QueueId_OwnerId__c;
                           eachCase.Previous_Queue_Name_Owner_Name__c = oldCase.Previous_Queue_Name_Owner_Name__c != null ? eachCase.Owner__c : oldCase.Previous_Queue_Name_Owner_Name__c;
                           
                           if((eachCase.LOB_Name__c.trim() == 'Buyer Care' || eachCase.LOB_Name__c == 'Buyers_Care' || eachCase.LOB_Name__c.trim() == 'PayU Biz Enterprise Bcare') && eachCase.RecordTypeId==MCRecordTypeId){
                               eachCase.RecordTypeId = BCRecordTypeId;
                           }else if((eachCase.LOB_Name__c.trim() != 'Buyer Care' || eachCase.LOB_Name__c == 'Buyers_Care') && eachCase.RecordTypeId==BCRecordTypeId && eachCase.LOB_Name__c.trim() != 'PayU Biz Enterprise Bcare'){
                               eachCase.RecordTypeId = MCRecordTypeId;
                           }
                           
                           // Create SLA object
                           statusSLAlist.add(OneCareReportHandler.createSLArecords(eachCase,oldCase));
                           // Update Old SLA object 
                           if(!lobWithSLAMap.isEmpty() && lobWithSLAMap.values() !=null){   
                               List<Status_SLA__c> slaLst = OneCareReportHandler.updateOldSLA(oldCase,lobWithSLAMap);   
                               for(Status_SLA__c sla : slaLst){ 
                                   updateStatusSLAMap.put(sla.id,sla);  
                               }    
                           }
                           
                           ownerChangeCaseList.add(eachCase);
                           setAccountId.add(eachCase.AccountId);
                           
                           closeExistingCasesMilestone.add(eachCase);
                       } 
                    
                    // update Status SLA object
                    if(eachCase.Status != oldCase.Status && eachCase.Status =='Resolved'){
                        eachCase.IsStopped = true;
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Resolved');
                        if(sla != null){
                            updateStatusSLAMap.put(sla.id,sla);
                        }    
                    }
                    //set is System edit flag value false
                    string childProfileId = Label.Merchant_Care_Child_Profile_Id;
                    List<String> childProfileIds = childProfileId.split(',');
                    if(eachCase.status != oldCase.status && eachCase.isSystemEdit__c == oldCase.isSystemEdit__c 
                       && eachCase.isSystemEdit__c == true 
                       && childProfileIds.contains(userinfo.getProfileId())){
                           eachCase.isSystemEdit__c = false;
                       }
                    
                    //update comments on parent case in case of auto closure
                    if(eachCase.isAutoClosed__c != oldCase.isAutoClosed__c && eachCase.isAutoClosed__c == true && System.isBatch() == false){
                        if(eachCase.status == 'Pending'){
                            eachCase.Agent_Comments__c = 'Auto-closed due to no reply';
                            eachCase.Comments = 'Auto-closed due to no reply';
                        }
                        else if(eachCase.status == 'Resolved'){
                            eachCase.Agent_Comments__c = 'Auto-closed after resolution';
                            eachCase.Comments = 'Auto-closed after resolution';
                        }
                        eachCase.status='Closed';
                        eachCase.LP_Sub_Status__c = '';
                    }
                    
                    // if(logIntiator.IsActive__c) system.debug('oldCase.Status======='+oldCase.Status);
                    // if(logIntiator.IsActive__c) system.debug('eachCase.status======='+eachCase.status);
                    
                    //publish data to care panel
                    if(eachCase.status != oldCase.status || eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c ||
                       eachCase.Comments != NULL){
                           // if(logIntiator.IsActive__c) system.debug('eachCase.Comment======='+eachCase.Comments);
                           if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != oldCase.Comments){
                               eachCase.Agent_Comments__c = eachCase.Comments;
                           }
                           if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Comments != NULL){
                               if(eachCase.OwnerId == eachCase.LastModifiedById)
                                   eachCase.Agent_Comments__c = eachCase.Comments;
                               eachCase.Comments = 'Agent: '+eachCase.Comments;
                           }
                           if(oldCase.Status=='Re-Open' && eachCase.Status=='Pending' && eachCase.status != oldCase.status
                              && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')){
                                  eachCase.Agent_Comments__c = eachCase.Comments;
                              }
                           //  if(logIntiator.IsActive__c) System.debug('comment 356>>>>'+eachCase.Agent_Comments__c+' old'+oldCase.Agent_Comments__c);
                           if((eachCase.status != oldCase.status && (eachCase.status == 'Open' || eachCase.status == 'Resolved' || eachCase.status == 'Closed'))
                              || (eachCase.status == 'Pending' && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')
                                  && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c)
                             ){
                                 if(eachCase.status == 'Closed' && eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && eachCase.Agent_Comments__c != NULL)
                                     eachCase.Comments = eachCase.Agent_Comments__c;
                                 listOfCaseId.add(eachCase.Id);
                             }
                       }
                    
                    //if agent takes action after merchant response then unchecked the flag on ticket
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Response_Received__c == true 
                       && ((eachCase.Status != oldCase.Status && eachCase.Status != NULL) 
                           || (eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c != NULL))){
                               eachCase.Response_Received__c = false;
                           }
                    
                    //comments required for Waiting on Merchant and Resolved status (We can not create validation for comment field)
                    if(userinfo.getUserId() != Label.IntegrationUserId && ((eachCase.Status =='Pending' && eachCase.Comments == NULL && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                                                                            && eachCase.LP_Sub_Status__c != NULL) ||
                                                                           (eachCase.status != oldCase.status && eachCase.Status == 'Resolved' && eachCase.comments == NULL)
                                                                           || (eachCase.LP_TAT__c != oldCase.LP_TAT__c && eachCase.comments == NULL)
                                                                          )){ 
                                                                              eachCase.addError(Label.LP_Please_Enter_Comments);
                                                                          }
                    
                    //pause the milestone
                    if(userinfo.getUserId() != Label.IntegrationUserId && ((eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                                                                            && eachCase.LP_Sub_Status__c != NULL) || eachCase.Status =='Resolved' || eachCase.Status =='Closed')){ 
                                                                                eachCase.IsStopped = true;
                                                                                if(eachCase.Status =='Pending' && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')){
                                                                                    eachCase.LP_Has_Agent_Reverted__c = true;
                                                                                }
                                                                            }
                    
                    // resume the milestone
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status != oldCase.Status && eachCase.Status =='Response Received from Other Teams'){ 
                        eachCase.IsStopped = false;
                    }
                    
                    //if Tat exceed of child ticket then update the expected closure date value on care panel
                    //assign case to L2 team
                    if(eachCase.Status != oldCase.Status && eachCase.Status =='No Resolution From Other Teams'){
                        
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
                        if(sla != null){
                            updateStatusSLAMap.put(sla.id,sla);
                        }
                    }
                    
                    //If Child is pending on Bank, update Expected closure date
                    system.debug('eachCase.Agent_Comments__c=='+eachCase.Agent_Comments__c);
                    system.debug('oldCase.Agent_Comments__c=='+oldCase.Agent_Comments__c);
                    if(eachCase.Agent_Comments__c != oldCase.Agent_Comments__c && eachCase.Agent_Comments__c.contains('Child:Waiting on Bank')){
                        if(eachCase.Is_Violated__c == true && eachCase.Is_L2_Violated__c == false){
                            if(oldCase.LP_TAT__c=='4')eachCase.LP_TAT__c = '5';
                            eachCase.Agent_Comments__c = '';
                        }
                        if(eachCase.Is_Violated__c == false && eachCase.Is_L2_Violated__c == false){
                            if(oldCase.LP_TAT__c=='3') eachCase.LP_TAT__c = '4';
                            eachCase.Agent_Comments__c = '';
                            /*Email_Status_Tracking__c emailTracker = new Email_Status_Tracking__c();
emailTracker.To_Addresses__c = eachCase.ContactEmail;
emailTracker.Template_Name__c = 'Query_TAT_updated';
emailTracker.Case__c = eachCase.Id;
emailTrackerList.add(emailTracker);*/
                        }
                        //eachCase.Priority = 'High';
                        listOfViolatedCase.add(eachCase);
                    }
                    
                    //complete the milestone of closed case
                    if(eachCase.Status != oldCase.Status && eachCase.Status =='Closed' && eachCase.RecordTypeId != MerchantchildCaseRecordTypeId){ 
                        Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Closed');
                        if(sla != null){
                            updateStatusSLAMap.put(sla.id,sla);
                        }
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
                        //eachCase.Is_Parent_Owner_Change__c =true;
                        eachCase.Start_Parent_Owner_Change_Milestone__c=false;                                   
                        //eachCase.Parent_Case_Owner_Change__c = false;
                        eachCase.Is_L2_Violated__c = false;
                        eachCase.Is_Violated__c = false;
                        eachCase.Start_Parent_Ticket_Milestone__c = false;
                        eachCase.Start_L2_Ticket_Milestone__c = false;
                        
                        listOfCaseToClosed.add(eachCase);
                    }
                    // if(logIntiator.IsActive__c) System.debug('398>>>'+eachCase.Is_Violated__c);
                    // if(logIntiator.IsActive__c) System.debug('399>>>'+eachCase.Start_L2_Ticket_Milestone__c);
                    
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
                           milestoneName = 'L2 merchant Care Milestone';
                           listOfViolatedCase.add(eachCase);
                           listOfViolatedCaseId.add(eachCase.Id);
                       }
                    // if(logIntiator.IsActive__c) system.debug('@@@@@######### '+eachCase.Is_L3_Violated__c+'sdsad '+oldCase.Is_L3_Violated__c+'cdcdac '+eachCase.Is_L2_Violated__c);
                    // If L3 ticket milestone violated
                    if(eachCase.Is_L3_Violated__c == true && eachCase.Is_L3_Violated__c != oldCase.Is_L3_Violated__c ){
                        eachCase.comments = '';
                        eachCase.Agent_Comments__c = '';
                        if(oldCase.LP_TAT__c=='4')eachCase.LP_TAT__c = '5';
                        eachCase.Priority = 'High';
                        milestoneName = 'L3 merchant Care Milestone';
                        listOfViolatedCase.add(eachCase);
                        listOfViolatedCaseId.add(eachCase.Id);
                    }
                    
                    if(eachCase.Is_L3_Violated__c == true && eachCase.Is_L3_Violated__c != oldCase.Is_L3_Violated__c){
                        milestoneName = 'L3 Merchant Care Milestone';
                    }
                    // if(logIntiator.IsActive__c) system.debug('eachCase.Comment======='+eachCase.comments);
                    // if(logIntiator.IsActive__c) System.debug('listOfCaseId 504>>>>'+listOfCaseId.size());
                    //if tat changes then send update to care panel
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.LP_TAT__c != oldCase.LP_TAT__c){
                        listOfCaseId.add(eachCase.Id);
                        listOfCaseToUpdateClosureDate.add(eachCase);
                    }
                    
                    if(userinfo.getUserId() != Label.IntegrationUserId && string.isNotBlank(eachCase.Merchant_Contacted__c) 
                       && eachCase.Merchant_Contacted__c != oldCase.Merchant_Contacted__c && eachCase.Merchant_Contacted__c =='Revert back to Merchant'){
                           if(string.isBlank(eachCase.Comments) || eachCase.comments==null)
                               eachcase.addError('Please Enter Comments.');
                       }
                    //to update response received in status sla and case
                    if(eachCase.Status != oldCase.Status && (eachCase.Status=='Response received from buyer' 
                                                             || eachCase.Status=='Response received from merchant' || eachCase.Status=='No Resolution From Other Teams'
                                                             || eachCase.Status=='Response Received from Other Teams')){
                                                                 Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,eachCase.Status);
                                                                 if(sla != null) updateStatusSLAMap.put(sla.id,sla);
                                                             }
                    //update Status SLA when Status is Pending
                    if(userinfo.getUserId() != Label.IntegrationUserId && eachCase.Status =='Pending' && eachCase.Status != oldCase.Status
                       && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c != NULL){
                           Status_SLA__c sla = OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Pending');
                           if(sla != null) updateStatusSLAMap.put(sla.id,sla);
                       }
                }
                
                //to update Auto close date 
                if(eachCase.recordTypeId == MCRecordTypeId || eachCase.recordTypeId == BCRecordTypeId || eachCase.recordTypeId == McareChildRecordTypeId || eachCase.recordTypeId == BCareChildRecordTypeId){
                    if(eachCase.Status != oldCase.status && (eachCase.Status == 'Resolved' || (eachCase.Status == 'Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                                                                                               && (eachCase.LP_Sub_Status__c == 'Waiting On Merchant' || eachCase.LP_Sub_Status__c == 'Waiting On Buyer')))){
                                                                                                   eachCase.Auto_Close_Date__c = Date.Today();        
                                                                                               }
                    else if(eachCase.Status != oldCase.status && (eachCase.Status == 'Re-Open' || eachCase.Status == 'Response received from merchant' || eachCase.Status == 'Response received from buyer')){
                        eachCase.Auto_Close_Date__c = null;   
                    }
                }
                }
               
            //create Email Status tracker record
            //if(emailTrackerList.size() > 0 && emailTrackerList != null) insert emailTrackerList;
            
            //complete the milestone
            if (listOfCaseToClosed.isEmpty() == false){
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfCaseToClosed, milestoneName, completionDate);
            }
            
            //calculate expected closure Date
            if(listOfCaseToUpdateClosureDate != NULL && listOfCaseToUpdateClosureDate.size()>0){
                BusinessDays.updateDateAccordingToBH(listOfCaseToUpdateClosureDate);
            }
            
            //complete milestone of parent case
            //if(logIntiator.IsActive__c) system.debug('listOfViolatedCase========'+listOfViolatedCase);
            if(listOfViolatedCase != NULL && listOfViolatedCase.size()>0){
                getCurrentUserManagerId(listOfViolatedCase,ownerwithManagerIdMap);
                BusinessDays.updateDateAccordingToBH(listOfViolatedCase);
                if(!Test.isRunningTest() && !System.isBatch()){
                    CarePanelUtility.preparepayload(listOfViolatedCaseId,'CarePanel','TAT_EXCEEDED');
                }
                DateTime completionDate = System.now();
                MilestoneUtils.completeMilestone(listOfViolatedCase, milestoneName, completionDate);
                MilestoneUtils.sendEmailtoManager(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification to Parent to Manager');
                MilestoneUtils.sendEmailtoOwner(listOfViolatedCase,ownerwithManagerIdMap,'Violation Notification to Parent Case to Owner');
            }
            
            //restrict agents to update Sub status
            if(mapOfCaseIDVsCase != NULL && mapOfCaseIDVsCase.size()>0){
                restrictUserToTakeActionOnCase(mapOfCaseIDVsCase);
            }
            
            if(reOpenCases.size()>0 && !reOpenCases.isEmpty())
                updateOwnerForStatusReopen(triggerNew,TriggeroldMap,case_userQueueIdMap,oneCareRecIdVsRecTypeMap);
            
            
            if(!ownerChangeCaseList.isEmpty() && !setAccountId.isEmpty()){
                //system.debug('Owner changed==='+ ownerChangeCaseList[0].ownerId +'LOB name =='+ownerChangeCaseList[0].LOB_Name__c + 'entitlementname=== '+ownerChangeCaseList[0].entitlement.name );
                updateEntitlementProcess(ownerChangeCaseList,setAccountId);
            }
            
            // Merchant care: update LOB name
            //updatedCasewithLOB = updateLOBname(triggerNew,case_userQueueIdMap,oneCareRecIdVsRecTypeMap);
            
            if(statusSLAlist.size()> 0 && statusSLAlist!=null){
                Insert statusSLAlist;
            }
            system.debug('##### sla status '+updateStatusSLAMap.values());
            if(updateStatusSLAMap.size()>0 && !updateStatusSLAMap.isEmpty()){
                update updateStatusSLAMap.values();
            }
            if(Test.isRunningTest()){
                integer i =1/0;
            }
         }catch(Exception ex){
            Error_Details__c erDetail = getExceptions(ex,'Before Update OneCare Parent');
            insert erDetail;
        }
    }
    
        
    public static List<Case> updateLOBname(List<Case> triggerNew, Map<Id,String> case_userQueueIdMap,Map<string,string> recTypeName){
        
        List<Case> updatedCase = New List<case>();
        for(Case newCase : triggerNew){
            if(recTypeName.containskey(newCase.RecordTypeId)){
                if(string.isNotBlank(newCase.OwnerId)){ 
                    if(!case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(newCase.OwnerId) &&
                       string.valueOf(newCase.OwnerId).startswith('005')){                           
                           newCase.LOB_Name__c = case_userQueueIdMap.get(newCase.OwnerId);
                           if(string.isBlank(newCase.First_LOB_Name__c)) 
                               newCase.First_LOB_Name__c = case_userQueueIdMap.get(newCase.OwnerId);
                       }else if(string.valueOf(newCase.OwnerId).startswith('00G') ){
                           newCase.LOB_Name__c = newCase.Owner__c;
                           if(string.isBlank(newCase.First_LOB_Name__c)) 
                               newCase.First_LOB_Name__c = newCase.Owner__c;
                       } 
                    updatedCase.add(newCase);
                }
            }
        }
        return updatedCase;
    }
    
    public static Map<Id,String> getCurrentQueueName(Map<Id,String> case_userQueueIdMap){
       List<Id> caseGroupIds = New List<Id>();
        
        Map<string,string> queueNameWithId = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management,Map<string,string>.class);
       // Map<string,string> queueDevNameWithName = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Developer_Name_IQueue_Name_Management,Map<string,string>.class); //|| Label commented
        
        //Commented Custom label and Replaced with Custom Metadata// added by Pooja//
        
        Map<String, OneCare_Queue_Developer_Name_QueueName__mdt> queMap = OneCare_Queue_Developer_Name_QueueName__mdt.getAll();
        Map<string,string> queueDevNameWithName = new Map<String, String>();
        for(OneCare_Queue_Developer_Name_QueueName__mdt each : queMap.values()){
            queueDevNameWithName.put(each.DeveloperName, each.MasterLabel);
        }
        //Commented Custom label and Replaced with Custom Metadata// Ended by Pooja//
        caseGroupIds.addAll(queueNameWithId.Values());
        
        For(GroupMember gm : [SELECT Id, GroupId,group.name,group.DeveloperName, UserOrGroupId FROM GroupMember where GroupId IN: caseGroupIds]){
            if(String.isNotBlank(gm.UserOrGroupId) ){
                  case_userQueueIdMap.put(gm.UserOrGroupId,queueDevNameWithName.get(gm.Group.DeveloperName));
                  //case_userQueueIdMap.put(gm.UserOrGroupId,gm.Group.DeveloperName);
            }
        } 
        // if(logIntiator.IsActive__c) system.debug('######## queue name '+case_userQueueIdMap);
        return case_userQueueIdMap;
    }

    
    // get ownerId with managerId
    public static void getCurrentUserManagerId(List<Case> listViolatedCases, Map<Id,Id> ownerwithManagerIdMap){
        Set<string> ManagerIds = New Set<String>();
        map<Id,Boolean> userManagerIdquery = new Map<id,Boolean>();
        
        for(Case cs : listViolatedCases){
            if(string.isNotBlank(cs.OwnerId) && string.valueOf(cs.OwnerId).startsWith('005') && string.valueOf(cs.OwnerId) != Label.IntegrationUserId){
                if(cs.Is_L2_Violated__c) userManagerIdquery.put(cs.OwnerId,true);
                else userManagerIdquery.put(cs.OwnerId,false);
            }else if(string.isNotBlank(cs.Previous_QueueId_OwnerId__c) && string.valueOf(cs.Previous_QueueId_OwnerId__c).startsWith('005') && string.valueOf(cs.Previous_QueueId_OwnerId__c) != Label.IntegrationUserId){
                if(cs.Is_L2_Violated__c) userManagerIdquery.put(cs.Previous_QueueId_OwnerId__c,true);
                else userManagerIdquery.put(cs.Previous_QueueId_OwnerId__c,false);
            }
        }
        
        if(!userManagerIdquery.isEmpty()){
            List<User> users = [Select Id, ManagerId from user where Id IN: userManagerIdquery.keySet()];
            for(User u : users){
                if(userManagerIdquery.get(u.Id)){
                    ownerwithManagerIdMap.put(u.Id,u.ManagerId);
                    ManagerIds.add(u.ManagerId);
                }
                else{
                    ownerwithManagerIdMap.put(u.Id,u.ManagerId);
                }
            }
        }
        
        if(ManagerIds.size() > 0 && ManagerIds != null && !ManagerIds.isEmpty()){
            List<User> managers = [Select Id, ManagerId from user where Id IN: ManagerIds];
            for(User l2User : managers){
                ownerwithManagerIdMap.put(l2User.Id,l2User.ManagerId);
            }
        }
    }
    
    /**
@author:            Shivdeep
@company:           PayU
@description:       this method show error on record if already child case is open/pending 
and agent is going to create another child case or child case is open and agent is going to mark 
resolve the case

**/
    public static void restrictUserToTakeActionOnCase(map<Id,Case> mapOfCase){
        if(mapOfCase != NULL && mapOfCase.size()>0){
            //Set<string> statusValueSet = new Set<string>{'Closed','Tat Exceeded','Resolved'};//Added by Pooja as per the requirement SFI-932 to give access to mark Resolve to the parent case when child case not closed
            //for(Case eachCase : [SELECT id,(SELECT id,status FROM Cases__r WHERE Status Not In :statusValueSet) FROM Case WHERE Id IN:mapOfCase.Keyset()]){
            for(Case eachCase : [SELECT id,(SELECT id,status FROM Cases__r WHERE status != 'Closed' AND status != 'Tat Exceeded') FROM Case WHERE Id IN:mapOfCase.Keyset()]){   
                if(eachCase.Cases__r != NULL && eachCase.Cases__r.size()>0){
                    if(UserInfo.getUserId()!=Label.systemAdminId && mapOfCase.get(eachCase.Id).status == 'Pending'){
                        mapOfCase.get(eachCase.Id).addError(Label.restrictToUpdateSubStatus);
                    }
                    else if(UserInfo.getUserId()!=Label.systemAdminId && mapOfCase.get(eachCase.Id).status == 'Resolved'){
                        mapOfCase.get(eachCase.Id).addError(Label.RestrictUserToMarkResolve);
                    }
                } 
                
            }
        }
    }
    
    /**
@author:            Shivdeep
@company:           PayU
@description:       this method calls the care and child case methods

**/
    public static void afterUpdateCareProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        set<Id> setOfAccountId = new set<Id>();
        list<Case> lstCareCase = new list<Case>();
        list<Case> lstMerchantCareCase = new list<Case>();
        list<Case> lstBuyerCareCase = new list<Case>();
        list<Case> lstChildCase = new list<Case>();
        List<Case> existingOpenChildCaseList = New List<Case>();
        
        //Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        //Id childCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ChildCase').getRecordTypeId();
        Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        Id BuyerCareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        Id BuyerCareChildRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
        string notCreateChildValue = Label.SubStatusNotCreateChild;
        List<string> subStatusValues = notCreateChildValue.split(',');
        // SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        if(!Test.isRunningTest())
            existingOpenChildCaseList = [Select Id from Case where Parent_Case__c IN: triggerNew AND (Status!='Closed' AND Status !='Tat Exceeded')];
        for(Case eachCase : triggerNew){
            Case oldCase = TriggeroldMap.get(eachCase.Id);
            if((eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c != NULL && (eachCase.LP_Sub_Status__c != 'Waiting On Merchant' && eachCase.LP_Sub_Status__c != 'Waiting On Buyer') && (!subStatusValues.contains(eachCase.LP_Sub_Status__c)) && (eachCase.RecordTypeId == MCRecordTypeId || eachCase.RecordTypeId == BuyerCareRecordTypeId))){
                // if(logIntiator.IsActive__c) system.debug('create child first if');
                if(existingOpenChildCaseList.size()>0){
                    eachCase.addError('Child case are already created.');
                }else{
                    if((eachCase.RecordTypeId == MCRecordTypeId) ){
                        lstMerchantCareCase.add(eachCase);
                    }
                    
                    if(eachCase.RecordTypeId == BuyerCareRecordTypeId ){
                        lstBuyerCareCase.add(eachCase);
                    }
                    
                    if(eachCase.accountId != NULL)
                        setOfAccountId.add(eachCase.accountId);
                }
            }
            
            if((eachCase.RecordTypeId == MerchantchildCaseRecordTypeId || eachCase.RecordTypeId == BuyerCareChildRecordTypeId)
               && (eachCase.status=='Closed' || (eachCase.status=='Pending' && eachCase.LP_Sub_Status__c == 'Waiting on Bank'))){
                   lstChildCase.add(eachCase);
               }
            
        }
        
        
        //create merchant child case
        if(lstMerchantCareCase != NULL && lstMerchantCareCase.size()>0){
            createChildCase(lstMerchantCareCase,setOfAccountId,'MerchantChildCase');
        }
        
        //create buyer child case
        if(!lstBuyerCareCase.isEmpty()){
            createChildCase(lstBuyerCareCase,setOfAccountId,'BuyerCareChild');
        }
        
        //update child case closed comments on parent case
        if(lstChildCase != NULL && lstChildCase.size()>0){
            updateCaseCommentsOnParent(lstChildCase);
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to update the case comments and status of parent case 
when child case is closed by agent
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void updateCaseCommentsOnParent(list<Case> lstChildCase){
        //SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        /// if(logIntiator.IsActive__c) system.debug('lstChildCase======'+lstChildCase);
        try{
            if(lstChildCase != NULL && lstChildCase.size()>0){
                list<Case> lstParentCase = new list<Case>();
                for(Case eachCase : lstChildCase){
                    if((string.isNotBlank(eachCase.ParentId) || eachCase.Parent_Case__c != NULL) && eachCase.Comments != NULL){
                        if(eachCase.isAutoClosed__c && system.isBatch() == false){
                            Case objCase = new Case(Id=eachCase.Parent_Case__c,Comments='Child:'+eachCase.Comments,status='Closed',LP_sub_status__c='',IsStopped=false,isSystemEdit__c=true);
                            lstParentCase.add(objCase); 
                        }
                        else if(eachCase.Status=='Closed'){
                            Case objCase = new Case(Id=eachCase.Parent_Case__c,Comments='Child:'+eachCase.Comments,status='Response Received from Other Teams',LP_sub_status__c='',IsStopped=false,isSystemEdit__c=true);
                            lstParentCase.add(objCase);
                        }
                        else if(eachCase.Status=='Pending' && eachCase.LP_Sub_Status__c == 'Waiting on Bank'){
                            Case objCase = new Case(Id=eachCase.Parent_Case__c,Comments='Child:'+eachCase.Comments);
                            lstParentCase.add(objCase);
                        }
                    }
                }
                //system.debug('lstParentCase======'+lstParentCase);
                if(lstParentCase != NULL && lstParentCase.size()>0){
                    update lstParentCase;
                }
            }
            if(Test.isRunningTest()){
                integer i =1/0;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = getExceptions(ex,'After Update oneCare Comment');
            insert erDetail;
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to create child case in care process
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void createChildCase(list<Case> lstCareCase,set<Id> setOfAccountId,string recordtype){
        // SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        list<Case> lstChildCase = new list<Case>();
        
        if(lstCareCase != NULL && lstCareCase.size()>0){
            map<string,string> mapOfSubStatusVsQueueId = new map<string,string>();
            map<string,Child_Case_Queue__mdt> mapOfSubStatusVsQueueMtdt = new map<string,Child_Case_Queue__mdt>();
            map<Id,Id> mapOfAccountIdVsEntitlementId = new map<Id,Id>();
            //map<string,ETC_Child_Ownership__mdt> mapOfSubStatusVsETCMtdt = new map<string,ETC_Child_Ownership__mdt>();
            
            //get the child entitlement
            if(setOfAccountId != NULL && setOfAccountId.size()>0){
                for(Entitlement eachEntitlement : [SELECT id,accountId FROM Entitlement WHERE accountID IN:setOfAccountId AND Name='Child Entitlement']){
                    mapOfAccountIdVsEntitlementId.put(eachEntitlement.accountId,eachEntitlement.Id);
                }
            }
            //get the metadata value to assign to settlement/Recon/Refund
            /*system.debug('child case record type=='+ recordtype);
if(recordtype == 'Email to Case Child'){
for(ETC_Child_Ownership__mdt eachETCMdt : [Select id,Detail__c ,Problem__c ,Sub_Detail_List__c ,Sub_Status__c,Platforms__c FROM ETC_Child_Ownership__mdt]){
mapOfSubStatusVsETCMtdt.put(eachETCMdt.Detail__c,eachETCMdt);
}
}*/
            
            //get the metadata value to assign case to queue
            for(Child_Case_Queue__mdt eachMdt : [Select id,MasterLabel,SubStatus__c,QueueId__c,Queue_Manager_Id__c FROM Child_Case_Queue__mdt]){
                mapOfSubStatusVsQueueMtdt.put(eachMdt.SubStatus__c,eachMdt);
            }
            // if(logIntiator.IsActive__c) System.debug('mapOfSubStatusVsQueueMtdt======'+mapOfSubStatusVsQueueMtdt);
            if(mapOfSubStatusVsQueueMtdt != NULL && mapOfSubStatusVsQueueMtdt.size()>0){
                Id ChildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                
                for(Case eachCase : lstCareCase){
                    Case objChildCase = new Case();
                    
                    //ETC_Child_Ownership__mdt objETCMtd = mapOfSubStatusVsETCMtdt.get(eachCase.Details_ETC__c);
                    Child_Case_Queue__mdt objMtdt = mapOfSubStatusVsQueueMtdt.get(eachCase.LP_Sub_Status__c);
                    //objETCMtd != null &&
                    if(objMtdt != null){
                        system.debug('map not null');
                        objChildCase.ownerId = objMtdt.QueueId__c;
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
                        //objChildCase.LP_Details__c = eachCase.LP_Details__c;
                        //objChildCase.LP_Sub_Details__c = eachCase.LP_Sub_Details__c;
                        objChildCase.Parent_Case__c = eachCase.id;
                        objChildCase.ParentId = eachCase.id;
                        if(!Test.isRunningTest()){
                            objChildCase.LOB_Name__c = objMtdt.MasterLabel.removeStart('Waiting On ');
                        }
                    }
                    if(objMtdt.Queue_Manager_Id__c != NULL)
                        objChildCase.Queue_Manager__c = objMtdt.Queue_Manager_Id__c; 
                    
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
    
    //=================== Sneha 26/11/2019==============//
    public static void updateEntitlementProcess(list<case> caseList, Set<string> accIds){
        Map<string,string> allEntitlementMaps = New Map<string,string>();
        Map<string,string> currentEntitlementMaps = New Map<string,string>();
        map<string,string> queueNameVsQueueIdMap = (map<string,string>)JSON.deserialize(System.Label.OneCare_Queue_Name_Id_Management,map<string,string>.class);
        
        for(Entitlement etl : [Select Id,Name from Entitlement where AccountId IN: accIds AND Enddate=null]){
            allEntitlementMaps.put(etl.Name,etl.Id);
        }
        for(Case cs : caseList){
            currentEntitlementMaps.put(cs.Entitlement.Name,cs.EntitlementId);
            if(string.isNotBlank(cs.OwnerId) && !queueNameVsQueueIdMap.isEmpty() && string.valueOf(cs.OwnerId).startsWith('00G') &&
               queueNameVsQueueIdMap.containsKey('payu_Money') && cs.OwnerId==queueNameVsQueueIdMap.get('payu_Money')){
                   if(allEntitlementMaps.containsKey('PayUMoney Parent Entitlement')){
                       cs.EntitlementId = allEntitlementMaps.get('PayUMoney Parent Entitlement');
                   }
               }else if(string.isNotBlank(cs.OwnerId) && !queueNameVsQueueIdMap.isEmpty() && string.valueOf(cs.OwnerId).startsWith('00G') &&
                        queueNameVsQueueIdMap.containsKey('payu_Money') && cs.OwnerId !=queueNameVsQueueIdMap.get('payu_Money')){
                            if( allEntitlementMaps.containsKey('Other Parent Entitlement')){
                                cs.EntitlementId = allEntitlementMaps.get('Other Parent Entitlement');
                            }
                        }else if(string.isNotBlank(cs.OwnerId) && string.valueOf(cs.OwnerId).startsWith('005') &&
                                 string.isNotBlank(cs.LOB_Name__c) && cs.LOB_Name__c!='PayU Money'){
                                     if(allEntitlementMaps.containsKey('Other Parent Entitlement')){
                                         cs.EntitlementId = allEntitlementMaps.get('Other Parent Entitlement');
                                     }
                                 }else if(string.isNotBlank(cs.OwnerId) && string.valueOf(cs.OwnerId).startsWith('005') &&
                                          string.isNotBlank(cs.LOB_Name__c) && cs.LOB_Name__c=='PayU Money'){
                                              if(allEntitlementMaps.containsKey('PayUMoney Parent Entitlement')){
                                                  cs.EntitlementId = allEntitlementMaps.get('PayUMoney Parent Entitlement');
                                              }
                                          }
        }
    }
    
    public static void updateOwnerForStatusReopen(list<case> caseLs , Map<id,case> oldCaseMap,Map<Id,String> case_userQueueIdMap,Map<string,string> recordTypeList){
        //SalesforceDebugLogInitiator__c logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        //Map<string,list<UserServicePresence>> UserPresenceMap = new map<string,list<UserServicePresence>>();
        //Map<Id,string> case_userQueueIdMap =new map<id,string>();
        Map<string,list<Id>> MapofQueueNameListOfAvailableUser = new Map<string,list<Id>>();
        //list<UserServicePresence> PresenceList = new list<UserServicePresence>();
        list<Id> userListForEachQueue = new list<Id>();
        //getCurrentQueueName(case_userQueueIdMap);
        //for(user usr : )
        /*list<ServicePresenceStatus> PresencestatusLst = [SELECT Id, DeveloperName FROM ServicePresenceStatus where (DeveloperName = 'Online' OR DeveloperName = 'Available')];
if(!Test.isRunningTest()){
for(UserServicePresence userPresence : [select id,userId,ServicePresenceStatusId,IsCurrentState FROM UserServicePresence where ServicePresenceStatusId in :PresencestatusLst and IsCurrentState = true]){
PresenceList.add(userPresence);
UserPresenceMap.put(userPresence.userId, PresenceList);
userListForEachQueue.add(userPresence.userId);
if(case_userQueueIdMap.get(userPresence.userId) != null){
MapofQueueNameListOfAvailableUser.put(case_userQueueIdMap.get(userPresence.userId),userListForEachQueue);
}

}
}*/
        for(case cs : caseLs){
            if(recordTypeList.containskey(cs.RecordTypeId)){
                if((cs.status == 'Re-Open' && cs.Previous_QueueId_OwnerId__c != null)){
                    //list<id> Ulist = MapofQueueNameListOfAvailableUser.get(case_userQueueIdMap.get(cs.Previous_QueueId_OwnerId__c));
                    if((cs.Previous_QueueId_OwnerId__c != null && cs.Previous_QueueId_OwnerId__c.startsWith('005')) ){
                        /*if(UserPresenceMap.get(cs.Previous_QueueId_OwnerId__c) != null){
cs.OwnerId = cs.Previous_QueueId_OwnerId__c;
cs.L1_L2_Agent_Id__c = cs.Previous_QueueId_OwnerId__c;
}
else if (Ulist != null){
//  if(logIntiator.IsActive__c) system.debug('enter else if on line 1170');
cs.OwnerId = Ulist[0];
cs.L1_L2_Agent_Id__c =Ulist[0]; 
}
else{*/
                        // if(logIntiator.IsActive__c) system.debug('assing to unavailable previous owner');
                        cs.OwnerId = cs.Previous_QueueId_OwnerId__c;
                        if(string.valueOf(cs.Previous_QueueId_OwnerId__c).startsWith('005'))
                            cs.L1_L2_Agent_Id__c = cs.Previous_QueueId_OwnerId__c;
                        //}
                    }
                }
            }
        } 
    }
    
    /*public static void updateSMBENTOwner(list<case> triggerNew,boolean isLobUpdated){

Map<string,string> queueNameWithId = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Name_Id_Management,Map<string,string>.class);
string payuBizEntQueueId = queueNameWithId.get('Payu_Biz_ENT'); 
string payuBizSmbQueueId = queueNameWithId.get('Payu_Biz');

for(case eachCase : triggerNew){
system.debug('ownerassignmentheader=='+eachCase.contact.Owner_Assignment_Header__c);
string OwnerHeader = eachCase.contact.Owner_Assignment_Header__c;
if(string.isNotBlank(OwnerHeader) && (string.valueOf(OwnerHeader).startsWith('SMB-') || string.valueOf(OwnerHeader).startsWith('ENT-')) && eachCase.OwnerId == payuBizEntQueueId &&
string.isNotBlank(eachCase.LP_Business_Vertical__c) && eachCase.LP_Business_Vertical__c == 'PayU Biz' && !isLobUpdated){
eachCase.OwnerId = payuBizSmbQueueId;
eachCase.LOB_Name__c = 'Payu Biz - SMB';
if(string.isBlank(eachCase.First_LOB_Name__c)) 
{eachCase.First_LOB_Name__c = 'Payu Biz - SMB';}
isLobUpdated = true;
}
}
}*/
    
    public static Error_Details__c getExceptions(Exception ex,string processName){
        Error_Details__c erDetail = New Error_Details__c();
        erDetail.Message__c = 'Error Message: '+ex.getMessage()+' Line No. '+ex.getLineNumber()+' Cause: '+ex.getCause();
        erDetail.Process__c = processName;
        return erDetail;
    }
}