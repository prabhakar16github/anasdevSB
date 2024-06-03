@isTest
public class ActionToCallPlatformAndFallBack_Test {
    static testMethod void test1(){
        // Create test data - you may need to create required records and data as per your org's schema
         Commercial2__c testCommercial = new Commercial2__c(Status__c = 'Live');
        insert testCommercial; Platform_Fee__c testPlatformFee = new Platform_Fee__c(Commercial__c = testCommercial.Id, Need_To_Publish__c = TRUE);
        insert testPlatformFee;
        Fallback_Charge__c testFallbackCharge = new Fallback_Charge__c(Commercial__c = testCommercial.Id, Need_To_Publish__c = TRUE);
        insert testFallbackCharge;
        Fixed_Pricing1__c fixed = new Fixed_Pricing1__c();
        fixed.Amount__c = 100;
        fixed.Commercial__c = testCommercial.Id;
        fixed.Need_To_Publish__c = true;
        insert fixed;
        
        // Set the page reference and parameters
         PageReference pageRef = Page.PlatformAndFallBack; 
        // Replace with your VF page name
         Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', testCommercial.Id);
        // Call the controller
         ApexPages.StandardController sc = new ApexPages.StandardController(testCommercial);
        ActionToCallPlatformAndFallBack_CTRL controller = new ActionToCallPlatformAndFallBack_CTRL(sc);
        controller.executeDml();
        // Assert that the messages were added as expected
         //List messages = ApexPages.getMessages();
        //System.assertEquals(2, messages.size());
        // You may need to adjust this based on your actual logic
    }
}