@istest  (seealldata=false)
public class csatFormControllerTracker {
    public static Contact ocontact;
    public static Case oCase; 
    public static LP_CsatFormValues__c objCsat;
    public static User u;
    
    public static void LoadData()
    { 
         Profile p = [SELECT Id FROM Profile WHERE Name= 'LazyPay Care Agent'];
        
         u = new User(Alias = 'standt', Email='test@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US',  ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='user@testorg1.com');
         insert u;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase=new Case();
        oCase.OwnerId=u.id;
        oCase.ContactId=oContact.id;        
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='LazyPay';
        oCase.LP_Category__c='BNPL';
        //oCase.LP_Customer_Feedback__c='Good Experience';
        //oCase.LP_Customer_Comments__c='test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        insert oCase;
       
        
        objCsat=new LP_CsatFormValues__c();
        objCsat.LP_feedbackValue__c='test';
        objCsat.Name='test';
        objCsat.LP_starValue__c='test1';
        insert objCsat;       
    }
    @isTest
    public static void csatFormControllerMethod(){
        LoadData();         
        string str = '{"caseId":"'+oCase.id +'","selectedOptions":["Response Quality","Resolution of query"],"ratingNum":4,"comment":"test","ratingVal":"Good Experience"}';
        csatFormController.getPageContent(oCase.id);
        csatFormController.saveCSATData(str);       
    }
}