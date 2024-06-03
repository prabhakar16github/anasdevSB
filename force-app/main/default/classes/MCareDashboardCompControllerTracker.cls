@isTest
public class MCareDashboardCompControllerTracker {
    
    @testSetup static void setupCommonData(){
        Test.startTest();
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
                
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Prod_Merchant_Id__c = 98321432;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Test.stopTest(); 
    }
    
    public static testMethod void testData_1(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        Insert mCareObj;
        MCareDashboardCompController.getMCareDashboardData(mCareObj.Id);
        MCareDashboardCompController.getMerchantStatus('MCare_Dashboard_Case__c','Status__c');
        MCareDashboardCompController.getBusinessCategory();
        MCareDashboardCompController.getFieldHelpText('MCare_Dashboard_Case__c');
        MCareDashboardCompController.getDependentMap('MCare_Dashboard_Case__c', 'Desposition_L1__c', 'Desposition_L2__c');
        
        string wrapperObj = '{"MCareDashboardCaseObj":{"Business_Origin__c":"SMB-ENT","ANDX_Value__c":1514164,"Merchant_Id__c":"7601561","Merchant_URL__c":"payu.in","Estimated_Hours__c":"24","From_Address__c":"riskemailsender@payu.in","Priority__c":"High","Credit_Risk_Rating__c":"D","Reason__c":"POMMRO3","Description__c":"Test 2 post onboarding merchant risk monitoring - SMB","Due_Date__c":"2021-06-05","Merchant_Age__c":"Years:3 Months:0 Days:25","Merchant_Legal_Name__c":"Ashish","Last_Transaction_Date__c":"2020-03-24","Subject__c":"Test Subject 7601561","Delivery_duration__c":"9","Start_Date__c":"2021-09-03","Sub_Category__c":"Ecommerce","Product_Name__c":"One PayU","Merchant_Email__c":"shivdeep.test1@test.in","Tracker_Id__c":"Merchant Risk Monitoring","FNDX_Value__c":4,"Project_Id__c":"Post On-boarding Merchant","Created_Internally__c":false,"Id":"a2H0p000000g6A3EAI","Status__c":"New","Risk_Rating__c":"E"},"userCurrentTheme":"Theme4d"}';
    	MCareDashboardCompController.saveDashboardData(wrapperObj, false, false, true, 'Test Project', false, null);
    }
    
    public static testMethod void testData_2(){
        MCareDashboardCompController.getMCareDashboardData(null);
        MCareDashboardCompController.saveDashboardData(null, false, false, true, 'Test Project', false, null);
    }
    
    public static testMethod void testData_3(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        Case caseObj =new Case();
        caseObj.ContactId=conObj.id;
        caseObj.AccountId=accObj.id;
        caseObj.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert caseObj;
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Case__c = caseObj.Id;
        Insert mCareObj;
        
        MCareDashboardCompController.getMCareDashboardData(caseObj.Id);
        
        mCareObj.Status__c = 'Risk Hold';
        update mCareObj;
        
        string wrapperObj = '{"MCareDashboardCaseObj":{"Business_Origin__c":"SMB-ENT","ANDX_Value__c":1514164,"Merchant_Id__c":"7601561","Merchant_URL__c":"payu.in","Estimated_Hours__c":"24","From_Address__c":"riskemailsender@payu.in","Priority__c":"High","Credit_Risk_Rating__c":"D","Reason__c":"POMMRO3","Description__c":"Test 2 post onboarding merchant risk monitoring - SMB","Due_Date__c":"2021-06-05","Merchant_Age__c":"Years:3 Months:0 Days:25","Merchant_Legal_Name__c":"Ashish","Last_Transaction_Date__c":"2020-03-24","Subject__c":"Test Subject 7601561","Delivery_duration__c":"9","Start_Date__c":"2021-09-03","Sub_Category__c":"Ecommerce","Product_Name__c":"One PayU","Merchant_Email__c":"shivdeep.test1@test.in","Tracker_Id__c":"Merchant Risk Monitoring","FNDX_Value__c":4,"Project_Id__c":"Post On-boarding Merchant","Created_Internally__c":false,"Id":"a2H0p000000g6A3EAI","Status__c":"Risk Hold","Risk_Rating__c":"E"},"userCurrentTheme":"Theme4d"}';
    	MCareDashboardCompController.saveDashboardData(wrapperObj, false, false, true, 'Test Project', false, null);
        
    }
}