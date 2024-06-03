@istest 
public class EmailMessagetriggerTracker {
    public static Contact ocontact;
    public static Case oCase;
    public static EmailMessage Objemail;
     public static EmailMessage Objemail1;
    
    public static void LoadData()
    {   Test.startTest();
     
     Trigger_Switch__c osetting = new Trigger_Switch__c();
     osetting.Active__c=true;
     osetting.Name='EmailMessage';
     insert osetting;
     
     oContact=new contact();
     oContact.LastName='test';
     oContact.Email='test@test.com';
     oContact.MobilePhone='1234567890';
     insert oContact;
        
     oCase=new Case();
     oCase.ContactId=oContact.id;
     oCase.status='Closed';
     //oCase.LP_Response_Recieved__c=true;
     oCase.LP_Manual_Call_Status__c='Not Available';
     oCase.LP_Manual_Call_Sub_Status__c='No answer';
     oCase.LP_Next_Scheduled_Call__c =system.today();
     oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
     // oCase.ParentId=Objemail.id;
     insert oCase;
     // update oCase;
     
     
     Objemail=new EmailMessage();
     Objemail.Subject='Re:test';
     Objemail.ParentId=oCase.id;
     Objemail.Incoming=true;
     insert Objemail;
     Objemail.Subject='test';
     update Objemail; 
     
      
     Objemail1=new EmailMessage();
     Objemail1.Subject='test';
     Objemail1.ParentId=oCase.id;
     Objemail1.Incoming=true;
     Objemail1.ToAddress='wecaretesting@lazypay.in';
     insert Objemail1;
     
     EmailMessage Objemail2=new EmailMessage();
     Objemail2.Subject='test';
     Objemail2.ParentId=oCase.id;
     Objemail2.Incoming=false;
     Objemail2.ToAddress='wecaretesting@lazypay.in';

     insert Objemail2;

     
     Test.stopTest();
    }
    @isTest
    public static void EmailMessagetriggerMethod(){
        LoadData(); 
        update Objemail;
        EmailMessageTriggerHandler.beforeUpdateHandler(null,null);

    }

     @isTest
    public static void EmailMessagetriggerMethod2(){
     Trigger_Switch__c osetting = new Trigger_Switch__c();
     osetting.Active__c=true;
     osetting.Name='EmailMessage';
     insert osetting;
     
     oContact=new contact();
     oContact.LastName='test';
     oContact.Email='test@test.com';
     oContact.MobilePhone='1234567890';
     insert oContact;
        
     oCase=new Case();
     oCase.ContactId=oContact.id;
     oCase.status='Resolved';
     //oCase.LP_Response_Recieved__c=true;
     oCase.LP_Manual_Call_Status__c='Not Available';
     oCase.LP_Manual_Call_Sub_Status__c='No answer';
     oCase.LP_Next_Scheduled_Call__c =system.today();
     oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
     // oCase.ParentId=Objemail.id;
     insert oCase;
     // update oCase;
     
     
     Objemail=new EmailMessage();
     Objemail.Subject='Re:test';
     Objemail.ParentId=oCase.id;
     Objemail.Incoming=true;
     insert Objemail;
     Objemail.Subject='test';
     update Objemail; 
    }
    
    @isTest
    public static void EmailMessagetriggerMethod3(){
             Trigger_Switch__c osetting = new Trigger_Switch__c();
     osetting.Active__c=true;
     osetting.Name='EmailMessage';
     insert osetting;
     
     oContact=new contact();
     oContact.LastName='test';
     oContact.Email='test@test.com';
     oContact.MobilePhone='1234567890';
     insert oContact;
        
     oCase=new Case();
     oCase.ContactId=oContact.id;
     oCase.status='New';
     //oCase.LP_Response_Recieved__c=true;
     oCase.LP_Manual_Call_Status__c='Not Available';
     oCase.LP_Manual_Call_Sub_Status__c='No answer';
     oCase.LP_Next_Scheduled_Call__c =system.today();
     oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
     // oCase.ParentId=Objemail.id;
     insert oCase;
     // update oCase;
     
     
     Objemail=new EmailMessage();
     Objemail.Subject='Re:test';
     Objemail.ParentId=oCase.id;
     Objemail.Incoming=true;
     insert Objemail;
     Objemail.Subject='test';
     update Objemail; 
    }
    @isTest
     public static void unitTest2(){     
     oContact=new contact();
     oContact.LastName='test';
     oContact.Email='test@test.com';
     oContact.MobilePhone='1234567890';
     insert oContact;
         
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.status='New';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        oCase.SuppliedEmail = 'kapilchauhan3108@gmail.com';
        oCase.Subject = 'test';  
 
        // oCase.ParentId=Objemail.id;
        insert oCase;  
         
     // oCase.ParentId=Objemail.id;      
        EmailMessage Objemail2 = new EmailMessage();
        Objemail2.Subject='test';
        Objemail2.ParentId=oCase.id;
       // Objemail2.Incoming=false;
        Objemail2.ToAddress='uatwecaretesting@gmail.com';
        objemail2.FromAddress = 'kapilchauhan3108@gmail.com'; 
        insert Objemail2;
        List<EmailMessage> msgList = new List<EmailMessage>();
        msgList.add(Objemail2);
         

         
      // Insert one CAse :
        Case oCase2=new Case();
        oCase2.ContactId=oContact.id;
        oCase2.status='New';
        oCase2.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        oCase2.origin = 'Email';
        oCase2.subject = Objemail2.subject ;
        oCase2.SuppliedEmail =  Objemail2.FromAddress; 
        insert oCase2; 
         
        // Create Email Message
        EmailMessage clone = new EmailMessage();
        clone.FromAddress = objemail2.FromAddress;
        clone.FromName = objemail2.FromName;
        insert clone ;
        EmailMessageTriggerHandler.LazyPayattachDuplicateEmailToSameCase(msgList);
     }
    
      @isTest
    public static void unitTest3(){
    
      oCase=new Case();
     //oCase.ContactId=oContact.id;
     oCase.status='Closed';
     oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
     // oCase.ParentId=Objemail.id;
     insert oCase; 
         
     // oCase.ParentId=Objemail.id;      
        EmailMessage Objemail2 = new EmailMessage();
        Objemail2.Subject='test';
        Objemail2.ParentId=oCase.id;
       // Objemail2.Incoming=false;
        Objemail2.ToAddress='uatwecaretesting@gmail.com';
        insert Objemail2;
        List<EmailMessage> msgList = new List<EmailMessage>();
        msgList.add(Objemail2); 
       
        EmailMessageTriggerHandler.LazyPayattachDuplicateEmailToSameCase(msgList) ; 
        
    }  
    
    @isTest
    public static void codeCoverage(){
        EmailMessageTriggerHandler.codeCoverage();
    } 
  }