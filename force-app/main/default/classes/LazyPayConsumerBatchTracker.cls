@isTest
public class LazyPayConsumerBatchTracker {
    public static LP_KYC_Document__c oKYCDocument;
    public static case oCase; 
    public static PayloadActMap__mdt oPayloadActMap ;   
    
    @isTest
    Public static  void LazyPayConsumerBatch(){
        loadData();
        test.startTest();
        List<contact> conlist= new List<contact>();
        conlist.add(new contact(Identifier__c='5536715202349341447', Email='xyz@gmail.com', MobilePhone='9999999999', LastName='9999999999'));
        Map<string, Case> mapOfUUIDVsCase=new  Map<string, Case>();
       // oCase.contactid=null;
       // update oCase;
        mapOfUUIDVsCase.put(conlist[0].Identifier__c,oCase);
        LazyPayConsumerBatch objLazyPayConsumer=new LazyPayConsumerBatch();         
        objLazyPayConsumer.mapOfUUIDVsCase=mapOfUUIDVsCase;
        database.executeBatch(objLazyPayConsumer);
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,'Complete','<?xml version="1.0"?> <ReceiveMessageResponse xmlns="http://queue.amazonaws.com/doc/2012-11-05/"> <ReceiveMessageResult> <Message> <MessageId>945459b8-7318-47a4-be01-f6533ef0f494</MessageId> <ReceiptHandle>AQEBDjnQI2IOAzoy9OBnaPbrLtjcu+MPNKLnI1rAlJues+Sdu22pAJMGxVKV2wQXaKD1SygQmu0aLKP5dqwj1wq64lAXyTOgOprpO1uA9osvOui9jMvKyAWEt5lD2ipfnbWDntO8mJaqApbywn0vD8du3lriXaqI1538sZ9ONwaUOOXxbc/FZsIVDxDnbwrxSEsceUYTsY8KGsWNrIPoswtGqoqqaXaVl5O+b7QODDxiA27rmDkWEZ6YuUb9o3VhuvxDbXBDpVm+m586mdlXpLp7DGAPs39vbpbl21tuHqE9FKM=</ReceiptHandle> <MD5OfBody>35f602a82d1a8994ac80c12023ea7350</MD5OfBody> <Body>{"product":"LazyPay","business_object":"Customer","timestamp":"20181120T062532Z","current_data":{"uuid": "5536715202349341447","email":"xyz@gmail.com","mobile":"9999999999", "kycCaseId": "123" , "kycTypeId": "AADHAAR_WITH_DOCUMENTS", "kycStatus":"DOCUMENTS_PENDING", "kycState":"MANUAL_DOCUMENTS_DECLINED", "kycDateCreated":"2018-06-11 10:39:47", "kycDateUpdated":"2018-06-11 10:39:47", "status": "KYC_PENDING" , "caseDateCreated":"2018-06-11 10:39:47", "caseDateUpdated":"2018-06-11 10:39:47", "products" : ["WALLET"], "recordTypeName" : "KYC", "documentList":[ { "documentTypeId":"ONBOARDING_DOCUMENTS", "documentId":799, "systemType":"CREDIT_LINE", "status":"KYC_PENDING", "remarks":"", "documentName":"Onboarding User data", "url":"", "value":{"employmentStatus":"Salaried","nameOnPan":"Priyesh Mishra","consentStatement":"true","dobInOnboardingDocuments":"2018-06-11 10:39:47","gender":"Male","panNumber":"******225A","currentPinCode":"500067","monthlySalary":"1L+","currentAddress":"Banglore","caseId":799,"bureauAddresses":"NA"}, "dateCreated":"2018-06-11 10:39:47", "dateUpdated":"2018-06-11 10:39:47" }, { "documentTypeId":"OSV_SIGNATURE", "documentId":4144, "systemType":"KYC", "status":"DECLINED", "remarks":"", "documentName":"Signature", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_OSV_SIGNATURE_cb047fd7a72f49d2baf07c6ee39bcefd.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"IPV_SELFIE", "documentId":4143, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Selfie", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_IPV_SELFIE_5e741155b44347de9f1c7e64e91d96f3.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_FRONT", "documentId":4141, "systemType":"KYC", "status":"DECLINED", "remarks":"", "documentName":"Aadhaar Front Photo", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_FRONT_d6c51cc4f01a4fc7aee9fefdfd3db8bb.jpeg" ,"value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_BACK", "documentId":4142, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Aadhaar Back Photo", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_FORM", "documentId":4145, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"KYC Form", "url":null, "value":{"ADDRESSLINE1":"Gorakhpur","PINCODE":"273303","FORM_DECLARATION":"true","NAME":"Priyesh Mishra","DOB":"2018-06-11 10:39:47","GENDER":"MALE","AADHAAR_NO":"315606266270"}, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"ADDITIONAL_DOC_FRONT", "documentId":4146, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Additional document", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"ADDITIONAL_DOC_BACK", "documentId":4147, "systemType":"KYC", "status":"DECLINED", "remarks":null,"documentName":"Additional document","url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg","value":null,"dateUpdated":"2018-06-11 10:39:47","dateCreated":"2018-06-11 10:39:47"}],"timestamp" : "2018-06-11 10:39:47.200"},"action":"upsert_kyc_detail","producer":"LazyPay"} </Body> </Message> </ReceiveMessageResult> <ResponseMetadata> <RequestId>6477a616-831f-5d72-8a55-f27b5e7d16fa</RequestId> </ResponseMetadata> </ReceiveMessageResponse>',null); 
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        test.stopTest(); }
        
    
     @isTest
    Public static  void LazyPayConsumerBatch1(){
        loadData();
        test.startTest();
        List<contact> conlist= new List<contact>();
        conlist.add(new contact(Identifier__c='5536715202349341447', Email='xyz@gmail.com', MobilePhone='9999999999', LastName='9999999999'));
        Map<string, Case> mapOfUUIDVsCase=new  Map<string, Case>();
        oCase.contactid=null;
        update oCase;
        mapOfUUIDVsCase.put(conlist[0].Identifier__c,oCase);
        LazyPayConsumerBatch objLazyPayConsumer=new LazyPayConsumerBatch();         
        objLazyPayConsumer.mapOfUUIDVsCase=mapOfUUIDVsCase;
        database.executeBatch(objLazyPayConsumer);
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,'Complete','<?xml version="1.0"?> <ReceiveMessageResponse xmlns="http://queue.amazonaws.com/doc/2012-11-05/"> <ReceiveMessageResult> <Message> <MessageId>945459b8-7318-47a4-be01-f6533ef0f494</MessageId> <ReceiptHandle>AQEBDjnQI2IOAzoy9OBnaPbrLtjcu+MPNKLnI1rAlJues+Sdu22pAJMGxVKV2wQXaKD1SygQmu0aLKP5dqwj1wq64lAXyTOgOprpO1uA9osvOui9jMvKyAWEt5lD2ipfnbWDntO8mJaqApbywn0vD8du3lriXaqI1538sZ9ONwaUOOXxbc/FZsIVDxDnbwrxSEsceUYTsY8KGsWNrIPoswtGqoqqaXaVl5O+b7QODDxiA27rmDkWEZ6YuUb9o3VhuvxDbXBDpVm+m586mdlXpLp7DGAPs39vbpbl21tuHqE9FKM=</ReceiptHandle> <MD5OfBody>35f602a82d1a8994ac80c12023ea7350</MD5OfBody> <Body>{"product":"LazyPay","business_object":"Customer","timestamp":"20181120T062532Z","current_data":{"uuid": "5536715202349341447","email":"xyz@gmail.com","mobile":"9999999999", "kycCaseId": "123" , "kycTypeId": "AADHAAR_WITH_DOCUMENTS", "kycStatus":"DOCUMENTS_PENDING", "kycState":"MANUAL_DOCUMENTS_DECLINED", "kycDateCreated":"2018-06-11 10:39:47", "kycDateUpdated":"2018-06-11 10:39:47", "status": "KYC_PENDING" , "caseDateCreated":"2018-06-11 10:39:47", "caseDateUpdated":"2018-06-11 10:39:47", "products" : ["WALLET"], "recordTypeName" : "KYC", "documentList":[ { "documentTypeId":"ONBOARDING_DOCUMENTS", "documentId":799, "systemType":"CREDIT_LINE", "status":"KYC_PENDING", "remarks":"", "documentName":"Onboarding User data", "url":"", "value":{"employmentStatus":"Salaried","nameOnPan":"Priyesh Mishra","consentStatement":"true","dobInOnboardingDocuments":"2018-06-11 10:39:47","gender":"Male","panNumber":"******225A","currentPinCode":"500067","monthlySalary":"1L+","currentAddress":"Banglore","caseId":799,"bureauAddresses":"NA"}, "dateCreated":"2018-06-11 10:39:47", "dateUpdated":"2018-06-11 10:39:47" }, { "documentTypeId":"OSV_SIGNATURE", "documentId":4144, "systemType":"KYC", "status":"DECLINED", "remarks":"", "documentName":"Signature", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_OSV_SIGNATURE_cb047fd7a72f49d2baf07c6ee39bcefd.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"IPV_SELFIE", "documentId":4143, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Selfie", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_IPV_SELFIE_5e741155b44347de9f1c7e64e91d96f3.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_FRONT", "documentId":4141, "systemType":"KYC", "status":"DECLINED", "remarks":"", "documentName":"Aadhaar Front Photo", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_FRONT_d6c51cc4f01a4fc7aee9fefdfd3db8bb.jpeg" ,"value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_BACK", "documentId":4142, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Aadhaar Back Photo", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"AADHAAR_FORM", "documentId":4145, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"KYC Form", "url":null, "value":{"ADDRESSLINE1":"Gorakhpur","PINCODE":"273303","FORM_DECLARATION":"true","NAME":"Priyesh Mishra","DOB":"2018-06-11 10:39:47","GENDER":"MALE","AADHAAR_NO":"315606266270"}, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"ADDITIONAL_DOC_FRONT", "documentId":4146, "systemType":"KYC", "status":"DECLINED", "remarks":null, "documentName":"Additional document", "url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg", "value":null, "dateUpdated":"2018-06-11 10:39:47", "dateCreated":"2018-06-11 10:39:47" }, { "documentTypeId":"ADDITIONAL_DOC_BACK", "documentId":4147, "systemType":"KYC", "status":"DECLINED", "remarks":null,"documentName":"Additional document","url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/6862778809899468142_AADHAAR_BACK_5e52e8399180435e85e5a85837ba8fb1.jpeg","value":null,"dateUpdated":"2018-06-11 10:39:47","dateCreated":"2018-06-11 10:39:47"}],"timestamp" : "2018-06-11 10:39:47.200"},"action":"upsert_kyc_detail","producer":"LazyPay"} </Body> </Message> </ReceiveMessageResult> <ResponseMetadata> <RequestId>6477a616-831f-5d72-8a55-f27b5e7d16fa</RequestId> </ResponseMetadata> </ReceiveMessageResponse>',null); 
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        test.stopTest();
    }
    
    public static void loadData()   
    {
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='5536715202349341447';
        insert oContact;
        
        oCase = CommonDataTracker.CreateCase(oAccount,oContact,'Pending');
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        oCase.LP_KYC_State__c='Under Manual Verification';
        oCase.Identifier__c = '1623';
        insert oCase; 
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Pending';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;  
        
        Document_Category_Master__c objCategory=new Document_Category_Master__c();
        insert objCategory;
        
        Document_Type_Master__c objtype=new Document_Type_Master__c();
        insert objtype;
        
        Document_Master__c objMaster=new Document_Master__c();              
        //  objMaster.Document_Category__c=objCategory.id;
        //objMaster.Document_Type__c=objtype.id;
        insert objMaster;
    }  
}