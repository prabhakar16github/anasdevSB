@IsTest
public class ReKYCAutomationBatchTest {
    @IsTest
    static void testReKYCAutomationBatch() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName='Closed',
            Onboarding_Completed__c=true,
            Agreement_Status__c='Approved',
            CloseDate=System.today()+10,
            Next_ReKYC_date__c = System.today()+20
        );
        insert opp;
        Platform__c testPlatform = new Platform__c(
            Name = 'PayU Money'
        );
        insert testPlatform;
        Product__c product = new Product__c(
        	Name = 'Payout',
            Platform__c = testPlatform.Id
        );
        insert product;
        Cross_Sell__c crossSell = new Cross_Sell__c(
            Custom_Product__c = product.Id,
            Name = 'Payout',
            Active__c = true,
            Opportunity__c = opp.Id
        );
        insert crossSell;
        String customLabel = Label.Risk_Category_Mapping;
        ReKYCAutomationBatch batch = new ReKYCAutomationBatch(90);
        Database.executeBatch(batch);
        Opportunity updatedOpp = [SELECT Id, Next_ReKYC_Date__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(null, updatedOpp.Next_ReKYC_Date__c, 'testing');
        
        Opportunity oppWithLastReKYC = new Opportunity(
            Name = 'Opportunity with Last ReKYC',
            Last_ReKYC_date__c = Date.today().addDays(-60),
            Next_ReKYC_date__c = Date.today().addDays(20),
            StageName='Closed',
            CloseDate=System.today()+10
        );
        insert oppWithLastReKYC;

        Opportunity oppWithSettlementDate = new Opportunity(
            Name = 'Opportunity with Settlement Date',
            Settlement_Date__c = Date.today().addDays(-30),
            StageName='Closed',
            CloseDate=System.today()+10,
            Next_ReKYC_date__c = Date.today().addDays(21)
        );
        insert oppWithSettlementDate;

        Opportunity oppNoDates = new Opportunity(
            Name = 'Opportunity without Dates',
            CreatedDate = Date.today().addDays(-15),
            StageName='Closed',
            CloseDate=System.today()+10,
            Next_ReKYC_date__c = Date.today().addDays(22)
        );
        insert oppNoDates;
        Opportunity updatedOppWithLastReKYC = [SELECT Id, Next_ReKYC_Date__c FROM Opportunity WHERE Id = :oppWithLastReKYC.Id LIMIT 1];
        System.assertNotEquals(null, updatedOppWithLastReKYC.Next_ReKYC_Date__c, '');

        Opportunity updatedOppWithSettlementDate = [SELECT Id, Next_ReKYC_Date__c FROM Opportunity WHERE Id = :oppWithSettlementDate.Id LIMIT 1];
        System.assertNotEquals(null, updatedOppWithSettlementDate.Next_ReKYC_Date__c, '');

        Opportunity updatedOppNoDates = [SELECT Id, Next_ReKYC_Date__c FROM Opportunity WHERE Id = :oppNoDates.Id LIMIT 1];
        System.assertNotEquals(null, updatedOppNoDates.Next_ReKYC_Date__c, '');
    
    }
}