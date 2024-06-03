@isTest
public class WebsiteDocumentPreOnbControllerTracker {

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
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.entity__c = entityObj.Id;
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
        MerchantDocumentObj.KYC_Documentable_Type__c = 'WebsiteDetail';
        MerchantDocumentObj.Opportunity__c = opportunityObj.Id;
        MerchantDocumentObj.Onboarding_Status__c = 'Approved';
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId); 
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(accountObj.Id, [SELECT id, Lead__c, Account__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Account__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Operating');
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
        
        //create ContentDocumentLink record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opportunityObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Banking Operations User'];
        User userObj = CommonDataTracker.insertUser(profileObj.Id);
        insert userObj;
        System.assertEquals('pb@ff.com', userObj.email);
    }
    
    @isTest static void testMethodOne(){
        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Contract contractObj = [SELECT ID, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Merchant_Document__c MerchantDocumentObj = [SELECT Id, Account__c
                                                    FROM Merchant_Document__c
                                                    WHERE Account__c =: accountObj.Id AND Active__c =: true LIMIT 1];
        
        Document_Type_Master__c dtm = new Document_Type_Master__c(name='Website Documents');
        insert dtm;
        
        Test.startTest();
        WebsiteDocumentPreOnbController.getMerchantDocumentRecords(null, null);
        WebsiteDocumentPreOnbController.saveMerchantDocument(null);
        
        WrapperDocument clsWrapperDocument = WebsiteDocumentPreOnbController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
        
        WebsiteDocumentPreOnbController.addNewRecordDoc(JSON.serialize(clsWrapperDocument));
        
        WebsiteDocumentPreOnbController.saveMerchantDocument(JSON.serialize(clsWrapperDocument)); 
        
        WebsiteDocumentPreOnbController.getDocumentURL(MerchantDocumentObj.Id);
        
        WebsiteDocumentPreOnbController.deleteMerchantDocument(MerchantDocumentObj.Id);
        
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){
        Account accountObj = [SELECT id, PAN_Number__c, Business_Entity__c, Identifier__c FROM Account LIMIT 1]; 
        system.debug('accountObj ########### '+accountObj);
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c, Identifier__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
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
        
        Document_Type_Master__c dtm = new Document_Type_Master__c(name='Website Documents');
        insert dtm;
        
        Test.startTest();
        WebsiteDocumentPreOnbController.getMerchantDocumentRecords(null, null);
        WebsiteDocumentPreOnbController.saveMerchantDocument(null);
        
        WrapperDocument clsWrapperDocument = WebsiteDocumentPreOnbController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
        
        WebsiteDocumentPreOnbController.getErrorSolutionMapping(accountObj, documentMasterObj.Id);
        
        WebsiteDocumentPreOnbController.saveMerchantDocument(JSON.serialize(clsWrapperDocument));
        
        Test.stopTest();
    }
    
    @isTest static void testMethodThree(){
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentVersion contentVersionObj = [SELECT Id, Title FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        test.startTest();
        ContentDocument result = WebsiteDocumentPreOnbController.getContentDocument(documents[0].id);
        ContentVersion rslt = WebsiteDocumentPreOnbController.getContentVersion(documents[0].id);
        test.stopTest();
    }
    
    @isTest static void testMethodFour(){
        Account accountObj = [SELECT id, PAN_Number__c, Business_Entity__c, Identifier__c FROM Account LIMIT 1]; 
        User userObj = [SELECT Id, Name FROM User LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c, Identifier__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
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
        
        Document_Type_Master__c dtm = new Document_Type_Master__c(name='Website Documents');
        insert dtm;
        
        System.runAs(new User(Id= userObj.Id)){
            Test.startTest();
            
            WebsiteDocumentPreOnbController.getMerchantDocumentRecords(null, null);
            WebsiteDocumentPreOnbController.saveMerchantDocument(null);
            
            WrapperDocument clsWrapperDocument = WebsiteDocumentPreOnbController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
            
            WebsiteDocumentPreOnbController.getErrorSolutionMapping(accountObj, documentMasterObj.Id);
            
            WebsiteDocumentPreOnbController.saveMerchantDocument(JSON.serialize(clsWrapperDocument));
            
            Test.stopTest();
        }
    }
}