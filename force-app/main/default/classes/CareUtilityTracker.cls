@isTest(seealldata=false)
public class CareUtilityTracker {    
    
    @isTest
    public static void getPayloadDataTest(){
        List<PayloadActMap__mdt> payloadList =[Select id,action__c,JsonMap__c from PayloadActMap__mdt where masterLabel=:'MerchantCareForCase'];
        
        Account oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;        
        
        Contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '44444444';
        insert oContact;
        
        Case merchantCase=new Case();
        merchantCase.ContactId=oContact.id;
        merchantCase.AccountId=oAccount.id;
        merchantCase.Status='Pending';
        merchantCase.LP_sub_status__c='Waiting On Merchant';
        merchantCase.Priority='high';
        merchantCase.Origin = 'App';
        merchantCase.Identifier__c = '3295-15e8-02fc45e7-270e-b388e09d554a';
        merchantCase.LP_Transaction_status__c='Success';
        merchantCase.LP_Transaction_ID__c='65656';
        merchantCase.LP_Business_Vertical__c='LazyPay';
        merchantCase.LP_Category__c='BNPL';
        merchantCase.LP_Issue__c = 'What is LazyPay?';
        merchantCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert merchantCase;
        
        Case kycCase=new Case();
        kycCase.ContactId=oContact.id;
        kycCase.AccountId=oAccount.id;
        kycCase.Status='Pending';
        kycCase.LP_sub_status__c='Waiting On Merchant';
        kycCase.Priority='high';
        kycCase.Origin = 'App';
        kycCase.Identifier__c = '3295-15e8-02fc45e7-270e-b388e09e324a';
        kycCase.LP_Transaction_status__c='Success';
        kycCase.LP_Transaction_ID__c='65656';
        kycCase.LP_Business_Vertical__c='LazyPay';
        kycCase.LP_Category__c='BNPL';
        kycCase.LP_Issue__c = 'What is LazyPay?';
        kycCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        insert kycCase;
        
        Attachment attach = New Attachment();
        attach.parentId=merchantCase.Id;
        attach.Body = blob.valueOf('sdvfsdvs');
        attach.Name = 'test';
        insert attach;
        
        string updateNach = 'updateNach';
        string merchantCare = 'MerchantCare';
        //CareUtility.getPayloadData(updateNach);
        //CareUtility.getPayloadData(merchantCare);
        //CareUtility.getAttachmentBody(attach,'wertyui');
        string businessVertical = 'LazyPay';
        string subVertical = 'Social';
        string businessVerticalPayu = 'Payu Money';
        string subVerticalPayu = 'Payu Money';
        CareUtility.getDuplicacyAndOwnership(businessVertical, subVertical);
        //CareUtility.getDuplicacyAndOwnership(businessVerticalPayu, subVerticalPayu);
        CareUtility.OwnerAndDedupeWrapper wrap = new CareUtility.OwnerAndDedupeWrapper();
        string  con = 'Contact';
        string objectName = 'Case';
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        sObject sObjCon = Schema.getGlobalDescribe().get(con).newSObject() ;
        //Careutility.populateObjectData(con, null, Null);
        case case1 = new case ();
        // Case Case = 'Case';
        String node = 'status';
        String fieldApi = 'email,Date,DateTime,Decimal';
        String data = '44444444';
        
        //CareUtility.populateField(case1, node, fieldApi, data, objectName);
        //CareUtility.populateField(sObj, node, fieldApi, data, objectName);
        //CareUtility.populateField(sObjCon, node, fieldApi, data, objectName);
    }
    
}