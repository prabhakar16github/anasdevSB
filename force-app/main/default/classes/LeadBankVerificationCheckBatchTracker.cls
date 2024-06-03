@isTest
public class LeadBankVerificationCheckBatchTracker {

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
            Lead lead = new Lead(Status = 'New', Sub_Status__c = 'Not Contacted', LastName = 'Test Lead '+i, Email = 'testemail'+i+'@abc.com', MobilePhone = '9988776655', 
                                Product__c = prodObj.Id, Lead_Type__c = 'Merchant', LeadSource = 'Organic', Sub_Source__c = 'Chat', Company = 'test Co. '+i, PAN_Verification_Status__c = 'Success',
                                Legal_Name__c = 'Test Lead '+i, Business_Entity__c = entityObj.Id, PAN_Holder_Name__c = 'Test Lead '+i, PAN_Number__c = 'AAAAA1111A',
                                Sub_Category__c = subCategoryOthers.Id, GST_Number__c = '22AAAAA1111A1Z5', Delivery_Duration__c = 30, Merchant_Id__c=11111+i, Monthly_Expected_Sale__c = 30000,
                                BusinessCategory__c = businessCategoryOthers.Id, Business_Category_Other__c = otherBusCategory, Sub_Category_Other__c = otherSubCategory);
            leads.add(lead);
        }
        insert leads;
        System.assertEquals(20, leads.size());
    }
    
    @isTest static void testMethodOne() {
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Iteration_Count__c FROM Batch_Setting__mdt WHERE MasterLabel = 'LeadBankVerificationCheckBatch'];
        Test.startTest();
        LeadBankVerificationCheckBatch lbvcb = new LeadBankVerificationCheckBatch();
        Id batchId = Database.executeBatch(lbvcb);
        Test.stopTest();
    }
}