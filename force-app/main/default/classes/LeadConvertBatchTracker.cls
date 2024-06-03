@isTest
public class LeadConvertBatchTracker {
    
    @testSetup 
    static void setup() {
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
        insert triggerSwitchObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Business_Category__c businessCategoryInd = CommonDataTracker.insertBusinessCategory('Individual', true);
        businessCategoryInd.Categories_For__c = 'Partner';
        insert businessCategoryInd;
        System.assertEquals('Individual', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryInd.id].Name);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        String otherBusCategory = 'test other business-category';
        String otherSubCategory = 'test other sub-category';
        
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<20; i++){
            Lead lead = new Lead(Status = 'New', Sub_Status__c = 'Not Contacted', LastName = 'Test Lead '+i, 
                                 Email = 'testemail'+i+'@abc.com', MobilePhone = '9988776655', 
                                Product__c = prodObj.Id, Lead_Type__c = 'Merchant', LeadSource = 'Organic', 
                                 Sub_Source__c = 'Chat', Company = 'test Co. '+i, 
                                 PAN_Verification_Status__c = 'Success',
                                Legal_Name__c = 'Test Lead '+i, Business_Entity__c = entityObj.Id, 
                                 PAN_Holder_Name__c = 'Test Lead '+i, PAN_Number__c = 'AAAAA1111A', 
                                 Bank_Verification_Status__c = 'Success',
                                Sub_Category__c = subCategoryOthers.Id, GST_Number__c = '22AAAAA1111A1Z5', 
                                 Delivery_Duration__c = 30, Merchant_Id__c=11111+i, Monthly_Expected_Sale__c = 30000,
                                BusinessCategory__c = businessCategoryOthers.Id, 
                                 Business_Category_Other__c = otherBusCategory, Sub_Category_Other__c = otherSubCategory);
            leads.add(lead);
        }
        insert leads;
        System.assertEquals(20, leads.size());
        
        
    }
    
     static testMethod void testMethodOne() {
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Iteration_Count__c FROM Batch_Setting__mdt WHERE MasterLabel = 'LeadConvertBatch'];
        Test.startTest();
        List<Lead> lead = [Select Id,Lead_Type__c,Lead_Conversion_Failure_Message__c,Bank_Verification_Status__c,
                               LeadSource,PAN_Holder_Name__c,Prod_Merchant_Id__c,ProductLabel__c,
                               Product__c,Business_Entity__c,BusinessCategory__c,Integration_Type__c,Delivery_Duration__c,
                               Monthly_Expected_Sale__c,Legal_Name__c,Sub_Category__c,Status,Sub_Status__c 
                               from Lead where PAN_Number__c = 'AAAAA1111A' LIMIT 10];
        system.assertEquals(20, [SELECT count() FROM Lead]);
        
        Bank_Account_Detail__c ba = new Bank_Account_Detail__c();
        ba.Lead__c = lead[0].Id;
        ba.Verification_Status__c = 'Success';
        ba.Account_Holder_Name__c = 'test one ';
        ba.Account_Number__c = '22132323233';
        ba.Active__c = true;
        ba.Bank_Name__c = 'ICICI Bank';
        ba.IFSC_Code__c = 'icic0000021';
        insert ba;
         
         lead[0].Bank_Verification_Status__c = 'Pending';
         update lead[0];
         
         lead[1].LeadSource = '';
         update lead[1];
                  
         lead[3].PAN_Number__c = '';
         lead[3].PAN_Holder_Name__c = '';
         update lead[3];         
         
         lead[4].Business_Entity__c = null;
         update lead[4];
         
         lead[5].Monthly_Expected_Sale__c = null;
         lead[5].BusinessCategory__c = null;
         lead[5].Sub_Category__c = null;
         update lead[5];
         
         lead[6].Legal_Name__c = '';
         update lead[6];
         
         Lead newLead = new Lead(Status = 'New', Sub_Status__c = 'Not Contacted', LastName = 'Test Lead New', 
                                 Email = 'testemailNew@abc.com', MobilePhone = '8888776655', 
                                Product__c = null, Lead_Type__c = 'Merchant', LeadSource = 'Organic', 
                                 Sub_Source__c = 'Chat', Company = 'test Co.In ', 
                                 PAN_Verification_Status__c = 'Success', 
                                 Bank_Verification_Status__c = 'Success', GST_Number__c = '22AAAAA1111A1Z5', 
                                 Delivery_Duration__c = 30, Prod_Merchant_Id__c=2423423, Monthly_Expected_Sale__c = 30000);
         insert newLead;
        System.assertEquals(1, [Select id from Bank_Account_Detail__c where Id=:ba.Id].size());
        system.assertEquals(1, [SELECT count() FROM Bank_Account_Detail__c]);
        LeadConvertBatch lcb = new LeadConvertBatch();
        Id batchId = Database.executeBatch(lcb);
       //  lcb.hasNext();
       // lcb.next();
       // lcb.Iterator();
        Test.stopTest();
        //system.assertEquals(batchSetting.Iteration_Count__c, [SELECT count() FROM Lead WHERE isConverted=true]);
    }
    
    
    static testMethod void testMethodTwo() {
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Iteration_Count__c FROM Batch_Setting__mdt WHERE MasterLabel = 'LeadConvertBatch'];
        Test.startTest();
        List<Lead> lead = [Select Id,Lead_Type__c,Lead_Conversion_Failure_Message__c,Bank_Verification_Status__c,
                               LeadSource,PAN_Holder_Name__c,Prod_Merchant_Id__c,ProductLabel__c,
                               Product__c,Business_Entity__c,BusinessCategory__c,Integration_Type__c,Delivery_Duration__c,
                               Monthly_Expected_Sale__c,Legal_Name__c,Sub_Category__c,Status,Sub_Status__c 
                               from Lead where PAN_Number__c = 'AAAAA1111A' LIMIT 5];
        system.assertEquals(20, [SELECT count() FROM Lead]);
        
        lead singlLead = lead[0];
        singlLead.Bank_Verification_Status__c = 'Pending';
        singlLead.Prod_Merchant_Id__c = 342324324;
        update singlLead;
        
        Bank_Account_Detail__c ba = new Bank_Account_Detail__c();
        ba.Lead__c = singlLead.Id;
        ba.Verification_Status__c = 'Success';
        ba.Account_Holder_Name__c = 'test one ';
        ba.Account_Number__c = '22132323233';
        ba.Active__c = true;
        ba.Bank_Name__c = 'ICICI Bank';
        ba.IFSC_Code__c = 'icic0000021';
        insert ba;
        
        System.assertEquals(1, [Select id from Bank_Account_Detail__c where Id=:ba.Id].size());
        system.assertEquals(1, [SELECT count() FROM Bank_Account_Detail__c]);
        LeadConvertBatch lcb = new LeadConvertBatch();
        Id batchId = Database.executeBatch(lcb);
        //lcb.hasNext();
        //lcb.next();
        //lcb.Iterator();
        Test.stopTest();
        //system.assertEquals(batchSetting.Iteration_Count__c, [SELECT count() FROM Lead WHERE isConverted=true]);
    }
        
}