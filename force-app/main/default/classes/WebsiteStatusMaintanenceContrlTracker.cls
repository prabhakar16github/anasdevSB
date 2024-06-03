@isTest
public class WebsiteStatusMaintanenceContrlTracker 
{
    @testSetup static void setupCommonData()
    {     
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);        
    }
    
    @isTest static void testMethodOne()
    {
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        System.assertNotEquals(opportunityObj.id, null);
        
        List<WrapperWebsitePage> lstWrapperWebsitePage = new List<WrapperWebsitePage>();
        List<String> lstWebsitePageStatus = new List<String>();
        
        
        Schema.DescribeFieldResult schemaDescribeFieldResult = Website_Page__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> lstSchemaPicklistEntry = schemaDescribeFieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry schemaPicklistEntry : lstSchemaPicklistEntry){
            lstWebsitePageStatus.add(schemaPicklistEntry.getLabel());
        }
        
        for(Website_Page__c websitePageObj : [SELECT id, Name, Opportunity__c, Risk_Remarks__c, 
                                                        Sales_Remarks__c, Status__c, Opportunity__r.Name 
                                                            FROM Website_Page__c 
                                                            WHERE Opportunity__c =: opportunityObj.Id])
        {
            WrapperWebsitePage wrapperWebsitePageObj = new WrapperWebsitePage();
            wrapperWebsitePageObj.WebsitePageObj = websitePageObj;
            wrapperWebsitePageObj.lstWebsitePageStatus = lstWebsitePageStatus;
            lstWrapperWebsitePage.add(wrapperWebsitePageObj);
        }
        
        Test.startTest();
        
        WebsiteStatusMaintanenceController.getWebsitePageRecords(opportunityObj.id);
        
        WebsiteStatusMaintanenceController.saveWebsitePageRecords(JSON.serialize(lstWrapperWebsitePage));
        
        WebsiteStatusMaintanenceController.getWebsitePageRecords(null);
        
        WebsiteStatusMaintanenceController.saveWebsitePageRecords(null);
            
        Test.stopTest();
    }
}