@isTest
public class LeadConvertBatchIdQueryBasicTracker {
	
    static testMethod void method1() {
        Lead newLead = new Lead(Status = 'New', Sub_Status__c = 'Not Contacted', LastName = 'Test Lead New', 
                                 Email = 'testemailNew@abc.com', MobilePhone = '8888776655', 
                                Product__c = null, Lead_Type__c = 'Merchant', LeadSource = 'Organic', 
                                 Sub_Source__c = 'Chat', Company = 'test Co.In ', 
                                 PAN_Verification_Status__c = 'Success', 
                                 Bank_Verification_Status__c = 'Success', GST_Number__c = '22AAAAA1111A1Z5', 
                                 Delivery_Duration__c = 30, Prod_Merchant_Id__c=2423423, Monthly_Expected_Sale__c = 30000);
         insert newLead;
        LeadConvertBatchIdQueryBasic lcb = new LeadConvertBatchIdQueryBasic((String) newLead.Id, 'ids');
        Id batchId = Database.executeBatch(lcb);
    }
}