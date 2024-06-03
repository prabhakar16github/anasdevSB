@istest (seealldata=false)
public class CaseCommentTriggerHandlerTracker {
    public static Contact ocontact;
    public static Case oCase;
    public static User u;
    @isTest
    public static void beforeInsertActionsTest()
    { 
        //User adminuser = [Select id FROM User Where id=:userinfo.getUserId()];
        //System.runAs(adminuser){
        
        user thisUser = [select id from user where id= :userInfo.getUserId()];
        System.runAs(thisUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='LazyPay Manual Call User'];
            u = new User(Alias = 'standt', Email='test@testorg.com', 
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p.Id, 
                         TimeZoneSidKey='America/Los_Angeles', UserName='testavvhcvcv@testorg.com');
            insert u;
            Group gp = [SELECT id FROM Group WHERE DeveloperName = 'LP_Manual_Call_Queue_KYC'];
            
            GroupMember GM = new GroupMember();
            GM.GroupId = gp.id;
            GM.UserOrGroupId = u.Id;
            insert GM; 
            //}
            Trigger_Switch__c osetting = new Trigger_Switch__c();
            osetting.Active__c=true;
            osetting.Name='CaseComment';
            insert osetting;
            
            oContact=new contact();
            oContact.LastName='test';
            oContact.Email='test@test.com';
            oContact.MobilePhone='1234567890';
            insert oContact;
            
            
            oCase=new Case();
            oCase.ContactId=oContact.id;
            oCase.LP_Manual_Call_Status__c='Not Available';
            oCase.LP_Manual_Call_Sub_Status__c='No answer';
            oCase.LP_Next_Scheduled_Call__c =system.today();
            //oCase.LOB_Name__c='PayU Money';
            //oCase.Status = 'New';
            insert oCase; 
            
            CaseComment objComment = new CaseComment();
            objComment.parentId = oCase.id;
            insert objComment;
        }
            
    }
    @isTest
    public static void afterInsertActionsTest(){
        list<caseComment> casecommlist = new list<caseComment>();
        user thisUser = [select id from user where id= :userInfo.getUserId()];
        System.runAs(thisUser){
        /*User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Child'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;*/
            Profile p =[SELECT Id FROM Profile WHERE Name = 'Merchant Care Child'];
            u = new User(Alias = 'standt', Email='test@testorg.com', 
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p.Id, 
                         TimeZoneSidKey='America/Los_Angeles', UserName='testavvhcvcv@testorg.com');
            insert u;
           
            oCase=new Case();
            oCase.OwnerId=u.id;
            oCase.Status='Pending';
            oCase.LP_Sub_Status__c='Waiting on Merchant Maintenance';
            oCase.LOB_Name__c='PayU Money';
            oCase.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            insert oCase;
            
            Status_SLA__c  sla = new Status_SLA__c();
            sla.Case__c = oCase.Id;
            sla.Active__c = true;
            sla.OneCare_LOB_Name__c = oCase.LOB_Name__c;
            sla.Transferred_from_Other_Teams_Count__c = 1;
            sla.First_assigned_user__c = oCase.Owner__c;
            insert sla;
            
            CaseComment objComment = new CaseComment();
            objComment.CommentBody = 'Agent: ';
            objComment.CreatedById = u.id;
            objComment.parentId = oCase.id;
            casecommlist.add(objComment);
            insert casecommlist;
            
            
            CaseCommentTriggerHandler.afterInsertHandler(casecommlist);
            
        }
    }
 
}