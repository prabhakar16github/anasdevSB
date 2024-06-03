/*
 * Created Date: 21 Dec 2020
 * Created By: Sneha Sahi
 * Description: To cover the code coverage of Batch_SendNeoBankingLeads and Batch_updateNeoBankingAccounts class. 
 * 
 * */
@isTest
public class Batch_SendNeoBankingLeadsTracker {
    @isTest
    public static void SendLeadsTest(){
        
        Trigger_Switch__c  logIntiator = new Trigger_Switch__c();
        logIntiator.Name = 'Case';
        logIntiator.Active__c = true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case caseObj = new Case();
        caseObj.AccountId = acc.Id;
        caseObj.contactId = oContact.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NeoBanking').getRecordTypeID();
        caseObj.ticketID__c = '123456';
        caseObj.Status = 'Lead sent to RBL';
        caseObj.Merchant_Id__c = '654321';
        insert caseObj;
        
        caseObj.Customer_phone_number__c = '987654321';
        caseObj.Customer_POC_Name__c = 'Test';
        caseObj.Customer_Pin_Code__c = '12211';
        caseObj.Initial_Cheque_Value__c = 1234;
        caseObj.Status = 'Open';
        update caseObj;
        
        Test.startTest();
       	//Batch_SendNeoBankingLeads Batch = new Batch_SendNeoBankingLeads();
        //Database.executeBatch(Batch);
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateLeadsTest(){
        
        Trigger_Switch__c  logIntiator = new Trigger_Switch__c();
        logIntiator.Name = 'Case';
        logIntiator.Active__c = true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.Lead_Created_date__c = null;
        //opp2.Product__c = prod.Id;
        insert opp2;
        
        Case caseObj = new Case();
        caseObj.AccountId = acc.Id;
        caseObj.contactId = oContact.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NeoBanking').getRecordTypeID();
        caseObj.ticketID__c = '123456';
        caseObj.Status = 'Lead sent to RBL';
        caseObj.Merchant_Id__c = '654321';
        insert caseObj;
        
        caseObj.Customer_phone_number__c = '987654321';
        caseObj.Customer_POC_Name__c = 'Test';
        caseObj.Customer_Pin_Code__c = '12211';
        caseObj.Initial_Cheque_Value__c = 1234;
        caseObj.Status = 'Open';
        update caseObj;
        
        caseObj.status = 'Lead sent to RBL';
        caseObj.LP_Sub_Status__c = 'Merchant is preparing docs';
        caseObj.isBulkUpdateSent__c = false;
        caseObj.Opportunity__c = opp2.id;
        caseObj.Identifier__c = '123456';
        caseObj.OwnerShip__c = 'RBL RM';
        caseObj.RBL_RM_Contact_Number__c = '3456789009';
        caseObj.RBL_Relationship_Manager_Name__c = 'Testing';
        caseObj.Account_Login_Date__c = Date.today();
        caseObj.Account_Opening_Date__c = Date.today();
        update caseObj;
        
        
        Test.startTest();
       	Batch_updateNeoBankingAccounts Batch = new Batch_updateNeoBankingAccounts('neoBankingRbl');
        Database.executeBatch(Batch);
        Test.stopTest();
        
    }
    
}