// =================== Used for "DocumentationCmp" Component=====================
public with sharing class WebsiteDocumentController {    
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
            
            User userObj = [SELECT Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            
            if(String.isNotBlank(SobjectName) && SobjectName == 'Opportunity'){
                optyObj = getOpportunityRecord(SobjectId); 
                getBankAccountDetails(optyObj, lstbankAcntDetails);
                
                if(String.isNotBlank(optyObj.AccountId)){
                	accObj = getAccountRecord(optyObj.AccountId);
                    getProcessInstance(accObj, approvalList);  
                    getAddressDetails(accObj, lstAddDetails);    
                } 
            }else if(String.isNotBlank(SobjectName) && SobjectName == 'Account'){
                accObj = getAccountRecord(SobjectId);
            }             
            
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            if(!approvalList.isEmpty() && approvalList[0].Status == 'Pending') WrapperDocumentObj.isInApprovalProcess = true;            
            if(optyObj != null && String.isNotBlank(optyObj.Id)) WrapperDocumentObj.optyObj = optyObj;
            WrapperDocumentObj.isContractExist = false;
            WrapperDocumentObj.isMerchantDocExist = false;
            WrapperDocumentObj.accountObj = accObj;
            WrapperDocumentObj.userObj = userObj;
            
            if(!lstAddDetails.isEmpty()){
                for(Address_Details__c eachAddress : lstAddDetails){
                    if(eachAddress.Type__c == 'Operating'){
                        WrapperDocumentObj.operatingAddObj = eachAddress;
                    }
                    if(eachAddress.Type__c == 'Registered'){
                        WrapperDocumentObj.regdAddObj = eachAddress;
                    }
                }
            }
            
            if(!lstbankAcntDetails.isEmpty()) WrapperDocumentObj.bankAcntObj = lstbankAcntDetails[0];
            
            List<WrapperMerchantDocument> lstWrapperMerchantDocument = new List<WrapperMerchantDocument>();
            
            if(accObj != null && accObj.Id != null){
                getMerchantDoc(accObj, lstWrapperMerchantDocument, userObj);
                system.debug(lstWrapperMerchantDocument.size()+ ' ^^^^^ lstWrapperMerchantDocument &&&&&&& ' +lstWrapperMerchantDocument);
                
                if(!lstWrapperMerchantDocument.isEmpty()){
                    WrapperDocumentObj.lstWrapperMerchantDocument = lstWrapperMerchantDocument;
                    WrapperDocumentObj.isMerchantDocExist = true;
                }
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                    WrapperDocumentObj.isEditAllow = true;
                }else{
                    if(Schema.sObjectType.Merchant_Document__c.isUpdateable()){
                        if(!accObj.isConverted__c || optyObj.Lead_Type__c.equalsIgnoreCase('Partner')){
                            WrapperDocumentObj.isEditAllow = true;
                        }else if(accObj.Document_Status__c == 'Docs Approved' && accObj.Agreement_Status__c == 'Approved'){
                            WrapperDocumentObj.isEditAllow = false;
                        }else{
                            WrapperDocumentObj.isEditAllow = true;
                        }
                    }else{
                        WrapperDocumentObj.isEditAllow = false;
                    }                        
                }
                return WrapperDocumentObj;
            }
        }
        return null; 
    }    
    
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
            
            List<Merchant_Document__c> lstMerchantDoc = new List<Merchant_Document__c>();
            List<Contract> lstContract = new List<Contract>();
            List<Contract> lstContractCloned = new List<Contract>();
            List<Contract> lstContractDelete = new List<Contract>();
            
            Integer MDTotalApproved = 0;
            Integer MDTotalReject = 0;
            Integer MDTotalReceived = 0;
            Integer ContractTotalApproved = 0;
            Integer ContractTotalReject = 0;
            
            
            if(clsWrapperDocument.lstWrapperMerchantDocument != null && !clsWrapperDocument.lstWrapperMerchantDocument.isEmpty()){                
                for(WrapperMerchantDocument clsWrpMerchantDocObj : clsWrapperDocument.lstWrapperMerchantDocument){
                    lstMerchantDoc.add(clsWrpMerchantDocObj.merchantDocumentObj);
                    
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Approved'){
                        MDTotalApproved++;
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Declined'){
                        MDTotalReject++;
                    }
                    if(clsWrpMerchantDocObj.merchantDocumentObj.Onboarding_Status__c == 'Received'){
                        MDTotalReceived++;
                    }
                }
                
                if(MDTotalReject > 0) clsWrapperDocument.accountObj.Document_Status__c = 'Docs Error';
                else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size()) clsWrapperDocument.accountObj.Document_Status__c = 'Docs Received';
                else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size()) clsWrapperDocument.accountObj.Document_Status__c = 'Docs Approved';
            }
            system.debug('----> saveMerchantDocument -- '+lstMerchantDoc);
            try{
                if(!lstMerchantDoc.isEmpty())  upsert lstMerchantDoc;
                //update clsWrapperDocument.accountObj;
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
    public static WrapperErrorSolution getErrorSolutionMapping(Account accountObj, Id docCateId){
        if(accountObj != null && String.isNotBlank(docCateId)){
            WrapperErrorSolution wrpErrorSolutionObj = new WrapperErrorSolution();
            List<Error_Solution_Mapping__c> lstErrorSolution = new List<Error_Solution_Mapping__c>();
            getErrorSolutionMappingRecords(accountObj.Business_Entity__c, docCateId, lstErrorSolution);
            if(!lstErrorSolution.isEmpty()){
                wrpErrorSolutionObj.lstErrorSolutionsExist = lstErrorSolution;
            }
            wrpErrorSolutionObj.lstErrorSolutionsCustom = new List<Error_Solution_Mapping__c>{ new Error_Solution_Mapping__c(Error__c='', Solution__c='') };
            return wrpErrorSolutionObj;
        }
        return null;
    }
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the list of Error Solution records based on Entity Type Id
    ---------------------------------------------------------------------------------------------------*/
    public static void getErrorSolutionMappingRecords(Id businesEntityId, Id docuCateId, List<Error_Solution_Mapping__c> lstErrorSolution){
        if(string.isNotBlank(businesEntityId) && string.isNotBlank(docuCateId)){
            lstErrorSolution.addAll([SELECT  Id, Name, Error__c, Solution__c, Entity__c, Document_Category__c
                                FROM Error_Solution_Mapping__c
                                WHERE Entity__c =: businesEntityId
                                AND Document_Category__c =: docuCateId]);
        }else if(string.isBlank(businesEntityId) && string.isNotBlank(docuCateId)){
            lstErrorSolution.addAll([SELECT  Id, Name, Error__c, Solution__c, Entity__c, Document_Category__c
                                FROM Error_Solution_Mapping__c
                                WHERE Document_Category__c =: docuCateId]);
        }        
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
            return [SELECT Id, Name, Document_Content_Type__c, File_Size__c, URL__c, Error__c, Solution__c, Expiry_Date__c,
                    Account__c, Document_Category__c, Document_Type__c, Document_Category__r.Name, Document_Type__r.Name, Active__c,
                    LastModifiedById, LastModifiedBy.Name, LastModifiedDate, Document_Category_Name__c, Document_Type_Name__c,
                    KYC_Documentable_Type__c
                    FROM Merchant_Document__c 
                    WHERE Id =: merchantDocId 
                    LIMIT 1];
        }
        return null;
    }
    
    /*-----------------------------------------------------------------------------------------------------
    Description:    method to get the merchanr document records
    ------------------------------------------------------------------------------------------------------*/
    public static void getMerchantDoc(Account accObj, List<WrapperMerchantDocument> lstWrapperMerchantDocument, User userObj){
        List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
        List<Document_Category_Master__c> lstDocCtaegoryMaster = new List<Document_Category_Master__c>();
        for(Document_Category_Master__c dcm : [SELECT Id, Name, Active__c, Identifier__c, Document_Category_Type__c FROM Document_Category_Master__c WHERE 
        Id IN :listDocumentCategoryMaster AND Document_Category_Type__c = 'Website']){
            lstDocCtaegoryMaster.add(dcm);
        }
        List<String> lstOnboardingStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Onboarding_Status__c');
        List<string> lstDocumentType = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');                                    
        Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
        mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
                                            
        for(Merchant_Document__c merchantDocObj : [SELECT URL__c, 
                                                   Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Name, 
                                                   Onboarding_Remarks__c, Onboarding_Status__c, Account__c, Active__c,
                                                   Sales_Remarks__c, Third_Party_Verification_Remarks__c, Error__c, Solution__c,
                                                   Third_Party_Verification_Status__c, Document_Received__c, Document_Content_Type__c, 
                                                   File_Size__c, Document_Master_Id__c, Document_Master_Id__r.Required__c, Upload_Date__c,
                                                   Document_Category__c, Document_Type__c, LastModifiedBy.Name, Expiry_Date__c,
                                                   Document_Category__r.Name, Document_Type__r.Name, Document_Category_Name__c,
                                                   KYC_Documentable_Type__c, Sample_Document__c, Opportunity__c, Opportunity__r.Document_Category__c
                                                   FROM Merchant_Document__c
                                                   WHERE Account__c =: accObj.Id
                                                   AND Active__c = true
                                                   AND KYC_Documentable_Type__c = 'WebsiteDetail'
                                                   ORDER BY Name ASC])
        {
            merchantDocObj.Onboarding_Status__c = String.isNotBlank(merchantDocObj.Onboarding_Status__c) ? merchantDocObj.Onboarding_Status__c : 'Pending';
            merchantDocObj.Expiry_Date__c = merchantDocObj.Expiry_Date__c != null ? merchantDocObj.Expiry_Date__c : Date.today().addYears(1);
            WrapperMerchantDocument WrapperMerchantDocumentObj = new WrapperMerchantDocument();
            WrapperMerchantDocumentObj.merchantDocumentObj = merchantDocObj;
            WrapperMerchantDocumentObj.lstOnboardingStatus = lstOnboardingStatus;
            WrapperMerchantDocumentObj.lstDocumentType = lstDocumentType;
            WrapperMerchantDocumentObj.listDocumentCategoryMaster = (lstDocCtaegoryMaster != null && !lstDocCtaegoryMaster.isEmpty()) ? lstDocCtaegoryMaster : null;
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
			
            if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                WrapperMerchantDocumentObj.isDocEditable = true;
            }else{
                if(merchantDocObj.Onboarding_Status__c == 'Approved'){
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
            lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj);
        } 
    }
    
    //=========================== Method is used to add New Row for Merchan Document =======================
    @AuraEnabled
    public static WrapperDocument addNewRecordDoc(String strWrapperDocumentObj){
        if(String.isNotBlank(strWrapperDocumentObj)){
            User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            WrapperDocumentObj = (WrapperDocument) System.JSON.deserialize(strWrapperDocumentObj, WrapperDocument.class);
            system.debug('WrapperDocumentObj ##################### '+WrapperDocumentObj);
            Merchant_Document__c merchantDocumentObj = new Merchant_Document__c(Account__c=WrapperDocumentObj.accountObj.Id, Active__c=true, Onboarding_Status__c='Pending', KYC_Documentable_Type__c='WebsiteDetail', Opportunity__c=WrapperDocumentObj.optyObj.Id);
            //insert merchantDocumentObj;
            system.debug('merchantDocumentObj ##################### '+merchantDocumentObj);
            List<String> lstOnboardingStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Onboarding_Status__c');
            List<string> lstDocumentType = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');            
            List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
            List<Document_Category_Master__c> lstDocumentCategoryMaster = [SELECT Id, Name, Active__c, Identifier__c, Document_Category_Type__c FROM Document_Category_Master__c WHERE Id IN :listDocumentCategoryMaster AND Document_Category_Type__c = 'Website'];
            
            Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
            mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
            
            WrapperMerchantDocument WrapperMerchantDocumentObj = new WrapperMerchantDocument();
            WrapperMerchantDocumentObj.merchantDocumentObj = merchantDocumentObj;
            WrapperMerchantDocumentObj.lstOnboardingStatus = lstOnboardingStatus;
            WrapperMerchantDocumentObj.lstDocumentType = lstDocumentType;
            WrapperMerchantDocumentObj.isNew = true;
            WrapperMerchantDocumentObj.listDocumentCategoryMaster = (lstDocumentCategoryMaster != null && !lstDocumentCategoryMaster.isEmpty()) ? lstDocumentCategoryMaster : null;
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
            
            if(WrapperDocumentObj.lstWrapperMerchantDocument == null || WrapperDocumentObj.lstWrapperMerchantDocument.isEmpty()){
                WrapperDocumentObj.lstWrapperMerchantDocument = new List<WrapperMerchantDocument>();				
            }
            WrapperDocumentObj.lstWrapperMerchantDocument.add(WrapperMerchantDocumentObj);  
            WrapperDocumentObj.isMerchantDocExist = true;
            system.debug('WrapperDocumentObj @@@@@@@ '+WrapperDocumentObj);
            return WrapperDocumentObj;
        }
        return null;
    }
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the oportunity record based on given opportunity Id
    ---------------------------------------------------------------------------------------------------*/
    public static opportunity getOpportunityRecord(String opportunityId){
        return [SELECT Id, AccountId, Lead_Type__c, Website__c, iOS_URL__c, Android_URL__c
                From Opportunity
                WHERE Id =: opportunityId];
    } 

    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the account record based on given account Id
    ---------------------------------------------------------------------------------------------------*/
    public static Account getAccountRecord(String accId){
        return [SELECT Id, Identifier__c, Business_Entity__c, Document_Status__c, isConverted__c, Agreement_Status__c, Legal_Name__c, 
                Business_Category__c, Business_Category__r.Name, Sub_Category__c, Sub_Category__r.Name, PAN_Holder_Name__c, PAN_Number__c
                From Account
                WHERE Id =: accId];            
    } 
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the address details record based on given account Id
    ---------------------------------------------------------------------------------------------------*/
    public static void getAddressDetails(Account accObj, List<Address_Details__c> lstAddDetails){
        lstAddDetails.addAll([SELECT Id, Active__c, Type__c, City__c, Country__c, State__c, Pincode__c, Address_Line__c 
                 				FROM Address_Details__c 
                              	WHERE Active__c =: true 
                              	AND Account__c =: accObj.Id]);
    }
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the bank account details record based on given Opportunity Id
    ---------------------------------------------------------------------------------------------------*/
    public static void getBankAccountDetails(Opportunity optyObj, List<Bank_Account_Detail__c> lstbankAcntDetails){
        lstbankAcntDetails.addAll([SELECT Id, Active__c, Account_Holder_Name__c, Account_Number__c, IFSC_Code__c, Verification_Status__c 
                 					FROM Bank_Account_Detail__c 
                                   	WHERE Active__c =: true 
                              		AND Opportunity__c =: optyObj.Id]);
    }
    
    public static void getProcessInstance(Account accObj, List<ProcessInstance> approvalList){
        approvalList.addAll([SELECT TargetObjectId, Status, CreatedDate, 
                             (SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                              FROM Steps ORDER BY CreatedDate DESC) FROM ProcessInstance WHERE TargetObjectId =: accObj.Id
                             ORDER BY CreatedDate DESC]);
    }
}