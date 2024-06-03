@isTest
public class SystemUtilityTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Entity__c', true);
        insert triggerSwitchObj ; 
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Lead', true);
        insert enableUUIDObjObj;
        
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
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
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
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        Attachment AttachObj = CommonDataTracker.insertAttachment('AttachName', accountObj.Id);
        insert  AttachObj;
        System.assertEquals(accountObj.Id, [SELECT ID, parentId FROM Attachment WHERE Id =: AttachObj.Id].parentId);
        
        Document_Type_Master__c docTypeMastObj = CommonDataTracker.insertDcoTypeMaster('Doc Type');
        insert  docTypeMastObj;
        System.assertEquals('Doc Type', [SELECT ID, Name FROM Document_Type_Master__c WHERE Id =: docTypeMastObj.Id].Name);
        
        Category_Type_Mapping__c CatTypeMapObj = CommonDataTracker.insertCategoryTypeMapping(docCategoryMasterObj, docTypeMastObj);
        insert CatTypeMapObj; 
        System.assertEquals(docCategoryMasterObj.Id, [SELECT ID, Document_Category__c FROM Category_Type_Mapping__c WHERE Id =: CatTypeMapObj.Id].Document_Category__c);    
    }
    
    @isTest static void testMethodOne(){ 
        
        List<EmailTemplate> lstEmailTemplate = DatabaseUtility.getEmailTemplate('Biz_Introduction_Template_With_MAF');
        
        List<Attachment> lstAttachment = [SELECT Id, ContentType, Name, Body FROM Attachment];
        
        Enable_UUID_Objects__c enableUUIDObjObj = Enable_UUID_Objects__c.getValues('Lead');
        
        Lead leadObj = new Lead();
        
        SystemUtility.ErrorLogWrapper ErrorLogWrp = new SystemUtility.ErrorLogWrapper();
        ErrorLogWrp.message = 'msg';
        ErrorLogWrp.process = 'DML';
        ErrorLogWrp.request = 'Req';
        ErrorLogWrp.response = 'Res';
        ErrorLogWrp.stackTrace = 'Stack';
        
        String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
        Id orgWideEmailAddId = null;
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
        if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
        if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;
        system.debug('orgWideEmailAddId ####### '+orgWideEmailAddId);
          
        
        Test.startTest(); 
        
        SystemUtility.sendEmailWithUpdateBody('Saasfocus', 'uma.shankar@saasfocus.com', lstEmailTemplate[0], lstAttachment, 'ABC', 'manav.arora@saasfocus.com', 'jatin.narula@saasfocus.com', orgWideEmailAddId, true);
        
        SystemUtility.getPicklistValue('Lead', 'Status');
        
        SystemUtility.getDocumentCategory();
            
        SystemUtility.getDocCategMapping();
            
        SystemUtility.getMapDocCateVsLstTypeMapping();
        
        SystemUtility.getRecordTypeId('Opportunity', 'Merchant');
        
        SystemUtility.generateRandomString(10);
        
        SystemUtility.getIdentifierUUID(leadObj, 'Identifier__c', enableUUIDObjObj);
            
        SystemUtility.BlobToString(Blob.valueOf('ABC'), 'UTF-8'); 
        
        SystemUtility.insertErrorLog(ErrorLogWrp);
        SystemUtility.getQueuesInfo(new List<String>());
        SystemUtility.createHTTPPublisher(null, null, null, null);
       // SystemUtility.getAllErrors(null, new List<String>());
        SystemUtility.MaskString('asdsa', New List<string> {'sadas'}, 'sads234234', 4);
        SystemUtility.getPLvaluesbyRT('Account', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId(), 'Type__c');
        SystemUtility.createTask(New List<Task>(), Date.today(), 'Test Desc', false, null, UserInfo.getUserId(), 'High', System.Now(), 'Test Subject', 'New', null);
        SystemUtility.getQueuesNameMembers(New list<string> {'test'});
        SystemUtility.getAllFieldsOfObject('Final', 'Contract', 'Type__c');
        SystemUtility.errorHandler(null, New Map<String, String>{'Prod'=>'test'});
        Test.stopTest();
    }
}