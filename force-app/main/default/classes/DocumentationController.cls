// =================== Used for "DocumentationCmp" Component=====================
public with sharing class DocumentationController{    
    /*----------------------------------------------------------------------------------------
Description:    method to get the list of merchant document and contracts records 
----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static WrapperDocument getMerchantDocumentRecords(Id SobjectId, String SobjectName){
        if(String.isNotBlank(SobjectId)){
            opportunity optyObj;
            Account accObj;
            Boolean isAllMerDocNotApproved = false;
            Boolean isAllContDocNotApproved = false; 
            List<Address_Details__c> lstAddDetails = new List<Address_Details__c>();
            List<Bank_Account_Detail__c> lstbankAcntDetails = new List<Bank_Account_Detail__c>();
            List<Contract> lstContract = new List<Contract>();
            List<ProcessInstance> approvalList = new List<ProcessInstance>();
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            List<WrapperMerchantDocument> lstWrapperMerchantDocument = new List<WrapperMerchantDocument>();
            List<WrapperContract> lstWrapperContract = new List<WrapperContract>();
            List<WrapperContract> lstWrapperPayoutContract = new List<WrapperContract>();
            List<Merchant_Auto_Approval_Details__c> mAutoApprovalDetailList = New List<Merchant_Auto_Approval_Details__c>();
            
            User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c,Is_Doc_Rejection_Allow__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            
            if(String.isNotBlank(SobjectName) && SobjectName == 'Opportunity'){
                /** added for V-KYC : SFI-983 */
                WrapperDocumentObj.vkycObj = getVkycObj(SobjectId);
                /** */
                optyObj = getOpportunityRecord(SobjectId); 
                getBankAccountDetails(optyObj, lstbankAcntDetails);
                if(String.isNotBlank(optyObj.E_Stamp__c)) WrapperDocumentObj.EStampNumber = optyObj.E_Stamp_Number__c;
                if(String.isNotBlank(optyObj.AccountId)){
                    accObj = getAccountRecord(optyObj.AccountId);
                    System.debug('accObj::::'+accObj);
                    getProcessInstance(accObj, optyObj, approvalList);            
                    getContracts(accObj, optyObj, lstContract);            
                    getAddressDetails(accObj, optyObj, lstAddDetails); 
                } 
                if(String.isNotBlank(optyObj.Id)) getMerchantAADetails(optyObj, mAutoApprovalDetailList);
            }else if(String.isNotBlank(SobjectName) && SobjectName == 'Account'){
                accObj = getAccountRecord(SobjectId);
            }             
            
            if(!approvalList.isEmpty() && approvalList[0].Status == 'Pending') WrapperDocumentObj.isInApprovalProcess = true;            
            
            if(optyObj != null && String.isNotBlank(optyObj.Id)) WrapperDocumentObj.optyObj = optyObj;
            if(optyObj != null && String.isBlank(optyObj.Document_Status_Document_Issue__c)) WrapperDocumentObj.optyObj.Document_Status_Document_Issue__c = 'Pending';
            
            WrapperDocumentObj.isContractExist = false;
            WrapperDocumentObj.isMerchantDocExist = false;
            if(accObj != null && String.isNotBlank(accObj.Id)) WrapperDocumentObj.accountObj = accObj;
            if(userObj != null && String.isNotBlank(userObj.Id)) WrapperDocumentObj.userObj = userObj;
            
            //============Updated for Onboarding Revamp==============
            if(!lstAddDetails.isEmpty()){
                for(Address_Details__c eachAddress : lstAddDetails){
                    if(eachAddress.Type__c == 'Registered'){
                        if(String.isNotBlank(eachAddress.Opportunity__c) && eachAddress.Opportunity__c == optyObj.Id){
                            WrapperDocumentObj.regdAddObj = eachAddress;
                        }else if(String.isBlank(eachAddress.Opportunity__c)){
                            WrapperDocumentObj.regdAddObj = eachAddress;
                        }
                    }
                    if(eachAddress.Type__c == 'Operating'){
                        if(String.isNotBlank(eachAddress.Opportunity__c) && eachAddress.Opportunity__c == optyObj.Id){
                            WrapperDocumentObj.operatingAddObj = eachAddress;
                        }else if(String.isBlank(eachAddress.Opportunity__c)){
                            WrapperDocumentObj.operatingAddObj = eachAddress;
                        }
                    }
                }
            }
            
            //if(!lstContract.isEmpty() && String.isNotBlank(lstContract[0].Id) && String.isNotBlank(lstContract[0].E_Stamp_Number__c)) WrapperDocumentObj.EStampNumber = lstContract[0].E_Stamp_Number__c;            
            if(!lstbankAcntDetails.isEmpty()) WrapperDocumentObj.bankAcntObj = lstbankAcntDetails[0];
            
            if(accObj != null && accObj.Id != null){
                getMerchantDoc(accObj, optyObj,lstWrapperMerchantDocument, userObj);
                system.debug('size::::::'+lstWrapperMerchantDocument.size()+ ' ^^^^^ lstWrapperMerchantDocument &&&&&&& ' +lstWrapperMerchantDocument);
                
                getContractRecords(accObj, optyObj,lstWrapperContract, userObj,lstWrapperPayoutContract);                
                system.debug(lstWrapperContract.size()+ ' ^^^^^ lstWrapperContract &&&&&&& ' +lstWrapperContract);
                
                if(!lstWrapperMerchantDocument.isEmpty()){
                    WrapperDocumentObj.lstWrapperMerchantDocument = lstWrapperMerchantDocument;
                    WrapperDocumentObj.isMerchantDocExist = true;
                    
                     /*Written By Rohit
                      * Calculate Time limit for Exceptionally Approval
                      * within 30 days if exceptionally approved should not be changed to normal approved than 
                      	opprtunitoy status should be pending and excetipnally status should be null.
                      	Calculate Time limit for Exceptionally Approval*/
                      
                    /*Map<Id,Opportunity> oppMapUpdate = new Map<Id,Opportunity>();
                    List<Merchant_Document__c> lstMerchantDoc = new List<Merchant_Document__c>();
                    List<Opportunity> oppListUpdate = new List<Opportunity>();
                    if(optyObj.Document_Status_Document_Issue__c=='Docs Approved' && optyObj.Exceptionally_Approval_Status__c=='Approved'){
                        for(WrapperMerchantDocument mer : WrapperDocumentObj.lstWrapperMerchantDocument){
                            if(mer.merchantDocumentObj.Exceptionally_Approval_Required__c ==true && mer.merchantDocumentObj.Exceptionally_Approval_Status__c=='Exceptionally Approved'){
                                Merchant_Document__c merdoc = new Merchant_Document__c();
                                Date todayDate = Date.today();
                                SYstem.debug('todayDate:::'+todayDate);
                                Integer exceptDate = Integer.valueOf(System.label.Exceptionally_TimeLine_Date);
                                Integer noOfDays = (todayDate.day()-optyObj.Approved_Date__c.day()) + exceptDate ;
                                System.debug('noOfDays:::::::'+noOfDays);
                                System.debug('exceptDate:::::::'+exceptDate);
                                if(noOfDays !=null && exceptDate !=null){
                                    if(noOfDays>exceptDate){
                                    optyObj.Document_Status_Document_Issue__c = 'Docs Received';
                                    optyObj.Exceptionally_Approval_Status__c = '';
                                    optyObj.Id = SobjectId;
                                    mer.merchantDocumentObj.Onboarding_Status__c = 'Pending';
                                    mer.merchantDocumentObj.Exceptionally_Approval_Status__c = '';
                                    
                                    merdoc.Onboarding_Status__c = 'Pending';
                                    merdoc.Exceptionally_Approval_Status__c='';
                                    merdoc.Exceptionally_Approval_Required__c = False;
                                    merdoc.Id =mer.merchantDocumentObj.Id; 
                                    lstMerchantDoc.add(merdoc);
                                    oppMapUpdate.put(optyObj.Id,optyObj);
                                    SYstem.debug('lstMerchantDoc::::009::'+lstMerchantDoc);
                                } 
                                }
                               
                            }
                        }
                        if(lstMerchantDoc.size()>0 && lstMerchantDoc !=null){
                            update lstMerchantDoc;
                        }
                        if(oppMapUpdate.size()>0 && oppMapUpdate !=null){
                            update oppMapUpdate.values();
                        }
                    }*/
                    // End 
                    System.debug('Size::100'+WrapperDocumentObj.lstWrapperMerchantDocument.size());
                }
                
                if(!lstWrapperContract.isEmpty()){
                    WrapperDocumentObj.lstWrapperContract = lstWrapperContract;
                    WrapperDocumentObj.isContractExist = true;
                    if(String.isNotBlank(lstWrapperContract[0].contractObj.E_Stamp_Number__c) && String.isBlank(WrapperDocumentObj.EStampNumber))	
                        WrapperDocumentObj.EStampNumber = lstWrapperContract[0].contractObj.E_Stamp_Number__c;
                }
                
                if(!lstWrapperPayoutContract.isEmpty()){
                    WrapperDocumentObj.lstWrapperPayoutContract = lstWrapperPayoutContract;
                    WrapperDocumentObj.isContractExist = true;
                    if(String.isNotBlank(lstWrapperPayoutContract[0].contractObj.E_Stamp_Number__c) && String.isBlank(WrapperDocumentObj.EStampNumber))	
                        WrapperDocumentObj.EStampNumber = lstWrapperPayoutContract[0].contractObj.E_Stamp_Number__c;
                }
                
                if(!mAutoApprovalDetailList.isEmpty()){
                    WrapperDocumentObj.merchantAADetailList = mAutoApprovalDetailList;
                } 
               
               
                
               if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c ){  
                    SYstem.debug('userObj.Profile.Name::'+userObj.Profile.Name+'Super_User__c::'+userObj.Super_User__c);
                    if(!lstWrapperPayoutContract.isEmpty()) WrapperDocumentObj.isPayoutEditAllow = true;
                    WrapperDocumentObj.isEditAllow = true;
                     
                }else{
                    
                    if(optyObj !=null && Schema.sObjectType.Merchant_Document__c.isUpdateable()){
                        system.debug('inside else::::::');
                        
                       
                        if(optyObj.Lead_Type__c.equalsIgnoreCase('Partner')){
                            WrapperDocumentObj.isEditAllow = true;
                        }
                        //=============Updating due to Onboarding Revamp===============
                        else if(lstWrapperMerchantDocument.isEmpty() /*&& optyObj.Merchant_Business_Type__c !='Enterprise'*/){
                            WrapperDocumentObj.isEditAllow = false;
                        }
                      
                     
                        else if(optyObj !=null && (optyObj.Document_Status_Document_Issue__c == 'Pending' || optyObj.Document_Status_Document_Issue__c == 'Docs Error')
                                 && optyObj.Merchant_Business_Type__c =='Enterprise' && !userObj.Is_Doc_Status_Update_Allow__c){
                                     WrapperDocumentObj.isEditAllow = true;
                                 }
                        else if(optyObj !=null && (optyObj.Document_Status_Document_Issue__c == 'Pending' || optyObj.Document_Status_Document_Issue__c == 'Docs Error')
                                && optyObj.Merchant_Business_Type__c =='Enterprise' && userObj.Is_Doc_Status_Update_Allow__c){
                                    WrapperDocumentObj.isEditAllow = false;
                                }
                        else if(optyObj !=null && System.Label.Doc_Status_Restrict_for_KAM.split(',').contains(optyObj.Document_Status_Document_Issue__c)
                                && optyObj.Merchant_Business_Type__c =='Enterprise' && !userObj.Is_Doc_Status_Update_Allow__c){
                                    WrapperDocumentObj.isEditAllow = false;
                                }
                        else if((optyObj !=null && optyObj.Document_Status_Document_Issue__c == 'Docs Approved' && optyObj.Agreement_Status__c == 'Approved' && optyObj.Next_ReKYC_Date__c == null && !optyObj.Is_dormant__c)){
                                WrapperDocumentObj.isEditAllow = false;
                            }
                        else{
                            WrapperDocumentObj.isEditAllow = true;
                        }
                        
                        // =============== Payout activation =======================
                        if(optyObj !=null && !lstWrapperPayoutContract.isEmpty() && !WrapperDocumentObj.lstWrapperPayoutContract.isEmpty() && WrapperDocumentObj.lstWrapperPayoutContract != null &&
                           (String.isBlank(optyObj.Payout_Activation_Status__c) || optyObj.Payout_Activation_Status__c !='Approved')){
                               WrapperDocumentObj.isPayoutEditAllow = true;
                           }else{
                               WrapperDocumentObj.isPayoutEditAllow = false;
                           }                        
                        // ===============  / Payout activation end=====================
                    }else{
                        WrapperDocumentObj.isEditAllow = false;
                        WrapperDocumentObj.isPayoutEditAllow = false;
                        system.debug(' WrapperDocumentObj.isEditAllow :::::'+ WrapperDocumentObj.isEditAllow );
                    }                        
                }
                return WrapperDocumentObj;
            }
        }
        return null; 
    } 
    
    /** added for V-KYC : SFI-983 */
    private static Video_KYC__c getVkycObj(String SobjectId){
        Video_KYC__c vkycObj = new Video_KYC__c();
        VKYC_DetailsController.Vkyc_Wrapper vkycWrap = VKYC_DetailsController.getVKYC_details(SobjectId);
        if(vkycWrap != NULL && vkycWrap.vkycObj != NULL){
            vkycObj = vkycWrap.vkycObj;
        }
        return vkycObj;
    }/** */
    
    /*------------------------------------------------------------
Description:    method to save the merchant document records 
------------------------------------------------------------*/
    @AuraEnabled
    public static String saveMerchantDocument(String strWrpDoc){
        
        system.debug('strWrpDoc ************* '+strWrpDoc);
        if(String.isNotBlank(strWrpDoc)){            
            WrapperDocument clsWrapperDocument = new WrapperDocument();
            clsWrapperDocument = (WrapperDocument) System.JSON.deserialize(strWrpDoc, WrapperDocument.class);
            system.debug('clsWrapperDocument ************* '+clsWrapperDocument.accountObj);
			system.debug('lstWrapperMerchantDocument ************* '+clsWrapperDocument.optyObj);            
            List<Merchant_Document__c> lstMerchantDoc = new List<Merchant_Document__c>();
            List<Contract> lstContract = new List<Contract>();
            List<Contract> lstContractCloned = new List<Contract>();
            List<Contract> lstContractDelete = new List<Contract>();
            List<Contract> lstContractDeleteNew = new List<Contract>();
            
            Integer MDTotalApproved = 0;
            Integer MDTotalReject = 0;
            Integer MDTotalReceived = 0;
            Integer ContractTotalApproved = 0;
            Integer ContractTotalReject = 0;
            Integer payoutContractApproved = 0;
            Integer payoutContractRejected = 0;
            //Added By Rohit Gupta
            Integer docStatusPending=0;
            Integer docStatusApproved=0;
            Integer excepApprovalRequired=0;
            //Added by Animesh
            Integer ExcAppStatusApproved = 0;
            Integer ExcAppStatusPending = 0;
            Integer ExcAppStatusReject = 0;
            Integer ExcAppStatusApprovedTotal = 0;
            Integer MDTotal = 0;
            
            
            Integer excepApproved=0;
            Integer excepRejected = 0;
            Integer excepPending = 0;
            Integer docStatus=0;
            if(clsWrapperDocument.lstWrapperMerchantDocument != null && !clsWrapperDocument.lstWrapperMerchantDocument.isEmpty()){                
                for(WrapperMerchantDocument clsWrpMerchantDocObj : clsWrapperDocument.lstWrapperMerchantDocument){
                    System.debug('clsWrpMerchantDocObj.merchantDocumentObj:::::'+clsWrpMerchantDocObj.merchantDocumentObj);
                    lstMerchantDoc.add(clsWrpMerchantDocObj.merchantDocumentObj);
                    /*******Below condition is to tagged every mentchant document to Opportunity added by rohit*********/
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Opportunity__c !=NULL){// added by rohit
                        clsWrpMerchantDocObj.merchantDocumentObj.Opportunity__c =  clsWrapperDocument.optyObj.Id;// added by rohit
                        
                    }
                     MDTotal++;
                    /*******New Code Added By Rohit**********/
                   ExcAppStatusApprovedTotal++;
                    SYstem.debug('inside if test123::'+clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c);
                    SYstem.debug('inside if test222::'+clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c);
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Exceptionally' && clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c == ''){
                        clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c = 'Exceptionally Pending';
                        clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c = 'Exceptionally';
                        
                        
                        
                        if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Exceptionally'){
                            clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Required__c = true;
                            
                        }
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Pending' || 
                       clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Received' || 
                       clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Declined' ||
                       clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Reuploaded' ||
                       clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c =='Approved'){
                           
                        clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c = ''; 
                        clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Required__c = False;
                    }
                    if( clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c == ''){
                      clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c = '';  
                    }
                    
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c == 'Exceptionally Approved'){
                        excepApprovalRequired++;
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Required__c==True){
                        ExcAppStatusApproved++;
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c == 'Exceptionally Pending'){
                        ExcAppStatusPending++;
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Exceptionally_Approval_Status__c == 'Exceptionally Rejected'){
                        ExcAppStatusReject++;
                    } 

                    
                    
                    
					
                    /******************End**********************/
                    
                    /** Added reKYC_Doc__c condition check to avoid 'Document_Status_Document_Issue__c' field update on opp for re-KYC doc. */
                    if(!clsWrpMerchantDocObj.merchantDocumentObj.reKYC_Doc__c && (clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Approved' || clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c=='Exceptionally')){
                        MDTotalApproved++;
                    }
                    if(!clsWrpMerchantDocObj.merchantDocumentObj.reKYC_Doc__c && clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Declined' ){
                        MDTotalReject++;
                    }
                    if(!clsWrpMerchantDocObj.merchantDocumentObj.reKYC_Doc__c && clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Received'){
                        MDTotalReceived++;
                    }
                    if(!clsWrpMerchantDocObj.merchantDocumentObj.reKYC_Doc__c && clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Pending' && String.isNotBlank(clsWrpMerchantDocObj.merchantDocumentObj.URL__c)){
                        MDTotalReceived++;
                    }
                    /** END -  Added reKYC_Doc__c condition */
                }
                //============= Updating the Code due to Onboarding Revamp==================

                /**********New Code Added By Rohit Gupta******************/
                
                if(ExcAppStatusReject > 0){ 
                    clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c = 'Rejected';
                }
                 else if(ExcAppStatusPending > 0){
                    clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c = 'Pending'; 

                }
                else if(ExcAppStatusApproved == excepApprovalRequired && ExcAppStatusApproved >0) {
                    clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c = 'Approved';
                }
               
                /*****************End***********************/
               
                if(clsWrapperDocument.optyObj.Merchant_business_Type__c == 'Enterprise' && clsWrapperDocument.optyObj.Lead_Type__c != 'Partner'){
                    SYstem.debug('Inside if:::254:::'+clsWrapperDocument.lstWrapperMerchantDocument.size());
                    if(MDTotalReject > 0){
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Error';
                    }
                    else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size() || MDTotalReceived >0 ) 
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Received';
                   /* else if(MDTotalReceived + MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size()){
                         clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Received';
                    	SYstem.debug('MDTotalReceived + MDTotalApproved::'+MDTotalReceived + MDTotalApproved); 
                    }*/
                      
                    else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size() && clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c=='Approved'){
                      clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Approved';  
                      clsWrapperDocument.optyObj.Approved_Date__c  = Date.today();
                    } 
                    else clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Pending';
                }
                else if(clsWrapperDocument.optyObj.Merchant_Business_Type__c == 'Compulsive' && clsWrapperDocument.optyObj.Lead_Type__c != 'Partner'){
                    if(MDTotalReject > 0) clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Error';
                    else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size()) 
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Received';
                    else if(MDTotalReceived > 0 && MDTotalApproved > 0 && MDTotalReceived + MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size())
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Received';
                    else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size() && clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c=='Approved'){
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Approved';
                        clsWrapperDocument.optyObj.Approved_Date__c  = Date.today();
                    } 
                    else clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Pending';
                }
                else if((clsWrapperDocument.optyObj.Merchant_business_Type__c == 'LongTail' || String.isBlank(clsWrapperDocument.optyObj.Merchant_business_Type__c)) && clsWrapperDocument.optyObj.Lead_Type__c != 'Partner'){
                    if(MDTotalReject > 0){
						clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Error';
                    } 
                    else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size() ||
                            (MDTotalReceived > 0 && MDTotalApproved > 0 && MDTotalReceived + MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size())){
                                clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Received';  
                            }
                    else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size() && (clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c=='Approved' || clsWrapperDocument.optyObj.Exceptionally_Approval_Status__c=='')){
                             clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Docs Approved';
                        	clsWrapperDocument.optyObj.Approved_Date__c  = Date.today();
                    }
                    else{
                        clsWrapperDocument.optyObj.Document_Status_Document_Issue__c = 'Pending';
                      
                    }
                        
                }
                //========= updating account level as partner team using the same===========
                if(clsWrapperDocument.optyObj.Lead_Type__c == 'Partner' && MDTotal > 2){
                    SYstem.debug('MDTotalReceived::::'+MDTotalReceived);
                    if(MDTotalReject > 0) clsWrapperDocument.accountObj.Document_Status__c = 'Docs Error';
                    
                    else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size() || 
                            (MDTotalReceived > 0 && MDTotalApproved > 0 && MDTotalReceived + MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size())){
                     			//SYstem.debug('MDTotalReceived::::'+MDTotalReceived);
                                clsWrapperDocument.accountObj.Document_Status__c = 'Docs Received';   
                    }
                        
                    else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size()){
                        SYstem.debug('MDTotalApproved::::'+MDTotalApproved);
                       clsWrapperDocument.accountObj.Document_Status__c = 'Docs Approved'; 
                    }
                        
                    else {
                        SYstem.debug('else:::::::');
                        clsWrapperDocument.accountObj.Document_Status__c = 'Pending';
                    }
                }
            }
           
            if(clsWrapperDocument.lstWrapperContract != null && !clsWrapperDocument.lstWrapperContract.isEmpty() 
               && (clsWrapperDocument.optyObj.Lead_Type__c == 'Partner' || clsWrapperDocument.optyObj.Merchant_Business_Type__c == 'Enterprise')){  
                   for(WrapperContract clsWrapperContract : clsWrapperDocument.lstWrapperContract){
                       if((clsWrapperContract.isContApproved && clsWrapperContract.contractObj.Status != 'Approved' && clsWrapperContract.contractObj.Contract_type__c=='Agreement') ||
                          (clsWrapperContract.isContDeclined && clsWrapperContract.contractObj.Status != 'Declined' && clsWrapperContract.contractObj.Contract_type__c=='Agreement')){
                              clsWrapperContract.contractObj.Does_Not_Publish__c = true;
                              //lstContractDelete.add(clsWrapperContract.contractObj);
                          }
                       else
                           lstContract.add(clsWrapperContract.contractObj);
                       
                       if((clsWrapperContract.contractObj.Status == 'Approved' || clsWrapperContract.contractObj.Status == 'Approved Activate') && clsWrapperContract.contractObj.Contract_type__c=='Agreement'
                          && clsWrapperContract.contractObj.Active__c){
                              ContractTotalApproved++;
                          }
                       if(clsWrapperContract.contractObj.Status == 'Declined' && clsWrapperContract.contractObj.Contract_type__c=='Agreement'
                          && clsWrapperContract.contractObj.Active__c){
                              ContractTotalReject++;
                          }
                   }
                   
                   //lstContractCloned = createnewContractsRecordsClone(lstContractDelete);
                   for(WrapperContract clsWrapperContract : clsWrapperDocument.lstWrapperContract){
                       if((clsWrapperContract.isContApproved && clsWrapperContract.contractObj.Status != 'Approved' && clsWrapperContract.contractObj.Contract_type__c=='Agreement') ||
                          (clsWrapperContract.isContDeclined && clsWrapperContract.contractObj.Status != 'Declined' && clsWrapperContract.contractObj.Contract_type__c=='Agreement')){
                              clsWrapperContract.contractObj.Does_Not_Publish__c = true;
                              if(clsWrapperContract.isContDeclined)
                                  clsWrapperContract.contractObj.Status = 'Declined';
                              else if(clsWrapperContract.isContApproved)
                                  clsWrapperContract.contractObj.Status = 'Approved';
                              //lstContractDeleteNew.add(clsWrapperContract.contractObj);
                          }
                   }

                   if(ContractTotalReject > 0) {
                       clsWrapperDocument.accountObj.Agreement_Status__c = 'Rejected';
                       clsWrapperDocument.optyObj.Agreement_Status__c = 'Rejected';
                   }
                   else if(ContractTotalApproved == clsWrapperDocument.lstWrapperContract.Size()) {
                       clsWrapperDocument.accountObj.Agreement_Status__c = 'Approved';
                       clsWrapperDocument.optyObj.Agreement_Status__c = 'Approved';
                   }
                   // }                
               }
            
            try{
                if(!lstContractDeleteNew.isEmpty()) upsert lstContractDeleteNew;
                if(!lstMerchantDoc.isEmpty())   upsert lstMerchantDoc;
                SYstem.debug('lstMerchantDoc:::445:'+lstMerchantDoc);
                if(!lstContract.isEmpty())      update lstContract;
                if(!lstContractDeleteNew.isEmpty()) delete lstContractDeleteNew;
                if(!lstContractCloned.isEmpty()) upsert lstContractCloned;
                
                 update clsWrapperDocument.optyObj; 
                //=============== Commenting the code due to onboarding Revamp===========
                /*if(clsWrapperDocument.optyObj.Merchant_Business_Type__c == 'Enterprise')
update clsWrapperDocument.optyObj; 
else{
update clsWrapperDocument.accountObj;
}
*/
                //======= update account level as partner team using the same=========
                update clsWrapperDocument.accountObj;
              
                System.debug('###### accountObj '+clsWrapperDocument.accountObj);
                return Label.Merchant_Document_Update;
            }catch(Exception ex){
                return 'Error: '+ ex.getMessage() +' at line '+ex.getLineNumber();
            }
        }    
        return 'No Record Exist';
    }
    
    @AuraEnabled
    public static List<WrapperMerchantDocument> deleteMerchantDocument(Id merchantDocId){
        if(String.isNotBlank(merchantDocId)){
            Merchant_Document__c merchantDoc = new Merchant_Document__c(Id=merchantDocId);
            delete merchantDoc;    
        }        
        return null;
    }  
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the list of Error Solution mapping based on Entity Type from Account
---------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static WrapperErrorSolution getErrorSolutionMapping(Account accountObj, Opportunity opportunityObj, Id docCateId){
        if((accountObj != null && String.isNotBlank(accountObj.Business_Entity__c)) || (opportunityObj != null && String.isNotBlank(opportunityObj.Business_Entity__c))){
            WrapperErrorSolution wrpErrorSolutionObj = new WrapperErrorSolution();
            List<Error_Solution_Mapping__c> lstErrorSolution = new List<Error_Solution_Mapping__c>();
            if(String.isNotBlank(opportunityObj.Business_Entity__c)){
                getErrorSolutionMappingRecords(opportunityObj.Business_Entity__c, docCateId, lstErrorSolution);
            }else{
                getErrorSolutionMappingRecords(accountObj.Business_Entity__c, docCateId, lstErrorSolution);
            }
            if(!lstErrorSolution.isEmpty()){
                wrpErrorSolutionObj.lstErrorSolutionsExist = lstErrorSolution;
            }
            wrpErrorSolutionObj.lstErrorSolutionsCustom = new List<Error_Solution_Mapping__c>{ new Error_Solution_Mapping__c(Error__c='', Solution__c='') };
                return wrpErrorSolutionObj;
        }
        return null;
    }
    
   /* @AuraEnabled//added by rahul
    public static Opportunity getOpportunity(Id oppId){
        return [SELECT Id, Name, Product__c, Product__r.Enable_Draft_Agreement__c, Product__r.Platform__c, MAF_Status__c, Merchant_Id__c,
                Product_Name__c, Identifier__c, AccountId, Pricing_Negotiation_Status__c, Product__r.Platform__r.Name, Bank_Verification_Status__c,
                Account.LOB_Status__c, Account.Dow_Jones_Status__c, Account.Document_Status__c,  Account.Business_Entity__c, 
                E_Stamp__c, E_Stamp__r.EStamp_Number__c, E_Stamp_Number__c,Settlement_Status__c,Partner_Id__c,Customized_Agreement__c,
                Account.Identifier__c, Account.Owner.Email, RecordTypeId, RecordType.Name, Lead_Type__c, 
                Profile_Verification_Status__c, Blacklist__c,Partner__r.Identifier__c,Account.BusinessCategoryName__c,
                Owner.Name,Owner.Email,Account.OwnerId,Business_Entity__c,Is_Partner_reffered_Merchant_Customized__c,PEP_Status__c,Customer_Declaration_PEP__c,Jocata_System_Alerts__c
                FROM Opportunity
                WHERE Id =: oppId];
    }*/
    
    
    
    
    
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the list of Error Solution records based on Entity Type Id
---------------------------------------------------------------------------------------------------*/
    public static void getErrorSolutionMappingRecords(Id businesEntityId, Id docuCateId, List<Error_Solution_Mapping__c> lstErrorSolution){
        lstErrorSolution.addAll([SELECT  Id, Name, Error__c, Solution__c, Entity__c, Document_Category__c
                                 FROM Error_Solution_Mapping__c
                                 WHERE Entity__c =: businesEntityId
                                 AND Document_Category__c =: docuCateId]);
    }
    
    public static ContentDocument getContentDocument(String uploadedDocumentId){
        if(String.isNotBlank(uploadedDocumentId)){
            return [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                    from ContentDocument 
                    where id =: uploadedDocumentId
                    LIMIT 1];
        }
        return null;
    }
    
    public static ContentVersion getContentVersion(String uploadedDocumentId){
        if(String.isNotBlank(uploadedDocumentId)){
            return [SELECT Id, Title, VersionData, isLatest, ContentDocumentId 
                    FROM ContentVersion 
                    WHERE isLatest = true 
                    AND ContentDocumentId =: uploadedDocumentId
                    LIMIT 1];
        }
        return null;
    } 
    
    /*-----------------------------------------------------------------------------------------------------
Description:    method to get the merchanr document object records
------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Merchant_Document__c getDocumentURL(Id strDocumentId){
        return getMerchantDocument(strDocumentId);
    }
    
    public static Merchant_Document__c getMerchantDocument(Id merchantDocId){
        if(String.isNotBlank(merchantDocId)){
            /** Added reKYC_Doc__c for SFI-804 */
            return [SELECT Id, Name, Document_Content_Type__c, File_Size__c, URL__c, Error__c, Solution__c, Expiry_Date__c,
                    Account__c, Document_Category__c,Opportunity__c, Document_Type__c, Document_Category__r.Name, Document_Type__r.Name, Active__c,
                    LastModifiedById, LastModifiedBy.Name, LastModifiedDate, Document_Category_Name__c, Document_Type_Name__c,reKYC_Doc__c
                    FROM Merchant_Document__c 
                    WHERE Id =: merchantDocId 
                    LIMIT 1];
        }
        return null;
    }
    
    /*-----------------------------------------------------------------------------------------------------
Description:    method to get the merchanr document records
------------------------------------------------------------------------------------------------------*/
    public static void getMerchantDoc(Account accObj, Opportunity oppObj,List<WrapperMerchantDocument> lstWrapperMerchantDocument, User userObj){
        List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
        List<String> lstOnboardingStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Onboarding_Status__c');
        List<string> lstDocumentType = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');  
        //Added by Animesh
        List<string> lstExpApprovalStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Exceptionally_Approval_Status__c');                                    
        Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
        mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
        SYstem.debug('mapDocCateIdVsLstTypeMapping::::::::'+mapDocCateIdVsLstTypeMapping);
        Map<String,Merchant_Document__c> existingMerchantDocMap = New Map<String,Merchant_Document__c>();
        List<Merchant_Document__c> merDocsExisting = new List<Merchant_Document__c>();//Added to show each merchant document records inside the documentation Tab
    
        for(Merchant_Document__c merchantDoc : [SELECT URL__c, 
                                                Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Name, 
                                                Onboarding_Remarks__c, Onboarding_Status__c ,
                                                Exceptionally_Approval_Status__c,Exceptionally_Approval_Required__c, Account__c, Active__c,
                                                Sales_Remarks__c, Third_Party_Verification_Remarks__c, Error__c, Solution__c,
                                                Third_Party_Verification_Status__c, Document_Received__c, Document_Content_Type__c, 
                                                File_Size__c, Document_Master_Id__c, Document_Master_Id__r.Required__c, Upload_Date__c,
                                                Document_Category__c, Document_Type__c, LastModifiedBy.Name, Expiry_Date__c,
                                                Document_Category__r.Name, Document_Type__r.Name, Document_Category_Name__c, Opportunity__c,Opportunity__r.Offline_Lead__c, Account__r.Offline_Lead__c,
                                                reKYC_Doc__c /** Added reKYC_Doc__c for SFI-804 */
                                                FROM Merchant_Document__c
                                                WHERE Active__c =: true AND KYC_Documentable_Type__c IN('ProductAccount','Account',null,'Merchant','BusinessOwner') AND (Opportunity__c =: oppObj.Id OR Account__c =: oppObj.AccountId) ORDER BY reKYC_Doc__c desc,CreatedDate DESC]){/** Added reKYC_Doc__c desc for SFI-804 */
                                                    /*if(oppObj !=null && String.isNotBlank(oppObj.Merchant_Business_Type__c) && oppObj.Merchant_Business_Type__c=='Enterprise' && merchantDoc.Opportunity__c == oppObj.Id){
                                                        existingMerchantDocMap.put(merchantDoc.Document_Category__c ,merchantDoc);
                                                        merDocsExisting.add(merchantDoc);
                                                    }else if(oppObj !=null && (String.isBlank(oppObj.Merchant_Business_Type__c) || (String.isNotBlank(oppObj.Merchant_Business_Type__c) && (oppObj.Merchant_Business_Type__c=='LongTail' || oppObj.Merchant_Business_Type__c=='Compulsive'))) && merchantDoc.Opportunity__c == oppObj.Id){
                                                        existingMerchantDocMap.put(merchantDoc.Document_Category__c,merchantDoc);
                                                        merDocsExisting.add(merchantDoc);
                                                    }else if(oppObj !=null && (String.isBlank(oppObj.Merchant_Business_Type__c) || (String.isNotBlank(oppObj.Merchant_Business_Type__c) && (oppObj.Merchant_Business_Type__c=='LongTail' || oppObj.Merchant_Business_Type__c=='Compulsive'))) && String.isBlank(merchantDoc.Opportunity__c) && merchantDoc.Account__c == oppObj.AccountId && oppObj.Lead_Type__c != 'Partner' && !oppObj.Onboarding_Revamp_Merchant__c){
                                                        if(!existingMerchantDocMap.containsKey(merchantDoc.Document_Category__c)){ 
                                                            existingMerchantDocMap.put(merchantDoc.Document_Category__c,merchantDoc);
                                                            merDocsExisting.add(merchantDoc);}
                                                    }*/
                                                    //Added by Pooja//
                                                    
                                                    if(oppObj !=null && merchantDoc.Opportunity__c == oppObj.Id){
                                                        existingMerchantDocMap.put(merchantDoc.Document_Category__c,merchantDoc);
                                                        merDocsExisting.add(merchantDoc);
                                                    }else if(oppObj !=null && String.isBlank(merchantDoc.Opportunity__c) && merchantDoc.Account__c == oppObj.AccountId && oppObj.Lead_Type__c != 'Partner'){
                                                        if(!existingMerchantDocMap.containsKey(merchantDoc.Document_Category__c)){ 
                                                            existingMerchantDocMap.put(merchantDoc.Document_Category__c,merchantDoc);
                                                            merDocsExisting.add(merchantDoc);}
                                                    }else if(oppObj !=null && String.isBlank(merchantDoc.Opportunity__c) && merchantDoc.Account__c == oppObj.AccountId && oppObj.Lead_Type__c == 'Partner'){
                                                        if(!existingMerchantDocMap.containsKey(merchantDoc.Document_Category__c)) { 
                                                            existingMerchantDocMap.put(merchantDoc.Document_Category__c,merchantDoc);
                                                            merDocsExisting.add(merchantDoc);}
                                                    }
                                                }
        
        system.debug('###### existingMerchantDocList '+existingMerchantDocMap);
        system.debug('###### merDocsExisting '+merDocsExisting);
        if(merDocsExisting.size()>0 && merDocsExisting !=NULL){ // adding only if condition by rohit
            
            for(Merchant_Document__c merchantDocObj : merDocsExisting){
                system.debug('merchantDocObjId::::::::>>>>>'+merchantDocObj.Id);
                merchantDocObj.Onboarding_Status__c = String.isNotBlank(merchantDocObj.Onboarding_Status__c) ? merchantDocObj.Onboarding_Status__c : 'Pending';
                merchantDocObj.Expiry_Date__c = merchantDocObj.Expiry_Date__c != null ? merchantDocObj.Expiry_Date__c : Date.today().addYears(1);
                WrapperMerchantDocument WrapperMerchantDocumentObj = new WrapperMerchantDocument();
                WrapperMerchantDocumentObj.merchantDocumentObj = merchantDocObj;
                WrapperMerchantDocumentObj.lstOnboardingStatus = lstOnboardingStatus;
                //Added by Animesh
                WrapperMerchantDocumentObj.lstExpApprovalStatus = lstExpApprovalStatus;
                WrapperMerchantDocumentObj.lstDocumentType = lstDocumentType;
                WrapperMerchantDocumentObj.listDocumentCategoryMaster = (listDocumentCategoryMaster != null && !listDocumentCategoryMaster.isEmpty()) ? listDocumentCategoryMaster : null;
                     WrapperMerchantDocumentObj.listCategoryTypeMapping = (merchantDocObj.Document_Category__c != null && mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty() && mapDocCateIdVsLstTypeMapping.containsKey(merchantDocObj.Document_Category__c))
                    ? mapDocCateIdVsLstTypeMapping.get(merchantDocObj.Document_Category__c) : null;
                WrapperMerchantDocumentObj.mapDocCateIdVsLstTypeMapping = (mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty()) ? mapDocCateIdVsLstTypeMapping : null;
                WrapperMerchantDocumentObj.isNew = false;
                WrapperMerchantDocumentObj.isDocCateAvail = (merchantDocObj.Document_Category__c != null) ? true : false; 
                WrapperMerchantDocumentObj.isApproved = merchantDocObj.Onboarding_Status__c == 'Approved' ? true : false;
                WrapperMerchantDocumentObj.strError = String.isNotBlank(merchantDocObj.Error__c) ? merchantDocObj.Error__c : '';
                WrapperMerchantDocumentObj.isDocuCategory = Schema.sObjectType.Merchant_Document__c.fields.Document_Category__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isDocuType = Schema.sObjectType.Merchant_Document__c.fields.Document_Type__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isDocFormat = Schema.sObjectType.Merchant_Document__c.fields.Document_Received__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isSalesRemark = Schema.sObjectType.Merchant_Document__c.fields.Sales_Remarks__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isOnboardingRemark = Schema.sObjectType.Merchant_Document__c.fields.Onboarding_Remarks__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isOnboardingStatus = Schema.sObjectType.Merchant_Document__c.fields.Onboarding_Status__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isExpiryDate = Schema.sObjectType.Merchant_Document__c.fields.Expiry_Date__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isActive = Schema.sObjectType.Merchant_Document__c.fields.Active__c.isUpdateable() ? true : false;
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Profile.Name =='Onboarding Operations User' ||  userObj.Super_User__c){
                    WrapperMerchantDocumentObj.isDocEditable = true;
                }else{
                    if(merchantDocObj.Onboarding_Status__c == 'Approved' || merchantDocObj.Exceptionally_Approval_Status__c == 'Approved' || !userObj.Is_Doc_Status_Update_Allow__c){
                        WrapperMerchantDocumentObj.isDocEditable = false;
                    }else{
                        WrapperMerchantDocumentObj.isDocEditable = true;
                    }
                }
                
                
                List<String> lstAllError = new List<String>();
                if(String.isNotBlank(merchantDocObj.Error__c)){
                    for(String str : merchantDocObj.Error__c.split(';')){
                        lstAllError.add(str);
                    }
                    WrapperMerchantDocumentObj.lstAllError = lstAllError;
                } 
                if(String.isNotBlank(merchantDocObj.URL__c) && merchantDocObj.Opportunity__r.Offline_Lead__c !=True){// && merchantDocObj.Account__r.Offline_Lead__c==True added by rohit
                    system.debug('inside if::::664');
                    lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj);
                }
                else if(merchantDocObj.Opportunity__r.Offline_Lead__c==True && merchantDocObj.Document_Category__c !=NULL 
                        && merchantDocObj.Active__c== True){// This else if condition added by rohit for offline lead
                            lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj);
                            System.debug('lstWrapperMerchantDocument:::::'+lstWrapperMerchantDocument);
                        }
                 
            } 
        }
    }
    
    /*-----------------------------------------------------------------------------------------------------
Description:    method to get the contracts records
------------------------------------------------------------------------------------------------------*/
    public static void getContractRecords(Account accObj, Opportunity oppObj, List<WrapperContract> lstWrapperContract, User userObj,List<WrapperContract> lstWrapperPayoutContract){
        List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
        List<String> lstContractStatus = SystemUtility.getPicklistValue('Contract', 'Status');
        List<String> lstDocReceived = SystemUtility.getPicklistValue('Contract', 'Document_Received__c');                                    
        Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
        mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
        
        List<String> lstConStatus = new List<String>();
        for(String strStatus : lstContractStatus){
            if(strStatus == 'Pending' || strStatus == 'Counter Signed Received' || strStatus == 'Approved' || strStatus == 'Declined' || strStatus == 'Approved Activate'){
                lstConStatus.add(strStatus);
            }            
        }
        
        for(Contract contractObj : [SELECT Id, Document_Received__c, Sales_Remarks__c, Onboarding_Remarks__c, Identifier__c, E_Stamp_Number__c,
                                    Document_Category__c, Document_Category__r.Name, Document_Type__c, Error__c, Upload_Date__c, Contract_Type__c ,
                                    Document_Type__r.Name, URL__c, Active__c, Type__c, Status, Document_Content_Type__c,AccountId,Opportunity__c
                                    FROM Contract 
                                    WHERE (AccountId =: accObj.Id OR Opportunity__c =: oppObj.Id)
                                    AND  Type__c =: 'Final'          
                                    AND ((Active__c=:True AND (Contract_Type__c = 'Agreement' OR Contract_Type__c = 'Addendum' OR Contract_Type__c = 'PayoutAgreement')))
                                    ORDER BY Name Desc])
        {
            WrapperContract WrapperContractObj = new WrapperContract();
            WrapperContractObj.contractObj = contractObj;
            WrapperContractObj.isContApproved = (contractObj.Status == 'Approved' || contractObj.Status == 'Approved Activate') ? true : false;
            WrapperContractObj.isContDeclined = (contractObj.Status == 'Declined') ? true : false;
            WrapperContractObj.lstContractStatus = lstConStatus;
            WrapperContractObj.lstDocumentReceived = lstDocReceived;
            WrapperContractObj.strError = String.isNotBlank(contractObj.Error__c) ? contractObj.Error__c : '';
            WrapperContractObj.isDocCateAvail = (contractObj.Document_Category__c != null) ? true : false;
            WrapperContractObj.listDocumentCategoryMaster = (listDocumentCategoryMaster != null && !listDocumentCategoryMaster.isEmpty()) ? listDocumentCategoryMaster : null;
            WrapperContractObj.listCategoryTypeMapping = (contractObj.Document_Category__c != null && mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty() && mapDocCateIdVsLstTypeMapping.containsKey(contractObj.Document_Category__c))
                ? mapDocCateIdVsLstTypeMapping.get(contractObj.Document_Category__c) : null;
            WrapperContractObj.mapDocCateIdVsLstTypeMapping = (mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty()) ? mapDocCateIdVsLstTypeMapping : null;
            WrapperContractObj.isContDocuCategory = Schema.sObjectType.Contract.fields.Document_Category__c.isUpdateable() ? true : false;
            WrapperContractObj.isContDocuType = Schema.sObjectType.Contract.fields.Document_Type__c.isUpdateable() ? true : false; 
            WrapperContractObj.isContDocFormat = Schema.sObjectType.Contract.fields.Document_Received__c.isUpdateable() ? true : false; 
            WrapperContractObj.isContSalesRemark = Schema.sObjectType.Contract.fields.Sales_Remarks__c.isUpdateable() ? true : false; 
            WrapperContractObj.isContOnboardingRemark = Schema.sObjectType.Contract.fields.Status.isUpdateable() ? true : false; 
            WrapperContractObj.isContStatus = Schema.sObjectType.Contract.fields.Onboarding_Remarks__c.isUpdateable() ? true : false; 
            WrapperContractObj.isActive = Schema.sObjectType.Contract.fields.Active__c.isUpdateable() ? true : false; 
            
            if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                WrapperContractObj.isDocEditable = true;
            }else{
                if(contractObj.Status == 'Approved' || contractObj.Status == 'Approved Activate'){
                    WrapperContractObj.isDocEditable = false;
                }else{
                    WrapperContractObj.isDocEditable = true;
                }
            }
            
            List<String> lstAllError = new List<String>();
            if(String.isNotBlank(contractObj.Error__c)){
                for(String str : contractObj.Error__c.split(';')){
                    lstAllError.add(str);
                }
                WrapperContractObj.lstAllError = lstAllError;
            }
            system.debug('WrapperContractObj $$$$$$$$$$$$$$$$$$ '+WrapperContractObj);
            if(WrapperContractObj.contractObj.Contract_Type__c == 'Agreement' && String.isNotBlank(WrapperContractObj.contractObj.Opportunity__c) && WrapperContractObj.contractObj.Opportunity__c == oppObj.Id){
                lstWrapperContract.add(WrapperContractObj);
            }else if(WrapperContractObj.contractObj.Contract_Type__c == 'Addendum' && String.isNotBlank(WrapperContractObj.contractObj.Opportunity__c) && WrapperContractObj.contractObj.Opportunity__c == oppObj.Id){
                lstWrapperContract.add(WrapperContractObj);
            }else if(WrapperContractObj.contractObj.Contract_Type__c == 'Agreement' && String.isBlank(WrapperContractObj.contractObj.Opportunity__c) && !oppObj.Onboarding_Revamp_Merchant__c){
                lstWrapperContract.add(WrapperContractObj);
            }
            //if(WrapperContractObj.contractObj.Contract_Type__c !='PayoutAgreement' && String.isBlank(WrapperContractObj.contractObj)) lstWrapperContract.add(WrapperContractObj);
            if(WrapperContractObj.contractObj.Contract_Type__c =='PayoutAgreement') lstWrapperPayoutContract.add(WrapperContractObj);
        }        
    }
    
    //=========================== Method is used to add New Row for Merchan Document =======================
    @AuraEnabled
    public static WrapperDocument addNewRecordDoc(String strWrapperDocumentObj){  
        
        if(String.isNotBlank(strWrapperDocumentObj)){
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            WrapperDocumentObj = (WrapperDocument) System.JSON.deserialize(strWrapperDocumentObj, WrapperDocument.class); 
            User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            List<String> lstOnboardingStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Onboarding_Status__c');
            List<string> lstDocumentType = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');            
            List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
            List<string> lstExpApprovalStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Exceptionally_Approval_Status__c');                                    
            
            Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
            mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
            if(WrapperDocumentObj.lstWrapperMerchantDocument !=NULL && !WrapperDocumentObj.lstWrapperMerchantDocument.isEmpty()){
                //Opportunity__c=WrapperDocumentObj.optyObj.Id by rohit for merchant document tagging to Opportunity : 4th Aug 2023
                Merchant_Document__c merchantDocumentObj = new Merchant_Document__c(Account__c=WrapperDocumentObj.accountObj.Id,Opportunity__c=WrapperDocumentObj.optyObj.Id,Active__c=true, Onboarding_Status__c='Pending');
                insert merchantDocumentObj;
 				WrapperMerchantDocument WrapperMerchantDocumentObj = new WrapperMerchantDocument();
                WrapperMerchantDocumentObj.merchantDocumentObj = merchantDocumentObj;
                WrapperMerchantDocumentObj.lstOnboardingStatus = lstOnboardingStatus;
                //Added by Animesh
                WrapperMerchantDocumentObj.lstExpApprovalStatus = lstExpApprovalStatus;
                WrapperMerchantDocumentObj.lstDocumentType = lstDocumentType;
                WrapperMerchantDocumentObj.isNew = true;
                WrapperMerchantDocumentObj.listDocumentCategoryMaster = (listDocumentCategoryMaster != null && !listDocumentCategoryMaster.isEmpty()) ? listDocumentCategoryMaster : null;
                WrapperMerchantDocumentObj.listCategoryTypeMapping = (merchantDocumentObj.Document_Category__c != null && mapDocCateIdVsLstTypeMapping != null &&  !mapDocCateIdVsLstTypeMapping.isEmpty() && mapDocCateIdVsLstTypeMapping.containsKey(merchantDocumentObj.Document_Category__c))
                    ? mapDocCateIdVsLstTypeMapping.get(merchantDocumentObj.Document_Category__c) : null;
                WrapperMerchantDocumentObj.mapDocCateIdVsLstTypeMapping = (mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty()) ? mapDocCateIdVsLstTypeMapping : null;
                WrapperMerchantDocumentObj.isDocCateAvail = false; 
                WrapperMerchantDocumentObj.isApproved = false;
                WrapperMerchantDocumentObj.strError = ''; 
                WrapperMerchantDocumentObj.isDocuCategory = Schema.sObjectType.Merchant_Document__c.fields.Document_Category__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isDocuType = Schema.sObjectType.Merchant_Document__c.fields.Document_Type__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isDocFormat = Schema.sObjectType.Merchant_Document__c.fields.Document_Received__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isSalesRemark = Schema.sObjectType.Merchant_Document__c.fields.Sales_Remarks__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isOnboardingRemark = Schema.sObjectType.Merchant_Document__c.fields.Onboarding_Remarks__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isOnboardingStatus = Schema.sObjectType.Merchant_Document__c.fields.Onboarding_Status__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isExpiryDate = Schema.sObjectType.Merchant_Document__c.fields.Expiry_Date__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isActive = Schema.sObjectType.Merchant_Document__c.fields.Active__c.isUpdateable() ? true : false;
                WrapperMerchantDocumentObj.isDocEditable = true;
                WrapperDocumentObj.lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj); 
                system.debug('WrapperDocumentObj @@@@@@@ '+WrapperDocumentObj);
                return WrapperDocumentObj;            
            }
            else{// this else condition written by rohit
                system.debug('oppid::::::'+WrapperDocumentObj.optyObj.Id);
                Opportunity acc = [SELECT Id,Offline_Lead__c FROM Opportunity WHERE ID=:WrapperDocumentObj.optyObj.Id];
                
                WrapperDocumentObj.lstWrapperMerchantDocument = new List<WrapperMerchantDocument>();
                   Merchant_Document__c merchantDocumentObj = new Merchant_Document__c();
                		merchantDocumentObj.Account__c=WrapperDocumentObj.accountObj.Id;
                		merchantDocumentObj.Opportunity__c=WrapperDocumentObj.optyObj.Id;//added by rohit to tagged with opportunity: 4th Aug 2023
                		merchantDocumentObj.Active__c=true;
                		merchantDocumentObj.Onboarding_Status__c='Pending';
                	insert merchantDocumentObj;
                    List<string> lstDocumentTypeNew = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');   
                    WrapperMerchantDocument WrapperMerchantDocumentObj = new WrapperMerchantDocument();
                    WrapperMerchantDocumentObj.merchantDocumentObj = merchantDocumentObj;
                    WrapperMerchantDocumentObj.lstOnboardingStatus = lstOnboardingStatus;
                    WrapperMerchantDocumentObj.lstDocumentType = lstDocumentTypeNew;
                    WrapperMerchantDocumentObj.listDocumentCategoryMaster = (listDocumentCategoryMaster != null && !listDocumentCategoryMaster.isEmpty()) ? listDocumentCategoryMaster : null;
                    WrapperMerchantDocumentObj.listCategoryTypeMapping =(merchantDocumentObj.Document_Category__c != null && mapDocCateIdVsLstTypeMapping != null &&  !mapDocCateIdVsLstTypeMapping.isEmpty() && mapDocCateIdVsLstTypeMapping.containsKey(merchantDocumentObj.Document_Category__c))
                        ? mapDocCateIdVsLstTypeMapping.get(merchantDocumentObj.Document_Category__c) : null;
                    WrapperMerchantDocumentObj.mapDocCateIdVsLstTypeMapping = (mapDocCateIdVsLstTypeMapping != null && !mapDocCateIdVsLstTypeMapping.isEmpty()) ? mapDocCateIdVsLstTypeMapping : null;
                    WrapperMerchantDocumentObj.isDocuCategory = true; 
                    WrapperMerchantDocumentObj.isDocCateAvail = false; 
                    WrapperMerchantDocumentObj.isApproved = true;
                    WrapperMerchantDocumentObj.strError = ''; 
                    WrapperMerchantDocumentObj.isDocuType = true;
                    WrapperMerchantDocumentObj.isDocFormat =  true;
                    WrapperMerchantDocumentObj.isSalesRemark = true;
                    WrapperMerchantDocumentObj.isOnboardingRemark = true;
                    WrapperMerchantDocumentObj.isOnboardingStatus = true;
                    WrapperMerchantDocumentObj.isExpiryDate =true;
                    WrapperMerchantDocumentObj.isActive =  true;
                    WrapperMerchantDocumentObj.isDocEditable = true;
                    WrapperDocumentObj.lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj); 
                	return WrapperDocumentObj;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static Contract getContractLink(Id strContDocuId){
        return getContractRec(strContDocuId);
    }
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the oportunity record based on given opportunity Id
---------------------------------------------------------------------------------------------------*/
    public static opportunity getOpportunityRecord(String opportunityId){ 
        return [SELECT Id, AccountId, Lead_Type__c, Website__c, iOS_URL__c, Android_URL__c, Blacklist__c,Approved_Date__c,
                Payout_Activation_Status__c,Settlement_Status__c,Merchant_Business_Type__c,Document_Status_Document_Issue__c,
                Agreement_Status__c,Exceptionally_Approval_Status__c,E_Stamp_Number__c,E_Stamp__c,BusinessCategory__r.Name,Sub_Category__r.Name,
                Legal_Name_Account__c,Business_Entity__c,Onboarding_Revamp_Merchant__c,Customer_Declaration_PEP__c,Jocata_System_Alerts__c,PEP_Status__c,Is_dormant__c,Next_ReKYC_Date__c
                From Opportunity
                WHERE Id =: opportunityId];
    } 
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the account record based on given account Id
---------------------------------------------------------------------------------------------------*/
    public static Account getAccountRecord(String accId){
        return [SELECT Id, Identifier__c, Business_Entity__c,Offline_Lead__c, Document_Status__c, isConverted__c, Agreement_Status__c, Legal_Name__c, 
                Business_Category__c, Business_Category__r.Name, Sub_Category__c, Sub_Category__r.Name, PAN_Holder_Name__c, PAN_Number__c
                From Account
                WHERE Id =: accId];            
    } 
    
    
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the address details record based on given account Id
---------------------------------------------------------------------------------------------------*/
    public static void getAddressDetails(Account accObj, Opportunity oppObj, List<Address_Details__c> lstAddDetails){
        lstAddDetails.addAll([SELECT Id, Active__c, Type__c, City__c, Country__c, State__c, Pincode__c, Address_Line__c,
                              Account__c,Opportunity__c
                              FROM Address_Details__c 
                              WHERE Active__c =: true 
                              AND (Account__c =: accObj.Id OR Opportunity__c =: oppObj.Id)]);
    }
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the bank account details record based on given Opportunity Id
---------------------------------------------------------------------------------------------------*/
    public static void getBankAccountDetails(Opportunity optyObj, List<Bank_Account_Detail__c> lstbankAcntDetails){
        lstbankAcntDetails.addAll([SELECT Id, Active__c, Account_Holder_Name__c, Account_Number__c, IFSC_Code__c, Verification_Status__c 
                                   FROM Bank_Account_Detail__c 
                                   WHERE Active__c =: true AND Opportunity__c =: optyObj.Id]);
    }
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to get the contracts record based on given account Id
=========Changing due to Onboarding Revamp================
---------------------------------------------------------------------------------------------------*/
    public static void getContracts(Account accObj, Opportunity oppObj, List<Contract> lstContract){
        lstContract.addAll([SELECT Id, E_Stamp_Number__c, AccountId 
                            FROM Contract
                            WHERE Active__c = false 
                            AND Status = 'Pending' 
                            AND (AccountId =: accObj.Id OR Opportunity__c =: oppObj.Id)
                            ORDER BY LastModifiedDate DESC]);
    }
    
    /*-------------------------------------------------------------------------------------------------
Description:    method to update Contract status
---------------------------------------------------------------------------------------------------*/
    public static List<Contract> createnewContractsRecordsClone(List<Contract> lstContract){
        List<Contract> lstContractNew = new List<Contract>();
        Map<String,String> mapofUUIDwithStatus = new Map<String,String>();
        if(lstContract != null && !lstContract.isEmpty()){
            for(Contract objContract :lstContract){
                mapofUUIDwithStatus.put(objContract.Identifier__c,objContract.Status);
                Contract objNewContract = objContract.clone(false,false,false,false);
                objNewContract.Status = 'Draft Sent';
                objNewContract.Does_Not_Publish__c = true;
                lstContractNew.add(objNewContract);
            }
        }
        if(!lstContractNew.isEmpty()){
            insert lstContractNew;
            for(Contract objContract : lstContractNew){
                if(String.isNotBlank(objContract.Identifier__c) && mapofUUIDwithStatus.get(objContract.Identifier__c)!= null)
                    objContract.Status = mapofUUIDwithStatus.get(objContract.Identifier__c);
            }
        }   
        return lstContractNew;
    }
    
    public static Contract getContractRec(Id contractId){
        if(String.isNotBlank(contractId)){
            return [SELECT Id, Document_Received__c, Sales_Remarks__c, Onboarding_Remarks__c, 
                    Document_Category__c, Document_Category__r.Name, Document_Type__c, 
                    Document_Type__r.Name, URL__c, Active__c, Type__c, Status, Document_Type_Name__c,
                    Document_Content_Type__c, File_Size__c, Document_Category_Name__c
                    FROM Contract 
                    WHERE Id =: contractId 
                    LIMIT 1];
        }
        return null;
    }
    
    //===================Changing due to Onboarding Revamp======================
    public static void getProcessInstance(Account accObj, Opportunity oppObj, List<ProcessInstance> approvalList){
        approvalList.addAll([SELECT TargetObjectId, Status, CreatedDate, 
                             (SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                              FROM Steps ORDER BY CreatedDate DESC) FROM ProcessInstance 
                             //WHERE TargetObjectId =: accObj.Id
                             WHERE TargetObjectId =: oppObj.Id
                             ORDER BY CreatedDate DESC]);
    }
    
    //=============get merchant auto approval details=============
    public static void getMerchantAADetails(Opportunity optyObj, List<Merchant_Auto_Approval_Details__c> mAutoApprovalDetailList){
        mAutoApprovalDetailList.addAll([SELECT Id,Status__c,Approvable_Type__c,Approval_Type__c,Score__c,Reason__c,Message__c from Merchant_Auto_Approval_Details__c Where Opportunity__c =: optyObj.Id]);
    }
    
    /**
     * Method to get the history tracking for Merchant_Document__c
     * @param - Id of selected Merchant_Document__c record.
     * Added for SFI-331
     */
    @AuraEnabled(cacheable=true)
    public static List<MerchantDocumentHistoryWrapper> getHistoryData(String merchantDocId){
        List<MerchantDocumentHistoryWrapper> historyWrapperList = new List<MerchantDocumentHistoryWrapper>();
        
        Map<String,Schema.SObjectField> mapOfField = Schema.getGlobalDescribe().get('Merchant_Document__c').getDescribe().fields.getMap();
        Map<String,String> fieldNameToLabelMap = new Map<String,String>();
        
        for(String fieldName : mapOfField.keySet()) {
            Schema.DescribeFieldResult f = mapOfField.get(fieldName).getDescribe();
            fieldNameToLabelMap.put(f.getName(),f.getLabel());
        }
        fieldNameToLabelMap.put('locked','Record Locked');
        fieldNameToLabelMap.put('unlocked','Record Unlocked');
        fieldNameToLabelMap.put('created','Record Created');
        
        for(Merchant_Document__History mdh : [SELECT Id, ParentId, Field, OldValue, NewValue,CreatedDate,CreatedById,CreatedBy.Name FROM Merchant_Document__History 
                                              WHERE ParentId = :merchantDocId
                                              ORDER By CreatedDate DESC]){
                                                  MerchantDocumentHistoryWrapper temp = new MerchantDocumentHistoryWrapper();
                                                  temp.fieldLabel = fieldNameToLabelMap.get(mdh.Field);
                                                  temp.oldValue = String.valueOf(mdh.OldValue);
                                                  temp.newValue = String.valueOf(mdh.NewValue);
                                                  temp.createdByUser = mdh.CreatedBy.Name;
                                                  temp.createdDate = mdh.CreatedDate;
                                                  
                                                  historyWrapperList.add(temp);
                                              } 
        return historyWrapperList;
    }/** END */
    
    /**
     * Wrapper class to bind the Merchant_Document__History fields to show in the component
     * Added for SFI-331
     */
    public class MerchantDocumentHistoryWrapper{
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String oldValue;
        @AuraEnabled
        public String newValue;
        @AuraEnabled
        public String createdByUser;
        @AuraEnabled
        public DateTime createdDate;
       
        /** Constructor */
        public MerchantDocumentHistoryWrapper(){
            this.fieldLabel = '';
            this.oldValue = '';
            this.oldValue = '';
            this.oldValue = '';
            this.oldValue = NULL;
        }/** END */
    }/** END */
}