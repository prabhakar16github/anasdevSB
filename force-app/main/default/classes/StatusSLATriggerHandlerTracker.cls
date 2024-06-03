/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       cover CasetriggerHandler,lazyPayPublish
@history
<Date>        <Authors Name>        
24-Sep-18     jatin arora          
**/
@isTest(seealldata=false)
public class StatusSLATriggerHandlerTracker {
    
    public static Trigger_Switch__c osetting;
    public static Contact ocontact;
    public static Case oCase;
    
    public static void LoadData()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='StatusSLA';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Identifier__c='test';
        insert oContact;
        
        
        oCase=new Case();
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        //oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        // oCase.LP_Sub_Status__c='Waiting on customer';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        oCase.LP_UUID_For_Collection__c='test';
        insert oCase;
        
        Status_SLA__c objSLA = new Status_SLA__c();
        objSLA.Case__c = oCase.Id;
        insert objSLA;
     }
    
    @isTest
    public static void validateVerifiedTest(){
        LoadData();
        oCase.status = 'Open';
        update oCase;
    }
}