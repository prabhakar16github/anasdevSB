@isTest
public class UserTriggerTracker{ 
    
    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('User', true);
        insert triggerSwitchObj ;
    }
    
    @isTest static void testMethodOne() {
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Test.startTest();
        user userObj = CommonDataTracker.insertUser(profileId);
        insert userObj;
        system.assertNotEquals(userObj.Id, null);        
        Test.stopTest();
    }
}