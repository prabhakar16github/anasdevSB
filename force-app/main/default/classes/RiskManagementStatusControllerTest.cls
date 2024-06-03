@isTest
private class RiskManagementStatusControllerTest {
    @testSetup static void setup() {
        Account accForOppWithoutAnyRiskHold = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithoutAnyRiskHold;
        
        Opportunity oppWithoutAnyRiskHold = CommonDataTracker.insertOpportunity(accForOppWithoutAnyRiskHold);
        oppWithoutAnyRiskHold.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert oppWithoutAnyRiskHold;
        
        
        Account accForOppWithAnyRiskHold = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithAnyRiskHold;
        
        Opportunity oppWithAnyRiskHold = CommonDataTracker.insertOpportunity(accForOppWithAnyRiskHold);
        oppWithAnyRiskHold.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert oppWithAnyRiskHold;
        
        
        Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
        Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
        Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
        List<Risk_status_Detail__c> lstRsd = new List<Risk_status_Detail__c>();
        Risk_status_Detail__c  rsdPo = new Risk_status_Detail__c();
        rsdPo.RecordTypeId = postTypeId;
        rsdPo.Opportunity__c = oppWithAnyRiskHold.Id;
        lstRsd.add(rsdPo);
        Risk_status_Detail__c  rsdOb = new Risk_status_Detail__c();
        rsdOb.RecordTypeId = obTypeId;
        rsdOb.Opportunity__c = oppWithAnyRiskHold.Id;
        lstRsd.add(rsdOb);
        Risk_status_Detail__c  rsdPre = new Risk_status_Detail__c();
        rsdPre.RecordTypeId = preTypeId;
        rsdPre.Opportunity__c = oppWithAnyRiskHold.Id;
        lstRsd.add(rsdPre);
        
        insert lstRsd; 
        Website_Details__c webDetails = new Website_Details__c();
        webDetails.Opportunity__c = oppWithoutAnyRiskHold.Id;
        webDetails.Active__c = true;
        insert webDetails;
        Website_Page__c webPageRecord = CommonDataTracker.insertWebsitePage('Product/Services Details',false,oppWithAnyRiskHold);
        insert webPageRecord;
        
    }
    
    @isTest static void testGetRecordTypeIdAndStatusNew() {
        Id oppWithoutRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account' LIMIT 1].Id;
        Test.startTest();
        Map<Id,Risk_status_Detail__c> listOfMerchantRec =  RiskManagementStatusController.getRecordTypeIdAndStatus(oppWithoutRiskRec);
        Test.stopTest();
        System.assertEquals(3, listOfMerchantRec.size());
        
    }
    
    @isTest static void testGetRecordTypeIdAndStatusExisting() {
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        Map<Id,Risk_status_Detail__c> listOfMerchantRec =  RiskManagementStatusController.getRecordTypeIdAndStatus(oppWithRiskRec);
        Test.stopTest();
        System.assertEquals(3, listOfMerchantRec.size());
        
    }    
    @isTest static void statusOfHoldType() {
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        Map<String,String> holdTypeStatus = RiskManagementStatusController.statusOfHoldType(oppWithRiskRec);
        Test.stopTest();
        
    }
    @isTest static void postRiskHistory() {
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        List<Risk_status_Detail__History> postRiskHistory = RiskManagementStatusController.postRiskHistory(oppWithRiskRec);
        Test.stopTest();
    }
    @isTest static void obRiskHistory() {
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        List<Risk_status_Detail__History> obRiskHistory = RiskManagementStatusController.obRiskHistory(oppWithRiskRec);
        Test.stopTest();
    }
    @isTest static void preRiskHistory() {
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        List<Risk_status_Detail__History> preRiskHistory = RiskManagementStatusController.preRiskHistory(oppWithRiskRec);
        Test.stopTest();
    }
    
    @isTest static void websitePages(){
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        list<Opportunity> result = RiskManagementStatusController.websitePages(oppWithRiskRec);
        Test.stopTest();
    }
    
    
    @isTest static void getPicklistValues(){
        Test.startTest();
        Map<String,String> webPagePickListValues = RiskManagementStatusController.getPicklistValues();
        Map<String,String> opportunityPickListValues = RiskManagementStatusController.getPicklistValuesOpp();
        Test.stopTest();
    }
    
    @isTest static void saveWebpageRecords(){
        Id webPageRecordId = [SELECT Id FROM Website_Page__c LIMIT 1].Id;
        Test.startTest();
        string websiteRecord = '[{"Availability__c": "Not Found","Approval_Type__c": "Approved","Pick_Risk_Remark__c": "","Id": "'+webPageRecordId+'"}]';
        RiskManagementStatusController.saveWebpageRecords(websiteRecord);
        Test.stopTest();
    }
    
    @isTest static void saveOppRecords(){
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        string opportunityRecord =  '[{"Pre_approved_for_EMI__c": "approved","Pre_approved_for_MCP__c": "pending","Max_Same_Day_Settlement_Amount__c": "100","Id": "'+oppWithRiskRec+'"}]';
        RiskManagementStatusController.saveOppRecords(opportunityRecord);
        Test.stopTest();
    }
    @isTest static void savewebsitepagerecord(){
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        //RiskManagementStatusController.savewebsitepagerecord(oppWithRiskRec,'Product','Test','Approved','Found');
        Test.stopTest();
    }
    @isTest static void savewebsitepagedata(){
        list<sobject> objrecord = [SELECT Id FROM Website_Page__c];
        // list<Sobject> objrecord=new list<Sobject>{Id=webPageRecordId,Risk_Remarks__c='test',Sales_Remarks__c='test'};
        Test.startTest();
        RiskManagementStatusController.savewebsitepagedata(objrecord);
        Test.stopTest();
    }
    
    @isTest static void updatewebsitepage(){
        Id webPageRecordId = [SELECT Id FROM Website_Page__c LIMIT 1].Id;
        string websiteRecord = '[{"Availability__c": "Not Found","Approval_Type__c": "Approved","Pick_Risk_Remark__c": "","Id": "'+webPageRecordId+'"}]';
        Test.startTest();
        RiskManagementStatusController.updatewebsitepage(websiteRecord);
        Test.stopTest();
    }
    
    @isTest static void websitepagegroup(){
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Test.startTest();
        RiskManagementStatusController.websitepagegroup(oppWithRiskRec);
        Test.stopTest();
    }
     @isTest static void saveWebsitepagegroup(){
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Website_Details__c webDetails = new Website_Details__c();
        webDetails.Opportunity__c = oppWithRiskRec;
        webDetails.Active__c = true;
        insert webDetails;
        
        Website_Page__c web = new Website_Page__c();
        web.Availability__c  = 'Found';
        web.Active__c = true;
        web.Approval_Type__c = 'Approved';
        web.Website_Details__c = webDetails.Id;
        web.Group__c = 'Product';
        web.Page_Details__c = '[{" ":" "}]';
        web.Opportunity__c = oppWithRiskRec;
        insert web;
        Test.startTest();
        RiskManagementStatusController.savewebsitepagerecord(oppWithRiskRec,'Product','Home Page','Approved','Found');
        Test.stopTest();
    }
    @isTest static void getMccCodeMetaData(){
        
        Test.startTest();
        RiskManagementStatusController.getMccCodeMetaData('4900',null);
        Test.stopTest();
    }  
     @isTest static void currentWebsitepage(){
        Id webPageId = [SELECT Id, Name FROM Website_Page__c WHERE Name = 'Product/Services Details' LIMIT 1].Id;
        Test.startTest();
        RiskManagementStatusController.currentWebsitepage(webPageId);
        Test.stopTest();
    }  
}