@isTest
public class OwnerReassignmentTracker {
    
    public static testMethod void testChangeOwnerControllerC2C(){
        
        user thisUser = [select id from user where id= :userInfo.getUserId()];
        System.runAs(thisUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='Merchant Care User'];
            user u = new User(Alias = 'standt', Email='test@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='testavvhcvcv@testorg.com');
            insert u;
            
            String g = [SELECT Id FROM Group WHERE Name = 'Buyer Care' and type = 'queue'].Id;
            GroupMember gm = new GroupMember(GroupId = g,UserOrGroupId = u.id);
            insert gm;
            
            Account acc = New Account();
            acc.Name='Test Acc';
            insert acc;
            
            contact oContact =new contact();
            oContact.LastName='test';
            oContact.Email='test223@test.com';
            oContact.MobilePhone='1236567890';
            oContact.AccountId=acc.Id;
            insert oContact;
            
            Case case2 =new Case();
            case2.Status='New';
            case2.Priority='High';
            case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            case2.ContactId=oContact.id;
            case2.AccountId = acc.Id;
            case2.MerchantBucket__c = 'Profile completion pending | PP';
            case2.LP_Issue__c = 'Transaction Issues';
            case2.LP_Sub_Issue__c = 'Refund Related';
            insert case2;
            
            
            test.startTest();
            OwnerReassignment.getfieldofCase(case2.Id);
            OwnerReassignment.setCaseFields(u.id,case2.Id,'Buyer Care');
            test.stopTest();
        }
    } 
    
    public static testMethod void testChangeOwnerController(){
        
        user thisUser = [select id from user where id= :userInfo.getUserId()];
        System.runAs(thisUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='Merchant Care User'];
            user u = new User(Alias = 'standt', Email='test@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='testavvhcvcv@testorg.com');
            insert u;
            
            String g = [SELECT Id FROM Group WHERE Name = 'citrus wallet' and type = 'queue'].Id;
            GroupMember gm = new GroupMember(GroupId = g,UserOrGroupId = u.id);
            insert gm;
            
            Account acc = New Account();
            acc.Name='Test Acc';
            insert acc;
            
            contact oContact =new contact();
            oContact.LastName='test';
            oContact.Email='test223@test.com';
            oContact.MobilePhone='1236567890';
            oContact.AccountId=acc.Id;
            insert oContact;
            
            Case oCase;
            oCase=new Case();
            oCase.Status='New';
            oCase.Priority='Medium';
            oCase.Comments='test45678';
            oCase.Subject='testing';
            oCase.SuppliedEmail = 'test@PayUMoney.com';
            oCase.SuppliedName = 'test';
            oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId();
            oCase.ContactId = oContact.id;
            oCase.AccountId = acc.id;
            oCase.Origin = 'citrus_wallet';
            insert oCase;
            
            
            test.startTest();
            OwnerReassignment.getfieldofCase(oCase.Id);
            OwnerReassignment.setCaseFields(u.id,oCase.Id,'citrus_wallet');
            test.stopTest();
        }
    } 
    
}