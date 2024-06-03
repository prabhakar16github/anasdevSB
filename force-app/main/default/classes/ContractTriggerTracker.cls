@isTest
public class ContractTriggerTracker{    
    
    @testSetup static void setupCommonData(){
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Contract', true);
        insert triggerSwitchObj ;
        
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
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name); 
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.InsertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c=entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Document_Type_Master__c docTypeMasterObj = CommonDataTracker.insertDcoTypeMaster('Addendum');
        insert docTypeMasterObj ;
        
        Document_Type_Master__c docTypeMasterObj2 = CommonDataTracker.insertDcoTypeMaster('Agreement');
        insert docTypeMasterObj2 ;
        
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
    }
    
    @isTest static void testMethodOne(){
        Account accountObj = [SELECT id, PAN_Number__c,Agreement_Status__c FROM Account LIMIT 1]; 
        accountObj.Agreement_Status__c = 'Not Generated';
        update accountObj;
        
        Contact contactObj = [SELECT id, AccountId FROM Contact WHERE AccountId =: accountObj.id LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Contract contractObj = [SELECT ID, Status, AccountId FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        Test.startTest();
        contractObj.Contract_Type__c ='Agreement';
        contractObj.Status = 'Draft Finalised';
        contractObj.URL__c = 'www.payu.in';
        contractObj.Type__c = 'Final';
        update contractObj;
        
        contractObj.Status = 'Pending';
        update contractObj;
        
        contractObj.Status = 'Counter Signed Received';
        update contractObj;
        
        contractObj.Status = 'Declined';
        update contractObj;
        
        contractObj.Status = 'Approved';
        update contractObj;
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, null,'Registered');
        insert  addDetailsRegObj;
        
        addDetailsRegObj.Address_Line__c = 'test add';
        update addDetailsRegObj;
        generateAgreementFromAddressUpdate queuable = new generateAgreementFromAddressUpdate(new Set<string>{addDetailsRegObj.Id});        
        Contract contractObj1 = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Counter Signed Received');
        contractObj1.Type__c = 'Final';
        insert contractObj1;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj1.Id].AccountId);
        
        ContractTriggerHandler.update_Status(new Set<Id>{contractObj.Id},new List<String>{accountObj.Id},null);
        
        Delete contractObj;
        
        Test.stopTest();
    }
    
    //for Insertion of bulk addendum
    @isTest static void testMethodTwo(){
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Contact contactObj = [SELECT id, AccountId FROM Contact WHERE AccountId =: accountObj.id LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Contract contractObj = [SELECT ID, Status,Opportunity__c, AccountId,Product_Label__c,URL__c,Contract_Type__c,Active__c
                                FROM Contract WHERE AccountId =: accountObj.Id LIMIT 1];
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        Document_Type_Master__c docTypeObj = [Select Id from Document_Type_Master__c Where Name='Addendum' LIMIT 1];
        Test.startTest();
        
        contractObj.Status = 'Pending';
        contractObj.Opportunity__c = opportunityObj.Id;
        contractObj.Name = 'EMI';
        contractObj.Document_Master__c = docMasterAgreementObj.id;
        contractObj.Document_Type__c = docTypeObj.id;
        contractObj.Product_Label__c = 'PayUmoney';
        contractObj.MID__c = '345678';
        contractObj.Bulk_Addendum__c = True;
        contractObj.Contract_Type__c = 'Addendum';
        contractObj.URL__c = 'www.google.com';
        update contractObj;
        
        Test.stopTest();
    }
    
    //for Insertion of bulk addendum
    @isTest static void testMethodThree(){
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Product__c prodObj = [select Id from product__c LIMIT 1];
        
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c,Account.Identifier__c,Productlabel__c,MIDProductLabel__c,prod_merchant_id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.prod_merchant_id__c = 345678;
        opportunityObj.Product__c = prodObj.id;
        opportunityObj.RecordTypeId = OpportunityRecordTypeId;
        update opportunityObj;
        // System.assertEquals(opportunityObj.MIDProductLabel__c, [SELECT ID, MIDProductLabel__c FROM Opportunity WHERE Id =: opportunityObj.Id].MIDProductLabel__c);
        
        system.debug('opportunityObj.prod_merchant_id__c'+opportunityObj.prod_merchant_id__c);
        system.debug('opportunityObj.MIDProductLabel__c=='+opportunityObj.MIDProductLabel__c);
        system.debug('opportunityObj.Productlabel__c=='+opportunityObj.Productlabel__c);
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c,identifier__c FROM Document_Master__c LIMIT 1];
        Document_Type_Master__c docTypeObj = [SELECT Id,identifier__c,Name FROM Document_Type_Master__c  LIMIT 1];
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, null,'Registered');
        insert  addDetailsRegObj;
        
        list<contract> newContractList = new list<contract>();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new AddendumMockClass());
        
        Contract contrObj = New Contract();
        contrObj.Document_Master__c = docMasterAgreementObj.id;
        contrObj.Status = 'Pending';
        contrObj.Name = 'EMI';
        contrObj.Document_Master__c = docMasterAgreementObj.id;
        contrObj.Document_Type__c = docTypeObj.id;
        contrObj.Product_Label__c = 'PayUmoney';
        contrObj.URL__c = '';
        contrObj.MID__c = '345678';
        contrObj.Bulk_Addendum__c = true;
        contrObj.Contract_Type__c = 'Addendum';
        contrObj.Active__c = true;
        contrObj.AccountId = accountObj.Id;
        contrObj.Opportunity__c = opportunityObj.Id;
        newContractList.add(contrObj);
        
        
        Contract contrObj1 = New Contract();
        contrObj1.Document_Master__c = docMasterAgreementObj.id;
        contrObj1.Status = 'Pending';
        contrObj1.Name = 'EMI';
        contrObj1.Document_Master__c = docMasterAgreementObj.id;
        contrObj1.Document_Type__c = docTypeObj.id;
        contrObj1.Product_Label__c = 'PayUmoney';
        contrObj1.MID__c = '345678';
        contrObj1.Bulk_Addendum__c = True;
        contrObj1.Contract_Type__c = 'Addendum';
        contrObj1.URL__c = 'www.google.com';
        contrObj.AccountId = accountObj.Id;
        //newContractList.add(contrObj1);
        
        insert  newContractList;        
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contrObj.Id].AccountId);
        
        Delete newContractList;
        Test.stopTest();
    }
    
    public static testMethod void methodFour(){
        
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Contact contactObj = [SELECT id, AccountId FROM Contact WHERE AccountId =: accountObj.id LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        Document_Type_Master__c docTypeObj = [Select Id from Document_Type_Master__c Where Name='Addendum' LIMIT 1];
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.Status = 'Pending';
        contractObj.Opportunity__c = opportunityObj.Id;
        contractObj.Name = 'EMI';
        contractObj.Document_Master__c = docMasterAgreementObj.id;
        contractObj.Document_Type__c = docTypeObj.id;
        contractObj.Product_Label__c = 'PayUmoney';
        contractObj.MID__c = '345678';
        contractObj.Bulk_Addendum__c = True;
        contractObj.Contract_Type__c = 'Addendum';
        contractObj.URL__c = ''; 
        contractObj.Active__c = true;
        contractObj.Document_Category_Name__c = 'Service Agreement';
        contractObj.Document_Type_Name__c = 'Addendum';
        contractObj.Document_Content_Type__c = '.pdf';
        insert contractObj;
    }
    
    public static testMethod void methodFive(){
        
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1]; 
        
        Contact contactObj = [SELECT id, AccountId FROM Contact WHERE AccountId =: accountObj.id LIMIT 1];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id LIMIT 1];
        opportunityObj.Merchant_Id__c = 345678;
        opportunityObj.Identifier__c = '11eb-50c3-19ac023c-93c8-02053299b2da';
        update opportunityObj;
        System.assertNotEquals(accountObj.id, null);
        
        Document_Master__c docMasterAgreementObj = [SELECT Id, Document_Category__c FROM Document_Master__c LIMIT 1];
        
        Document_Type_Master__c docTypeObj = [Select Id from Document_Type_Master__c Where Name='Agreement' LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('Payout', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        
        Cross_Sell__c cs = new Cross_Sell__c();
        //cs.Care_Status__c = 'Not Interested';
        cs.Opportunity__c = opportunityObj.Id;
        cs.Custom_Product__c = prodObj.Id;
        cs.Product_Name__c = 'Payout';
        cs.Source__c = 'Dashboard';
        cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        cs.Risk_Status__c = 'Pending';
        cs.Risk_Rejection_Date__c = date.today();
        cs.Cross_Sell_Stop_Task_Creation__c = false;
        cs.Risk_Zone__c = 'Amber Zone';
        cs.Uploaded_by_dataloader__c = true;
        insert cs;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.Status = 'Pending';
        contractObj.Opportunity__c = opportunityObj.Id;
        contractObj.Name = 'EMI';
        contractObj.Document_Master__c = docMasterAgreementObj.id;
        contractObj.Document_Type__c = docTypeObj.id;
        contractObj.Product_Label__c = 'PayUmoney';
        contractObj.MID__c = '345678';
        contractObj.Bulk_Addendum__c = True;
        contractObj.Contract_Type__c = 'PayoutAgreement';
        contractObj.URL__c = ''; 
        contractObj.Active__c = true;
        contractObj.Document_Category_Name__c = 'PayoutAgreement';
        contractObj.Document_Type_Name__c = 'Agreement';
        contractObj.Document_Content_Type__c = '.pdf';
        insert contractObj;
        
        contractObj.status = 'Approved';
        update contractObj;
    }
}