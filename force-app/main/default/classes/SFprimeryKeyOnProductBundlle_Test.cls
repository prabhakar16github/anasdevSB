@isTest
public class SFprimeryKeyOnProductBundlle_Test {
    public static testmethod void SFprimeryKeyOnProductBundlle_Test(){
        Product_Bundle_Detail__c  prod  = new Product_Bundle_Detail__c ();
        prod.Pricing_Info_Json__c = 'pg1';
        prod.Product_Bundle_ID__c  = '3434';
        insert prod;
        Master_Pricing_Data__c  master1 = new Master_Pricing_Data__c ();
        master1.Salesforce_Primary_Key__c = 'pg1';
        master1.Product_Bundle_Detail__c = prod.Id;
        insert master1;    
        Master_Pricing_Data__c  master2 = new Master_Pricing_Data__c ();
        master2.Salesforce_Primary_Key__c = 'pg2';
        master2.Product_Bundle_Detail__c = prod.Id;
        insert master2;     
            
            }
}