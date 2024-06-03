@isTest
public class BankDetailTriggerTracker{  
   
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Bank_Account_Detail__c', true);
        triggerSwitchObj.Publisher_Call__c = true;
        insert triggerSwitchObj;
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name); 
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
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, null, null, null);
        leadObj.Prod_Merchant_Id__c = 876746557;
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c); 
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        insert MerchantDocumentObj;
        
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Pending');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        insert contractObj;
        
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
    }    
    
    
    @isTest static void testMethodOne_1() {        
        
        Lead ld = [Select Id from Lead where Prod_Merchant_Id__c = 876746557];
        ld.OwnerId = Label.IntegrationUserId;
        update ld;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.lead__c = ld.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        
        bankDeatilObj.Penny_Deposit_Status__c = 'Success';
        update bankDeatilObj;
        
        Bank_Account_Detail__c bankDeatilObj1 = new Bank_Account_Detail__c();
        bankDeatilObj1.Account_Number__c = '20472628463';
        bankDeatilObj1.Verification_Status__c = 'Success';
        bankDeatilObj1.Id = bankDeatilObj.Id;
        update bankDeatilObj1;
        Map<String, Map<String, String>> performaMap = new Map<String, Map<String, String>>();  
        BankDetailTriggerHandler.requestPerformaMap(performaMap,bankDeatilObj1);
        Test.stopTest();
    }
    
    @isTest static void testMethodOne_2() {        
        
        Lead ld = [Select Id from Lead where Prod_Merchant_Id__c = 876746557];
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.lead__c = ld.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        
        bankDeatilObj.Penny_Deposit_Status__c = 'Success';
        update bankDeatilObj;
        
        Bank_Account_Detail__c bankDeatilObj1 = new Bank_Account_Detail__c();
        bankDeatilObj1.Account_Number__c = '20472628463';
        bankDeatilObj1.Verification_Status__c = 'Success';
        bankDeatilObj1.Id = bankDeatilObj.Id;
        update bankDeatilObj1;
        
        Test.stopTest();
    }
    
    @isTest static void testMethodOne_3() {        
        
        Group grp = new Group();
		grp.name = Label.Other_Queue_Name;
		grp.Type = 'Queue'; 
		Insert grp; 
		
                
		//Create Group Member
		GroupMember grpMem1 = new GroupMember();
		grpMem1.UserOrGroupId = UserInfo.getUserId();
		grpMem1.GroupId = grp.Id;
		Insert grpMem1;
        
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        
        System.RunAs(u){
            QueuesObject q1 = new QueueSObject(QueueID = grp.id, SobjectType = 'Lead');
            insert q1;
            
            Lead ld = [Select Id from Lead where Prod_Merchant_Id__c = 876746557];
        ld.OwnerId = grp.Id;
        update ld;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.lead__c = ld.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        
        bankDeatilObj.Penny_Deposit_Status__c = 'Success';
        update bankDeatilObj;
        
        Bank_Account_Detail__c bankDeatilObj1 = new Bank_Account_Detail__c();
        bankDeatilObj1.Account_Number__c = '20472628463';
        bankDeatilObj1.Verification_Status__c = 'Success';
        bankDeatilObj1.Id = bankDeatilObj.Id;
        update bankDeatilObj1;
        
        Test.stopTest();
        }
        
    }
    
    @isTest static void testMethodTwo() { 
        
        Lead leadObj = [SELECT id FROM Lead LIMIT 1]; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Lead__c = leadObj.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Penny_Deposit_Status__c = 'Success';
        insert bankDeatilObj;
        
        bankDeatilObj.Nodal_Code__c = '';
        bankDeatilObj.NEFT_Nodal_Code__c = '';
        update bankDeatilObj;
        
        bankDeatilObj.Nodal_Code__c = 'asdfghjkl';
        bankDeatilObj.NEFT_Nodal_Code__c = 'asdfghj';
        update bankDeatilObj;      
        
        
        Test.stopTest();
    }
    
    @isTest static void testMethodThree_1() { 
        
        Lead leadObj = [SELECT id FROM Lead LIMIT 1]; 
        
        Account accountObj=[SELECT id,Agreement_Status__c FROM Account LIMIT 1];
        accountObj.Agreement_Status__c = 'Sent';
        //accountObj.Agreement_Status__c = 'Not Generated';
        update accountObj;
        system.assertEquals('Sent',accountObj.Agreement_Status__c );
        
        Contract cont = [Select Id,Active__c,AccountId from Contract where AccountId =: accountObj.Id];
        cont.Active__c = false;
        update cont;
        system.assertEquals(1, [Select Id,Active__c from Contract where AccountId =: accountObj.Id].Size());
        
        Product__c prodObj = [Select Id,Product_Name__c from Product__c LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id,AccountId,Account.Agreement_Status__c,lead_Type__c,Product__c,
                                      Product__r.Product_Name__c,Product_Name__c
                                      FROM Opportunity LIMIT 1];
        
        VFPageWithData__c vfData = new VFPageWithData__c();
        vfData.VFPageName__c = 'ServiceAgreementMoney';
        vfData.Name = 'payUmoney-Merchant';
        Insert vfData;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Bank_Account_Detail__c bankDeatilObj0 = new Bank_Account_Detail__c();
        bankDeatilObj0.Account_Number__c = '20472628463';
        bankDeatilObj0.Account_Type__c = 'Saving';
        bankDeatilObj0.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj0.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj0.Lead__c = leadObj.Id;
        bankDeatilObj0.Active__c = true;
        bankDeatilObj0.Opportunity__c = opportunityObj.Id;
        bankDeatilObj0.Preforma_Processed__c = true;
        bankDeatilObj0.NEFT_Nodal_Code__c = 'xfddxfug';
        insert bankDeatilObj0;
                
        bankDeatilObj0.Verification_Status__c = 'Success';
        bankDeatilObj0.Account_Number__c = '2134567889';
        update bankDeatilObj0;
        bankDeatilObj0.Request_Type__c='Escrow Plug-in';
        bankDeatilObj0.Active__c = false;
        update bankDeatilObj0;
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Lead__c = leadObj.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Opportunity__c = opportunityObj.Id;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.NEFT_Nodal_Code__c = 'xfddxfug';
        bankDeatilObj.Verification_Status__c = 'Success';
        bankDeatilObj.Bank_Account_Verified_Last__c = true;
        insert bankDeatilObj;
        
        Bank_Account_Detail__c badObj = [Select Id,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Product__r.Product_Name__c,Lead_Type__c
                                        ,Bank_Account_Verified_Last__c,VFPageKey__c From Bank_Account_Detail__c Where Id=:bankDeatilObj.Id];
        
        System.debug('@@@@@@@@@@@@@ '+badObj.Opportunity__r.AccountId);
        system.assertEquals(true,badObj.Bank_Account_Verified_Last__c);
        //system.assertEquals(badObj.VFPageKey__c,badObj.Opportunity__r.Product__r.Product_Name__c +'-'+badObj.Lead_Type__c);
        //system.assertEquals(true,bankDeatilObj.Agreement_Regeneration__c);
        system.assertEquals(accountObj.Id,[Select Id,AccountId,lead_Type__c,Product__c,Product__r.Product_Name__c
                                           from Opportunity Where Id =: badObj.Opportunity__c].AccountId);
        
        BankDetailTriggerHandler.updateagreementinOnlineCaseWithnewURL(new Set<String>{badObj.Id});
        
        Test.stopTest();
    }
    
    @isTest static void testMethodThree_2() { 
        
        Lead leadObj = [SELECT id FROM Lead LIMIT 1]; 
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        leadMap.put(leadObj.Id,leadObj);
        Account accountObj=[SELECT id,Agreement_Status__c FROM Account LIMIT 1];
        accountObj.Agreement_Status__c = 'Sent';
        update accountObj;
        system.assertEquals('Sent',accountObj.Agreement_Status__c );
        
        Contract cont = [Select Id,Active__c,AccountId from Contract where AccountId =: accountObj.Id];
        cont.Active__c = false;
        update cont;
        system.assertEquals(1, [Select Id,Active__c from Contract where AccountId =: accountObj.Id].Size());
        
        Product__c prodObj = [Select Id,Product_Name__c from Product__c LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id,AccountId,Account.Agreement_Status__c,lead_Type__c,Product__c,
                                      Product__r.Product_Name__c,Product_Name__c
                                      FROM Opportunity LIMIT 1];
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        oppMap.put(opportunityObj.Id,opportunityObj);
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        List<Bank_Account_Detail__c> bobjList = new List<Bank_Account_Detail__c>();
        Bank_Account_Detail__c bankDeatilObj0 = new Bank_Account_Detail__c();
        bankDeatilObj0.Account_Number__c = '20472628463';
        bankDeatilObj0.Account_Type__c = 'Saving';
        bankDeatilObj0.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj0.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj0.Lead__c = leadObj.Id;
        bankDeatilObj0.Active__c = true;
        bankDeatilObj0.Opportunity__c = opportunityObj.Id;
        bankDeatilObj0.Preforma_Processed__c = true;
        bankDeatilObj0.NEFT_Nodal_Code__c = 'xfddxfug';
        insert bankDeatilObj0;
                
        bankDeatilObj0.Verification_Status__c = 'Success';
        bankDeatilObj0.Account_Number__c = '2134567889';
        update bankDeatilObj0;
        bobjList.add(bankDeatilObj0);
        Map<String,Bank_Account_Detail__c> escrowOppWithBankDetailMap = new Map<String,Bank_Account_Detail__c>();
        escrowOppWithBankDetailMap.put(String.valueOf(bankDeatilObj0.Opportunity__c),bankDeatilObj0);
        BankDetailTriggerHandler.updateParentStatus(bobjList,oppMap,null);
        //BankDetailTriggerHandler.updateEscrowOppData(escrowOppWithBankDetailMap);
        BankDetailTriggerHandler.getParentDetails(null,null,null,null,null);
    }
    
    public static testMethod void test_supportOpp(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();    
    
        Account accountObj=[SELECT id,Agreement_Status__c FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id,AccountId,Account.Agreement_Status__c,lead_Type__c,Product__c,
                                      Product__r.Product_Name__c,Product_Name__c
                                      FROM Opportunity LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
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
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(null,supportOpportunityLegalObj.Id);
        bankAccObj.New_Account_Holder_Name__c = 'Test Name';
        bankAccObj.New_Account_Number__c = '002341239900';
        bankAccObj.New_Bank_Name__c = 'ICICI BANK';
        bankAccObj.New_IFSC_Code__c = 'ICIC0000021';
        insert bankAccObj;
        
        bankAccObj.Verification_Status__c = 'Success';
        bankAccObj.Penny_Deposit_Status__c = 'Success';
        update bankAccObj;
    }
}