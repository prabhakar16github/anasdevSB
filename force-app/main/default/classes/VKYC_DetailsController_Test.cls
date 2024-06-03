@isTest
public class VKYC_DetailsController_Test {
    @isTest
    static void test1(){
        Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test contact';
        con.AccountId = acc.Id;
        con.Email = 'test@abc.com';
        con.Authorised_Signatory__c = true;
        con.Active__c = true;
        con.PAN__c = 'BAACA1234T';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Last_txn_date__c = System.today().addDays(-210);
        opp.CloseDate = System.today();
        opp.Identifier__c = 'abcd-1122-xyz-555-qwert';
        insert opp;
        
        Video_KYC__c vk = new Video_KYC__c();
        vk.Opportunity__c = opp.Id;
        vk.Active__c = true;
        vk.Capture_Link__c = 'test.payu.in';
        vk.Status__c = 'Pending';
        vk.Link_Created_At__c = System.today().addDays(-15);
        insert vk;
        
        VKYC_DetailsController.Vkyc_Wrapper wrap = VKYC_DetailsController.getVKYC_details(opp.Id);
        VKYC_DetailsController.getCurrentUserProfile();
        VKYC_DetailsController.generateLinkForVKYC(opp.Id);
        //Video_KYC__c vkyc = (Video_KYC__c)JSON.deserialize()
        VKYC_DetailsController.sendEmailWithVkycLink(opp.Id,JSON.serialize(wrap.vkycObj));
    }
    
    @isTest
    static void test2(){
        Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test contact';
        con.AccountId = acc.Id;
        con.Email = 'test@abc.com';
        con.Authorised_Signatory__c = true;
        con.Active__c = true;
        con.PAN__c = 'BAACA1234T';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Last_txn_date__c = System.today().addDays(-210);
        opp.CloseDate = System.today();
        opp.Identifier__c = 'abcd-1122-xyz-555-qwert';
        //insert opp;
        
        Video_KYC__c vk = new Video_KYC__c();
        vk.Opportunity__c = opp.Id;
        vk.Active__c = true;
        vk.Capture_Link__c = 'test.payu.in';
        vk.Status__c = 'Pending';
        vk.Link_Created_At__c = System.today().addDays(-15);
        insert vk;
        
        VKYC_DetailsController.Vkyc_Wrapper wrap = VKYC_DetailsController.getVKYC_details(opp.Id);
        VKYC_DetailsController.getCurrentUserProfile();
        VKYC_DetailsController.generateLinkForVKYC(opp.Id);
        //VKYC_DetailsController.sendEmailWithVkycLink(opp.Id,JSON.serialize(wrap.vkycObj));
    }

}