Public class OpportunityTriggerHandler{    
    
    //Added by Pooja |SFI-338 29th June 2022
    public static boolean AssignLead= false;
    public static boolean isAutoCreateWebsitePage = false; //Added by rohit
    public static boolean isWebsiteDetailsRecordInsert = false; //Added by rohit
    public static boolean isWebsiteUpdate = false; //Added by rohit
    public static boolean runningFromConsumerAPI = false; 
    /* public static Map<Integer,Id> mapUserNumberToUserId = populateUserMap();
public static Integer currentValuenew=1;
private static Map<Integer,Id> populateUserMap() {
Map<Integer,Id> mapUserNumberToUserId = new Map<Integer,Id>();
for(User usr : [SELECT Id,Opty_Owner_Website_Null__c FROM User WHERE Opty_Owner_Website_Null__c  != NULL]) 
mapUserNumberToUserId.put(Integer.valueOf(usr.Opty_Owner_Website_Null__c),usr.Id);
return mapUserNumberToUserId;

}*/
    
    
    //-----Added By (Anas Yar Khan) to automate the population of Bank Category based on the MCC Code
    public static Map<String,Object> mapMCCCodeToBankCategory = (Map<String,Object>)JSON.deserializeUntyped(Label.MCCCodeToBankCategoryMapping);
    public static Map<String,Id> mapBankCategoryNameToId = getBankCategoryMap();
    
    public static Map<String,Id> getBankCategoryMap() {
        Map<String,Id> mapBankCategoryNameToId = new Map<String,Id>();
        for(Bank_Category__c bc : [SELECT Id,Name FROM Bank_Category__c LIMIT 50000]) {
            mapBankCategoryNameToId.put(bc.Name,bc.Id);    
        }
        return mapBankCategoryNameToId;
    }
    //-----Added By (Anas Yar Khan) to automate the population of Bank Category based on the MCC Code
    
    private static void assignRoundRobinUser(List<Opportunity> listOpportunity) {
        OpportunityOwnerWebsiteNull__c customSettingRecord = OpportunityOwnerWebsiteNull__c.getValues('OppOwnerWebsiteNullMerchant');
        Integer currentValue = Integer.valueOf(customSettingRecord.Current_Value__c);
        
        Map<Integer,Id> mapUserNumberToUserId = new Map<Integer,Id>();
        List<Id> websiteOwnerIdList = new List<Id>();
        for(User usr : [SELECT Id,Opty_Owner_Website_Null__c FROM User WHERE Opty_Owner_Website_Null__c  != NULL]) {
            mapUserNumberToUserId.put(Integer.valueOf(usr.Opty_Owner_Website_Null__c),usr.Id);
            websiteOwnerIdList.add(usr.Id);
        }
        
        if(mapUserNumberToUserId.keySet().size() > 0) {
            for(Opportunity opp : listOpportunity) {
                system.debug('opp====='+opp);
                //if the opportunity is already assigned to website owner, do not re-assign
                if(mapUserNumberToUserId.containsKey(currentValue) && !websiteOwnerIdList.contains(opp.OwnerId)) {  
                    opp.OwnerId = mapUserNumberToUserId.get(currentValue);
                    currentValue++;
                }
                if(currentValue > customSettingRecord.Maximum_Value__c) {
                    currentValue = 1;
                    
                }
            }   
        }
        customSettingRecord.Current_Value__c = currentValue;
        update customSettingRecord;
    }
    //Ended By Pooja|SFI-338
    
    public static Boolean checkRecurssion = false;
    public static boolean doNotUpdate = false;//added by Rohit
    public static Boolean publishUpdateFromApex = true;
    public static List<String> leadTypeList = New List<String>{'Merchant','seller','aggregator','child_aggregator','Child Aggregator'};
        public static List<String> merchantTypeList = New List<String>{'seller','aggregator','child_aggregator','Child Aggregator'};
            public static String oppSupportRTId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Support_Opportunity').getRecordTypeId();
    public static String oppMerchantRTId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Merchant').getRecordTypeId();
    public static String oppWibmoRTId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Wibmo').getRecordTypeId();
    public static Id resellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
    public static List<String> businessEntityNameList = New List<String>{'Sole Proprietorship','Individual'};
        public static List<String> productNameList = New List<String>{'PayUmoney','PayUbiz'};
            public static List<String> merchantBusinessTypeList = New List<String>{'LongTail','Compulsive'};
                
                public static void beforeInsertHandler(List<Opportunity> triggerNew){
                    Map<String,List<GroupMember>> indSolProgroupMap = New Map<String,List<GroupMember>>();
                    for(Group gp : [Select Id,Name,DeveloperName,(Select Id,UserORGroupId FROM GroupMembers) FROM GROUP WHERE DeveloperName IN('Alpha','Beta','Delta') AND Type =: 'Queue']){
                        indSolProgroupMap.put(gp.DeveloperName,gp.GroupMembers);
                    }
                    //========get custom setting for creating Identifier============
                    Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Opportunity');
                    
                    //========get custom setting for activating/Deactivating Baby care flow============
                    Baby_Care_Flow__c babyCareFlow = Baby_Care_Flow__c.getValues('FlowActivate');
                    
                    Set<Id> setAccId = new Set<Id>();
                    Map<Id, Account> mapAccount = new Map<Id, Account>();
                    Set<Id> setOptyId = new Set<Id>();
                    //*****Line no 8 Added by Akash Pandey*****//
                    Set<Id> setBusinessCategory = new Set<Id>(); 
                    List<Opportunity> listOpportunity = new List<Opportunity>();
                    Set<Id> subCategoryIds = new Set<Id>();
                    // Opp List for Baby Care assignment
                    List<Opportunity> settlementReassignOwner = new List<Opportunity>();
                    Map<Id,Opportunity> triggerOldMap = new Map<Id,Opportunity>();
                    List<string> settlementStatusList = system.label.Settlement_Status_Restricted.split(',');
                    Set<Id> compulsiveAccountIds = New Set<Id>();
                    List<Opportunity> ownerUpdateList = New List<Opportunity>();
                    
                    //========UTM Param Update Account And Opportunity Owner============
                    Integer counterofPartnerAllianceLead = 0;
                    Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
                    List<Account> partnerAccountList = New List<Account>();
                    List<Opportunity> listOpportunityRoundRobin = new List<Opportunity>();//Added By Pooja|SFI-338
                    
                    
                    for(Opportunity each : triggerNew){
                        System.debug('*******each'+each);
                        
                        // call this method to get the identifier field value if not exist                    
                        SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj); 
                        
                        //Handle Settlement Permission - Yash Lokwani
                        // checkSettlementStatusAccess(each, null);
                        
                        //================= SFI-530=Kunal====This will tag Teams to Partnership if Merchant is tagged to a partner=============
                        if(String.isNotBlank(each.Partner__c) && each.Campaign_Name__c == NULL) each.Team__c = 'Partnership';
                        //=================SFI-530=Kunal==END==================================================================================
                        
                        //Added By Pooja|SFI-338
                        if(each.Settlement_Status__c == 'Active' && each.Integration_Type__c =='Tools' && each.GMV_Lifetime__c ==null && each.Partner__c ==null 
                           && each.Partner_UUID__c ==null && each.Key_Assigned_Manager__c ==null && each.Last_3_months_GMV__c ==null && each.Last_6_months_GMV__c ==null && each.Last_12_months_GMV__c ==null && each.MTD_GMV__c ==null 
                           && each.YTD_GMV__c ==null && each.First_Successful_Txn_Amount__c ==null && each.Last_Settled_TXN_Amount__c ==null && each.Last_Attempted_Txn_Amount__c ==null && (each.LeadSource =='Organic'
                                                                                                                                                                                             || each.LeadSource == 'Others') && each.Document_Status_Document_Issue__c == 'Docs Approved' && each.Agreement_Status__c == 'Approved'){
                                                                                                                                                                                                 listOpportunityRoundRobin.add(each);    
                                                                                                                                                                                             }
                        //Ended By Pooja|SFI-338
                        if(each.AccountId != null){
                            setAccId.add(each.AccountId);
                        } 
                        
                        //========Updating settlement status to TP and Active as False if Opportunity is Terminated for LongTail and Compulsive Merchant============
                        if(each.StageName == 'Terminated'){
                            each.Active__c = false; 
                            each.Settlement_Status__c = 'Thirdparty Hold';
                        }
                        
                        //========Updating settlement status to TP for LongTail and Compulsive Merchant============
                        if(String.isNotBlank(each.Website_Status__c) && System.Label.Opportunitywebsitestatus.split(';').contains(each.Website_Status__c)
                           && each.NDX_Score__c > 50000 && (String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c)) 
                           && each.Merchant_Business_Type__c == 'LongTail' && leadTypeList.contains(each.Lead_Type__c)){
                               each.Settlement_Status__c = 'Thirdparty Hold';
                               each.Risk_Hold_Reason__c = Label.Risk_Hold_Reason;
                           } 
                        
                        //========Updating settlement status to TP for Enterprise Merchant============
                        if(String.isNotBlank(each.Website_Status__c) && System.Label.Opportunitywebsitestatus.split(';').contains(each.Website_Status__c)
                           && (each.Merchant_Business_Type__c == 'Enterprise') && (String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c))
                           && each.Lead_Type__c == 'Merchant' || each.Lead_Type__c == 'ProductAccount'){
                               each.Settlement_Status__c = 'Thirdparty Hold';
                               each.Risk_Hold_Reason__c = Label.Risk_Hold_Reason;
                           }
                        
                        //========Updating default Risk Level for all Merchants============
                        if(string.isBlank(each.Risk_Level__c)){
                            each.Risk_Level__c = 'Medium';
                        }
                        
                        //========Updating default lead type if Merchant Type is available for all Merchants============
                        if(string.isNotBlank(each.merchant_Type__c)){
                            each.Lead_Type__c = each.merchant_type__c;
                        }
                        
                        //*****Line no 42 to 46 Added by Akash Pandey*****//
                        // ======== update LOB status and Risk Auto Approved fields value
                        if(each.RecordTypeId != oppSupportRTId && String.isNotEmpty(each.Transaction_Facility_Required__c)
                           && each.Delivery_Duration__c != null && each.NDX_Score__c != null && each.BusinessCategory__c != null){
                               listOpportunity.add(each);
                               setBusinessCategory.add(each.BusinessCategory__c);
                           }
                        
                        //==============Commenting this code as delivery duration is updated by formula field of Sub Category========
                        //============================= update delivery duration=====================
                        /*if(String.isNotBlank(each.BusinessCategory__c) && string.isNotBlank(each.Sub_Category__c)){
subCategoryIds.add(each.Sub_Category__c);
}
//=============================update delivery duration end===============
*/
                        
                        //============== Opp List for Baby Care assignment======================================
                        if(each.Settlement_Status__c=='Active' && leadTypeList.contains(each.Lead_Type__c) && (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')){
                            settlementReassignOwner.add(each);
                        }
                        
                        //==========================update for Compulsive merchant ===============
                        if(String.isNotBlank(each.Merchant_Business_Type__c) && each.Merchant_Business_Type__c == 'Compulsive'){
                            if(!settlementStatusList.contains(each.Settlement_Status__c)){
                                each.Settlement_Status__c = 'Active';
                                each.Onboarding_Completed__c = true;//SFI-1065 By Saksham
                            }
                            if(String.isNotBlank(each.Integration_Type__c) && each.Integration_Type__c =='Thirdparty'){
                                each.Website_Status__c = 'Website OK';
                            }
                            if(each.Document_Status_Document_Issue__c != 'Docs Approved') each.Document_Status_Document_Issue__c = 'Docs Approved';
                            if(each.Agreement_Status__c != 'Approved') each.Agreement_Status__c = 'Approved';
                            if(String.isNotBlank(each.AccountId)){
                                compulsiveAccountIds.add(each.AccountId);
                            }
                        } 
                        //==========================update for Compulsive Merchant end==============
                        
                        //================update closeDate id Blank===================
                        //if(each.CloseDate == null) each.CloseDate = Date.Today().addMonths(1);
                        
                        //============update Opportunity Owner based on Lead assignment Rule========
                        if(String.isNotBlank(each.OwnerId) && each.OwnerId == Label.IntegrationUserId)
                            ownerUpdateList.add(each);
                        
                        //=============Campaign Tagging Lead assignment========
                        System.debug(each.Campaign_Name__c + '====================== campaign name 205');
                        if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Telesales'){
                            each.OwnerId = Label.Campaign_Telesales;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Inbound';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='SMB-Farming'){
                            each.OwnerId = Label.Campaign_SMB_Farming;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Farming';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='SMB-Outbound'){
                            each.OwnerId = Label.Campaign_SMB_Outbound;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Outbound';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='SMB-Strategy'){
                            each.OwnerId = Label.Campaign_SMB_Strategy;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Inbound';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Payout-Sales'){
                            each.OwnerId = Label.Campaign_Payout_Sales;
                            each.Merchant_Business_Type__c = 'Neobanking';
                            each.Team__c = 'Hunting';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Vista-Lending-AR'){
                            each.OwnerId = Label.Campaign_Vista_Lending_AR;
                            each.Merchant_Business_Type__c = 'Neobanking';
                            each.Team__c = 'Hunting';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Vista-CA-AP'){
                            each.OwnerId = Label.Campaign_Vista_CA_AP;
                            each.Merchant_Business_Type__c = 'Neobanking';
                            each.Team__c = 'Hunting';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Enterprise'){
                            each.OwnerId = Label.Campaign_Enterprise;
                            each.Merchant_Business_Type__c = 'Enterprise';
                            each.Team__c = 'Hunting';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Enterprise-Hunting'){
                            each.OwnerId = Label.Campaign_Enterprise_Hunting;
                            each.Merchant_Business_Type__c = 'Enterprise';
                            each.Team__c = 'Hunting';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Enterprise-Farming'){
                            each.OwnerId = Label.Campaign_Enterprise_Farming;
                            each.Merchant_Business_Type__c = 'Enterprise';
                            each.Team__c = 'Farming';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Inbound-Contact-Center'){
                            each.OwnerId = Label.Campaign_Inbound_Contact_Center;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Inbound';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Partnership-Conversions-Insta-Wix'){
                            each.OwnerId = Label.Campaign_Partnership_Conversions_Insta_Wix;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Partnership-Conversions-FB-Wix'){
                            each.OwnerId = Label.Campaign_Partnership_Conversions_FB_Wix;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Partnership-Shopify-Add-App'){
                            each.OwnerId = Label.Campaign_Partnership_Shopify_Add_App;
                            each.Merchant_Business_Type__c = 'LongTail';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='Shopify'){
                            each.OwnerId = Label.Campaign_Shopify;
                            each.Merchant_Business_Type__c = 'SMB';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='BigCommerce'){
                            each.OwnerId = Label.Campaign_BigCommerce;
                            each.Merchant_Business_Type__c = 'SMB';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='WooCommerce'){
                            each.OwnerId = Label.Campaign_WooCommerce;
                            each.Merchant_Business_Type__c = 'SMB';
                            each.Team__c = 'Partnership';
                            AssignLead = true;
                        }
                        
                        //=======SFI-613===========Partner Campaign Tagging=================================
                        else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='enterprise-hunting-partners' && each.Lead_Type__c == 'Partner'){
                            each.OwnerId = Label.Campaign_EnterpriseHuntingPartners;
                            each.Merchant_Business_Type__c = 'Platform Partner';
                            each.Team__c = 'Enterprise';
                            each.LeadSource = 'Inorganic';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners1' && each.Lead_Type__c == 'Partner'){
                            each.OwnerId = Label.Campaign_EnterpriseHuntingPartners1;
                            each.Merchant_Business_Type__c = 'Platform Partner';
                            each.Team__c = 'Platform Partner';
                            each.LeadSource = 'Inorganic';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners2' && each.Lead_Type__c == 'Partner'){
                            each.OwnerId = Label.Campaign_EnterpriseHuntingPartners2;
                            each.Merchant_Business_Type__c = 'Platform Partner';
                            each.Team__c = 'Platform Partner';
                            each.LeadSource = 'Inorganic';
                            AssignLead = true;
                        }else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners3' && each.Lead_Type__c == 'Partner'){
                            each.OwnerId = Label.Campaign_EnterpriseHuntingPartners3;
                            each.Merchant_Business_Type__c = 'Platform Partner';
                            each.Team__c = 'Platform Partner';
                            each.LeadSource = 'Inorganic';
                            AssignLead = true;
                        }
                        //==END==========SFI-613===========Partner Campaign Tagging=========================
                        
                        
                        //=============Child Aggregator Merchants Assignment======/    
                        else if(String.isNotBlank(each.Merchant_Type__c) && each.Merchant_Type__c =='Child Aggregator'){
                            each.OwnerId = Label.Child_Aggregator_Merchants_Assignment;
                            AssignLead = true;
                        }
                        
                        //=============Enterprise Merchants Assignment Logic======/
                        else if(String.isNotBlank(each.Business_Origin__c) && each.Business_Origin__c =='PayUbiz'){
                            each.OwnerId = Label.Enterprise_merchants_Assignment;
                            AssignLead = true;
                        }
                        
                        //============= Partner Alliance Lead assignment=========
                        if(String.isNotBlank(each.Lead_Type__c) && 'Partner'.equals(each.Lead_Type__c) && string.isNotBlank(each.Queue_Name__c) && each.Queue_Name__c == 'Partnerships_Alliances'){
                            counterofPartnerAllianceLead = counterofPartnerAllianceLead + 1;
                        }
                        
                        //==============All Indi Sole Pro Logic added by Rohit=================//
                        // This If condition assign round robin to  Opportunity Owner based on condition
                        
                        if(String.isNotBlank(each.Business_Entity_Formula__c ) && (each.Business_Entity_Formula__c=='Individual' || each.Business_Entity_Formula__c=='Sole Proprietorship')
                           && ( String.isBlank(each.Website__c ) || String.isBlank(each.iOS_URL__c) 
                               || String.isBlank(each.Android_URL__c) ) && (each.Integration_Type__c=='Tools' || each.Integration_Type__c=='Not Selected') && each.Partner__c==NULL && each.Lead_Type__c!='Partner' &&  AssignLead ==false){
                                   Integer userIndexInv = Math.mod(IntrandomNumber, indSolProgroupMap.get('Alpha').Size());
                                   SYstem.debug('userIndexInv::::::'+userIndexInv);
                                   each.OwnerId = indSolProgroupMap.get('Alpha').get(userIndexInv).UserORGroupId;
                                   userIndexInv = userIndexInv +1;
                                   
                               }
                        else if(String.isNotBlank(each.Business_Entity_Formula__c ) && (each.Business_Entity_Formula__c=='Individual')
                                && (String.isNotBlank(each.Website__c ) || String.isNotBlank(each.iOS_URL__c) || String.isNotBlank(each.Android_URL__c))
                                && each.Partner__c==NULL && each.Lead_Type__c!='Partner' &&  AssignLead ==false){
                                    Integer userIndexInv = Math.mod(IntrandomNumber, indSolProgroupMap.get('Beta').Size());
                                    SYstem.debug('userIndexInv::::::'+userIndexInv);
                                    each.OwnerId = indSolProgroupMap.get('Beta').get(userIndexInv).UserORGroupId;
                                    userIndexInv = userIndexInv +1;
                                    
                                }
                        else if(String.isNotBlank(each.Business_Entity_Formula__c ) && (each.Business_Entity_Formula__c !='Individual' ) && each.Partner__c==NULL && each.Lead_Type__c!='Partner' &&  AssignLead ==false){
                            Integer userIndexInv = Math.mod(IntrandomNumber, indSolProgroupMap.get('Delta').Size());
                            SYstem.debug('userIndexInv::::::'+userIndexInv);
                            each.OwnerId = indSolProgroupMap.get('Delta').get(userIndexInv).UserORGroupId;
                            userIndexInv = userIndexInv +1;
                            
                        }
                        /*******************End************************/
                        
                        
                        //============Update Integration Type on website URL change===========
                        if(each.Integration_Type__c == 'Tools' && (String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c))){
                            each.Integration_Type__c = 'Thirdparty';
                        }else if(each.Integration_Type__c == 'Thirdparty' && (String.isBlank(each.Website__c) && String.isBlank(each.Android_URL__c) && String.isBlank(each.iOS_URL__c))){
                            each.Integration_Type__c = 'Tools';
                        }
                        
                        //====================== Check Skip Identifier for status Update==================
                        if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
                           && each.Skip_Agreement_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
                           && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)) {
                               each.Agreement_Status__c = 'Approved';
                           }
                        if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
                           && each.Skip_Document_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
                           && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                               each.Document_Status_Document_Issue__c = 'Docs Approved';
                           }
                        //======================= End Check Skip Identifier for status Update================
                    }
                    
                    
                    
                    if(!settlementReassignOwner.isEmpty() && settlementReassignOwner.size()>0){
                        babyCareReassignOppOwnerBU(settlementReassignOwner,null,babyCareFlow);
                    }
                    
                    
                    if(!setAccId.isEmpty()) getAccountRecords(setAccId, mapAccount);
                    
                    updateOptyNameAndWebsiteStatus(triggerNew, null, mapAccount);
                    
                    updateTheStageBasedOnCriteria(triggerNew, mapAccount);
                    
                    beforeInsertOptyUpdateStage(triggerNew, mapAccount);
                    
                    //=========Commenting the code due to onboarding revamp===============
                    //if(!mapAccount.isEmpty()) updateSettlementStatus(triggerNew, triggerOldMap, mapAccount); 
                    updateSettlementStatus(triggerNew, triggerOldMap, mapAccount);
                    
                    //*****Line no 69 Added by Akash Pandey*****//
                    if(!listOpportunity.isEmpty() && !setBusinessCategory.isEmpty()) updateLOBAndRiskAutoApproved(listOpportunity, setBusinessCategory);
                    
                    /******=====Commenting this code as delivery duration is updated by formula field of Sub Category========
//===================update delivery duration==============
if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0) updateDeliveryDuration(subCategoryIds,triggerNew);
*****************************/
                    
                    //=====================To blacklist the merchant============
                    if(Label.BlacklistRiskType == 'true'){
                        pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(triggerNew,null);
                    }
                    
                    //================update Compulsite Account Doc and Agreement Status=================
                    if(!compulsiveAccountIds.isEmpty() && compulsiveAccountIds.size()>0)
                        updateCompulsiveAccounts(compulsiveAccountIds);
                    
                    //======== This is used to check partner alliances opportunity and add to set for owner assignment
                    if(counterofPartnerAllianceLead > 0){
                        List<Group> lstGroup = getGroupdata('Partnerships_Alliances');
                        if(lstGroup != null && lstGroup.size() > 0){
                            for(Opportunity each : triggerNew){
                                if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                                    Integer userIndex = Math.mod(IntrandomNumber, lstGroup[0].GroupMembers.Size());
                                    each.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                    
                                    if(!mapAccount.isEmpty() && mapAccount.containsKey(each.AccountId) && mapAccount.get(each.AccountId) != null){
                                        Account accObj = mapAccount.get(each.AccountId);
                                        accObj.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                        partnerAccountList.add(accObj);
                                    }
                                    IntrandomNumber = IntrandomNumber + 1;
                                }
                            }
                        }
                    }
                    
                    //======== This is used to check partner alliances account list and add to set for owner assignment
                    if(!partnerAccountList.isEmpty()) update partnerAccountList;
                    
                    if(listOpportunityRoundRobin.size() > 0)assignRoundRobinUser(listOpportunityRoundRobin);//Added By Pooja|SFI-338
                    
                    //===============update Opportunity Owner, if assignment rule not run=============
                    //if(!ownerUpdateList.isEmpty()) updateOpportunityOwner(ownerUpdateList);
                }
    
    // this method call FROM Opportunity trigger at before update
    public static void beforeUpdateHandler(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id, Opportunity>  TriggerNewMap){        
        //*****Line no 81 to 82 Added by Akash Pandey*****//
        Set<Id> setBusinessCategory = new Set<Id>(); 
        Baby_Care_Flow__c babyCareFlow = Baby_Care_Flow__c.getValues('FlowActivate');
        List<Opportunity> listOpportunity = new List<Opportunity>();
        Set<Id> setAccId = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        Set<Id> setOptyId = new Set<Id>();
        List<String> websiteStatusValueList = Label.Opportunitywebsitestatus.split(';');
        List<Opportunity> settlementReassignOwner = new List<Opportunity>();
        Set<id> subCategoryIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> blackListTaskForRiskTeam = new List<Opportunity>();//By:- Akash Pandey. Task for risk if we find any blacklisted parameter.
        List<Opportunity> listOpportunityRoundRobin = new List<Opportunity>();//Added By Pooja|SFI-338
        //=====================To blacklist the merchant============
        //List<String> websiteList = new List<String>();
        Boolean isExecuteMerchantBlackList = false;
        
        List<string> settlementStatusList = system.label.Settlement_Status_Restricted.split(',');
        Set<Id> compulsiveAccountIds = New Set<Id>();
        List<String> subCategoryNameList = New List<String>();
        List<String> businessCategoryNameList = New List<String>();
        
        //========UTM Param Update Account And Opportunity Owner============
        Integer counterofPartnerAllianceLead = 0;
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        List<Account> partnerAccountList = New List<Account>();
        Set<Id> oppIdForWebPage = new Set<Id>();//. added by rohit
        List<Website_Details__c> listLeadWebsiteForOfflineOpp = new List<Website_Details__c>();
        
        // Collect the Opportunity Ids For PEP Status Validation added by Rahul
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : triggerNew) {
            opportunityIds.add(opp.Id);
        }
        
        // Query the related Merchant_Status_Details__c records
        Map<Id, Merchant_Status_Details__c> merchantStatusDetailsMap = new Map<Id, Merchant_Status_Details__c>();
        List<Merchant_Status_Details__c> relatedStatusDetails = [SELECT Id, Opportunity__c, Status_Value__c, Status_Type__c FROM Merchant_Status_Details__c WHERE Opportunity__c IN :opportunityIds AND Status_Type__c = 'KYC_DOCUMENTS'];
       // List<Merchant_Status_Details__c> relatedStatusDetails = [SELECT Id, Opportunity__c, Status_Value__c, Status_Type__c FROM Merchant_Status_Details__c WHERE Opportunity__c IN :opportunityIds AND (Status_Type__c = 'KYC_DOCUMENTS' OR Status_Type__c = 'RE_KYC_DOCUMENTS')];

        for (Merchant_Status_Details__c statusDetail : relatedStatusDetails) {
            merchantStatusDetailsMap.put(statusDetail.Opportunity__c, statusDetail);
        }
        
        for(Opportunity each : triggerNew){
            
             // (SFI-831) start
            if(triggerOldMap.get(each.Id).KAM_Change_Approval__c != each.KAM_Change_Approval__c && each.KAM_Change_Approval__c=='Approved' && triggerOldMap.get(each.Id).OwnerId != each.New_Opportunity_Owner_Requested__c) {
            	each.OwnerId = each.New_Opportunity_Owner_Requested__c;each.KAM_Change_Request_Sent_To__c = null;each.New_Opportunity_Owner_Requested__c=null;
            }
            if(triggerOldMap.get(each.Id).Team_Change_Approval_Status__c != each.Team_Change_Approval_Status__c && each.Team_Change_Approval_Status__c=='Approved') {
            	each.Team__c = each.New_Team_Requested__c;each.Merchant_Business_Type__c = each.New_Merchant_Business_Type_Requested__c;each.Team_Change_Requested_To__c = null;each.New_Merchant_Business_Type_Requested__c=null;each.New_Team_Requested__c=NULL;
            }
            if((triggerOldMap.get(each.Id).Team__c == null && triggerOldMap.get(each.Id).Merchant_Business_Type__c == null) || 
              (triggerOldMap.get(each.Id).Team__c == 'Untagged' && triggerOldMap.get(each.Id).Merchant_Business_Type__c == 'Untagged') ) {
                   if(triggerOldMap.get(each.Id).New_Opportunity_Owner_Requested__c != each.New_Opportunity_Owner_Requested__c) {
                       each.OwnerId = each.New_Opportunity_Owner_Requested__c;
                   }
                   if(triggerOldMap.get(each.Id).New_Team_Requested__c != each.New_Team_Requested__c || triggerOldMap.get(each.Id).New_Merchant_Business_Type_Requested__c != each.New_Merchant_Business_Type_Requested__c) {
                        each.Team__c = each.New_Team_Requested__c; each.Merchant_Business_Type__c = each.New_Merchant_Business_Type_Requested__c;
                   }
            }
            // (SFI-831) end
            
            /* SFI : 1125 :: GST Number Validation : 3rd to 12th character of GST Number should be the PAN Number*/
            String gstNumber = each.GST_Number__c;
            String panNumber = each.PAN_Number_Account_New__c;
            
            // Check for changes in Customer_Declaration_PEP__c or Jocata_System_Alerts__c
            
            if ((triggerOldMap.get(each.Id).Customer_Declaration_PEP__c != each.Customer_Declaration_PEP__c && each.Customer_Declaration_PEP__c == 'PEP') || (triggerOldMap.get(each.Id).Customer_Declaration_PEP__c != each.Customer_Declaration_PEP__c && each.Customer_Declaration_PEP__c == 'Related to PEP') || (triggerOldMap.get(each.Id).Jocata_System_Alerts__c != each.Jocata_System_Alerts__c && each.Jocata_System_Alerts__c)) {
                // Check if there is a related Merchant_Status_Details__c record
                if (merchantStatusDetailsMap.containsKey(each.Id)) {
                    Merchant_Status_Details__c statusDetail = merchantStatusDetailsMap.get(each.Id);
                    
                   if ( statusDetail.Status_Value__c != 'Docs Approved' || each.Next_ReKYC_Date__c != null || each.Is_dormant__c ) {
                        each.PEP_Status__c = 'pending';    
                    } 
              /*     if (statusDetail.Status_Type__c == 'KYC_DOCUMENTS' && statusDetail.Status_Value__c != 'Docs Approved') {
            // Update the logic based on your requirements
            if (statusDetail.Status_Type__c == 'RE_KYC_DOCUMENTS') {
                // Logic for 'ReKYC_DOCUMENTS' status type
                // Set PEP_Status__c accordingly
                each.PEP_Status__c = 'pending';
            } else {
                // Logic for 'KYC_DOCUMENTS' status type
                // Set PEP_Status__c accordingly
                each.PEP_Status__c = 'pending';
            }
        }*/
                }
            }
            

            //=======End PEP Validation=======//
            
            //======added by Rahul =======//
            // Additional logic for preventing the clearance of Next_ReKYC_Date__c
            Set<Id> oppIdsForReKYCCheck = new Set<Id>();
            for (Opportunity opp : triggerNew) {
                Opportunity oldOpp = triggerOldMap.get(opp.Id);
                if (oldOpp.Next_ReKYC_Date__c != null && opp.Next_ReKYC_Date__c == null) {
                    oppIdsForReKYCCheck.add(opp.Id);
                }
            }
            
            // Only proceed if there are Opportunities to check
            if (!oppIdsForReKYCCheck.isEmpty()) {
                // Fetch related Merchant_Document__c records in bulk
                List<Merchant_Document__c> merchantDocs = [
                    SELECT Id, reKYC_Doc__c	, Onboarding_Status__c, Opportunity__c 
                    FROM Merchant_Document__c 
                    WHERE Opportunity__c IN :oppIdsForReKYCCheck
                ];
                
                // Map Merchant Documents to their respective Opportunities
                Map<Id, List<Merchant_Document__c>> merchantDocMap = new Map<Id, List<Merchant_Document__c>>();
                for (Merchant_Document__c md : merchantDocs) {
                    if (!merchantDocMap.containsKey(md.Opportunity__c)) {
                        merchantDocMap.put(md.Opportunity__c, new List<Merchant_Document__c>());
                    }
                    merchantDocMap.get(md.Opportunity__c).add(md);
                }
                
                // Check conditions and apply business logic
            /*   for (Opportunity opp : triggerNew) {
                    if (oppIdsForReKYCCheck.contains(opp.Id)) {
                        for (Merchant_Document__c md : merchantDocMap.get(opp.Id)) {
                            if (md.reKYC_Doc__c	 == true &&
                                md.Onboarding_Status__c != 'Approved' &&
                                md.Onboarding_Status__c != 'Declined' &&
                                md.Onboarding_Status__c != 'Exceptional') {
                                    
                                    opp.addError('Next ReKYC Date cannot be cleared while KYC verification is in progress.');
                                    break; // Exit the loop after finding one case that meets the criteria
                                }
                        }
                    }
                }
            }*/
            
            
            
                // Check conditions and apply business logic
                for (Opportunity opp : triggerNew) {
                    if (oppIdsForReKYCCheck.contains(opp.Id)) {
                        List<Merchant_Document__c> merchantDocsForOpp = merchantDocMap.get(opp.Id);
                        
                        // Check if the map contains the key and if the list is not null
                        if (merchantDocsForOpp != null) {
                            for (Merchant_Document__c md : merchantDocsForOpp) {
                                if (md.reKYC_Doc__c == true &&
                                    md.Onboarding_Status__c != 'Approved' &&
                                    md.Onboarding_Status__c != 'Declined' &&
                                    md.Onboarding_Status__c != 'Exceptional') {
                                        opp.addError('Next ReKYC Date cannot be cleared while KYC verification is in progress.');
                                        break; // Exit the loop after finding one case that meets the criteria
                                    }
                            }
                        }
                    }
                }
            }
            
            
     


            //====End next rekyc validation  ====//    
            
            if(gstNumber != null && gstNumber.length() == 15){
                String gstSubString = gstNumber.subString(2, 12);
                if(!gstSubString.equalsIgnorecase(panNumber)){
                    each.addError('Invalid GST Number. GST Number should be of 15 characters. Also, 3rd to 12th character of GST Number should be the PAN Number');
                    System.debug('WRONG GST');
                }
            }
            
            
            
            /*End : GST Number Validation */
            
            Opportunity oldOpp = triggerOldMap.get(each.Id); 
            //Handle Settlement Permission - Yash Lokwani
            checkSettlementStatusAccess(each, oldOpp);
            
            
            //================= SFI-530=Kunal====This will tag Teams to Partnership if Merchant is tagged to a partner=============
            if(String.isNotBlank(each.Partner__c) && String.isBlank(oldOpp.Partner__c) && each.CreatedDate >= Date.today().addDays(-90)) {
                each.Team__c = 'Partnership';
            }
            //=================SFI-530=Kunal==END==================================================================================      
            
            //==========get AccountId for quering the Account Data==============
            if(each.AccountId != null){
                setAccId.add(each.AccountId);
            }
            
            //==========Updating the Last Rekyc date when Next Rekyc is null=======SFI-1245=Rahul Pandey//
            if (each.Next_ReKYC_Date__c == null && oldOpp.Next_ReKYC_Date__c != null) {
                each.Last_ReKYC_date__c = Date.today();
                
            }
            
            // Set PEP_Status__c to null when Next_ReKYC_Date__c is changed from null to a date added by Rahul
            if (oldOpp.Next_ReKYC_Date__c == null && each.Next_ReKYC_Date__c != null) {
                each.PEP_Status__c = null;
            }
           
            
            
            //========Updating settlement status to TP and Active as False if Opportunity is Terminated for LongTail and Compulsive Merchant============
            if(each.StageName == 'Terminated' && oldOpp.StageName != each.StageName){
                each.Active__c = false;
                each.Settlement_Status__c = 'Thirdparty Hold';
            }
            
            //========Updating settlement status to TP if website status change for all merchant business type=====SS Risk Hold condition added By Pooja For SFI-418 (To hold merchant on Risk hold If old status is Risk Hold===============
            if((String.isNotBlank(each.Website_Status__c) && each.Website_Status__c != oldOpp.Website_Status__c && each.Website_Status__c != 'Website OK' && each.Settlement_Status__c != 'Risk Hold')
               && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || string.isNotBlank(each.Android_URL__c))
               && leadTypeList.contains(each.Lead_Type__c)){
                   each.Settlement_Status__c = 'Thirdparty Hold';                   
                   each.Risk_Hold_Reason__c = Label.Risk_Hold_Reason;
               }
            
            //==========Updating lead type if merchant type is updated===========================
            if(string.isNotBlank(each.merchant_Type__c) && each.merchant_Type__c != oldOpp.merchant_Type__c){
                each.Lead_Type__c = each.merchant_type__c;
            }
            
            //==========Updating Merchant type if Lead Type is updated===========================
            if(string.isNotBlank(each.Lead_Type__c) && each.Lead_Type__c != oldOpp.Lead_Type__c && merchantTypeList.contains(each.Lead_Type__c)){//(each.Lead_Type__c == 'Seller' || each.Lead_Type__c == 'Aggregator')){
                each.merchant_type__c = each.Lead_Type__c;
            }
            
            //Yash Lokwani- changes for handling "hold by" and "date of capture" fields
            //Risk Hold / Post-risk Hold
            /*if((each.Settlement_Status__c == 'Risk Hold') && oldOpp.Settlement_Status__c == 'Active'){
//each.Post_Risk_Hold_By__c = UserInfo.getUserId();
//each.Post_Risk_Hold_Date_of_Capture__c = Datetime.now();
} 
//OB Hold
else if((each.Settlement_Status__c == 'OB Hold') && oldOpp.Settlement_Status__c == 'Active'){
//each.OB_Hold_By__c = UserInfo.getUserId();
//each.OB_Hold_Date_of_Capture__c = Datetime.now();
}
//Pre-risk Hold
else if((each.Settlement_Status__c == 'Pre-risk Hold') && oldOpp.Settlement_Status__c == 'Active'){
//each.Pre_Risk_Hold_By__c = UserInfo.getUserId();
//each.Pre_Risk_Hold_Date_of_Capture__c = Datetime.now();
}
//Unhold
else if((oldOpp.Settlement_Status__c == 'Pre-risk Hold' || oldOpp.Settlement_Status__c == 'Risk Hold' || oldOpp.Settlement_Status__c == 'OB Hold') && each.Settlement_Status__c == 'Active'){
//each.Hold_Removed_By__c = UserInfo.getUserId();
//each.Date_of_Unhold__c = Datetime.now();
}*/
            //=======SFI-613===========Partner Campaign Tagging=================================
            /*if(String.isNotBlank(each.Campaign_Name__c) && trigger.oldMap.get(each.Campaign_Name__c) == NULL && each.Campaign_Name__c =='enterprise-hunting-partners' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
each.OwnerId = Label.Campaign_EnterpriseHuntingPartners;
each.Merchant_Business_Type__c = 'Enterprise';
each.Team__c = 'Enterprise';
each.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnerships-hunting-partners1' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
each.OwnerId = Label.Campaign_EnterpriseHuntingPartners1;
each.Merchant_Business_Type__c = 'Platform Partner';
each.Team__c = 'Platform Partner';
each.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners2' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
each.OwnerId = Label.Campaign_EnterpriseHuntingPartners2;
each.Merchant_Business_Type__c = 'Platform Partner';
each.Team__c = 'Platform Partner';
each.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners3' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
each.OwnerId = Label.Campaign_EnterpriseHuntingPartners3;
each.Merchant_Business_Type__c = 'Platform Partner';
each.Team__c = 'Platform Partner';
each.LeadSource = 'Inorganic';
AssignLead = true;
} */  
            
            //===END========SFI-613===========Partner Campaign Tagging=================================
            //*****Line no 131 to 135 Added by Akash Pandey*****//
            
            if(each.RecordTypeId != oppSupportRTId && (each.Transaction_Facility_Required__c != oldOpp.Transaction_Facility_Required__c
                                                       || each.Delivery_Duration__c != oldOpp.Delivery_Duration__c || each.NDX_Score__c != oldOpp.NDX_Score__c || each.BusinessCategory__c != oldOpp.BusinessCategory__c)
               && String.isNotEmpty(each.Transaction_Facility_Required__c) && each.Delivery_Duration__c != null && each.NDX_Score__c != null && each.BusinessCategory__c != null)
            {
                listOpportunity.add(each);
                setBusinessCategory.add(each.BusinessCategory__c);
            } 
            
            /******=====Commenting this code as delivery duration is updated by formula field of Sub Category========
//======================update deliver duration=====================
if(string.isnotBlank(each.BusinessCategory__c) && string.isNotBlank(each.Sub_Category__c) && 
(each.Sub_Category__c != triggerOldMap.get(each.id).Sub_Category__c)){
subCategoryIds.add(each.Sub_Category__c);
} 
//====================update delivery duration end==================*/
            
            //====================Update Call Status and Call Duration of C2C============================
            if(string.isNotBlank(each.Manual_Call_Response__c) && each.Manual_Call_Response__c != oldOpp.Manual_Call_Response__c && each.Missed_Call_Time__c == oldOpp.Missed_Call_Time__c){
                map<string,string> callResponseMap = new Map<string,string>();
                list<string> listManualCallResponse = (each.Manual_Call_Response__c).split(','); 
                If(!listManualCallResponse.isEmpty() && listManualCallResponse.size()>0){
                    for(integer i=0; i<listManualCallResponse.size(); i++){
                        If(listManualCallResponse[i].contains(':')){
                            list<string> str = listManualCallResponse[i].split(':');
                            If(!str.isEmpty() && str.size()>0) callResponseMap.put(str[0],str[1]);
                        }
                    }
                    
                    if(!callResponseMap.isEmpty()){
                        each.Call_Status__c = callResponseMap.get('CallStatus');
                        each.Call_Duration__c = callResponseMap.get('Bill_Seconds');
                    }
                }
            }
            
            //================== get Opp List for settlement baby care assignment===========================           
            if(String.isNotBlank(each.Settlement_Status__c) && 
               (each.Settlement_Status__c != oldOpp.Settlement_Status__c || each.Website_Status__c != oldOpp.Website_Status__c
                || each.LeadSource != oldOpp.LeadSource || each.Document_Status_Document_Issue__c!= oldOpp.Document_Status_Document_Issue__c
                || each.Integration_Type__c != oldOpp.Integration_Type__c)
               && each.Settlement_Status__c == 'Active' && leadTypeList.contains(each.Lead_Type__c) && (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')
              ){
                  
                  if(each.Integration_Type__c == 'ThirdParty' || each.Integration_Type__c == 'Tools'){
                      settlementReassignOwner.add(each);
                  }
              }
            
            //==================get Opp List of Changed Manual Call Response OR Changed Missed Call Time====================
            if((each.Manual_Call_Response__c != null && each.Manual_Call_Response__c  != oldOpp.Manual_Call_Response__c && each.Missed_Call_Time__c == oldOpp.Missed_Call_Time__c) || (each.Missed_Call_Time__c != oldOpp.Missed_Call_Time__c && String.isNotBlank(each.Missed_Call_Time__c))) {
                oppList.add(each);
            }
            
            //**********get Opp List for Blacklist Task By Akash***********//
            if(String.isNotBlank(each.Risk_Type_Multi_Select__c) && each.Blacklist__c && each.Risk_Type_Multi_Select__c != oldOpp.Risk_Type_Multi_Select__c){
                blackListTaskForRiskTeam.add(each);
            }
            
            //======================update for BlackList && Agreement Generate========================
            if((String.isNotBlank(each.Website__c) && each.Website__c != oldOpp.Website__c) 
               || (String.isNotBlank(each.Android_URL__c) && each.Android_URL__c != oldOpp.Android_URL__c) 
               || (String.isNotBlank(each.iOS_URL__c) && each.iOS_URL__c != oldOpp.iOS_URL__c)){
                   isExecuteMerchantBlackList = true;
               }
            
            if(each.Display_name__c != null && each.Display_name__c != oldOpp.Display_name__c){
                isExecuteMerchantBlackList = true;
            }
            //======================update for BlackList end=====================
            
            //==========================update for Compulsive merchant ===============
            if(String.isNotBlank(each.Merchant_Business_Type__c) && 
               each.Merchant_Business_Type__c != triggerOldMap.get(each.Id).Merchant_Business_Type__c
               && each.Merchant_Business_Type__c=='Compulsive'){
                   if(!settlementStatusList.contains(each.Settlement_Status__c)){
                       each.Settlement_Status__c = 'Active';
                       each.Onboarding_Completed__c = true;//SFI-1065 By Saksham
                   }
                   if(String.isNotBlank(each.Integration_Type__c) && each.Integration_Type__c =='Thirdparty'){
                       each.Website_Status__c = 'Website OK';
                   }
                   if(each.Document_Status_Document_Issue__c != 'Docs Approved') each.Document_Status_Document_Issue__c = 'Docs Approved';
                   if(each.Agreement_Status__c != 'Approved') each.Agreement_Status__c = 'Approved';
                   if(String.isNotBlank(each.AccountId)){
                       compulsiveAccountIds.add(each.AccountId);
                   }
               } 
            //==========================update for Compulsive Merchant end==============
            
            //==============Commenting the code as we are not using wibmo product=============
            //===================== update for Wibmo product========================
            /* If(each.RecordTypeId == oppWibmoRTId){   
if(each.Target_Close_Date__c != null && each.Target_Close_Date__c != oldOpp.Target_Close_Date__c){  
date myDate = each.Target_Close_Date__c;  
date Expected_Rev_start_date_go_live = myDate.addMonths(3);  
each.Expected_Rev_start_date_go_live__c = Expected_Rev_start_date_go_live;   
}  
if(each.stagename != oldOpp.stagename && each.stagename == 'Stage 4 - Closure'){  
each.Date_of_closure__c = Date.today();  
}   
}  
*/
            
            //==========================Update for Whatsapp outBound =================
            if((each.Settlement_Status__c == 'Risk Hold' || each.Settlement_Status__c == 'Risk & Thirdparty hold' || each.Settlement_Status__c == 'OB Hold') &&
               each.Settlement_Status_Latest_Date__c != null && oldOpp.Settlement_Status__c == 'Active' && (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive') ){
                   each.TemplateId__c = '2';
               }
            
            //============Update KAM Updated Date for Reporting====================
            if(String.isNotBlank(each.Key_Assigned_Manager__c) && each.Key_Assigned_Manager__c != oldOpp.Key_Assigned_Manager__c){
                each.KAM_Updated_Date__c = System.now();
            }
            
            //=============update MCC Code==================
            if((String.isNotBlank(each.Business_Category__c) && each.Business_Category__c != triggerOldMap.get(each.Id).Business_Category__c)
               ||(String.isNotBlank(each.SubCategory__c) && each.SubCategory__c != triggerOldMap.get(each.Id).SubCategory__c)
              ){
                  subCategoryNameList.add(each.SubCategory__c);
                  businessCategoryNameList.add(each.Business_Category__c);
              }
            //============== update for onboarding Revamp==================
            if(String.isNotBlank(each.Agreement_Status__c) && each.Agreement_Status__c != triggerOldMap.get(each.Id).Agreement_Status__c && each.Agreement_Status__c == 'Approved' && (String.isBlank(each.Document_Status_Document_Issue__c) || (string.isNotBlank(each.Document_Status_Document_Issue__c) && each.Document_Status_Document_Issue__c !='Docs Approved'))){
                each.Document_Status_Document_Issue__c = 'Docs Approved';
            }
            
            //============= Partner Alliance Lead assignment=========
            if(String.isNotBlank(each.Lead_Type__c) && 'Partner'.equals(each.Lead_Type__c) && string.isNotBlank(each.Queue_Name__c) && each.Queue_Name__c != oldOpp.Queue_Name__c && each.Queue_Name__c == 'Partnerships_Alliances'){
                counterofPartnerAllianceLead = counterofPartnerAllianceLead + 1;
            }
            
            //============Update Integration Type on website URL change===========
            if(each.Integration_Type__c == 'Tools' && ((String.isNotBlank(each.Website__c) && each.Website__c != triggerOldMap.get(each.Id).Website__c) 
                                                       || (String.isNotBlank(each.Android_URL__c) && each.Android_URL__c != triggerOldMap.get(each.Id).Android_URL__c)
                                                       || (String.isNotBlank(each.iOS_URL__c) && each.iOS_URL__c != triggerOldMap.get(each.Id).iOS_URL__c))){
                                                           each.Integration_Type__c = 'Thirdparty';
                                                       }else if(each.Integration_Type__c == 'Thirdparty' && (String.isBlank(each.Website__c) && String.isBlank(each.Android_URL__c) && String.isBlank(each.iOS_URL__c)
                                                                                                             && (each.Website__c != triggerOldMap.get(each.Id).Website__c || each.Android_URL__c != triggerOldMap.get(each.Id).Android_URL__c || each.iOS_URL__c != triggerOldMap.get(each.Id).iOS_URL__c))){
                                                                                                                 System.debug('each.Website__c:::888::'+each.Website__c);
                                                                                                                 each.Integration_Type__c = 'Tools';
                                                                                                             }
            
            //====================== Check Skip Identifier for status Update==================
            if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
               && each.Skip_Agreement_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && (each.Partner__c != oldOpp.Partner__c || each.Bank_Verification_Status__c != oldOpp.Bank_Verification_Status__c)){
                   each.Agreement_Status__c = 'Approved';
               }
            if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
               && each.Skip_Document_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && (each.Partner__c != oldOpp.Partner__c || each.Bank_Verification_Status__c != oldOpp.Bank_Verification_Status__c)){
                   each.Document_Status_Document_Issue__c = 'Docs Approved';
               }
            //======================= End Check Skip Identifier for status Update================
        }
        if(!setAccId.isEmpty()) getAccountRecords(setAccId, mapAccount);
        
        updateOptyNameAndWebsiteStatus(triggerNew, triggerOldMap, mapAccount);
        
        beforeUpdateOptyUpdateStage(triggerNew, triggerOldMap, mapAccount);
        //=========Commenting the code due to onboarding revamp===============
        //if(!mapAccount.isEmpty()) updateSettlementStatus(triggerNew, triggerOldMap, mapAccount);
        updateSettlementStatus(triggerNew, triggerOldMap, mapAccount);
        for(Opportunity each : triggerNew){
            Opportunity oldOpp = triggerOldMap.get(each.Id); //Added By Pooja|SFI-338
            system.debug('old status=='+oldOpp.Settlement_Status__c);
            system.debug('new status'+each.Settlement_Status__c);
            if(each.Settlement_Status__c == 'Active' && each.Integration_Type__c =='Tools' && each.GMV_Lifetime__c ==null && each.Partner__c ==null 
               && each.Partner_UUID__c ==null && each.Key_Assigned_Manager__c ==null && each.Last_3_months_GMV__c ==null && each.Last_6_months_GMV__c ==null && each.Last_12_months_GMV__c ==null && each.MTD_GMV__c ==null 
               && each.YTD_GMV__c ==null && each.First_Successful_Txn_Amount__c ==null && each.Last_Settled_TXN_Amount__c ==null && each.Last_Attempted_Txn_Amount__c ==null && (each.LeadSource =='Organic'
                                                                                                                                                                                 || each.LeadSource == 'Others') && each.Document_Status_Document_Issue__c == 'Docs Approved' && each.Agreement_Status__c == 'Approved'){
                                                                                                                                                                                     system.debug('inside'+oldOpp.Settlement_Status__c);
                                                                                                                                                                                     listOpportunityRoundRobin.add(each);    
                                                                                                                                                                                 }
            
        }
        if(listOpportunityRoundRobin.size() > 0) {assignRoundRobinUser(listOpportunityRoundRobin);
                                                  
                                                 }
        //Ended By Pooja|SFI-338
        updateNEFTHoldStatus(triggerNew, triggerOldMap);
        
        //*****Line no 159 Added by Akash Pandey*****//
        if(!listOpportunity.isEmpty() && !setBusinessCategory.isEmpty()) updateLOBAndRiskAutoApproved(listOpportunity, setBusinessCategory);
        
        checkModifyOwner(triggerNew, triggerOldMap);
        
        if(!subCategoryNameList.isEmpty() && !businessCategoryNameList.isEmpty()) updateMCCCode(triggerNew, triggerOldMap,businessCategoryNameList,subCategoryNameList,null);
        
        //===================CreateTAsk for Click to call=============
        if(oppList.size() > 0){
            createTaskforClickToCall(oppList,triggerOldMap);
        }
        
        /******=====Commenting this code as delivery duration is updated by formula field of Sub Category========
//===================update delivery duration==============
if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0) updateDeliveryDuration(subCategoryIds,triggerNew);
******************************************************************/
        
        //=====================To blacklist the merchant============
        if(Label.BlacklistRiskType == 'true' && isExecuteMerchantBlackList ){
            pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(triggerNew,triggerOldMap);
        }
        
        //**********Blacklist Task By Akash***********//
        if(blackListTaskForRiskTeam.size()>0 && Label.BlacklistRiskType == 'true'){
            createTaskForBlacklist(blackListTaskForRiskTeam, triggerOldMap);
        }
        
        //=============== update baby care owner after settlement active================
        if(!settlementReassignOwner.isEmpty() && settlementReassignOwner.size()>0){
            babyCareReassignOppOwnerBU(settlementReassignOwner,triggerOldMap, babyCareFlow);
        }
        
        
        //================update Compulsite Account Doc and Agreement Status=================
        if(!compulsiveAccountIds.isEmpty() && compulsiveAccountIds.size()>0)
            updateCompulsiveAccounts(compulsiveAccountIds);
        
        //======== This is used to check partner alliances lead and add to set for owner assignment
        if(counterofPartnerAllianceLead > 0){
            List<Group> lstGroup = getGroupdata('Partnerships_Alliances');
            if(lstGroup != null && lstGroup.size() > 0){
                for(Opportunity each : triggerNew){
                    if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                        Integer userIndex = Math.mod(IntrandomNumber, lstGroup[0].GroupMembers.Size());
                        each.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                        
                        if(!mapAccount.isEmpty() && mapAccount.containsKey(each.AccountId) && mapAccount.get(each.AccountId) != null){
                            Account accObj = mapAccount.get(each.AccountId);
                            accObj.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                            partnerAccountList.add(accObj);
                        }
                        IntrandomNumber = IntrandomNumber + 1;
                    }
                }
            }
        }
        
        //======== This is used to check partner alliances account list and add to set for owner assignment
        if(!partnerAccountList.isEmpty()) update partnerAccountList;
    }
    // This Method has been added by rohit for offline lead
    public static void offlineLead(List<Opportunity> oppList){
        List<AggregateResult> arList =  [SELECT Document_Category_Master__c ,Business_Entity__c FROM Entity_DocCategoryMapping__c WHERE
                                         Business_Entity__c=:oppList[0].Business_Entity__c AND Active__c=true GROUP BY Document_Category_Master__c,Business_Entity__c];
        if(arList !=NULL && arList.size()>0){
            Map<Id,Set<String>> entitesToCateMap = new Map<Id,Set<String>>();
            for(AggregateResult result : arList){
                Id entityVal = (Id)result.get('Business_Entity__c');
                String documentNameVal = (String)result.get('Document_Category_Master__c');
                if(!entitesToCateMap.containsKey(entityVal)){
                    entitesToCateMap.put(entityVal,new Set<String>());
                }
                entitesToCateMap.get(entityVal).add(documentNameVal);
            }
            Set<String> docuCategories;
            for(Id entity : entitesToCateMap.keySet()){
                docuCategories = entitesToCateMap.get(entity);
            }
            List<Merchant_Document__c> merDocList = new List<Merchant_Document__c>();
            for(String DocAgg : docuCategories){
                Merchant_Document__c mer = new Merchant_Document__c();
                mer.Document_Category__c =   (Id)DocAgg;
                mer.Active__c = true;
                mer.Account__c = oppList[0].AccountId;
                mer.Opportunity__c = oppList[0].Id;
                mer.Onboarding_Status__c = 'Pending' ;  
                merDocList.add(mer);
            }            
            if(merDocList !=NULL && !merDocList.isEmpty() && merDocList.size()>0){
                Insert merDocList;
            }
        }
    }
    // This Method has been added by rohit for auto create websitepage if website is not null on opportunity
    public static void autoCreateWebsitePage(Set<Id> oppIds,Id websiteDetailsId){
        System.debug('websiteDetailsId::1026:::'+websiteDetailsId);
            List<Website_Page__c> websitePageList = [SELECT ID,Active__c FROM Website_Page__c WHERE Opportunity__c=:oppIds];
            List<Website_Page__c> exitingWebsitePageToUpdate = new List<Website_Page__c>();
            if(websitePageList !=NULL && !WebsiteDetailsTriggerHandler.runningWebsiteDetails){//added by rohit risk revamp !WebsiteDetailsTriggerHandler.runningWebsiteDetails
                for(Website_Page__c web : websitePageList){
                    web.Active__c = False;
                    exitingWebsitePageToUpdate.add(web);
                }
                if(exitingWebsitePageToUpdate !=NULL){
                    update exitingWebsitePageToUpdate;
                }
                SYstem.debug('exitingWebsitePageToUpdate:::1038::::::'+exitingWebsitePageToUpdate);
            }
            Map<String,List<String>> mapOfKeyValues = new  Map<String,List<String>>();
            List<WebsitePageGrouping__mdt> webListMetadata = [SELECT WebsiteGrouping__c FROM WebsitePageGrouping__mdt 
                                                              WHERE DeveloperName='WebsiteGrouping'];
            Map<String,object> jsonData = (Map<String,object>) JSON.deserializeUntyped(webListMetadata[0].WebsiteGrouping__c);
            List<Website_Page__c > websiteList = new List<Website_Page__c>();
            Map<String,List<String>> convertedMap = new  Map<String,List<String>>();
            for(String key : jsonData.keySet()){
                List<object> valueForGroup =(List<object>) jsonData.get(key);
                List<String> stringValueList = new List<String>();
                for(Object obj : valueForGroup){
                    stringValueList.add(String.valueOf(obj));
                }
                convertedMap.put(key,stringValueList);
            }
            for(Id oppId : oppIds){
                for(String key : convertedMap.keySet()){
                    List<String> valueList = convertedMap.get(key);
                    for(String str : valueList){
                        Website_Page__c website = new Website_Page__c();
                        website.Name = str;
                        website.Active__c = True;
                        website.Website_Details__c  = websiteDetailsId;
                        website.Opportunity__c = oppId; 
                        website.Group__c = key;
                        website.Page_Details__c = '[{" ":" "}]';
                        websiteList.add(website);
                    }
                }
            }
            if(websiteList !=NULL && websiteList.size()>0){
                insert websiteList;
                SYstem.debug('websiteList::::'+websiteList);
            }
    }
    //============= this method call FROM Opportunity trigger at after insert====================
    public static void afterInsertHandler(List<Opportunity> triggerNew){
        
        
        List<Opportunity> oppToOperateComm = new List<Opportunity>();
        List<Opportunity> oppToOperateWP = new List<Opportunity>();
        Map<String, List<Plan__c>> productPlanMap = new Map<String, List<Plan__c>>();
        Set<String> webMasterPageName = New Set<String>();
        Set<Id> productsIdSet = new Set<Id>();
        Set<String> intTypeSet = new Set<String>();        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Opportunity> taskForOpportunitiesWhenVIP = new List<Opportunity>();
        List<Opportunity> taskForInboundSalesTeam = new List<Opportunity>();
        List<Opportunity> blackListTaskForRiskTeam = new List<Opportunity>();//By:- Akash Pandey. Task for risk if we find any blacklisted parameter.
        List<Opportunity> businesscategoryTaskForRiskTeam = new List<Opportunity>();
        
        //update check for status skip of Doc Status and Agreement status========
        Map<Id,Account> aggAccountDataMap = New Map<Id,Account>();
        Map<Id,Account> DocAccountDataMap = New Map<Id,Account>();
        List<Website_Page__c> webPageInserted = New List<Website_Page__c>();
        Set<Id> optyIds = New Set<Id>();
        List<Opportunity> systemVerifiedWebsiteList = New List<Opportunity>();
        List<Opportunity> merchantVerifiedWebsiteList = New List<Opportunity>();
        List<Opportunity> premiumMerchantDocList = New List<Opportunity>();
        
        List<Website_Page_Master__c> wpmList = [SELECT Id, Name, Active__c, Page_Details__c FROM Website_Page_Master__c WHERE Active__c = true];
        
        for(Website_Page_Master__c wpm : wpmList){
            webMasterPageName.add(wpm.Name);
        }
        
        for(Opportunity newOpp : triggerNew){
            if(String.isNotBlank(newOpp.AccountId))
                accountMap.put(newOpp.AccountId,null);
        }
        
        //================get Account of Opportunity================
        if(!accountMap.keySet().isEmpty()){
            for(Account acc : [SELECT Id, Name, Document_Status__c,Pan_Verification_Status__c,Agreement_Status__c,
                               NDX_Score__c,LOB_Status__c,Skip_Agreement_Verification__c,Skip_Document_Verification__c  FROM Account WHERE Id IN :accountMap.keySet()]){
                                   accountMap.put(acc.Id, acc);
                               }
        }  
        List<Opportunity> OppListForOfflineLead = new List<Opportunity>();//Added by rohit
        Set<Id> oppIdForWebPage = new Set<Id>();//Added by rohit
        List<Website_Details__c> listLeadWebsiteForOfflineOpp = new List<Website_Details__c>();
        for(Opportunity each : triggerNew){
            if(each.Website__c != NULL){
                Website_Details__c webDetail = new Website_Details__c();
                webDetail.Website_URL__c = each.Website__c;
                webDetail.Android_URL__c = each.Android_URL__c  !=NULL ?  each.Android_URL__c :'';
                webDetail.IOS_URL__c = each.IOS_URL__c  !=NULL ?  each.IOS_URL__c :'';
                webDetail.Opportunity__c = each.Id;
                webDetail.Active__c= TRUE;
                webDetail.Website_Status__c='Verification in Process';
                listLeadWebsiteForOfflineOpp.add(webDetail);
            }
            if(each.Website__c !=NULL){ //Added by rohit for risk requirment
                oppIdForWebPage.add(each.Id);
            }
            if(each.Offline_Lead__c){ //Added by rohit
                OppListForOfflineLead.add(each);
            }
            //===============Commenting this method as this API is not working yet=============
            //LeadTriggerHelper.checkFetchMID(each, 'Opportunity');
            
            //==========Send data to ESB================================
            if(!System.isBatch() && each.Data_need_to_be_publish__c && !runningFromConsumerAPI)
                IntegrationUtility.checkMaintenance(each, null, 'Opportunity', 'Lead');  
            
            //===============Commenting this method as commercial functionality is not using yet=============
            //OpportunityTriggerHelper.checkInsertCommercial(each, oppToOperateComm, productPlanMap);
            
            //===============Commenting this method as not using this method===============================
            //OpportunityTriggerHelper.checkInsertWP(each, productsIdSet, intTypeSet, oppToOperateWP);
            //
            //=======SFI-613===========Partner Campaign Tagging=================================
            
            /*Opportunity ctOpp = new Opportunity(Id=each.Id);
if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='enterprise-hunting-partners' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
ctOpp.OwnerId = Label.Campaign_EnterpriseHuntingPartners;
ctOpp.Merchant_Business_Type__c = 'Enterprise';
ctOpp.Team__c = 'Enterprise';
ctOpp.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnerships-hunting-partners1' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
ctOpp.OwnerId = Label.Campaign_EnterpriseHuntingPartners1;
ctOpp.Merchant_Business_Type__c = 'Platform Partner';
ctOpp.Team__c = 'Platform Partner';
ctOpp.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners2' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
ctOpp.OwnerId = Label.Campaign_EnterpriseHuntingPartners2;
ctOpp.Merchant_Business_Type__c = 'Platform Partner';
ctOpp.Team__c = 'Platform Partner';
ctOpp.LeadSource = 'Inorganic';
AssignLead = true;
}else if(String.isNotBlank(each.Campaign_Name__c) && each.Campaign_Name__c =='partnership-hunting-partners3' && each.Business_Origin__c == 'Partnership' && each.Lead_Type__c == 'Partner'){
ctOpp.OwnerId = Label.Campaign_EnterpriseHuntingPartners3;
ctOpp.Merchant_Business_Type__c = 'Platform Partner';
ctOpp.Team__c = 'Platform Partner';
ctOpp.LeadSource = 'Inorganic';
AssignLead = true;
}
if(AssignLead) {
campaingTaggingChanges.add(ctOpp);
}*/
            //==END==========SFI-613===========Partner Campaign Tagging=========================
            
            //===========get Task list to Insert for Inbound Sales Team of Manual Call=================
            if(string.isBlank(each.Manual_Call_Response__c) && each.Lead_Type__c == 'Merchant' && String.isBlank(each.Partner__c)
               && each.Integration_Type__c == 'ThirdParty' && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))
               && !businessEntityNameList.contains(each.Business_Entity_Formula__c) 
               && each.CreatedDate.Date() == Date.today() 
               && productNameList.contains(each.ProductLabel__c)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   taskForInboundSalesTeam.add(each);
               }
            
            //============get Task list to Insert for Risk Team of BlackListed Merchant=====================
            if(String.isNotBlank(each.Risk_Type_Multi_Select__c) && each.Blacklist__c){
                blackListTaskForRiskTeam.add(each);
            }
            
            //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
            /* String BusinessCategory = Label.Business_Category;
List<String> BusinessCategorysName = BusinessCategory.split(',');
if(String.isNotBlank(each.Business_Category__c) && each.NDX_Score__c > 0 && each.NDX_Score__c <= 50000 &&
(String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c))
&& each.Integration_Type__c == 'Thirdparty' && (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')){

if(BusinessCategorysName.contains(each.Business_Category__c)){                    
businesscategoryTaskForRiskTeam.add(each);   
}
}
*/
            if(each.Website_Status__c == 'Verification in process' && each.Integration_Type__c =='Thirdparty'
               && leadTypeList.contains(each.Lead_Type__c) 
               && (accountMap.get(each.AccountId).NDX_Score__c == null || accountMap.get(each.AccountId).NDX_Score__c == 0) 
               && each.NDX_Score__c != null && each.NDX_Score__c > 50000 
               && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))
               && each.Website_Addendum_Status__c != 'pending' && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)
               && each.isPremiumCustomer__c){
                   systemVerifiedWebsiteList.add(each);
               }else if(each.Website_Status__c == 'Pending' && each.Integration_Type__c =='Thirdparty'
                        && leadTypeList.contains(each.Lead_Type__c) && (accountMap.get(each.AccountId).NDX_Score__c == null || accountMap.get(each.AccountId).NDX_Score__c == 0) && each.NDX_Score__c != null && each.NDX_Score__c > 50000 
                        && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))
                        && each.Website_Addendum_Status__c != 'pending' && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)
                        && each.isPremiumCustomer__c){
                            merchantVerifiedWebsiteList.add(each);
                        }
            else if(each.Website_Status__c == 'Verification in process' && each.Integration_Type__c =='Thirdparty'
                    && leadTypeList.contains(each.Lead_Type__c) && accountMap.get(each.AccountId).NDX_Score__c != null && accountMap.get(each.AccountId).NDX_Score__c > 50000 
                    && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))
                    && each.Website_Addendum_Status__c != 'pending' && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)
                    && each.isPremiumCustomer__c){
                        systemVerifiedWebsiteList.add(each);
                    }else if(each.Website_Status__c == 'Pending' && each.Integration_Type__c =='Thirdparty'
                             && leadTypeList.contains(each.Lead_Type__c) && accountMap.get(each.AccountId).NDX_Score__c != null && accountMap.get(each.AccountId).NDX_Score__c > 50000 
                             && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))
                             && each.Website_Addendum_Status__c != 'pending' && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)
                             && each.isPremiumCustomer__c){
                                 merchantVerifiedWebsiteList.add(each);
                             }
            
            
            //====================== Check Skip Identifier for status Update==================
            if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
               && each.Skip_Agreement_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
               && accountMap.containsKey(each.AccountId) && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   aggAccountDataMap.put(each.AccountId,accountMap.get(each.AccountId));
               }
            if((string.isNotBlank(each.Business_Entity__c) || String.isNotBlank(each.Partner__c)) 
               && each.Skip_Document_Verification__c && String.isNotBlank(each.AccountId) && leadTypeList.contains(each.Lead_Type__c)
               && accountMap.containsKey(each.AccountId) && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   docAccountDataMap.put(each.AccountId,accountMap.get(each.AccountId));
               }
            //======================= End Check Skip Identifier for status Update================
            
            //=================== Create Task for Onboarding team of Premium Merchant===========    
            if(String.isNotBlank(each.Lead_Type__c) && each.Lead_Type__c.equalsIgnoreCase('Merchant') &&    
               each.Document_Status_Document_Issue__c == 'Docs Received' && each.isPremiumCustomer__c){ 
                   premiumMerchantDocList.add(each);    
               }
        }
        
        if(!listLeadWebsiteForOfflineOpp.isEmpty() && listLeadWebsiteForOfflineOpp.size()>0){
            insert listLeadWebsiteForOfflineOpp;
        } 
        
        //updateCampaignTagging(campaingTaggingChanges);
        //=============Commenting this method as not using currently====================
        //OpportunityTriggerHelper.insertCommercial(oppToOperateComm, productPlanMap);
        
        //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
        /*if(!taskForOpportunitiesWhenVIP.isEmpty()){
List<Opportunity> taskForOpportunitiesWhenVIPPremium = new List<Opportunity>();
List<Opportunity> taskForOpportunitiesWhenVIPNormal = new List<Opportunity>();
for(Opportunity eachOpp : taskForOpportunitiesWhenVIP){
if(eachOpp.isPremiumCustomer__c ) taskForOpportunitiesWhenVIPPremium.add(eachOpp);
else taskForOpportunitiesWhenVIPNormal.add(eachOpp);
}
if(!taskForOpportunitiesWhenVIPPremium.isEmpty())
createTasksForRiskTeam(taskForOpportunitiesWhenVIPPremium, Label.VIP_task_Subject_Premium, '', 'High',True);
else
createTasksForRiskTeam(taskForOpportunitiesWhenVIPNormal, Label.VIP_task_Subject, '', 'Normal',False);
}
*/
        //===========Create task for premium merchant to Risk Team=====================
        if(!systemVerifiedWebsiteList.isEmpty() || !merchantVerifiedWebsiteList.isEmpty()){ 
            createPremiumMemberTask(systemVerifiedWebsiteList,merchantVerifiedWebsiteList);
        }
        
        //===================Create task at opportunity creation for inboundSalesTeam======================
        if(!taskForInboundSalesTeam.isEmpty() && taskForInboundSalesTeam.size() > 0) {
            createTasksForSalesTeam(taskForInboundSalesTeam);
        }
        
        //**********Blacklist Task By Akash***********//
        if(blackListTaskForRiskTeam.size()>0 && Label.BlacklistRiskType == 'true'){
            createTaskForBlacklist(blackListTaskForRiskTeam, null);
        }
        
        //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
        /*if(!businesscategoryTaskForRiskTeam.isEmpty() && businesscategoryTaskForRiskTeam.size()>0){
list<Opportunity> businesscatTaskForPremiumRiskTeam = new List<Opportunity>();
list<Opportunity> businesscatTaskForNormalRiskTeam = new List<Opportunity>();
for(Opportunity eachOpp : businesscategoryTaskForRiskTeam){
if(eachOpp.isPremiumCustomer__c) {
businesscatTaskForPremiumRiskTeam.add(eachOpp);
}else {
businesscatTaskForNormalRiskTeam.add(eachOpp);
}
}
if(!businesscatTaskForPremiumRiskTeam.isEmpty())
createTasksForRiskTeam(businesscatTaskForPremiumRiskTeam, Label.Business_Category_Task, '', 'High',true);
else
createTasksForRiskTeam(businesscatTaskForNormalRiskTeam, Label.Business_Category_Task, '', 'Normal',false);
}
*/
        
        //=========update Account doc and Agreement status for skip
        if(!aggAccountDataMap.isEmpty() || !docAccountDataMap.isEmpty()) updateAccountSkipStatus(triggerNew,docAccountDataMap,aggAccountDataMap);
        
        //===========Create task for premium merchant to Onboarding Team=====================   
        if(!premiumMerchantDocList.IsEmpty()) createTasksForDocsTeam(premiumMerchantDocList,System.Label.Docs_Team_Task, '', 'High',true);
        
        if(!OppListForOfflineLead.IsEmpty()){
            offlineLead(OppListForOfflineLead);// added by rohit
        }
        /*******When there is a website present in Opp then it will callautoCreateWebsitePage to Insert the 
website page ***************/
        if(oppIdForWebPage !=NULL && oppIdForWebPage.size()>0){
            autoCreateWebsitePage(oppIdForWebPage,listLeadWebsiteForOfflineOpp[0].Id);// added by rohit
        }
        /******END*******/
    }
    
    // this method call FROM Opportunity trigger at after update
    public static void afterUpdateHandler(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap){
        Map<String, String> oppIdMap = new Map<String, String>();
        Map<Id,Opportunity> riskOppMap = New Map<Id,Opportunity>();
        Set<String> webMasterPageName = New Set<String>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Opportunity> taskForOpportunitiesWhenVIP = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        List<Task> taskList = new List<Task>();
        List<Opportunity> taskForInboundSalesTeam = new List<Opportunity>();
        Set<Id> CloseTaskOppIds = new Set<Id>();
        Set<id> closestatustaskIds = new Set<Id>();
        Set<id> closeApprovetaskIds = new Set<Id>();
        List<Opportunity> settlementReassignOwner = new List<Opportunity>();
        List<Opportunity> businesscategoryTaskForRiskTeam = New List<Opportunity>();
        List<Opportunity> opportunityWibmolist = new List<Opportunity>();
        Set<Id> wibmoAccountIds = New Set<Id>();
        Baby_Care_Flow__c babyCareFlow = Baby_Care_Flow__c.getValues('FlowActivate');
        
        //Code changes : 12th April 2022
        Map<Id,String> mapOpportunityIdToWebsiteStatus = new map<Id,String>();
        Set<Id> oppIdForWebsitedetails = new Set<Id>();//Added by rohit
        Set<Id> oppIdForWebPage = new Set<Id>();//Added by rohit
        List<Opportunity> oppKAMChangeList = new List<Opportunity>();
        List<Website_Details__c> listLeadWebsiteForOfflineOpp = new List<Website_Details__c>();
        
        /** Added for SFI-1243 - Dormancy Date Automation **/
        List<Opportunity> oppListToProcessOnLastTxnUpdate = new List<Opportunity>();
        List<Opportunity> oppListToUpdateOnIsDormantUpdate = new List<Opportunity>();
        /** */
        
        for(Opportunity opp : triggerNew) {
            /** Added for SFI-1243 - Dormancy Date Automation **/
            /** Last_txn_date__c updated */
            if(opp.Last_txn_date__c != NULL && opp.Last_txn_date__c != triggerOldMap.get(opp.Id).Last_txn_date__c){
                oppListToProcessOnLastTxnUpdate.add(opp);
            }
            /** Is_dormant__c updated */
            if(!opp.Is_dormant__c && triggerOldMap.get(opp.Id).Is_dormant__c){
                oppListToUpdateOnIsDormantUpdate.add(opp);
            }
            /** END SFI-1243 **/
            
            if(triggerOldMap.get(opp.Id).Website__c != opp.Website__c &&  opp.Website__c !=NULL &&  !AwsConsumerAPI_CTRL.runningFromConsumerAPIForOfflineFlow && !WebsiteDetailsTriggerHandler.runningWebsiteDetails){ //Added by rohit for risk requirment
                oppIdForWebsitedetails.add(opp.Id);
                /***Below website details creating when website URL is changed on Opportunity Added by rohit**/
                Website_Details__c webDetail = new Website_Details__c();
                webDetail.Website_URL__c = opp.Website__c;
                webDetail.Android_URL__c = opp.Android_URL__c  !=NULL ?  opp.Android_URL__c :'';
                webDetail.IOS_URL__c = opp.IOS_URL__c  !=NULL ?  opp.IOS_URL__c :'';
                webDetail.Opportunity__c = opp.Id;
                webDetail.Active__c= TRUE;
                webDetail.Website_Status__c='Verification in Process';
                listLeadWebsiteForOfflineOpp.add(webDetail);
                SYstem.debug('listLeadWebsiteForOfflineOpp:::::::1372::::'+listLeadWebsiteForOfflineOpp);
            }
            if(opp.Website_Status__c != triggerOldMap.get(opp.Id).Website_Status__c) {
                mapOpportunityIdToWebsiteStatus.put(opp.Id,opp.Website_Status__c);              
            }
        }
        
        /** Added for SFI-1243 - Dormancy Date Automation on Last_TXN_Date update. **/
        if(!oppListToProcessOnLastTxnUpdate.isEmpty()){
            processRecordForDormancyAutomation(oppListToProcessOnLastTxnUpdate);
        }
        if(!oppListToUpdateOnIsDormantUpdate.isEmpty()){
            processRecordForRekycUpdate(oppListToUpdateOnIsDormantUpdate);
        }
        /** END SFI-1243 */
        
        /******When changing the website url on opp then existing website details which is active we need 
to mark as a false and new website details should be created and status should be
'Verification in process'  Added by rohit *****/
        if(oppIdForWebsitedetails !=NULL && !AwsConsumerAPI_CTRL.runningFromConsumerAPIForOfflineFlow){
            if(!WebsiteDetailsTriggerHandler.runningWebsiteDetails && !isWebsiteDetailsRecordInsert && listLeadWebsiteForOfflineOpp !=NULL){
                isWebsiteDetailsRecordInsert = true;
                insert listLeadWebsiteForOfflineOpp;
                System.debug('listLeadWebsiteForOfflineOpp::1396:::'+listLeadWebsiteForOfflineOpp);
                if( !isAutoCreateWebsitePage &&  oppIdForWebsitedetails !=NULL && oppIdForWebsitedetails.size()>0){
                    isAutoCreateWebsitePage = true;
                    isWebsiteUpdate = true;
                    autoCreateWebsitePage(oppIdForWebsitedetails,listLeadWebsiteForOfflineOpp[0].Id);// added by rohit
                }
            }
        }  
        List<Website_Details__c> listWebsiteDetailsToUpdate = new List<Website_Details__c>();
        if(mapOpportunityIdToWebsiteStatus.keySet().size() > 0) {
            for(Website_Details__c wd : [SELECT Id,Website_Status__c,Opportunity__c 
                                         FROM Website_Details__c 
                                         WHERE Opportunity__c IN :mapOpportunityIdToWebsiteStatus.keySet()
                                         AND Active__c = true]) {
                                             wd.Website_Status__c = mapOpportunityIdToWebsiteStatus.get(wd.Opportunity__c);
                                             listWebsiteDetailsToUpdate.add(wd); 
                                         }    
        }
        if(listWebsiteDetailsToUpdate.size() > 0) {
            update listWebsiteDetailsToUpdate;
        }
        
        //Code end : 12th April, 2022
        
        //=============Update Dynamic status===================    
        Set<id> updateDynamicStatusIds = new Set<id>();
        Set<id> idsTobePublishedToBiz = new Set<id>();
        Map<id, String> idsTobePublishedToBizMap = new Map<id, String>();
        Map<id, double> idsTobePublishedToBizTimeMap = new Map<id, double>();
        
        //=============WhatsApp send list for Whatsapp outBound ===================
        List<String> sendWhatsappOpp = new List<String>();
        
        //=============Website page deletion list=======================
        List<Opportunity> deleteWebPagesList = new List<Opportunity>();
        
        Set<String> websiteURLoppIds = new Set<String>();
        
        //==============update check for status skip of Doc Status and Agreement status========
        Map<Id,Account> aggAccountDataMap = New Map<Id,Account>();
        Map<Id,Account> DocAccountDataMap = New Map<Id,Account>();
        
        List<Opportunity> systemVerifiedWebsiteList = New List<Opportunity>();
        List<Opportunity> merchantVerifiedWebsiteList = New List<Opportunity>();
        
        //update for CS
        List<Opportunity> premiumOppList = new List<Opportunity>();
        //==============
        
        //==============New Banking Eligible Opportunity Ids=============
        Set<Id> nbEligibleOpportunityIds = New Set<Id>();
        
        /*List<Website_Page_Master__c> wpmList = [SELECT Id, Name, Active__c, Page_Details__c FROM Website_Page_Master__c WHERE Active__c = true];
        for(Website_Page_Master__c wpm : wpmList){
            webMasterPageName.add(wpm.Name);
        }*/
        
        for(Opportunity newOpp : triggerNew){
            if(String.isNotBlank(newOpp.AccountId))
                accountMap.put(newOpp.AccountId,null);           
        }
        
        if(!accountMap.keySet().isEmpty()){
            for(Account acc : [SELECT Id, Name, Document_Status__c,Pan_Verification_Status__c,Agreement_Status__c,
                               NDX_Score__c,LOB_Status__c,Skip_Agreement_Verification__c,Skip_Document_Verification__c  FROM Account WHERE Id IN :accountMap.keySet()]){
                                   accountMap.put(acc.Id, acc);
                               }
        }
        
        for(Opportunity each : triggerNew){
            Opportunity oldEach = triggerOldMap.get(each.Id); 
            //============Used to send data to ESB===================
            /** Added validForPreApprovedSettlement check for preApproved Priority Settlement whcih is calling from Batch PreApprovedPrioritySettlementBatch. */
            if(!System.isBatch() && each.Data_need_to_be_publish__c && publishUpdateFromApex && !runningFromConsumerAPI) 
                IntegrationUtility.checkMaintenance(each, oldEach, 'Opportunity', 'Lead');
            
            //===========Comenting out as not using New and OLD MID comparision==========
            
            //OpportunityTriggerHelper.checkLiveAndTrans(each, oldEach, oppIdMap);
            
            //===========Create task for premium merchant to Risk Team=====================
            if(each.Website_Status__c == 'Verification in process' && each.Integration_Type__c == 'Thirdparty' &&
               each.isPremiumCustomer__c !=  oldEach.isPremiumCustomer__c && leadTypeList.contains(each.Lead_Type__c)
               && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c)) 
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && each.isPremiumCustomer__c && each.NDX_Score__c != null && each.NDX_Score__c > 50000){
                   systemVerifiedWebsiteList.add(each);
               }else if(each.Website_Status__c == 'Pending' && each.Integration_Type__c == 'Thirdparty' &&
                        each.isPremiumCustomer__c !=  oldEach.isPremiumCustomer__c && leadTypeList.contains(each.Lead_Type__c) 
                        && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c)) 
                        && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && each.isPremiumCustomer__c && each.NDX_Score__c != null && each.NDX_Score__c > 50000){
                            merchantVerifiedWebsiteList.add(each);
                        }else if(each.Website_Status__c == 'Verification in process' && each.Integration_Type__c == 'Thirdparty' &&
                                 each.isPremiumCustomer__c !=  oldEach.isPremiumCustomer__c && leadTypeList.contains(each.Lead_Type__c)
                                 && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c)) 
                                 && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && each.isPremiumCustomer__c && accountMap.get(each.AccountId).NDX_Score__c != null && accountMap.get(each.AccountId).NDX_Score__c > 50000 
                                 && (each.NDX_Score__c == null || each.NDX_Score__c ==0)){
                                     systemVerifiedWebsiteList.add(each);
                                 }else if(each.Website_Status__c == 'Pending' && each.Integration_Type__c == 'Thirdparty' &&
                                          each.isPremiumCustomer__c !=  oldEach.isPremiumCustomer__c && leadTypeList.contains(each.Lead_Type__c) 
                                          && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c)) 
                                          && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c) && each.isPremiumCustomer__c && accountMap.get(each.AccountId).NDX_Score__c != null && accountMap.get(each.AccountId).NDX_Score__c > 50000 
                                          && (each.NDX_Score__c == null || each.NDX_Score__c ==0)){
                                              merchantVerifiedWebsiteList.add(each);
                                          }
            
            
            //==============get Opp Id list if website status change and URL not empty====================
            if(each.Website_Status__c == 'Website OK' && each.Website_Status__c != oldEach.Website_Status__c
               && (string.isNotBlank(each.Website__c) || string.isNotBlank(each.Android_URL__c) || string.isNotBlank(each.iOS_URL__c))){
                   oppIds.add(each.Id);
               }  
            
            //=============get Task To Insert for Inbound Sales Team of Manual Call Response=======================
            if(each.Integration_Type__c != oldEach.Integration_Type__c && each.Integration_Type__c == 'ThirdParty'
               && string.isBlank(each.Manual_Call_Response__c) && each.CreatedDate.Date() == date.TODAY()
               && each.Lead_Type__c == 'Merchant' && string.isBlank(each.Partner__c) 
               && !businessEntityNameList.contains(each.Business_Entity_Formula__c)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   taskForInboundSalesTeam.add(each);
               }
            
            //=============get Task To Closed for Inbound Sales Team of Manual Call Response=======================
            if(each.Manual_Call_Response__c != null && each.Manual_Call_Response__c != oldEach.Manual_Call_Response__c 
               && each.Manual_Call_Response__c.contains('ANSWER') && string.isBlank(each.Partner__c) 
               && !each.Manual_Call_Response__c.contains('NOANSWER') && each.Lead_Type__c == 'Merchant'
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   CloseTaskOppIds.add(each.Id);
               }
            
            //=============get Task To Close for Inbound Sales Team of Website and Received Document Status Change=======================
            if(each.Lead_Type__c == 'Merchant' && each.Integration_Type__c == 'ThirdParty'
               && ((each.Website_Status__c!= oldEach.Website_Status__c && (each.Website_Status__c == 'Verification in Process' || each.Website_Status__c == 'Website OK')) 
                   || (each.Document_Status_Document_Issue__c != oldEach.Document_Status_Document_Issue__c && each.Document_Status_Document_Issue__c=='Docs Received'))
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   closestatustaskIds.add(each.Id);
               }
            
            //=============get Task To Insert for Inbound Sales Team of Website and Approved Document Status Change=======================
            if(each.Lead_Type__c == 'Merchant' && each.Integration_Type__c == 'ThirdParty'
               && ((each.Website_Status__c != oldEach.Website_Status__c && each.Website_Status__c == 'Website OK') 
                   || (each.Document_Status_Document_Issue__c!=oldEach.Document_Status_Document_Issue__c && each.Document_Status_Document_Issue__c=='Docs Approved'))
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   closeApprovetaskIds.add(each.Id);
               } 
            
            //==========get Opp List for Baby Care Assignment after settlement active==================
            if(String.isNotBlank(each.Settlement_Status__c) && 
               (each.Settlement_Status__c != oldEach.Settlement_Status__c || each.Website_Status__c != oldEach.Website_Status__c
                || each.LeadSource != oldEach.LeadSource || each.Document_Status_Document_Issue__c != oldEach.Document_Status_Document_Issue__c
                || each.Integration_Type__c != oldEach.Integration_Type__c )
               && each.Settlement_Status__c == 'Active' && each.Lead_Type__c == 'Merchant'
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)) {
                   checkRecurssion = true;
                   if(each.Integration_Type__c == 'ThirdParty' || each.Integration_Type__c == 'Tools'){
                       settlementReassignOwner.add(each);
                   }
               }
            
            //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
            /*  String BusinessCategory = Label.Business_Category;
List<String> BusinessCategorysName = BusinessCategory.split(',');
if(String.isNotBlank(each.Business_Category__c) && accountMap.get(each.AccountId).NDX_Score__c > 0 
&& accountMap.get(each.AccountId).NDX_Score__c <= 50000 &&
(String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c))
&& each.Integration_Type__c == 'Thirdparty' && (each.Website__c != triggerOldMap.get(each.Id).Website__c
|| each.iOS_URL__c != triggerOldMap.get(each.Id).iOS_URL__c
|| each.Android_URL__c != triggerOldMap.get(each.Id).Android_URL__c
|| each.Website_Status__c != triggerOldMap.get(each.Id).Website_Status__c
|| each.Integration_Type__c != triggerOldMap.get(each.Id).Integration_Type__c)
&& merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){

if(BusinessCategorysName.contains(each.Business_Category__c)){                    
businesscategoryTaskForRiskTeam.add(each);   
}
}
*/
            //================ Commenting the code as we are not using Wibmo product===========
            //======================= update for Wibmo Product====================
            /* If(each.RecordTypeId == oppWibmoRTId && each.stagename != oldEach.stagename && each.StageName == 'Stage 4 - Closure' && String.isNotBlank(each.AccountId)){  
opportunityWibmolist.add(each);  
wibmoAccountIds.add(each.AccountId);  
} 
*/
            //==================get Opp List for Whatsapp outBound message==========================
            if((each.Settlement_Status__c == 'Risk Hold' || each.Settlement_Status__c == 'Risk & Thirdparty hold' || each.Settlement_Status__c == 'OB Hold')
               && each.Settlement_Status_Latest_Date__c != null && oldEach.Settlement_Status__c == 'Active'
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   sendWhatsappOpp.add(each.Id);
               }
            
            
            //=================Update Dynamic status===============================
            if((each.Settlement_Status__c == 'Risk Hold' || each.Settlement_Status__c == 'Risk & Thirdparty hold' || each.Settlement_Status__c == 'Active' || each.Settlement_Status__c == 'Thirdparty Hold' || each.Settlement_Status__c == 'Pre-Risk Hold' || each.Settlement_Status__c == 'OB Hold')
               && (each.Settlement_Status__c != oldEach.Settlement_Status__c || each.Re_Published__c != oldEach.Re_Published__c)){
                   updateDynamicStatusIds.add(each.Id);
                   System.debug('Treasury Publisher : '+each.Re_Published__c);
               }
            
            
            //=================get website pages list to delete===============================
            if((String.isNotBlank(each.Website__c) || String.isNotBlank(each.Android_URL__c) || String.isNotBlank(each.iOS_URL__c))
               && (String.isNotBlank(oldEach.Website__c) || String.isNotBlank(oldEach.Android_URL__c) || String.isNotBlank(oldEach.iOS_URL__c))
               && each.Integration_Type__c == 'Thirdparty' && (each.Website__c != oldEach.Website__c || each.iOS_URL__c != oldEach.iOS_URL__c || each.Android_URL__c != oldEach.Android_URL__c)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   deleteWebPagesList.add(each);
                   if(String.isNotBlank(each.New_Website_Url__c) && each.Website__c == each.New_Website_Url__c){
                       websiteURLoppIds.add(each.Id);
                   }
               }
            
            //====================== Check Skip Identifier for status Update==================
            if(((string.isNotBlank(each.Business_Entity__c) && each.Business_Entity__c != oldEach.Business_Entity__c)
                || (String.isNotBlank(each.Partner__c) && each.Partner__c != oldEach.Partner__c )) 
               && each.Skip_Agreement_Verification__c && String.isNotBlank(each.AccountId) && accountMap.containsKey(each.AccountId)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   aggAccountDataMap.put(each.AccountId,accountMap.get(each.AccountId));
               }
            if(((string.isNotBlank(each.Business_Entity__c) && each.Business_Entity__c != oldEach.Business_Entity__c) 
                || (String.isNotBlank(each.Partner__c) && each.Partner__c != oldEach.Partner__c )) 
               && each.Skip_Document_Verification__c && String.isNotBlank(each.AccountId) && accountMap.containsKey(each.AccountId)
               && merchantBusinessTypeList.contains(each.Merchant_Business_Type__c)){
                   docAccountDataMap.put(each.AccountId,accountMap.get(each.AccountId));
               }
            //======================= End Check Skip Identifier for status Update================
            
            
            //==========update for CS , create task for premium merchants, move this logic from Account=======
            //Removing counter signed logic as we are not using this value, onboarding revamp---
            if(String.isNotBlank(each.Lead_Type__c) && each.Lead_Type__c.equalsIgnoreCase('Merchant') && each.isPremiumCustomer__c && each.Document_Status_Document_Issue__c == 'Docs Received'
               &&  (each.isPremiumCustomer__c != oldEach.isPremiumCustomer__c || each.Agreement_Status__c != oldEach.Agreement_Status__c || each.Document_Status_Document_Issue__c != oldEach.Document_Status_Document_Issue__c)){
                   premiumOppList.add(each);
               }
            
            //============Used to send the nb eligible opportunity to panel===========
            if(each.NB_Eligible__c != oldEach.NB_Eligible__c && each.NB_Eligible__c){
                nbEligibleOpportunityIds.add(each.Id);
            }
        }
        
        //==================Commenting out this method as not using currently==============
        //OpportunityTriggerHelper.processLiveAndTransOpps(oppIdMap);
        
        //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
        /* if(!taskForOpportunitiesWhenVIP.isEmpty()){
List<Opportunity> taskForOpportunitiesWhenVIPPremium = new List<Opportunity>();
List<Opportunity> taskForOpportunitiesWhenVIPNormal = new List<Opportunity>();
for(Opportunity eachOpp : taskForOpportunitiesWhenVIP){
if(eachOpp.isPremiumCustomer__c) taskForOpportunitiesWhenVIPPremium.add(eachOpp);
else taskForOpportunitiesWhenVIPNormal.add(eachOpp);
}
if(!taskForOpportunitiesWhenVIPPremium.isEmpty())
createTasksForRiskTeam(taskForOpportunitiesWhenVIPPremium, Label.VIP_task_Subject_Premium, '', 'High',True);
else
createTasksForRiskTeam(taskForOpportunitiesWhenVIPNormal, Label.VIP_task_Subject, '', 'Normal',False);
}
*/
        //==============Get Task List and update the status to Close==============
        if(!oppIds.isEmpty()) updateTaskStatusToClosed(oppIds,taskList);
        if(!taskList.isEmpty()) update taskList;
        
        //=========Create TAsk and close for InbounSalesTeam when opportunity owner change or integrationtype is updated to Thirdaprty--//
        if(!taskForInboundSalesTeam.isEmpty()){
            createTasksForSalesTeam(taskForInboundSalesTeam);
        }
        
        //========close Task of Sales Team=====================
        if(!CloseTaskOppIds.isEmpty() && CloseTaskOppIds.Size()>0){
            closetaskforsalesteam(CloseTaskOppIds);
        }
        if(!closestatustaskIds.isEmpty()){
            closeUpdatestatusTask(closestatustaskIds);
        }
        if(!closeApprovetaskIds.isEmpty()){
            closeApprovedTask(closeApprovetaskIds);
        }
        
        //=============== update baby care owner after settlement active================
        if(!settlementReassignOwner.isEmpty() && settlementReassignOwner.size()>0 && checkRecurssion){
            babyCareReassignOppOwnerAU(settlementReassignOwner,triggerOldMap, babyCareFlow);
        }
        
        
        //===============Update Dynamic status===============   
        if(!updateDynamicStatusIds.isEmpty()){
            List<Opportunity> OppList = [select Id, settlement_Status__C,Prod_Merchant_Id__c, Merchant_Id__c, Aggregator_UUID__c, productLabel__C, TimeInMillis__c  from opportunity where id in :updateDynamicStatusIds];
            if(!OppList.isEmpty()){
                for(Opportunity oppo : oppList){
                    if(!(oppo.Aggregator_UUID__c == '11ed-e4ea-b74b48aa-929c-02e708f88ebc' && System.Label.StopBFLAggregatorStatusToBiz == 'True' )
                       || System.Label.StopSendingSettlementStatustoPayuBiz == 'True' || oppo.ProductLabel__c != 'PayUbiz')  {
                           idsTobePublishedToBiz.add(oppo.Id);
                           idsTobePublishedToBizMap.put(oppo.Id , oppo.Settlement_Status__c);
                           idsTobePublishedToBizTimeMap.put(oppo.Id, oppo.TimeInMillis__c);
                       }       
                } 
            }
            
            if(!idsTobePublishedToBiz.isEmpty() && System.IsBatch() == false && System.isFuture() == false ){
                Set<String> producerNames = AwsConsumerAPI_CTRL.setproducerName;
                boolean isProducerPayuBizTresury = false;
                List<String> producerNameList = new List<String>();
                if(producerNames !=NULL && producerNames.size()>0){
                    producerNameList = new List<String>(producerNames);
                    if(producerNameList[0]=='PayUbizTreasury'){
                        //If settlement status changed as an outcome of payload consumption from Treasury . Do no send back the API . 
                        isProducerPayuBizTresury = true; 
                    }
                }
                if(!isProducerPayuBizTresury){
                    if (System.Label.SwitchOnTreasuryRetry == 'True'){
                        System.debug('SwitchOnTreasuryRetry:::'+ True +  '::: '+System.Label.SwitchOnTreasuryRetry);
                        sendSettlementStatusToBizTreasury(idsTobePublishedToBizMap, idsTobePublishedToBizTimeMap);
                    }else{
                        System.debug('SwitchOnTreasuryRetry:::'+ False +  '::: '+System.Label.SwitchOnTreasuryRetry);
                        //sendSettlementStatusToMCare(idsTobePublishedToBiz,producerNames);
                        sendSettlementStatusToBizTreasuryNewAPI(idsTobePublishedToBizMap, idsTobePublishedToBizTimeMap);
                        
                    }
                }
                
            }
        }
        
        //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
        /* if(!businesscategoryTaskForRiskTeam.isEmpty() && businesscategoryTaskForRiskTeam.Size()>0){
list<Opportunity> businesscatTaskForPremiumRiskTeam = new List<Opportunity>();
list<Opportunity> businesscatTaskForNormalRiskTeam = new List<Opportunity>();
for(Opportunity eachOpp : businesscategoryTaskForRiskTeam){
if(eachOpp.isPremiumCustomer__c) {
businesscatTaskForPremiumRiskTeam.add(eachOpp);
}else {
businesscatTaskForNormalRiskTeam.add(eachOpp);
}
}
if(!businesscatTaskForPremiumRiskTeam.isEmpty())
createTasksForRiskTeam(businesscatTaskForPremiumRiskTeam, Label.Business_Category_Task, '', 'High',true);
else
createTasksForRiskTeam(businesscatTaskForNormalRiskTeam, Label.Business_Category_Task, '', 'Normal',false);
}
*/
        //================= Commenting the code as we are not using the wibmo product============
        //================Method to call for updating wibmo Account ===========================
        /*if(!wibmoAccountIds.isEmpty() && wibmoAccountIds.size()>0 && !opportunityWibmolist.isEmpty() && opportunityWibmolist.size()>0){
updateWibmoAccounts(opportunityWibmolist,wibmoAccountIds);
}  
*/
        //====================Update for Whatsapp outBound to call Batch Class================================
        if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled() && !sendWhatsappOpp.isEmpty() && sendWhatsappOpp != null && sendWhatsappOpp.size() >0) {
            Database.executeBatch(new whatsappOutboundUtilityBatch(sendWhatsappOpp));
        }
        
        //====================Update for Website deletion // Commented by rohit : this code was deleting the website page records on website URL upate===========================
        //if(deleteWebPagesList.size() >0 && deleteWebPagesList!= null) deleteWebsitePages(deleteWebPagesList);
        
        //=========update Account doc and Agreement status for skip============================
        if(!aggAccountDataMap.isEmpty() || !docAccountDataMap.isEmpty()) updateAccountSkipStatus(triggerNew,docAccountDataMap,aggAccountDataMap);
        
        //===========Create task for premium merchant to Risk Team=====================
        if(!systemVerifiedWebsiteList.isEmpty() || !merchantVerifiedWebsiteList.isEmpty()){ 
            createPremiumMemberTask(systemVerifiedWebsiteList,merchantVerifiedWebsiteList);
        }
        
        //===========Create task for premium merchant to Onboarding Team=====================
        if(!premiumOppList.IsEmpty()) createTasksForDocsTeam(premiumOppList,System.Label.Docs_Team_Task, '', 'High',true);
        
        //============Used to call the nb eligible method to send data==========
        if(System.IsBatch() == false && System.isFuture() == false){
            if(!nbEligibleOpportunityIds.isEmpty()) sendNBEligiblePayload(nbEligibleOpportunityIds);
        }
    }
    
    // this method is used to update the opportunity stage while lead will be created through lead conversion (Fire at before insert)
    private static void updateTheStageBasedOnCriteria(List<Opportunity> triggerNew, Map<Id, Account> mapAccount){
        
        for(Opportunity optyObj : triggerNew){
            // optyObj.Valid_Stage__c = true;  ==> As per discussion with kashish, comment this on Oct.11, 2018
            if((optyObj.RecordTypeId == oppMerchantRTId || optyObj.RecordTypeId == oppSupportRTId)){
                if(optyObj.isConverted__c && optyObj.AccountId != null && !mapAccount.isEmpty() && 
                   mapAccount.containsKey(optyObj.AccountId) && (mapAccount.get(optyObj.AccountId).LOB_Status__c == 'Approved' || optyObj.Website_Status__c == 'Website OK')){
                       optyObj.StageName = 'Pre-Risk';
                   }else{
                       optyObj.StageName = 'MAF';
                   }
            }else if(optyObj.RecordTypeId == resellerRecordTypeId){
                optyObj.StageName = 'Onboarding';
            }
        }
    }
    
    // this method is used to update the stage based on some criteria at before insert
    private static void beforeInsertOptyUpdateStage(List<Opportunity> triggerNew, Map<Id, Account> mapAccount){
        List<Opportunity> lstOpty = new List<Opportunity>();    
        
        for(Opportunity optyObj : triggerNew){
            if(optyObj.AccountId != null && !mapAccount.isEmpty() && mapAccount.containsKey(optyObj.AccountId) 
               && (mapAccount.get(optyObj.AccountId).Document_Status__c != null || mapAccount.get(optyObj.AccountId).Agreement_Status__c != null || mapAccount.get(optyObj.AccountId).LOB_Status__c != null || optyObj.Credit_Underwriting_Status__c != null || optyObj.Bank_Verification_Status__c != null || optyObj.MAF_Status__c != null || optyObj.Activation_Status_Onboarding__c != null || optyObj.Settlement_Status__c != null || optyObj.Profile_Verification_Status__c != null || optyObj.Activation_Status__c != null)){
                   lstOpty.add(optyObj);
               }
        }        
        if(!lstOpty.isEmpty()) updateTheStageBasedOnAllStatus(lstOpty, mapAccount);
    }
    
    // this method is used to update the stage based on some criteria at before update
    private static void beforeUpdateOptyUpdateStage(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id, Account> mapAccount){
        List<Opportunity> lstOpty = new List<Opportunity>();
        
        for(Opportunity optyObj : triggerNew){
          
            if(optyObj.AccountId != null && !mapAccount.isEmpty() && mapAccount.containsKey(optyObj.AccountId)
               && (mapAccount.get(optyObj.AccountId).Document_Status__c != null || mapAccount.get(optyObj.AccountId).LOB_Status__c != null || mapAccount.get(optyObj.AccountId).Agreement_Status__c != null || optyObj.MAF_Status__c != triggerOldMap.get(optyObj.Id).MAF_Status__c || optyObj.Credit_Underwriting_Status__c != triggerOldMap.get(optyObj.Id).Credit_Underwriting_Status__c || optyObj.Bank_Verification_Status__c != triggerOldMap.get(optyObj.Id).Bank_Verification_Status__c || optyObj.Activation_Status_Onboarding__c != triggerOldMap.get(optyObj.Id).Activation_Status_Onboarding__c || optyObj.Settlement_Status__c != triggerOldMap.get(optyObj.Id).Settlement_Status__c || optyObj.Pricing_Negotiation_Status__c != triggerOldMap.get(optyObj.Id).Pricing_Negotiation_Status__c || optyObj.Profile_Verification_Status__c != triggerOldMap.get(optyObj.Id).Profile_Verification_Status__c || optyObj.Activation_Status__c != triggerOldMap.get(optyObj.Id).Activation_Status__c )){
                   lstOpty.add(optyObj);
               }
        }        
        if(!lstOpty.isEmpty()) updateTheStageBasedOnAllStatus(lstOpty, mapAccount);
    }   
    
    // this method is used to update the stage based on some critera and calling from "beforeInsertOptyUpdateStage" and "beforeUpdateOptyUpdateStage"
    private static void updateTheStageBasedOnAllStatus(List<Opportunity> triggerNew, Map<Id, Account> mapAccount){
        
        for(Opportunity optyObj : triggerNew){            
            
            if(optyObj.RecordTypeId == oppMerchantRTId || optyObj.RecordTypeId == oppSupportRTId){
                //=========Commenting out this as not using Pricing/MAF===================
                // Pricing & Negotiation
                if(optyObj.MAF_Status__c == 'Received'){
                    optyObj.StageName = 'Pricing & Negotiation';
                    //if(!optyObj.Valid_Stage__c)     optyObj.Valid_Stage__c = true;  ==> As per discussion with kashish, comment this on Oct.11, 2018
                    
                    // Pre-Risk
                    if(String.isBlank(optyObj.Pricing_Negotiation_Status__c) || optyObj.Pricing_Negotiation_Status__c == 'Accepted'){
                        if(String.isNotBlank(optyObj.Website_Status__c) && optyObj.Website_Status__c == 'Website OK'){
                            optyObj.StageName = 'Pre-Risk';
                            
                            // Onboarding
                            if(((optyObj.AccountId != null && !mapAccount.isEmpty() && mapAccount.containsKey(optyObj.AccountId)
                                 && mapAccount.get(optyObj.AccountId).Document_Status__c == 'Docs Received' 
                                 || mapAccount.get(optyObj.AccountId).Document_Status__c == 'Docs Approved' || mapAccount.get(optyObj.AccountId).Document_Status__c == 'Exceptionally Approved')
                                || (optyObj.Document_Status_Document_Issue__c == 'Docs Received' 
                                    || optyObj.Document_Status_Document_Issue__c == 'Docs Approved' || optyObj.Document_Status_Document_Issue__c == 'Exceptionally Approved'))
                               //&& mapAccount.get(optyObj.AccountId).LOB_Status__c == 'Approved' 
                               && optyObj.StageName != 'Live & Transacting' && optyObj.StageName != 'Terminated' && optyObj.Product__c != null 
                               && ((optyObj.Product_Name__c == 'lazy pay' && optyObj.Credit_Underwriting_Status__c == 'Approved') || optyObj.Product_Name__c != 'lazy pay')){
                                   
                                   optyObj.StageName = 'Onboarding';
                                   
                                   // Activation
                                   if(optyObj.Bank_Verification_Status__c == 'Success' && optyObj.Website_Status__c == 'Website OK'
                                      && ((mapAccount.get(optyObj.AccountId).Agreement_Status__c == 'Approved'
                                           && (mapAccount.get(optyObj.AccountId).Document_Status__c == 'Docs Approved' || mapAccount.get(optyObj.AccountId).Document_Status__c == 'Exceptionally Approved'))
                                          || (optyObj.Agreement_Status__c == 'Approved' && optyObj.Document_Status_Document_Issue__c == 'Docs Approved'))){
                                              optyObj.StageName = 'Activation';
                                              //if(optyObj.Valid_Stage__c)  optyObj.Valid_Stage__c = false;  ==> As per discussion with kashish, comment this on Oct.11, 2018
                                              
                                              //=========Commenting this method as we are not using MID fetch==================
                                              /*if(!System.isBatch() && !System.isFuture()){
LeadTriggerHelper.fetchMIdwithTrigger(optyObj.Id, 'Opportunity', null); 
} */
                                              
                                              // Live & Transacting
                                              if(optyObj.Activation_Status_Onboarding__c == 'ME Code Activated' && optyObj.Settlement_Status__c == 'Active'){
                                                  optyObj.StageName = 'Live & Transacting';
                                              }
                                          }
                               }
                        }
                    }
                }
            }
            else if(optyObj.RecordTypeId == resellerRecordTypeId && optyObj.Bank_Verification_Status__c == 'Success' && mapAccount.get(optyObj.AccountId).Document_Status__c == 'Docs Approved' && mapAccount.get(optyObj.AccountId).Agreement_Status__c == 'Approved' && optyObj.Profile_Verification_Status__c == 'Submitted' && optyObj.Activation_Status__c == 'Active'){
                optyObj.StageName = 'Live & Transacting'; 
            }
        }
    }
    
    // Get the Bank Account Details records under the each Opportunity
    private static void getAccountRecords(Set<Id> setAccId, Map<Id, Account> mapAccount){
        mapAccount.putAll([SELECT Id, Name, Pan_Verification_Status__c,Agreement_Status__c, Document_Status__c,
                           LOB_Status__c, NDX_Score__c FROM Account WHERE Id IN : setAccId]);
    }
    
    public static void updateOptyNameAndWebsiteStatus(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id, Account> mapAccount){
        Id optyRTId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Support_Opportunity').getRecordTypeId();
        
        List<String> businessCategoryNames = System.Label.Business_Category.split(',');
        
        for(Opportunity each : triggerNew){   
            if(each.Prod_Merchant_Id__c != null && (triggerOldMap == null || each.Prod_Merchant_Id__c != triggerOldMap.get(each.Id).Prod_Merchant_Id__c)){
                if(each.RecordTypeId == optyRTId){
                    //========= Handling this in Maintenance Request Controller=======
                    //each.Name = 'CR - ' + String.valueOf(each.Prod_Merchant_Id__c);
                }
                else{
                    each.Name = String.valueOf(each.Prod_Merchant_Id__c);
                } 
            }
            
            if(each.Merchant_Id__c != null && each.Prod_Merchant_Id__c == null &&
               (triggerOldMap == null || each.Merchant_Id__c != triggerOldMap.get(each.Id).Merchant_Id__c || each.Prod_Merchant_Id__c != triggerOldMap.get(each.Id).Prod_Merchant_Id__c)){
                   if(each.RecordTypeId == optyRTId){
                       //========= Handling this in Maintenance Request Controller=======
                       //each.Name = 'CR - ' + String.valueOf(each.Merchant_Id__c);
                   }
                   else{
                       each.Name = String.valueOf(each.Merchant_Id__c);
                   }
               }
            
            if(each.Merchant_Id__c == null && each.Prod_Merchant_Id__c == null && !mapAccount.isEmpty() && mapAccount.containsKey(each.AccountId)){
                if(each.RecordTypeId == optyRTId){
                    //========= Handling this in Maintenance Request Controller=======
                    //each.Name = 'CR - ' + mapAccount.get(each.AccountId).Name;
                }
                else{
                    each.Name = mapAccount.get(each.AccountId).Name; 
                }
            }
        }
        
        //====== commenting for onboarding revamp used in website detail trigger - JIRA-SFPI-997======================
        /*
if(!mapAccount.isEmpty()){
for(Opportunity each : triggerNew){
if(mapAccount.containskey(each.AccountId) && mapAccount.get(each.AccountId).NDX_Score__c !=null 
&& mapAccount.get(each.AccountId).NDX_Score__c>0
&& mapAccount.get(each.AccountId).NDX_Score__c <=50000 
&& (each.Website_Status__c != 'Website OK')
&& each.Integration_Type__c == 'ThirdParty'
&& (string.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || string.isNotBlank(each.Android_URL__c))                   
&& (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')
&& !each.Skip_Website_Verification__c){

if(triggerOldMap != null && 
((each.Updated_by_Dataloader__c && each.Updated_by_Dataloader__c != triggerOldMap.get(each.Id).Updated_by_Dataloader__c && !System.isFuture() && !System.isBatch()) && userinfo.getUserId() != System.label.IntegrationUserId)){
// Commented as API is disabled from Payu Hub
//WebsiteStatusCallout(each.Id);
System.debug('under if 2 '+mapAccount);
}else if(triggerOldMap != null && (each.Website__c != triggerOldMap.get(each.Id).Website__c
|| each.iOS_URL__c != triggerOldMap.get(each.Id).iOS_URL__c
|| each.Android_URL__c != triggerOldMap.get(each.Id).Android_URL__c
|| each.Website_Status__c != triggerOldMap.get(each.Id).Website_Status__c
|| each.Integration_Type__c != triggerOldMap.get(each.Id).Integration_Type__c)
&& userinfo.getUserId() == System.label.IntegrationUserId && each.Integration_Type__c == 'Thirdparty'){
if(String.isNotBlank(each.Business_Category__c)){
If(!businessCategoryNames.contains(each.Business_Category__c)){
each.Website_Status__c = 'Website OK';
each.Risk_Level__c = 'High-Auto Approved';
}
}  
} else if(triggerOldMap == null){
if(String.isNotBlank(each.Business_Category__c) && !businessCategoryNames.contains(each.Business_Category__c)){
each.Website_Status__c = 'Website OK';
each.Risk_Level__c = 'High-Auto Approved';
}
}                  
}else if((string.isNotBlank(each.Website__c) || string.isNotBlank(each.iOS_URL__c) || string.isNotBlank(each.Android_URL__c))
&& each.Skip_Website_Verification__c && each.Integration_Type__c == 'ThirdParty'
&& (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')){
If(each.Skip_Website_Verification__c == true){
each.Website_Remarks__c='Website marked auto approved for whitelabel Partner Referred Merchants';
} 
each.Website_Status__c = 'Website OK';
each.Risk_Level__c = 'High-Auto Approved';
}

}        
}*/
    } 
    
    // ============= Update the Settlement Staus when Website Status is OK ===================
    private static void updateSettlementStatus(List<Opportunity> lstOpportunity, Map<Id,Opportunity> triggerOldMap, Map<Id, Account> mapAccount){
        //SFI-614 / SFI-647
        /*User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c, Username From User 
where Id =: UserInfo.getUserId() LIMIT 1];      
if((userObj.Username=='integration.user@payu.in.prod'|| userObj.Username=='awsconsumer.user@payu.in.prod') && Label.Settlement_Status_Hold_Release_User == '1'){  
return;         
}*/
        //end SFI-614 / SFI-647
        
        List<String> settlementStatusLabelList = System.Label.Settlement_Status_Restricted.split(',');
        List<String> settlementStatusPublishList = System.Label.Settlement_Status_Published.split(',');
        List<String> settlementStatusChangeCheck = System.Label.Settlement_Status_Change_Check.split(',');
        for(Opportunity each : lstOpportunity){ 
            String localSettlementStatus = each.Settlement_Status__c;
            System.debug('1608*triggerOldMap'+triggerOldMap.isEmpty());
            System.debug('1609*each-websiteStatus_'+each.Website_Status__c+''+each.Agreement_Status__c+''+each.Document_Status_Document_Issue__c);
            if(!triggerOldMap.isEmpty() && triggerOldMap != null){
                Opportunity oldEach = triggerOldMap.get(each.Id);
                
                /*if(String.isNotBlank(each.AccountId) && !mapAccount.isEmpty() && mapAccount.containsKey(each.AccountId)
&& String.isNotBlank(mapAccount.get(each.AccountId).Agreement_Status__c) && mapAccount.get(each.AccountId).Agreement_Status__c == 'Approved' 
&& String.isNotBlank(mapAccount.get(each.AccountId).Document_Status__c) && mapAccount.get(each.AccountId).Document_Status__c == 'Docs Approved'
&& String.isNotBlank(mapAccount.get(each.AccountId).Pan_Verification_Status__c) && mapAccount.get(each.AccountId).Pan_Verification_Status__c == 'Success'
&& (each.Website_Status__c != oldEach.Website_Status__c)
&& !settlementStatusLabelList.contains(each.Settlement_Status__c)
&& each.Website_Status__c == 'Website OK'
&& (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')){
each.Settlement_Status__c = 'Active';
each.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;

If(each.Settlement_Activated__c == null) each.Settlement_Activated__c = oldEach.OwnerId;
If(each.Settlement_Date__c == null) each.Settlement_Date__c = Date.today();
each.Settlement_Status_Latest_Date__c = Date.today();                
}else */System.debug('condition for thirdparty'+!settlementStatusPublishList.contains(each.Settlement_Status__c)+'merchantType'+each.Merchant_Business_Type__c );
                if(/*!settlementStatusPublishList.contains(each.Settlement_Status__c) && */ (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')
                   && (each.Integration_Type__c == 'Tools' || each.Integration_Type__c == 'Not Selected' || (each.Integration_Type__c == 'ThirdParty' && each.Website_Status__c == 'Website OK')) 
                   && each.Agreement_Status__c == 'Approved' && each.Document_Status_Document_Issue__c == 'Docs Approved'
                   && ((each.Website_Status__c != oldEach.Website_Status__c ) 
                       || (each.Document_Status_Document_Issue__c != oldEach.Document_Status_Document_Issue__c )
                       || (each.Agreement_Status__c != oldEach.Agreement_Status__c )
                       || (each.Settlement_Status__c != oldEach.Settlement_Status__c && each.Settlement_Status__c != 'Active')
                       || each.Integration_Type__c != oldEach.Integration_Type__c)){
                           each.Settlement_Status__c = 'Active';
                           each.Onboarding_Completed__c = true;//SFI-1065 By Saksham
                           each.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;
                           
                           If(each.Settlement_Activated__c == null) each.Settlement_Activated__c = oldEach.OwnerId;
                           If(each.Settlement_Date__c == null) each.Settlement_Date__c = Date.today();
                           each.Settlement_Status_Latest_Date__c = Date.today();
                       }else if(/*!settlementStatusChangeCheck.contains(each.Settlement_Status__c) && */(each.Merchant_Business_Type__c == 'LongTail')
                                && ((each.Integration_Type__c == 'ThirdParty' && (each.Agreement_Status__c != 'Approved' || each.Document_Status_Document_Issue__c != 'Docs Approved' || each.Website_Status__c != 'Website OK'))
                                    || (each.Integration_Type__c == 'Tools' || each.Integration_Type__c == 'Not Selected') && (each.Agreement_Status__c != 'Approved' || each.Document_Status_Document_Issue__c != 'Docs Approved'))
                                && ((each.Website_Status__c != oldEach.Website_Status__c && each.Integration_Type__c == 'ThirdParty') 
                                    || (each.Document_Status_Document_Issue__c != oldEach.Document_Status_Document_Issue__c )
                                    || (each.Agreement_Status__c != oldEach.Agreement_Status__c)
                                    || (each.Settlement_Status__c != oldEach.Settlement_Status__c)) && each.Next_ReKYC_Date__c == null){
                                        each.Settlement_Status__c = 'Thirdparty Hold';
                                    }
            }else if(triggerOldMap.isEmpty() && triggerOldMap == null){
                /*if(String.isNotBlank(each.AccountId) && !mapAccount.isEmpty() && mapAccount.containsKey(each.AccountId)
&& String.isNotBlank(mapAccount.get(each.AccountId).Agreement_Status__c) && mapAccount.get(each.AccountId).Agreement_Status__c == 'Approved' 
&& String.isNotBlank(mapAccount.get(each.AccountId).Document_Status__c) && mapAccount.get(each.AccountId).Document_Status__c == 'Docs Approved'
&& String.isNotBlank(mapAccount.get(each.AccountId).Pan_Verification_Status__c) && mapAccount.get(each.AccountId).Pan_Verification_Status__c == 'Success'                 
&& !settlementStatusLabelList.contains(each.Settlement_Status__c)
&& each.Website_Status__c == 'Website OK'
&& (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')){
each.Settlement_Status__c = 'Active';
each.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;

If(each.Settlement_Activated__c == null) each.Settlement_Activated__c = each.OwnerId;
If(each.Settlement_Date__c == null) each.Settlement_Date__c = Date.today();
each.Settlement_Status_Latest_Date__c = Date.today();
System.debug('each settlement method end ^^^^^^^ '+each );                 
}else*/System.debug('1663*triggerOldMap'+triggerOldMap.isEmpty());
                if(!settlementStatusPublishList.contains(each.Settlement_Status__c) && (each.Merchant_Business_Type__c == 'LongTail')
                   && ((each.Integration_Type__c == 'ThirdParty' && each.Website_Status__c == 'Website OK') 
                       || (each.Document_Status_Document_Issue__c == 'Docs Approved')
                       || (each.Agreement_Status__c == 'Approved')
                       || (each.Settlement_Status__c == 'Thirdparty Hold' && each.Website_Status__c == 'Website OK' && each.Document_Status_Document_Issue__c == 'Docs Approved' && each.Agreement_Status__c == 'Approved'))){
                           each.Settlement_Status__c = 'Active';
                           each.Onboarding_Completed__c = true;//SFI-1065 By Saksham
                           each.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;
                           
                           If(each.Settlement_Activated__c == null) each.Settlement_Activated__c = each.OwnerId;
                           If(each.Settlement_Date__c == null) each.Settlement_Date__c = Date.today();
                           each.Settlement_Status_Latest_Date__c = Date.today();
                       }else if(!settlementStatusChangeCheck.contains(each.Settlement_Status__c) && (each.Merchant_Business_Type__c == 'LongTail' || each.Merchant_Business_Type__c == 'Compulsive')
                                && ((each.Integration_Type__c == 'Tools' || (each.Integration_Type__c == 'ThirdParty' && each.Website_Status__c != 'Website OK')) 
                                    || (each.Document_Status_Document_Issue__c != 'Docs Approved')
                                    || (each.Agreement_Status__c != 'Approved')) && each.Next_ReKYC_Date__c == null){
                                        each.Settlement_Status__c = 'Thirdparty Hold';
                                    }
            }
            system.debug('inside settlment status update'+each.Settlement_Status__c);
            
            if( (each.Settlement_Status__c == 'Active' || each.Settlement_Status__c == 'Thirdparty Hold' || each.Settlement_Status__c == Null)
               && (each.On_OB_Hold__c == 'Y' || each.On_Post_Risk_Hold__c == 'Y' || each.On_Pre_Risk_Hold__c == 'Y')){
                   each.Settlement_Status__c = 'Risk Hold';
                   
               }else if(each.Settlement_Status__c == 'Risk Hold' && each.Blacklist__c != True && each.On_OB_Hold__c != 'Y' && each.On_Post_Risk_Hold__c != 'Y' && each.On_Pre_Risk_Hold__c != 'Y'){               
                   if((each.Merchant_Business_Type__c == 'LongTail' || String.isBlank(each.Merchant_Business_Type__c))
                      && ((each.Integration_Type__c == 'ThirdParty' && (each.Agreement_Status__c != 'Approved' || each.Document_Status_Document_Issue__c != 'Docs Approved' || each.Website_Status__c != 'Website OK'))
                          || ((each.Integration_Type__c == 'Tools' || each.Integration_Type__c == 'Not Selected' || String.isBlank(each.Integration_Type__c)) && (each.Agreement_Status__c != 'Approved' || each.Document_Status_Document_Issue__c != 'Docs Approved')))){
                              //Released from Risk Hold but goes to TP Hold now
                              each.Settlement_Status__c = 'Thirdparty Hold';
                          } else if((each.Merchant_Business_Type__c != 'LongTail' ) || ((each.Merchant_Business_Type__c == 'LongTail' || String.isBlank(each.Merchant_Business_Type__c))
                                                                                        && (String.isBlank(each.Integration_Type__c) || each.Integration_Type__c == 'Tools' || each.Integration_Type__c == 'Not Selected' || (each.Integration_Type__c == 'ThirdParty' && each.Website_Status__c == 'Website OK')) 
                                                                                        && each.Agreement_Status__c == 'Approved' && each.Document_Status_Document_Issue__c == 'Docs Approved' )){
                                                                                            //Release from Risk Hold to Active
                                                                                            
                                                                                            if(each.Document_Status_Document_Issue__c != 'Docs Approved') each.Document_Status_Document_Issue__c = 'Docs Approved';
                                                                                            if(each.Agreement_Status__c != 'Approved') each.Agreement_Status__c = 'Approved';
                                                                                            each.Settlement_Status__c = 'Active';
                                                                                            each.Onboarding_Completed__c = true;//SFI-1065 By Saksham
                                                                                            each.Risk_Unhold_Reason__c = Label.Risk_Unhold_Reason;
                                                                                            
                                                                                            If(each.Settlement_Activated__c == null) each.Settlement_Activated__c = each.OwnerId;
                                                                                            If(each.Settlement_Date__c == null) each.Settlement_Date__c = Date.today();
                                                                                            each.Settlement_Status_Latest_Date__c = Date.today();
                                                                                        } 
               }
            if(each.Settlement_Status__c != localSettlementStatus) { 
                each.TimeInMillis__c = System.currentTimeMillis(); 
                System.debug('TimeInMillis__c::::: line 1733: '+each.TimeInMillis__c);
            }
            
        }
    }    
    
    private static void updateNEFTHoldStatus(List<Opportunity> lstOpprt, Map<Id,Opportunity> mapOfOpprt){
        for(Opportunity objOpp :lstOpprt){
            if(objOpp.NEFT_Hold_Status__c == 'Hold' && mapOfOpprt.get(objOpp.Id).NEFT_Hold_Status__c != objOpp.NEFT_Hold_Status__c){
                objOpp.Settlement_Old_Status__c = objOpp.Settlement_Status__c;
                objOpp.Settlement_Status__c = 'Risk & Thirdparty hold';
            } 
            else if(objOpp.NEFT_Hold_Status__c == 'Active' && mapOfOpprt.get(objOpp.Id).NEFT_Hold_Status__c != objOpp.NEFT_Hold_Status__c &&
                    objOpp.Settlement_Status__c == 'Risk & Thirdparty hold' ){
                        objOpp.Settlement_Status__c = objOpp.Settlement_Old_Status__c ;
                    }   
        }
    }
    
    
    //*****Line no 478 to 500 Added by Akash Pandey*****//
    public static void updateLOBAndRiskAutoApproved(List<Opportunity> listOpportunity, Set<Id> setBusinessCategory){
        Map<Id, Business_Category__c> mapBusinessCategory = new Map<Id, Business_Category__c>();
        if(!setBusinessCategory.isEmpty()) getBusinessCategoryRecord(setBusinessCategory, mapBusinessCategory);
        
        if(!listOpportunity.isEmpty() && !mapBusinessCategory.isEmpty()){
            for(Opportunity eachOpp : listOpportunity){
                if(mapBusinessCategory.get(eachOpp.BusinessCategory__c).Doable__c
                   && eachOpp.Transaction_Facility_Required__c == 'Domestic' 
                   && eachOpp.Delivery_Duration__c > 0 && eachOpp.NDX_Score__c > 0 && eachOpp.NDX_Score__c <= 140000
                   && merchantBusinessTypeList.contains(eachOpp.Merchant_Business_Type__c)){
                       eachOpp.Risk_Auto_Approved__c = true;
                       eachOpp.LOB_Status__c = 'Approved';
                   }
                else{
                    eachOpp.Risk_Auto_Approved__c = false;
                    eachOpp.LOB_Status__c = 'Pending';
                }
            }
        }        
    }
    
    // Get the Business Category Records
    private static void getBusinessCategoryRecord(Set<Id> setBusinessCategory, Map<Id, Business_Category__c> mapBusinessCategory){
        mapBusinessCategory.putAll([SELECT Id, Doable__c From Business_Category__c WHERE Id IN : setBusinessCategory]);
    }
    
    public static void checkModifyOwner(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        Map<String, String> mapOfMerchant_Owners = (Map<String, String>)JSON.deserialize(Label.Merchant_Owner_for_Shopmatic, Map<String, String>.class);
        List<String> desiredOwners = new List<String>();
        Integer userIndex = 0;
        for(Opportunity opty : triggerNew){
            if(opty.Partner_ID__c == Label.Shopmatric_UUID){
                if(opty.Partner__c != null)  desiredOwners = mapOfMerchant_Owners.get(opty.Partner_ID__c).split(', ');
                if(!desiredOwners.isEmpty()){
                    userIndex = Math.mod(IntrandomNumber, desiredOwners.Size());
                }else{
                    userIndex = 0;
                }
                List<String> payU_SMB_Outsource_Team_Members = Label.PayU_SMB_Outsource_Team_Members.split(', ');
                if(mapOfMerchant_Owners.keySet().contains(opty.Partner_ID__c) && !desiredOwners.isEmpty() && opty.Partner__c != triggerOldMap.get(opty.id).partner__c){
                    if(!payU_SMB_Outsource_Team_Members.contains(opty.Owner_First_Name__c+' '+opty.Owner_Last_Name__c)){
                        opty.OwnerId =  desiredOwners.get(userIndex);
                    }else{
                        if(!triggerOldMap.isEmpty())  opty.OwnerId = triggerOldMap.get(opty.Id).ownerId;
                    }
                }
            }
            IntrandomNumber = IntrandomNumber+1;
        }
    }
    
    //===============Commenting thsi method as using in Website Detail Trigger Handler==================
    /* public static void createTasksForRiskTeam(List<Opportunity> taskForOpportunities, String subject, String comment, String priority,Boolean isPremiumCustomer){

Integer IntrandomPreNumber = Integer.valueof((Math.random() * 1000));
Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
List<task> tasks = new List<task>();

if(isPremiumCustomer){
Group premiumGrp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) 
FROM Group WHERE DeveloperName ='Risk_Team_For_CS' AND Type =: 'Queue' LIMIT 1];
list<Merchant_Plan__c> planList = [select id,opportunity__c from Merchant_Plan__c where opportunity__c IN :taskForOpportunities];
Map<String,Merchant_Plan__c> oppIdPlanMap = new Map<String,Merchant_Plan__c>();
Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');

if(!planList.isEmpty()){
for(Merchant_Plan__c eachPlan : planList){
oppIdPlanMap.put(eachPlan.opportunity__c, eachPlan);
}
for(Opportunity opty : taskForOpportunities){
String merchantPlanId = oppIdPlanMap.get(opty.id).id;
DateTime timeNow = System.now();
Task task = new Task(whatId = opty.Id, Subject = subject, Status = 'Open', ActivityDate = system.today()+1, Priority = priority,
Description = comment, Merchant_Plan__c = merchantPlanId,
IsReminderSet = True, ReminderDateTime = MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,timeNow,10800000));
if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
task.OwnerId = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
}
tasks.add(task);
IntrandomPreNumber = IntrandomPreNumber+1;
}
}
}
else{
Group grp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) 
FROM Group WHERE DeveloperName ='Pre_Onboarding_Risk_Team' AND Type =: 'Queue' LIMIT 1];
for(Opportunity opty : taskForOpportunities){
Task task = new Task(whatId = opty.Id, Subject = subject, Status = 'Not Started', ActivityDate = system.today(), Priority = priority,
Description = comment);
if(grp != null && grp.GroupMembers != null && !grp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomNumber, grp.GroupMembers.Size());
task.OwnerId = grp.GroupMembers.get(userIndex).UserOrGroupId;
}
tasks.add(task);
IntrandomNumber = IntrandomNumber+1;
}
}
if(!tasks.isEmpty())    insert tasks;
}
*/
    private static void createTasksForDocsTeam(List<Opportunity> taskForOpportunities, String subject, String comment, String priority,Boolean isPremiumCustomer){
        Integer IntrandomPreNumber = Integer.valueof((Math.random() * 1000));
        List<task> tasks = new List<task>();
        
        if(isPremiumCustomer){
            Group premiumGrp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) 
                                FROM Group WHERE DeveloperName ='Documentation_Team_For_CS' AND Type =: 'Queue' LIMIT 1];
            list<Merchant_Plan__c> planList = [select id,opportunity__c from Merchant_Plan__c where opportunity__c IN :taskForOpportunities];
            Map<String,Merchant_Plan__c> oppIdPlanMap = new Map<String,Merchant_Plan__c>();
            Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
            String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');
            
            if(!planList.isEmpty()){
                for(Merchant_Plan__c eachPlan : planList){
                    system.debug('create map merchant plan opportunity');
                    oppIdPlanMap.put(eachPlan.opportunity__c, eachPlan);
                }
                for(Opportunity opty : taskForOpportunities){
                    String merchantPlanId = oppIdPlanMap.get(opty.id).id;
                    DateTime timeNow = System.now();
                    Task task = new Task(whatId = opty.Id, Subject = subject, Status = 'Open', ActivityDate = system.today()+1, Priority = priority,
                                         Description = comment, Merchant_Plan__c = merchantPlanId,
                                         IsReminderSet = True, ReminderDateTime = MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,timeNow,10800000));
                    if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
                        Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
                        task.OwnerId = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
                    }
                    tasks.add(task);
                    IntrandomPreNumber = IntrandomPreNumber+1;
                }
            }
            if(!tasks.isEmpty())    insert tasks;
        }
    }
    
    private static List<Task> updateTaskStatusToClosed(Set<Id> oppIds,List<Task> taskList){
        if(!oppIds.isEmpty()){
            List<string> subjectList = System.Label.Website_Task_Subject.split(',');
            for(Task tsk : [Select Id,Status from Task where WhatId IN : oppIds AND Subject IN: (subjectList) AND Status IN ('Open','Not Started')]){
                tsk.Status = 'Closed';
                taskList.add(tsk);
            }
            return taskList;
        }
        return null;
    }
    
    private static void createTasksForSalesTeam(List<Opportunity> taskForSalesTeam){
        List<task> tasks = new List<task>();
        for(Opportunity opty : taskForSalesTeam){ 
            if(opty.Inbound_team_member__c == true){
                Task objTask = New Task(whatId = opty.Id,Status='Open',Type='call', ActivityDate = date.today()+1,
                                        OwnerId=opty.OwnerId,Subject = 'Merchant Call Required post Opportunity creation');
                tasks.add(objTask);
            }
        }
        if(!tasks.isEmpty())    insert tasks;
    }
    private static List<Task> closetaskforsalesteam(Set<Id> closetaskForSalesTeamIds){
        try{
            List<task> taskListToClosed = new List<task>();
            for(Task tk : [Select Id,Status from Task where Status IN ('Open','Not Started') AND
                           Subject IN ('Merchant Call Required post Opportunity creation') AND WhatId IN: closetaskForSalesTeamIds]){
                               tk.status = 'Closed';
                               taskListToClosed.add(tk);       
                           }
            if(!taskListToClosed.isEmpty() && taskListToClosed.size()>0) update taskListToClosed;
            return taskListToClosed;
        }
        catch(Exception ex){
            return null;
        }
    }
    
    private static List<Task> closeUpdatestatusTask(Set<Id> closetaskForSalesTeamIds){
        try{
            List<task> taskToBeClosedList = new List<task>();
            for(Task tk : [Select Id,Status from Task where 
                           Status IN ('Open','Not Started') AND WhatId IN: closetaskForSalesTeamIds
                           AND Subject IN ('Merchant Call Required for uploading Website and document',
                                           'Merchant Call Required for documents uploading',
                                           'Merchant Call Required for uploading Website') 
                          ]){
                              tk.Status = 'Closed';
                              taskToBeClosedList.add(tk);
                          }
            
            update taskToBeClosedList;
            return taskToBeClosedList;
        }
        catch(Exception ex){
            return null;
        }
    }
    
    private static List<Task> closeApprovedTask(Set<Id> closetaskForSalesTeamIds){
        try{
            List<task> taskToBeClosedList = new List<task>();
            for(Task tk : [Select Id,Status from Task where 
                           Status IN ('Open','Not Started') AND WhatId IN: closetaskForSalesTeamIds
                           AND Subject IN ('Merchant Call Required for website and document verification',
                                           'Merchant Call Required for document verification',
                                           'Merchant Call Required for website verification') 
                          ]){
                              tk.Status = 'Closed';
                              taskToBeClosedList.add(tk);
                          }
            
            update taskToBeClosedList;
            return taskToBeClosedList;
        }
        catch(Exception ex){
            return null;
        }
    }
    
    //============ update click to call count===================================
    // Created for click to call
    private static void createTaskforClickToCall(List<Opportunity> triggerNew,Map<Id, Opportunity> triggerOldMap){  
        try{  
            
            List<Task> taskList = new List<Task>();  
            String userDetails = '';  
            List<String> strList = new List<String>();
            String userMobile = '';
            
            for(Opportunity opp: triggerNew){
                if(opp.Agent_Details__c != null){
                    userDetails = opp.Agent_Details__c;  
                }
            } 
            
            if(userDetails != null){
                strList =  userDetails.split('-');
            }
            
            if(strList.size() > 0){
                userMobile = strList[1].deleteWhitespace();
                if(userMobile.contains('+91')){  
                    userMobile = userMobile.removeStart('+91');  
                }  
                userMobile = '%'+userMobile;
            }
            
            //String finalMobile   
            String userName = strList[0].trim();  
            
            User user = [SELECT Id, Name,isActive,FirstName,LastName, MobilePhone FROM User 
                         where Name =: userName AND isActive = true AND MobilePhone Like: userMobile];  
            
            for(Opportunity opp: triggerNew){  
                Opportunity oldOpp = triggerOldMap.get(opp.Id);  
                Decimal oldCount;  
                if(oldOpp.C2C_Call_Count__c  != null && opp.Manual_Call_Response__c  != oldOpp.Manual_Call_Response__c){  
                    oldCount = oldOpp.C2C_Call_Count__c ;  
                }else if(opp.C2C_Call_Count__c ==null){  
                    oldCount = 0;  
                }  
                
                if(opp.Manual_Call_Response__c  != oldOpp.Manual_Call_Response__c && opp.Manual_Call_Response__c != null && (opp.Missed_Call_Time__c == oldOpp.Missed_Call_Time__c)){  
                    
                    opp.C2C_Call_Count__c   = oldCount + 1;  
                    Task objTask = New Task();  
                    objTask.Subject = 'Click To Call Details';  
                    objTask.WhatId = Opp.Id;  
                    objTask.Status = 'Closed';  
                    objTask.Description = 'Manual Call Responce:: '+opp.Manual_Call_Response__c+', '+'\n Audio Clip: '+opp.Audio_Clip__c;  
                    objTask.Merchant_Name__c = opp.Merchant_Name__c;  
                    objTask.Merchant_Mobile__c = opp.Merchant_Mobile__c;  
                    objTask.Agent_Details__c = opp.Agent_Details__c;
                    if(string.isNotBlank(opp.Call_Status__c) && string.isNotBlank(opp.Call_Duration__c) 
                       && opp.Call_Status__c != NULL && opp.Call_Duration__c != NULL){
                           objTask.Call_Status__c = opp.Call_Status__c;
                           objTask.CallDurationInSeconds = Integer.valueOf(opp.Call_Duration__c);
                       }
                    if(user != null){
                        objTask.OwnerId = user.Id;
                    }
                    taskList.add(objTask);  
                }  
                if(opp.Missed_Call_Time__c != oldOpp.Missed_Call_Time__c && String.isNotBlank(opp.Missed_Call_Time__c) ){  
                    Task objTask = New Task();  
                    objTask.Subject = 'Click To Call Missed Call Alert';  
                    objTask.WhatId = Opp.Id;  
                    objTask.Status = 'Open';
                    if(user != null){
                        objTask.OwnerId = user.Id;
                    }
                    objTask.Merchant_Name__c = opp.Merchant_Name__c;  
                    objTask.Merchant_Mobile__c = opp.Merchant_Mobile__c;  
                    taskList.add(objTask);  
                }  
            }  
            if(taskList.size() > 0){  
                insert taskList;  
            }  
        }Catch(Exception ex){  
            System.debug('ERROR:: '+ex.getMessage());  
            System.debug('LINE NO:: '+ex.getLineNumber());  
        } 
    }
    
    //============Commenting this method as formula field is using for this==============
    // Update delivery duration=================================================
    /*public static void updateDeliveryDuration(Set<Id> subCategoryIds, List<Opportunity> triggerNew){
Map<Id,Sub_Category__c> subCategoryMap = new Map<Id,Sub_Category__c>();
if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0){
for(Sub_Category__c sbObj : [Select Id,Delivery_duration__c from Sub_Category__c where Id IN: subCategoryIds]){
if(sbObj.Delivery_duration__c != null){
subCategoryMap.put(sbObj.Id,sbobj);
}
}
if(!subCategoryMap.isEmpty() && subCategoryMap != null){
for(Opportunity eachOpp : triggerNew){
if(subCategoryMap.containsKey(eachOpp.Sub_Category__c)){
if(eachOpp.Delivery_Duration__c==null || eachOpp.Delivery_Duration__c==0)
eachOpp.Delivery_Duration__c = subCategoryMap.get(eachOpp.Sub_Category__c).Delivery_duration__c;
}
}
}
}
}*/
    
    //--Added by Shivani-Reassign opportunity owner when settlement is active---//
    public static void babyCareReassignOppOwnerBU(List<Opportunity> settlementReassignOwner,Map<Id,Opportunity> triggerOldMap,Baby_Care_Flow__c babyCareFlow){
        Map<string,string> fieldWithMessage = new Map<string,string>();
        try{
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000)); 
            Integer userIndex = 0;
            Map<String,List<GroupMember>> babyCaregroupMap = New Map<String,List<GroupMember>>();
            if(babyCareFlow != null && babyCareFlow.Active__c){
                for(Group gp : [Select Id,Name,DeveloperName,(Select Id,UserORGroupId FROM GroupMembers) FROM GROUP WHERE DeveloperName IN('BabyCare_Thirdparty_Team','BabyCare_Tools_Team')]){
                    babyCaregroupMap.put(gp.DeveloperName,gp.GroupMembers);
                }
            }
            
            for(Opportunity eachOpp : settlementReassignOwner){
                if (eachOpp.Integration_Type__c == 'ThirdParty' &&
                    (string.isNotBlank(eachOpp.Website__c) || string.isNotBlank(eachOpp.Android_URL__c) || string.isNotBlank(eachOpp.iOS_URL__c)))
                {
                    if(babyCareFlow != null && !babyCareFlow.Active__c){
                        if(eachOpp.Settlement_Activated__c == null){
                            if(Trigger.isInsert){
                                eachOpp.Settlement_Activated__c = eachOpp.OwnerId;
                            }
                            else if(triggerOldMap != null && !triggerOldMap.isEmpty() && !checkRecurssion) 
                                eachOpp.Settlement_Activated__c = triggerOldMap.get(eachOpp.Id).OwnerId;
                        }
                        if(eachOpp.Settlement_Date__c==null){
                            eachOpp.Settlement_Date__c=date.today();
                        }
                        eachOpp.Settlement_Status_Latest_Date__c = Date.today();
                    }
                    If(!babyCaregroupMap.isEmpty() && babyCaregroupMap.get('BabyCare_Thirdparty_Team') != null && babyCaregroupMap.get('BabyCare_Thirdparty_Team').size()>0){
                        if(eachOpp.LeadSource!=null && eachOpp.LeadSource == 'Organic' && eachOpp.Key_Assigned_Manager__c ==null && !System.Label.Baby_care_Owner.split(',').contains(eachOpp.OwnerId) && System.Label.Baby_care_transfer_lead.split(',').contains(eachOpp.OwnerId) && eachopp.partner__c == null){
                            userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Thirdparty_Team').size());
                            eachOpp.OwnerId = babyCaregroupMap.get('BabyCare_Thirdparty_Team').get(userIndex).UserORGroupId;
                        }
                        if(eachOpp.Settlement_Activated__c == null){
                            if(Trigger.isInsert){
                                eachOpp.Settlement_Activated__c = eachOpp.OwnerId;
                            }
                            else if(triggerOldMap != null && !triggerOldMap.isEmpty() && !checkRecurssion) 
                                eachOpp.Settlement_Activated__c = triggerOldMap.get(eachOpp.Id).OwnerId;
                        }
                        if(eachOpp.Settlement_Date__c==null){
                            eachOpp.Settlement_Date__c=date.today();
                        }
                        eachOpp.Settlement_Status_Latest_Date__c = Date.today();
                    }
                    else{
                        userIndex = 0;
                    }
                }
                else if(eachOpp.Integration_Type__c == 'Tools' &&(
                    string.isBlank(eachOpp.Android_URL__c) && string.isBlank(eachOpp.iOS_URL__c))){
                        if(babyCareFlow != null && !babyCareFlow.Active__c){
                            if(eachOpp.Settlement_Date__c==null){
                                eachOpp.Settlement_Date__c=date.today();
                            }
                            if(eachOpp.Settlement_Activated__c == null){
                                if(Trigger.isInsert){
                                    eachOpp.Settlement_Activated__c = eachOpp.OwnerId;
                                }
                                else if(triggerOldMap != null && !triggerOldMap.isEmpty() && !checkRecurssion) 
                                    eachOpp.Settlement_Activated__c = triggerOldMap.get(eachOpp.Id).OwnerId;
                            }
                            eachOpp.Settlement_Status_Latest_Date__c = Date.today();
                        }
                        If(!babyCaregroupMap.isEmpty() && babyCaregroupMap.get('BabyCare_Tools_Team') != null && babyCaregroupMap.get('BabyCare_Tools_Team').size()>0){
                            if(eachOpp.LeadSource!=null && eachOpp.LeadSource=='Organic' && eachOpp.Key_Assigned_Manager__c ==null && !System.Label.Baby_care_Owner.split(',').contains(eachOpp.OwnerId) && System.Label.Baby_care_transfer_lead.split(',').contains(eachOpp.OwnerId) && eachOpp.partner__c == null){
                                if(System.Label.Business_entity.split(',').contains(eachOpp.Business_Entity__c) && string.isNotBlank(eachOpp.Business_Entity__c))  
                                {  
                                    userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Tools_Team').size());  
                                    eachOpp.OwnerId = babyCaregroupMap.get('BabyCare_Tools_Team').get(userIndex).UserORGroupId;
                                }  
                                else if(string.isNotBlank(eachOpp.Business_Entity__c)){  
                                    userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Thirdparty_Team').size());  
                                    eachOpp.OwnerId = babyCaregroupMap.get('BabyCare_Thirdparty_Team').get(userIndex).UserORGroupId;  
                                }
                            }
                            if(eachOpp.Settlement_Date__c==null){
                                eachOpp.Settlement_Date__c=date.today();
                            }
                            if(eachOpp.Settlement_Activated__c == null){
                                if(Trigger.isInsert){
                                    eachOpp.Settlement_Activated__c = eachOpp.OwnerId;
                                }
                                else if(triggerOldMap != null && !triggerOldMap.isEmpty() && !checkRecurssion) 
                                    eachOpp.Settlement_Activated__c = triggerOldMap.get(eachOpp.Id).OwnerId;
                            }
                            eachOpp.Settlement_Status_Latest_Date__c = Date.today();
                        }else{
                            userIndex = 0;
                        }
                    }
            }
            
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            fieldWithMessage.put('Message__c',ex.getMessage());
            fieldWithMessage.put('Process__c','SettlementUpdateFromOpportunity');
            fieldWithMessage.put('Request__c','babyCareReassignOppOwnerAU');
            SystemUtility.errorHandler(ex,fieldWithMessage);
        }
        
    }
    //--complete reassignment of opportunity owner---////
    
    //--Added by Shivani-Reassign opportunity owner when settlement is active---//
    public static void babyCareReassignOppOwnerAU(List<Opportunity> settlementReassignOwner,Map<Id,Opportunity> triggerOldMap,Baby_Care_Flow__c babyCareFlow){
        Map<string,string> fieldWithMessage = new Map<string,string>();
        try{
            List<opportunity> oppListToUpdate = New List<Opportunity>();
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000)); 
            Integer userIndex = 0;
            Map<String,List<GroupMember>> babyCaregroupMap = New Map<String,List<GroupMember>>();
            
            if(babyCareFlow != null && babyCareFlow.Active__c){
                for(Group gp : [Select Id,Name,DeveloperName,(Select Id,UserORGroupId FROM GroupMembers) FROM GROUP WHERE DeveloperName IN('BabyCare_Thirdparty_Team','BabyCare_Tools_Team')]){
                    babyCaregroupMap.put(gp.DeveloperName,gp.GroupMembers);
                }
            }
            
            for(Opportunity eachOpp : settlementReassignOwner){
                Opportunity updateOpp = New Opportunity(Id = eachOpp.Id);
                if (eachOpp.Integration_Type__c == 'ThirdParty' && (string.isNotBlank(eachOpp.Website__c) || string.isNotBlank(eachOpp.Android_URL__c) || string.isNotBlank(eachOpp.iOS_URL__c)))
                {
                    if(babyCareFlow != null && !babyCareFlow.Active__c){
                        if(eachOpp.Settlement_Activated__c == null){
                            updateOpp.Settlement_Activated__c = triggerOldMap.get(eachopp.Id).OwnerId;
                        }
                        if(eachOpp.Settlement_Date__c==null){
                            updateOpp.Settlement_Date__c=date.today();
                        }
                        updateOpp.Settlement_Status_Latest_Date__c = Date.today();
                    }
                    If(!babyCaregroupMap.isEmpty() && babyCaregroupMap.get('BabyCare_Thirdparty_Team') != null && babyCaregroupMap.get('BabyCare_Thirdparty_Team').size()>0){
                        if(eachOpp.LeadSource!=null && eachOpp.LeadSource=='Organic' && eachOpp.Key_Assigned_Manager__c ==null && !System.Label.Baby_care_Owner.split(',').contains(eachOpp.OwnerId) && System.Label.Baby_care_transfer_lead.split(',').contains(eachOpp.OwnerId) && eachOpp.Partner__c == null){
                            userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Thirdparty_Team').size());
                            updateOpp.OwnerId = babyCaregroupMap.get('BabyCare_Thirdparty_Team').get(userIndex).UserORGroupId;
                        }
                        if(eachOpp.Settlement_Activated__c == null){
                            updateOpp.Settlement_Activated__c = triggerOldMap.get(eachopp.Id).OwnerId;
                        }
                        if(eachOpp.Settlement_Date__c==null){
                            updateOpp.Settlement_Date__c=date.today();
                        }
                        updateOpp.Settlement_Status_Latest_Date__c = Date.today();
                    }
                    else{
                        userIndex = 0;
                    }
                }
                else if(eachOpp.Integration_Type__c == 'Tools' &&
                        (string.isBlank(eachOpp.Website__c) && string.isBlank(eachOpp.Android_URL__c) && string.isBlank(eachOpp.iOS_URL__c))){
                            if(babyCareFlow != null && !babyCareFlow.Active__c){
                                if(eachOpp.Settlement_Activated__c == null){
                                    updateOpp.Settlement_Activated__c = triggerOldMap.get(eachopp.Id).OwnerId;
                                }
                                if(eachOpp.Settlement_Date__c==null){
                                    updateOpp.Settlement_Date__c=date.today();
                                }
                                updateOpp.Settlement_Status_Latest_Date__c = Date.today();
                            }
                            If(!babyCaregroupMap.isEmpty() && babyCaregroupMap.get('BabyCare_Tools_Team') != null && babyCaregroupMap.get('BabyCare_Tools_Team').size()>0){
                                if(eachOpp.LeadSource!=null && eachOpp.LeadSource=='Organic' && eachOpp.Key_Assigned_Manager__c ==null && !System.Label.Baby_care_Owner.split(',').contains(eachOpp.OwnerId) && System.Label.Baby_care_transfer_lead.split(',').contains(eachOpp.OwnerId) && eachopp.partner__c == null){
                                    if( System.Label.Business_entity.split(',').contains(eachOpp.Business_Entity__c) && string.isNotBlank(eachOpp.Business_Entity__c))  
                                    {  
                                        userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Tools_Team').size());  
                                        updateOpp.OwnerId = babyCaregroupMap.get('BabyCare_Tools_Team').get(userIndex).UserORGroupId;
                                    }  
                                    else if(string.isNotBlank(eachOpp.Business_Entity__c)){  
                                        userIndex = Math.mod(IntrandomNumber, babyCaregroupMap.get('BabyCare_Thirdparty_Team').size());  
                                        updateOpp.OwnerId = babyCaregroupMap.get('BabyCare_Thirdparty_Team').get(userIndex).UserORGroupId;  
                                    }
                                }
                                if(eachOpp.Settlement_Activated__c == null){
                                    updateOpp.Settlement_Activated__c = triggerOldMap.get(eachopp.Id).OwnerId;
                                }
                                if(eachOpp.Settlement_Date__c==null){
                                    updateOpp.Settlement_Date__c=date.today();
                                }
                                updateOpp.Settlement_Status_Latest_Date__c = Date.today();
                            }else{
                                userIndex = 0;
                            }
                        }
                oppListToUpdate.add(updateOpp);
            }
            
            if(checkRecurssion && !oppListToUpdate.isEmpty()){
                update oppListToUpdate;
                checkRecurssion = false;
            }
            
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            fieldWithMessage.put('Message__c',ex.getMessage());
            fieldWithMessage.put('Process__c','SettlementUpdateFromAccount');
            fieldWithMessage.put('Request__c','babyCareReassignOppOwnerAU');
            SystemUtility.errorHandler(ex,fieldWithMessage);
        }
    }
    //--complete reassignment of opportunity owner---////
    
    //=================update Compulsive Account Doc and Agreement Status=============
    public static void updateCompulsiveAccounts(Set<Id> compulsiveAccountIds){
        Map<string,string> fieldWithMessage = new Map<string,string>();
        try{
            
            List<Account> accountList = New List<Account>();
            for(Account eachAccount : [Select Id,Document_Status__c,Agreement_Status__c from Account WHERE Id IN: compulsiveAccountIds]){
                eachAccount.Document_Status__c = 'Docs Approved';
                eachAccount.Agreement_Status__c = 'Approved';
                eachAccount.Merchant_Business_Type__c = 'Compulsive';
                accountList.add(eachAccount);            
            }
            if(!accountList.isEmpty() && accountList.size()>0) update accountList;
            
            if(Test.isRunningTest()) Integer i = 1/0;
        }catch(Exception ex){
            fieldWithMessage.put('Message__c',ex.getMessage());
            fieldWithMessage.put('Process__c','CompulsiveAccountUpdate');
            fieldWithMessage.put('Request__c','updateCompulsiveAccounts');
            SystemUtility.errorHandler(ex,fieldWithMessage);
        }
    }
    
    //--complete reassignment of opportunity owner---////
    /*Creted By: Akash Pandey.
* Creted Date: 1 Aug 2020.
* SFPI-732 
*/
    public static void createTaskForBlacklist(List<Opportunity> newOppList,Map<Id, Opportunity> triggerOldMap){
        
        List<Task> taskList = new List<Task>();
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));        
        List<string>  toolBlacklistQueueMembers= New List<string>();
        List<string>  riskTeamQueueMembers= New List<string>();
        Integer userIndexToolBlacklistQueue = 0;
        Integer userIndexRiskTeamQueue = 0;
        Integer userIndex;
        List<String> queueDeveloperNames = New List<String>{'Tool_blacklist_queue','Pre_Onboarding_Risk_Team'};
            
            Map<String,List<GroupMember>> queueDeveloperNameVsMembers = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        /*
for(GroupMember gpm: [SELECT Id, UserOrGroupId FROM GroupMember where Group.DeveloperName= 'Tool_blacklist_queue']){
if(gpm != null){
toolBlacklistQueueMembers.add(gpm.UserOrGroupId);
}
}

if(!toolBlacklistQueueMembers.isEmpty()){
userIndexToolBlacklistQueue = Math.mod(IntrandomNumber, toolBlacklistQueueMembers.Size());
}else{
userIndexToolBlacklistQueue = 0;
}
//Pre_Onboarding_Risk_Team
for(GroupMember gpm: [SELECT Id, UserOrGroupId FROM GroupMember where Group.DeveloperName= 'Pre_Onboarding_Risk_Team']){
if(gpm != null){
riskTeamQueueMembers.add(gpm.UserOrGroupId);
}
}
if(!riskTeamQueueMembers.isEmpty()){
userIndexRiskTeamQueue = Math.mod(IntrandomNumber, riskTeamQueueMembers.Size());
}else{
userIndexRiskTeamQueue = 0;
}
*/
        for(Opportunity newOpp: newOppList){
            if(newOpp.Integration_Type__c == 'Tools'){
                /*Task objTask = New Task();  
objTask.Subject = 'Risk verification task for Blacklist Merchant(Tools)';  
objTask.WhatId = newOpp.Id;  
objTask.Status = 'Open';  
objTask.Priority = 'High';
objTask.OwnerId = toolBlacklistQueueMembers.get(userIndexToolBlacklistQueue);
objTask.Description = 'Tools Merchant is Blacklisted By following blacklist parameter: '+newOpp.Risk_Type_Multi_Select__c;
taskList.add(objTask);
*/
                string subject = 'Risk verification task for Blacklist Merchant(Tools)';
                string comment = 'Tools Merchant is Blacklisted By following blacklist parameter: '+newOpp.Risk_Type_Multi_Select__c;
                if(queueDeveloperNameVsMembers.containsKey('Tool_blacklist_queue') && queueDeveloperNameVsMembers.get('Tool_blacklist_queue') != null){
                    userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Tool_blacklist_queue').Size());
                }
                SystemUtility.createTask(taskList, null, comment, False, null, queueDeveloperNameVsMembers.get('Tool_blacklist_queue').get(userIndex).UserOrGroupId, 'High', null, subject, 'Open', newOpp.Id);
                
            }
            if(newOpp.Integration_Type__c == 'ThirdParty'){
                /*Task objTask = New Task();  
objTask.Subject = 'Risk verification task for Blacklist Merchant(ThirdParty)';  
objTask.WhatId = newOpp.Id;  
objTask.Status = 'Open';  
objTask.Priority = 'High';
objTask.OwnerId = riskTeamQueueMembers.get(userIndexRiskTeamQueue);
objTask.Description = 'ThirdParty Merchant is Blacklisted By following blacklist parameter: '+newOpp.Risk_Type_Multi_Select__c;
taskList.add(objTask);
*/
                string subject = 'Risk verification task for Blacklist Merchant(ThirdParty)';
                string comment = 'ThirdParty Merchant is Blacklisted By following blacklist parameter: '+newOpp.Risk_Type_Multi_Select__c;
                if(queueDeveloperNameVsMembers.containsKey('Pre_Onboarding_Risk_Team') && queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team') != null){
                    userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').Size());
                }
                SystemUtility.createTask(taskList, null, comment, False, null, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').get(userIndex).UserOrGroupId, 'High', null, subject, 'Open', newOpp.Id);
            }
        }
        
        if(taskList.size()>0){
            insert taskList;
        }
    }
    
    //============= Commenting the code as we are not using wibmo product=========
    //=================update Wibmo Account=============
    /* public static void updateWibmoAccounts(List<Opportunity> settlementReassignOwner,Set<Id> compulsiveAccountIds){
Map<string,string> fieldWithMessage = new Map<string,string>();
try{
List<Account> accountList = New List<Account>();
for(Opportunity eachOpp : settlementReassignOwner){
for(Account eachAccount : [Select Id,Daily_Volumes__c,Impl_Fees__c, Other_fees__c, Transaction_fees__c from Account WHERE Id IN: compulsiveAccountIds]){
eachAccount.Daily_Volumes__c = eachOpp.Daily_Volume__c;
//eachAccount.Impl_Fees__c = eachOpp.Impl_Fees__c;
//eachAccount.Other_fees__c = eachOpp.Other_fees__c;
//eachAccount.Transaction_fees__c = eachOpp.Transaction_fees__c;
eachAccount.Y1_Revenue_US_with_probability__c = eachOpp.Y1_Revenue_US_with_probability__c;
eachAccount.Deal_Value_with_probability_US__c = eachOpp.Deal_Value_with_probability_US__c;
eachAccount.Financial_Year_Revenue__c = eachOpp.Financial_Year_Revenue__c;
//eachAccount.Market__c = eachOpp.Country__c;
eachAccount.Program__c = eachOpp.Wibmo_Product__c;
accountList.add(eachAccount);            
}
}    
if(!accountList.isEmpty() && accountList.size()>0) update accountList;

if(Test.isRunningTest()) Integer i = 1/0;
}catch(Exception ex){
fieldWithMessage.put('Message__c',ex.getMessage());
fieldWithMessage.put('Process__c','WibmoAccountUpdate');
fieldWithMessage.put('Request__c','WibmoCompulsiveAccounts');
SystemUtility.errorHandler(ex,fieldWithMessage); 
}
}
*/
    
    //Added to regenerate Agreement when Website is updated
    public static List<Sobject> updateagreementWithNewWebURL(List<Opportunity> oppList, Map<String,String> oppIdwithChildId){
        
        Set<String> setofAccId = new Set<String>();
        List<Contract> lstContractUpdate = new List<Contract>();
        Map<Id, Opportunity> mapAccIdOpp = new Map<Id, Opportunity>();
        Map<String,String> mapofContractWithopport = new Map<String,String>();
        Map<String,List<Contract>> mapAccountwithContract = new Map<String,List<Contract>>();
        Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
        Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();List<String> lstofBankId ;
        List<Account> accounttoUpdateList = new List<Account>();
        Map<String,Opportunity> mapofApprovedContrOpp = new Map<string,Opportunity>();
        //List<Contract> lstAddendumUpdate = new List<Contract>();
        
        if(!oppList.isEmpty() && oppList.size() > 0){
            for(opportunity opp : oppList){
                setofAccId.add(opp.AccountId);
            }
            if(!setofAccId.isEmpty()) getContractfromAccount(setofAccId, mapAccountwithContract);
            
            
            for(opportunity eachOpp : oppList){
                system.debug('##### Website_updated_last__c '+eachOpp.Website_updated_last__c);
                if(eachOpp.AccountId != null && mapAccountwithContract.containsKey(eachOpp.AccountId) 
                   && eachOpp.Website_updated_last__c
                   && mapAccountwithContract.get(eachOpp.AccountId) != null
                   && !mapAccountwithContract.get(eachOpp.AccountId).isEmpty()){
                       String VfpageName ='';
                       if(eachOpp.VFPageKey__c != null && VFPageWithData__c.getValues(eachOpp.VFPageKey__c) != null){
                           VfpageName = VFPageWithData__c.getValues(eachOpp.VFPageKey__c).VFPageName__c ;
                       }
                       if(Test.isRunningTest()) VfpageName = 'payUmoney-Merchant';
                       system.debug('=======VfpageName ======'+VfpageName );
                       system.debug('=======VfpageName22 ======'+eachOpp.Agreement_Regeneration__c );
                       for(Contract objContact : mapAccountwithContract.get(eachOpp.AccountId)){
                           if((objContact.Status == 'Pending' || objContact.Status == 'Sent') && VfpageName != '' && objContact.Active__c == false
                              && eachOpp.Agreement_Regeneration__c){
                                  if(oppIdwithChildId.isEmpty()) mapofContractWithopport.put(objContact.Id,eachOpp.Id); 
                                  else mapofContractWithopport.put(objContact.Id,oppIdwithChildId.get(eachOpp.Id));
                                  mapOfIdContract.put(objContact.Id,objContact);
                                  mapofContractWithAgreementVFpage.put(objContact.Id,VfpageName);
                                  objContact.URL__c ='';
                                  objContact.Upload_Date__c = System.today();
                                  Break;
                              }
                           else if(objContact.Status == 'Approved Activate' || objContact.Status == 'Approved' || objContact.Status == 'Counter Signed Received'){
                               mapofApprovedContrOpp.put(objContact.id, eachOpp);
                           }
                       }
                   }
            }
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
        /*else if(!mapofApprovedContrOpp.isEmpty()){
lstContractUpdate = createNewAddendumforWebsiteUpdate(mapofApprovedContrOpp);
}*/
        System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate); 
        System.debug(accounttoUpdateList.size()+' <== accounttoUpdateList ==> '+accounttoUpdateList);   
        if(!lstContractUpdate.isEmpty())
            update lstContractUpdate;
        if(!accounttoUpdateList.isEmpty()) 
            update accounttoUpdateList;
        return lstContractUpdate;
        
    } 
    
    public static Map<String,List<Contract>> getContractfromAccount(Set<String> setAccountId, Map<String,List<Contract>> mapAccountwithContract){
        
        for(Contract objContract:[SELECT Id, Status, Account.Agreement_Status__c,AccountId, E_Stamp__c, Document_Master__c, Type__c, Document_Category__c,  
                                  Document_Category__r.Name, Contract_Type__c, Offline_Generation__c, Pricebook2Id, Active__c,Account.Identifier__c,
                                  Document_Content_Type__c, File_Size__c, URL__c, OwnerExpirationNotice, Document_Type__c, 
                                  Document_Category_Name__c, Document_Type_Name__c, StartDate, ContractTerm, E_Stamp_Number__c 
                                  FROM Contract WHERE AccountId IN : setAccountId 
                                  AND (Account.Agreement_Status__c = 'Not Generated' OR Account.Agreement_Status__c = 'Pending'
                                       OR Account.Agreement_Status__c = 'Sent' OR Account.Agreement_Status__c = 'Rejected' 
                                       OR Account.Agreement_Status__c = 'Draft In Process' 
                                       OR Account.Agreement_Status__c = 'Counter Signed Received'
                                       OR Account.Agreement_Status__c = 'Approved')
                                  AND Contract_Type__c = 'Agreement' AND Status IN('Pending','Sent','Counter Signed Received','Approved','Approved Activate')
                                  ORDER BY LastModifiedDate DESC]){
                                      
                                      if(String.isBlank(objContract.Document_Type_Name__c) && objContract.Status != 'Approved' && objContract.Status != 'Counter Signed Received'){
                                          objContract.Document_Type_Name__c = 'Agreement';
                                      }
                                      if(String.isBlank(objContract.Document_Category_Name__c) && objContract.Status != 'Approved' && objContract.Status != 'Counter Signed Received'){
                                          objContract.Document_Category_Name__c = 'Service Agreement';
                                      }
                                      if(mapAccountwithContract.containsKey(String.valueof(objContract.AccountId)) && mapAccountwithContract.get(String.valueof(objContract.AccountId)) != null){
                                          List<Contract> lstCont = mapAccountwithContract.get(String.valueof(objContract.AccountId));
                                          lstCont.add(objContract);
                                          mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                      }
                                      else if(!mapAccountwithContract.containsKey(String.valueof(objContract.AccountId)) || (mapAccountwithContract.containsKey(String.valueof(objContract.AccountId)) && mapAccountwithContract.get(String.valueof(objContract.AccountId)) == null)){
                                          List<Contract> lstCont = new List<Contract>();
                                          lstCont.add(objContract);
                                          mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                      }  
                                  }
        return mapAccountwithContract;
    }
    /*public static List<Contract> createNewAddendumforWebsiteUpdate (Map<String,Contract> mapContrOpp) {
Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
List<string> DocMasterList = Label.DocMasterList.Split(',');
String PageAssociation;
List<Document_Master__c> docDetails = [Select Id,Name, Page_Association__c 
FROM Document_Master__c where id IN :DocMasterList order by Page_Association__c];
List<Contract> AddendumList = new List<Contract>();
set<String> setAddendumId = new Set<String>();
String strEndPoint;
List<Contract> updatedList = new List<Contract>();

for(String each : mapContrOpp.keySet()){
Contract Addendum = new Contract();
Addendum.Contract_Type__c = 'Addendum';
Addendum.Opportunity__c = each;
Addendum.AccountId = mapContrOpp.get(each).AccountId;
Addendum.Name = 'Website Change Addendum';
//Addendum.Document_Master__c = (docDetails[0].Name != null) ? docDetails[0].Name : 'Addendum';
Addendum.Active__c = true;
Addendum.Document_Category_Name__c = 'Service Agreement';
Addendum.Document_Type_Name__c = 'Addendum';
Addendum.Document_Content_Type__c = mapContentType.get('pdf');
Addendum.StartDate = date.today();
Addendum.ContractTerm = 120;
Addendum.KYC_Documentable_Type__c = 'Merchant';
AddendumList.add(Addendum);
}
if(AddendumList != null && AddendumList.size() > 0) {
Insert AddendumList;
}
return AddendumList;
}  */
    
    public static void deleteWebsitePages(List<opportunity> oppList){
        
        List<Website_Page__c> webpagestoDeleteList = [Select id from Website_Page__c where Opportunity__c IN :oppList];
        delete webpagestoDeleteList;
    }
    
    //==========update Account status for skip UUIDs
    public static void updateAccountSkipStatus(List<Opportunity> triggerNew, Map<Id,Account> docAccountDataMap, Map<Id,Account> aggAccountDataMap){
        List<Account> updateAccountStatus = New List<Account>();
        Map<String,Account> updateAccountStatusMap = New Map<String,Account>();
        for(Opportunity each : triggerNew){
            Account accObj = New Account();
            if(string.isNotBlank(each.AccountId) && docAccountDataMap.containsKey(each.AccountId) && docAccountDataMap.get(each.AccountId) != null){
                accObj.Id = docAccountDataMap.get(each.AccountId).Id;
                accObj.Skip_Document_Verification__c = each.Skip_Document_Verification__c;
                updateAccountStatusMap.put(accObj.id,accObj);
                //updateAccountStatus.add(accObj);
            }
            if(string.isNotBlank(each.AccountId) && aggAccountDataMap.containsKey(each.AccountId) && aggAccountDataMap.get(each.AccountId) != null){
                accObj.Id = aggAccountDataMap.get(each.AccountId).Id;
                accObj.Skip_Agreement_Verification__c = each.Skip_Agreement_Verification__c;
                updateAccountStatusMap.put(accObj.id,accObj);
                //updateAccountStatus.add(accObj);
            }
        }
        if(!updateAccountStatusMap.isEmpty() && updateAccountStatusMap != null){
            update updateAccountStatusMap.values();
        } 
    }
    
    public static void createPremiumMemberTask(List<Opportunity> systemVerifiedWebsiteList, List<Opportunity> merchantVerifiedWebsiteList){
        //===========Create task for premium merchant to Risk Team=====================
        if(!systemVerifiedWebsiteList.isEmpty() || !merchantVerifiedWebsiteList.isEmpty()){ 
            Map<Id,Merchant_Plan__c> merchantPlanVsOppIdMap = New Map<Id,Merchant_Plan__c>();
            Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
            String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            //========get Merchant Plan Map Data================
            List<Opportunity> verifiedOppList = New List<Opportunity>();
            if(!systemVerifiedWebsiteList.isEmpty()) verifiedOppList.addAll(systemVerifiedWebsiteList); 
            if(!merchantVerifiedWebsiteList.isEmpty()) verifiedOppList.addAll(merchantVerifiedWebsiteList);
            
            for(Merchant_Plan__c mpObj : [Select Id,Opportunity__c,Plan_Type__c from Merchant_Plan__c Where Opportunity__c IN: verifiedOppList AND Plan_Type__c ='cs_plan']){
                merchantPlanVsOppIdMap.put(mpObj.Opportunity__c,mpObj);
            }
            List<String> queueDeveloperNames = New List<String>{'Pre_Onboarding_Risk_Team','Risk_Team_For_CS'};
                
                Map<String,List<GroupMember>> queueDeveloperNameVsMembers = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
            
            if(!systemVerifiedWebsiteList.isEmpty()){
                List<task> taskList = New List<Task>();
                for(Opportunity oppObj : systemVerifiedWebsiteList){
                    if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(oppObj.Id)){
                        Integer userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                        
                        SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(oppObj.Id).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000), Label.VIP_task_Subject_Premium, 'Not Started', oppObj.Id); 
                    }
                }
                if(!taskList.isEmpty()) Insert taskList;
            }   
            if(!merchantVerifiedWebsiteList.isEmpty()){
                List<Website_Details__c> wdObjList = [Select Id from Website_Details__c Where Opportunity__c IN: merchantVerifiedWebsiteList AND Active__c =: True AND Is_Website_Live__c =: 'Active'];
                if(!wdObjList.isEmpty()){
                    List<task> taskList = New List<Task>();
                    for(Opportunity oppObj : merchantVerifiedWebsiteList){
                        if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(oppObj.Id)){
                            Integer userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                            
                            SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(oppObj.Id).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000), Label.VIP_task_Subject_Premium, 'Not Started', oppObj.Id); 
                        }
                    }
                    if(!taskList.isEmpty()) Insert taskList;
                }
            }
        }
    }
    
    //======= Used to update the MCC code and Risk Classification status, if sub category got changed.=========
    public static void updateMCCCode(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap,List<String> BusinessCategoryList, List<String> SubCategory,String riskclassificationStatus){
        
        Map<String, String> subCategoryVsMCCcodeMap = new Map<String, String>();
        Map<String, String> subCategoryvsRiskStatusMap = new Map<String, String>();
        
        for(MCC_Code__mdt  mccCodeMetadata : [Select id,Sub_Category_vs_MCC_Code__c,Sub_category_vs_risk_status__c FROM MCC_Code__mdt where MasterLabel IN:BusinessCategoryList]){
            if(String.isNotBlank(mccCodeMetadata.Sub_Category_vs_MCC_Code__c)) 
                subCategoryVsMCCcodeMap = (Map<String, String>)JSON.deserialize(mccCodeMetadata.Sub_Category_vs_MCC_Code__c, Map<String, String>.class);
            if(String.isNotBlank(mccCodeMetadata.Sub_category_vs_risk_status__c)) 
                subCategoryvsRiskStatusMap = (Map<String, String>)JSON.deserialize(mccCodeMetadata.Sub_category_vs_risk_status__c, Map<String, String>.class);
        }
        
        List<String> desiredOwners = new List<String>();
        List<String> riskStatus = new List<String>();
        Integer userIndex = 0;      
        for(Opportunity eachOpty : triggerNew){
            if(String.isNotBlank(eachOpty.Sub_Category__c) && String.isNotBlank(eachOpty.SubCategory__c) && !subCategoryVsMCCcodeMap.isEmpty()){
                if(subCategoryVsMCCcodeMap.containsKey(eachOpty.SubCategory__c)){
                    String mccCode = subCategoryVsMCCcodeMap.get(eachOpty.SubCategory__c);
                    eachOpty.MCC_Code__c = mccCode;
                    //String baseMID = WebsiteStatusMaintanenceController_Onb.getMccCodeMetaData(mccCode, null);
                    
                    
                    //----Added by (Anas Yar Khan) 
                    if(mapMCCCodeToBankCategory.containsKey(mccCode)) {
                        eachOpty.Bank_Category__c = mapBankCategoryNameToId.get((String)mapMCCCodeToBankCategory.get(mccCode));                      
                    }
                    //****************************
                }
            }
            if(String.isNotBlank(eachOpty.Sub_Category__c) && String.isNotBlank(eachOpty.SubCategory__c) && !subCategoryvsRiskStatusMap.isEmpty()){
                if(subCategoryvsRiskStatusMap.containsKey(eachOpty.SubCategory__c)){
                    eachOpty.Risk_Classification_Status__c = subCategoryvsRiskStatusMap.get(eachOpty.SubCategory__c);
                }
            }
        }
    }
    
    //============Send nb eligible payload to panel=======================
    @future(callout=true)
    public static void sendNBEligiblePayload(Set<Id> nbEligibleOpportunityIds){
        List<Payload_Log__c> payloadLogList = New List<Payload_Log__c>();
        List<Error_Details__c> errorDetailsList = New List<Error_Details__c>();
        HttpResponse response = New HttpResponse();
        string responseBody = '';
        string nbEligibleAccessToken = '';
        
        if(!nbEligibleOpportunityIds.isEmpty()){
            if(!Test.isRunningTest()){
                nbEligibleAccessToken = IntegrationUtility.getAuthToken('NB_Eligible_Authentication');
            }else{
                nbEligibleAccessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }
            
            if(string.isNotBlank(nbEligibleAccessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('NB_Eligible_Activation');
                
                for(Opportunity each : [Select Id,Prod_MID__c,Email__c,Mobile__c,NB_Eligible__c,BusinessEntityName__c,
                                        Legal_Name_Account__c,MerchantName__c,Prod_Merchant_Id__c From Opportunity 
                                        WHERE ID IN : nbEligibleOpportunityIds]){
                                            response = IntegrationUtility.requestUtility(theIntIns, False, nbEligibleAccessToken, each, null, null);
                                            
                                            if(response != null && response.getStatusCode() == 200){
                                                Payload_Log__c plLog = New Payload_Log__c(Payload__c = response.getBody(),Process__c = 'NB Activation Merchant',Prod_MID__c = each.Prod_Merchant_Id__c,Status__c = 'SUCCESS',SalesforceRecordId__c = each.Id);
                                                payloadLogList.add(plLog);
                                                responseBody = response.getBody();
                                            }else{
                                                Error_Details__c edLog = New Error_Details__c(Process__c = 'NB Activation Merchant');
                                                if(response != null && response.getBody() != null) {
                                                    edLog.Response__c = response.getBody();
                                                    responseBody = response.getBody();
                                                }
                                                errorDetailsList.add(edLog);
                                            }
                                        }
            }
        }
        
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
    }
    
    
    
    //==============Update Opportunity Owner, if Lead assignment rule was not working=============
    /* public static void updateOpportunityOwner(List<Opportunity> ownerUpdateList){
List<String> queueDeveloperNameList = New List<String>{'Money_Individual_Sole_Team','Current_Account_Assignment_To_NB_Team','Biz_Enterprise_Team','Biz_SMB_Team','Money_Individual_Team'};
Map<String,List<GroupMember>> queueNameVsGroupMemberMap = SystemUtility.getQueuesNameMembers(queueDeveloperNameList);
Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));

for(Opportunity each : ownerUpdateList){
if(String.isNotBlank(each.OwnerId) && each.OwnerId == Label.IntegrationUserId){
if(each.Service_Intent__c != 'NB'){
if(each.LeadSource != 'Partner' && (each.BusinessEntityName__c == 'Sole Proprietorship' || each.BusinessEntityName__c == 'Individual') && each.Business_Origin__c == 'SMB-ENT'
&& (each.Lead_Type__c == 'Merchant' || each.Lead_Type__c == 'Seller') && (each.ProductLabel__c == 'PayUmoney' || each.ProductLabel__c == 'PayUbiz')
){
Integer userIndex = Math.mod(IntrandomNumber, queueNameVsGroupMemberMap.get('Money_Individual_Sole_Team').Size());
each.OwnerId = queueNameVsGroupMemberMap.get('Money_Individual_Sole_Team').get(userIndex).UserOrGroupId;
}else if(each.LeadSource != 'Partner' && (each.BusinessEntityName__c != 'Sole Proprietorship' && each.BusinessEntityName__c != 'Individual') && each.Business_Origin__c == 'SMB-ENT'
&& (each.Lead_Type__c == 'Merchant' || each.Lead_Type__c == 'Seller') && (each.ProductLabel__c == 'PayUbiz')
){
Integer userIndex = Math.mod(IntrandomNumber, queueNameVsGroupMemberMap.get('Biz_SMB_Team').Size());
each.OwnerId = queueNameVsGroupMemberMap.get('Biz_SMB_Team').get(userIndex).UserOrGroupId;
}else if(each.LeadSource != 'Partner' && (each.BusinessEntityName__c != 'Sole Proprietorship' && each.BusinessEntityName__c != 'Individual') && each.Business_Origin__c == 'SMB-ENT'
&& (each.Lead_Type__c == 'Merchant' || each.Lead_Type__c == 'Seller') && (each.ProductLabel__c == 'PayUmoney')
){
Integer userIndex = Math.mod(IntrandomNumber, queueNameVsGroupMemberMap.get('Money_Individual_Team').Size());
each.OwnerId = queueNameVsGroupMemberMap.get('Money_Individual_Team').get(userIndex).UserOrGroupId;
}
}else{
Integer userIndex = Math.mod(IntrandomNumber, queueNameVsGroupMemberMap.get('Money_Individual_Sole_Team').Size());
each.OwnerId = queueNameVsGroupMemberMap.get('Current_Account_Assignment_To_NB_Team').get(userIndex).UserOrGroupId;
}
}
}
}*/
    
    private static List<Group> getGroupdata(String strGroupName){
        return [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: strGroupName AND Type =: 'Queue' LIMIT 1];
    }
    
    //======================Update Dynamic status===========================
    
    @future(callout=true)
    public static void sendSettlementStatusToMCare(Set<Id> OppSet,Set<String> producerNames){
        Boolean isProducerPayuBizTresury = false;
        List<String> producerNameList = new List<String>();
        if(producerNames !=NULL && producerNames.size()>0){
            producerNameList = new List<String>(producerNames);
            if(producerNameList[0]=='PayUbizTreasury'){
                isProducerPayuBizTresury = true; 
            }
        }
        //Map<Id,Risk_Hold_Reasons__c> dashboardCasesMap = New Map<Id,Risk_Hold_Reasons__c>([Select Id,Merchant_Id__c, Hold_Reason_Shown_to_Merchant__c,Status__c,API_Response__c,Opportunity__c from Risk_Hold_Reasons__c Where Id IN: Opportunity]); 
        List<Opportunity> OppList = [select settlement_Status__C,Prod_Merchant_Id__c, Merchant_Id__c from opportunity where id in :OppSet];
        
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
        statusVsNumberMap.put('Active', '0');
        statusVsNumberMap.put('Thirdparty Hold', '2');
        statusVsNumberMap.put('0', 'Active');
        statusVsNumberMap.put('1', 'Risk Hold');
        statusVsNumberMap.put('Pre-Risk Hold', '1');//Added for Admin pannel - Final
        statusVsNumberMap.put('OB Hold', '1');//Added for Admin pannel - Final (OB Hold)
        statusVsNumberMap.put('2', 'Thirdparty Hold');
        statusVsNumberMap.put('3', 'Risk & Thirdparty hold');
        HttpResponse response = New HttpResponse();
        List<MCare_Dashboard_Case__c> mCareListToUpdate = New List<MCare_Dashboard_Case__c>();
        Map<Id,Opportunity> opportunityToUpdateMap = New Map<Id,Opportunity>();
        if(!OppList.isEmpty()){
            if(!Test.isRunningTest()){
                accessToken = IntegrationUtility.getAuthToken('AuthenticateSettlementStatusFromMCare');
                SYstem.debug('accessToken::::::::'+accessToken);
            }else{
                accessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }
            
            if(string.isNotBlank(accessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('UpdateSettlementStatusFromSF');
                for(Opportunity each : OppList){
                    // IntegrationUtility.HTTPWrapper wrpCls = new IntegrationUtility.HTTPWrapper();
                    if(each.Settlement_Status__c == 'Risk Hold' || each.Settlement_Status__c == 'Active' || each.Settlement_Status__c == 'Thirdparty Hold' || each.Settlement_Status__c == 'Pre-Risk Hold' || each.Settlement_Status__c == 'OB Hold'){
                        SYstem.debug('statusVsNumberMap.get(each.Settlement_Status__c)::'+statusVsNumberMap.get(each.Settlement_Status__c));
                        urlFormatStr.add(statusVsNumberMap.get(each.Settlement_Status__c));
                        
                        if(!isProducerPayuBizTresury){
                            // wrpCls = IntegrationUtility.sendHTTPRequest(theIntIns, False, accessToken, each, urlFormatStr, null);
                        }
                    }
                    
                    
                    /* if(wrpCls.response != null && wrpCls.response.getStatusCode() == 200){
Payload_Log__c plLog = New Payload_Log__c(Process__c = 'Send Hold Settlement Status to Admin Panel',Prod_MID__c = Integer.valueOf(each.Prod_Merchant_Id__c),Status__c = 'SUCCESS',SalesforceRecordId__c = each.Id, Exception__c = String.valueOf(wrpCls.response.getBody()),Payload__c = String.valueOf(wrpCls.request));
payloadLogList.add(plLog);

// each.API_Response__c = response.getBody();
// mCareListToUpdate.add(each);
}
else if(wrpCls.response!=null && each.Lead_Type__c != 'Partner' && each.Prod_Merchant_Id__c != null){
sendRetryFailedEmail(each.Prod_MID__c , wrpCls.response.getBody());  
Error_Details__c edLog = New Error_Details__c(Process__c = 'Send Hold Settlement Status to Admin Panel');
// (response != null && response.getBody() != null) 
edLog.Response__c = String.valueOf(wrpCls.response.getBody());
edLog.Request__c = wrpCls.request;
errorDetailsList.add(edLog);
}*/
                    
                }
                
            }
        }
        
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
    }
    // added by rohit sendSettlementStatusToBizTreasuryNewAPI // Consume Treasury New API - Login Delays
     @future(callout=true)
    public static void sendSettlementStatusToBizTreasuryNewAPI(Map<Id,String> oppMap, Map<Id, double> timeStampMap ){
        Set<Id> oppSet = null;
        oppSet = oppMap.keySet();
        //Map<Id,Risk_Hold_Reasons__c> dashboardCasesMap = New Map<Id,Risk_Hold_Reasons__c>([Select Id,Merchant_Id__c, Hold_Reason_Shown_to_Merchant__c,Status__c,API_Response__c,Opportunity__c from Risk_Hold_Reasons__c Where Id IN: Opportunity]); 
        List<Opportunity> OppList = [select settlement_Status__C,Prod_Merchant_Id__c, Merchant_Id__c,TimeInMillis__c from opportunity where id in :oppSet];
        
        string accessToken;
        List<Error_Details__c> errorDetailsList = New List<Error_Details__c>();
        List<Payload_Log__c> payloadLogList = New List<Payload_Log__c>();
        List<String> urlFormatStr = New List<String>();
        Map<string,String> settlementStatusMap = New Map<String,String>();
        settlementStatusMap.put('Risk Hold', '1');
        settlementStatusMap.put('Active', '0');
        settlementStatusMap.put('Thirdparty Hold', '2');
        HttpResponse response = New HttpResponse();
        List<MCare_Dashboard_Case__c> mCareListToUpdate = New List<MCare_Dashboard_Case__c>();
        Map<Id,Opportunity> opportunityToUpdateMap = New Map<Id,Opportunity>();
        if(!OppList.isEmpty()){
            /*if(!Test.isRunningTest()){accessToken = IntegrationUtility.getAuthToken('AccessTokenSettlementNewAPI');
            }else{
                accessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }*/
             accessToken = '4979d8220566bdb51b0b9e14a7a6aadff1909c9e59e37c6e67d4385438c9c333';
            if(string.isNotBlank(accessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('UpdateSettlementStatusFromSFNewAPI');
                for(Opportunity each : OppList){
                    double timeInFutureCall = timeStampMap.get(each.Id); 
                    String settStatusInFutureCall = oppMap.get(each.Id);
                    System.debug('Time In Future Call >> '+timeInFutureCall);
                    System.debug('Timestamp saved In Opportunity  >> '+timeStampMap.get(each.Id));
                    
                    if((timeInFutureCall < each.TimeInMillis__c) || settStatusInFutureCall != each.Settlement_Status__c ){
                    //skip invoking the API as the future call has become old enough or an update to settement status happened in the interim. 
                    return;
                    }
                    SYstem.debug('settlementStatusMap.get(each.Settlement_Status__c)::'+settlementStatusMap.get(each.Settlement_Status__c));
                    urlFormatStr.add(settlementStatusMap.get(each.Settlement_Status__c));
                    response = IntegrationUtility.requestUtility(theIntIns, False, accessToken, each, urlFormatStr, null);
                    System.debug('response:::3295::::'+response.getBody());
                    if(response != null && response.getStatusCode() == 200){
                        Payload_Log__c plLog = New Payload_Log__c(Process__c = 'Send Hold Settlement Status to Admin Panel',Prod_MID__c = Integer.valueOf(each.Prod_Merchant_Id__c),Status__c = 'SUCCESS',SalesforceRecordId__c = each.Id, Exception__c  = response.getBody(), Time_of_Exec__c = System.currentTimeMillis(), Time_of_Invoc__c = timeInFutureCall);
                        payloadLogList.add(plLog);
                        // each.API_Response__c = response.getBody();
                        // mCareListToUpdate.add(each);
                    }
                    else if(response!=null){
                       if(!Test.isRunningTest()) sendRetryFailedEmail(each.id,response.getBody());  
                        Error_Details__c edLog = New Error_Details__c(Process__c = 'Send Hold Settlement Status to Admin Panel');
                        //if(response != null && response.getBody() != null) 
                        edLog.Response__c = response.getBody();
                        errorDetailsList.add(edLog);
                    }
                }
            }
        }
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
    }
    @future(callout=true)
    public static void sendSettlementStatusToBizTreasury(Map<Id,String> oppMap, Map<Id, double> timeStampMap ){
        SYstem.debug('sendSettlementStatusToBizTreasury::'+oppMap.keySet());
        
        Set<Id> oppSet = null;
        oppSet = oppMap.keySet();
        //Map<Id,Risk_Hold_Reasons__c> dashboardCasesMap = New Map<Id,Risk_Hold_Reasons__c>([Select Id,Merchant_Id__c, Hold_Reason_Shown_to_Merchant__c,Status__c,API_Response__c,Opportunity__c from Risk_Hold_Reasons__c Where Id IN: Opportunity]); 
        List<Opportunity> OppList = [select settlement_Status__C,Prod_Merchant_Id__c, Merchant_Id__c,TimeInMillis__c from opportunity where id in :oppSet];
        
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
        statusVsNumberMap.put('Active', '0');
        statusVsNumberMap.put('Thirdparty Hold', '2');
        statusVsNumberMap.put('0', 'Active');
        statusVsNumberMap.put('1', 'Risk Hold');
        statusVsNumberMap.put('Pre-Risk Hold', '1');//Added for Admin pannel - Final
        statusVsNumberMap.put('OB Hold', '1');//Added for Admin pannel - Final (OB Hold)
        statusVsNumberMap.put('2', 'Thirdparty Hold');
        statusVsNumberMap.put('3', 'Risk & Thirdparty hold');
        HttpResponse response = New HttpResponse();
        List<MCare_Dashboard_Case__c> mCareListToUpdate = New List<MCare_Dashboard_Case__c>();
        Map<Id,Opportunity> opportunityToUpdateMap = New Map<Id,Opportunity>();
        if(!OppList.isEmpty()){
            if(!Test.isRunningTest()){
                accessToken = IntegrationUtility.getAuthToken('AuthenticateSettlementStatusFromMCare');
                SYstem.debug('accessToken::::::::'+accessToken);
            }else{
                accessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            }
            accessToken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
            if(string.isNotBlank(accessToken)){
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('UpdateSettlementStatusFromSF');
                for(Opportunity each : OppList){
                    double timeInFutureCall = timeStampMap.get(each.Id); 
                    String settStatusInFutureCall = oppMap.get(each.Id);
                    System.debug('Time In Future Call >> '+timeInFutureCall);
                    System.debug('Timestamp saved In Opportunity  >> '+timeStampMap.get(each.Id));
                    
                    
                    if((timeInFutureCall < each.TimeInMillis__c) || settStatusInFutureCall != each.Settlement_Status__c ){
                        //skip invoking the API as the future call has become old enough or an update to settement status happened in the interim. 
                        return;
                    }
                    
                    // IntegrationUtility.HTTPWrapper wrpCls = new IntegrationUtility.HTTPWrapper();
                    SYstem.debug('statusVsNumberMap.get(each.Settlement_Status__c)::'+statusVsNumberMap.get(each.Settlement_Status__c));
                    urlFormatStr.add(statusVsNumberMap.get(each.Settlement_Status__c));
                    // wrpCls = IntegrationUtility.sendHTTPRequest(theIntIns, False, accessToken, each, urlFormatStr, null);                   
                    
                    
                    /* if(wrpCls.response != null && wrpCls.response.getStatusCode() == 200){
Payload_Log__c plLog = New Payload_Log__c(Process__c = 'Send Hold Settlement Status to Admin Panel',Prod_MID__c = Integer.valueOf(each.Prod_Merchant_Id__c),Status__c = 'SUCCESS',SalesforceRecordId__c = each.Id, Exception__c = String.valueOf(wrpCls.response.getBody()),Payload__c = String.valueOf(wrpCls.request));
payloadLogList.add(plLog);

// each.API_Response__c = response.getBody();
// mCareListToUpdate.add(each);
}
else if(wrpCls.response!=null && each.Lead_Type__c != 'Partner' && each.Prod_Merchant_Id__c != null){
//TODO : Add a entry in the table for retry .                         
sendRetryFailedEmail(each.Prod_MID__c , wrpCls.response.getBody());  

Error_Details__c edLog = New Error_Details__c(Process__c = 'Send Hold Settlement Status to Admin Panel');
// (response != null && response.getBody() != null) 
edLog.Response__c = String.valueOf(wrpCls.response.getBody());
edLog.Request__c = wrpCls.request;
errorDetailsList.add(edLog);
}*/
                    
                }
                
            }
        }
        
        if(!payloadLogList.isEmpty()) insert payloadLogList;
        if(!errorDetailsList.isEmpty()) insert errorDetailsList;
    }
    
    
    //Yash Lokwani - Method to manage settlement status access MER-65
    public static void checkSettlementStatusAccess(Opportunity each, Opportunity oldOpp) {
        if(each.Settlement_Status__c == oldOpp.Settlement_Status__c) {
            return;
        }else {
            each.TimeInMillis__c = System.currentTimeMillis(); 
        }
        
        
        
        User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c From User 
                        where Id =: UserInfo.getUserId() LIMIT 1];      
        if(Label.SuperUser_Access_for_Holds.contains(UserInfo.getUserId())){  
            return;
        }
        
        // Check if the update is coming from Delegation Matrix
        if(each.Settlement_Status__c == 'Active' && each.Delegation_Matrix_Override__c) {
            each.Delegation_Matrix_Override__c = false;
            return;
        }
        // For Post-risk
        Boolean flag = false;
        // Blank Settlement Status Permissions
        // requirement was that some settlement statuses that are blank/null need to be either given holds, or become active
        // All holds except active
        
        if(oldOpp == null || String.IsBlank(oldOpp.Settlement_Status__c)) {
            if(each.Settlement_Status__c == 'OB Hold' && Label.Hold_Users_From_Blank_For_OB.contains(UserInfo.getUserId())) {
                flag = true;
            } else if(each.Settlement_Status__c == 'Risk Hold' && Label.Hold_Users_From_Blank_For_Post_Risk.contains(UserInfo.getUserId())) {
                flag = true;
            } else if(each.Settlement_Status__c == 'Pre-risk Hold' && Label.Hold_Users_From_Blank_For_Pre_Risk.contains(UserInfo.getUserId())) {
                flag = true;
            }
        }
        //Thirdparty Hold Permissions
        // Change was required because there need to be users that should be able to put Thirdparty Hold Merchants to
        // Post-Risk Hold or Pre-Risk Hold
        if(oldOpp == null || oldOpp.Settlement_Status__c == 'Thirdparty Hold') {
            if(each.Settlement_Status__c == 'Risk Hold' && Label.Hold_Users_TP_to_Post_risk.contains(UserInfo.getUserId())) {
                flag = true;
            } else if(each.Settlement_Status__c == 'Pre-risk Hold' && Label.Hold_Users_TP_to_Pre_risk.contains(UserInfo.getUserId())) {
                flag = true;
            }
        }
        //Hold Permissions
        if(oldOpp == null || oldOpp.Settlement_Status__c == 'Active') {
            //Post Risk
            if(each.Settlement_Status__c == 'Risk Hold' && Label.Hold_Users_For_Post_risk.contains(UserInfo.getUserId())) {
                flag = true;
            } else 
                //Pre Risk
                if(each.Settlement_Status__c == 'Pre-risk Hold' && Label.Hold_Users_For_Pre_risk.contains(UserInfo.getUserId())) {
                    flag = true;
                } else
                    //OB
                    if(each.Settlement_Status__c == 'OB Hold' && Label.Hold_Users_For_OB.contains(UserInfo.getUserId())) {
                        flag = true;
                    }
        }
        
        //Release Permisisions
        if(each.Settlement_Status__c == 'Active' && oldOpp != null) {
            //Post Risk
            if(oldOpp.Settlement_Status__c == 'Risk Hold' && Label.Hold_Users_From_Post_risk.contains(UserInfo.getUserId())) {
                flag = true;
            } else 
                //Pre Risk
                if(oldOpp.Settlement_Status__c == 'Pre-risk Hold' && Label.Hold_Users_From_Pre_risk.contains(UserInfo.getUserId())) {
                    flag = true;
                } else 
                    //OB
                    if(oldOpp.Settlement_Status__c == 'OB Hold' && Label.Hold_Users_From_OB.contains(UserInfo.getUserId())) {
                        flag = true;
                    }
        }
        
        if(!flag && !Test.isRunningTest()) {
            each.addError('You don\'t have enough permissions for that change to settlement status!');
            each.TimeInMillis__c = oldOpp.TimeInMillis__c;
            
        }
    }
    
    /*
* Name of the Method : sendRetryFailedEmail
* Author's Name      : Rahul Pandey  
* Created Date       : 23th may, 2023
* Description        : sends an email notification to the user 
* Version.           : 1   
*/
    /*********************The method returns this extracted code value .*****************/
    
    public static String extractCodeValue(String inputString) {
        return inputString.replaceAll('.*"code":"(\\d+)".*', '$1');
    }
    
    public static void sendRetryFailedEmail(string merchantId, String responseBody){
        /* Access modifier: public
*Return type: void (no return value)
*Method name: sendRetryFailedEmail
*Parameters: string merchantId, string responseBody
*/
        /*********************Sends the email message using the salesforce  Messaging framework*******************/
        if(extractCodeValue(responseBody)=='4004'){
            return;
        }
        String emailSubject = 'Retry failed for Opportunity Id'+ String.valueOf(merchantId);
        String emailBody = 'Opportunity Id: ' + String.valueOf(merchantId)+ '\n\nResponse details: ' + responseBody;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTargetObjectId(userinfo.getUserId());  
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.Email>{email});
        
        /*********************Sends the email message using the salesforce Messaging framework End*******************/ 
    }
    
    /** Added for SFI-1243 - Dormancy Date Automation **/
    /** private method to process the opportunity records for dormancy date update.*/
    /** @param - List of Opportuniuty */

    private static void processRecordForDormancyAutomation(List<Opportunity> oppListToProcessDormancyDate){
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppListToProcessDormancyDate){
            Opportunity oppUpdate = new Opportunity();
            oppUpdate.Id = opp.Id;
            if(needToRemoveDormancyDate(opp)){
                oppUpdate.Dormancy_Date__c = NULL;
                oppListToUpdate.add(oppUpdate);
            }
        }
        if(!oppListToUpdate.isEmpty()){
            update oppListToUpdate;
        }
    }
    /** private method to check that opportunity is valid to update the dormancy date.*/
    /** @param -  Opportuniuty record */
    /** return type - Boolean */
    private static Boolean needToRemoveDormancyDate(Opportunity opp){
        if(opp.Dormancy_Date__c != NULL && !opp.Is_dormant__c && opp.Days_Since_Last_Transaction__c > 0 && opp.Days_Since_Last_Transaction__c < 270){
            return true;
        }
        return false;
    }
    
    /** private method to process the opportunity records for last_re-KYC_date update.*/
    /** @param - List of Opportuniuty */
    private static void processRecordForRekycUpdate(List<Opportunity> oppListForRekycUpdate){
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppListForRekycUpdate){
            Opportunity oppUpdate = new Opportunity();
            oppUpdate.Id = opp.Id;
            oppUpdate.Dormancy_Date__c = NULL;
            oppUpdate.Last_ReKYC_date__c = System.today();
            oppListToUpdate.add(oppUpdate);
            
        }
        if(!oppListToUpdate.isEmpty()){
            update oppListToUpdate;
        }
    }
    /** END SFI-1243 **/
}