@isTest
public class LP_KYC_Document_Upsert_Tracker {

    @isTest
    public static void unitTest1(){
    test.startTest();
    loadData();    
    Payload_log__c log1 = [Select id , payload__c from payload_Log__c where process__c = 'payload1'];             
    //Integration_Setting__mdt integrationMdt = [Select id , body__c FRom Integration_Setting__mdt];
    try{
       LP_KYC_Document_Upsert.documentService(log1.payload__c); 
    }catch(Exception e){            
    }
    test.stopTest();            
    }
    
    @isTest
    public static void unitTest2(){
    test.startTest();
    loadData();    
    Payload_log__c log2 = [Select id , payload__c from payload_Log__c where process__c = 'payload2'];
    system.debug('log2***' + log2);    
             
    //Integration_Setting__mdt integrationMdt = [Select id , body__c FRom Integration_Setting__mdt];
    try{
       LP_KYC_Document_Service.documentService(log2.payload__c); 
    }catch(Exception e){            
    }
    test.stopTest();         
    }
    
    public static void loadData(){
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='5536715202349341447';
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
        
        Document_Category_Master__c objCategory=new Document_Category_Master__c();
        insert objCategory;
        
        
        Payload_Log__c objPayload1 = new Payload_Log__c();
        objPayload1.Payload__c = '{"business_object":"Customer","action":"upsert_kyc_doc","identifier":"5657429304604567380","product":"LazyPay","producer":"LazyPay","current_data":{"payloadId":"20890-1575457116523-PASSPORT_BACK-UPLOADED","uuid":"5657429304604567380","documentObj":{"documentTypeId":"PASSPORT_BACK","documentId":20890,"systemType":"KYC","status":"UPLOADED","documentName":"Passport back photo","url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/5de4aaeefc1ef66a0280a670_PASSPORT_BACK_d00a72fbe8ef416c8989c19bc8dc447f.jpeg","dateUpdated":"2019-12-04 16:28:36","dateCreated":"2019-12-04 16:28:36"}},"timestamp":"2019-12-04 16:28:44.548"}';
        objPayload1.Process__c = 'payload1';
        insert objPayload1;   
        
        Payload_Log__c objPayload2 = new Payload_Log__c();
        //objPayload2.Payload__c = '{"business_object":"Customer","action":"upsert_kyc_doc","identifier":"5657429304604567380","product":"LazyPay","producer":"LazyPay","current_data":{"payloadId":"20890-1575457116523-PASSPORT_BACK-UPLOADED","uuid":"5657429304604567380","documentObj":{"documentTypeId":"PASSPORT_FORM", "value": "{\"GENDER\":\"MALE\"}","documentId":20890,"systemType":"KYC","status":"UPLOADED",   "documentName":"Passport back photo","url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/5de4aaeefc1ef66a0280a670_PASSPORT_BACK_d00a72fbe8ef416c8989c19bc8dc447f.jpeg","dateUpdated":"2019-12-04 16:28:36","dateCreated":"2019-12-04 16:28:36"}},"timestamp":"2019-12-04 16:28:44.548"}';
        objPayload2.Payload__c = '{"business_object":"Customer","action":"upsert_kyc_doc","identifier":"5657429304604567380","product":"LazyPay","producer":"LazyPay","current_data":{"payloadId":"20890-1575457116523-PASSPORT_BACK-UPLOADED","uuid":"5657429304604567380","documentObj":{"documentTypeId":"PASSPORT_FORM", "value": "{\"GENDER\":\"MALE\"}","documentId":20890,"systemType":"KYC","status":"UPLOADED",   "documentName":"Passport back photo","url":"https://s3.ap-south-1.amazonaws.com/document-pay-sbox/userDocuments/5de4aaeefc1ef66a0280a670_PASSPORT_BACK_d00a72fbe8ef416c8989c19bc8dc447f.jpeg","dateUpdated":"2019-12-04 16:28:36","dateCreated":"2019-12-04 16:28:36"}},"timestamp":"2019-12-04 16:28:44.548"}';
        objPayload2.Process__c = 'payload2';
        insert objPayload2; 
    }   
}