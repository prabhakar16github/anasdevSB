/*
* Created By: Akash Pandey
* Created date: 27 may 2020
* */
public with sharing class pre_OnboardingBlacklistController {
    
    @AuraEnabled
    public static wrapperDetail getBlacklistDetails( Id oppId) {
        wrapperDetail accOppWrap = New wrapperDetail();
        if(string.isNotBlank(oppId)){
            accOppWrap.opp = getOpportunity(oppId);
            accOppWrap.acc = getAccount(accOppWrap.opp.AccountId);
            String riskType = '';
            for(String str: utilMethod()){
                riskType = riskType+','+str;
            }
            riskType = riskType.removeStart(',');
            accOppWrap.riskTypes = riskType.removeEnd(',');
            Boolean isBlacklIstDataFound = checkBlacklist_Merchant_Attributes(accOppWrap.opp, accOppWrap.acc);
            accOppWrap.isBlacklIstDataFound = isBlacklIstDataFound;
            return accOppWrap;
        }
        return null;
    }
    
    @AuraEnabled
    public static String unblockMerchant(Id oppId, String blacklistComment,String riskTypeforInactive,List<String> selectedRiskType){
        try{
            Map<String, String> blacklistTypeVsDataMap = new Map<String, String>();
            riskTypeforInactive = riskTypeforInactive.removeEnd(']');
            riskTypeforInactive = riskTypeforInactive.removeStart('[');
            riskTypeforInactive = riskTypeforInactive.remove('"');
            String riskType = '';
            String data = '';
            if(!selectedRiskType.contains('None')){
                for(String str:selectedRiskType){
                    riskType = riskType +str+';';
                }
                riskType = riskType.removeEnd(';');
            }
            System.debug('selected_RiskType'+selectedRiskType);
            Opportunity opty = getOpportunity(oppId);
            if(selectedRiskType.contains('None')){
                opty.Blacklist__c = false;
                if(opty.Settlement_Status__c == 'Risk Hold'){
                    opty.Settlement_Status__c = 'Thirdparty Hold';
                }
                opty.Unblocked_by__c = userInfo.getUserId();
                opty.Was_Blacklisted__c = true;
            }
            opty.Blacklist_Comment__c = String.isNotBlank(blacklistComment) ? blacklistComment : Label.Unblock_merchant_by_Risk;
            opty.Blacklist_Comment__c += ' by : '+userInfo.getName();
            opty.Risk_Type_Multi_Select__c = riskType;
            update opty;
            Bank_Account_Detail__c bnkDetail = getbankDetail(oppId);
            Account acc = getAccount(opty.AccountId);
            //acc.Risk_Type_Multi_Select__c = riskType;
            //acc.Risk_Comment__c = '';
            //update acc;
            List<String> riskTypeforInactiveList = riskTypeforInactive.split(',');
            System.debug('riskTypeforInactiveList>>>>'+riskTypeforInactiveList);
            if(riskTypeforInactiveList.contains('Bank Detail') || riskTypeforInactiveList.contains('Email ID') || riskTypeforInactiveList.contains('Lead Business Name') || riskTypeforInactiveList.contains('Lead Legal Name') || riskTypeforInactiveList.contains('Phone Number') || riskTypeforInactiveList.contains('PAN Number') || riskTypeforInactiveList.contains('Website URL') || riskTypeforInactiveList.contains('Display Name')){
                for(String str: riskTypeforInactiveList){
                    if(str == 'Bank Detail'){
                        data = String.isNotBlank(bnkDetail.Account_Number_IFSC_Code__c) ? bnkDetail.Account_Number_IFSC_Code__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Email ID'){
                        data = String.isNotBlank(opty.Email__c) ? opty.Email__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Lead Business Name'){
                        data = String.isNotBlank(acc.Merchant_Trading_Name__c) ? acc.Merchant_Trading_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Lead Legal Name'){
                        data = String.isNotBlank(acc.Legal_Name__c) ? acc.Legal_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Phone Number'){
                        data = String.isNotBlank(opty.Mobile__c) ? opty.Mobile__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'PAN Number'){
                        data = String.isNotBlank(acc.PAN_Number__c) ? acc.PAN_Number__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Website URL'){
                        if(String.isNotBlank(opty.Website__c))    data = opty.Website__c;
                        else if(String.isNotBlank(opty.Android_URL__c))   data = opty.Android_URL__c;
                        else if(String.isNotBlank(opty.iOS_URL__c))   data = opty.iOS_URL__c;
                        else data = '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                    if(str == 'Display Name'){
                        data = String.isNotBlank(opty.Display_Name__c) ? opty.Display_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                    }
                }
                System.debug('blacklistTypeVsDataMap>>>>'+blacklistTypeVsDataMap);
                getBlacklistData(blacklistTypeVsDataMap,'UnblockEvent',oppId);
            }
            system.debug('-->> 23'+opty.Blacklist__c+' '+opty.Unblocked_by__c);
            return opty.Risk_Type_Multi_Select__c;
        }catch(exception exc){
            system.debug('-->> '+exc.getLineNumber()+' '+exc.getMessage());
            return 'ERROR';
        }
    }
    
    @AuraEnabled 
    public static String saveWrapperDetail(Opportunity oppObj, Boolean isBlacklIstData, List<String> riskTypes){
        system.debug('saveWrapperDetail'+riskTypes);
        oppObj.Risk_Comment__c = oppObj.Risk_Comment__c + ' by : '+userinfo.getName();
        //oppObj.Risk_Comment__c = oppObj.Risk_Comment__c + ' by : '+userinfo.getUserName();
        oppObj.Blacklist__c = true;
        //if this label contains settlement status then only we have to mark Risk Hold
        String tempLabel = Label.Settlement_Status_Restricted;
        List<String> settlementStatusList = tempLabel.split(',');
        if(!settlementStatusList.contains(oppObj.Settlement_Status__c)){
            oppObj.Settlement_Status__c = 'Risk Hold';  
        }
        oppObj.Blacklisted_By__c  = userInfo.getUserId();
        Bank_Account_Detail__c bankDetailObj = getbankDetail(oppObj.Id);
        Boolean isBlacklIstDataFound = false;
        try{
            
            if(riskTypes.contains('Bank Detail') || riskTypes.contains('Email ID') || riskTypes.contains('Lead Business Name') || riskTypes.contains('Lead Legal Name') || riskTypes.contains('Phone Number') || riskTypes.contains('Website URL') || riskTypes.contains('PAN Number') || riskTypes.contains('Display Name')){
                isBlacklIstDataFound = crete_Blacklist_Merchant_Attributes(oppObj,riskTypes,oppObj.Id);
            }
            //update accObj;
            System.debug('Risk_Type_Multi_Select__c after update>>>>>>>>>'+oppObj.Risk_Type_Multi_Select__c);
            System.debug('Settlement_Status__c after update>>>>>>>>>'+oppObj.Settlement_Status__c);
            update oppObj;
            return oppObj.Risk_Type_Multi_Select__c;
        }catch(Exception exc){
            system.debug('ERROR'+exc.getLineNumber()+' '+exc.getMessage());
            return '';
        }
        
    }
    
    public static opportunity getOpportunity(Id oppId){
        return[Select Id, AccountId, Blacklist__c, Blacklist_Comment__c, Unblocked_by__c,Risk_Type_Multi_Select__c ,Risk_Comment__c,Mobile__c,
               Website__c, Android_URL__c, iOS_URL__c,Email__c,Settlement_Status__c, Was_Blacklisted__c,Display_Name__c
               from opportunity where Id =:oppId];
    }
    
    public static Account getAccount(Id accId){ 
        return[Select Id,PAN_Number__c, Merchant_Trading_Name__c, Legal_Name__c, Phone from Account where Id =:accId];
    }
    
    public static Bank_Account_Detail__c getbankDetail(Id optyId){
        Bank_Account_Detail__c bObj = new Bank_Account_Detail__c();
        List<Bank_Account_Detail__c> bankDetailList = new List<Bank_Account_Detail__c>();
        if(optyId != null){
            bankDetailList = [Select Id, Account_Number_IFSC_Code__c from Bank_Account_Detail__c where Active__c = True AND Opportunity__c =:optyId];
        }
        if(bankDetailList.size() > 0){
            bObj = bankDetailList[0];
        }
        return bObj;
    }
    
    public static list<string> utilMethod(){
        list<string> picklistval = systemUtility.getPicklistValue('Opportunity','Risk_Type_Multi_Select__c');
        return picklistval;
    }
    
    public static Boolean getBlacklistData(Map<String, String> blacklistTypeVsDataMap, String eventType,String opId){
        Boolean isUpdated = false;
        system.debug('blacklistTypeVsDataMap '+blacklistTypeVsDataMap);
        system.debug('eventType '+eventType);
        Set<String> blacklistTypsList= blacklistTypeVsDataMap.keySet();
        List<String> blacklistNameList= blacklistTypeVsDataMap.values();
        list<Blacklist_Merchant_Attribute__c> BlacklistDataList = [SELECT Id,Name__c,Blacklist_Type__c, Active__c 
                                                                   FROM Blacklist_Merchant_Attribute__c where 
                                                                   Active__c = true AND 
                                                                   Blacklist_Type__c IN: blacklistTypsList AND 
                                                                   Name__c IN:blacklistNameList AND Blacklist_Type__c != null
                                                                   AND Name__c != null];
        system.debug('BlacklistDataList '+BlacklistDataList);
        if(BlacklistDataList.size() > 0){
            if(eventType == 'UnblockEvent'){
                for(Blacklist_Merchant_Attribute__c blacklist: BlacklistDataList){
                    blacklist.Active__c = false;
                    blacklist.Unblock_By__c = userInfo.getUserId();
                }
                //blockExistingOpportunityList(blacklistTypeVsDataMap,'UnblockEvent',opId);
            }
            system.debug('BlacklistDataList updated '+BlacklistDataList);
            update BlacklistDataList;
            isUpdated = true;
        }
        return isUpdated;
    }
    //It will create the blacklist object when based on selected tisk type
    public static Boolean crete_Blacklist_Merchant_Attributes(Opportunity opp,List<String> field,String opId){
        Map<String,String> blacklistDataVsTypeMap = new Map<String,String>();
        List<String> dataList = new List<String>();
        List<String> typeList = new List<String>();
        Opportunity opty = getOpportunity(opp.Id);
        Account acc = getAccount(opty.AccountId);
        Map<String, String> blacklistTypeVsDataMap = new Map<String, String>();
        List<Blacklist_Merchant_Attribute__c> BlacklistDataListToUpdate = new  List<Blacklist_Merchant_Attribute__c>();
        List<Blacklist_Merchant_Attribute__c> BlacklistData_List = new  List<Blacklist_Merchant_Attribute__c>();
        String data = '';
        Boolean isBlacklIstDataFound = false;
        
        Bank_Account_Detail__c bnkDetail = getbankDetail(opty.Id);
        System.debug('bnkDetail>>'+bnkDetail);
        System.debug('field>>'+field);
        if(field.size()>0){
            if(field.contains('Bank Detail') || field.contains('Email ID') || field.contains('Lead Business Name') || field.contains('Lead Legal Name') || field.contains('Phone Number') || field.contains('PAN Number') || field.contains('Website URL') || field.contains('Display Name')){
                for(String str: field){
                    System.debug('str>>'+str);
                    Blacklist_Merchant_Attribute__c bObj = new Blacklist_Merchant_Attribute__c();
                    bObj.Active__c = true;
                    bObj.Blacklisted_By__c = userInfo.getUserId();
                    if(str == 'Bank Detail'){
                        data = String.isNotBlank(bnkDetail.Account_Number_IFSC_Code__c) ? bnkDetail.Account_Number_IFSC_Code__c : '';
                        System.debug('data>>'+data);
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Bank Detail';
                    }
                    if(str == 'Email ID'){
                        data = String.isNotBlank(opty.Email__c) ? opty.Email__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Email ID';
                    }
                    if(str == 'Lead Business Name'){
                        data = String.isNotBlank(acc.Merchant_Trading_Name__c) ? acc.Merchant_Trading_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Lead Business Name';
                    }
                    if(str == 'Lead Legal Name'){
                        data = String.isNotBlank(acc.Legal_Name__c) ? acc.Legal_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Lead Legal Name';
                    }
                    if(str == 'Phone Number'){
                        data = String.isNotBlank(opty.Mobile__c) ? opty.Mobile__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Phone Number';
                    }
                    if(str == 'PAN Number'){
                        data = String.isNotBlank(acc.PAN_Number__c) ? acc.PAN_Number__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'PAN Number';
                    }
                    if(str == 'Website URL'){
                        if(String.isNotBlank(opty.Website__c))    data = opty.Website__c;
                        else if(String.isNotBlank(opty.Android_URL__c))   data = opty.Android_URL__c;
                        else if(String.isNotBlank(opty.iOS_URL__c))   data = opty.iOS_URL__c;
                        else data = '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Website URL';
                    }
                    if(str == 'Display Name'){
                        data = String.isNotBlank(opty.Display_Name__c) ? opty.Display_Name__c : '';
                        blacklistTypeVsDataMap.put(str,data);
                        bObj.Name__c = data;
                        bObj.Blacklist_Type__c = 'Display Name';
                    }
                    System.debug('bObj>>'+bObj);
                    dataList.add(bObj.Name__c);
                    typeList.add(bObj.Blacklist_Type__c);
                    if(String.isNotBlank(bObj.Name__c) && String.isNotBlank(bObj.Blacklist_Type__c)) BlacklistData_List.add(bObj);
                    System.debug('BlacklistData_List>>'+BlacklistData_List);
                    
                    
                }
                list<Blacklist_Merchant_Attribute__c> BlacklistDataList = new list<Blacklist_Merchant_Attribute__c>();
                
                if(!typeList.isEmpty() && !dataList.isEmpty()){
                    BlacklistDataList = [SELECT Id,Name__c,Blacklist_Type__c, Active__c FROM Blacklist_Merchant_Attribute__c where Active__c = true AND Blacklist_Type__c IN: typeList AND Name__c IN:dataList];
                }
                
                System.debug('BlacklistDataList>>'+BlacklistDataList);
                List<String> existingBlacklistType = new List<String>();
                List<String> existingBlacklistData = new List<String>();
                
                if(BlacklistDataList.size()>0){
                    for(Blacklist_Merchant_Attribute__c blacklist : BlacklistDataList){
                        if(String.isNotBlank(blacklist.Blacklist_Type__c) && String.isNotBlank(blacklist.Name__c)){
                            existingBlacklistType.add(blacklist.Blacklist_Type__c);
                            existingBlacklistData.add(blacklist.Name__c);
                            if(!blacklistTypeVsDataMap.containsKey(blacklist.Blacklist_Type__c)){
                                BlacklistDataListToUpdate.add(blacklist);
                            }
                        }
                    }
                }
                if(BlacklistData_List.size() >0){
                    System.debug('existingBlacklistData?????'+existingBlacklistData);
                    for(Blacklist_Merchant_Attribute__c blacklist : BlacklistData_List){
                        if(String.isNotBlank(blacklist.Blacklist_Type__c) && String.isNotBlank(blacklist.Name__c)){
                            if(!existingBlacklistType.contains(blacklist.Blacklist_Type__c) && !existingBlacklistData.contains(blacklist.Name__c)){
                                System.debug('blacklist?????'+blacklist);
                                BlacklistDataListToUpdate.add(blacklist);
                            }
                        }
                    }
                    
                }
            }
            System.debug('BlacklistDataListToUpdate>>'+BlacklistDataListToUpdate);
            if(BlacklistDataListToUpdate.size()>0){
                insert BlacklistDataListToUpdate;
                isBlacklIstDataFound = true;
            }
        }
        return isBlacklIstDataFound;
    }
    //it will check the the blacklisted opportunity at the time of opportunity refresh
    public static Boolean checkBlacklist_Merchant_Attributes(Opportunity opty, Account acc){
        List<String> riskTypeList = new List<String>();
        Boolean isBlacklIstDataFound = false;
        String riskType = '';
        Bank_Account_Detail__c bnkDetail = getbankDetail(opty.Id);
        String BankDetail = String.isNotBlank(bnkDetail.Account_Number_IFSC_Code__c) ? bnkDetail.Account_Number_IFSC_Code__c : '';
        String EmailID = String.isNotBlank(opty.Email__c) ? opty.Email__c : '';
        String LeadBusinessName = String.isNotBlank(acc.Merchant_Trading_Name__c) ? acc.Merchant_Trading_Name__c : '';
        String LeadLegalName = String.isNotBlank(acc.Legal_Name__c) ? acc.Legal_Name__c : ''; 
        String PhoneNumber = String.isNotBlank(opty.Mobile__c) ? opty.Mobile__c : '';
        String DisplayName = String.isNotBlank(opty.Display_Name__c) ? opty.Display_Name__c : '';
        String panNumber = String.isNotBlank(acc.PAN_Number__c) ? acc.PAN_Number__c : '';
        
        Boolean isOppUpdatable = false;
        /*String WebsiteURL;
if(String.isNotBlank(opty.Website__c))    WebsiteURL = opty.Website__c;
else if(String.isNotBlank(opty.Android_URL__c))   WebsiteURL = opty.Android_URL__c;
else if(String.isNotBlank(opty.iOS_URL__c))   WebsiteURL = opty.iOS_URL__c;
//else WebsiteURL = ''; 
*/
        
        String WebsiteURL = String.isNotBlank(opty.Website__c) ? opty.Website__c : String.isNotBlank(opty.Android_URL__c) ? opty.Android_URL__c : opty.iOS_URL__c;
        if(String.isNotBlank(BankDetail) || String.isNotBlank(EmailID) || String.isNotBlank(LeadBusinessName) || String.isNotBlank(LeadLegalName) || 
           String.isNotBlank(PhoneNumber) || String.isNotBlank(WebsiteURL) || String.isNotBlank(panNumber) || String.isNotBlank(DisplayName)){
               List<Blacklist_Merchant_Attribute__c> blacklist_List = [SELECT Id,Name__c,Blacklist_Type__c, Active__c, OwnerId 
                                                                       FROM Blacklist_Merchant_Attribute__c 
                                                                       WHERE Active__c = True AND (Name__c =:BankDetail 
                                                                                                   OR Name__c =: EmailID 
                                                                                                   OR Name__c =: LeadBusinessName 
                                                                                                   OR Name__c =: LeadLegalName 
                                                                                                   OR Name__c =: PhoneNumber 
                                                                                                   OR Name__c =: WebsiteURL 
                                                                                                   OR Name__c =: panNumber
                                                                                                  OR Name__c =: DisplayName) 
                                                                       AND Blacklist_Type__c != null AND Name__c != null];
               
               System.debug('blacklist_List>>>'+blacklist_List);
               System.debug('blacklist_List>>>'+blacklist_List.size());
               String blackListOwnerId ='';// Added by rohit gupta UserStory point : SFI-620
               if(blacklist_List.size()>0){
                   isBlacklIstDataFound = true;
                   String tempRiskType = opty.Risk_Type_Multi_Select__c;
                   if(String.isNotBlank(tempRiskType)){
                       //riskTypeList = tempRiskType.split(';');
                   }
                   System.debug('riskTypeList>>>'+riskTypeList);
                   for(Blacklist_Merchant_Attribute__c bl: blacklist_List){
                       if(String.isNotBlank(bl.Blacklist_Type__c)){
                           riskTypeList.add(bl.Blacklist_Type__c);
                       }
                       // Added by rohit gupta UserStory point : SFI-620
                       if(blackListOwnerId !=NULL){
                        blackListOwnerId =bl.OwnerId;
                       }
                      /**************END*************/
                   }
                   System.debug('riskTypeList'+riskTypeList);
                   if(riskTypeList.size()>0){
                       
                       for(String str:riskTypeList){
                           riskType = riskType +str+';';
                       }
                       riskType = riskType.removeEnd(';');
                       System.debug('riskType>415>>'+riskType);
                       if(riskType != null){
                           opty.Risk_Type_Multi_Select__c = riskType;
                       }
                       
                       if(!opty.Blacklist__c){
                           opty.Blacklist__c = true;
                           opty.Was_Blacklisted__c = false;
                           //opty.Blacklisted_By__c = UserInfo.getUserId(); --> Commented to not show the user's name while refreshing.
                           //below line Added by rohit gupta UserStory point : SFI-620
                           opty.Blacklisted_By__c = blackListOwnerId;//system.label.IntegrationUserId; // Adding the Integration User in Blacklisted_by field, when refresh.
                           if(String.isBlank(opty.Risk_Comment__c)){
                               opty.Risk_Comment__c = 'This merchant has been blacklisted due to existing blacklisted parameter.';
                               opty.Blacklist_Comment__c ='';
                           }
                           isOppUpdatable = true;
                       }
                       //if this label contains settlement status then only we have to mark Risk Hold
                       String tempLabel = Label.Settlement_Status_Restricted;
                       List<String> settlementStatusList = tempLabel.split(',');
                       if(!settlementStatusList.contains(opty.Settlement_Status__c)){
                           opty.Settlement_Status__c = 'Risk Hold';  
                           isOppUpdatable = true;
                       }
                       
                   }
                   
               }else{
                   if(String.isNotBlank(opty.Risk_Type_Multi_Select__c)){
                       opty.Was_Blacklisted__c = true;
                       opty.Blacklist__c = false;
                       //opty.Unblocked_by__c = userInfo.getUserId(); --> Commented to not show the user's name while refreshing.
                       opty.Unblocked_by__c = system.Label.IntegrationUserId;// Adding the Integration User in Blacklisted_by field, when refresh.
                       opty.Blacklist_Comment__c = 'This merchant has been unblocked due to existing blacklisted parameter.';
                       opty.Risk_Comment__c ='';
                       opty.Risk_Type_Multi_Select__c = '';
                       isOppUpdatable = true;
                   }
                   
                   if(opty.Blacklist__c) {
                       opty.Blacklist__c = false;
                       isOppUpdatable = true;
                   }
                   /* if(opty.Settlement_Status__c == 'Risk Hold'){
opty.Settlement_Status__c = 'Thirdparty Hold';
} */  
               }
               if(isOppUpdatable) update opty;
           }
        
        return isBlacklIstDataFound;
    } 
    //this method call from trigger to check blacklist at the time of before insert.
    public static void checkBlacklistForNewOpportunity(List<Opportunity> oppList,Map<Id, Opportunity> triggerOldMap){
        System.debug('oppList>>>'+oppList);
        System.debug('triggerOldMap>>>'+triggerOldMap);
        Set<Id> accIdSet = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();
        Map<Id,Account> oppIdVsAccountMap = new Map<Id,Account>();
        
        for(Opportunity op: oppList){
            if(string.isNotBlank(op.AccountId)) accIdSet.add(op.AccountId);
        }
        
        Map<Id,Account> accountMap = New Map<Id,Account>([Select Id,Name,PAN_Number__c,Merchant_Trading_Name__c,Legal_Name__c,Phone FROM Account Where Id IN:accIdSet]);
        
        List<String> bankDetails = new List<String>();
        List<String> EmailIDList = new List<String>();
        List<String> LeadBusinessNameList = new List<String>();
        List<String> LeadLegalNameList = new List<String>();
        List<String> PhoneNumberList = new List<String>();
        List<String> websiteUrlList = new List<String>();
        List<String> panNumberList = new List<String>();
        String WebsiteURL=''; 
        List<String> displayNameList = new List<String>();
        
        if(!accountMap.isEmpty()){
            for(Opportunity op: oppList){
                Account accObj = accountMap.get(op.AccountId);
                System.debug('accObj>>>'+accObj);
                if(String.isNotBlank(op.Email__c)){
                    EmailIDList.add(op.Email__c);
                }
                if(String.isNotBlank(accObj.Merchant_Trading_Name__c)){
                    LeadBusinessNameList.add(accObj.Merchant_Trading_Name__c);
                }
                if(String.isNotBlank(accObj.Legal_Name__c)){
                    LeadLegalNameList.add(accObj.Legal_Name__c);
                }
                if(String.isNotBlank(op.Mobile__c)){
                    PhoneNumberList.add(op.Mobile__c);
                }
                if(String.isNotBlank(accObj.PAN_Number__c)){
                    panNumberList.add(accObj.PAN_Number__c);
                }
                if(String.isNotBlank(op.Website__c)){
                    //WebsiteURL = op.Website__c;
                    websiteUrlList.add(op.Website__c);
                }
                if(String.isNotBlank(op.Android_URL__c)){
                    //WebsiteURL = op.Website__c;
                    websiteUrlList.add(op.Android_URL__c);
                }
                if(String.isNotBlank(op.iOS_URL__c)){
                    //WebsiteURL = op.Website__c;
                    websiteUrlList.add(op.iOS_URL__c);
                }
                //if(String.isNotBlank(WebsiteURL)){
                // websiteUrlList.add(WebsiteURL);
                //}
                if(String.isNotBlank(op.Display_Name__c)){
                    displayNameList.add(op.Display_Name__c);
                }
            }
        }
        
        List<Blacklist_Merchant_Attribute__c> blacklist_List = [SELECT Id,Name__c,Blacklist_Type__c, Active__c 
                                                                FROM Blacklist_Merchant_Attribute__c 
                                                                WHERE Active__c = True 
                                                                AND (Name__c IN:bankDetails OR Name__c IN: EmailIDList 
                                                                     OR Name__c IN: LeadBusinessNameList 
                                                                     OR Name__c IN: LeadLegalNameList 
                                                                     OR Name__c IN: PhoneNumberList 
                                                                     OR Name__c IN: websiteUrlList 
                                                                     OR Name__c IN: panNumberList
                                                                    OR Name__c IN: displayNameList)
                                                                AND Name__c != null AND Blacklist_Type__c != null];
        if(blacklist_List.size() > 0 && !accountMap.isEmpty()){
            for(Opportunity op: oppList){
                Account accObj = accountMap.get(op.AccountId);
                if(triggerOldMap == null){
                    String riskType = '';
                    String Website_URL = '';
                    if(String.isNotBlank(op.Website__c))    Website_URL = op.Website__c;
                    else if(String.isNotBlank(op.Android_URL__c))   Website_URL = op.Android_URL__c;
                    else if(String.isNotBlank(op.iOS_URL__c))   Website_URL = op.iOS_URL__c;
                    for(Blacklist_Merchant_Attribute__c blacklistObj: blacklist_List){
                        System.debug('blacklistObj>>>'+blacklistObj);
                        if((blacklistObj.Name__c == op.Email__c && blacklistObj.Blacklist_Type__c =='Email ID') || 
                           (blacklistObj.Name__c == accObj.Merchant_Trading_Name__c && blacklistObj.Blacklist_Type__c == 'Lead Business Name') || 
                           (blacklistObj.Name__c == accObj.Legal_Name__c && blacklistObj.Blacklist_Type__c =='Lead Legal Name') || 
                           (blacklistObj.Name__c == op.Mobile__c && blacklistObj.Blacklist_Type__c == 'Phone Number') || 
                           (blacklistObj.Name__c == accObj.PAN_Number__c && blacklistObj.Blacklist_Type__c == 'PAN Number') ||
                           ((websiteUrlList.contains(op.Website__c) || websiteUrlList.contains(op.Android_URL__c) || websiteUrlList.contains(op.iOS_URL__c)) && blacklistObj.Blacklist_Type__c == 'Website URL') ||
                           (blacklistObj.Name__c == op.Display_Name__c && blacklistObj.Blacklist_Type__c == 'Display Name')
                          ){
                               
                               System.debug('before insert');
                               riskType = riskType +';'+blacklistObj.Blacklist_Type__c;
                               riskType = riskType.removeStart(';');
                               op.Blacklist__c = true;
                               //if this label contains settlement status then only we have to mark Risk Hold
                               String tempLabel = Label.Settlement_Status_Restricted;
                               List<String> settlementStatusList = tempLabel.split(',');
                               if(!settlementStatusList.contains(op.Settlement_Status__c)){
                                   op.Settlement_Status__c = 'Risk Hold';  
                               }
                               op.Risk_Type_Multi_Select__c = riskType;
                               op.Risk_Comment__c = 'Opportunity is blacklisted by the system at the creation time';
                               op.Blacklisted_By__c = UserInfo.getUserId();
                           }
                    }
                }else if(triggerOldMap != null){
                    if((op.iOS_URL__c != triggerOldMap.get(op.Id).iOS_URL__c || op.Android_URL__c != triggerOldMap.get(op.Id).Android_URL__c || op.Website__c != triggerOldMap.get(op.Id).Website__c)
                      || op.Display_Name__c != triggerOldMap.get(op.Id).Display_Name__c){
                        //Account accObj = oppIdVsAccountMap.get(op.id);
                        String riskType = '';
                        String Website_URL = '';
                        if(String.isNotBlank(op.Website__c))    Website_URL = op.Website__c;
                        else if(String.isNotBlank(op.Android_URL__c))   Website_URL = op.Android_URL__c;
                        else if(String.isNotBlank(op.iOS_URL__c))   Website_URL = op.iOS_URL__c;
                        for(Blacklist_Merchant_Attribute__c blacklistObj: blacklist_List){
                            System.debug('blacklistObj>>>'+blacklistObj);
                            if((blacklistObj.Name__c == op.Email__c && blacklistObj.Blacklist_Type__c =='Email ID') || 
                           (blacklistObj.Name__c == accObj.Merchant_Trading_Name__c && blacklistObj.Blacklist_Type__c == 'Lead Business Name') || 
                           (blacklistObj.Name__c == accObj.Legal_Name__c && blacklistObj.Blacklist_Type__c =='Lead Legal Name') || 
                           (blacklistObj.Name__c == op.Mobile__c && blacklistObj.Blacklist_Type__c == 'Phone Number') || 
                           (blacklistObj.Name__c == accObj.PAN_Number__c && blacklistObj.Blacklist_Type__c == 'PAN Number') ||
                           ((websiteUrlList.contains(op.Website__c) || websiteUrlList.contains(op.Android_URL__c) || websiteUrlList.contains(op.iOS_URL__c)) && blacklistObj.Blacklist_Type__c == 'Website URL') ||
                           (blacklistObj.Name__c == op.Display_Name__c && blacklistObj.Blacklist_Type__c == 'Display Name')
                          ){
                                   System.debug('before update');
                                   riskType = riskType +';'+blacklistObj.Blacklist_Type__c;
                                   riskType = riskType.removeStart(';');
                                   op.Blacklist__c = true;
                                   //if this label contains settlement status then only we have to mark Risk Hold
                                   String tempLabel = Label.Settlement_Status_Restricted;
                                   List<String> settlementStatusList = tempLabel.split(',');
                                   if(!settlementStatusList.contains(op.Settlement_Status__c)){
                                       op.Settlement_Status__c = 'Risk Hold';  
                                   }
                                   op.Risk_Type_Multi_Select__c = riskType;
                                   op.Risk_Comment__c = 'Opportunity is blacklisted by the system at the updation time';
                                   op.Blacklisted_By__c = UserInfo.getUserId();
                               }
                        }
                    }
                }
                
                //accListToUpdate.add(accObj);
            }
        }
        System.debug('accListToUpdate>>>'+accListToUpdate);
        if(accListToUpdate.size() > 0){
            //update accListToUpdate;
            //update oppList;
        }
    }
    //=====it will check the bank account detail at the time of opportunity creation=====
    public static void checkBankAccountDetails(Map<Id,Bank_Account_Detail__c> oppIdVsBankDetails){
        //List<Blacklist_Merchant_Attribute__c> blacklist = new List<Blacklist_Merchant_Attribute__c>();
        List<String> strList = new List<String>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        Map<String,Opportunity> accNoIfscCodeVsBlacklistMap = new Map<String,Opportunity>();
        List<Opportunity> opList = [Select Id, AccountId, Blacklist__c, Blacklist_Comment__c, Unblocked_by__c,Risk_Type_Multi_Select__c ,Risk_Comment__c,Mobile__c,
                                    Website__c, Android_URL__c, iOS_URL__c,Email__c, Was_Blacklisted__c,Settlement_Status__c,Display_Name__c
                                    from opportunity where Id =:oppIdVsBankDetails.keySet()];
        if(opList.size()>0){
            for(opportunity op: opList){
                Bank_Account_Detail__c bankDetail = oppIdVsBankDetails.get(op.Id);
                strList.add(bankDetail.Account_Number_IFSC_Code__c);
                accNoIfscCodeVsBlacklistMap.put(bankDetail.Account_Number_IFSC_Code__c,op);
            }
        }
        List<Blacklist_Merchant_Attribute__c> blacklist_List = [SELECT Id,Name__c,Blacklist_Type__c, Active__c 
                                                                FROM Blacklist_Merchant_Attribute__c 
                                                                WHERE Active__c = True 
                                                                AND Name__c IN:strList AND Blacklist_Type__c = 'Bank Detail'];
        if(blacklist_List.size()>0){
            for(Blacklist_Merchant_Attribute__c blacklist: blacklist_List){
                if(accNoIfscCodeVsBlacklistMap.containsKey(blacklist.Name__c)){
                    Opportunity op = accNoIfscCodeVsBlacklistMap.get(blacklist.Name__c);
                    String riskType = op.Risk_Type_Multi_Select__c;
                    if(String.isNotBlank(riskType)){
                        riskType = riskType+';'+'Bank Detail';
                    }else{
                        riskType = 'Bank Detail';
                    }
                    op.Risk_Type_Multi_Select__c = riskType;
                    op.Risk_Comment__c = 'Opportunity is blacklisted by the system at the creation time';
                    op.Blacklist__c = true;
                    //if this label contains settlement status then only we have to mark Risk Hold
                    String tempLabel = Label.Settlement_Status_Restricted;
                    List<String> settlementStatusList = tempLabel.split(',');
                    if(!settlementStatusList.contains(op.Settlement_Status__c)){
                        op.Settlement_Status__c = 'Risk Hold';  
                    }
                    op.Blacklisted_By__c = UserInfo.getUserId();
                    oppListToUpdate.add(op);
                }
                
            }
            if(oppListToUpdate.size()>0){
                update oppListToUpdate;
            }
        }
        
    }
    
    public class wrapperDetail{
        @AuraEnabled
        public opportunity opp;
        @AuraEnabled
        public Account acc;
        @AuraEnabled
        public String riskTypes;
        @AuraEnabled
        public Boolean isBlacklIstDataFound;
    }
}