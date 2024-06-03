@isTest
public class PayUfeedbackControllerTracker {

    @testSetup static void setupCommonData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'Test',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '9090909090',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        system.runAs(u){
            Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new MockClass());
            
            Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
            insert triggerSwitchObj ;
            
            Entity__c entityObj = CommonDataTracker.insertEntity('Society');
            insert entityObj;
            System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
            
            Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
            accountObj.Business_Entity__c =  entityObj.Id;
            accountObj.Identifier__c = '9867587879089887';
            accountObj.Document_Status__c = 'Docs Approved';
            accountObj.LOB_Status__c = 'Approved';
            accountObj.Agreement_Status__c = 'Approved';
            accountObj.Dow_Jones_Status__c = 'Match Found';
            accountObj.Document_Status__c = 'Docs Approved';
            accountObj.Monthly_Expected_Sale__c = 200;
            accountObj.Delivery_Duration__c = 2;
            insert accountObj;
            System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockClass()); 
            
            Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            insert businessCategory;
            
            Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
            insert subCategory;
            
            Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj.BusinessCategory__c = businessCategory.id;
            opportunityObj.Prod_Merchant_Id__c = 789789;
            insert opportunityObj;
            
            System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
            Test.stopTest(); 
            
            Case csObj = New Case();
            csObj.TicketId__c = 'PORMS-0001';
            csObj.Payment_Id__c = '8767868,2131123';
            csObj.LP_Category__c = 'Test Category';
            csObj.LP_Sub_Category__c = 'Test Sub Category';
            csObj.LP_Transaction_Reason__c = 'Test hold reason';
            csObj.Subject = 'Test subjecrt';
            csObj.Merchant_Id__c = '789789';
            csObj.Opportunity__c = opportunityObj.Id;
            csObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
            insert csObj;
        }
    }
    
    public static testMethod void testData_1(){
        Opportunity opp = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Case csObj = [Select Id from Case LIMIT 1];
        Test.startTest();
        PayUfeedbackController.getWrapperData(csObj.Id);
        string wrapperObj = '{"caseObj":{"LP_Customer_Feedback__c":"Fair","Status":"Re-Open","Id":"5000p000004shHEAAY","LP_Customer_Sub_Feedback__c":"Response Quality;Expertise","LP_Customer_Comments__c":"csdc","Contact_Name__c":"SarvpriyaTest"},"message":"Feedback submitted."}';
        PayUfeedbackController.submitMerchantFeedback(wrapperObj, New List<String>{'Prosperity'}, 'Fair', '3');
        Test.stopTest();
    }
}