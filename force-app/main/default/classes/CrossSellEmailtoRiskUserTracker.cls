@isTest
public class CrossSellEmailtoRiskUserTracker {

    @testSetup static void CommonData(){
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        //System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Delivery_Duration__c = 1;
        accountObj.Monthly_Expected_Sale__c = 10000;
        insert accountObj;
        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.Website_Status__c = 'Not Applicable';
        opportunityObj.Website__c = 'testweb.com';
        insert opportunityObj;
        
        Cross_sell__c crossSellObj = new Cross_sell__c();
        crossSellObj.RecordTypeId = Schema.SObjectType.Cross_sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
        crossSellObj.Opportunity__c = opportunityObj.id;
        insert crossSellObj;
        
        Merchant_Document__c MerchantDocumentObj = new Merchant_Document__c();
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Account__c= accountObj.Id;
        MerchantDocumentObj.URL__c = 'www.google.com';
        MerchantDocumentObj.Cross_Sell__c = crossSellObj.Id;
        MerchantDocumentObj.Onboarding_Status__c = 'Received';
        insert MerchantDocumentObj;
        
        //System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        //Test.stopTest();  
        
    }
    
    static testMethod void testCrossSell() 
    {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Child'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        //System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Delivery_Duration__c = 1;
        accountObj.Monthly_Expected_Sale__c = 10000;
        insert accountObj;
        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.Website_Status__c = 'Not Applicable';
        opportunityObj.Website__c = 'testweb.com';
        insert opportunityObj;
        
        Cross_sell__c crossSellObj = new Cross_sell__c();
        crossSellObj.RecordTypeId = Schema.SObjectType.Cross_sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
        crossSellObj.Opportunity__c = opportunityObj.id;
        insert crossSellObj;
        
        Merchant_Document__c MerchantDocumentObj = new Merchant_Document__c();
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Account__c= accountObj.Id;
        MerchantDocumentObj.URL__c = 'www.google.com';
        MerchantDocumentObj.Cross_Sell__c = crossSellObj.Id;
        MerchantDocumentObj.Onboarding_Status__c = 'Received';
        insert MerchantDocumentObj;
            
        //Cross_sell__c cs = [select id, Risk_Status__c,Risk_Comment__c,Opportunity__r.Name,RecordTypeId,CreatedDate,Legal_Name__c,Risk_Manager_Comment__c,Risk_Manager_Status__c from Cross_Sell__c where ];
        System.debug('Cs>>>>>'+crossSellObj);
        List<Cross_Sell__c> crossSellList = new List<Cross_Sell__c>();
        List<String> crossSellIdList = new List<String>();
        crossSellList.add(crossSellObj);
        crossSellIdList.add(crossSellObj.Id);
        //Merchant_Document__c mDoc = [Select Id From Merchant_Document__c LIMIT 1]; 
        System.debug('Cs>>>>>'+MerchantDocumentObj);
        
        
        Test.startTest();
        Test.setCurrentPage(Page.CrossSellEmailToRiskTeamVf);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Cross_sell__c> {crossSellObj});
        stdSetController.setSelected(new List<Cross_sell__c> {crossSellObj});
        CrossSellEmailtoRiskUser ext = new CrossSellEmailtoRiskUser(stdSetController);
        ext.getSelectedCs();
        ext.sendEmailtoRiskTeam();
        ext.getMySelectedSize();
        ext.getSelectedCrossSell();
        CrossSellEmailtoRiskUser.getselectOptions(crossSellObj , 'Risk_Status__c');
        CrossSellEmailtoRiskUser.saveCrossSell(crossSellList, 'Manager', u.id);
            CrossSellEmailtoRiskUser.saveCrossSell(crossSellList, 'User', u.id);
        CrossSellEmailtoRiskUser.fetchCrossSell();
        CrossSellEmailtoRiskUser.getUserIdentity('sneha.sahi@payu.in');
            CrossSellEmailtoRiskUser.getUserIdentity('sneha.sahi@payu.in');
        CrossSellEmailtoRiskUser.deleteMerchDocument(MerchantDocumentObj.Id);
        CrossSellEmailtoRiskUser.createNewMerchDocument(crossSellObj.Id);
        CrossSellEmailtoRiskUser.getMerchantDocList(crossSellObj.Id);
        CrossSellEmailtoRiskUser.getCrossSellSelectedRec(crossSellIdList);
        CrossSellEmailtoRiskUser.sendEmailtoRiskTeam(crossSellList);
        CrossSellEmailtoRiskUser.uploadDocToS3('fileName', 'base64Data', '', crossSellObj.Id);
        CrossSellEmailtoRiskUser.saveTheFile(crossSellObj.Id, 'fileName', 'base64Data', 'application/json', crossSellObj);
        CrossSellEmailtoRiskUser.getselectOptions('Cross_sell__c' , 'Risk_Status__c');
        CrossSellEmailtoRiskUser.crossSellWrapper wrap = new CrossSellEmailtoRiskUser.crossSellWrapper();
        Test.stopTest();
        }
    }

}