@isTest
public class MaintenanceCtrlTracker{     
    @testSetup static void setupCommonData(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT Id, Name FROM Entity__c WHERE Id =: entityObj.Id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT Id, AccountId FROM Contact WHERE Id =: contactObj.Id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Prod_Merchant_Id__c = 7654234;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: opportunityObj.Id].AccountId);
        
        Plan__c planObj = CommonDataTracker.insertPlan('Pay Citrus');
        insert planObj;
        System.assertEquals('Pay Citrus', [SELECT Id, Name FROM Plan__c WHERE Id =: planObj.Id].Name);
        
        Commercial__c commercialObj = CommonDataTracker.insertCommercial(opportunityObj, planObj);
        insert  commercialObj;
        System.assertEquals(opportunityObj.Id, [SELECT Id, Opportunity__c FROM Commercial__c WHERE Id =: commercialObj.Id].Opportunity__c);
        
        MerchantPaymentOption__c mpoObj = new MerchantPaymentOption__c();
        mpoObj.Opportunity__c = opportunityObj.Id;
        mpoObj.Active__c = true;
        insert mpoObj; 
        System.assertNotEquals(null, [SELECT Id, Active__c FROM MerchantPaymentOption__c WHERE Id =: mpoObj.Id].Id);
        
        TDR__c tdrObj = new TDR__c();
        tdrObj.Opportunity__c = opportunityObj.Id;
        tdrObj.Active__c = true;
        insert tdrObj;
        
        Website_Details__c wdObj = CommonDataTracker.insertwebsiteDetails(opportunityObj,true, null, '', '', false, false, '',false, 'Pending', 'payu.in');
        insert wdObj;
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankAccObj; 
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Opportunity__c );
        
        Address_Details__c addressObj = CommonDataTracker.insertAddressDetails(null, null, opportunityObj.Id, 'Registered');
        insert addressObj;
    }
    
    @isTest static void testMethodOne() {
        Account accountObj = [SELECT id, PAN_Number__c,Merchant_Email__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c,New_Type__c From Address_Details__c LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        MaintenanceCtrl.createClonedData(opportunityObj.Id, 'BankDetail');
        MaintenanceCtrl.updateBankAccountData(bankAccObj);
        MaintenanceCtrl.updateAccountData(accountObj, opportunityObj, 'PANDetail');
        MaintenanceCtrl.updateOpportunityData(opportunityObj, opportunityObj, opportunityObj.BusinessEntityName__c+'--'+opportunityObj.Business_Entity__c, 'EntityDetail');
        MaintenanceCtrl.updateOpportunityData(opportunityObj, opportunityObj, '', 'WebsiteDetail');
        MaintenanceCtrl.createAddressAccountData(addressObj, opportunityObj, opportunityObj,'Registered', 'AddressDetail');
        Test.stopTest();
    }
    
    @isTest static void testMethod2() {
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        bankAccObj.IFSC_Code__c = null;
                                       update bankAccObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        MaintenanceCtrl.createClonedData(opportunityObj.Id, 'BankDetail');
        MaintenanceCtrl.updateBankAccountData(bankAccObj);        
        Test.stopTest();
    }
    
    @isTest static void testMethod3() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    

        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,
                                      Prod_Merchant_Id__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        bankAccObj.Penny_Deposit_Status__c = 'Success';
                                       update bankAccObj;
        
        Entity__c entityObj = [Select Id from Entity__c];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '9867587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        supportAccountObj.ParentId = accountObj.Id;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);        
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.Active__c = True;
        supportOpportunityObj.recordTypeId = oppRecordTypeId;
        supportOpportunityObj.Name = 'CR-BankDetail-'+opportunityObj.Prod_Merchant_Id__c;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        MaintenanceCtrl.createClonedData(opportunityObj.Id, 'BankDetail');
        MaintenanceCtrl.updateBankAccountData(bankAccObj);        
        Test.stopTest();
    }
}