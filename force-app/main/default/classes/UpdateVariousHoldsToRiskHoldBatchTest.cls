@isTest
public class UpdateVariousHoldsToRiskHoldBatchTest {
@testSetup static void setup() {
        Account accForOppWithAnyRiskHold = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithAnyRiskHold;
            
        Opportunity oppWithAnyRiskHold = CommonDataTracker.insertOpportunity(accForOppWithAnyRiskHold);
        oppWithAnyRiskHold.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
    	oppWithAnyRiskHold.Settlement_Status__c = 'OB Hold';
        insert oppWithAnyRiskHold;
    
    	Account accForOppWithAnyRiskHold2 = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithAnyRiskHold2;
            
        Opportunity oppWithAnyRiskHold2 = CommonDataTracker.insertOpportunity(accForOppWithAnyRiskHold);
        oppWithAnyRiskHold2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
    	oppWithAnyRiskHold2.Settlement_Status__c = 'Risk Hold';
        insert oppWithAnyRiskHold2;
    
    	Account accForOppWithAnyRiskHold3 = CommonDataTracker.insertAccount('Test Account3', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithAnyRiskHold3;
            
        Opportunity oppWithAnyRiskHold3 = CommonDataTracker.insertOpportunity(accForOppWithAnyRiskHold);
        oppWithAnyRiskHold3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
    	oppWithAnyRiskHold3.Settlement_Status__c = 'Pre-Risk Hold';
        insert oppWithAnyRiskHold3;
    
	}
    
    @isTest static void updateOBHoldtoHoldTest(){
        
        Test.startTest();
        	Database.executeBatch(new UpdateVariousHoldsToRiskHoldBatch('OB Hold'));
        Test.stopTest();
    }
    @isTest static void updateRiskHoldtoHoldTest(){
        
        Test.startTest();
        	Database.executeBatch(new UpdateVariousHoldsToRiskHoldBatch('Risk Hold'));
        Test.stopTest();
    }
    @isTest static void updatePreRisktoHoldTest(){
        
        Test.startTest();
        	Database.executeBatch(new UpdateVariousHoldsToRiskHoldBatch('Pre-Risk Hold'));
        Test.stopTest();
    }
}