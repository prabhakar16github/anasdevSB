@isTest(seealldata=false)
public class manualcallScheduletracker {
    public static QueuesObject testQueue;
    public static QueuesObject testQueue1;
    public static Contact ocontact;
    public static Case oCase1;
    public static Case oCase2;
    public static Group testGroup;

     Public static testmethod void manualcallBatchMethod(){ 
        loadData();
        manualcallSchedule sh1 = new manualcallSchedule();
        String sch = '0 0 2 * * ?'; 
        test.StartTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        system.schedule('Check', sch, sh1);
         // CollectionNotificationUtility.sendRequest('{}', 'SendMessage','sendemail');
        test.stopTest();
        
        
         
        
}

    
  public static void LoadData() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Email_Queue', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        Id queueID2 = [SELECT Id,DeveloperName,Name FROM Group WHERE type ='queue' AND DeveloperName = 'LP_Email_Queue'].id;
        Id queueID = [SELECT Id,DeveloperName,Name FROM Group WHERE type ='queue' AND DeveloperName = 'LP_SMS_Queue'].id;
        Id queueID3 = [SELECT Id,DeveloperName,Name FROM Group WHERE type ='queue' AND DeveloperName = 'LP_Manual_Call_Queue_Collection'].id;
        
      
      
        system.debug('queueID======'+queueID);
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='+911234567890';
        insert oContact; 
        
        oCase1=new Case();
        oCase1.OwnerId = queueID3;
        oCase1.Priority='High';
        oCase1.LP_IVR_Call__c=1;
        oCase1.LP_Customer_Score__c=7;
        oCase1.LP_Manual_Call__c=1;
         String dateStr = Date.today().format();
        oCase1.Collection_Rule_Time__c = dateStr;
        oCase1.LP_Due_Since__c = Date.today().addDays(-9);
        oCase1.LP_Outstanding_Amount__c = 200;
        oCase1.LP_SMS__c=1;
        oCase1.LP_Email__c=1;
        oCase1.LP_CL_Status__c = '0';
        oCase1.LP_APP_Notification__c=1;
        oCase1.LP_Communication_Type__c='Competitive';
        oCase1.LP_Communication_sub_type__c='Type Default';
        oCase1.LP_IVR_Call_Count__c=1;
         oCase1.LP_Email_Template_Name__c = 'test';
        oCase1.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase1.Status='New';      
        oCase1.ContactId=oContact.id;
        insert oCase1;
        system.debug('case'+oCase1);
     
    }
   

}