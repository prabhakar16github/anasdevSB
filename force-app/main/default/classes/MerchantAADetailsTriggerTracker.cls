@istest
public class MerchantAADetailsTriggerTracker {

    @istest static void testData_1(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Merchant_Auto_Approval_Details__c', true);
        insert triggerSwitchObj ;
        
        Merchant_Auto_Approval_Details__c maadObj = New Merchant_Auto_Approval_Details__c();
        insert maadObj;
        
        maadObj.Message__c = 'test message';
        update maadObj;
    }
}