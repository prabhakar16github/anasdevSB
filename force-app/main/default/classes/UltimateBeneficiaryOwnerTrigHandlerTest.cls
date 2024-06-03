/*@isTest
public class UltimateBeneficiaryOwnerTrigTracker {
@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Ultimate_Beneficiary_Owner_UBO__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Ultimate_Beneficiary_Owner_UBO__c UBOScoreObj = new Ultimate_Beneficiary_Owner_UBO__c();
        UBOScoreObj.UUID__c = '11ed-3e37-a92d18a2-993a-02053299b2da';

        insert UBOScoreObj;
        System.assertEquals('11ed-3e37-a92d18a2-993a-02053299b2da', [SELECT id, UUID__c FROM Ultimate_Beneficiary_Owner_UBO__c WHERE Id =: UBOScoreObj.Id].UUID__c);    
        
        Test.stopTest();
    }

}*/

@isTest
private class UltimateBeneficiaryOwnerTrigHandlerTest {
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Ultimate_Beneficiary_Owner_UBO__c', true);
        insert triggerSwitchObj ;        
    }

    @isTest
    static void testBeforeInsertHandler() {
        // Create test data
        //Enable_UUID_Objects__c enableUUIDObj = new Enable_UUID_Objects__c(); 
        
        //insert enableUUIDObj;

        List<Ultimate_Beneficiary_Owner_UBO__c> testRecords = new List<Ultimate_Beneficiary_Owner_UBO__c>();
        for (Integer i = 0; i < 5; i++) {
            Ultimate_Beneficiary_Owner_UBO__c ubo = new Ultimate_Beneficiary_Owner_UBO__c(
                //Merchant_UUID__c = '8569750',
                //uuid__c = '11ed-7cfe-4470e866-b904-025dcc012560' + i,
                Ownership_num__c = 20 
            );
            testRecords.add(ubo);
        }
        if(testRecords.size()>0) insert testRecords;

        Test.startTest();

        // Call the beforeInsertHandler method
        UltimateBeneficiaryOwnerTrigHandler.beforeInsertHandler(testRecords);

        Test.stopTest();

        // Perform assertions based on your test logic
        // Example assertions:
        for (Ultimate_Beneficiary_Owner_UBO__c ubo : testRecords) {
            System.assertEquals(ubo.uuid__c, ubo.Identifier__c);
            // Add more assertions as needed
        }
    }
}