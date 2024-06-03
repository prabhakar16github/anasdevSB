@isTest
public class Batch_CSCreationForOpportunityTracker {
    
    public static testMethod void testData1(){
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Cross_Sell__c';
        insert osetting;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);   
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('Professional Services', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('Professional Services', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Matrimony', false);
        subCategoryInd.Category__c = businessCategoryNGO.Id;
        subCategoryInd.Delivery_duration__c = 5;
        insert subCategoryInd ;
        System.assertEquals('Matrimony', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Product__c csMCPProdObj = CommonDataTracker.insertCustomProduct('MCP', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csMCPProdObj;
        
        Product__c csISProdObj = CommonDataTracker.insertCustomProduct('T+0', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csISProdObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(acc);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.AccountId = acc.Id;
        opportunityObj.Prod_Merchant_Id__c = 123456;
        opportunityObj.Product__c  = prodObj.Id;
        opportunityObj.GMV_Latest_Date__c = date.today();
        opportunityObj.businessCategory__c = businessCategoryNGO.Id;
        opportunityObj.Sub_Category__c = subCategoryInd.Id;
        opportunityObj.Website_Status__c = 'Website OK';
        opportunityObj.Settlement_Status__c = 'Active';
        opportunityObj.CB_Ratio__c = 0.4;
        opportunityObj.Last_6_months_GMV__c = 200000.00;
        opportunityObj.First_Txn_date__c = Date.today() - 100;
        opportunityObj.Lead_Type__c = 'Merchant';
        insert opportunityObj;
        
        Cross_Sell__c csMCP = new Cross_Sell__c();
        csMCP.Opportunity__c = opportunityObj.Id;
        csMCP.Custom_Product__c = csMCPProdObj.Id;
        csMCP.Product_Name__c = 'PayU Money';
        csMCP.Source__c = 'Dashboard';
        csMCP.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csMCP.Risk_Status__c = 'Pending';
        csMCP.Risk_Rejection_Date__c = date.today();
        csMCP.Cross_Sell_Stop_Task_Creation__c = false;
        csMCP.Risk_Zone__c = 'Amber Zone';
        csMCP.Uploaded_by_dataloader__c = true;
        insert csMCP;
        
        Cross_Sell__c csIS = new Cross_Sell__c();
        csIS.Opportunity__c = opportunityObj.Id;
        csIS.Custom_Product__c = csISProdObj.Id;
        csIS.Product_Name__c = 'PayU Money';
        csIS.Source__c = 'Dashboard';
        csIS.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csIS.Risk_Status__c = 'Pending';
        csIS.Risk_Rejection_Date__c = date.today();
        csIS.Cross_Sell_Stop_Task_Creation__c = false;
        csIS.Risk_Zone__c = 'Amber Zone';
        csIS.Uploaded_by_dataloader__c = true;
        insert csIS;
        
        Test.startTest();
        Batch_CrossSellCreationForOpportunity csCreationOpp = new Batch_CrossSellCreationForOpportunity(false,opportunityObj);
        database.executeBatch(csCreationOpp);
        
        Batch_CrossSellCreationForOpportunity.getCSObjList(New List<Opportunity>{opportunityObj});
        Test.stopTest();
        
    }
    
    public static testMethod void testData2(){
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Cross_Sell__c';
        insert osetting;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);   
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('Professional Services', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('Professional Services', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Matrimony', false);
        subCategoryInd.Category__c = businessCategoryNGO.Id;
        subCategoryInd.Delivery_duration__c = 5;
        insert subCategoryInd ;
        System.assertEquals('Matrimony', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Product__c csMCPProdObj = CommonDataTracker.insertCustomProduct('MCP', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csMCPProdObj;
        
        Product__c csISProdObj = CommonDataTracker.insertCustomProduct('T+0', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csISProdObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(acc);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.AccountId = acc.Id;
        opportunityObj.Prod_Merchant_Id__c = 123456;
        opportunityObj.Product__c  = prodObj.Id;
        opportunityObj.GMV_Latest_Date__c = date.today();
        opportunityObj.businessCategory__c = businessCategoryNGO.Id;
        opportunityObj.Sub_Category__c = subCategoryInd.Id;
        opportunityObj.Website_Status__c = 'Website OK';
        opportunityObj.Settlement_Status__c = 'Active';
        opportunityObj.CB_Ratio__c = 0.4;
        opportunityObj.Last_6_months_GMV__c = 200000.00;
        opportunityObj.First_Txn_date__c = Date.today() - 100;
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.MCC_Code__c = '4321';
        insert opportunityObj;
        
        Cross_Sell__c csMCP = new Cross_Sell__c();
        csMCP.Opportunity__c = opportunityObj.Id;
        csMCP.Custom_Product__c = csMCPProdObj.Id;
        csMCP.Product_Name__c = 'PayU Money';
        csMCP.Source__c = 'Dashboard';
        csMCP.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csMCP.Risk_Status__c = 'Pending';
        csMCP.Risk_Rejection_Date__c = date.today();
        csMCP.Cross_Sell_Stop_Task_Creation__c = false;
        csMCP.Risk_Zone__c = 'Amber Zone';
        csMCP.Uploaded_by_dataloader__c = true;
        insert csMCP;
        
        Cross_Sell__c csIS = new Cross_Sell__c();
        csIS.Opportunity__c = opportunityObj.Id;
        csIS.Custom_Product__c = csISProdObj.Id;
        csIS.Product_Name__c = 'PayU Money';
        csIS.Source__c = 'Dashboard';
        csIS.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csIS.Risk_Status__c = 'Pending';
        csIS.Risk_Rejection_Date__c = date.today();
        csIS.Cross_Sell_Stop_Task_Creation__c = false;
        csIS.Risk_Zone__c = 'Amber Zone';
        csIS.Uploaded_by_dataloader__c = true;
        insert csIS;
        
        Test.startTest();
        Batch_CrossSellCreationForOpportunity csCreationOpp = new Batch_CrossSellCreationForOpportunity(true,opportunityObj);
        database.executeBatch(csCreationOpp);
        
        Test.stopTest();
        
    }
    
    public static testMethod void testData3(){
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Cross_Sell__c';
        insert osetting;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);   
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('Professional Services', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('Professional Services', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Matrimony', false);
        subCategoryInd.Category__c = businessCategoryNGO.Id;
        subCategoryInd.Delivery_duration__c = 5;
        insert subCategoryInd ;
        System.assertEquals('Matrimony', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        acc.Business_Category__c = businessCategoryNGO.Id;
        acc.Sub_Category__c = subCategoryInd.Id;
        insert acc;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Product__c csMCPProdObj = CommonDataTracker.insertCustomProduct('MCP', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csMCPProdObj;
        
        Product__c csISProdObj = CommonDataTracker.insertCustomProduct('T+0', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csISProdObj;
        
        Product__c csEMIProdObj = CommonDataTracker.insertCustomProduct('EMI', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert csEMIProdObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(acc);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.AccountId = acc.Id;
        opportunityObj.Prod_Merchant_Id__c = 123456;
        opportunityObj.Product__c  = prodObj.Id;
        opportunityObj.GMV_Latest_Date__c = date.today();
        opportunityObj.CB_Ratio__c = 0.4;
        opportunityObj.Last_6_months_GMV__c = 200000.00;
        opportunityObj.First_Txn_date__c = Date.today() - 100;
        opportunityObj.Lead_Type__c = 'Merchant';
        insert opportunityObj;
        
        Cross_Sell__c csMCP = new Cross_Sell__c();
        csMCP.Opportunity__c = opportunityObj.Id;
        csMCP.Custom_Product__c = csMCPProdObj.Id;
        csMCP.Product_Name__c = 'PayU Money';
        csMCP.Source__c = 'Dashboard';
        csMCP.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csMCP.Risk_Status__c = 'Pending';
        csMCP.Risk_Rejection_Date__c = date.today();
        csMCP.Cross_Sell_Stop_Task_Creation__c = false;
        csMCP.Risk_Zone__c = 'Amber Zone';
        csMCP.Uploaded_by_dataloader__c = true;
        insert csMCP;
        
        Cross_Sell__c csIS = new Cross_Sell__c();
        csIS.Opportunity__c = opportunityObj.Id;
        csIS.Custom_Product__c = csISProdObj.Id;
        csIS.Product_Name__c = 'PayU Money';
        csIS.Source__c = 'Dashboard';
        csIS.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csIS.Risk_Status__c = 'Pending';
        csIS.Risk_Rejection_Date__c = date.today();
        csIS.Cross_Sell_Stop_Task_Creation__c = false;
        csIS.Risk_Zone__c = 'Amber Zone';
        csIS.Uploaded_by_dataloader__c = true;
        insert csIS;
        
        Cross_Sell__c csEMI = new Cross_Sell__c();
        csEMI.Opportunity__c = opportunityObj.Id;
        csEMI.Custom_Product__c = csEMIProdObj.Id;
        csEMI.Product_Name__c = 'PayU Money';
        csEMI.Source__c = 'Dashboard';
        csEMI.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        csEMI.Risk_Status__c = 'Pending';
        csEMI.Risk_Rejection_Date__c = date.today();
        csEMI.Cross_Sell_Stop_Task_Creation__c = false;
        csEMI.Risk_Zone__c = 'Amber Zone';
        csEMI.Uploaded_by_dataloader__c = true;
        insert csEMI;
        
        Test.startTest();
        Batch_CrossSellCreationForOpportunity csCreationOpp = new Batch_CrossSellCreationForOpportunity(true,opportunityObj);
        database.executeBatch(csCreationOpp);
        
        Test.stopTest();
        
    }
}