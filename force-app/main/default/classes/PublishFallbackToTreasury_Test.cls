@isTest
public class PublishFallbackToTreasury_Test {
	 @testSetup
    static void dataSetupMethod(){
        Opportunity opp = New Opportunity();
        opp.Name='test1';
        opp.Email__c='test@test.com';
        opp.StageName='MAF';
        opp.CloseDate=Date.today();
        insert opp;
        
        Commercial2__c com = new Commercial2__c();
        com.Status__c = 'Draft';
        com.Opportunity__c = opp.Id;
        insert com;
        
        Payment_Mode__c mode = new Payment_Mode__c();
        mode.Name = 'Credit Card';
        insert mode;
        
        List<Fallback_Charge__c> fallList = new List<Fallback_Charge__c>();
 		Fallback_Charge__c  fallBack1 = new Fallback_Charge__c();
        fallBack1.Commercial__c  = com.Id;
        fallBack1.Need_to_Publish__c	 = true;
        fallList.add(fallBack1);
        Fallback_Charge__c  fallBack2 = new Fallback_Charge__c();
        fallBack2.Commercial__c  = com.Id;
        fallBack2.Need_to_Publish__c	 = true;
        fallList.add(fallBack2);
        insert fallList;
    }
    @isTest
    static void test1(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        List<Commercial2__c> commList = [SELECT Id,Name,Opportunity__c FROM Commercial2__c LIMIT 1];
        System.assertEquals(oppList[0].Id,commList[0].Opportunity__c);
        PublishFallbackToTreasury_CTRL.FallBackToTreasury(commList[0].Id);
    }
}