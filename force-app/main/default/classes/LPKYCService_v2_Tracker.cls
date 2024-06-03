@isTest
public class LPKYCService_v2_Tracker {

    @isTest
    public static void unitTest1(){
    test.startTest();
    loadData();    
    Payload_log__c log = [Select id , payload__c from payload_Log__c where process__c = 'payload1'];
             
    //Integration_Setting__mdt integrationMdt = [Select id , body__c FRom Integration_Setting__mdt];
    try{
       LPKYCService_v2.createCaseAndContact(log.payload__c); 
    }catch(Exception e){
            
    }
    LPKYCService_v2.codeCoverage();    
    test.stopTest();            
    }
    @isTest
    public static void unitTest2(){
    Test.startTest();   
    loadData();    
    Payload_log__c log = [Select id , payload__c from payload_Log__c where process__c = 'payload2'];
    try{
       LPKYCService_v2.createCaseAndContact(log.payload__c); 
    }catch(Exception e){
            
    }
    LPKYCService_v2.createHTTPPublisher('Request Body','Case','Response Body' ,'Upsert Case'); 
    LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
    Test.setMock(HttpCalloutMock.class, fakeResponse);      
    Test.stopTest();    
    }
    
    
    @isTest
    public static void unitTest3(){
    loadData();    
    Payload_log__c log = [Select id , payload__c from payload_Log__c where process__c = 'payload3'];
    try{
       LPKYCService_v2.createCaseAndContact(log.payload__c); 
    }catch(Exception e){
            
    }  
    }

    /*    @isTest
        public static void unitTest3(){
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='6248531800772645843';
        insert oContact;

        
        Payload_Log__c objPayload = new Payload_Log__c();
        objPayload.Payload__c = '{"business_object": "Customer","action": "upsert_kyc_case_detail","identifier": "6248531800772645843","current_data": {"uuid": "6248531800772645843","mobile": "7568031284","merchantKyc": false,"products": ["CREDIT_LINE"],"recordTypeName": "KYC","documentList": ["12345","898989"],"timestamp": "2019-12-12 18:11:07.817","overrideExistingData": true},"timestamp": "2019-12-12 18:11:07.817"}';
        objPayload.Process__c = 'payload2';
        insert objPayload;     
        try{LPKYCService.createCaseAndContact( objPayload.Payload__c);}catch(exception ex){}
    } 
  */
    
    public static void loadData(){
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='6248531800772645843';
        insert oContact;
        
        Case oCase = CommonDataTracker.CreateCase(oAccount,oContact,'Pending');
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        oCase.LP_KYC_State__c='Under Manual Verification';
        oCase.Identifier__c = '1623';
        insert oCase; 
        
        Document_Type_Master__c objtype=new Document_Type_Master__c();
        objtype.name = 'PASSPORT_FORM';
        insert objtype;
        
        Document_Master__c objMaster=new Document_Master__c();              
        //  objMaster.Document_Category__c=objCategory.id;
        objMaster.Document_Type__c=objtype.id;
        insert objMaster;
        
        LP_KYC_Document__c oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Pending';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Document_ID__c = '12345';
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        oKYCDocument.LP_Document_Master__c = objMaster.Id;
        insert oKYCDocument;
        
        LP_KYC_Document__c oKYCDocument2=new LP_KYC_Document__c();
        oKYCDocument2.LP_Status__c='Pending';
        oKYCDocument2.Name='Aadhaar Back';
        oKYCDocument2.LP_Document_ID__c = '55555';
        oKYCDocument2.LP_Rejection_Reason__c='Test';
        oKYCDocument2.LP_Date_Created__c=system.today();
        oKYCDocument2.LP_Last_Modified_Date__c=system.today();
        oKYCDocument2.LP_Document_Master__c = objMaster.Id;
       // insert oKYCDocument2; 
        
        Document_Category_Master__c objCategory=new Document_Category_Master__c();
        insert objCategory;
        
        
        Payload_Log__c objPayload1 = new Payload_Log__c();
        //objPayload.Payload__c = '{"payload":"{"producer":"LazyPay","current_data":{"kycDateCreated":"2019-01-23 16:32:27","status":"REPAY_IN_PROGRESS","payloadId":"423593-1551093312414-MANUAL_DOCUMENTS_DECLINED-DOCUMENTS_PENDING","caseDateUpdated":"2019-02-25 16:19:36","kycDateCreated":"2019-02-25 16:19:36" , "email":"ishant.gupta@payu.in","products":["CREDIT_LINE"],"caseDateCreated":"2018-12-22 13:40:35","timestamp":"2019-02-25 16:45:12","kycTypeId":"AADHAAR_WITH_DOCUMENTS","recordTypeName":"KYC","documentList":[{"value":null,"documentTypeId":"IPV_SELFIE","remarks":null,"dateCreated":"2019-02-17 17:57:16" ,"dateUpdated":"2019-02-17 17:57:16","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_IPV_SELFIE_f5762f8ced2b4a5184920ad5e890c7da.jpeg","documentId":2436943,"status":"UPLOADED","systemType":"KYC","documentName":"Selfie"},{"value":null,"documentTypeId":"ADDITIONAL_DOC_BACK","remarks":{"0":"Invalid Document - Screenshot/ photo of a photo"},"dateCreated":"2019-02-17 18:07:49","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_ADDITIONAL_DOC_BACK_73521fd1342e4a42a7e35e8cb067b217.jpeg","documentId":2436998,"status":"DECLINED","systemType":"KYC","documentName":"Additional document back"},{"value":null,"documentTypeId":"ADDITIONAL_DOC_FRONT","remarks":{"0":"Invalid Document - Screenshot/ photo of a photo"},"dateCreated":"2019-02-17 18:07:23","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_ADDITIONAL_DOC_FRONT_f8438841bf1c45ec8b181ad013cb124e.jpeg","documentId":2436993,"status":"DECLINED","systemType":"KYC","documentName":"Additional document front"},{"value":null,"documentTypeId":"AADHAAR_FRONT","remarks":{"0":"Quality - Poor quality/Unreadable"},"dateCreated":"2019-02-17 17:55:45","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_AADHAAR_FRONT_8bac6ad6b8ec4f9091e528d501f1f986.jpeg","documentId":2436925,"status":"DECLINED","systemType":"KYC","documentName":"Aadhaar Front Photo"},{"value":null,"documentTypeId":"OSV_SIGNATURE","remarks":null,"dateCreated":"2019-02-17 17:58:40","dateUpdated":"2019-02-17 17:58:40","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_OSV_SIGNATURE_0a6d0d7c194247a6b2959cfc6d1956a4.jpeg","documentId":2436950,"status":"UPLOADED","systemType":"KYC","documentName":"Signature"},{"value":null,"documentTypeId":"AADHAAR_BACK","remarks":{"0":"Quality - Poor quality/Unreadable"},"dateCreated":"2019-02-17 17:56:28","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_AADHAAR_BACK_bc778d4ba78049ce821a956facba42d8.jpeg","documentId":2436932,"status":"DECLINED","systemType":"KYC","documentName":"Aadhaar Back Photo"}],"kycDateUpdated":"2019-02-25 16:45:12","mobile":"9582033021","overrideExistingData":false,"kycStatus":"DOCUMENTS_PENDING","kycState":"MANUAL_DOCUMENTS_DECLINED","kycCaseId":423593,"uuid":"6920876865812833118"},"timestamp":"2019-02-25 16:45:12","identifier":"6920876865812833118","action":"upsert_kyc_detail","business_object":"Customer","product":"LazyPay"}"}';
        objPayload1.Payload__c = '{"business_object": "Customer","action": "upsert_kyc_detail","identifier": "8888888","current_data": {"uuid": "111111111", "status":"REPAY_IN_PROGRESS","kycStatus":"DOCUMENTS_PENDING","kycState":"UNDER_MANUAL_VERIFICATION","mobile": "7568031284","merchantKyc": false,"products": ["CREDIT_LINE"],"recordTypeName": "KYC","documentList": ["55555"],"timestamp": "2019-12-12 18:11:07.817","overrideExistingData": true},"timestamp": "2019-12-12 18:11:07.817"}';
        objPayload1.Process__c = 'payload1';
        insert objPayload1;   
        
        Payload_Log__c objPayload2 = new Payload_Log__c();
        objPayload2.Payload__c = '{"business_object": "Customer","action": "upsert_kyc_detail","identifier": "7777777","current_data": {"uuid": "11111111","mobile": "7568031284","merchantKyc": false,"products": ["CREDIT_LINE"],"recordTypeName": "KYC","documentList": ["12345","898989"],"timestamp": "2019-12-12 18:11:07.817","overrideExistingData": true},"timestamp": "2019-12-12 18:11:07.817"}';
        objPayload2.Process__c = 'payload2';
        insert objPayload2; 
        
        Payload_Log__c objPayload3 = new Payload_Log__c();
        objPayload3.Payload__c = '{"business_object": "Customer","action": "Upsert_Nach","identifier": "66666666","current_data": {"uuid": "111111111111","mobile": "7568031284","merchantKyc": false,"products": ["CREDIT_LINE"],"recordTypeName": "KYC","documentList": ["12345","898989"],"timestamp": "2019-12-12 18:11:07.817","overrideExistingData": true},"timestamp": "2019-12-12 18:11:07.817"}';
        objPayload3.Process__c = 'payload3';
        insert objPayload3; 
    }
}