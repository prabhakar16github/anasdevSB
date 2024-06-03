@isTest
public class MaintenanceRequestControllerTracker {

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
        contactObj.Email = 'test@test10.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT Id, AccountId FROM Contact WHERE Id =: contactObj.Id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
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
        
        Email_Status_Tracking__c estAddressObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, null, addressObj.Id);
        List<Email_Status_Tracking__c> emailStatusList = New List<Email_Status_Tracking__c>{estAddressObj};
        insert emailStatusList;
    }
    
    public static testMethod void testDate_BankDetail_1(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Bank_Account_Detail__c supportBankAccObj = CommonDataTracker.insertBankAccDetails(null, supportOpportunityObj.Id);
        insert supportBankAccObj; 
        System.assertEquals(supportOpportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: supportBankAccObj.Id].Opportunity__c );
        
        Email_Status_Tracking__c estBankObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, supportBankAccObj.Id, null);
        insert estBankObj;
        
        MaintenanceRequestController.getRequestData(null, supportBankAccObj.Id, 'BankDetail', 'accepted');
    }
    
    public static testMethod void testDate_BankDetail_2(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Bank_Account_Detail__c supportBankAccObj = CommonDataTracker.insertBankAccDetails(null, supportOpportunityObj.Id);
        insert supportBankAccObj; 
        System.assertEquals(supportOpportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: supportBankAccObj.Id].Opportunity__c );
        
        Email_Status_Tracking__c estBankObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, supportBankAccObj.Id, null);
        insert estBankObj;
        
        MaintenanceRequestController.getRequestData(null, supportBankAccObj.Id, 'BankDetail', 'rejected');
        
    }
    
    public static testMethod void testDate_BankDetail_3(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c
                                      FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        supportOpportunityObj.New_Email__c = opportunityObj.Email__c;
        update supportOpportunityObj;
        
        Bank_Account_Detail__c supportBankAccObj = CommonDataTracker.insertBankAccDetails(null, supportOpportunityObj.Id);
        insert supportBankAccObj; 
        System.assertEquals(supportOpportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: supportBankAccObj.Id].Opportunity__c );
        supportBankAccObj.Penny_Deposit_Status__c = 'Success';
        supportBankAccObj.Verification_Status__c = 'Success';
        update supportBankAccObj;
        
        Email_Status_Tracking__c estBankObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, supportBankAccObj.Id, null);
        insert estBankObj;
        
        MaintenanceRequestController.getRequestData(null, supportBankAccObj.Id, 'BankDetail', 'accepted');
        
    }
    
    public static testMethod void testDate_BankDetail_4(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Bank_Account_Detail__c supportBankAccObj = CommonDataTracker.insertBankAccDetails(null, supportOpportunityObj.Id);
        insert supportBankAccObj; 
        System.assertEquals(supportOpportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: supportBankAccObj.Id].Opportunity__c );
        
        Email_Status_Tracking__c estBankObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, supportBankAccObj.Id, null);
        estBankObj.Merchant_Response__c = 'Accepted';
        insert estBankObj;
        
        MaintenanceRequestController.getRequestData(null, supportBankAccObj.Id, 'BankDetail', 'accepted');
        
    }
    
    public static testMethod void testDate_EmailDetail_1(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c FROM Opportunity LIMIT 1];
        opportunityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        opportunityObj.Mobile__c = '9876543219';
        update opportunityObj;
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        supportOpportunityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityObj.New_Email__c = 'shivdeep.yadav@payu.in';
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityObj.Id, '', null, null,null);
        insert estOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityObj.Id, 'EmailDetail', 'accepted');
        
        Account supportMobileAccountObj = CommonDataTracker.insertAccount('CR-Test Account2', 'LegalName868', 'GKMSF4212W');
        supportMobileAccountObj.Business_Entity__c =  entityObj.Id;
        supportMobileAccountObj.Identifier__c = '587879089887';
        supportMobileAccountObj.RecordTypeId = accRecordTypeId;
        insert supportMobileAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportMobileAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityMobileObj = CommonDataTracker.insertOpportunity(supportMobileAccountObj);
        supportOpportunityMobileObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityMobileObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityMobileObj.Prod_Merchant_Id__c = null;
        supportOpportunityMobileObj.Active__c = True;
        supportOpportunityMobileObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityMobileObj.Mobile__c = '8765432198';
        supportOpportunityMobileObj.New_Mobile__c = '9987654321';
        insert supportOpportunityMobileObj;
        System.assertEquals(supportMobileAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityMobileObj.Id].AccountId);
        
        Email_Status_Tracking__c estMobileOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityMobileObj.Id, '', null, null,null);
        insert estMobileOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityMobileObj.Id, 'MobileDetail', 'accepted');
        
        Entity__c individualEntityObj = CommonDataTracker.insertEntity('Individual');
        insert individualEntityObj;
        System.assertEquals('Individual', [SELECT Id, Name FROM Entity__c WHERE Id =: individualEntityObj.Id].Name); 
        
        Account supportEntityAccountObj = CommonDataTracker.insertAccount('CR-Test Account3', 'LegalName88', 'GKMSF4212W');
        supportEntityAccountObj.Business_Entity__c =  entityObj.Id;
        supportEntityAccountObj.Identifier__c = '587879089887';
        supportEntityAccountObj.RecordTypeId = accRecordTypeId;
        insert supportEntityAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportEntityAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityEntityObj = CommonDataTracker.insertOpportunity(supportEntityAccountObj);
        supportOpportunityEntityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityEntityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityEntityObj.Prod_Merchant_Id__c = null;
        supportOpportunityEntityObj.Active__c = True;
        supportOpportunityEntityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityEntityObj.Business_Entity__c = entityObj.Id;
        supportOpportunityEntityObj.New_Business_Entity__c = individualEntityObj.Name;
        insert supportOpportunityEntityObj;
        System.assertEquals(supportEntityAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityEntityObj.Id].AccountId);
       
        Email_Status_Tracking__c estEntityOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityEntityObj.Id, '', null, null,null);
        insert estEntityOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityEntityObj.Id, 'EntityDetail', 'accepted');
    }
    
    public static testMethod void testDate_EmailDetail_2(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityObj.Id, '', null, null,null);
        insert estOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityObj.Id, 'EmailDetail', 'rejected');
        
        Account supportMobileAccountObj = CommonDataTracker.insertAccount('CR-Test Account2', 'LegalName868', 'GKMSF4212W');
        supportMobileAccountObj.Business_Entity__c =  entityObj.Id;
        supportMobileAccountObj.Identifier__c = '587879089887';
        supportMobileAccountObj.RecordTypeId = accRecordTypeId;
        insert supportMobileAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportMobileAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityMobileObj = CommonDataTracker.insertOpportunity(supportMobileAccountObj);
        supportOpportunityMobileObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityMobileObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityMobileObj.Prod_Merchant_Id__c = null;
        supportOpportunityMobileObj.Active__c = True;
        supportOpportunityMobileObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityMobileObj.Mobile__c = '8765432198';
        supportOpportunityMobileObj.New_Mobile__c = '9987654321';
        insert supportOpportunityMobileObj;
        System.assertEquals(supportMobileAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityMobileObj.Id].AccountId);
        
        Email_Status_Tracking__c estMobileOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityMobileObj.Id, '', null, null,null);
        insert estMobileOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityMobileObj.Id, 'MobileDetail', 'rejected');
        Account supportEntityAccountObj = CommonDataTracker.insertAccount('CR-Test Account3', 'LegalName88', 'GKMSF4212W');
        supportEntityAccountObj.Business_Entity__c =  entityObj.Id;
        supportEntityAccountObj.Identifier__c = '587879089887';
        supportEntityAccountObj.RecordTypeId = accRecordTypeId;
        insert supportEntityAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportEntityAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityEntityObj = CommonDataTracker.insertOpportunity(supportEntityAccountObj);
        supportOpportunityEntityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityEntityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityEntityObj.Prod_Merchant_Id__c = null;
        supportOpportunityEntityObj.Active__c = True;
        supportOpportunityEntityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityEntityObj.Mobile__c = '8765432198';
        supportOpportunityEntityObj.New_Mobile__c = '9987654321';
        insert supportOpportunityEntityObj;
        System.assertEquals(supportEntityAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityEntityObj.Id].AccountId);
        
        Email_Status_Tracking__c estEntityOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityEntityObj.Id, '', null, null,null);
        insert estEntityOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityEntityObj.Id, 'EntityDetail', 'rejected');
    }
    
    public static testMethod void testDate_EmailDetail_3(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c,Mobile__c
                                      FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        bankAccObj.Verification_Status__c = 'Success';
        update bankAccObj;
        
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        supportOpportunityObj.Email__c = 'shivdeep.yadav@payu.in';
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        supportOpportunityObj.New_Email__c = opportunityObj.Email__c;
        update supportOpportunityObj;
        
        Email_Status_Tracking__c estOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityObj.Id, '', null, null,null);
        insert estOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityObj.Id, 'EmailDetail', 'accepted');
        
        Account supportMobileAccountObj = CommonDataTracker.insertAccount('CR-Test Account2', 'LegalName868', 'GKMSF4212W');
        supportMobileAccountObj.Business_Entity__c =  entityObj.Id;
        supportMobileAccountObj.Identifier__c = '587879089887';
        supportMobileAccountObj.RecordTypeId = accRecordTypeId;
        insert supportMobileAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportMobileAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityMobileObj = CommonDataTracker.insertOpportunity(supportMobileAccountObj);
        supportOpportunityMobileObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityMobileObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityMobileObj.Prod_Merchant_Id__c = null;
        supportOpportunityMobileObj.Active__c = True;
        supportOpportunityMobileObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityMobileObj.Mobile__c = '8765432198';
        supportOpportunityMobileObj.New_Mobile__c = '9987654321';
        insert supportOpportunityMobileObj;
        System.assertEquals(supportMobileAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityMobileObj.Id].AccountId);
        
        supportOpportunityMobileObj.New_Mobile__c = opportunityObj.Mobile__c;
        update supportOpportunityMobileObj;
        
        Email_Status_Tracking__c estMobileOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityMobileObj.Id, '', null, null,null);
        insert estMobileOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityMobileObj.Id, 'MobileDetail', 'accepted');
        
        Account supportEntityAccountObj = CommonDataTracker.insertAccount('CR-Test Account3', 'LegalName88', 'GKMSF4212W');
        supportEntityAccountObj.Business_Entity__c =  entityObj.Id;
        supportEntityAccountObj.Identifier__c = '587879089887';
        supportEntityAccountObj.RecordTypeId = accRecordTypeId;
        insert supportEntityAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportEntityAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityEntityObj = CommonDataTracker.insertOpportunity(supportEntityAccountObj);
        supportOpportunityEntityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityEntityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityEntityObj.Prod_Merchant_Id__c = null;
        supportOpportunityEntityObj.Active__c = True;
        supportOpportunityEntityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityEntityObj.Mobile__c = '8765432198';
        supportOpportunityEntityObj.New_Mobile__c = '9987654321';
        insert supportOpportunityEntityObj;
        System.assertEquals(supportEntityAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityEntityObj.Id].AccountId);
        
        supportOpportunityEntityObj.New_Business_Entity__c = opportunityObj.BusinessEntityName__c;
        update supportOpportunityEntityObj;
        
        Email_Status_Tracking__c estEntityOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityEntityObj.Id, '', null, null,null);
        insert estEntityOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityEntityObj.Id, 'EntityDetail', 'accepted');
    }
    
    public static testMethod void testDate_EmailDetail_4(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityObj.Id, '', null, null,null);
        estOppObj.Merchant_Response__c = 'Accepted';
        insert estOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityObj.Id, 'EmailDetail', 'accepted');
        
        Account supportMobileAccountObj = CommonDataTracker.insertAccount('CR-Test Account2', 'LegalName868', 'GKMSF4212W');
        supportMobileAccountObj.Business_Entity__c =  entityObj.Id;
        supportMobileAccountObj.Identifier__c = '587879089887';
        supportMobileAccountObj.RecordTypeId = accRecordTypeId;
        insert supportMobileAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportMobileAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityMobileObj = CommonDataTracker.insertOpportunity(supportMobileAccountObj);
        supportOpportunityMobileObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityMobileObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityMobileObj.Prod_Merchant_Id__c = null;
        supportOpportunityMobileObj.Active__c = True;
        supportOpportunityMobileObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityMobileObj.Mobile__c = '8765432198';
        supportOpportunityMobileObj.New_Mobile__c = '9987654321';
        insert supportOpportunityMobileObj;
        System.assertEquals(supportMobileAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityMobileObj.Id].AccountId);
        
        Email_Status_Tracking__c estMobileOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityMobileObj.Id, '', null, null,null);
        estMobileOppObj.Merchant_Response__c = 'Accepted';
        insert estMobileOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityMobileObj.Id, 'MobileDetail', 'accepted');
        
        Account supportEntityAccountObj = CommonDataTracker.insertAccount('CR-Test Account3', 'LegalName88', 'GKMSF4212W');
        supportEntityAccountObj.Business_Entity__c =  entityObj.Id;
        supportEntityAccountObj.Identifier__c = '587879089887';
        supportEntityAccountObj.RecordTypeId = accRecordTypeId;
        insert supportEntityAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportEntityAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityEntityObj = CommonDataTracker.insertOpportunity(supportEntityAccountObj);
        supportOpportunityEntityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityEntityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityEntityObj.Prod_Merchant_Id__c = null;
        supportOpportunityEntityObj.Active__c = True;
        supportOpportunityEntityObj.Email__c = 'shivdeep.yadav@testpayu.in';
        supportOpportunityEntityObj.Mobile__c = '8765432198';
        supportOpportunityEntityObj.New_Mobile__c = '9987654321';
        insert supportOpportunityEntityObj;
        System.assertEquals(supportEntityAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityEntityObj.Id].AccountId);
        
        Email_Status_Tracking__c estEntityOppObj = CommonDataTracker.insertEmailStatusTrack('', supportOpportunityEntityObj.Id, '', null, null,null);
        estEntityOppObj.Merchant_Response__c = 'Accepted';
        insert estEntityOppObj;
        
        MaintenanceRequestController.getRequestData(null, supportOpportunityEntityObj.Id, 'EntityDetail', 'accepted');
    }
    
    public static testMethod void testDate_PANDetail_1(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c,New_PAN_Number__c,New_PAN_Holder_Name__c,PAN_Holder_Name__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        supportAccountObj.ParentId = accountObj.Id;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountObj.Id, null,null);
        insert estAccountObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountObj.Id, 'PANDetail', 'accepted');
        
        Account supportAccountLegalObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName823', 'GKMSF4212W');
        supportAccountLegalObj.Business_Entity__c =  entityObj.Id;
        supportAccountLegalObj.Identifier__c = '587879089887';
        supportAccountLegalObj.RecordTypeId = accRecordTypeId;
        supportAccountLegalObj.ParentId = accountObj.Id;
        insert supportAccountLegalObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountLegalObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityLegalObj = CommonDataTracker.insertOpportunity(supportAccountLegalObj);
        supportOpportunityLegalObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityLegalObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityLegalObj.Prod_Merchant_Id__c = null;
        supportOpportunityLegalObj.Active__c = True;
        insert supportOpportunityLegalObj;
        System.assertEquals(supportAccountLegalObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityLegalObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountLegalObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountLegalObj.Id, null,null);
        insert estAccountLegalObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountLegalObj.Id, 'LegalDetail', 'accepted');
    }
    
    public static testMethod void testDate_PANDetail_2(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c,New_PAN_Number__c,New_PAN_Holder_Name__c,PAN_Holder_Name__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        supportAccountObj.ParentId = accountObj.Id;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountObj.Id, null,null);
        insert estAccountObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountObj.Id, 'PANDetail', 'rejected');
        
        Account supportAccountLegalObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName823', 'GKMSF4212W');
        supportAccountLegalObj.Business_Entity__c =  entityObj.Id;
        supportAccountLegalObj.Identifier__c = '587879089887';
        supportAccountLegalObj.RecordTypeId = accRecordTypeId;
        supportAccountLegalObj.ParentId = accountObj.Id;
        insert supportAccountLegalObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountLegalObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityLegalObj = CommonDataTracker.insertOpportunity(supportAccountLegalObj);
        supportOpportunityLegalObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityLegalObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityLegalObj.Prod_Merchant_Id__c = null;
        supportOpportunityLegalObj.Active__c = True;
        insert supportOpportunityLegalObj;
        System.assertEquals(supportAccountLegalObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityLegalObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountLegalObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountLegalObj.Id, null,null);
        insert estAccountLegalObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountLegalObj.Id, 'LegalDetail', 'rejected');
    }
    
    public static testMethod void testDate_PANDetail_3(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c,New_PAN_Number__c,New_PAN_Holder_Name__c,PAN_Holder_Name__c,Legal_Name__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c
                                      FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        bankAccObj.Verification_Status__c = 'Success';
        update bankAccObj;
        
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        supportAccountObj.ParentId = accountObj.Id;
        supportAccountObj.Merchant_Email__c = 'shivdeep.yadav@payu.in';
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        supportAccountObj.New_PAN_Holder_Name__c = accountObj.PAN_Holder_Name__c;
        supportAccountObj.New_PAN_Number__c = accountObj.PAN_Number__c;
        update supportAccountObj;
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountObj.Id, null,null);
        insert estAccountObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountObj.Id, 'PANDetail', 'accepted');
        
        Account supportAccountLegalObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName823', 'GKMSF4212W');
        supportAccountLegalObj.Business_Entity__c =  entityObj.Id;
        supportAccountLegalObj.Identifier__c = '587879089887';
        supportAccountLegalObj.RecordTypeId = accRecordTypeId;
        supportAccountLegalObj.ParentId = accountObj.Id;
        supportAccountLegalObj.Merchant_Email__c = 'shivdeep.yada@testpayu.in';
        insert supportAccountLegalObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountLegalObj.Id].PAN_Number__c);
        
        supportAccountLegalObj.New_Legal_Name__c = accountObj.Legal_Name__c;
        update supportAccountLegalObj;
        
        Opportunity supportOpportunityLegalObj = CommonDataTracker.insertOpportunity(supportAccountLegalObj);
        supportOpportunityLegalObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityLegalObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityLegalObj.Prod_Merchant_Id__c = null;
        supportOpportunityLegalObj.Active__c = True;
        insert supportOpportunityLegalObj;
        System.assertEquals(supportAccountLegalObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityLegalObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountLegalObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountLegalObj.Id, null,null);
        insert estAccountLegalObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountLegalObj.Id, 'LegalDetail', 'accepted');
    }
    
    public static testMethod void testDate_PANDetail_4(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c,New_PAN_Number__c,New_PAN_Holder_Name__c,PAN_Holder_Name__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        supportAccountObj.ParentId = accountObj.Id;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountObj.Id, null,null);
        estAccountObj.Merchant_Response__c = 'Accepted';
        insert estAccountObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountObj.Id, 'PANDetail', 'accepted');
        
        Account supportAccountLegalObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName823', 'GKMSF4212W');
        supportAccountLegalObj.Business_Entity__c =  entityObj.Id;
        supportAccountLegalObj.Identifier__c = '587879089887';
        supportAccountLegalObj.RecordTypeId = accRecordTypeId;
        supportAccountLegalObj.ParentId = accountObj.Id;
        insert supportAccountLegalObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountLegalObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityLegalObj = CommonDataTracker.insertOpportunity(supportAccountLegalObj);
        supportOpportunityLegalObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityLegalObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityLegalObj.Prod_Merchant_Id__c = null;
        supportOpportunityLegalObj.Active__c = True;
        insert supportOpportunityLegalObj;
        System.assertEquals(supportAccountLegalObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityLegalObj.Id].AccountId);
        
        Email_Status_Tracking__c estAccountLegalObj = CommonDataTracker.insertEmailStatusTrack('', null, '', supportAccountLegalObj.Id, null,null);
        estAccountLegalObj.Merchant_Response__c = 'Accepted';
        insert estAccountLegalObj;
        
        MaintenanceRequestController.getRequestData(null, supportAccountLegalObj.Id, 'LegalDetail', 'accepted');
    }
    
    public static testMethod void testDate_AddressDetail_1(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Address_Details__c supportAddressObj = CommonDataTracker.insertAddressDetails(null, supportAccountObj.Id, supportOpportunityObj.Id, 'Registered');
        insert supportAddressObj;
        
        Email_Status_Tracking__c estAddressObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, null,supportAddressObj.Id);
        insert estAddressObj;
        
        MaintenanceRequestController.getRequestData(null, supportAddressObj.Id, 'AddressDetail', 'accepted');
    }
    
    public static testMethod void testDate_AddressDetail_2(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Address_Details__c supportAddressObj = CommonDataTracker.insertAddressDetails(null, supportAccountObj.Id, supportOpportunityObj.Id, 'Registered');
        insert supportAddressObj;
        
        Email_Status_Tracking__c estAddressObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, null,supportAddressObj.Id);
        insert estAddressObj;
        
        MaintenanceRequestController.getRequestData(null, supportAddressObj.Id, 'AddressDetail', 'rejected');
    }
    
    public static testMethod void testDate_AddressDetail_3(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c,Email__c
                                      FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        bankAccObj.Verification_Status__c = 'Success';
        update bankAccObj;
        
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        supportOpportunityObj.New_Email__c = opportunityObj.Email__c;
        update supportOpportunityObj;
        
        Address_Details__c supportAddressObj = CommonDataTracker.insertAddressDetails(null, null, supportOpportunityObj.Id, 'Registered');
        insert supportAddressObj;
        
        Email_Status_Tracking__c estAddressObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, null,supportAddressObj.Id);
        insert estAddressObj;
        
        MaintenanceRequestController.getRequestData(null, supportAddressObj.Id, 'AddressDetail', 'accepted');
    }
    
    public static testMethod void testDate_AddressDetail_4(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT Id, AccountId,Business_Entity__c,Business_Entity__r.Name,BusinessEntityName__c,
                                      New_Website_Url__c,New_Android_URL__c,New_IOS_URL__c,Website_Status__c FROM Opportunity LIMIT 1];
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c,IFSC_Code__c,Penny_Deposit_Status__c,Active__c  FROM Bank_Account_Detail__c LIMIT 1];
        Website_Details__c wdObj = [Select Id,Active__c ,Opportunity__c,Website_Status__c,IOS_URL__c,Android_URL__c,Website_URL__c
                                    from Website_Details__c LIMIT 1];
        Address_Details__c addressObj = [Select Id,Opportunity__c From Address_Details__c LIMIT 1];
        
        Account supportAccountObj = CommonDataTracker.insertAccount('CR-Test Account', 'LegalName86823', 'GKMSF4212W');
        supportAccountObj.Business_Entity__c =  entityObj.Id;
        supportAccountObj.Identifier__c = '587879089887';
        supportAccountObj.RecordTypeId = accRecordTypeId;
        insert supportAccountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: supportAccountObj.Id].PAN_Number__c);
        
        Opportunity supportOpportunityObj = CommonDataTracker.insertOpportunity(supportAccountObj);
        supportOpportunityObj.RecordTypeId = oppRecordTypeId;
        supportOpportunityObj.Parent_Opportunity__c = opportunityObj.Id;
        supportOpportunityObj.Prod_Merchant_Id__c = null;
        supportOpportunityObj.Active__c = True;
        insert supportOpportunityObj;
        System.assertEquals(supportAccountObj.id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: supportOpportunityObj.Id].AccountId);
        
        Address_Details__c supportAddressObj = CommonDataTracker.insertAddressDetails(null, null, supportOpportunityObj.Id, 'Registered');
        insert supportAddressObj;
        
        Email_Status_Tracking__c estAddressObj = CommonDataTracker.insertEmailStatusTrack('', null, '', null, null,supportAddressObj.Id);
        estAddressObj.Merchant_Response__c = 'Accepted';
        insert estAddressObj;
        
        MaintenanceRequestController.getRequestData(null, supportAddressObj.Id, 'AddressDetail', 'accepted');
    }
}