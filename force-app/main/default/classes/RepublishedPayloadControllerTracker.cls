@isTest
public class RepublishedPayloadControllerTracker {

    public static testMethod void testData1(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        RepublishedPayloadController.republishedData('Account',accountObj.Id);
    }
    
    public static testMethod void testData2(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        RepublishedPayloadController.republishedData('Entity__c',entityObj.Id);
    }
}