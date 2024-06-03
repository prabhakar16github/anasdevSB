@isTest
public class CommentTriggerTracker {

    public static testMethod void testData1(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Comments__c', true);
        insert triggerSwitchObj ;
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accountObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = opportunityObj.Id;
        websiteObj.Active__c = true;
        insert websiteObj;
        
        Comments__c commentObj = CommonDataTracker.insertComment('testData', opportunityObj, websiteObj);
        insert commentObj;
        
        commentObj.Comment__c = 'adfaf';
        update commentObj;
    }
}