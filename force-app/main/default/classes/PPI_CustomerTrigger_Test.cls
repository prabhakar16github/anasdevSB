@isTest
public class PPI_CustomerTrigger_Test {
    
	@isTest
    static void test1(){
        
        Trigger_Switch__c tr = new Trigger_Switch__c();
        tr.Name = 'PPI_Customer__c';
        tr.Active__c = true;
        insert tr;
        
        Map<String,String> clientIdToMIDMap = (Map<String,String>)JSON.deserialize(System.label.PPI_Client_Id_To_MID_Mapping,Map<String,String>.class);
        Opportunity opp = new Opportunity();
        opp.Name = clientIdToMIDMap.values()[0];
        opp.StageName = 'Active';
        opp.CloseDate = System.today().addDays(30);
        insert opp;
        
        PPI_Customer__c co = new PPI_Customer__c();
        co.Customer_Id__c = '1234';
        co.Client_Id__c = '12345640';
        co.Merchant__c = opp.Id;
        insert co;
    }
}