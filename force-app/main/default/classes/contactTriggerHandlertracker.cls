/**
@author:            jatin arora
@company:           SaaSFocus
@description:       cover contactTriggerHandler,lazyPayPublish
@history
<Date>        <Authors Name>        
26-Sep-18     jatin arora          
**/
@isTest
public class contactTriggerHandlertracker {
    public static Contact ocontact;
    public static Case oCase;
    public static user L1User;
    public static Trigger_Switch__c osetting;
    
    public static void LoadData()
    { 
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Contact';
        insert osetting; 
        
        oCase=new Case();
        oCase.Status='Pending';
        oCase.Priority='High';
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_Sub_Status__c = 'Additional Documents Requested';
        oCase.LP_KYC_State__c ='User Documents Pending';
        insert oCase;
        
        oContact=new contact();
        oContact.LastName='test';
        insert oContact;
        
        User adminUser = [Select id from user where id=:userinfo.getUserId()];
        System.runAs(adminUser){
            string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'LazyPay Standard User' limit 1].id;
            system.assertNotEquals(profileId, null);
            
            L1User = CommonDataTracker.insertUser(profileId);
            insert L1User;
            system.assertNotEquals(L1User.Id, null);
            
            //Creating a Queue
            Group g = new Group(Type='Queue', Name='L1 KYC Queue');
            insert g;
            
            QueueSObject q = new QueueSObject(SobjectType='Case', QueueId=g.Id);
            insert q;
            
            /////Adding users to Queue//////////
            
            //Get the group you want. Queues are stored as group objects with a type of Queue
            list<Group> lstgrp = [select Id from Group where Name='L1 KYC Queue' AND Type = 'Queue'];
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = L1User.Id;
            member.GroupId = lstgrp[0].Id;
            insert member;
        }
        
    }
    @isTest
    public static void contactTriggerHandlerMethodOne(){
        
        LoadData();
        system.runAs(L1User){
            Contact oContact=new contact();
            oContact.LastName='test';
            insert oContact;
            system.assertNotEquals(oContact.Id, null);
            Contact objContact = [SELECT id,lastname FROM Contact limit 1];
            ocontact.lastname = 'test1';
            update ocontact;
            system.assertEquals(oContact.lastname, 'test1');
        }
    }
    @isTest
    public static void contactTriggerHandlerMethodTwo(){
        
        LoadData();
        system.runAs(L1User){
            Contact oContact=new contact();
            oContact.LastName='test';
            oContact.MobilePhone = '9988776655';
            insert oContact;
            system.assertNotEquals(oContact.Id, null);
            Contact objContact = [SELECT id,lastname FROM Contact limit 1];
            ocontact.lastname = 'test1';
            update ocontact;
            system.assertEquals(oContact.lastname, 'test1');
        }
    }
}