@istest(seealldata=false)
public class LP_clickToCallControllertracker {
    public static Case oCase;
    public static list<Case> lstCase;
    public static Contact ocontact;
    public static Group testGroup;
    public static QueuesObject testQueue;
    public static user aUser;
    public static void LoadData()
    { 
         aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Manual_Call_Queue_KYC', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            //system.debug('testQueue'+testQueue);
             GroupMember member = new GroupMember();
            member.UserOrGroupId = aUser.id;
            member.GroupId = testGroup.Id;
            insert member;
        }
        
       
            
           
        oContact=new contact();
        oContact.LastName='test';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        oCase=new Case();
        oCase.Status='New';
        oCase.OwnerId = testGroup.Id;
        oCase.ContactId=oContact.id;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId(); 
        insert oCase;
        
        system.debug('oCase12'+oCase);        
        lstCase=new list<Case>();
        lstCase.add(oCase);
        system.debug('oCase12'+oCase);
        
    }
    @isTest
    public static void LP_clickToCallControllertrackerMethod(){
        //
        system.debug('userinfo.getuserid======='+userinfo.getuserid());
        LoadData(); 
        test.startTest();        
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        //  String customLabelNameString = 'LP_Manual_Call_Queue_Collection,LP_Manual_Call_Queue_KYC,L1_KYC_Rejection_case_to_Calling_queue';
        // Label.get(customLabelNameString);
        system.runAs(aUser){
        LP_clickToCallController.callKnowlarityForC2C(oCase.id);       
        test.stopTest();
        }
    }
    
}