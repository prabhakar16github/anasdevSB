@isTest
public class UpdateWebsiteDetailsControllerTracker {

    public static testMethod void testData1(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        
        Website_Details__c websiteDetailObj = CommonDataTracker.insertwebsiteDetails(opportunityObj,true, '', '', '', false, false, '', false, 'Website Error', 'Payu.in');
        insert websiteDetailObj;
        
        UpdateWebsiteDetailsController.updateWebsiteDetails('Opportunity',opportunityObj.Id);
    }
    
    public static testMethod void testData2(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.integration_type__c = 'Thirdparty';
        insert opportunityObj;
        
        Website_Details__c websiteDetailObj = CommonDataTracker.insertwebsiteDetails(opportunityObj,true, '', '', '', false, false, 'active', false, 'Website Error', 'Payu.in');
        insert websiteDetailObj;
        
        UpdateWebsiteDetailsController.updateWebsiteDetails('Opportunity',opportunityObj.Id);
    }
    
    public static testMethod void testData3(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.integration_type__c = 'Thirdparty';
        insert opportunityObj;
        
        Website_Details__c websiteDetailObj = CommonDataTracker.insertwebsiteDetails(opportunityObj,true, '', '', '', false, false, '', false, 'Website Error', 'Payu.in');
        insert websiteDetailObj;
        
        UpdateWebsiteDetailsController.updateWebsiteDetails('Opportunity',opportunityObj.Id);
    }
    
    public static testMethod void testData4(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.integration_type__c = 'Thirdparty';
        insert opportunityObj;
        
        UpdateWebsiteDetailsController.updateWebsiteDetails('Opportunity',opportunityObj.Id);
    }
}