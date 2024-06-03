@isTest
public class MerchantStatusDetailsTriggerTracker {

    public static testMethod void testData1(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Merchant_Status_Details__c', true);
        insert triggerSwitchObj ;  
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert opportunityObj;
        
        Merchant_Status_Details__c mSDObj = New Merchant_Status_Details__c();
        mSDObj.Status_Type__c = 'WEBSITE';
        mSDObj.Status_Value__c = 'Pending';
        mSDObj.Opportunity__c = opportunityObj.Id;
        Insert mSDObj;
        
        mSDObj.Status_Value__c = 'Website OK';
        update mSDObj;
    }
    @isTest
    static void testAddBodyInMail() {
        String contactName='testContact';
        String emailBody = MerchantStatusDetailsTriggerHandler.addBodyInMail(contactName);
        System.assertNotEquals(null, emailBody, 'not null');
    }
    @isTest
    static void testAddTableInMail() {
        List<Merchant_Document__c> merchantDocs = new List<Merchant_Document__c>();
        String tableEmailBody = MerchantStatusDetailsTriggerHandler.addTableInMail(merchantDocs);
        System.assertNotEquals(null, tableEmailBody,'not null');
    }
    @isTest
    static void testSendMailToMerchantOnDocRejectDormancyandReKYC() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        List<Opportunity> testOpportunities = new List<Opportunity>();
        Opportunity testOpp1 = new Opportunity(
            Name = 'Test Opportunity 1',
            AccountId = testAccount.Id
        );
        testOpportunities.add(testOpp1);
        Opportunity testOpp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = testAccount.Id
        );
        testOpportunities.add(testOpp2);
    	
        List<Merchant_Document__c> testMerchantDocs = new List<Merchant_Document__c>();
        List<Merchant_Status_Details__c> testMerchantStatusDocs = new List<Merchant_Status_Details__c>();
        for (Opportunity opp : testOpportunities) {
            Merchant_Status_Details__c msd1 = new Merchant_Status_Details__c(
                Opportunity__c = opp.Id,
                Status_Type__c = 'KYC_DOCUMENTS',
                Status_Value__c = 'Docs Error'
            );
            testMerchantStatusDocs.add(msd1);
            Merchant_Status_Details__c msd2 = new Merchant_Status_Details__c(
                Opportunity__c = opp.Id,
                Status_Type__c = 'RE_KYC_DOCUMENTS',
                Status_Value__c = 'Docs Error'
            );
            testMerchantStatusDocs.add(msd2);
            Merchant_Document__c doc1 = new Merchant_Document__c(
                Opportunity__c = opp.Id,
                Account__c = testAccount.Id,
                Error__c = 'Remarks 1',
                Onboarding_Status__c = 'Declined',
                reKYC_Doc__c = true,
                Active__c = true
            );
            testMerchantDocs.add(doc1);
            Merchant_Document__c doc2 = new Merchant_Document__c(
                Opportunity__c = opp.Id,
                Account__c = testAccount.Id,
                Error__c = '',
                Onboarding_Status__c = 'Declined',
                reKYC_Doc__c = false,
                Active__c = true
            );
            testMerchantDocs.add(doc2);
            Merchant_Document__c doc3 = new Merchant_Document__c(
                Opportunity__c = opp.Id,
                Account__c = testAccount.Id,
                Error__c = 'Remarks 2',
                Onboarding_Status__c = 'Approved',
                reKYC_Doc__c = true,
                Active__c = false
            );
            testMerchantDocs.add(doc3);
            Merchant_Document__c doc4 = new Merchant_Document__c(
                Opportunity__c = opp.Id,
                Account__c = testAccount.Id,
                Error__c = 'Remarks 2',
                Onboarding_Status__c = 'Approved',
                reKYC_Doc__c = true,
                Active__c = false
            );
            testMerchantDocs.add(doc4);
        }
        insert testMerchantDocs;
        insert testMerchantStatusDocs;
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact 1',AccountId = testAccount.Id,Active__c = true, Authorised_Signatory__c=true,Email='test@test.com',PAN__c='ABCDE1234F');
        insert testContact1;
        Map<Id, Opportunity> testOpportunityMap = new Map<Id, Opportunity>();
        for (Opportunity opp : testOpportunities) {
            testOpportunityMap.put(opp.Id, opp);
        }
        Map<Id, Id> conToOppId = new Map<Id, Id>{
            testContact1.Id => testOpp1.Id
        };
        Test.startTest();
        MerchantStatusDetailsTriggerHandler.sendMailToMerchantOnDocRejectOnboarding(testOpportunityMap);
        MerchantStatusDetailsTriggerHandler.sendMailToMerchantOnDocRejectDormancy(testOpportunityMap);
        MerchantStatusDetailsTriggerHandler.sendMailToMerchantOnDocRejectReKYC(testOpportunityMap);
        Test.stopTest();
    }
    @isTest
	static void testSetMailParametersAndSend() {
        Opportunity testOpportunity = new Opportunity(Name='test',StageName='Closed',CloseDate=System.today()+10);
        insert testOpportunity;
    
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact 1',Email='a@a.com');
        insert testContact;
        Map<Id, Id> conToOppId = new Map<Id, Id>{
            testContact.Id => testOpportunity.Id
        };
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailContent = '<html><body>test html</body></html>';
        Test.startTest();
        MerchantStatusDetailsTriggerHandler.setMailParametersAndSend(mail, emailContent, testContact.Id, conToOppId);
        Test.stopTest();
	}
}