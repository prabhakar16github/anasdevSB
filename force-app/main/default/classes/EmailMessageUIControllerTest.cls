@isTest
public class EmailMessageUIControllerTest {
@isTest
    public static void testGetEmailMessageOnLoad() {
        Contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Verified';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        insert oCase;
        
        Intermediate_Object__c interObj = new Intermediate_Object__c();
        interObj.Record_Id__c = oCase.Id;
        interObj.Attachments_Files_name_in_the_one_drive__c = 'TestAttachment1,TestAttachment2';
        insert interObj;
        
        Test.startTest();
        EmailMessageUIController.getEmailMessageOnLoad(oCase.Id);
        EmailMessageUIController.getAttachmentAndFiles(oCase.Id);
        Test.stopTest();
    }
}