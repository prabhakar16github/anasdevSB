@isTest
public class WebsiteStatusMaintanenceCtlrTracker {
    
    @testSetup static void setupCommonData(){
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);  
        
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
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Website__c = 'test.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        opportunityObj.Website_Status__c = 'Website OK';
        opportunityObj.Pre_Approved_for_priority_settlement__c = false;
        opportunityObj.Max_Same_Day_Settlement_Amount__c = 18000;
        opportunityObj.Base_Merchant_Id__c = 897056;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId, Pre_Approved_for_priority_settlement__c, Max_Same_Day_Settlement_Amount__c, Base_Merchant_Id__c FROM Opportunity WHERE id =: opportunityObj.id].AccountId);    
        
        string pageDetails = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        Website_Page_Master__c wpm = CommonDataTracker.insertWPM('Contact Us Details',pageDetails);
        insert wpm;
        
        
        string pageDetails2 = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        Website_Page_Master__c wpm2 = CommonDataTracker.insertWPM('Terms & Conditions Details',pageDetails2);
        insert wpm2;
        
        
        Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj1.Active__c = true;
        websitePageObj1.Name = 'Contact Us Details';
        websitePageObj1.Risk_Remarks__c = 'Test Remarks';
        websitePageObj1.Pick_Risk_Remark__c = 'Share us the Login credentials so that we can verify the details.';
        insert websitePageObj1;
        
        Merchant_Document__c merchantDoc = CommonDataTracker.insertMerchantDoc(accountObj);
        merchantDoc.KYC_Documentable_Type__c = 'WebsiteDetail';
        merchantDoc.Opportunity__c = opportunityObj.id;
        merchantDoc.Onboarding_Status__c = 'Approved';
        insert merchantDoc;
        
        merchantDoc.Onboarding_Status__c = 'Not Applicable';
        update merchantDoc;
        
        
       /*  Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj1.Active__c = true;
        insert websitePageObj1;
        Website_Page__c websitePageObj2 = CommonDataTracker.insertWebsitePage('Terms & Conditions Details', true, opportunityObj);
        websitePageObj2.Active__c = true;
        insert websitePageObj2;*/
        
    }
    
    @isTest static void testMethodOne(){ 
        Opportunity opportunityObj = [SELECT id, AccountId, Pre_Approved_for_priority_settlement__c, 
                                      Max_Same_Day_Settlement_Amount__c, Base_Merchant_Id__c FROM Opportunity LIMIT 1];
        List<Website_Page_Master__c> wpmList = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c ];
        List<Comments__c> listCom1 = [Select Id,Comment__c, Active__c, Comment_By__c from Comments__c LIMIT 1];
        //Website_Details__c[] websiteObj = [SELECT id FROM Website_Details__c LIMIT 1];
        
        //Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        //websitePageObj.Page_Details__c = wpm.Page_Details__c;
        Test.startTest();
        //insert websitePageObj;
        List<Comments__c> listCom = WebsiteStatusMaintanenceController_Onb.getLatestComments('0060p00000BG2k0AAD','0060p00000BG2k0ssc',listCom1);
        list<WrapperWebsitePage> result = WebsiteStatusMaintanenceController_Onb.getWebsitePageRecords(opportunityObj.id);
        test.stopTest();
        system.assertNotEquals(null, result);
    }
    
    @isTest static void testMethodTwo(){ 
        Website_Page__c WebsitePageObj = [SELECT Id FROM Website_Page__c LIMIT 1];
        List<string> lstWebsitePageStatus = new List<string> {'Verification in Process'};
        WrapperWebsitePage obj = new WrapperWebsitePage();
        obj.WebsitePageObj = WebsitePageObj;
        obj.lstWebsitePageStatus = lstWebsitePageStatus;
        List<WrapperWebsitePage> objList = new List<WrapperWebsitePage> {obj};
        String str = JSON.serialize(objList);
        test.startTest();
        WebsiteStatusMaintanenceController_Onb.saveWebsitePageRecords(str);
        test.stopTest();
    }
    
    @isTest static void testMethodThree(){ 
        Opportunity opportunityObj = [SELECT id, AccountId, Website_Status__c,NDX_Score__c, Pre_Approved_for_priority_settlement__c, 
                                      Max_Same_Day_Settlement_Amount__c, Base_Merchant_Id__c, Partner__c FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Contact Us Details' LIMIT 1];
        Website_Page__c websitePageObjnew = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObjnew.Page_Details__c = wpm.Page_Details__c;
        
        Website_Page__c WebsitePageObj = [SELECT Id,Name,Risk_Remarks__c,Pick_Risk_Remark__c FROM Website_Page__c LIMIT 1];
        List<string> lstWebsitePageStatus = new List<string> {'Verification in Process'};
        WrapperWebsitePage obj = new WrapperWebsitePage();
        obj.WebsitePageObj = WebsitePageObj;
        obj.lstWebsitePageStatus = lstWebsitePageStatus;
        List<WrapperWebsitePage> objList = new List<WrapperWebsitePage> {obj};
        String str = JSON.serialize(objList);
        
        Test.startTest();	
        insert websitePageObjnew;
        WebsiteStatusMaintanenceController_Onb.getMccCodeMetaData('98765', opportunityObj.id); 
        WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus(opportunityObj.id, 'Website OK','1231','A',true,str,true,4000,300,'Approved','Rejected');
        WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus(opportunityObj.id, 'Website OK','1231','A',true,'[{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise","Risk_Rating__c":""},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR5EAM","Name":"Contact Us Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Functional email ID\",\"status\":\"Approved\",\"is_present\":false,\"error\":null,\"remarks\":null},{\"name\":\"Functional contact number\",\"status\":\"Rejected\",\"is_present\":false,\"error\":\"No functional Contact Number is mentioned on your website/app\",\"remarks\":null},{\"name\":\"Functional address\",\"status\":\"Not Applicable\",\"is_present\":false,\"error\":null,\"remarks\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"ghvg"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR6EAM","Name":"Product/Services Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Legal Products/Services\",\"is_present\":false,\"status\":\"Approved\",\"remarks\":null,\"error\":null},{\"name\":\"No re-directions to other URLs\",\"is_present\":false,\"status\":\"Rejected\",\"remarks\":null,\"error\":\"Your website is getting re-directed to some other URL\"},{\"name\":\"Detailed Description\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Correct Pricing\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jhvjh"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR4EAM","Name":"Terms & Conditions Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Advanced Booking Duration\",\"is_present\":false,\"status\":\"Approved\",\"remarks\":null,\"error\":null},{\"name\":\"Limited Liability Clause\",\"is_present\":false,\"status\":\"Rejected\",\"remarks\":null,\"error\":\"Customers are not being made to accept the Limited Liability Clause before making the payment for the product/service\"},{\"name\":\"Shipping/Membership Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Cancellation Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Return Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Refund Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jv"}}]',true,50000, 6600,'Approved','Rejected');
        WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus(opportunityObj.id, 'Website OK','','A',true,'',true,50000,400,'Approved','Rejected');
        WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus(opportunityObj.id, 'Website OK','1231','A',false,'[{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise","Risk_Rating__c":""},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR5EAM","Name":"Contact Us Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Functional email ID\",\"status\":\"Approved\",\"is_present\":false,\"error\":null,\"remarks\":null},{\"name\":\"Functional contact number\",\"status\":\"Rejected\",\"is_present\":false,\"error\":\"No functional Contact Number is mentioned on your website/app\",\"remarks\":null},{\"name\":\"Functional address\",\"status\":\"Not Applicable\",\"is_present\":false,\"error\":null,\"remarks\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"ghvg"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR6EAM","Name":"Product/Services Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Legal Products/Services\",\"is_present\":false,\"status\":\"Approved\",\"remarks\":null,\"error\":null},{\"name\":\"No re-directions to other URLs\",\"is_present\":false,\"status\":\"Rejected\",\"remarks\":null,\"error\":\"Your website is getting re-directed to some other URL\"},{\"name\":\"Detailed Description\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Correct Pricing\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jhvjh"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR4EAM","Name":"Terms & Conditions Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{\"name\":\"Advanced Booking Duration\",\"is_present\":false,\"status\":\"Approved\",\"remarks\":null,\"error\":null},{\"name\":\"Limited Liability Clause\",\"is_present\":false,\"status\":\"Rejected\",\"remarks\":null,\"error\":\"Customers are not being made to accept the Limited Liability Clause before making the payment for the product/service\"},{\"name\":\"Shipping/Membership Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Cancellation Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Return Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null},{\"name\":\"Refund Policy\",\"is_present\":false,\"status\":\"Not Applicable\",\"remarks\":null,\"error\":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jv"}}]',true,90000, 5600,'Approved','Rejected');
        test.stopTest();
        system.assertEquals('Website OK', opportunityObj.Website_Status__c);
    }
    
    @isTest static void testMethod4(){ 
        Opportunity opportunityObj = [SELECT id, AccountId, Website_Status__c,NDX_Score__c, MCC_Code__c, Base_Merchant_Id__c,Partner__c,Pre_Approved_for_priority_settlement__c, Max_Same_Day_Settlement_Amount__c FROM Opportunity LIMIT 1];
        opportunityObj.Website_Status__c = 'Verification in Process';
        update opportunityObj;
        
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Contact Us Details' LIMIT 1];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj.Page_Details__c = wpm.Page_Details__c;
        Test.startTest();
        insert websitePageObj;
        WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus(opportunityObj.id, 'Verification in Process','1231','A',true,'[{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise","Risk_Rating__c":""},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR5EAM","Name":"Contact Us Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{"name":"Functional email ID","status":"Approved","is_present":false,"error":null,"remarks":null},{"name":"Functional contact number","status":"Rejected","is_present":false,"error":"No functional Contact Number is mentioned on your website/app","remarks":null},{"name":"Functional address","status":"Not Applicable","is_present":false,"error":null,"remarks":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"ghvg"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR6EAM","Name":"Product/Services Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{"name":"Legal Products/Services","is_present":false,"status":"Approved","remarks":null,"error":null},{"name":"No re-directions to other URLs","is_present":false,"status":"Rejected","remarks":null,"error":"Your website is getting re-directed to some other URL"},{"name":"Detailed Description","is_present":false,"status":"Not Applicable","remarks":null,"error":null},{"name":"Correct Pricing","is_present":false,"status":"Not Applicable","remarks":null,"error":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jhvjh"}},{"isEditAllow":true,"isObjectEditable":true,"isRiskRemark":true,"isSalesRemark":true,"isStatus":true,"isURL":true,"latestCommentsObj":{"Id":"a2G7200000017yjEAA","Active__c":true,"Comment_By__c":"Salesforce"},"lstWebsitePageStatus":["Not Applicable","Pending","Approved","Rejected","Verification in Process"],"OppObj":{"Id":"0060p000007jk1mAAA","Website_Status__c":"Website Error","Integration_Type__c":"ThirdParty","MCC_Code__c":"3432","Website__c":"Friendscorner.com","NDX_Score__c":90000,"Merchant_Business_Type__c":"Enterprise"},"pageDetails":true,"userObj":{"Id":"0057F000005HnHYQA0","Name":"Shivdeep Yadav","ProfileId":"00e7F000002zRq5QAE","Super_User__c":true,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"websiteDetailsObj":{"Id":"a2F720000001tIbEAI","Website_Status__c":"Website Error"},"WebsitePageObj":{"Id":"a0Y0p0000011MR4EAM","Name":"Terms & Conditions Details","Opportunity__c":"0060p000007jk1mAAA","Do_Not_Publish__c":false,"Status__c":"Pending","URL__c":"test.com","Page_Details__c":"[{"name":"Advanced Booking Duration","is_present":false,"status":"Approved","remarks":null,"error":null},{"name":"Limited Liability Clause","is_present":false,"status":"Rejected","remarks":null,"error":"Customers are not being made to accept the Limited Liability Clause before making the payment for the product/service"},{"name":"Shipping/Membership Policy","is_present":false,"status":"Not Applicable","remarks":null,"error":null},{"name":"Cancellation Policy","is_present":false,"status":"Not Applicable","remarks":null,"error":null},{"name":"Return Policy","is_present":false,"status":"Not Applicable","remarks":null,"error":null},{"name":"Refund Policy","is_present":false,"status":"Not Applicable","remarks":null,"error":null}]","Active__c":true,"Opportunity__r":{"AccountId":"0010p00000e6QUPAA2","Name":"7200612","Website_Status__c":"Website Error","MCC_Code__c":"3432","NDX_Score__c":90000,"Integration_Type__c":"ThirdParty","Blacklist__c":false,"Merchant_Business_Type__c":"Enterprise","Id":"0060p000007jk1mAAA","Account":{"NDX_Score__c":90000,"Id":"0010p00000e6QUPAA2"}},"Risk_Remarks__c":"jv"}}]',true,100000, 9000,'Approved','Rejected');
        WebsiteStatusMaintanenceController_Onb.createComments('sad', 'Merchant', 'Salesforce', null, opportunityObj.Id);
        test.stopTest();
        system.assertEquals('Verification in Process', opportunityObj.Website_Status__c);
    }
        
}