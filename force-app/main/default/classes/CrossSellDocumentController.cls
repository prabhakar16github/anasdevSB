// =================== Used for "DocumentationCmp" Component=====================
public class CrossSellDocumentController {    
    /*----------------------------------------------------------------------------------------
Description:    method to get the list of merchant document and contracts records 
----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static WrapperDocument getMerchantDocumentRecords(Id SobjectId, String SobjectName,String crossSellId){
        Map<String,String> 	CrossSell_AdditionalAccessAsKamMap = (Map<String,String>)JSON.deserialize(System.Label.CrossSell_Additional_Access_As_Kam_And_Send_CrossSell_Data_Excel ,Map<String, String>.class);
        List<String> CrossSell_AdditionalAccessAsKamList = CrossSell_AdditionalAccessAsKamMap.get('Additional access same as kam').split(',');
        if(String.isNotBlank(SobjectId)){ 
            opportunity optyObj;
            Account accObj;
            Boolean isAllMerDocNotApproved = false;
            Boolean isAllContDocNotApproved = false; 
            
            User userObj = [SELECT Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            Map<string,string> userAccessLevelMap = (Map<String,string>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap,Map<string,string>.class);
            
            if(String.isNotBlank(SobjectName) && SobjectName == 'Opportunity'){
                optyObj = getOpportunityRecord(SobjectId); 
                if(String.isNotBlank(optyObj.AccountId)){
                    accObj = getAccountRecord(optyObj.AccountId);
                } 
            }else if(String.isNotBlank(SobjectName) && SobjectName == 'Account'){
                accObj = getAccountRecord(SobjectId);
            }             
            
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            
            if(optyObj != null && String.isNotBlank(optyObj.Id)) WrapperDocumentObj.optyObj = optyObj;
            WrapperDocumentObj.isContractExist = false;
            WrapperDocumentObj.isMerchantDocExist = false;
            WrapperDocumentObj.accountObj = accObj;
            WrapperDocumentObj.userObj = userObj;
            
            List<WrapperMerchantDocument> lstWrapperMerchantDocument = new List<WrapperMerchantDocument>();
            List<WrapperContract> lstWrapperPayoutContracts = new List<WrapperContract>();
            
            if(accObj != null && accObj.Id != null && optyObj != null && optyObj.Id != null){
                getMerchantDoc(accObj, lstWrapperMerchantDocument, userObj,optyObj,crossSellId);
                system.debug(lstWrapperMerchantDocument.size()+ ' ^^^^^ lstWrapperMerchantDocument &&&&&&& ' +lstWrapperMerchantDocument);
                
                if(!lstWrapperMerchantDocument.isEmpty()){
                    WrapperDocumentObj.lstWrapperMerchantDocument = lstWrapperMerchantDocument;
                    WrapperDocumentObj.isMerchantDocExist = true;
                }
                
                getPayoutContracts(accObj,lstWrapperPayoutContracts,userObj,optyObj,crossSellId);
                
                if(!lstWrapperPayoutContracts.isEmpty()){
                    WrapperDocumentObj.lstWrapperPayoutContract = lstWrapperPayoutContracts;
                    WrapperDocumentObj.isContractExist = true;
                }
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c || userAccessLevelMap.get('MCP')==userObj.Id || CrossSell_AdditionalAccessAsKamList.contains(userObj.Id)){
                    WrapperDocumentObj.isEditAllow = true;
                }
                System.debug('WrapperDocumentObj>>'+WrapperDocumentObj.isEditAllow);
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
            //system.debug('crossSellId ************* '+clsWrapperDocument.crossSellId);
            //Document_Type_Master__c dtm = getDocumentType();
            List<Document_Type_Master__c> dtm = [SELECT Id, Identifier__c FROM Document_Type_Master__c 
                                                 WHERE Name = 'Website Documents' LIMIT 1];
            
            List<Merchant_Document__c> lstMerchantDoc = new List<Merchant_Document__c>();
            List<task> taskList = New List<task>();
            Integer MDTotalApproved = 0;
            Integer MDTotalReject = 0;
            Integer MDTotalReceived = 0;
            List<Contract> lstContract = new List<Contract>();
            
            if(clsWrapperDocument.lstWrapperMerchantDocument != null && !clsWrapperDocument.lstWrapperMerchantDocument.isEmpty()){                
                for(WrapperMerchantDocument clsWrpMerchantDocObj : clsWrapperDocument.lstWrapperMerchantDocument){
                    clsWrpMerchantDocObj.merchantDocumentObj.Document_Type__c = dtm[0].Id;
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
                
                if(MDTotalReject > 0) {
                    clsWrapperDocument.accountObj.Document_Status__c = 'Docs Error';
                    Map<String,String> crossSellProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
                    taskList.add(CrossSellTriggerHandler.getTaskCreate(clsWrapperDocument.optyObj.Id,New Map<Id,Opportunity>(new List<Opportunity>{clsWrapperDocument.optyObj}),'Cross-Sell Task for Document Rejection','','',crossSellProductAndUserIdMap));
                }
                else if(MDTotalReceived == clsWrapperDocument.lstWrapperMerchantDocument.size()) {
                    clsWrapperDocument.accountObj.Document_Status__c = 'Docs Received';
                    taskList.add(CrossSellTriggerHandler.getTaskCreate(clsWrapperDocument.optyObj.Id,null,'Cross-Sell Task for Document Received','','Cross_Sell_Risk_Team',null));
                }
                else if(MDTotalApproved == clsWrapperDocument.lstWrapperMerchantDocument.size()) clsWrapperDocument.accountObj.Document_Status__c = 'Docs Approved';
            }
            system.debug('----> saveMerchantDocument -- '+lstMerchantDoc);
            
            
            if(clsWrapperDocument.lstWrapperPayoutContract != null && !clsWrapperDocument.lstWrapperPayoutContract.isEmpty()){  
                for(WrapperContract clsWrapperContract : clsWrapperDocument.lstWrapperPayoutContract){
                    
                    lstContract.add(clsWrapperContract.contractObj);
                }
            }
            
            try{
                if(!lstMerchantDoc.isEmpty())  upsert lstMerchantDoc;
                if(!taskList.isEmpty()) Insert taskList;
                if(!lstContract.isEmpty())      update lstContract;
                //commenting the below code for updating related account
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
        if(accountObj != null && String.isNotBlank(accountObj.Business_Entity__c)){
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
    public static void getMerchantDoc(Account accObj, List<WrapperMerchantDocument> lstWrapperMerchantDocument, User userObj, opportunity optyObj, String crossSellId){
        try{
            System.debug('crossSellId>>>>'+crossSellId);
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
                                                       AND KYC_Documentable_Type__c = 'CrossSellDocument'
                                                       AND Opportunity__c =: optyObj.Id
                                                       AND Cross_Sell__c =:crossSellId
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
        }catch(Exception ex){
            System.debug('ERRPR:: '+ex.getMessage());
            System.debug('LINE NO:: '+ex.getLineNumber());
        }
        
    }
    
    //=========================== Method is used to add New Row for Merchan Document =======================
    @AuraEnabled
    public static WrapperDocument addNewRecordDoc(String strWrapperDocumentObj,Id crossSellId){
        if(String.isNotBlank(strWrapperDocumentObj)){
            User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
            WrapperDocument WrapperDocumentObj = new WrapperDocument();
            WrapperDocumentObj = (WrapperDocument) System.JSON.deserialize(strWrapperDocumentObj, WrapperDocument.class);
            system.debug('WrapperDocumentObj ##################### '+WrapperDocumentObj);
            Merchant_Document__c merchantDocumentObj = new Merchant_Document__c(Account__c=WrapperDocumentObj.accountObj.Id,
                                                                                Active__c=true, Onboarding_Status__c='Pending',
                                                                                KYC_Documentable_Type__c='CrossSellDocument',
                                                                                Opportunity__c=WrapperDocumentObj.optyObj.Id,
                                                                                Cross_Sell__c = crossSellId
                                                                               );
            insert merchantDocumentObj;
            system.debug('merchantDocumentObj ##################### '+merchantDocumentObj);
            List<String> lstOnboardingStatus = SystemUtility.getPicklistValue('Merchant_Document__c', 'Onboarding_Status__c');
            List<string> lstDocumentType = SystemUtility.getPicklistValue('Merchant_Document__c', 'Document_Received__c');
            
            List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
            List<Document_Category_Master__c> lstDocumentCategoryMaster = [SELECT Id, Name, Active__c, Identifier__c, 
                                                                           Document_Category_Type__c FROM Document_Category_Master__c 
                                                                           WHERE Id IN :listDocumentCategoryMaster 
                                                                           AND Document_Category_Type__c = 'Website'];
            
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
        return [SELECT Id, AccountId, Lead_Type__c, Website__c, iOS_URL__c, Android_URL__c,Settlement_Status__c
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
    
    public static Document_Type_Master__c getDocumentType(){
        return [SELECT Id, Identifier__c FROM Document_Type_Master__c WHERE Name IN('Website Documents','Service Agreement') LIMIT 1];
    }
    
    public static void getPayoutContracts(Account accObj,List<WrapperContract> lstWrapperContract,User userObj,Opportunity optyObj, String crossSellId){
        try{
            List<Document_Category_Master__c> listDocumentCategoryMaster = SystemUtility.getDocumentCategory();
            List<String> lstContractStatus = SystemUtility.getPicklistValue('Contract', 'Status');
            List<String> lstDocReceived = SystemUtility.getPicklistValue('Contract', 'Document_Received__c');                                    
            Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
            mapDocCateIdVsLstTypeMapping = SystemUtility.getMapDocCateVsLstTypeMapping();
            
            List<String> lstConStatus = new List<String>();
            for(String strStatus : lstContractStatus){
                if(strStatus == 'Pending' || strStatus == 'Approved' || strStatus == 'Declined' ){
                    lstConStatus.add(strStatus);
                }            
            }
            
            for(Contract contractObj : [SELECT Id, Document_Received__c, Sales_Remarks__c, Onboarding_Remarks__c, Identifier__c, E_Stamp_Number__c,
                                        Document_Category__c, Document_Category__r.Name, Document_Type__c, Error__c, Upload_Date__c, Contract_Type__c ,
                                        Document_Type__r.Name, URL__c, Active__c, Type__c, Status, Document_Content_Type__c,AccountId
                                        FROM Contract 
                                        WHERE AccountId =: accObj.Id 
                                        //AND Active__c =: true 
                                        AND Type__c =: 'Final'  
                                        AND Contract_Type__c ='PayoutAgreement'
                                        AND Opportunity__c =: optyObj.Id
                                        ORDER BY Name ASC])
            {
                system.debug('contract Status=='+contractObj.Status+' '+contractObj.Id+' '+contractObj.Contract_Type__c);
                WrapperContract WrapperContractObj = new WrapperContract();
                WrapperContractObj.contractObj = contractObj;
               // WrapperContractObj.isAlreadyAct = (contractObj.Status == 'Approved Activate' || contractObj.Status == 'Approved') ? true : false;
                WrapperContractObj.contractObj.Status = (contractObj.Status == 'Approved Activate') ? 'Approved' : contractObj.Status;
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
                WrapperContractObj.isActive = Schema.sObjectType.Contract.fields.Active__c.isUpdateable() ? true : false; 
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                    WrapperContractObj.isDocEditable = true;
                }else{
                    if(contractObj.Status == 'Approved'){
                        WrapperContractObj.isDocEditable = false;
                    }else{
                        WrapperContractObj.isDocEditable = true;
                    }
                }
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                    WrapperContractObj.isContStatus = true;
                }else if(Schema.sObjectType.Contract.fields.Status.isUpdateable()){
                   /* if(userObj.Is_Doc_Status_Update_Allow__c){
                        WrapperContractObj.isContStatus = true;
                    }
                    else{*/
                        WrapperContractObj.isContStatus = false;
                    //}
                }
                
                List<String> lstAllError = new List<String>();
                if(String.isNotBlank(contractObj.Error__c)){
                    for(String str : contractObj.Error__c.split(';')){
                        lstAllError.add(str);
                    }
                    WrapperContractObj.lstAllError = lstAllError;
                }
                system.debug('WrapperContractObj $$$$$$$$$$$$$$$$$$ '+WrapperContractObj);
                lstWrapperContract.add(WrapperContractObj);
            }
        }catch(Exception ex){System.debug('####### excep '+ex);}
    }
    
}