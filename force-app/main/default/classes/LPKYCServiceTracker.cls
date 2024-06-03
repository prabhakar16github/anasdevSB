@isTest
public class LPKYCServiceTracker {
	public static LP_KYC_Document__c oKYCDocument;
    public static case oCase; 
    public static PayloadActMap__mdt oPayloadActMap ;
	
    
    @isTest
    Public static  void createCaseAndContact(){
        loadData();
        Payload_Log__c objpayload = [select id,Payload__c from Payload_Log__c limit 1 ];
        system.debug('payload value' + objpayload.Payload__c);
        try{LPKYCService.createCaseAndContact(objpayload.Payload__c);}catch(exception ex){}
        
         try{LPKYCService.prepareListOfArrayNodes(null, null);}catch(exception ex){}
        LPKYCService.populateField(null, null, null, null, null);
        String todate = '2019-02-25 16:45:12'; 
        try{LPKYCService.populateField(null, null, todate, null, null);}catch(exception ex){}
        string node = 'products';
        string sobj = 'LP_KYC_Document__c';
        string data = 'test,dgd';
        try{LPKYCService.populateField(null, node, todate, data, sobj);}catch(exception ex){}
         
        LPKYCService.valueFormatToLowerCase('test');
       
        LPKYCService.getDateAndTime(todate);
        
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
        
        Payload_Log__c objPayload = new Payload_Log__c();
            objPayload.Payload__c = '{"producer":"LazyPay","current_data":{"kycDateCreated":"2019-01-23 16:32:27","status":"REPAY_IN_PROGRESS","payloadId":"423593-1551093312414-MANUAL_DOCUMENTS_DECLINED-DOCUMENTS_PENDING","caseDateUpdated":"2019-02-25 16:19:36","email":"ishant.gupta@payu.in","products":["CREDIT_LINE"],"caseDateCreated":"2018-12-22 13:40:35","timestamp":"2019-02-25 16:45:12","kycTypeId":"AADHAAR_WITH_DOCUMENTS","recordTypeName":"KYC","documentList":[{"value":null,"documentTypeId":"IPV_SELFIE","remarks":null,"dateCreated":"2019-02-17 17:57:16","dateUpdated":"2019-02-17 17:57:16","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_IPV_SELFIE_f5762f8ced2b4a5184920ad5e890c7da.jpeg","documentId":2436943,"status":"UPLOADED","systemType":"KYC","documentName":"Selfie"},{"value":null,"documentTypeId":"ADDITIONAL_DOC_BACK","remarks":{"0":"Invalid Document - Screenshot/ photo of a photo"},"dateCreated":"2019-02-17 18:07:49","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_ADDITIONAL_DOC_BACK_73521fd1342e4a42a7e35e8cb067b217.jpeg","documentId":2436998,"status":"DECLINED","systemType":"KYC","documentName":"Additional document back"},{"value":null,"documentTypeId":"ADDITIONAL_DOC_FRONT","remarks":{"0":"Invalid Document - Screenshot/ photo of a photo"},"dateCreated":"2019-02-17 18:07:23","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_ADDITIONAL_DOC_FRONT_f8438841bf1c45ec8b181ad013cb124e.jpeg","documentId":2436993,"status":"DECLINED","systemType":"KYC","documentName":"Additional document front"},{"value":null,"documentTypeId":"AADHAAR_FRONT","remarks":{"0":"Quality - Poor quality/Unreadable"},"dateCreated":"2019-02-17 17:55:45","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_AADHAAR_FRONT_8bac6ad6b8ec4f9091e528d501f1f986.jpeg","documentId":2436925,"status":"DECLINED","systemType":"KYC","documentName":"Aadhaar Front Photo"},{"value":null,"documentTypeId":"OSV_SIGNATURE","remarks":null,"dateCreated":"2019-02-17 17:58:40","dateUpdated":"2019-02-17 17:58:40","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_OSV_SIGNATURE_0a6d0d7c194247a6b2959cfc6d1956a4.jpeg","documentId":2436950,"status":"UPLOADED","systemType":"KYC","documentName":"Signature"},{"value":null,"documentTypeId":"AADHAAR_BACK","remarks":{"0":"Quality - Poor quality/Unreadable"},"dateCreated":"2019-02-17 17:56:28","dateUpdated":"2019-02-25 16:45:12","url":"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/6920876865812833118_AADHAAR_BACK_bc778d4ba78049ce821a956facba42d8.jpeg","documentId":2436932,"status":"DECLINED","systemType":"KYC","documentName":"Aadhaar Back Photo"}],"kycDateUpdated":"2019-02-25 16:45:12","mobile":"9582033021","overrideExistingData":false,"kycStatus":"DOCUMENTS_PENDING","kycState":"MANUAL_DOCUMENTS_DECLINED","kycCaseId":423593,"uuid":"6920876865812833118"},"timestamp":"2019-02-25 16:45:12","identifier":"6920876865812833118","action":"upsert_kyc_detail","business_object":"Customer","product":"LazyPay"}';
             insert objPayload;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    }  
	
     public static void NachloadData()   
    {
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='5536715202349341447';
        insert oContact;
      
        
        Payload_Log__c objPayload = new Payload_Log__c();
        objPayload.Payload__c = '{"business_object":"Customer","producer":"LazyPay","product":"LazyPay","action":"Upsert_Nach","identifier":"6870582168296003378","payloadId":"829-ACCEPTED-2019-06-17 19:40:11","timestamp":"2019-06-19 20:09:16.308","current_data":{"uuid":"5536715202349341447","nachMethod":"NET_BANKING","nachVendor":"RAZOR_PAY","nachStatus":"ACCEPTED","nachMaxAmount":"99999.0","nachCreatedDate":"2019-06-12 14:47:19","nachUpdatedDate":"2019-06-17 19:40:11","nachExpiryDate":"2024-06-15 12:00:00","nachId":829,"nachFormUnsigned":null,"nachFormSigned":null,"nachRejectedBy":null,"nachRejectionCode":null,"nachRejectionMessage":null}}';    
        insert objPayload;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    }
	
    @isTest
    Public static  void updateContact(){
        NachloadData();
        Payload_Log__c objpayload = [select id,Payload__c from Payload_Log__c limit 1 ];
        system.debug('payload value' + objpayload.Payload__c);
       LPKYCService.createCaseAndContact(objpayload.Payload__c);
        //NachService.updateContact(objpayload.Payload__c);
    }
}