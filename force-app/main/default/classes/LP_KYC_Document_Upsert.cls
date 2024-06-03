public class LP_KYC_Document_Upsert {

    public static  PayloadActMap__mdt thePayLoadMap;
    public static List<Object> docListArray;
    public static List<LP_KYC_Document__c> kycDocList  = new  List<LP_KYC_Document__c>();
    public static Map<String,String> mapOfResponse;
    public static Map<String,Object> jsonbaseMap = new  Map<String,Object>();
    static map<String,String> mapOfDocNameVsDocId = new map<String,String>();
    static map<String,String> mapOfDocIdVsDocName = new map<String,String>();
    static String docTypeId = '';
   
     public static void documentService(String currentData){ 
     System.debug('Json String **' + currentData);
     Map<String,String> fieldMap1 ;
     thePayLoadMap =  [select action__c , JsonMap__c ,Sobject__c , JSONMapPub__c ,LookUpField__c ,Related_Object__c  From PayloadActMap__mdt where action__c = 'upsert_KYC_Documents'];    
    //deserialize json string into map
    Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);         
    Map<String,Object> jsonBaseMap = (Map<String,Object>)jsonMap.get('current_data');         
    Map<String,Object> documentMap = (Map<String,Object>)(jsonBaseMap.get('documentObj'))  ;
    
    docTypeId = (String)documentMap.get('documentTypeId'); 
    System.debug('docTypeId' + docTypeId);
    //prepare document map to fill the documsnt master field lookup value on kyc document
        System.debug('Fill Doc Map called **' );  
        fillDocumentMap(thePayLoadMap,docTypeId); 
    system.debug('jsonMap***' + jsonMap);            
    jsonbaseMap =(Map<String,Object>)jsonMap;
    System.debug('jsonbaseMap**' + jsonbaseMap);
    System.debug('documentMap***' + documentMap);     
    Object docObject;                 
    //create logs of KYC consumption
    Payload_log__c thelog = new Payload_log__c();
    theLog.Producer__c=String.valueOf(jsonbaseMap.get('producer'));
    theLog.Business_Object__c =String.ValueOf(jsonbaseMap.get('business_object'));
    theLog.Action__c = 'Insert_Missing_KYC_Document' ;
    theLog.Payload__c = CurrentData; 
  
    try{ 
     //String action = String.ValueOf(jsonbaseMap.get('action'));    
         LP_KYC_Document__c kycDocObject = new LP_KYC_Document__c();
         sObject objCreated = populateObject( thePayLoadMap , documentMap , kycDocObject);
         System.debug('objCreated**' + objCreated);
         
         // Populate the additional field values
         if(documentMap.containsKey('value') && documentMap.get('value') != null){
             
             //fieldMap = (Map<String,String>)JSON.deserialize(documentMap.get('value'), Map<String,String>.class) ;
             String fieldMap2 = String.valueOf(documentMap.get('value'));
             Map<String, string> fieldMap = (Map<String, string>)JSON.deserialize(fieldMap2, Map<String, string>.class);
             System.debug('fieldMap**' + fieldMap); 
             String documentTypeId = (String)documentMap.get('documentTypeId');
             System.debug('DocumentTYpeId ***' + documentTypeId); 
             System.debug('thePayLoadMap.JSONMapPub__c**' + thePayLoadMap.JSONMapPub__c);
             Map<String,String> mapOfDocWithFields =  (Map<String,String>)JSON.deserialize(thePayLoadMap.JSONMapPub__c, Map<String,String>.class);
             if(mapOfDocWithFields.containsKey(documentTypeId) ){
                String docFieldvalues = mapOfDocWithFields.get(documentTypeId);
                System.debug('docFieldvalues**' + docFieldvalues);
                for(String fieldmapping : docFieldvalues.split(';')){
                    System.debug('fieldmapping***'+ fieldmapping);
                    populateField(objCreated,fieldmapping.substringBefore(':'),fieldmapping.substringAfter(':'), String.valueOf(fieldMap.get(fieldmapping.substringBefore(':'))),'LP_KYC_Document__c'); 
                } 
             }
          }
         
         LP_KYC_Document__c kycDoc =  (LP_KYC_Document__c)objCreated;
         System.debug('Doc Created **' + kycDoc);
         LP_KYC_Document__c kycDocNew =  checkOfExistingDoc(kycDoc);
         kycDocList.add(kycDocNew);
     
        upsert  kycDocList;
        System.debug('kycDocList***' + kycDocList);
        if(kycDocList.size() > 0){
            theLog.Status__c = 'SUCCESS';
            insert theLog; 
        }
                        
        //prepare return response       
      /*  mapOfResponse = new map<string,string>();
        mapOfResponse.put('State','Success'); 
        RestResponse res = RestContext.response; 
        res.addHeader('Content-Type', 'Application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
        res.statusCode = 200; 
      */
        
     } catch(Exception ex){            
        //prepare return response
        theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); 
        theLog.Status__c = 'Error';
        insert theLog;
     /*   map<string,string> mapOfResponse = new map<string,string>();
        mapOfResponse.put('State','Error');
        mapOfResponse.put('message',ex.getMessage());               
        RestResponse res = RestContext.response; 
        res.addHeader('Content-Type', 'Application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
        res.statusCode = 500;  
       */
       }
       
    }     
    
    public static LP_KYC_Document__c checkOfExistingDoc(LP_KYC_Document__c kycDoc){
       LP_KYC_Document__c kycDocument = kycDoc;
       String query = 'select id , LP_Document_ID__c,LP_Case__c FRom LP_KYC_Document__c where LP_Document_ID__c =\'' + kycDoc.LP_Document_ID__c + '\'';
       List<LP_KYC_Document__c> kycDocs =database.query(query) ;   
 
        if(kycDocs.size() >0){
           kycDocument.put('Id', kycDocs[0].Id);  
        } 
        System.debug('Document Existing ***' + kycDoc);
        return kycDocument;
    }
        
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to populate the data into objects
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static sObject populateObject(PayloadActMap__mdt thePayLoadMap , Map<String,Object>jsonRootMap , sObject sobToInsert){
     System.debug('jsonRootMap***' + jsonRootMap);
     System.debug('thePayLoadMap**' + thePayLoadMap);
      System.debug('sobToInsert**Earlier ' + sobToInsert);  
      Map<String, String> jsonFieldMap;     
     if(String.isNotBlank(thePayLoadMap.JsonMap__c)){
           jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
           system.debug('jsonFieldMap**' + jsonFieldMap);
     } 
        
  
     if(jsonFieldMap!= NULL && jsonFieldMap.size()>0){
       // LP_KYC_Document__c kycDoc = new LP_KYC_Document__c(); 
        for(String eachKey : jsonFieldMap.keyset()){
            if(jsonRootMap.containsKey(eachKey) ){
               populateField(sobToInsert,eachKey,jsonFieldMap.get(eachKey),String.valueOf(jsonRootMap.get(eachKey)),thePayLoadMap.Sobject__c); 
            }             
          }
        }
        System.debug('sobToInsert**Pupulated' + sobToInsert);
        return sobToInsert;           
    }    
                                      
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to populate the data into objects
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
        public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data,String SObjectName){
               
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){            
            if(fieldAPI.subStringAfter(',') == 'Date'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Date.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'DateTime'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),DateTime.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'Decimal'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Decimal.valueOf(data));
            } 
			else if(mapOfDocNameVsDocId != NULL && mapOfDocNameVsDocId.size()>0 && String.isNotBlank(node) && node == 'documentTypeId'){
                 //Commenting code for Master document
                 System.debug('data **' + data); 
                 System.debug('fieldAPI.subStringBefore*****'+ fieldAPI.subStringBefore(','));
                 System.debug('mapOfDocNameVsDocId.get(data)***' + mapOfDocNameVsDocId.get(data));
                 sobToUpsert.put(fieldAPI.subStringBefore(','), mapOfDocNameVsDocId.get(data));
            }else{
				sobToUpsert.put(fieldAPI.subStringBefore(','),data);
			}           
        }
    }
   
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to prepare the map which contain the document name and its id and this map is usd to populate document master lookup on KYC documemnt record 
    
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static void fillDocumentMap(PayloadActMap__mdt thePayLoadMap, String docTypeId){
  
                         
      string strQuery = 'Select id , Document_Type__r.Name  FRom Document_Master__c where Document_Type__r.Name  = ' + ' \''+ docTypeId + '\'';
      system.debug('strQuery=========='+strQuery);
      for(Document_Master__c docMaster : Database.query(strQuery)){
          mapOfDocNameVsDocId.put(docMaster.Document_Type__r.Name,docMaster.Id);
      }
    }
}