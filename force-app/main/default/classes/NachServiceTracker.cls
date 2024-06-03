@isTest
public class NachServiceTracker {
    public static LP_KYC_Document__c oKYCDocument;
    public static case oCase; 
    public static PayloadActMap__mdt oPayloadActMap ;
    
    @isTest
    Public static  void updateContact(){
        loadData();
        Payload_Log__c objpayload = [select id,Payload__c from Payload_Log__c limit 1 ];
        system.debug('payload value' + objpayload.Payload__c);
       // NachService.updateContact(objpayload.Payload__c);
        NachService.updateContact(objpayload.Payload__c);
    }
    
    public static void loadData()   
    {
        Account oAccount = CommonDataTracker.InsertAccount('Test','Test','bwbpk7166d'); 
        insert oAccount;
        
        Contact oContact = CommonDataTracker.InsertContact(oAccount); 
        oContact.Identifier__c='5536715202349341447';
        insert oContact;
        
     /*   oCase = CommonDataTracker.CreateCase(oAccount,oContact,'Pending');
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
        insert objMaster; */
        
        Payload_Log__c objPayload = new Payload_Log__c();
           // objPayload.Payload__c = '{"nachData":"{\"business_object\":\"Customer\",\"action\":\"Upsert_Nach\",\"identifier\":\"6501778201014309979\",\"product\":\"LazyPay\",\"producer\": \"LazyPay\",\"payloadId\":\"308404-1547230283000-UNDER_MANUAL_VERIFICATION-VERIFICATION_IN_PROGRESS\",\"current_data\":{\"uuid\":\"6501778201014309979\",\"nachMethod\": \"testt\",\"nachVendor\":\"tessttt\",\"nachStatus\":\"Verified\", \"nachMaxAmount\":234,\"nachCreatedDate\":\"2019-02-06 14:37:36\", \"nachUpdatedDate\":\"2019-02-06 14:37:36\",\"nachExpiryDate\":\"2019-02-06 14:37:36\",\"nachId\":\"53535\",\"nachFormUnsigned\":\"testtt33\", \"nachFormSigned\":\"https://www.concursolutions.com\",\"nachRejectedBy\": \"teddd\",\"nachRejectionCode\":\"56565\",\"nachRejectionMessage\":\"ytytyt\"},\"timestamp\": \"2019-02-06 14:37:36\"}"}';
         objPayload.Payload__c = '{"business_object":"Customer","producer":"LazyPay","product":"LazyPay","action":"Upsert_Nach","identifier":"6870582168296003378","payloadId":"829-ACCEPTED-2019-06-17 19:40:11","timestamp":"2019-06-19 20:09:16.308","current_data":{"uuid":"5536715202349341447","nachMethod":"NET_BANKING","nachVendor":"RAZOR_PAY","nachStatus":"ACCEPTED","nachMaxAmount":"99999.0","nachCreatedDate":"2019-06-12 14:47:19","nachUpdatedDate":"2019-06-17 19:40:11","nachExpiryDate":"2024-06-15 12:00:00","nachId":829,"nachFormUnsigned":null,"nachFormSigned":null,"nachRejectedBy":null,"nachRejectionCode":null,"nachRejectionMessage":null}}';    
        insert objPayload;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    }

}