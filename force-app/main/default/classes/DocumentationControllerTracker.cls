@isTest
public class DocumentationControllerTracker{ 
    
    @testSetup static void setupCommonData(){
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Offline_Lead__c = true;
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Merchant_Business_Type__c = 'LongTail';
        opportunityObj.Lead_Type__c = 'Merchant';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        websitePageObj.Page_Details__c = 'test';
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Error_Solution_Mapping__c errorSolutionObj = CommonDataTracker.insertErrorSolutionMapping(entityObj, docCategoryMasterObj);
        insert errorSolutionObj;
        System.assertEquals(docCategoryMasterObj.id, [SELECT id, Document_Category__c FROM Error_Solution_Mapping__c WHERE id =: errorSolutionObj.id].Document_Category__c);
        
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        MerchantDocumentObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentObj.Opportunity__c = opportunityObj.Id;
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId); 
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id,null, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(accountObj.Id, [SELECT id, Lead__c, Account__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Account__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id,null,'Operating');
        insert  addDetailsOpeObj;
        System.assertEquals(accountObj.Id, [SELECT id, Lead__c, Account__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Account__c);
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankAccObj; 
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Opportunity__c );        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opportunityObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        User userObj = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Onboarding Operations User'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        insert userObj;
        
        Merchant_Auto_Approval_Details__c merchantAutoObj = CommonDataTracker.insertMerchantAutoApproval(null,opportunityObj);
        insert merchantAutoObj;
    }
    
    @isTest static void testMethodOne(){
        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c,Merchant_Business_Type__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Merchant_Business_Type__c = 'LongTail';
        update opportunityObj;
        
        Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Merchant_Document__c MerchantDocumentObj = [SELECT Id, Account__c
                                                    FROM Merchant_Document__c
                                                    WHERE Account__c =: accountObj.Id AND Active__c =: true LIMIT 1];
        
        Test.startTest();
        DocumentationController.getMerchantDocumentRecords(null, null);
        DocumentationController.saveMerchantDocument(null);
        
        WrapperDocument clsWrapperDocument = DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
        
        WrapperMerchantDocument wrpperMerDocObj = new WrapperMerchantDocument();
        wrpperMerDocObj.merchantDocumentObj = MerchantDocumentObj;
        
        clsWrapperDocument.lstWrapperMerchantDocument = new List<WrapperMerchantDocument> { wrpperMerDocObj };
        DocumentationController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
        
        DocumentationController.saveMerchantDocument(JSON.serialize(clsWrapperDocument)); 
        
        DocumentationController.getDocumentURL(MerchantDocumentObj.Id);
        
        DocumentationController.getContractLink(contractObj.Id);
        
        DocumentationController.deleteMerchantDocument(MerchantDocumentObj.Id);
        
        /** Added for SFI-331 */
        DocumentationController.getHistoryData(MerchantDocumentObj.Id);
        /** END */
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){
        Account accountObj = [SELECT id, PAN_Number__c, Business_Entity__c, Identifier__c FROM Account LIMIT 1]; 
        system.debug('accountObj ########### '+accountObj);
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c,Merchant_Business_Type__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Merchant_Business_Type__c = 'Enterprise';
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Merchant_Document__c MerchantDocumentObj = [SELECT Id, Account__c
                                                    FROM Merchant_Document__c
                                                    WHERE Account__c =: accountObj.Id AND Active__c =: true LIMIT 1];
        
        Document_Master__c documentMasterObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId]; 
        
        Test.startTest();
        DocumentationController.getMerchantDocumentRecords(null, null);
        DocumentationController.saveMerchantDocument(null);
        
        WrapperDocument clsWrapperDocument = DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
        
        DocumentationController.getErrorSolutionMapping(accountObj, opportunityObj,documentMasterObj.Id);
        
        DocumentationController.saveMerchantDocument(JSON.serialize(clsWrapperDocument));
       // DocumentationController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
        //DocumentationController.updateMerchantFileDetails(contentDocumentObj.Id, MerchantDocumentObj.Id, accountObj, 'Bank Proof', 'AVFB', null, null);
        
        //DocumentationController.updateContFiles(contentDocumentObj.Id, contractObj.Id, accountObj, 'Bank Proof', 'AVFB', null, null);        
        
        Test.stopTest();
    }
    
     @isTest static void testMethodThree(){
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentVersion contentVersionObj = [SELECT Id, Title FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        test.startTest();
        ContentDocument result = DocumentationController.getContentDocument(documents[0].id);
        ContentVersion rslt = DocumentationController.getContentVersion(documents[0].id);
        test.stopTest();
    }
    
    @isTest static void testMethod4(){
        User userObj = [Select Id from User Where Email='puser000@amamama.com' LIMIT 1];
        
        System.runAs(userObj){
            Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
            
            Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c,Merchant_Business_Type__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
            
            Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
            
            Merchant_Document__c MerchantDocumentObj = [SELECT Id, Account__c
                                                        FROM Merchant_Document__c
                                                        WHERE Account__c =: accountObj.Id AND Active__c =: true LIMIT 1];
            
            Test.startTest();
            DocumentationController.getMerchantDocumentRecords(null, null);
            DocumentationController.saveMerchantDocument(null);
            
            WrapperDocument clsWrapperDocument = DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
            
            WrapperMerchantDocument wrpperMerDocObj = new WrapperMerchantDocument();
            wrpperMerDocObj.merchantDocumentObj = MerchantDocumentObj;
            
            clsWrapperDocument.lstWrapperMerchantDocument = new List<WrapperMerchantDocument> { wrpperMerDocObj };
            DocumentationController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
            
            DocumentationController.saveMerchantDocument(JSON.serialize(clsWrapperDocument)); 
            
            DocumentationController.getDocumentURL(MerchantDocumentObj.Id);
            
            DocumentationController.getContractLink(contractObj.Id);
            
            DocumentationController.deleteMerchantDocument(MerchantDocumentObj.Id);
            
            Test.stopTest();
        }
    }
    
    @isTest static void testMethod5(){
        User userObj = [Select Id from User Where Email='puser000@amamama.com' LIMIT 1];
        
        System.runAs(userObj){
            Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
            
            Opportunity opportunityObj = [SELECT Id, Lead_Type__c,AccountId, Merchant_Id__c,Merchant_Business_Type__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
            
            Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
            contractObj.Contract_Type__c = 'PayoutAgreement';
            update contractObj;
            
            Merchant_Document__c MerchantDocumentObj = [SELECT Id, Account__c
                                                        FROM Merchant_Document__c
                                                        WHERE Account__c =: accountObj.Id AND Active__c =: true LIMIT 1];
            Merchant_Auto_Approval_Details__c merchantAutoObj = [SELECT Id,Status__c,Approvable_Type__c,Approval_Type__c,Score__c,Reason__c,Message__c from Merchant_Auto_Approval_Details__c LIMIT 1];
            Test.startTest();
            DocumentationController.getMerchantDocumentRecords(null, null);
            DocumentationController.saveMerchantDocument(null);
            
            WrapperDocument clsWrapperDocument = DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
            
            WrapperMerchantDocument wrpperMerDocObj = new WrapperMerchantDocument();
            wrpperMerDocObj.merchantDocumentObj = MerchantDocumentObj;
            
            clsWrapperDocument.lstWrapperMerchantDocument = new List<WrapperMerchantDocument> { wrpperMerDocObj };
            DocumentationController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
            
            DocumentationController.saveMerchantDocument(JSON.serialize(clsWrapperDocument)); 
            
            DocumentationController.getDocumentURL(MerchantDocumentObj.Id);
            
            DocumentationController.getContractLink(contractObj.Id);
            
            DocumentationController.deleteMerchantDocument(MerchantDocumentObj.Id);
            
            Test.stopTest();
        }
    }
    @isTest static void testMethod7(){ // Written by rohit gupta
        User userObj = [Select Id from User Where Email='puser000@amamama.com' LIMIT 1];
        
        System.runAs(userObj){
            Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
            
            Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c,Merchant_Business_Type__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
            
            Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
            Test.startTest();
            DocumentationController.getMerchantDocumentRecords(null, null);
            DocumentationController.saveMerchantDocument(null);
            
            WrapperDocument clsWrapperDocument =DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
            clsWrapperDocument.lstWrapperMerchantDocument = null;
            WrapperMerchantDocument wrpperMerDocObj = new WrapperMerchantDocument();
            DocumentationController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
            
            DocumentationController.saveMerchantDocument(JSON.serialize(clsWrapperDocument)); 
            DocumentationController.getContractLink(contractObj.Id);
            
            Test.stopTest();
        }
    }
    
}