@isTest
public class ProductAccountDetailTriggerTracker {

    public static testMethod void testData1(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Product_Account_Detail__c', true);
        insert triggerSwitchObj;
        
        Product_Account_Detail__c pad = New Product_Account_Detail__c();
        insert pad;
        
        pad.Anti_Money_Laundering__c = true;
        update pad;
    }
}