@isTest
public class SettlementMismatchSchedulableTracker {
    @testSetup static void setup() {
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
            insert triggerSwitchObj ;
            
            Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
            insert enableUUIDObjObj;
            
            Enable_UUID_Objects__c enableUUIDObjObj1 = CommonDataTracker.insertEnableUUIDRec('Lead', true);
            insert enableUUIDObjObj1;
            
            Credentials__c credObj = CommonDataTracker.insertCredentials();
            insert credObj;
            
            Entity__c entityObj = CommonDataTracker.insertEntity('Society');
            insert entityObj;
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            insert businessCategory;
            
            Business_Category__c businessCategory1 = CommonDataTracker.insertBusinessCategory('Real Estate', false);
            businessCategory1.Doable__c = True;
            insert businessCategory1;
            
            Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
            insert subCategory;
            System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
            
            Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
            accountObj.Business_Entity__c =  entityObj.Id;
            accountObj.Identifier__c = '9867587879089887';
            accountObj.Document_Status__c = 'Docs Approved';
            accountObj.LOB_Status__c = 'Approved';
            accountObj.Agreement_Status__c = 'Approved';
            accountObj.Dow_Jones_Status__c = 'Match Found';
            accountObj.Document_Status__c = 'Docs Approved';
            accountObj.Monthly_Expected_Sale__c = 200;
            accountObj.Delivery_Duration__c = 2;
            insert accountObj;
//        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        
        //Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        //Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        //Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        //insert entityObj;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
                //Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
         accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.stageName = 'Terminated';
        opportunityObj4.Website_Status__c = 'Website Error';
        opportunityObj4.Risk_Level__c = '';
        opportunityObj4.Merchant_Type__c = 'Seller';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj4.MAF_Status__c = 'Received';
        opportunityObj4.Agreement_Status__c='Pending';
        opportunityObj4.Document_Status__c='Pending';
        opportunityObj4.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj4.Bank_Verification_Status__c = 'Success';
        opportunityObj4.LOB_Status__c='Pending';
        opportunityObj4.Prod_Merchant_Id__c = 2345677;
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj4.Blacklist__c = false;
        opportunityObj4.Business_Entity__c =entityObj.Id;
        opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Bank Detail';
        insert opportunityObj4;
        
        opportunityObj4.Settlement_Status__c = 'Risk Hold';
        opportunityObj4.On_OB_Hold__c = 'N';
        opportunityObj4.On_Post_Risk_Hold__c = 'N';
        opportunityObj4.On_Pre_Risk_Hold__c = 'N';
        update opportunityObj4;
         
         
        Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
        Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
        Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
    	List<Risk_status_Detail__c> lstRsd = new List<Risk_status_Detail__c>();
        Risk_status_Detail__c  rsdPo = new Risk_status_Detail__c();
        rsdPo.RecordTypeId = postTypeId;
        rsdPo.Opportunity__c = opportunityObj4.Id;
        rsdPo.Hold_Type__c = 'Post Hold';
        rsdPo.Current_Status__c = 'On Hold';
        lstRsd.add(rsdPo);
        Risk_status_Detail__c  rsdOb = new Risk_status_Detail__c();
        rsdOb.RecordTypeId = obTypeId;
        rsdOb.Opportunity__c = opportunityObj4.Id;
        rsdOb.Hold_Type__c = 'OB Hold';
        rsdOb.Current_Status__c = 'On Hold';
        lstRsd.add(rsdOb);
        Risk_status_Detail__c  rsdPre = new Risk_status_Detail__c();
        rsdPre.RecordTypeId = preTypeId;
        rsdPre.Opportunity__c = opportunityObj4.Id;
        rsdPre.Hold_Type__c = 'Pre Hold';
        rsdPre.Current_Status__c = 'On Hold';
        lstRsd.add(rsdPre);
         
        insert lstRsd; 
        
        
    }
    
	@isTest
    public static void testone() {
        SettlementMismatchSchedulable.sendMail();
    }
}