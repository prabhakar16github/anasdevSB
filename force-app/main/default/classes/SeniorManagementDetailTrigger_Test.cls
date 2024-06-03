@isTest
public class SeniorManagementDetailTrigger_Test {
	@isTest
    static void testSetup(){
        Trigger_Switch__c tr = new Trigger_Switch__c();
        tr.Name = 'Senior_Management_Detail__c';
        tr.Active__c = true;
        insert tr;
        
        Senior_Management_Detail__c sm = new Senior_Management_Detail__c();
        sm.Name = 'test';
        insert sm;
        
        sm.Designation__c = 'CEO';
        update sm;
    }
}