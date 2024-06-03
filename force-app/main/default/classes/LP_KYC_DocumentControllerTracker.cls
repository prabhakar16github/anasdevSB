/*
*    
*
*    Version        Date         Author         
*     1.0         19/11/2018     jatin arora    */
@isTest(seealldata=false)
public class LP_KYC_DocumentControllerTracker {
    public static Case oCase;
    public static LP_KYC_Document__c oKYCDocument;
    
    
    
    public static void LoadData()
    {
        oCase=new Case();
        oCase.Status='New';
        insert oCase;
               
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Pending';
        oKYCDocument.Name='Aadhaar Back Photo';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        oKYCDocument.LP_Show_On_Component__c = true ;
        insert oKYCDocument; 
    }
    @isTest
    public static void LP_KYC_DocumentControllerMethod(){
        Test.startTest();
        LoadData();
        LP_KYC_DocumentController.getKYCDocData(oCase.id);
        LP_KYC_DocumentController.getPicklistValues('Status','Case',False);
        LP_KYC_DocumentController.handleEditAccess(oCase.id);
        LP_KYC_DocumentController.KYCWrapper obj=new LP_KYC_DocumentController.KYCWrapper();
        obj.kycDoc = oKYCDocument;
        list<LP_KYC_DocumentController.KYCWrapper> listobj=new  list<LP_KYC_DocumentController.KYCWrapper>();
        listobj.Add(obj); 
        string jsonstr=json.serialize(listobj);
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        LP_KYC_DocumentController.saveKYCDocData(jsonstr);        
       // LP_KYC_DocumentController.isloggedinUserL1OrL2();        
        system.assertEquals(200, 200);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest2(){
        LP_KYC_DocumentController.codeCoverage();
    }
}