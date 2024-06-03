@isTest
public class CrossSellDocumentControllerTracker {
    @isTest
    public static void testMethod1(){
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('NGO', true);
        businessCategory.Doable__c = true;
        businessCategory.Categories_For__c = 'Merchant';
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        subCategory.Category__c = businessCategory.Id;
        insert subCategory;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        
        Account accountObj = New Account();
        accountObj.Name = 'testAccount';
        accountObj.Business_Category__c = businessCategory.Id;
        accountObj.Sub_Category__c = subCategory.Id;
        accountObj.Agreement_Status__c = 'Pending'; 
        accountObj.PAN_Holder_Name__c = 'Sujit kumar';
        accountObj.PAN_Number__c = 'cfbpk5851h';
        accountObj.Business_Entity__c = entityObj.Id;
        insert accountObj;
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'shivdeep.testYadav@testPayu.in';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.AccountId = accountObj.Id;
        opportunityObj.Prod_Merchant_Id__c = 123456;
        insert opportunityObj;
        
        Cross_Sell__c crossSell = new Cross_Sell__c();
        crossSell.Care_Status__c = 'Interested';
        crossSell.Risk_Status__c = 'Approved';
        crossSell.Opportunity__c = opportunityObj.Id;
        insert crossSell;
        
        Merchant_Document__c MerchantDocumentObj = new Merchant_Document__c();
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Account__c= accountObj.Id;
        MerchantDocumentObj.URL__c = 'www.google.com';
        MerchantDocumentObj.KYC_Documentable_Type__c = 'CrossSellDocument';
        MerchantDocumentObj.Document_Category__c = docCategoryMasterObj.Id;
        MerchantDocumentObj.Opportunity__c = opportunityObj.Id;
        MerchantDocumentObj.Cross_Sell__c = crossSell.Id;
        insert  MerchantDocumentObj;
        
        Document_Type_Master__c docTypeMasObj = new Document_Type_Master__c();
        docTypeMasObj.Active__c = true;
        docTypeMasObj.Name = 'Website Documents';
        insert docTypeMasObj;
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankAccObj;
        List<Bank_Account_Detail__c> bankAccObjList = new List<Bank_Account_Detail__c>();
        bankAccObjList.add(bankAccObj);
        
        
        Address_Details__c addDetailsRegObj = new Address_Details__c();
        addDetailsRegObj.Account__c = accountObj.Id;
        insert addDetailsRegObj;
        List<Address_Details__c> addressList = new List<Address_Details__c>();
        addressList.add(addDetailsRegObj);
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //System.debug('documents'+documents);
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
       
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        contractObj.Opportunity__c = opportunityObj.Id;
        contractObj.Contract_Type__c ='PayoutAgreement';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        String MerchantDocumentId = MerchantDocumentObj.Id;
        WrapperDocument clsWrapperDocument = DocumentationController.getMerchantDocumentRecords(opportunityObj.id, 'Opportunity');
        
        String crossSellId = crossSell.Id;
        CrossSellDocumentController.addNewRecordDoc(JSON.serialize(clsWrapperDocument),crossSell.Id);
        CrossSellDocumentController.saveMerchantDocument(JSON.serialize(clsWrapperDocument));
        //String strWrpDoc = '{"accountObj":{"Business_Category__c":'+businessCategory.Id+',"Sub_Category__c":'+subCategory.Id+',"Agreement_Status__c":"Pending","PAN_Number__c ":"cfbpk5851h","PAN_Holder_Name__c":"Sujit kumar","Identifier__c":"1c53-7bca-8deeb192-143a-a4edfd8a602b","Legal_Name__c":"Sujit kumar","Document_Status__c":"Pending","Business_Category__r":{"Id":'+businessCategory.Id+',"Name":"Others"},"Sub_Category__r":{"Id":'+subCategory.Id+',"Name":"Others"},"isConverted__c":true,"Id":'+acc.Id+',"Business_Entity__c":'+entityObj.Id+',"PAN_Number__c":"cfbpk5851h"},"isContractExist":false,"isEditAllow":true,"isMerchantDocExist":true,"lstWrapperMerchantDocument":[{"isActive":true,"isApproved":false,"isDocCateAvail":true,"isDocEditable":true,"isDocFormat":true,"isDocuCategory":true,"isDocuType":true,"isExpiryDate":true,"isNew":false,"isOnboardingRemark":true,"isOnboardingStatus":true,"isSalesRemark":true,"listDocumentCategoryMaster":[{"Id":'+docCategoryMasterObj.Id+',"Document_Category_Type__c":"Website","Name":"Procurement Invoice","Active__c":true,"Identifier__c":"4819d403-f4e6-479b-baab-c1b6c768f4f3"}],"lstDocumentType":["Hard Copy","Soft Copy","Both"],"lstOnboardingStatus":["Pending","Received","Approved","Declined","Reuploaded"],"merchantDocumentObj":{"Account__c":'+acc.Id+',"Active__c":true,"Onboarding_Status__c":"Pending","KYC_Documentable_Type__c":"CrossSellDocument","Opportunity__c":'+opportunityObj.Id+',"Document_Category__c":'+docCategoryMasterObj.Id+',"Document_Received__c":"Soft Copy","Cross_Sell__c":'+crossSell.Id+'},"strError":""}]","optyObj":{"AccountId":"'+acc.Id+'","Lead_Type__c":"Merchant","Id":"'+opportunityObj.Id+'"}}';
        //String testDataString = '{,"optyObj":{"AccountId":"'+acc.Id+'","Lead_Type__c":"Merchant,"Id":"'+opportunityObj.Id+}}';
        CrossSellDocumentController.getMerchantDocumentRecords(opportunityObj.Id, 'Opportunity',crossSellId);
        CrossSellDocumentController.getDocumentURL(MerchantDocumentId);
        CrossSellDocumentController.deleteMerchantDocument(MerchantDocumentObj.Id);
        CrossSellDocumentController.getErrorSolutionMapping(accountObj, docCategoryMasterObj.Id);
        CrossSellDocumentController.getDocumentType();
        //CrossSellDocumentController.getAddressDetails(acc, addressList);
        //CrossSellDocumentController.getBankAccountDetails(opportunityObj, bankAccObjList);
        CrossSellDocumentController.getContentDocument(cdList[0].Id);
        CrossSellDocumentController.getContentVersion(cdList[0].Id);
        //CrossSellDocumentController.saveMerchantDocument(strWrpDoc);
    }

}