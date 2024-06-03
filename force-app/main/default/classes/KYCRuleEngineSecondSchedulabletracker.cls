@isTest
public class KYCRuleEngineSecondSchedulabletracker{ 
    public static Case oCase;  
    public static Contact ocontact;
    
    
    Public static testmethod void test1(){
        LoadData();   
        Test.startTest();
        KYCRuleEngineSecondSchedulable sh1 = new KYCRuleEngineSecondSchedulable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Check', sch, sh1); 
        Test.stopTest();
    }    
    public static void LoadData()
    {  
        oContact=new contact();
        oContact.LastName='test';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase=new Case();
        oCase.Status='New';
        oCase.ContactId=oContact.id;
        oCase.LP_IVR_Call__c=1;
        oCase.LP_KYC_Last_Modified_Date__c=date.today().adddays(-3);
        oCase.LP_IVR_Call_Count_Per_Day__c=1;
        oCase.LP_Notification_1__c=2;
        oCase.LP_Notification_2__c=3;
        oCase.LP_Notification_3__c=0;
        oCase.LP_Notification_4__c=4;
        oCase.LP_Manual_Call__c=1;
        oCase.LP_Type_of_IVR__c='abc';
        oCase.LP_KYC_State__c='Manual Documents Declined';
        oCase.LP_Onboarding_Status__c='Awaiting Nach File';
        oCase.LP_Status_Priority_Order__c=2;
        oCase.LP_Manual_Call_Completed__c=TRUE;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();        
        insert oCase;
        
    }
}