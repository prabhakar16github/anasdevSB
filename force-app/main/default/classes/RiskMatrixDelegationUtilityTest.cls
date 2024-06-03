@isTest
public class RiskMatrixDelegationUtilityTest {
    @TestSetup
    static void makeData(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
            insert entityObj;
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
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
            insert subCategory;
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            insert businessCategory;
        
        Opportunity opp = CommonDataTracker.insertOpportunity(accountObj);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opp.stageName = 'Terminated';
        opp.Website_Status__c = 'Website Error';
        opp.Risk_Level__c = '';
        opp.Merchant_Type__c = 'Seller';
        opp.BusinessCategory__c = businessCategory.id;
        opp.Sub_Category__c = subCategory.id;
        opp.Delivery_Duration__c = 23;
        opp.Monthly_Expected_Sale__c = 2342;
        opp.Transaction_Facility_Required__c = 'Domestic';
        opp.MAF_Status__c = 'Received';
        opp.Agreement_Status__c='Pending';
        opp.Document_Status__c='Pending';
        opp.Activation_Status_Onboarding__c='ME Code Activated';
        opp.Bank_Verification_Status__c = 'Success';
        opp.LOB_Status__c='Pending';
        opp.Prod_Merchant_Id__c = 2345677;
        opp.Settlement_Status__c='Active';
        opp.Risk_Type_Multi_Select__c = 'Website URL';
        opp.Blacklist__c = true;
        opp.Business_Entity__c =entityObj.Id;
        opp.Agent_Details__c='Shivdeep test - 7877002681';
        opp.Risk_Type_Multi_Select__c = 'Bank Detail';
        insert opp;
        
        System.debug('OB Hold ss =========');
        opp.stageName = 'MAF';
        opp.Blacklist__c = false;
        opp.Settlement_Status__c = 'Active';
        update opp; 
        
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Settlement_Amount_on_Hold__c = 1000;
    }
    
    @isTest
    static void methodOne() {
        Opportunity opp = [Select Id From Opportunity Limit 1];
        
        Release_Note__c releasenote = new Release_Note__c();
        releasenote.Opportunity__c = opp.Id;
        insert releasenote;
        
        releasenote.Status__c = 'Approved';
        update releasenote;
        
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(releasenote.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Slab_1_Risk_Hold_Approval_Process ');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        RiskMatrixDelegationUtility.getReleaseNotes(opp.Id);
        RiskMatrixDelegationUtility.revertApprovalProcess(releasenote.Id, '');
        RiskMatrixDelegationUtility.getRNCheck(releasenote.Id);
        RiskMatrixDelegationUtility.getProcessInstances(releasenote.Id);
        RiskMatrixDelegationUtility.updateRNAnalystL1Status(true, releasenote.Id, 'test');
        RiskMatrixDelegationUtility.updSettlementStatus(new List<Release_Note__c>{releasenote});
    }
}