@isTest
public class CrossSellTriggerHandlerTracker {
    @isTest
    public static void testMethod1(){
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Cross_Sell__c';
        insert osetting;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);   
        
        /*Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj;*/
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Platform__c platform = new Platform__c();
        platform.Name = 'Test';
        insert platform;
        
        Product__c prod = new Product__c();
        prod.Name = 'PayU Money';
        prod.Platform__c = platform.Id;
        insert prod;
        
        Product__c prod2 = new Product__c();
        prod2.Name = 'MCP';
        prod2.Platform__c = platform.Id;
        insert prod2;
        
        Contact conObj = New Contact();
        conObj.LastName = 'last name';
        conObj.AccountId = acc.Id;
        insert conObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(acc);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.AccountId = acc.Id;
        opportunityObj.Prod_Merchant_Id__c = 123456;
        opportunityObj.Product__c  = prod.Id;
        opportunityObj.GMV_Latest_Date__c = date.today();
        insert opportunityObj;
        
        /*Product__c prod = new Product__c();
        prod.Name = 'Testing';
        prod.Platform__c = platformObj.Id;
        insert prod;
        System.debug('prodId>>>'+prod.Id);*/
        
        Task objTask = New Task();
        objTask.Subject = 'Cross-Sell Task for Product Approval';
        objTask.WhatId = opportunityObj.Id;
        insert objTask;
        
        Cross_Sell__c cs = new Cross_Sell__c();
        //cs.Care_Status__c = 'Not Interested';
        cs.Opportunity__c = opportunityObj.Id;
        cs.Custom_Product__c = prod2.Id;
        cs.Product_Name__c = 'PayU Money';
        cs.Source__c = 'Dashboard';
        cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        cs.Risk_Status__c = 'Pending';
        cs.Risk_Rejection_Date__c = date.today();
        cs.Cross_Sell_Stop_Task_Creation__c = false;
        cs.Risk_Zone__c = 'Amber Zone';
        cs.Uploaded_by_dataloader__c = true;
        insert cs;
        
        //cs.Kam_Status__c = 'Merchant Accepted';
        cs.Risk_Status__c = 'Rejected';
        cs.Risk_Rejection_Date__c = date.today();
        cs.Cross_Sell_Stop_Task_Creation__c = false;
        cs.Care_Status__c = 'Interested';
        update cs;
        cs.Kam_Status__c = 'Merchant Accepted';
        cs.Risk_Status__c = 'Approved';
        cs.Risk_Rejection_Date__c = date.today();
        cs.Cross_Sell_Stop_Task_Creation__c = false;
        cs.Care_Status__c = 'Interested';
        cs.Source__c = 'Active Merchant';
        update cs;
        cs.Risk_Status__c = 'Re-Evaluate';
        update cs;
        
        Cross_Sell__c cs2 = new Cross_Sell__c();
        //cs2.Care_Status__c = 'Interested';
        cs2.Opportunity__c = opportunityObj.Id;
        cs2.Custom_Product__c = prod2.Id;
        cs2.Risk_Status__c = 'Rejected';
        cs2.Risk_Rejection_Date__c = date.today();
        cs2.Cross_Sell_Stop_Task_Creation__c = false;
        cs2.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
        
        //insert cs2;
        
        Merchant_Document__c MerchantDocumentObj = new Merchant_Document__c();
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Account__c= acc.Id;
        MerchantDocumentObj.URL__c = 'www.google.com';
        MerchantDocumentObj.Cross_Sell__c = cs.Id;
        MerchantDocumentObj.Onboarding_Status__c = 'Received';
        MerchantDocumentObj.KYC_Documentable_Type__c = 'Merchant consent crossSell';
        insert MerchantDocumentObj;
        
        //cs.Care_Status__c = 'Interested';
        cs.Risk_Status__c = 'Need More Information';
        update cs;
        
        String bodyStr = 'sdfghxdfcgv';
        Attachment att=new Attachment();
        att.Body=Blob.valueOf(bodyStr);
        att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
        att.parentId=opportunityObj.id;
        insert att;
        List<Attachment> attList = new List<Attachment>();
        attList.add(att);
        CrossSellTriggerHandler.updateTaskPriority(cs,'update');
        CrossSellTriggerHandler.sendEmailCommonMethod('PayU Instant Settlement', 'Request Email to Risk Team','Pre_Onboarding_Risk_Team', attList);
        
        cs.Risk_Status__c = 'Approved';
        cs.Kam_Status__c = 'Merchant Accepted';
        cs.Active__c = True;
        update cs;
    }
    

}