/*
Created By - Rohit Kumar Gupta
Date - 11-05-2022
Class Name - AwsAccountSync_Tracker
Purpose - Code coverage for AwsAccountSync_CTRL.
*/

@isTest(SeeAllData=true)
public class AwsAccountSync_Tracker {
    public static testmethod void AwsAccountSync2() {
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        Platform__c platformObj =new Platform__c();
        platformObj.Name = 'PayU Biz';
        insert platformObj;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'PayU Biz';
        prodObj.Platform__c  = platformObj.Id;
        insert prodObj; 
         Entity__c ent = [SELECT Id,Identifier__c,Name FROM Entity__c WHERE Identifier__c=:'1f52-d683-0b1384e5-d7e4-4bb3c2dc7468'];
         Lead ld = new Lead(lastname = 'RohitGuptaNewTest',Monthly_Expected_Sale__c=12344545.00,Website__c ='payu.in',Business_Origin__c='SMB-ENT',Device__c='Desktop',company ='Merchant',Status='New',Integration_Type__c ='ThirdParty',Display_Name__c ='Merchant',PAN_Verification_Status__c ='Success',Merchant_Business_Type__c ='LongTail',MobilePhone ='9043432323',Online_Lead__c =True,Penny_Verification_Required__c =true,Sub_Status__c='Not Contacted',Email='Rohit@gmail.com',
                           Product__c=prodObj.Id,Business_Entity__c= ent.Id,Prod_Merchant_Id__c =8021154,Lead_Type__c='Merchant',LeadSource ='Partner',Sub_Source__c ='Others',Identifier__c='14ed-7b99-26611dca-9f8f-02053299b2da');
        insert ld;
        Lead ld1 = new Lead();
        ld1.PAN_Holder_Name__c = 'Rohit Kumar Gupta';
        ld1.PAN_Number__c = 'BWRPG3606C';
        ld1.Legal_Name__c = 'Rohit Kumar Gupta';
		ld1.Identifier__c = ld.Identifier__c;
        ld1.Business_Entity__c = ent.Id;
        ld1.PAN_Verification_Status__c='Success';
        ld1.Id = ld.Id;
        update ld1;
        system.debug('ld1:::::::'+ld1);
        AwsAccountSync_CTRL.AccSync wrapper = new AwsAccountSync_CTRL.AccSync(); 
        wrapper.business_entity_uuid = '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468';
        wrapper.business_name = ld1.Legal_Name__c; 
        wrapper.name_on_pan = 'Rohit Kumar Gupta';
        wrapper.pan_card_number = 'BWRPG3606C';
        wrapper.pan_verification_status = 'Success';
        wrapper.uuid = ld1.Identifier__c;
 
        List<Lead> updateLeadList = new List<Lead>();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String str = '{"name_on_pan": "Rohit Kumar Gupta","pan_card_number": "BWRPG3606C","uuid":'+' "' + ld1.Identifier__c +'" ' +',"business_name":"Rohit Kumar Gupta","pan_verification_status":"Success"}';
        req.requestBody = Blob.valueof(str);    
        req.requestURI = '/services/apexrest/accountSyncWithAws'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        AwsAccountSync_CTRL.updateLead();
        //AwsAccountSync3(ld1); 
    }
     public static testmethod void AwsAccountSync3() {
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        Platform__c platformObj =new Platform__c();
        platformObj.Name = 'PayU Biz';
        insert platformObj;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'PayU Biz';
        prodObj.Platform__c  = platformObj.Id;
        insert prodObj; 
         Entity__c ent = [SELECT Id,Identifier__c,Name FROM Entity__c WHERE Identifier__c=:'1f52-d683-0b1384e5-d7e4-4bb3c2dc7468'];
         Lead ld = new Lead(lastname = 'RohitGuptaNewTest',Monthly_Expected_Sale__c=12344545.00,Website__c ='payu.in',Business_Origin__c='SMB-ENT',Device__c='Desktop',company ='Merchant',Status='New',Integration_Type__c ='ThirdParty',Display_Name__c ='Merchant',PAN_Verification_Status__c ='Success',Merchant_Business_Type__c ='LongTail',MobilePhone ='9043432323',Online_Lead__c =True,Penny_Verification_Required__c =true,Sub_Status__c='Not Contacted',Email='Rohit@gmail.com',
                           Product__c=prodObj.Id,Business_Entity__c= ent.Id,Prod_Merchant_Id__c =8021154,Lead_Type__c='Merchant',LeadSource ='Partner',Sub_Source__c ='Others',Identifier__c='14ed-7b99-26611dca-9f8f-02053299b2da');
        insert ld;
        Lead ld1 = new Lead();
        ld1.PAN_Holder_Name__c = 'Rohit Kumar Gupta';
        ld1.PAN_Number__c = 'BWRPG3606C';
        ld1.Legal_Name__c = 'Rohit Kumar Gupta';
		ld1.Identifier__c = ld.Identifier__c;
        ld1.Business_Entity__c = ent.Id;
        ld1.PAN_Verification_Status__c='Success';
        ld1.Id = ld.Id;
        update ld1;
        system.debug('ld1:::::::'+ld1);
        AwsAccountSync_CTRL.AccSync wrapper = new AwsAccountSync_CTRL.AccSync(); 
        wrapper.business_entity_uuid = '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468';
        wrapper.business_name = ld1.Legal_Name__c; 
        wrapper.name_on_pan = 'Rohit Kumar Gupta';
        wrapper.pan_card_number = 'BWRPG3606C';
        wrapper.pan_verification_status = 'Success';
        wrapper.uuid = ld1.Identifier__c;
 
        List<Lead> updateLeadList = new List<Lead>();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String str = '{"business_entity_uuid":'+' "' + '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468' +'" ' +',"name_on_pan": "Rohit Kumar Gupta","pan_card_number": "BWRPG3606C","uuid":'+' "' + ld.Identifier__c +'" ' +',"business_name":"Rohit Kumar Gupta","pan_verification_status":"Success"}';
        req.requestBody = Blob.valueof(str);    
        req.requestURI = '/services/apexrest/accountSyncWithAws'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        AwsAccountSync_CTRL.updateLead(); 
    }
      public static testmethod void AwsAccountSync4() {
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        Platform__c platformObj =new Platform__c();
        platformObj.Name = 'PayU Biz';
        insert platformObj;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'PayU Biz';
        prodObj.Platform__c  = platformObj.Id;
        insert prodObj; 
         Entity__c ent = [SELECT Id,Identifier__c,Name FROM Entity__c WHERE Identifier__c=:'1f52-d683-0b1384e5-d7e4-4bb3c2dc7468'];
         Lead ld = new Lead(lastname = 'RohitGuptaNewTest',Monthly_Expected_Sale__c=12344545.00,Website__c ='payu.in',Business_Origin__c='SMB-ENT',Device__c='Desktop',company ='Merchant',Status='New',Integration_Type__c ='ThirdParty',Display_Name__c ='Merchant',PAN_Verification_Status__c ='Success',Merchant_Business_Type__c ='LongTail',MobilePhone ='9043432323',Online_Lead__c =True,Penny_Verification_Required__c =true,Sub_Status__c='Not Contacted',Email='Rohit@gmail.com',
                           Product__c=prodObj.Id,Business_Entity__c= ent.Id,Prod_Merchant_Id__c =8021154,Lead_Type__c='Merchant',LeadSource ='Partner',Sub_Source__c ='Others',Identifier__c='14ed-7b99-26611dca-9f8f-02053299b2da');
        insert ld;
        Lead ld1 = new Lead();
        ld1.PAN_Holder_Name__c = 'Rohit Kumar Gupta';
        //ld1.PAN_Number__c = 'BWRPG3606C';
        ld1.Legal_Name__c = 'Rohit Kumar Gupta';
		ld1.Identifier__c = ld.Identifier__c;
        ld1.Business_Entity__c = ent.Id;
        ld1.PAN_Verification_Status__c='Success';
        ld1.Id = ld.Id;
        update ld1;
        system.debug('ld1:::::::'+ld1);
        AwsAccountSync_CTRL.AccSync wrapper = new AwsAccountSync_CTRL.AccSync(); 
        wrapper.business_entity_uuid = '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468';
        wrapper.business_name = ld1.Legal_Name__c; 
        wrapper.name_on_pan = 'Rohit Kumar Gupta';
        wrapper.pan_card_number = 'BWRPG3606C';
        wrapper.pan_verification_status = 'Success';
        wrapper.uuid = ld1.Identifier__c;
 
        List<Lead> updateLeadList = new List<Lead>();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String str = '{"business_entity_uuid":'+' "' + '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468' +'" ' +',"name_on_pan": "Rohit Kumar Gupta","uuid":'+' "' + ld.Identifier__c +'" ' +',"business_name":"Rohit Kumar Gupta","pan_verification_status":"Success"}';
        req.requestBody = Blob.valueof(str);    
        req.requestURI = '/services/apexrest/accountSyncWithAws'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        AwsAccountSync_CTRL.updateLead(); 
    }
     public static testmethod void AwsAccountSync5() {
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        Platform__c platformObj =new Platform__c();
        platformObj.Name = 'PayU Biz';
        insert platformObj;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'PayU Biz';
        prodObj.Platform__c  = platformObj.Id;
        insert prodObj; 
         Entity__c ent = [SELECT Id,Identifier__c,Name FROM Entity__c WHERE Identifier__c=:'1f52-d683-0b1384e5-d7e4-4bb3c2dc7468'];
         Lead ld = new Lead(lastname = 'RohitGuptaNewTest',Monthly_Expected_Sale__c=12344545.00,Website__c ='payu.in',Business_Origin__c='SMB-ENT',Device__c='Desktop',company ='Merchant',Status='New',Integration_Type__c ='ThirdParty',Display_Name__c ='Merchant',PAN_Verification_Status__c ='Success',Merchant_Business_Type__c ='LongTail',MobilePhone ='9043432323',Online_Lead__c =True,Penny_Verification_Required__c =true,Sub_Status__c='Not Contacted',Email='Rohit@gmail.com',
                           Product__c=prodObj.Id,Business_Entity__c= ent.Id,Prod_Merchant_Id__c =8021154,Lead_Type__c='Merchant',LeadSource ='Partner',Sub_Source__c ='Others',Identifier__c='15ed-7b99-26611dca-9f8f-02053299b2da');
        insert ld;
        Lead ld1 = new Lead();
        ld1.PAN_Holder_Name__c = 'Rohit Kumar Gupta';
        //ld1.PAN_Number__c = 'BWRPG3606C';
        ld1.Legal_Name__c = 'Rohit Kumar Gupta';
		ld1.Identifier__c = ld.Identifier__c;
        ld1.Business_Entity__c = ent.Id;
        ld1.PAN_Verification_Status__c='Success';
        ld1.Id = ld.Id;
        update ld1;
        system.debug('ld1:::::::'+ld1);
        AwsAccountSync_CTRL.AccSync wrapper = new AwsAccountSync_CTRL.AccSync(); 
        wrapper.business_entity_uuid = '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468';
        wrapper.business_name = ld1.Legal_Name__c; 
        wrapper.name_on_pan = 'Rohit Kumar Gupta';
        wrapper.pan_card_number = 'BWRPG3606C';
        wrapper.pan_verification_status = 'Success';
        wrapper.uuid = ld1.Identifier__c;
 
        List<Lead> updateLeadList = new List<Lead>();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String str = '{"business_entity_uuid":'+' "' + '1f52-d683-0b1384e5-d7e4-4bb3c2dc7468' +'" ' +',"name_on_pan": "Rohit Kumar Gupta","uuid":'+' "' + ld1.Identifier__c +'" ' +',"business_name":"Rohit Kumar Gupta","pan_verification_status":"Success"}';
        req.requestBody = Blob.valueof(str);    
        req.requestURI = '/services/apexrest/accountSyncWithAws'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        AwsAccountSync_CTRL.updateLead(); 
    }
}