@isTest
public class ApprovalRequestAutoApproveBatchTest{

    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Bank_Account_Detail__c', true);
        triggerSwitchObj.Publisher_Call__c = true;
        insert triggerSwitchObj;
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, null, null, null);
        leadObj.Prod_Merchant_Id__c = 876746557;
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        accountObj.Delivery_Duration__c = 60;
        accountObj.Monthly_Expected_Sale__c = 100000;
        update accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c); 
        }
        
        @isTest static void testMethodOne() { 
        
                String strQuery = 'SELECT Id, ProcessInstance.Id,ProcessInstance.Status,  ProcessInstance.TargetObject.Name, ProcessInstance.ProcessDefinition.Name,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type'; 
                strQuery += ' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.Type= \'Account\' AND ProcessInstance.Status!= \'Approved\' AND ProcessInstance.Status!= \'Rejected\' AND ProcessInstance.ProcessDefinition.Name IN : setofAppName';
                Set<String> setofAppName = new Set<String>();
                for(String objStr : Label.Account_approval_process_name.split(';')){
                    setofAppName.add(objStr);
                }
                Test.startTest();
                Database.executebatch(new ApprovalRequestAutoApproveBatch(strQuery,setofAppName),25);
                Test.stopTest();
        }
}