@isTest
public class PublishOtherProductApi_Test {
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
        List<Other_Product_Pricing__c> otherList = new List<Other_Product_Pricing__c>();
        Other_Product_Pricing__c  other1 = new Other_Product_Pricing__c();
        other1.Opportunity__c = opp.Id;
        other1.Card_Type__c = 'domestic';
        other1.Valid_From__c = SYstem.today();
        other1.Ibibo_Code__c = 'inbiboTest';
        other1.Valid_Till__c = SYstem.today();
        other1.Scheme__c = 'DINR';
        other1.PG_Id__c = '1234';
        other1.ONUS__c = '0';
        other1.Mode__c = 'creditCard';
        other1.Need_to_Publish__c = True;
		otherList.add(other1);
        Other_Product_Pricing__c  other2 = new Other_Product_Pricing__c();
        other2.Opportunity__c = opp.Id;
        other2.Need_to_Publish__c = True;
        other2.Card_Type__c = 'domestic';
        other2.Valid_From__c = SYstem.today();
        other2.Valid_Till__c = SYstem.today();
        other2.Ibibo_Code__c = 'inbiboTest';
        other2.Mode__c = 'creditCard';
        other2.Scheme__c = 'DINR';
        other2.PG_Id__c = '1234';
        other2.ONUS__c = '0';
        otherList.add(other2);
        Insert otherList; 
        
     
    }
    @isTest
    static void test1(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        List<RecordTYpe> recordTypeList = [SELECT ID,Name,developername FROM RecordType WHERE developername='Instant_Settlement'];
        List<Other_Product_Pricing__c> commList = [SELECT Id,Name,recordType.Name,Opportunity__c FROM Other_Product_Pricing__c LIMIT 1];
        PublishOtherProductApi_CTRL.otherProductPricingToTreasury(oppList[0].Id,recordTypeList[0].developername);
        PublishOtherProductApi_CTRL.deleteProductPricingFromTreasury(String.valueOf(commList[0].Id));
    }
   
}