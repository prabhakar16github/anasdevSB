@isTest
public class PublishExistingOppWebsiteBatchTracker {

    public static testMethod void data1(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', '12345');
        accountObj.PAN_Number__c='wedds2323e';
        insert accountObj;
        system.debuG(accountObj);
        System.assertEquals('Test Account', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Website__c = 'tetshelp.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        opportunityObj.Website_Status__c='Website OK';
        opportunityObj.Risk_Level__c = 'High-Auto Approved';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        string sObjectname = 'Opportunity';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{opportunityObj.Id},sObjectname,producerName ));
        Test.stopTest();
    }
    
    /*public static testMethod void data2(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account2', 'Legal2', '122245');
        accountObj.PAN_Number__c='wedds2322e';
        accountObj.Delivery_Duration__c = 3;
        accountObj.Monthly_Expected_Sale__c = 21321;
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        system.debuG(accountObj);
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        System.assertEquals('Test Account2', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Website OK';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.risk_level__c = 'Medium';
        opportunityObj.Website_Remarks__c = 'sdvsdv';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opp = [Select Id,Account.Ndx_Score__c,Account.Pan_verification_Status__c,Account.Document_Status__c,
                          Account.Agreement_Status__c,lead_type__c,website_status__c,risk_level__c,Website_Remarks__c,
                          Website__c,iOS_URL__c,Android_URL__c,Settlement_Status__c from opportunity 
                          where id=:opportunityObj.Id];
        string objName = 'Opportunity';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{opp.Id},objName,producerName));
        Test.stopTest();
    }*/
    
    public static testMethod void data3(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account3', 'Legal3', '132345');
        accountObj.PAN_Number__c='wedds2343e';
        accountObj.Delivery_Duration__c = 3;
        accountObj.Monthly_Expected_Sale__c = 21321;
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        system.debuG(accountObj);
        System.assertEquals('Test Account3', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.risk_level__c = 'Medium';
        opportunityObj.Website_Remarks__c = 'sdvsdv';
        opportunityObj.Prod_Merchant_Id__c = 234313312;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opp = [Select Id,Account.Ndx_Score__c,Account.Pan_verification_Status__c,Account.Document_Status__c,
                          Account.Agreement_Status__c,lead_type__c,website_status__c,risk_level__c,Website_Remarks__c,
                          Website__c,iOS_URL__c,Android_URL__c,Settlement_Status__c from opportunity 
                          where id=:opportunityObj.Id];
        string objName = 'Opportunity';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{opp.Id},objName,producerName));
        Test.stopTest();
    }
    
    public static testMethod void data4(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account3', 'Legal3', '132345');
        accountObj.PAN_Number__c='wedds2343e';
        accountObj.Delivery_Duration__c = 3;
        accountObj.Monthly_Expected_Sale__c = 21321;
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        system.debuG(accountObj);
        System.assertEquals('Test Account3', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.risk_level__c = 'Medium';
        opportunityObj.Website_Remarks__c = 'sdvsdv';
        opportunityObj.Prod_Merchant_Id__c = 234313312;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opp = [Select Id,Account.Ndx_Score__c,Account.Pan_verification_Status__c,Account.Document_Status__c,
                          Account.Agreement_Status__c,lead_type__c,website_status__c,risk_level__c,Website_Remarks__c,
                          Website__c,iOS_URL__c,Android_URL__c,Settlement_Status__c from opportunity 
                          where id=:opportunityObj.Id];
        string objName = 'Account';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{accountObj.Id},objName,producerName));
        Test.stopTest();
    }
    
    public static testMethod void data5(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account3', 'Legal3', '132345');
        accountObj.PAN_Number__c='wedds2343e';
        accountObj.Delivery_Duration__c = 3;
        accountObj.Monthly_Expected_Sale__c = 21321;
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        system.debuG(accountObj);
        System.assertEquals('Test Account3', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.risk_level__c = 'Medium';
        opportunityObj.Website_Remarks__c = 'sdvsdv';
        opportunityObj.Prod_Merchant_Id__c = 234313312;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opp = [Select Id,Account.Ndx_Score__c,Account.Pan_verification_Status__c,Account.Document_Status__c,
                          Account.Agreement_Status__c,lead_type__c,website_status__c,risk_level__c,Website_Remarks__c,
                          Website__c,iOS_URL__c,Android_URL__c,Settlement_Status__c from opportunity 
                          where id=:opportunityObj.Id];
        Bank_Account_Detail__c bad = New Bank_Account_Detail__c();
        bad.Active__c = true;
        bad.Account_Holder_Name__c = 'Test Account';
        bad.Account_Number__c = '232432422';
        bad.Account_Number_IFSC_Code__c = 'icic0000021';
        bad.Verification_Status__c = 'Success';
        bad.Opportunity__c = opp.Id;
        insert bad;
        string objName = 'Bank_Account_Detail__c';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{bad.Id},objName,producerName));
        Test.stopTest();
    }

    
    public static testMethod void data6(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account3', 'Legal3', '132345');
        accountObj.PAN_Number__c='wedds2343e';
        accountObj.Delivery_Duration__c = 3;
        accountObj.Monthly_Expected_Sale__c = 21321;
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Agreement_Status__c = 'Sent';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        system.debuG(accountObj);
        System.assertEquals('Test Account3', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        insert contactObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Individual');
        entityObj.Total_Required_Documents__c = 3;
        insert entityObj;
        
        Document_Category_Master__c docCategoryAddressObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof of Signing Authority');
        
        Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('PAN Card of Signing Authority');
        
        Document_Category_Master__c docCategoryBankObj =  CommonDataTracker.insertDocCategoryMaster('Bank Account Proof');

        Document_Type_Master__c docTypeObj = CommonDataTracker.insertDcoTypeMaster('Agreement');
        insert docTypeObj;
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Merchant Document').getRecordTypeId();
        Id docMasterRecId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Merchant Document').getRecordTypeId();
        Id agreementRecId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
      
        Document_Master__c docMasterPan = CommonDataTracker.insertDocumentMaster('Pan',docCategoryPanObj,docMasterRecId,'');
        docMasterPan.Document_For__c = 'Merchant';
        docMasterPan.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterAddress = CommonDataTracker.insertDocumentMaster('Address',docCategoryAddressObj,docMasterRecId,'');
        docMasterAddress.Document_For__c = 'Merchant';
        docMasterAddress.Document_Category__c = docCategoryAddressObj.Id;
        docMasterAddress.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterBank = CommonDataTracker.insertDocumentMaster('Bank',docCategoryBankObj,docMasterRecId,'');
        docMasterBank.Document_For__c = 'Merchant';
        docMasterBank.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterAgreement = CommonDataTracker.insertDocumentMaster('Agreement',docCategoryBankObj,agreementRecId,'ServiceAgreementMoney');
        docMasterAgreement.Document_For__c = 'Merchant';
        docMasterAgreement.Document_Type__c = docTypeObj.Id;
        docMasterAgreement.Entity__c = entityObj.Id;
        
        List<Document_Master__c> docMasterList = new List<Document_Master__c>{docMasterPan,docMasterAddress,docMasterBank,docMasterAgreement};
            insert docMasterList;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj,contactObj,null,docMasterAgreement,'Pending');
        contractObj.Active__c = false;
        insert contractObj;
        
        contractObj.Status = 'Pending';
        update contractObj;
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.risk_level__c = 'Medium';
        opportunityObj.Website_Remarks__c = 'sdvsdv';
        opportunityObj.Prod_Merchant_Id__c = 234313312;
        //opportunityObj.Website_updated_last__c = true;
        
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opp = [Select Id,Account.Ndx_Score__c,Account.Pan_verification_Status__c,Account.Document_Status__c,
                          Account.Agreement_Status__c,lead_type__c,website_status__c,risk_level__c,Website_Remarks__c,
                          Website__c,iOS_URL__c,Android_URL__c,Settlement_Status__c from opportunity 
                          where id=:opportunityObj.Id];
        string objName = 'WebsiteOpportunity';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{opp.Id},objName,producerName));
        Test.stopTest();
    }
    
    public static testMethod void data7(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account3', 'Legal3', 'GKMSF4212W');
        insert accountObj;
        System.assertEquals('Test Account3', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        string objName = 'WebsiteAddendumOpportunity';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{opportunityObj.Id},objName,producerName));
        Test.stopTest();
    }
    
    public static testMethod void data8(){
        Test.startTest();
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        insert accountObj;
        System.assertEquals('Test Account', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        set<string> producerName = new set<String>();
        producerName.add('MerchantOnboarding');
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Website_Status__c='Verification in Process';
        opportunityObj.Website__c = 'sadasdas.com';
        opportunityObj.Monthly_Expected_Sale__c = 123;
        opportunityObj.Delivery_Duration__c = 30;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = opportunityObj.Id;
        websiteObj.Active__c = true;
        websiteObj.Website_Status__c = 'Verification in Process';
        insert websiteObj;
        
        string objName = 'Website_Details__c';
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch(new Set<String>{websiteObj.Id},objName,producerName));
        Test.stopTest();
    }
}