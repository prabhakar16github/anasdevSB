public class MCareDashboardCaseTriggerHandler {
    
    /** Added for round robin assignment */
    public static Map<Integer,Id> assignmentMap = getAssignmentMap(); 
    
    /** Need to re-arrange the Mcare_Case_assignment_Index__c on user in case of any user deactivation & user addition.  */
    public static Map<Integer,Id> getAssignmentMap() {
        Map<Integer,Id> assignmentMap = new Map<Integer,Id>();
        for(User usr : [SELECT Id,Name,Mcare_Case_assignment_Index__c FROM User 
                        WHERE Mcare_Case_assignment_Index__c != NULL 
                        AND isActive = true]){
            assignmentMap.put(Integer.valueOf(usr.Mcare_Case_assignment_Index__c),usr.Id);
        }   
        return assignmentMap;
    }
    /** END **/
    
    public static Boolean stopRecurrsion = false;
    public static void beforeInsertHandler(List<MCare_Dashboard_Case__c> triggerNew){
        Set<String> merchantIdSet = New Set<String>();
        Map<String,MCare_Dashboard_Case__c> mCareVsMerchantIdMap = New Map<String,MCare_Dashboard_Case__c>();
        List<Integer> prodMerchantIds = New List<Integer>();
        Map<Integer, Opportunity> opportunityMIDMap = New Map<Integer, Opportunity>();
        Set<String> midVsProdNameSet = New Set<String>();
        Map<String,Contact> accountIdVsContactMap = New Map<String,Contact>();
        Boolean startSafeLogic = true;
        
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('MCare_Dashboard_Case__c');
        
        /** Added for round robin assignment */
        /** Using Lookup__c object for round robin because of object limit exceed in PROD. */
        Integer roundRobinCount;
        List<Lookup__c> roundRobinList = [SELECT Id,Start_Index__c, Max_Index__c 
                                          FROM Lookup__c 
                                          WHERE Lookup_Type__c = 'Round Robin' 
                                          AND Lookup_Code__c = 'MCare_Dashboard_Case__c'
                                          AND Active__c = true
                                          ORDER BY CreatedDate DESC
                                          LIMIT 1 ];
        if(!roundRobinList.isEmpty()){
            roundRobinCount = Integer.valueOf(roundRobinList[0].Start_Index__c);
        }
         
        /** END */
        
        for(MCare_Dashboard_Case__c mCareObj : triggerNew){
            /** Added for round robin assignment */
            /** Need to re-arrange the Mcare_Case_assignment_Index__c on user in case of any user deactivation & user addition.  */
            if(!roundRobinList.isEmpty() && roundRobinCount != NULL) {
                mCareObj.OwnerId = assignmentMap.get(roundRobinCount);
                if(roundRobinCount == roundRobinList[0].Max_Index__c){
                    roundRobinCount = 1;
                }else {
                    roundRobinCount++;
                }
            }
            /** END */
            
            SystemUtility.getIdentifierUUID(mCareObj, 'Identifier__c', enableUUIDObj);
            if(String.isNotBlank(mCareObj.Merchant_Id__c)){
                merchantIdSet.add(mCareObj.Merchant_Id__c);
                prodMerchantIds.add(Integer.valueOf(mCareObj.Merchant_Id__c));
                if(String.isNotBlank(mCareObj.Product_Name__c)) midVsProdNameSet.add(mCareObj.Product_Name__c+'##'+mCareObj.Merchant_Id__c);
                
            }
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c == 'Risk Hold') mCareObj.Risk_Hold_Date_Time__c  = System.now();
            if(String.isNotBlank(mCareObj.Approval_Status__c)) mCareObj.Approval_Status_Date__c = Date.today();
        }
        
        /** Added for round robin assignment */
        if(!roundRobinList.isEmpty()){
            roundRobinList[0].Start_Index__c = roundRobinCount;
            update roundRobinList;
        }
        
        /** END */
        
        if(!prodMerchantIds.isEmpty()) getOpportunityList(prodMerchantIds, midVsProdNameSet, opportunityMIDMap, accountIdVsContactMap);
        
        if(!opportunityMIDMap.isEmpty()){
            for(MCare_Dashboard_Case__c mCareObj : triggerNew){
                if(String.isNotBlank(mCareObj.Merchant_Id__c)){
                    if(opportunityMIDMap.containsKey(Integer.valueOf(mCareObj.Merchant_Id__c))){
                        mCareObj.Opportunity__c = opportunityMIDMap.get(Integer.valueOf(mCareObj.Merchant_Id__c)).Id;
                        /** Added for Mcare Enhancement - SFI-1064 */
                        if(opportunityMIDMap.get(Integer.valueOf(mCareObj.Merchant_Id__c)).Whitelisting_Status__c == 'Permanent Whitelisted'){
                            mCareObj.Status__c = 'Recommend Whitelist';
                        }
                        /** */
                    }   
                }
            }
        }
        
        if(!merchantIdSet.isEmpty()) getExistingMCareData(merchantIdSet, '', mCareVsMerchantIdMap, null);
        
        if(!mCareVsMerchantIdMap.isEmpty()){
            for(MCare_Dashboard_Case__c mCareObj : triggerNew){
                if(mCareVsMerchantIdMap.containsKey(mCareObj.Merchant_Id__c)){
                    MCare_Dashboard_Case__c existingMCareObj = mCareVsMerchantIdMap.get(mCareObj.Merchant_Id__c);
                    if(String.isNotBlank(existingMCareObj.Approval_Status__c) && existingMCareObj.Approval_Status__c == 'Approved' && String.isNotBlank(existingMCareObj.Status__c) && existingMCareObj.Status__c == 'Recommend Whitelist'){
                        if(String.isNotBlank(existingMCareObj.No_of_Days_to_Whitelist__c) && existingMCareObj.Approval_Status_Date__c != null){
                            Integer daysDiff = Date.today().daysBetween(existingMCareObj.Approval_Status_Date__c);
                            if(daysDiff <= Integer.valueOf(existingMCareObj.No_of_Days_to_Whitelist__c)){
                                mCareObj.Is_Recommend_Whitelist_Auto_Approved__c = True;
                                mCareObj.Status__c = 'Recommend Whitelist';
                                startSafeLogic = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public static void beforeUpdateHandler(List<MCare_Dashboard_Case__c> triggerNew, Map<Id, MCare_Dashboard_Case__c> triggerOldMap){
        List<Integer> prodMerchantIds = New List<Integer>();
        Map<Integer, Opportunity> opportunityMIDMap = New Map<Integer, Opportunity>();
        Set<String> midVsProdNameSet = New Set<String>();
        Map<String,Contact> accountIdVsContactMap = New Map<String,Contact>();
        
        //SFI-674 | Changes in Mcare Dashboard case assignment depending upon Alert Reason Added By Pooja//
        
        Map<String, List<GroupMember>> queueToMembersMap = New Map<String, List<GroupMember>>();
        List<String> alertList = Label.Mcare_case_assignment_AlertReason.split(',');
        
        for(Group thisQueue : [SELECT Id, Name, DeveloperName, (SELECT Id, UserORGroupId FROM GroupMembers) FROM GROUP WHERE DeveloperName IN('Mcare_PO_Alert_Reason','MCare_PO_Risk_Team') AND Type =: 'Queue']){
            queueToMembersMap.put(thisQueue.DeveloperName, thisQueue.GroupMembers);
        }
        //SFI-674 | End //
        
        for(MCare_Dashboard_Case__c mCareObj : triggerNew){
            MCare_Dashboard_Case__c oldMCareObj = triggerOldMap.get(mCareObj.Id);
            if(String.isNotBlank(mCareObj.Approval_Status__c) && mCareObj.Approval_Status__c != oldMCareObj.Approval_Status__c)
                mCareObj.Approval_Status_Date__c = Date.today();
            
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Mark as Safe')
                mCareObj.Safe_Mark_Date__c = Date.today();
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Risk Hold')
                mCareObj.Risk_Hold_Date_Time__c  = System.now();
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Released')
                mCareObj.Released_Date_Time__c = System.now();
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Terminate')
                mCareObj.Terminated_Date_Time__c = System.now();
            if(String.isNotBlank(mCareObj.Status__c) && mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Suspend')
                mCareObj.Suspended_Date_Time__c = System.now();
            
            if(String.isNotBlank(mCareObj.Merchant_Id__c) && String.isNotBlank(mCareObj.Product_Name__c)){
                if(mCareObj.Merchant_Id__c != oldMCareObj.Merchant_Id__c || mCareObj.Product_Name__c != oldMCareObj.Product_Name__c){
                    prodMerchantIds.add(Integer.valueOf(mCareObj.Merchant_Id__c));
                    if(String.isNotBlank(mCareObj.Product_Name__c)) midVsProdNameSet.add(mCareObj.Product_Name__c+'##'+mCareObj.Merchant_Id__c);
                }  
            }
            
            if(mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Recommend Whitelist'){
                submitApprovalProcess(mCareObj);
            }
            
            if(mCareObj.Status__c != oldMCareObj.Status__c && mCareObj.Status__c == 'Released'){
                submitApprovalProcess(mCareObj);
            }
            
            //SFI-674 | Changes in Mcare Dashboard case assignment depending upon Alert Reason Added By Pooja//
            
            if(mCareObj.alert_Reason__c != oldMCareObj.Alert_Reason__c) {
                if(alertList.contains(mCareObj.Alert_Reason__c)){
                    Integer userIndex = Integer.valueof(Math.random() * (queueToMembersMap.get('Mcare_PO_Alert_Reason').size() - 1));
                    //mCareObj.OwnerId = queueToMembersMap.get('Mcare_PO_Alert_Reason').get(userIndex).UserORGroupId;
                } else{
                    Integer userIndex = Integer.valueof(Math.random() * (queueToMembersMap.get('MCare_PO_Risk_Team').size() - 1));
                    //mCareObj.OwnerId = queueToMembersMap.get('MCare_PO_Risk_Team').get(userIndex).UserORGroupId;
                }               
                
            }
            //SFI-674 | End //
        }
        
        if(!prodMerchantIds.isEmpty()) getOpportunityList(prodMerchantIds, midVsProdNameSet, opportunityMIDMap, accountIdVsContactMap);
        
        if(!opportunityMIDMap.isEmpty()){
            for(MCare_Dashboard_Case__c mCareObj : triggerNew){
                if(String.isNotBlank(mCareObj.Merchant_Id__c)){
                    if(opportunityMIDMap.containsKey(Integer.valueOf(mCareObj.Merchant_Id__c))){
                        mCareObj.Opportunity__c = opportunityMIDMap.get(Integer.valueOf(mCareObj.Merchant_Id__c)).Id;
                        /** Added for Mcare Enhancement - SFI-1064 */
                        if(opportunityMIDMap.get(Integer.valueOf(mCareObj.Merchant_Id__c)).Whitelisting_Status__c == 'Permanent Whitelisted'){
                            mCareObj.Status__c = 'Recommend Whitelist';
                        }
                        /** */
                    }   
                }
            }
        }
    }
    
    public static void afterInsertHandler(List<MCare_Dashboard_Case__c> triggerNew){
        Set<Id> mCareCaseIds = New Set<Id>();
        List<MCare_Dashboard_Case__c> mCareDashboardList = New List<MCare_Dashboard_Case__c>();
        List<Case> caseList = New List<Case>();
        List<Integer> prodMerchantIds = New List<Integer>();
        Set<String> midVsProdNameSet = New Set<String>();
        Map<Integer,Opportunity> opportunityMIDMap = New Map<Integer, Opportunity>();
        Map<String,Contact> accountIdVsContactMap = New Map<String,Contact>();
        Map<String,Case> ticketIdVsCaseMap = New Map<String,Case>();
        List<MCare_Dashboard_Case__c> mCareDashboardUpdateList = New List<MCare_Dashboard_Case__c>();
        List<Group> lstGroup = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: 'MCare_PO_Risk_Team' AND Type =: 'Queue' LIMIT 1];
        Map<Id,MCare_Dashboard_Case__c> mCareDashboardOwnerMap = New Map<Id,MCare_Dashboard_Case__c>();
        Set<String> merchantIdSet = New Set<String>();
        Map<String,List<MCare_Dashboard_Case__c>> mCareListVsMerchantIdMap = New Map<String,List<MCare_Dashboard_Case__c>>();
        
        //SFI-674 | Changes in Mcare Dashboard case assignment depending upon Alert Reason Added By Pooja//
        Map<String, List<GroupMember>> queueToMembersMap = new Map<String, List<GroupMember>>();
        List<String> alertList = Label.Mcare_case_assignment_AlertReason.split(',');
        
        for(Group thisQueue : [SELECT Id, Name, DeveloperName, (SELECT Id, UserORGroupId FROM GroupMembers) FROM GROUP WHERE DeveloperName IN('Mcare_PO_Alert_Reason','MCare_PO_Risk_Team') AND Type =: 'Queue']){
            queueToMembersMap.put(thisQueue.DeveloperName, thisQueue.GroupMembers);
        }
        //SFI-674 |End //
        
        /** Added to remove the test alerts comming from DS. */
        Set<Id> recordIdsToDelete = new Set<Id>();
        for(MCare_Dashboard_Case__c dashboardObj : triggerNew){
            /** Added to remove the test alerts comming from DS. */
            if(String.isNotBlank(dashboardObj.Name__c) && dashboardObj.Name__c.equalsIgnoreCase('Test') && dashboardObj.Name__c != 'DS Alert'){
                recordIdsToDelete.add(dashboardObj.Id);
                continue;
            }
            /** END */
            if(String.isNotBlank(dashboardObj.Merchant_Id__c)){
                merchantIdSet.add(dashboardObj.Merchant_Id__c);
            }
            if(String.isNotBlank(dashboardObj.Status__c) && dashboardObj.Status__c == 'Risk Hold'){
                mCareCaseIds.add(dashboardObj.Id);
                mCareDashboardList.add(dashboardObj);
                if(String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    prodMerchantIds.add(Integer.valueOf(dashboardObj.Merchant_Id__c));
                if(String.isNotBlank(dashboardObj.Product_Name__c) && String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    midVsProdNameSet.add(dashboardObj.Product_Name__c+'##'+dashboardObj.Merchant_Id__c);
            }
        }
        
        /** Added to remove the test alerts comming from DS. */
        if(!recordIdsToDelete.isEmpty()){
            delete [SELECT Id FROM MCare_Dashboard_Case__c WHERE Id IN :recordIdsToDelete];
        }/** END */
        
        if(!merchantIdSet.isEmpty()) getExistingMCareData(merchantIdSet, 'DateFilter', null, mCareListVsMerchantIdMap);
        
        
        /*for(MCare_Dashboard_Case__c dashboardObj : triggerNew){
            
            MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c(Id = dashboardObj.Id);
            
            //SFI-674 | Line 214 added to assign users in before insert
            if(!alertList.contains(dashboardObj.alert_Reason__c)){
                if(lstGroup != null && lstGroup.size() > 0){
                    if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                        Integer userIndex = Math.mod(Integer.valueOf(dashboardObj.Round_Robin_Identifier__c), lstGroup[0].GroupMembers.Size());
                        //mCareObj.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                    }
                }
            }
            
            
            if(!mCareListVsMerchantIdMap.isEmpty()){
                if(mCareListVsMerchantIdMap.containsKey(dashboardObj.Merchant_Id__c)){
                    List<String> ownerIdList = New List<String>();
                    List<String> uniqueOwnerIdCount = New List<String>();
                    
                    for(MCare_Dashboard_Case__c existingMCareObj : mCareListVsMerchantIdMap.get(dashboardObj.Merchant_Id__c)){
                        if(existingMCareObj.Assigned_Fifth__c || existingMCareObj.Assigned_Fourth__c){
                            //mCareObj.OwnerId = dashboardObj.Mark_As_Safe_Owner_Ids__c.substringAfter(';').substringAfter('-');
                            mCareObj.Assigned_Fifth__c = True;
                        }
                        else if(String.isNotBlank(existingMCareObj.Status__c) && existingMCareObj.Status__c == 'Mark as Safe' && existingMCareObj.Safe_Mark_Date__c != null){
                            ownerIdList.add(existingMCareObj.OwnerId);
                        }
                    }
                    
                    if(ownerIdList.contains(mCareObj.OwnerId)){
                        for(String ownerStr : ownerIdList){
                            uniqueOwnerIdCount.add(ownerStr);
                        }
                    }
                    
                    if(!uniqueOwnerIdCount.isEmpty() && uniqueOwnerIdCount.size() >= 3){
                        //mCareObj.OwnerId = dashboardObj.Mark_As_Safe_Owner_Ids__c.substringBefore(';').substringAfter('-');
                        mCareObj.Assigned_Fourth__c = True;
                    }
                    
                }
            }
            
            
            mCareDashboardOwnerMap.put(mCareObj.Id, mCareObj);
        }*/
        
        
        if(!mCareDashboardOwnerMap.isEmpty() && mCareDashboardOwnerMap.values().size() > 0) update mCareDashboardOwnerMap.values();
        
        if(!mCareCaseIds.isEmpty()) sendSettlementStatusToMCare(mCareCaseIds);
        
        if(!prodMerchantIds.isEmpty()) getOpportunityList(prodMerchantIds,midVsProdNameSet, opportunityMIDMap, accountIdVsContactMap);
        
    }
    
    public static void afterUpdateHandler(List<MCare_Dashboard_Case__c> triggerNew, Map<Id, MCare_Dashboard_Case__c> triggerOldMap){
        Set<Id> mCareCaseIds = New Set<Id>();
        List<MCare_Dashboard_Case__c> mCareDashboardList = New List<MCare_Dashboard_Case__c>();
        List<Case> caseList = New List<Case>();
        List<Integer> prodMerchantIds = New List<Integer>();
        Set<String> midVsProdNameSet = New Set<String>();
        Map<Integer,Opportunity> opportunityMIDMap = New Map<Integer, Opportunity>();
        Map<String,Contact> accountIdVsContactMap = New Map<String,Contact>();
        Map<String,Case> ticketIdVsCaseMap = New Map<String,Case>();
        List<MCare_Dashboard_Case__c> mCareDashboardUpdateList = New List<MCare_Dashboard_Case__c>();
        List<Opportunity> updatedOppList = New List<Opportunity>();
        Set<Id> releasedMCareCaseIds = New Set<Id>();
        
        for(MCare_Dashboard_Case__c dashboardObj : triggerNew){
            MCare_Dashboard_Case__c oldDashboardObj = triggerOldMap.get(dashboardObj.Id);
            if(String.isNotBlank(dashboardObj.Status__c) && dashboardObj.Status__c == 'Risk Hold' && dashboardObj.Status__c != oldDashboardObj.Status__c){
                mCareCaseIds.add(dashboardObj.Id);
                if(String.isBlank(dashboardObj.Case__c)) mCareDashboardList.add(dashboardObj);
                if(String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    prodMerchantIds.add(Integer.valueOf(dashboardObj.Merchant_Id__c));
                if(String.isNotBlank(dashboardObj.Product_Name__c) && String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    midVsProdNameSet.add(dashboardObj.Product_Name__c+'##'+dashboardObj.Merchant_Id__c);
            }
            if(String.isNotBlank(dashboardObj.Status__c) && dashboardObj.Status__c == 'Released' && dashboardObj.Approval_Status__c != oldDashboardObj.Approval_Status__c && dashboardObj.Approval_Status__c == 'Approved'){
                releasedMCareCaseIds.add(dashboardObj.Id);
            }
            if(dashboardObj.Product_Name__c != oldDashboardObj.Product_Name__c || dashboardObj.Merchant_Id__c != oldDashboardObj.Merchant_Id__c){
                if(String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    prodMerchantIds.add(Integer.valueOf(dashboardObj.Merchant_Id__c));
                if(String.isNotBlank(dashboardObj.Product_Name__c) && String.isNotBlank(dashboardObj.Merchant_Id__c)) 
                    midVsProdNameSet.add(dashboardObj.Product_Name__c+'##'+dashboardObj.Merchant_Id__c);
            }
        }
        system.debug('###### mCareDashboardList '+mCareDashboardList);
        if(!mCareCaseIds.isEmpty()) sendSettlementStatusToMCare(mCareCaseIds);
        
        if(!releasedMCareCaseIds.isEmpty()) sendSettlementStatusToMCare(releasedMCareCaseIds);
        
        if(!prodMerchantIds.isEmpty()) getOpportunityList(prodMerchantIds,midVsProdNameSet, opportunityMIDMap, accountIdVsContactMap);
        
    }
    
    public static void getOpportunityList(List<Integer> prodMerchantIds, Set<String> midVsProdNameSet, Map<Integer,Opportunity> opportunityMIDMap, Map<String,Contact> accountIdVsContactMap){
        /** Added Whitelisting_Status__c field for Mcare enhancement- SFI-1064 */
        for(Opportunity eachOpp : [Select Id,Whitelisting_Status__c , Prod_Merchant_Id__c,Product_Name__c,ProductLabel__c, Prod_MID__c,AccountId,NDX_Score__c from Opportunity Where Prod_Merchant_Id__c IN: prodMerchantIds]){
            string midVsProdName = eachOpp.ProductLabel__c+'##'+eachOpp.Prod_MID__c;
            //if(!midVsProdNameSet.isEmpty() && midVsProdNameSet.contains(midVsProdName)) /** Commented this because productName is not coming from DS. */
            opportunityMIDMap.put(Integer.valueOf(eachOpp.Prod_Merchant_Id__c), eachOpp);
            accountIdVsContactMap.put(eachOpp.AccountId,null);
        }
        
        if(!accountIdVsContactMap.isEmpty()){
            for(Contact contactObj : [Select Id,AccountId from Contact Where AccountId IN: accountIdVsContactMap.keySet()]){
                accountIdVsContactMap.put(contactObj.AccountId,contactObj);
            }
        }
    }
    
    public static void getExistingMCareData(Set<String> merchantIdSet, string DateFilter, Map<String,MCare_Dashboard_Case__c> mCareVsMerchantIdMap, Map<String,List<MCare_Dashboard_Case__c>> mCareListVsMerchantIdMap){
        Date lastThirtyDays = Date.today().addDays(-30);
        string query = 'Select Id,Approval_Status__c,No_of_Days_to_Whitelist__c,Safe_Mark_Date__c,Approval_Status_Date__c,Merchant_Id__c,OwnerId,Status__c,Assigned_Fifth__c,Assigned_Fourth__c from MCare_Dashboard_Case__c Where Merchant_Id__c IN : merchantIdSet';
        query += string.isNotBlank(DateFilter) ? ' AND Safe_Mark_Date__c != null AND Safe_Mark_Date__c >: lastThirtyDays' : '';
        query += ' ORDER BY LastModifiedDate Desc';
        
        for(MCare_Dashboard_Case__c existObj : Database.query(query)){
            if(string.isNotBlank(DateFilter)){
                if(!mCareListVsMerchantIdMap.containsKey(existObj.Merchant_Id__c)){
                    mCareListVsMerchantIdMap.put(existObj.Merchant_Id__c, New List<MCare_Dashboard_Case__c>{existObj});
                }else{
                    List<MCare_Dashboard_Case__c> existList = mCareListVsMerchantIdMap.get(existObj.Merchant_Id__c);
                    existList.add(existObj);
                    mCareListVsMerchantIdMap.put(existObj.Merchant_Id__c, existList);
                }
            }else{
                mCareVsMerchantIdMap.put(existObj.Merchant_Id__c, existObj);
            }
        }      
    }
    
    @future(callout=true)
    public static void sendSettlementStatusToMCare(Set<Id> sObjectIds){
        Map<Id,MCare_Dashboard_Case__c> dashboardCasesMap = New Map<Id,MCare_Dashboard_Case__c>([Select Id,Merchant_Id__c, Hold_Reason_Shown_to_Merchant__c,Status__c,API_Response__c,Opportunity__c from MCare_Dashboard_Case__c Where Id IN: sObjectIds]);
        string accessToken;
        List<Error_Details__c> errorDetailsList = New List<Error_Details__c>();
        List<Payload_Log__c> payloadLogList = New List<Payload_Log__c>();
        List<String> urlFormatStr = New List<String>();
        Map<string,String> statusVsNumberMap = New Map<String,String>();
        statusVsNumberMap.put('NO_HOLD', '0');//NO_HOLD
        statusVsNumberMap.put('RISK_HOLD', '1');//RISK_HOLD
        statusVsNumberMap.put('SETTLEMENT_TPHOLD', '2');//SETTLEMENT_TPHOLD
        statusVsNumberMap.put('RISK_AND_TPHOLD', '3');//RISK_AND_TPHOLD
        statusVsNumberMap.put('Risk Hold', '1');
        statusVsNumberMap.put('0', 'Active');
        statusVsNumberMap.put('1', 'Risk Hold');
        statusVsNumberMap.put('2', 'Thirdparty Hold');
        statusVsNumberMap.put('3', 'Risk & Thirdparty hold');
        HttpResponse response = New HttpResponse();
        List<MCare_Dashboard_Case__c> mCareListToUpdate = New List<MCare_Dashboard_Case__c>();
        Map<Id,Opportunity> opportunityToUpdateMap = New Map<Id,Opportunity>();
        
        if(!dashboardCasesMap.isEmpty()){
            if(!Test.isRunningTest()){
                accessToken = IntegrationUtility.getAuthToken('AuthenticateSettlementStatusFromMCare');
            }else{
                accessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }
            
            if(string.isNotBlank(accessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('UpdateSettlementStatusFromMCare');
                for(MCare_Dashboard_Case__c each : dashboardCasesMap.values() ){
                    if(dashboardCasesMap.containsKey(each.Id)){
                        if(each.Status__c == 'Risk Hold'){
                            urlFormatStr.add(statusVsNumberMap.get(each.Status__c));
                            response = IntegrationUtility.requestUtility(theIntIns, False, accessToken, each, urlFormatStr, null);
                            if(String.isNotBlank(each.Opportunity__c)){
                                Opportunity oppToUpdate = New Opportunity(Id = each.Opportunity__c);
                                oppToUpdate.Settlement_Status__c = 'Risk Hold';
                                oppToUpdate.Risk_Hold_Reason__c = each.Hold_Reason_Shown_to_Merchant__c;
                                opportunityToUpdateMap.put(oppToUpdate.Id, oppToUpdate);
                            }
                        }else if(each.Status__c == 'Released' && String.isNotBlank(each.API_Response__c)){
                            Map<string,object> deserializeResponse = (Map<String,object>) system.JSON.deserializeUntyped(each.API_Response__c);
                            Map<string,object> deserializeResult = (Map<String,object>) system.JSON.deserializeUntyped(JSON.serialize(deserializeResponse.get('result')));
                            
                            urlFormatStr.add(String.valueOf(deserializeResult.get('oldHoldStatus')));
                            response = IntegrationUtility.requestUtility(theIntIns, False, accessToken, each, urlFormatStr, null);
                            if(String.isNotBlank(each.Opportunity__c)){
                                Opportunity oppToUpdate = New Opportunity(Id = each.Opportunity__c);
                                oppToUpdate.Settlement_Status__c = statusVsNumberMap.get(String.valueOf(deserializeResult.get('oldHoldStatus')));
                                oppToUpdate.Risk_Hold_Reason__c = each.Hold_Reason_Shown_to_Merchant__c;
                                opportunityToUpdateMap.put(oppToUpdate.Id, oppToUpdate);
                            }
                        }
                        if(response != null && response.getStatusCode() == 200){
                            Payload_Log__c plLog = New Payload_Log__c(Process__c = 'Send Hold Settlement Status to Admin Panel',Prod_MID__c = Integer.valueOf(each.Merchant_Id__c),Status__c = 'SUCCESS',SalesforceRecordId__c = each.Id, Payload__c = response.getBody());
                            payloadLogList.add(plLog);
                            each.API_Response__c = response.getBody();
                            mCareListToUpdate.add(each);
                        }else{
                            Error_Details__c edLog = New Error_Details__c(Process__c = 'Send Hold Settlement Status to Admin Panel');
                            if(response != null && response.getBody() != null) edLog.Response__c = response.getBody();
                            errorDetailsList.add(edLog);
                        }
                    }
                }
            }
        }
        
        if(!opportunityToUpdateMap.isEmpty() && opportunityToUpdateMap.values().size() > 0) update opportunityToUpdateMap.values();
        if(!mCareListToUpdate.isEmpty()) update mCareListToUpdate;
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
    }
    
    public static void submitApprovalProcess(MCare_Dashboard_Case__c mCareObj){
        
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        
        submitRequest.setObjectId(mCareObj.id);
        submitRequest.setSubmitterId(mCareObj.OwnerId); 
        if(mCareObj.Status__c == 'Recommend Whitelist'){
            submitRequest.setProcessDefinitionNameOrId('MCare_Recommend_Whitelist_Ticket');
            submitRequest.setComments('Submitting request for approval of Recommend Whitelist.');
        }
        
        else if(mCareObj.Status__c == 'Released' && mCareObj.ANDX_Value__c != null && mCareObj.ANDX_Value__c > 1000000){
            submitRequest.setProcessDefinitionNameOrId('MCare_Released_10_Lacs');
            submitRequest.setComments('Submitting request for approval of released having NDX greater than 10 Lacs.');
        }else if(mCareObj.Status__c == 'Released' && mCareObj.ANDX_Value__c != null && mCareObj.ANDX_Value__c < 1000000){
            submitRequest.setProcessDefinitionNameOrId('MCare_Released_Less_10_Lacs');
            submitRequest.setComments('Submitting request for approval of released having NDX less than 10 Lacs.');
        }
        //submitRequest.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(submitRequest);
        
    }
}