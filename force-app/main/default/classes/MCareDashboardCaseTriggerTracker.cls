@isTest
public class MCareDashboardCaseTriggerTracker {
    
    @testSetup static void setupCommonData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Risk Operations User']; 
        User u = new User(Alias = 'standt', Email='abcdefg@xyz.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='qwertyuas@xyzx.com',Mcare_Case_assignment_Index__c = 1);
 
        Test.startTest();
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('MCare_Dashboard_Case__c', true);
        insert triggerSwitchObj ;
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('MCare_Dashboard_Case__c', true);
        insert enableUUIDObjObj;
        
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
        
        Lookup__c roundRobinSetting = new Lookup__c();
        roundRobinSetting.Name = 'McareDashboard';
        roundRobinSetting.Lookup_Type__c= 'Round Robin';
        roundRobinSetting.Lookup_Code__c = 'MCare_Dashboard_Case__c' ;
        roundRobinSetting.Lookup_Value__c = 'Round Robin';
        roundRobinSetting.Start_Index__c = 1;
        roundRobinSetting.Max_Index__c = 4;
        roundRobinSetting.Active__c = true;
        insert roundRobinSetting;
        Test.stopTest(); 
    }
    
    public static testMethod void testData_1(){
        //List<Mcare_Dashboard_Case_Round_Robin_Setting__c> customSetting = [SELECT Id]
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Status__c = 'Risk Hold';
        mCareObj.Risk_Hold_Reason__c = 'R1 - Phishing/Vishing attack';
        mCareObj.Approval_Status__c = 'Approved';
        mCareObj.Merchant_Email__c = 'test@test.com';
        mCareObj.OwnerId = '0057F000005HnDkQAK';
        Insert mCareObj;
        
    }
    
    public static testMethod void testData_2(){
        try{
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Status__c = 'New';
        mCareObj.No_of_Days_to_Whitelist__c = '5';
        mCareObj.Approval_Status__c = 'Approved';
        mCareObj.Merchant_Email__c = 'test@test.com';
        Insert mCareObj;
        
        mCareObj.Status__c = 'Recommend Whitelist';
        update mCareObj;
        
        Approval.ProcessWorkitemRequest approvedReq = New Approval.ProcessWorkitemRequest();
        approvedReq.setComments('Approving request.');
        approvedReq.setAction('Approve');
        //ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: mCareObj.id];
        //approvedReq.setWorkitemId(pItem.Id);
        Approval.ProcessResult result = Approval.process(approvedReq);
        
        MCare_Dashboard_Case__c mCareObj2 = New MCare_Dashboard_Case__c();
        mCareObj2.Merchant_Id__c = '98321432';
        mCareObj2.Product_Name__c = 'PayUmoney';
        mCareObj2.Status__c = 'New';
        mCareObj2.Merchant_Email__c = 'test@test.com';
        Insert mCareObj2;
        }catch(exception ex){}
    }
    
    public static testMethod void testData_3(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        oppObj.Prod_Merchant_Id__c = 9832109;
        update oppObj;
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Status__c = 'New';
        mCareObj.No_of_Days_to_Whitelist__c = '5';
        mCareObj.Merchant_Email__c = 'test@test.com';
        Insert mCareObj;
        
        mCareObj.Approval_Status__c = 'Approved';
        update mCareObj;
        
        mCareObj.Status__c = 'Risk Hold';
        mCareObj.Risk_Hold_Reason__c = 'R1 - Phishing/Vishing attack';
        update mCareObj;
        
        mCareObj.Status__c = 'Suspend';
        mCareObj.Risk_Hold_Reason__c = '';
        update mCareObj;
        
        mCareObj.Status__c = 'Terminate';
        update mCareObj;
        
        mCareObj.Status__c = 'Mark as Safe';
        update mCareObj;
        
        mCareObj.Status__c = 'Released';
        update mCareObj;
        
        mCareObj.Merchant_Id__c = '9832109';
        update mCareObj;
    }
    
    public static testMethod void testData_4(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Status__c = 'New';
        mCareObj.No_of_Days_to_Whitelist__c = '5';
        mCareObj.Merchant_Email__c = 'test@test.com';
        Insert mCareObj;
        
        mCareObj.Status__c = 'Mark as Safe';
        update mCareObj;
        
        MCare_Dashboard_Case__c mCareObj2 = New MCare_Dashboard_Case__c();
        mCareObj2.Merchant_Id__c = '98321432';
        mCareObj2.Product_Name__c = 'PayUmoney';
        mCareObj2.Status__c = 'New';
        mCareObj2.No_of_Days_to_Whitelist__c = '5';
        mCareObj2.Merchant_Email__c = 'test@test.com';
        Insert mCareObj2;
        
        MCare_Dashboard_Case__c mCareObj3 = New MCare_Dashboard_Case__c();
        mCareObj3.Merchant_Id__c = '98321432';
        mCareObj3.Product_Name__c = 'PayUmoney';
        mCareObj3.Status__c = 'New';
        mCareObj3.No_of_Days_to_Whitelist__c = '5';
        mCareObj3.Merchant_Email__c = 'test@test.com';
        Insert mCareObj3;
        
        MCare_Dashboard_Case__c mCareObj4 = New MCare_Dashboard_Case__c();
        mCareObj4.Merchant_Id__c = '98321432';
        mCareObj4.Product_Name__c = 'PayUmoney';
        mCareObj4.Status__c = 'New';
        mCareObj4.No_of_Days_to_Whitelist__c = '5';
        mCareObj4.Merchant_Email__c = 'test@test.com';
        Insert mCareObj4;
        
    }
    
    public static testMethod void testData_5(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,Product__c,ProductLabel__c FROM Opportunity LIMIT 1]; 
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Merchant_Id__c = '98321432';
        mCareObj.Product_Name__c = 'PayUmoney';
        mCareObj.Status__c = 'Risk Hold';
        mCareObj.Risk_Hold_Reason__c = 'R1 - Phishing/Vishing attack';
        mCareObj.Approval_Status__c = 'Approved';
        mCareObj.Merchant_Email__c = 'test@test.com';
        mCareObj.ANDX_Value__c = 343434344;
        mCareObj.OwnerId = '0057F000005HnDkQAK';
        Insert mCareObj;
        
    }
}