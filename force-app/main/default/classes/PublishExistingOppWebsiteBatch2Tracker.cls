@isTest
public class PublishExistingOppWebsiteBatch2Tracker {

    public static testMethod void data1(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', '12345');
        accountObj.PAN_Number__c='wedds2323e';
        insert accountObj;
        system.debuG(accountObj);
        System.assertEquals('Test Account', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Website__c = 'tetshelp.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        opportunityObj.Website_Status__c='Website Error';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c wp1 = New Website_Page__c();
        wp1.Opportunity__c = opportunityObj.Id;
        wp1.Name = 'test';
        insert wp1;
        Website_Page__c wp2 = New Website_Page__c();
        wp2.Opportunity__c = opportunityObj.Id;
        wp2.Name = 'test2';
        insert wp2;
        Website_Page__c wp3 = New Website_Page__c();
        wp3.Opportunity__c = opportunityObj.Id;
        wp3.Name = 'test3';
        insert wp3;
        Website_Page__c wp4 = New Website_Page__c();
        wp4.Opportunity__c = opportunityObj.Id;
        wp4.Name = 'test4';
        insert wp4;
        Database.executeBatch(new PublishExistingOppotunityWebsiteBatch2());
        Test.stopTest();
    }
    
    public static testMethod void data2(){
        Test.startTest();
        Account accountObj = CommonDataTracker.InsertAccount('Test Account2', 'Legal2', '122345');
        accountObj.PAN_Number__c='wedds2323e';
        insert accountObj;
        system.debuG(accountObj);
        System.assertEquals('Test Account2', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Integration_Type__c = 'Tools';
        opportunityObj.Website_Status__c='Website Error';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c wp1 = New Website_Page__c();
        wp1.Opportunity__c = opportunityObj.Id;
        wp1.Name = 'test';
        insert wp1;
        Website_Page__c wp2 = New Website_Page__c();
        wp2.Opportunity__c = opportunityObj.Id;
        wp2.Name = 'test2';
        insert wp2;
        Website_Page__c wp3 = New Website_Page__c();
        wp3.Opportunity__c = opportunityObj.Id;
        wp3.Name = 'test3';
        insert wp3;
        Website_Page__c wp4 = New Website_Page__c();
        wp4.Opportunity__c = opportunityObj.Id;
        wp4.Name = 'test4';
        insert wp4;
        
    	Database.executeBatch(new PublishExistingOppotunityWebsiteBatch2());
        Test.stopTest();
    }
}