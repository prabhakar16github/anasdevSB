@isTest
public class SendAgreementControllerTracker{
    
    @testSetup static void setupCommonData(){
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Email__c = 'asdf@asd.com';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Service Agreement');
        insert docCategoryMasterObj; 
        System.assertEquals('Service Agreement', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);    
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        Id PayOutRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Payout Activation').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Product__c = prodObj.Id;
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractDraftObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractDraftObj.E_Stamp__c = EStampMasterObj.Id;
        contractDraftObj.Type__c = 'Draft';
       // contractDraftObj.Contract_Type__c ='PayoutAgreement';
        insert contractDraftObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractDraftObj.Id].AccountId);
        
       /* Contract contractDraftObj1 = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractDraftObj1.E_Stamp__c = EStampMasterObj.Id;
        contractDraftObj1.Type__c = 'Draft';
        contractDraftObj1.Contract_Type__c ='PayoutAgreement';
        insert contractDraftObj1;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractDraftObj.Id].AccountId);
        */
        Contract contractFinalObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractFinalObj.E_Stamp__c = EStampMasterObj.Id;
        contractFinalObj.Type__c = 'Final';
        contractFinalObj.Contract_Type__c = 'PayoutAgreement';
        contractFinalObj.Status='Pending';
        contractFinalObj.URL__c='agreement@payu.in';
        insert contractFinalObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractFinalObj.Id].AccountId);
        
        Contract contCounterSignedObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractFinalObj.E_Stamp__c = EStampMasterObj.Id;
        contCounterSignedObj.Type__c = 'Final';
        contCounterSignedObj.Status = 'Counter Signed Received';
        insert contCounterSignedObj;
        System.assertEquals('Counter Signed Received', [SELECT ID, Status FROM Contract WHERE Id =: contCounterSignedObj.Id].Status);
        
        Document_Type_Master__c docType = CommonDataTracker.insertDcoTypeMaster('Partnership Deed');
        insert docType;
        Document_Type_Master__c docType2 = CommonDataTracker.insertDcoTypeMaster('Addendum');	
        insert docType2;
    }
    
    @isTest static void testMethodOne(){        
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Contact contactObj = [SELECT id, Name, Email, AccountId, OwnerId, Owner.Email, Owner.Name FROM Contact WHERE AccountId =: accountObj.Id];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Merchant_Id__c, Account.Owner.Email, Product__c,Owner.Name, Owner.Email FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Email__c = 'asdf@asd.com';
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        system.debug('contentVersionObj ########### '+contentVersionObj);
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId]; 
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Name, Document_Category__c, Page_Association__c, Product__c FROM Document_Master__c  LIMIT 1];
        
        List<E_Stamp_Master__c> lstEStampMaster = [SELECT Id, Active__c FROM E_Stamp_Master__c];
        
        Contract contractObject = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c, Status, URL__c, Document_Category__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Final' LIMIT 1];
        
        Contract contCounterSignedObj = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c, Status, URL__c, Document_Category__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Final' AND Status = 'Counter Signed Received' LIMIT 1];
            
        Test.startTest();
        SendAgreementController.getOpportunityRecord(null, null);
        SendAgreementController.getOpportunityRecord(opportunityObj.Id, true);
        
        SendAgreementController.createContract(accountObj, contactObj, true,opportunityObj,null);
        
        SendAgreementController.getContentVersion(contentVersionObj.ContentDocumentId);
        
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, contentDocumentObj.Id, true, contractObject, 'Agreement', true, contCounterSignedObj);        
        
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, null, true, contractObject, 'Agreement', false, contCounterSignedObj);        
        SendAgreementController.getParentAcntContactRec(docMasterAgreementObj.Id);
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){        
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Contact contactObj = [SELECT id, Name, Email, AccountId, OwnerId, Owner.Email, Owner.Name FROM Contact WHERE AccountId =: accountObj.Id];
        
        List<E_Stamp_Master__c> lstEStampMaster = [SELECT Id, Active__c FROM E_Stamp_Master__c];
         Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
       
        Opportunity opportunityObj = [SELECT id, AccountId, Merchant_Id__c, Account.Owner.Email, Product__c,Owner.Name, Owner.Email FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.E_Stamp__c = lstEStampMaster[0].Id;
        opportunityObj.Email__c = 'asdf@asd.com';
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        system.debug('contentVersionObj Two ########### '+contentVersionObj);
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId]; 
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Name, Document_Category__c, Page_Association__c, Product__c FROM Document_Master__c  LIMIT 1];
        system.debug('docMasterAgreementObj!!!'+docMasterAgreementObj);
        Contract contractObject = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Draft' LIMIT 1];
        
        Contract contCounterSignedObj = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c, Status, URL__c, Document_Category__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Final' AND Status = 'Counter Signed Received' LIMIT 1];
        
        Attachment attach = New Attachment(ParentId=opportunityObj.Id,Name='Addendum',body=blob.valueOf('test body'));
        insert attach;
        
        Document_Type_Master__c docType =[Select Id,Name from Document_Type_Master__c LIMIT 1];
        docType.name='Addendum';
        update docType;
        Document_Category_Master__c docCategory =[Select Id from Document_Category_Master__c where Name=:'Service Agreement' LIMIT 1];
        
        WrapperSendAgreement wrapperData = new WrapperSendAgreement();
        wrapperData.accObj = accountObj;
        wrapperData.authSignContact = contactObj;
        wrapperData.isSendingMail = true;
        wrapperData.oppObj = opportunityObj;
        
        Test.startTest();
        SendAgreementController.getOpportunityRecord(null, null);
        SendAgreementController.getOpportunityRecord(opportunityObj.Id, false);
        
        SendAgreementController.createContract(accountObj, contactObj, false,opportunityObj,null);
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, contentDocumentObj.Id, false, contractObject, 'Agreement', true, contCounterSignedObj);  
        SendAgreementController.getContentVersion(contentVersionObj.ContentDocumentId);
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, null, false, contractObject, 'Agreement', true, contCounterSignedObj);  
        SendAgreementController.insertAttachmentonOpp(opportunityObj.Id,attach.Id,attach.Name, 'test body',attach.ContentType);
        SendAgreementController.insertContractAndSendToESB(attach.Id, true, contactObj, wrapperData, 'Addendum', docType.Id,docType.Name,false);
        Test.stopTest();
    }
    @isTest static void testMethodThree(){ 
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Name, Merchant_Id__c,Owner.Name, Owner.Email FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Email__c = 'asdf@asd.com';
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        Test.startTest();
        ServiceAgreementMoneyComponentController objForPage2 = new ServiceAgreementMoneyComponentController();
        objForPage2.strOppId = opportunityObj.Id;
        objForPage2.getstrOpportunity();
        getListOfMerchantDocController onjGetdata = new getListOfMerchantDocController();
        onjGetdata.strAccountId = accountObj.id;
        onjGetdata.getlstofMercDoc();
        
        Test.stopTest();
    }
    
    @isTest static void testMethodFour(){        
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Contact contactObj = [SELECT id, Name, Email, AccountId, OwnerId, Owner.Email, Owner.Name FROM Contact WHERE AccountId =: accountObj.Id];
        
        List<E_Stamp_Master__c> lstEStampMaster = [SELECT Id, Active__c FROM E_Stamp_Master__c];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Merchant_Id__c, Account.Owner.Email, Product__c,Owner.Name, Owner.Email FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.E_Stamp__c = lstEStampMaster[0].Id;
        opportunityObj.Email__c = 'asdf@asd.com';
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        system.debug('contentVersionObj Two ########### '+contentVersionObj);
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId]; 
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Name, Document_Category__c, Page_Association__c, Product__c FROM Document_Master__c  LIMIT 1];
                        
        Contract contractObject = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Draft'  LIMIT 1];
        
        Contract contCounterSignedObj = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c, Status, URL__c, Document_Category__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Final' AND Status = 'Counter Signed Received' LIMIT 1];
        
        Attachment attach = New Attachment(ParentId=opportunityObj.Id,Name='Test',body=blob.valueOf('test body'));
        insert attach;
        
        Document_Type_Master__c docType =[Select Id,name from Document_Type_Master__c LIMIT 1];
        Document_Category_Master__c docCategory =[Select Id from Document_Category_Master__c where Name=:'Service Agreement' LIMIT 1];
        
        WrapperSendAgreement wrapperData = new WrapperSendAgreement();
        wrapperData.accObj = accountObj;
        wrapperData.authSignContact = contactObj;
        wrapperData.isSendingMail = true;
        wrapperData.oppObj = opportunityObj;
        
        Test.startTest();
        SendAgreementController.getOpportunityRecord(null, null);
        SendAgreementController.getOpportunityRecord(opportunityObj.Id, false);
        
        SendAgreementController.createContract(accountObj, contactObj, false,opportunityObj,null);
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, contentDocumentObj.Id, false, contractObject, 'Agreement', true, contCounterSignedObj);  
        SendAgreementController.getContentVersion(contentVersionObj.ContentDocumentId);
        SendAgreementController.sendMailWithAttachment(opportunityObj, contactObj, docMasterAgreementObj.Id, null, false, contractObject, 'Agreement', true, contCounterSignedObj);  
        SendAgreementController.insertAttachmentonOpp(opportunityObj.Id,'',attach.Name, 'test body',attach.ContentType);
        
        Test.stopTest();
    }
    @isTest  static void testMethodFive(){
        
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        //Contact contactObj = [SELECT id, Name, Email, AccountId, OwnerId, Owner.Email, Owner.Name FROM Contact WHERE AccountId =: accountObj.Id];
        
        List<E_Stamp_Master__c> lstEStampMaster = [SELECT Id, Active__c FROM E_Stamp_Master__c];
         Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
       
        Opportunity opportunityObj = [SELECT id, Merchant_Id__c, Account.Owner.Email, Product__c,Owner.Name, Owner.Email FROM Opportunity ];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Email__c = 'asdf@asd.com';
        //opportunityObj.E_Stamp__c = lstEStampMaster[0].Id;
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        system.debug('contentVersionObj Two ########### '+contentVersionObj);
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId]; 
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Name, Document_Category__c, Page_Association__c, Product__c FROM Document_Master__c  LIMIT 1];
                        
       // Contract contractObject = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Draft' LIMIT 1];
        
        //Contract contCounterSignedObj = [SELECT ID, AccountId, Type__c, Contract_Type__c, E_Stamp__c, Status, URL__c, Document_Category__c FROM Contract WHERE AccountId =: accountObj.Id AND type__c =: 'Final' AND Status = 'Counter Signed Received' LIMIT 1];
        
        Attachment attach = New Attachment(ParentId=opportunityObj.Id,Name='Test',body=blob.valueOf('test body'));
        insert attach;
        
        Document_Type_Master__c docType =[Select Id,Name from Document_Type_Master__c LIMIT 1];
        Document_Category_Master__c docCategory =[Select Id from Document_Category_Master__c where Name=:'Service Agreement' LIMIT 1];
        
        WrapperSendAgreement wrapperData = new WrapperSendAgreement();
        //wrapperData.accObj = accountObj;
       // wrapperData.authSignContact = contactObj;
        wrapperData.isSendingMail = true;
        wrapperData.oppObj = opportunityObj;
        
        Test.startTest();
        //SendAgreementController.getOpportunityRecord(null, null);
        SendAgreementController.getOpportunityRecord(opportunityObj.Id, false);
        Test.stopTest();
    }
   
    
}