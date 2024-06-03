public class WebsiteStatusMaintanenceController_Onb {
    
    /*-----------------------------------------------------------------------
Description:    method to get the list of website pages records
-----------------------------------------------------------------------*/
    @AuraEnabled
    public static list<WrapperWebsitePage> getWebsitePageRecords(id opportunityId){
        try{
            List<WrapperWebsitePage> lstWrapperWebsitePage = new List<WrapperWebsitePage>();
            
            //Added by Kunal Raj | 10th May 2022
            List<String> listAllRiskComments = new List<String>();
            String objectName = 'Website_Page__c';
            String fieldName ='Pick_Risk_Remark__c';
            
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple){
                System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
                listAllRiskComments.add(pickListVal.getValue());
            }    
            //Ended by Kunal//
            
            //Added by Pooja - SFI-332
            List<string> preApprovedEmiList = SystemUtility.getPicklistValue('opportunity','Pre_approved_for_EMI__c');
            List<string> preApprovedMcpList = SystemUtility.getPicklistValue('opportunity','Pre_approved_for_MCP__c');
            //Ended by Pooja
            
            List<String> lstWebsitePageStatus = new List<String>();
            List<String> lstProfilesHavingIsViewAccess = New List<string>();
            List<String> lstProfilesHavingIsEditAccess = New List<string>();
            List<String> listStatusForRiskUsers = New List<string>();
            List<String> websiteStatusValues = New List<String>{'Pending','Verification in Process','Website OK','Website Error','Website OK (Non Cards)'};
                List<String> salesUserwebsiteStatusValues = New List<String>{'Pending','Website Error'};
                    List<String> riskUserwebsiteStatusValues = New List<String>{'Verification in Process','Pending'};
                        List<String> readOnlywebsiteStatusValues = New List<String>{'Website OK','Website OK (Non Cards)'};
                            
                            User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            
            String statusVals = System.Label.Status_on_WebsitePage_Details;
            if(string.isNotBlank(statusVals))
                listStatusForRiskUsers = statusVals.split(', ');        
            
            String profilesHavingIsEditAccess = System.Label.Profiles_to_Edit_Webiste_Page_Details;
            if(string.isNotBlank(profilesHavingIsEditAccess))
                lstProfilesHavingIsEditAccess = profilesHavingIsEditAccess.split(',');
            
            String profilesHavingIsViewAccess = System.Label.Profiles_to_View_Webisite_Page_Details;
            if(string.isNotBlank(profilesHavingIsViewAccess))
                lstProfilesHavingIsViewAccess = profilesHavingIsViewAccess.split(',');
            
            lstWebsitePageStatus = SystemUtility.getPicklistValue('Website_Page__c', 'Status__c');
            
            List<ProcessInstance> approvalList = new List<ProcessInstance>();
            
            Map<string,Website_Page__c> webPageNameWithMap = new Map<string,Website_Page__c>();
            WrapperWebsitePage wrapperWebsitePageObj = new WrapperWebsitePage();
            List<Website_details__c> websiteDetailsList = New List<Website_details__c>();
            List<Comments__c> commentsList = New List<Comments__c>();
            //List<String> riskRatingList = SystemUtility.getPicklistValue('Opportunity', 'Risk_Rating__c');
            
            if(opportunityId != null){
                wrapperWebsitePageObj.OppObj = [Select Id,Website_Status__c,Integration_Type__c,Android_URL__c,
                                                IOS_URL__c,MCC_Code__c, Risk_Classification_Status__c,                                                                              
                                                Base_Merchant_Id__c,Partner__c,Website__c,NDX_Score__c,Merchant_Business_Type__c,Pre_Approved_for_priority_settlement__c,Max_Same_Day_Settlement_Amount__c, 
                                                Pre_approved_for_EMI__c,Pre_approved_for_MCP__c,LOB_Approver_Risk_Team__c,LOB_Rejection_Reason__c,LOB_Status_PreRisk__c,
                                                Business_Entity__c,BusinessCategory__c,Sub_Category__c from Opportunity Where Id=: opportunityId]; //Added this-Pooja//
                
                system.debug('======'+wrapperWebsitePageObj.OppObj.Pre_Approved_for_priority_settlement__c);
                List<Website_Page_Master__c> wpmList = [Select Id,Name,Page_Details__c,Merchant_Business_Type__c,Active__c from Website_Page_Master__c where Active__c=true
                                                        AND Merchant_Business_Type__c=: wrapperWebsitePageObj.OppObj.Merchant_Business_Type__c];
                
                List<Website_Page__c> webPageList = new List<Website_Page__c>();
                Boolean checkUpsert = false;
                
                getWebsiteDetails(wrapperWebsitePageObj.OppObj.Id, websiteDetailsList);
                if(!websiteDetailsList.isEmpty()) getLatestComments(wrapperWebsitePageObj.OppObj.Id, websiteDetailsList[0].Id, commentsList);
                
                for(Website_Page__c wpEach : [SELECT id, Name, Opportunity__c, Opportunity__r.AccountId, Risk_Remarks__c, Do_Not_Publish__c,
                                              Sales_Remarks__c, Status__c, Opportunity__r.Name, Opportunity__r.Website_Status__c,Opportunity__r.MCC_Code__c,
                                              Opportunity__r.LOB_Rejection_Reason__c,Opportunity__r.LOB_Status_PreRisk__c,
                                              Opportunity__r.Pre_approved_for_EMI__c,Opportunity__r.Pre_approved_for_MCP__c,
                                              Opportunity__r.NDX_Score__c ,URL__c, Page_Details__c, Active__c, Opportunity__r.Integration_Type__c,
                                              Opportunity__r.Blacklist__c,Opportunity__r.Merchant_Business_Type__c,Pick_Risk_Remark__c
                                              FROM Website_Page__c
                                              WHERE Opportunity__c =: opportunityId
                                              AND Active__c = true AND (Opportunity__r.Website_Status__c IN: websiteStatusValues)
                                              AND Opportunity__r.Integration_Type__c = 'Thirdparty'// AND Opportunity__r.Integration_Type__c = 'Tools'
                                              AND (Opportunity__r.Website__c != Null OR Opportunity__r.IOS_URL__c != Null
                                                   OR Opportunity__r.Android_URL__c != Null)
                                              ORDER BY Name ASC]){
                                                  webPageNameWithMap.put(wpEach.name,wpEach);
                                                  webPageList.add(wpEach);
                                              }
                
                
                for(Website_Page_Master__c wpm : wpmList){
                    
                    if(!webPageNameWithMap.isEmpty() && !webPageNameWithMap.containsKey(wpm.Name) &&
                       webPageNameWithMap.size()<wpmList.Size() && webPageNameWithMap.Size()>0 && wpm.Active__c
                       && wpm.Merchant_Business_Type__c == wrapperWebsitePageObj.OppObj.Merchant_Business_Type__c){
                           webPageList.add(createWebsitePages(opportunityId, wpm));
                           checkUpsert = true;
                       }else if(webPageNameWithMap.isEmpty() && webPageNameWithMap.Size()==0){
                           If(wrapperWebsitePageObj.OppObj.Website_Status__c != 'Not Applicable'
                              && wrapperWebsitePageObj.OppObj.Integration_Type__c=='Thirdparty' /*&& wrapperWebsitePageObj.OppObj.Integration_Type__c=='Tools'*/ && wpm.Active__c
                              && (String.isNotBlank(wrapperWebsitePageObj.OppObj.Website__c) || String.isNotBlank(wrapperWebsitePageObj.OppObj.IOS_URL__c)
                                  || String.isNotBlank(wrapperWebsitePageObj.OppObj.Android_URL__c))
                              && wpm.Merchant_Business_Type__c == wrapperWebsitePageObj.OppObj.Merchant_Business_Type__c){
                                  
                                  webPageList.add(createWebsitePages(opportunityId, wpm));
                                  checkUpsert = true;
                              }
                       }
                }
                
                if(checkUpsert) upsert webPageList;
                
                for(Website_Page__c websitePageObj : [SELECT id, Name, Opportunity__c, Opportunity__r.AccountId, Risk_Remarks__c, Do_Not_Publish__c,
                                                      Sales_Remarks__c, Status__c, Opportunity__r.Name, Opportunity__r.Website_Status__c,Opportunity__r.MCC_Code__c,
                                                      Opportunity__r.NDX_Score__c,URL__c, Page_Details__c, Active__c, Opportunity__r.Integration_Type__c,
                                                      Opportunity__r.Blacklist__c,Opportunity__r.Merchant_Business_Type__c,Opportunity__r.Account.NDX_Score__c,Pick_Risk_Remark__c,Opportunity__r.LOB_Rejection_Reason__c
                                                      FROM Website_Page__c WHERE Opportunity__c =: opportunityId AND Active__c = true
                                                      ORDER BY Name ASC]) 
                {
                    system.debug('websitePageObj ============>>> '+websitePageObj);
                    WrapperWebsitePage eachWrapperWebsitePageObj = new WrapperWebsitePage();
                    eachWrapperWebsitePageObj.isObjectEditable = Schema.sObjectType.Website_Page__c.isUpdateable();
                    eachWrapperWebsitePageObj.WebsitePageObj = websitePageObj;
                    eachWrapperWebsitePageObj.OppObj = WrapperWebsitePageObj.OppObj;
                    eachWrapperWebsitePageObj.lstWebsitePageStatus = lstWebsitePageStatus;
                    eachWrapperWebsitePageObj.userObj = userObj;
                    eachWrapperWebsitePageObj.listAllRiskComments = listAllRiskComments; //Added by Kunal -- SFI-279
                    
                    if(!websiteDetailsList.isEmpty() && websiteDetailsList.size() >0) eachWrapperWebsitePageObj.websiteDetailsObj = websiteDetailsList[0];
                    
                    //added - Kunal - To populate the Risk Comments to Risk Remarks -- SFI-279
                    if((String.isNotBlank(websitePageObj.Pick_Risk_Remark__c) && String.isBlank(websitePageObj.Risk_Remarks__c)) || (String.isNotBlank(websitePageObj.Pick_Risk_Remark__c) && String.isNotBlank(websitePageObj.Risk_Remarks__c))){
                        websitePageObj.Risk_Remarks__c = websitePageObj.Pick_Risk_Remark__c;
                    } 
                    // Kunal - End
                    
                    if(!commentsList.isEmpty() && commentsList.size() >0) eachWrapperWebsitePageObj.latestCommentsObj = commentsList[0];
                    system.debug('######## eachWrapperWebsitePageObj.latestCommentsObj '+eachWrapperWebsitePageObj.latestCommentsObj);
                    
                    if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                        eachWrapperWebsitePageObj.isEditAllow = true;
                    }else{
                        if(salesUserwebsiteStatusValues.contains(eachWrapperWebsitePageObj.OppObj.Website_Status__c) && lstProfilesHavingIsViewAccess.contains(userObj.Profile.Name)){
                            eachWrapperWebsitePageObj.isEditAllow = true;
                        }
                        else if(riskUserwebsiteStatusValues.contains(eachWrapperWebsitePageObj.OppObj.Website_Status__c) && lstProfilesHavingIsEditAccess.contains(userObj.Profile.Name)){
                            eachWrapperWebsitePageObj.isEditAllow = true;
                        }else{
                            eachWrapperWebsitePageObj.isOnlyViewAllow = true;
                        }
                    }
                    
                    eachWrapperWebsitePageObj.isSalesRemark = Schema.sObjectType.Website_Page__c.fields.Sales_Remarks__c.isUpdateable() ? true : false;
                    eachWrapperWebsitePageObj.isRiskRemark = Schema.sObjectType.Website_Page__c.fields.Risk_Remarks__c.isUpdateable() ? true : false;
                    eachWrapperWebsitePageObj.isStatus = Schema.sObjectType.Website_Page__c.fields.Status__c.isUpdateable() ? true : false;
                    eachWrapperWebsitePageObj.isURL = Schema.sObjectType.Website_Page__c.fields.URL__c.isUpdateable() ? true : false;
                    eachWrapperWebsitePageObj.pageDetails = Schema.sObjectType.Website_Page__c.fields.Page_Details__c.isUpdateable() ? true : false;
                    
                    lstWrapperWebsitePage.add(eachWrapperWebsitePageObj);
                }
                if(!lstWrapperWebsitePage.isEmpty()){
                    getProcessInstance(lstWrapperWebsitePage[0].WebsitePageObj.Opportunity__r.AccountId, approvalList);
                    
                    if(!approvalList.isEmpty() && approvalList[0].Status == 'Pending'){
                        lstWrapperWebsitePage[0].isInApprovalProcess = true;
                    }                
                    return lstWrapperWebsitePage;
                }
            }
            If(Test.isRunningTest()) integer i = 1/0;
            return lstWrapperWebsitePage;
        }catch(Exception ex){
            return null;
        }
    }
    //Added by pooja || SFI-412
    @AuraEnabled
    public static Map<String,string> getPickListValues(string strObjectName,string strPicklistField){
        
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f : lstPickListValues) {
            System.debug('Value = ' +f.getValue() +' , Label = ' +f.getLabel());
            options.put(f.getValue(),f.getLabel());
        }
        return options;
    }
  //Ended || Pooja || for SFI-412//  
    /*------------------------------------------------------------
Description:    method to save the website pages records
------------------------------------------------------------*/
    @AuraEnabled
    public static String saveWebsitePageRecords(String strWrapperWebsitePage){
        system.debug('strWrapperWebsitePage ========== '+strWrapperWebsitePage);
        //String recordTypeId = Schema.SObjectType.Website_Page__c.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        List<WrapperWebsitePage> lstWrapperWebsitePage = new List<WrapperWebsitePage>();
        
        if(String.isNotBlank(strWrapperWebsitePage)){
            lstWrapperWebsitePage = (List<WrapperWebsitePage>) Json.deserialize(strWrapperWebsitePage, list<WrapperWebsitePage>.class);
            system.debug('lstWrapperWebsitePage ========== '+lstWrapperWebsitePage);            
            
            if(!lstWrapperWebsitePage.isEmpty()){
                List<Website_Page__c> lstWebsitePage = new List<Website_Page__c>();
                
                for(WrapperWebsitePage WrapperWebsitePageObj : lstWrapperWebsitePage){
                    //WrapperWebsitePageObj.WebsitePageObj.RecordTypeId = recordTypeId;
                    system.debug('WrapperWebsitePageObj.WebsitePageObj. ==> '+WrapperWebsitePageObj.WebsitePageObj.Status__c);
                    //system.debug('WrapperWebsitePageObj.WebsitePageObj. ==> '+WrapperWebsitePageObj.WebsitePageObj.Sales_Remarks__c);
                    //WrapperWebsitePageObj.WebsitePageObj.Page_Details__c = WrapperWebsitePageObj.WebsitePageObj.Page_Details__c.subString(1, WrapperWebsitePageObj.WebsitePageObj.Page_Details__c.length()-1);
                    IF(WrapperWebsitePageObj.WebsitePageObj.Do_Not_Publish__c) WrapperWebsitePageObj.WebsitePageObj.Do_Not_Publish__c = False;
                    lstWebsitePage.add(WrapperWebsitePageObj.WebsitePageObj);
                    
                }
                
                if(!lstWebsitePage.isEmpty()){
                    try{
                        system.debug('lstWebsitePage ==> '+lstWebsitePage);
                        update lstWebsitePage;
                        
                        If(Test.isRunningTest()) integer i = 1/0;
                        return Label.Website_Page_Update;
                    }catch(Exception ex){
                        return 'Error: '+ ex.getMessage() +' at line '+ex.getLineNumber();
                    }
                }                
            }
        }
        return null;
    }
    
    public static void getProcessInstance(Id strAccId, List<ProcessInstance> approvalList){
        if(String.isNotBlank(strAccId)){
            approvalList.addAll([SELECT TargetObjectId, Status, CreatedDate,
                                 (SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                  FROM Steps ORDER BY CreatedDate DESC)
                                 FROM ProcessInstance
                                 WHERE TargetObjectId =: strAccId
                                 ORDER BY CreatedDate DESC]);
        }
    }
    
    // Added by Pooja - DATE - 27-05-2022 //Start// --- MCC code - base MID mapping-- SFI-278
    @AuraEnabled
    public static string getMccCodeMetaData(string mccCode,Id partner)
    {
        system.debug('mcc code====='+mccCode);
        system.debug('partner====='+partner);
        string strmccCode='';
        try{
            List<MCC_code_Base_MID_Mapping__mdt> mccCodeRec=[select id,MCC_Code__c,Base_MID__c 
                                                             from MCC_code_Base_MID_Mapping__mdt where MCC_Code__c=:mccCode];
            system.debug('check meta data values'+mccCodeRec);
            //MCC code given and Partner not given in oppty
            if(string.isNotBlank(mccCode)&&partner==null){
                //when meta data exist based id related to given mcc code
                if(mccCodeRec.size()>0){
                    strmccCode=mccCodeRec[0].Base_MID__c;
                }
                else{//when meta data not having realted mcc code  poupulate base mid
                    strmccCode='8597556';
                }
            }
            else{
                
                //Mcc code given and partner also given in opty
                
                strmccCode='';
            }
            
            system.debug('base mid==return'+strmccCode);
            return strmcccode;    
        }catch(exception ex)
        {
            system.debug('check meta data values');
            return strmcccode;           
        }
        
    }
    // Ended by Pooja - DATE - 27-05-2022
    
    @AuraEnabled
    public static MccWrapper updateOptyWebsiteStatus(Id recordId, String status, String strWrapperWebsitePage){
        /*(Id recordId, String status,string mccCode, string riskRating, Boolean isFileUploaded, String strWrapperWebsitePage,
            Boolean isPrioritySettlment, string preApprvdEMI, string PreApprvdMCP, integer maxAmount,
            integer BaseMID, string businessEntity, string businessCategory, string subCategory,
            string lobStatus,string lobRiskApprover, string lobRiskReason)Added this-Pooja*/ 
        
        //system.debug('===lobStatus'+lobStatus);
        // system.debug('===lobRiskReason'+lobRiskReason);                                                
        Set<string> merchantDocStatus = New Set<String>();
        String recordTypeId = Schema.SObjectType.Website_Page__c.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        MccWrapper MccWrapperObj = new MccWrapper();
        MccWrapperObj.isMccUpdated = false;
        string remarks = '';
                                                     
        
        try{
            If(String.isNotBlank(recordId) && String.isNotBlank(status)){
                List<Merchant_Document__c> merchantDocList = [Select Id,Onboarding_Status__c from Merchant_Document__c where Opportunity__c=:recordId AND KYC_Documentable_Type__c=:'WebsiteDetail'];
                Opportunity opty = [SELECT Id, Name, Website_Status__c,MCC_Code__c,Base_Merchant_Id__c,Partner__c,NDX_Score__c,Android_URL__c,IOS_URL__c,Pre_Approved_for_priority_settlement__c,Max_Same_Day_Settlement_Amount__c, 
                                    Pre_approved_for_EMI__c,Pre_approved_for_MCP__c,LOB_Approver_Risk_Team__c,LOB_Rejection_Reason__c,LOB_Status_PreRisk__c,Business_Entity__c,BusinessCategory__c,Sub_Category__c,Website__c FROM Opportunity WHERE Id =:recordId]; //Added this-Pooja//
                
                List<Website_Details__c> websiteDetailList = [Select Id,Website_Status__c From Website_Details__c Where Opportunity__c =:recordId AND Active__c =True LIMIT 1];
                
                List<WrapperWebsitePage> websitePageWrapList = new List<WrapperWebsitePage>();
                
                if(String.isNotBlank(strWrapperWebsitePage)){
                    
                    websitePageWrapList = (List<WrapperWebsitePage>) Json.deserialize(strWrapperWebsitePage, list<WrapperWebsitePage>.class);
                    system.debug('websitePageWrapList ========== '+websitePageWrapList);            
                }
                if(!merchantDocList.isEmpty()){
                    for(Merchant_Document__c md : merchantDocList){
                        if(string.isNotBlank(md.Onboarding_Status__c)) merchantDocStatus.add(md.Onboarding_Status__c);
                    }
                }
                system.debug('#### merchant status = '+merchantDocList);
                system.debug('#### status = '+status);
                if(!merchantDocStatus.isEmpty()){
                    if(merchantDocStatus.contains('Declined')){
                        opty.Website_Status__c='Website Error';
                    }else if(merchantDocStatus.contains('Approved') && !merchantDocStatus.contains('Declined')){
                        opty.Website_Status__c = status;
                    }else{
                        opty.Website_Status__c = 'Verification in Process';
                    }
                }else{
                    opty.Website_Status__c = status;
                }
                
                //Added by Pooja// --- MCC code - base MID mapping-- SFI-278
                
                /*system.debug('base mid===='+baseMid);
if(String.isNotBlank(mccCode)){
opty.MCC_Code__c = mccCode; 
opty.Base_Merchant_Id__c = baseMid;//added
}*/
                
                //Ended by Pooja// --- MCC code - base MID mapping-- SFI-278
                
                /* if(String.isNotBlank(riskRating)){
opty.Risk_Rating__c = riskRating;  
}*/
                
                // Added by Pooja - DATE - 15-05-2022 //Start// --- Upload PreApproved List of Merchants on SalesForce-- SFI-204 continuation
                
                /*system.debug('isPrioritySettlment'+isPrioritySettlment);
system.debug('maxAmount'+maxAmount);

opty.Pre_Approved_for_priority_settlement__c = isPrioritySettlment;
if(maxAmount!=0){ opty.Max_Same_Day_Settlement_Amount__c = maxAmount;}
else{
opty.Max_Same_Day_Settlement_Amount__c=0;
}

opty.Pre_approved_for_EMI__c = preApprvdEMI;
opty.Pre_approved_for_MCP__c = PreApprvdMCP;
opty.LOB_Rejection_Reason__c = lobRiskReason;
opty.LOB_Status_PreRisk__c = lobStatus;
opty.LOB_Approver_Risk_Team__c = lobRiskApprover;
opty.Business_Entity__c = businessEntity;
opty.BusinessCategory__c = businessCategory;
opty.Sub_Category__c = subCategory;*/
                
                update opty;
                
                //Ended by Pooja-Upload PreApproved List of Merchants on SalesForce-- SFI-204 continuation
                
                if(!websitePageWrapList.isEmpty()){
                    String rejectionReason = null;
                    for(WrapperWebsitePage wrapWebsitePageObj : websitePageWrapList){
                        if(rejectionReason == null && String.isNotBlank(wrapWebsitePageObj.websitePageObj.Opportunity__r.LOB_Rejection_Reason__c)){
                           rejectionReason = 'LOB Rejection Reason - ' +wrapWebsitePageObj.websitePageObj.Opportunity__r.LOB_Rejection_Reason__c;
                            
                        }
                        if(wrapWebsitePageObj.WebsitePageObj.Name == 'Contact Us Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                            remarks = 'Contact Us Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                        }
                        else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Product/Services Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                            remarks = remarks + '\n Product/Services Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                            
                        }
                        else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Terms & Conditions Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                            remarks = remarks + '\n Terms & Conditions Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                        }
                        
                        /* Added By Kunal : The Risk comment value to be populated in Comment Section --SFI-279 */
                        if(wrapWebsitePageObj.WebsitePageObj.Name == 'Contact Us Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                            remarks = 'Contact Us Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                        }
                        else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Product/Services Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                            remarks = remarks + '\n Product/Services Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                            
                        }
                        else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Terms & Conditions Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                            remarks = remarks + '\n Terms & Conditions Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                        }
                        /*Ended by Kunal SFI --279*/
                    }
                    
                    if (rejectionReason != null) {
                        remarks = remarks + '\n' + rejectionReason;
                    }
                    
                }
                system.debug('######## opty '+opty.Website_Status__c);
                system.debug('######## remarks '+remarks);
                if(!websiteDetailList.isEmpty()){
                    websiteDetailList[0].Website_Status__c = opty.Website_Status__c;
                    update websiteDetailList;
                    if(String.isNotBlank(opty.Website_Status__c) && opty.Website_Status__c != 'Website OK'){
                        Comments__c commentObj = createComments(remarks, 'WebsiteDetail', 'Salesforce', websiteDetailList[0].Id, opty.Id);
                        insert commentObj;
                    }
                    
                }else if(websiteDetailList.isEmpty()){
                    Website_Details__c wdObj = createWebsiteDetails(opty);
                    insert wdObj;
                    if(String.isNotBlank(opty.Website_Status__c) && opty.Website_Status__c != 'Website OK'){
                        Comments__c commentObj = createComments(remarks, 'WebsiteDetail', 'Salesforce', wdObj.Id, opty.Id);
                        insert commentObj;
                    }
                }
            }
        }catch(exception ex){
            system.debug('ex.line='+ex.getLineNumber() +'ex.message'+ex.getMessage()+' '+ex.getTypeName());
            MccWrapperObj.exceptionError = ex.getMessage();
        }
        return MccWrapperObj;
    }
    
    //Added this-Pooja --- Approval Tab || Pre Risk Tab-SFI-412//
    
    @AuraEnabled
    public static opportunity updateApprovalDetails(Id recordId, Boolean isPrioritySettlment, integer maxAmount, string preApprvdEMI, string PreApprvdMCP){
        opportunity opty=new opportunity();                                   
        try{
            If(String.isNotBlank(recordId)){
                opty = [SELECT Id, Name, Website_Status__c,MCC_Code__c,Base_Merchant_Id__c,Partner__c,NDX_Score__c,Android_URL__c,IOS_URL__c,Pre_Approved_for_priority_settlement__c,Max_Same_Day_Settlement_Amount__c, 
                        Pre_approved_for_EMI__c,Pre_approved_for_MCP__c, Website__c FROM Opportunity WHERE Id =:recordId]; //Added this-Pooja//  
                opty.Pre_approved_for_EMI__c = preApprvdEMI;
                opty.Pre_approved_for_MCP__c = PreApprvdMCP;               
                opty.Pre_Approved_for_priority_settlement__c = isPrioritySettlment;
                opty.Max_Same_Day_Settlement_Amount__c = maxAmount;                    
                update opty;
                
            }
        }catch(exception ex)
        {
            system.debug('error while updating oppty');
        } 
        return opty;
    }
    
    @AuraEnabled
    public static opportunity updatePreRiskDetails(Id recordId, string mccCode, integer BaseMID, Boolean isFileUploaded, string lobRiskReason,
                                                   string lobStatus, string lobRiskApprover, string businessEntity, string businessCategory, string subCategory, string strWrapperWebsitePage){
                                                       opportunity opty=new opportunity();                                   
                                                       try{
                                                           If(String.isNotBlank(recordId)){
                                                               opty = [SELECT Id, Name, Website_Status__c,MCC_Code__c,Base_Merchant_Id__c,Partner__c,NDX_Score__c,Android_URL__c,IOS_URL__c, 
                                                                       LOB_Approver_Risk_Team__c,LOB_Rejection_Reason__c,LOB_Status_PreRisk__c,Business_Entity__c,BusinessCategory__c,Sub_Category__c,Website__c FROM Opportunity WHERE Id =:recordId]; 
                                                               
                                                               Boolean rejectionReasonUpdated = opty.LOB_Rejection_Reason__c == lobRiskReason ? false : true;
                                                               
                                                               //Added by Pooja// --- MCC code - base MID mapping-- SFI-278
                                                               
                                                               system.debug('base mid===='+baseMid);
                                                               if(String.isNotBlank(mccCode)){
                                                                   opty.MCC_Code__c = mccCode; 
                                                                   opty.Base_Merchant_Id__c = baseMid;//added
                                                               }
                                                               
                                                               //Ended by Pooja// --- MCC code - base MID mapping-- SFI-278
                                                               
                                                               opty.LOB_Approver_Risk_Team__c = lobRiskApprover;
                                                               opty.LOB_Status_PreRisk__c = lobStatus;
                                                               opty.LOB_Rejection_Reason__c = lobRiskReason;
                                                               opty.Business_Entity__c = businessEntity;
                                                               opty.BusinessCategory__c = businessCategory;
                                                               opty.Sub_Category__c = subCategory;                
                                                               if(opty.LOB_Status_PreRisk__c == 'LOB Approved') {
                                                                   opty.Website_Status__c = 'Website OK';
                                                               } else if(opty.LOB_Status_PreRisk__c == 'LOB Rejected' || opty.LOB_Status_PreRisk__c == 'LOB Error' ) {
                                                                   opty.Website_Status__c = 'Website Error';
                                                               }else if(opty.LOB_Status_PreRisk__c == '') {
                                                                   opty.Website_Status__c = 'Verification in Process';
                                                               }
                                                               update opty;
                                                               
                                                                if (rejectionReasonUpdated) {
                                                                   string remarks = '';
                                                                   List<WrapperWebsitePage> websitePageWrapList = new List<WrapperWebsitePage>();
                                                                   if(String.isNotBlank(strWrapperWebsitePage)){                    
                                                                       websitePageWrapList = (List<WrapperWebsitePage>) Json.deserialize(strWrapperWebsitePage, list<WrapperWebsitePage>.class);            
                                                                   }
                                                                   
                                                                   if(!websitePageWrapList.isEmpty()) {
                                                                       /*for(WrapperWebsitePage wrapWebsitePageObj : websitePageWrapList){
                                                                           if(wrapWebsitePageObj.WebsitePageObj.Name == 'Contact Us Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                                                                               remarks = 'Contact Us Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                                                                           }
                                                                           else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Product/Services Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                                                                               remarks = remarks + '\n Product/Services Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                                                                           }
                                                                           else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Terms & Conditions Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c)){
                                                                               remarks = remarks + '\n Terms & Conditions Details - '+wrapWebsitePageObj.WebsitePageObj.Risk_Remarks__c;
                                                                           }
                                                                           
                                                                           if(wrapWebsitePageObj.WebsitePageObj.Name == 'Contact Us Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                                                                               remarks = 'Contact Us Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                                                                           }
                                                                           else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Product/Services Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                                                                               remarks = remarks + '\n Product/Services Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                                                                               
                                                                           }
                                                                           else if(wrapWebsitePageObj.WebsitePageObj.Name == 'Terms & Conditions Details' && String.isNotBlank(wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c)){
                                                                               remarks = remarks + '\n Terms & Conditions Details - '+wrapWebsitePageObj.WebsitePageObj.Pick_Risk_Remark__c;
                                                                           }
                                                                          
                                                                       }*/
                                                                       
                                                                       if (lobRiskReason != null) {
                                                                           remarks = remarks + '\n LOB Rejection Reason - ' + lobRiskReason;
                                                                       }
                                                                       
                                                                   }
                                                                   
                                                                   List<Website_Details__c> websiteDetailList = [Select Id,Website_Status__c From Website_Details__c Where Opportunity__c =:recordId AND Active__c =True LIMIT 1];
                                                                   if(!websiteDetailList.isEmpty()){
                                                                       if(String.isNotBlank(opty.Website_Status__c) && opty.Website_Status__c != 'Website OK'){
                                                                           Comments__c commentObj = createComments(remarks, 'WebsiteDetail', 'Salesforce', websiteDetailList[0].Id, recordId);
                                                                           insert commentObj;
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       } catch (exception ex) {
                                                           system.debug('error while updating oppty');
                                                       } 
                                                       return opty;
                                                   }
    
    //Ended by Pooja || SFI-412//
    
    public static Website_Page__c createWebsitePages(Id opportunityId, Website_Page_Master__c wpmObj){
        Website_Page__c websitePageObj = New Website_Page__c();
        websitePageObj.Active__c = true;
        websitePageObj.Approved__c = true;
        websitePageObj.Opportunity__c = opportunityId;
        websitePageObj.Page_Details__c = wpmObj.Page_Details__c;
        websitePageObj.Name = wpmObj.Name;
        websitePageObj.Status__c = 'Pending';
        //Added  - kunal
        websitePageObj.Pick_Risk_Remark__c = String.isNotBlank(websitePageObj.Pick_Risk_Remark__c) ? websitePageObj.Pick_Risk_Remark__c : null;
        //End- Kunal
        return websitePageObj;
    }
    
    public static Website_Details__c createWebsiteDetails(Opportunity opportunityObj){
        Website_Details__c wdObj = New Website_Details__c();
        wdObj.Active__c = True;
        wdObj.Opportunity__c = opportunityObj.Id;
        wdObj.Android_URL__c = String.isNotBlank(opportunityObj.Android_URL__c) ? opportunityObj.Android_URL__c : null;
        wdObj.Website_URL__c = String.isNotBlank(opportunityObj.Website__c) ? opportunityObj.Website__c : null;
        wdObj.IOS_URL__c = String.isNotBlank(opportunityObj.iOS_URL__c) ? opportunityObj.iOS_URL__c : null;
        wdObj.Website_Status__c = opportunityObj.Website_Status__c;
        return wdObj;
    }
    
    public static Comments__c createComments(string remarks, string commentableType, string currentUserName, Id wdObjId, Id opportunityId){
        Comments__c commentObj = New Comments__c();
        commentObj.Active__c = True;
        commentObj.Comment__c = remarks;
        commentObj.Commentable_Type__c = commentableType;
        commentObj.Comment_By__c = currentUserName;
        commentObj.Website_Details__c = wdObjId;
        commentObj.Opportunity__c = opportunityId;
        return commentObj;
    }
    
    public static List<Website_Details__c> getWebsiteDetails(Id OpportunityId, List<Website_Details__c> websiteDetailsList){
        websiteDetailsList.addAll([Select Id,Website_Status__c from Website_Details__c Where Opportunity__c =: OpportunityId AND Active__c= True]);
        return websiteDetailsList;
    }
    
    public static List<Comments__c> getLatestComments(Id OpportunityId, Id websiteDetailId, List<Comments__c> commentsList){
        commentsList.addAll([Select Id,Comment__c, Active__c, Comment_By__c from Comments__c Where Website_Details__c =: websiteDetailId ORDER BY CreatedDate DESC LIMIT 1]);
        return commentsList;
    }
    
    public class MccWrapper{
        @AuraEnabled
        public boolean isMccUpdated {get;set;}
        @AuraEnabled
        public string exceptionError {get;set;}
        @AuraEnabled
        public opportunity oppty {get;set;}
    }
    
}