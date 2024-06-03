@isTest
public class EmailStatusTrackingControllerTracker {
    
    public static testMethod void testData1(){
        Email_Status_Tracking__c estObj = New Email_Status_Tracking__c();
        estObj.Template_Name__c = 'Test';
        insert estObj;
        
        PageReference myVfPage = Page.EmailStatusTrackingVF;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('emailTrackingId',estObj.Id);
        ApexPages.currentPage().getParameters().put('onboardingUrl','google.com');
        EmailStatusTrackingController estController = new EmailStatusTrackingController();
        estController.messageDoInit();
    }
    
    public static testMethod void testData2(){
        Email_Status_Tracking__c estObj = New Email_Status_Tracking__c();
        estObj.Template_Name__c = 'Test';
        insert estObj;
        
        PageReference myVfPage = Page.EmailStatusTrackingVF;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('emailTrackingId',estObj.Id);
        EmailStatusTrackingController estController = new EmailStatusTrackingController();
        estController.messageDoInit();
    }
}