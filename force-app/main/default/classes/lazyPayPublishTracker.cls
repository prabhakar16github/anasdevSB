@isTest(seealldata=false)
public class lazyPayPublishTracker {
    public static list<Case> cselist;
    
     public static void LoadData()
    { 
        Case oCase=new Case();
        oCase.Status='open';
        oCase.Priority='High';
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        insert oCase;
        
        list<Case> cselist=new list<Case>();
        cselist.add(oCase);    
        
    }
     @isTest
    public static void lazyPayPublishMethod(){
        LoadData();
        lazyPayPublish.GenerateUniqueID();
        lazyPayPublish.valueFormatToUpperCase('New');
       try{lazyPayPublish.prepareKnowlarityResponsePayload(cselist,null,null);}catch(exception ex){}
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
      // try{lazyPayPublish.prepareKnowlarityResponsePayload(null,null,null);}catch(exception ex){}
      // try{LPKYCService.prepareListOfArrayNodes(null,null,null);}catch(exception ex){}
       try{lazyPayPublish.getCaseInfo(null);}catch(exception ex){}
        test.startTest();
        string thePayLoad;
        lazyPayPublish.PublishData(thePayLoad);
         lazyPayPublish.PublishDataToLPDB(thePayLoad,thePayLoad);
        test.stopTest();
        try{lazyPayPublish.sendPayLoaddata(null, null, null, null);}catch(exception ex){}
       try{lazyPayPublish.PublishPayLoad(null, null, null, null, null);}catch(exception ex){}
        lazyPayPublish.SendPayloadCaseData(new set<id>());
        try{lazyPayPublish.payLoadGenerator(null);}catch(exception ex){}
        try{lazyPayPublish.sendDataToKnowlarity(new list<case>(),null,null);}catch(exception ex){}
            try{lazyPayPublish.sendknowlarityResponse(new map<String,list<Case>>());}catch(exception ex){}
            try{lazyPayPublish.getObjectDataforArray(null,null,null);}catch(exception ex){}
        
        
}
}