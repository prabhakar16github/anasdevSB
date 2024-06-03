public class fetchOpportunityOrLeadDetails {

  public class MerchantIdInput {
    @InvocableVariable(required=true)
    public string sMID;
    @InvocableVariable(required=true)
    public string sProduct;
      
    @InvocableVariable
    public string spageName;
      
    @InvocableVariable
    public String sCaseCreated;
      
  }
  
    public class VisitorOutput {
        @InvocableVariable
        public String sDocumentStatus;
        
        @InvocableVariable
        public String sBusinessEntity;
        
        @InvocableVariable
        public Decimal sTotalDocsReceivedStatus;
        
        @InvocableVariable
        public Decimal sTotalRequiredMerchantDocuments;
        
        @InvocableVariable
        public DateTime sCounterSignedDate;
        
        @InvocableVariable
        public DateTime sDocsReceivedDate;
        
        @InvocableVariable
        public String sAgreementStatus;
        
        @InvocableVariable
        public Boolean statExceeded;
        
        @InvocableVariable
        public Date sDocsVerificationDate;
        
        @InvocableVariable
        public String sOpportunityId;
        
        @InvocableVariable
        public String sWebsiteStatus;
        
        
        @InvocableVariable
        public DateTime slatestWebUpdDate;
        
        @InvocableVariable
        public Boolean sWebtatExceeded;
        
        @InvocableVariable
        public DateTime sWebVerificationDate;
        
        @InvocableVariable
        public String sRiskRemark;
        
        @InvocableVariable
        public Boolean sBankDetailsUpdate;
        
        @InvocableVariable
        public String sPanStatus;
        
        @InvocableVariable
        public String sBankStatus;
        
        @InvocableVariable
        public String sSettlementStatus;
        
        @InvocableVariable
        public String sSettlementPendingReason;
        
        @InvocableVariable
        public string sSettlementTatExceeded;
        
        @InvocableVariable
        public string sLegalNameAccount;
        
        @InvocableVariable
        public string sRiskHoldReasonEmailContent;
        
        @InvocableVariable
        public string sOBHoldReasonEmailContent;
        
        @InvocableVariable
        public string sPreRiskHoldReasonEmailContent;
        
    }

    @InvocableMethod(label='Get Opp Lead deatails')
    public static List<VisitorOutput> getOpportunityLeadDetails(List<MerchantIdInput> merchantDetails) {
        
         //List<MerchantIdInput> merchantDetails
        //MerchantIdInput obj = new MerchantIdInput();
        //obj.sMID = '8006686';
        //obj.sProduct='PayUbiz';
        //obj.spageName = ' OnePayU Dashboard ';
        //obj.sCaseCreated='';
        //List<MerchantIdInput> merchantDetails = new List<MerchantIdInput>();
		//merchantDetails.add(obj);
        
        List<VisitorOutput> results = new List<VisitorOutput>();
        List<Integer> midList = new list<Integer>();
        List<String> productList = new List<String>();
        list<id> accIdList = new List<id>();
        Map<String,VisitorOutput> resultAccountIdMap = new Map<String,VisitorOutput>();
        Map<String,VisitorOutput> resultOpportunityIdMap = new Map<String,VisitorOutput>();
        
        BusinessHours bsnessHours = [SELECT Id FROM BusinessHours where Name = 'OneCare Business Hour' ORDER BY Name ASC];
        Integer BusinessDay = Integer.valueOf(Label.BusinessDayDocsTeam);
		String pageName;    
        String riskRemarks = '';
        Set<String> docsVerificationInProcess = new Set<String>();
        Opportunity oppforCase = new Opportunity();
        
        
        for (MerchantIdInput mDetail : merchantDetails) {
            Integer Mid = integer.valueOf(mDetail.sMID);
            
            system.debug('Mid=='+Mid);
            system.debug('mDetail.sProduct'+mDetail.sProduct);
            midList.add(Mid);
            productList.add(mDetail.sProduct);
            //pageName = mDetail.sPageName;
        }
        
        List<Opportunity> oppList = [Select id,Account.Document_Status__c ,Business_Entity_Formula__c,Account.Total_Docs_Received_Status_Received__c,
                                     Account.Total_Required_Merchant_Documents_New__c,AccountId,Account.Agreement_Status__c,Website_Status__c,Website__c,
                                      PAN_Verification_Status__c,Bank_Verification_Status__c,Settlement_Status__c,Legal_Name_Account__c,Risk_Hold_Reason_Email_Content__c,
                                     Pre_Risk_Hold_Reason_Email_Content__c,OB_Hold_Reason_Email_Content__c
                                     from Opportunity where Prod_Merchant_Id__c IN :midList AND ProductLabel__c IN :productList];
        
        List<Lead> leadList = [Select PAN_Verification_Status__c ,Bank_Verification_Status__c from lead where Prod_Merchant_Id__c IN :midList];
        system.debug('leadList.size() =='+leadList.size());
        system.debug('oppList.size() =='+oppList.size());

            //&& merchantDetails[0].sCaseCreated == 'false' 
        if(oppList.size() > 0 && oppList != null ){
            for(Opportunity opp : oppList){
                
                accIdList.add(opp.AccountId);
                
                VisitorOutput res = new VisitorOutput();
                if(opp.Account.Document_Status__c != 'Pending'){
                    res.sDocumentStatus = opp.Account.Document_Status__c;
                    if(opp.Account.Document_Status__c == 'Docs Received' && opp.Account.Agreement_Status__c == 'Counter Signed Received'){
                        docsVerificationInProcess.add(opp.AccountId);
                    }
                }
                else{
                    if(opp.Account.Total_Docs_Received_Status_Received__c < opp.Account.Total_Required_Merchant_Documents_New__c
                      && opp.Account.Total_Docs_Received_Status_Received__c > 0){
                        res.sDocumentStatus = 'Partially uploaded Docs';
                    }
                    else
                        res.sDocumentStatus = 'Pending';
                }
                
                if(opp.Website_Status__c != 'Not Applicable'){
                    res.sBankDetailsUpdate = true;
                }
                
                
                
                res.sBusinessEntity = opp.Business_Entity_Formula__c ;
                res.sTotalDocsReceivedStatus = opp.Account.Total_Docs_Received_Status_Received__c;
                res.sTotalRequiredMerchantDocuments = opp.Account.Total_Required_Merchant_Documents_New__c;
                res.sAgreementStatus = opp.Account.Agreement_Status__c;
                res.sOpportunityId = opp.id;
                res.sWebsiteStatus = opp.Website_Status__c;
                res.sPanStatus = opp.PAN_Verification_Status__c;
                res.sBankStatus = opp.Bank_Verification_Status__c;
                res.sSettlementStatus = opp.Settlement_Status__c;
                res.sLegalNameAccount = opp.Legal_Name_Account__c;
                res.sRiskHoldReasonEmailContent = opp.Risk_Hold_Reason_Email_Content__c;
                res.sOBHoldReasonEmailContent = opp.OB_Hold_Reason_Email_Content__c;
                res.sPreRiskHoldReasonEmailContent = opp.Pre_Risk_Hold_Reason_Email_Content__c;
                 
                if(opp.Bank_Verification_Status__c != 'Success' || opp.Website_Status__c != 'Approved' || opp.Account.Document_Status__c != 'Docs Approved'){
                    if(opp.Bank_Verification_Status__c != 'Success'){
                        res.sSettlementPendingReason = 'Bank' ;
                    } 
                    if(opp.Website_Status__c != 'Approved') {
                      res.sSettlementPendingReason  = res.sSettlementPendingReason != null ? res.sSettlementPendingReason + ', Website' : 'Website';
                    }   
                    if(opp.Account.Document_Status__c != 'Docs Approved'){
                        res.sSettlementPendingReason = res.sSettlementPendingReason != null ? res.sSettlementPendingReason +', Documents': 'Documents';
                    }  
                }
                                               
                resultAccountIdMap.put(opp.AccountId, res);
                resultOpportunityIdMap.put(opp.Id,res);
                oppforCase = opp;
                results.add(res);
            }
        if(accIdList.size() > 0 && accIdList != null && docsVerificationInProcess != null 
          && docsVerificationInProcess.size() > 0 ){
            
            List<String> fieldList = new List<String>{'Agreement_Status__c','Document_Status__c'};
            List<AccountHistory> accHistoryList = [SELECT Id, AccountId, Field, OldValue, NewValue,createdDate FROM AccountHistory WHERE AccountId IN :accIdList AND Field IN :fieldList Order by createdDate desc];
            
            for(AccountHistory accHistory : accHistoryList){
                VisitorOutput res1 = resultAccountIdMap.get(accHistory.AccountId);
                if(docsVerificationInProcess.contains(accHistory.AccountId)){
                if(accHistory.Field == 'Agreement_Status__c' && accHistory.NewValue == 'Counter Signed Received'){
                    res1.sCounterSignedDate = accHistory.CreatedDate;
                }
                else if(accHistory.Field == 'Document_Status__c' && accHistory.NewValue == 'Docs Received'){
                    res1.sDocsReceivedDate = accHistory.CreatedDate;
                }
                }
            }
        }
            else {
                List<OpportunityFieldHistory> oppHistoryList = [SELECT Id,OpportunityId, Field, OldValue, NewValue,createdDate FROM OpportunityFieldHistory WHERE OpportunityId IN :oppList AND Field = 'Website__c' Order by createdDate desc Limit 1];
                for(OpportunityFieldHistory oppHistory : oppHistoryList){
                    VisitorOutput res1 = resultOpportunityIdMap.get(oppHistory.OpportunityId);
                    res1.slatestWebUpdDate = oppHistory.createdDate;
                }
                
                List<Website_Page__c> webPqageList = [SELECT Status__c,URL__c ,Sales_Remarks__c,Risk_Remarks__c,Approved__c,Opportunity__c FROM Website_Page__c where Opportunity__c IN :oppList  ];
                
                for(Website_Page__c webPage : webPqageList){
                    VisitorOutput resp = resultOpportunityIdMap.get(webPage.Opportunity__c);
                    if(webPage.URL__c != null && webPage.Risk_Remarks__c != null){
                        riskRemarks = riskRemarks != null ? riskRemarks + webPage.URL__c + ': ' + webPage.Risk_Remarks__c + '\n': riskRemarks;
                        resp.sRiskRemark = riskRemarks;
                    }
                    
                }
                
            }
            
            for(VisitorOutput resp : results){
                if(resp.sCounterSignedDate != null || test.isRunningTest()){
                    Decimal daysBetween = getDurationbetween(bsnessHours, System.now(),resp.sCounterSignedDate);
                    system.debug('daysBetween=='+daysBetween);
                    if(daysBetween > 24){
                        resp.statExceeded = true;
                    }
                    else {
                        resp.statExceeded = False;
                        DateTime verificationDate = addBusinessDay(bsnessHours, resp.sCounterSignedDate, BusinessDay);
                        resp.sDocsVerificationDate = verificationDate != null ? Date.valueOf(verificationDate) : resp.sDocsVerificationDate;
                    }
            }
                if(resp.slatestWebUpdDate != null || test.isRunningTest()){
                    Decimal daysBetween = getDurationbetween(bsnessHours, System.now(),resp.slatestWebUpdDate);
                    if(daysBetween > 120)
                        resp.sWebtatExceeded = true;
                    else{
                        resp.sWebtatExceeded = False;
                        DateTime verificationDate = addBusinessDay(bsnessHours, resp.slatestWebUpdDate, BusinessDay);
                        resp.sWebVerificationDate = verificationDate != null ? Date.valueOf(verificationDate) : resp.sWebVerificationDate;  
                    }
                }
                system.debug('resp.sCounterSignedDate=='+resp.sCounterSignedDate);
            	system.debug('resp.sDocsVerificationDate=='+resp.sDocsVerificationDate);
                system.debug('resp.sWebtatExceeded=='+resp.sWebtatExceeded);
                
            }
        
        }
        
        //&& merchantDetails[0].sCaseCreated == 'false'
        else if(leadList.size() > 0 && leadList != null ){
            for(Lead eachLead : leadList){
                VisitorOutput res = new VisitorOutput();
                res.sPanStatus = eachLead.PAN_Verification_Status__c != null ? eachLead.PAN_Verification_Status__c : '';
                res.sBankStatus = eachLead.Bank_Verification_Status__c != null ? eachLead.Bank_Verification_Status__c : '';
                //res.sSettlementStatus = 'not done';
                results.add(res);
                
                system.debug('res.sBankStatus=='+res.sBankStatus);
                system.debug('res.sPanStatus=='+res.sPanStatus);
                system.debug('res.sSettlementStatus=='+res.sSettlementStatus);
            }            
        }
        
        /*else if(merchantDetails[0].sCaseCreated == 'true'){
            VisitorOutput res = new VisitorOutput();
            List<Case> caseList = [Select id,LP_Issue__c,LP_Sub_Issue__c,createdDate,Priority  from case where Opportunity__c = :oppforCase.id and LP_Issue__c = 'Money Deposit/Settlement Related' and Status != 'Closed' order by createdDate desc limit 1];
            if(!caseList.isEmpty()){
                Decimal HoursBetween = (getDurationbetween(bsnessHours,System.now(),caseList[0].createdDate));
                if(HoursBetween > 24){
                    caseList[0].Priority = 'High';
                    res.sSettlementTatExceeded = 'true';
                    update caseList[0];
                }
                else{
                res.sSettlementTatExceeded = 'false';
            }
            }
            else if(caseList.isEmpty()){
                system.debug('results.size()=='+results.size()+results);
                res.sSettlementTatExceeded = 'Raise a ticket';
            }
            
            results.add(res);
        }*/
        
        system.debug('results.size()=='+results.size()+results);
        if(results.size() == 0 || results == null || test.isRunningTest()){
            VisitorOutput resEmpty = new VisitorOutput();
            resEmpty.sBankDetailsUpdate = false;
            results.add(resEmpty);
        }
        return results;
        
    }
    
    
    public static Decimal getDurationbetween(BusinessHours busnHrs,Datetime date1, Datetime date2 ){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs.Id, date2, date1);   
            Long resultInHours = timeDiff/(60000*60);
            return resultInHours;
        }
        else{
            return 0;
        }
    }
    
    public static DateTime addBusinessDay(BusinessHours busnHrs,Datetime date1, long BusinessDay ){
        if(BusinessDay != null && date1 != null){
            Datetime verificationDate = BusinessHours.add(busnHrs.id, date1, BusinessDay);
            return verificationDate;
        }
        else{
            return null;
        }
    }
    
}