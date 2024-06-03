@isTest
public class RiskStatusDetailHandlerTest {
    
    @testSetup static void setup() {
        Account accForOppWithAnyRiskHold = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accForOppWithAnyRiskHold;
        
        Opportunity oppWithAnyRiskHold = CommonDataTracker.insertOpportunity(accForOppWithAnyRiskHold);
        oppWithAnyRiskHold.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert oppWithAnyRiskHold;
        
        Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
        Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
        Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
        List<Risk_status_Detail__c> lstRsd = new List<Risk_status_Detail__c>();
        
        // Populate the Risk_status_Detail__c records and set the Unique_Identifier__c field(add due to SFI-841)
        for (Integer i = 1; i <= 3; i++) {
            Risk_status_Detail__c rsd = new Risk_status_Detail__c();
            rsd.Opportunity__c = oppWithAnyRiskHold.Id;
            
            if (i == 1) {
                rsd.RecordTypeId = postTypeId;
                rsd.Current_Status__c = 'On Hold';
            } else if (i == 2) {
                rsd.RecordTypeId = obTypeId;
                rsd.Current_Status__c = 'On Hold';
            } else if (i == 3) {
                rsd.RecordTypeId = preTypeId;
                rsd.Current_Status__c = 'On Hold';
            }
            
            // Set the Unique_Identifier__c
            rsd.Unique_Identifier__c = rsd.Hold_Type__c + '@@' + rsd.Opportunity__c;
            lstRsd.add(rsd);
        }
        
        insert lstRsd; 
    }
    
    @isTest static void beforeUpdateRSDPostOnHold() {
        Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Risk_status_Detail__c resultPostRec = [SELECT Id, RecordTypeId, Current_Status__c, Unique_Identifier__c FROM Risk_status_Detail__c 
                                               WHERE RecordTypeId = :postTypeId AND Opportunity__c = :oppWithRiskRec LIMIT 1];
        
        resultPostRec.Current_Status__c = 'On Hold';
        Test.startTest();
        update resultPostRec;
        Test.stopTest();
    }
    
    @isTest static void beforeUpdateRSDONObHold() {
        Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Risk_status_Detail__c resultOBRec = [SELECT Id, RecordTypeId, Current_Status__c, Unique_Identifier__c FROM Risk_status_Detail__c 
                                             WHERE RecordTypeId = :obTypeId AND Opportunity__c = :oppWithRiskRec LIMIT 1];
        
        resultOBRec.Current_Status__c = 'On Hold';
        Test.startTest();
        update resultOBRec;
        Test.stopTest();
    }
    
    @isTest static void beforeUpdateRSDPreONHold() {
        Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Risk_status_Detail__c resultPreRec = [SELECT Id, RecordTypeId, Current_Status__c, Unique_Identifier__c, Released_By__c, Release_Date__c  FROM Risk_status_Detail__c 
                                              WHERE RecordTypeId = :preTypeId AND Opportunity__c = :oppWithRiskRec LIMIT 1];
        
        resultPreRec.Current_Status__c = 'On Hold';
        
        Test.startTest();
        update resultPreRec;
        Test.stopTest();
    }
    
    @isTest static void beforeUpdateRSDPreNotONHold() {
        Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
        Id oppWithRiskRec = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Account.Name = 'Test Account2' LIMIT 1].Id;
        Risk_status_Detail__c resultPreRec = [SELECT Id, RecordTypeId, Current_Status__c, Unique_Identifier__c, Released_By__c, Release_Date__c  FROM Risk_status_Detail__c 
                                              WHERE RecordTypeId = :preTypeId AND Opportunity__c = :oppWithRiskRec LIMIT 1];
        
        resultPreRec.Current_Status__c = 'Not On Hold';
        
        Test.startTest();
        update resultPreRec;
        Test.stopTest();
    }
}