@isTest
public class UpdateMerchantDetailControllerTracker {

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
        
        UpdateMerchantDetailController.getMerchantDetails(opportunityObj.Id);
        string wrapperStr = '{"accountObj":{"Id":"0010p00000btB5qAAE","IsDeleted":false,"Name":"Sarvpriya-GAXPS9363B"},"addressOptions":["Registered","Operating","AadharXML","GSTIN","CKYC","CIN"],"entityWrapList":[{"pickListLabel":"Local Authority","pickListValue":"a0D0p000000XbFMEA0--Local Authority"},{"pickListLabel":"Individual","pickListValue":"a0D0p000000XbFwEAK--Individual"}],"opportunityObj":{"AccountId":"0010p00000btB5qAAE","Id":"0060p000005EPNqAAO","Android_URL__c":"cscsa.in","Website_Status__c":"Pending","Website__c":"sfsfsdfsdfds.com","iOS_URL__c":"xvxfv.in","Account":{"Business_Entity__c":"a0D0p000000XbFwEAK","Id":"0010p00000btB5qAAE"}}}';
            UpdateMerchantDetailController.updateMerchantData('WebsiteDetail', wrapperStr, null, '');
        
        UpdateMerchantDetailController.updateMerchantData('EntityDetail', wrapperStr, 'a0D0p000000XbFMEA0--Local Authority', '');
        
        UpdateMerchantDetailController.updateMerchantData('AddressDetail', wrapperStr, null, 'Registered');
    }
}