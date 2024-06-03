@isTest
public class generateAgreementAddressUpdateTracker{

    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Address_Details__c', true);
        insert triggerSwitchObj ; 
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Id supportRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.recordtypeId = supportRecordTypeId;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c); 
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.GST_Number__c = '343443343443';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId); 
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
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
        contractObj.status = 'Pending';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.Merchant_Id__c = null;
        leadObj.Email = 'uma.shankar+jbshadbash7y281y@gmail.com';
        leadObj.LeadSource = 'Organic';
        leadObj.Sub_Source__c = 'Email';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
    }
    
    @isTest static void testMethodOne(){        
        Account accountObj = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
         Lead leadObj = [SELECT id, ProductLabel__c, Merchant_Id__c, IntegrationInfo__c, Name, FirstName, LastName, Email, MobilePhone__c, Identifier__c, 
                        Business_Entity_Identifier__c, Business_Category_Identifier__c, Sub_Category_Identifier__c, Website__c, Merchant_Trading_Name__c, Device__c, 
                        Merchant_Business_Type__c, PAN_Holder_Name__c, PAN_Number__c, Android_URL__c, iOS_URL__c, GST_Number__c, Integration_Type__c, Delivery_Duration__c, 
                        Monthly_Expected_Sale__c, SAP_Id__c,Lead_Type__c,Active__c, Campaign_Name__c, Campaign_Medium__c, Campaign_Source__c, Campaign_Term__c, Partner_UUID__c, LeadSource, Sub_Source__c 
                        FROM Lead LIMIT 1 ];
        system.debug('>>>>>>>>> '+leadObj);
        system.debug('>>>>>>>>>product '+leadObj.ProductLabel__c);
        system.debug('>>>>>>>>>lead type '+leadObj.Lead_Type__c);
        
        Contact contactObj = [SELECT id, AccountId FROM Contact WHERE AccountId =: accountObj.id LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Contract contractObj = [SELECT ID, Status, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
         
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.id, accountObj.Id, 'Registered');
        insert  addDetailsRegObj;
        Address_Details__c addDetailsRegObj2 = CommonDataTracker.insertAddressDetails(leadObj.id, accountObj.Id, 'Operating');
        insert  addDetailsRegObj2;
        System.assertEquals(accountObj.Id, [SELECT Id,VFPageKey__c, Account__c FROM Address_Details__c WHERE Id =: addDetailsRegObj.Id].Account__c); 
        system.debug('@@@@@@@ '+addDetailsRegObj.VFPageKey__c);
        
        
        Address_Details__c addDetailsRegObj1 = new Address_Details__c(Id=addDetailsRegObj.Id);
        addDetailsRegObj1.City__c = 'Noida';
        addDetailsRegObj1.Setup_Operating_Address__c = true;
        addDetailsRegObj1.Address_Line__c = 'rdxfcgvhbj';
        addDetailsRegObj1.Pincode__c = '201305';
        update addDetailsRegObj1;
        
        Address_Details__c addDetailsRegObj12 = new Address_Details__c(Id=addDetailsRegObj2.Id);
        addDetailsRegObj12.City__c = 'Noida';
        addDetailsRegObj12.Address_Line__c = 'rdxfcgvhbj';
        addDetailsRegObj12.Pincode__c = '201305';
        update addDetailsRegObj12;
        
        system.enqueueJob(new generateAgreementFromAddressUpdate(new set<string>{string.valueOf(addDetailsRegObj1.id),string.valueOf(addDetailsRegObj12.id)}));
        Test.stopTest();
    }

}