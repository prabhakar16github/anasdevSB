/**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this class is utility for careService 
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
public class CareUtility {
	
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to get the data from custom metadata  
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static map<string,PayloadActMap__mdt> getPayloadData(string action){
        map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = new map<string,PayloadActMap__mdt>();
        String queryStr = 'SELECT Action__c, Delete_Action__c, JSONfieldMap__c, JsonMapComp__c, SecondaryCond__c, SecondaryObject__c, JSONMapkeyArray__c, Related_Object__c, ArrayNodes__c, JSONMapPub__c, FieldsCheck__c, ReadOnly__c, JsonMap__c, Sobject__c, LookUpField__c,Field_To_Query__c FROM PayloadActMap__mdt WHERE ';        
        queryStr += 'Action__c =\'' + action + '\'';
        
        for(PayloadActMap__mdt payloaddt : Database.query(queryStr)){
            mapOfObjectNameVsPayload.put(payloaddt.Sobject__c,payloaddt);
        }
        
        return mapOfObjectNameVsPayload;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to get blob body of attachment 
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static blob getAttachmentBody(Attachment obj, string attachmentURL){
        
		blob bodyContent;
		if(String.isNotBlank(attachmentURL)){
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			string firstImageURL = attachmentURL;
			req.setEndpoint(firstImageURL);
			req.setMethod('GET'); 
			req.setCompressed(true); 
			req.setTimeout(60000); 
            HttpResponse res;
            if(!Test.isRunningTest()){
                res = h.send(req); 
                string responseValue = res.getBody(); 
                //system.debug('Response Body for File: ' + responseValue); 
                bodyContent = res.getBodyAsBlob();
            }else if(Test.isRunningTest()){
                bodyContent = blob.valueOf('test body');
            }
		}
		return bodyContent;
	}
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to get the data from custom metdata and store in wrapper to check the duplicacy 
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static OwnerAndDedupeWrapper getDuplicacyAndOwnership(string businessVertical, string subVertical){
        OwnerAndDedupeWrapper objwrapper;
        
        //String recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
		//System.debug('recordTypeName::'+recordTypeName);
        
        String queryStr = 'SELECT Business_Vertical__c,QueueId__c, Duplicate_Criteria__c, Queue_Name__c,L2_Queue_Id__c,L3_Queue_Id__c, Sub_Vertical__c FROM Duplicacy_And_Ownership__mdt WHERE ';        
        queryStr += 'Business_Vertical__c =\'' + businessVertical + '\' and Sub_Vertical__c=\'' + subVertical +'\'';
        system.debug('test queryStr'+ queryStr);
        
        list<Duplicacy_And_Ownership__mdt> lstMdt = Database.query(queryStr);
        
        if(lstMdt != NULL && lstMdt.size()>0){
            objwrapper = new OwnerAndDedupeWrapper();
            if(lstMdt[0].Queue_Name__c != NULL){
                objwrapper.ownerId = lstMdt[0].QueueId__c;
                objwrapper.mdtVal = lstMdt[0];
                if(lstMdt[0].Duplicate_Criteria__c != NULL)
                	objwrapper.mapOfFieldMapping = (Map<String, String>)JSON.deserialize(lstMdt[0].Duplicate_Criteria__c, Map<String, String>.class);
            }
        }
        
        return objwrapper;
    }
    
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to create/update object field values
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static SObject populateObjectData(string sObjectName,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,Map<String, Object> jsonRequestDataMap){
        sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();  
        string accmapVal = mapOfObjectNameVsPayload.get(sObjectName).JsonMap__c;
        map<string,string> mapOfAccountmapping = (Map<String, String>)JSON.deserialize(accmapVal, Map<String, String>.class);
        if(mapOfAccountmapping != NULL && mapOfAccountmapping.size()>0){
            for(string strNode : mapOfAccountmapping.keyset()){
                if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && jsonRequestDataMap.containsKey(strNode)){                   
                    populateField(sObj,strNode,mapOfAccountmapping.get(strNode),String.valueOf(jsonRequestDataMap.get(strNode)),sObjectName);
                    
                }
            }
        }
        
        system.debug('sObj=========='+sObj);
        return sObj;
    }
    
    public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data,string objectName){
        try{
           
           if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){           
            if(objectName == 'Case' && node == 'status'){
                if(String.valueOf(data) == 'REOPENED'){
                    sobToUpsert.put(fieldAPI.subStringBefore(','),'Re-Open');
                }
            }
           
            if(objectName == 'Nach_Data__c' && node == 'uuid'){
                string strQuery = 'SELECT id, (SELECT id FROM Cases WHERE recordtype.name=\'KYC\') FROM Contact WHERE Identifier__c = \''+ data +'\'';
                System.debug('strQuery========'+strQuery);
                list<Contact> lstContact = Database.query(strQuery);
                if(lstContact != NULL && lstContact.size()>0){
                    sobToUpsert.put(fieldAPI.subStringBefore(','),lstContact[0].Id);
                    if(lstContact[0].Cases != NULL && lstContact[0].Cases.size()>0)
                        //if(!Test.isRunningTest()){
                            sobToUpsert.put('Case__c',lstContact[0].Cases[0].Id);
                        //}
                    	
                }
                
            }
            
            else if(fieldAPI.subStringAfter(',') == 'Date'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Date.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'DateTime'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),DateTime.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'Decimal'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Decimal.valueOf(data));
            }
            else{
                sobToUpsert.put(fieldAPI.subStringBefore(','),data);
            }
            if(sobToUpsert.get('Identifier__c') != NULL){
                string strQuery = '';
                if(objectName == 'Contact'){
                    strQuery = 'Select id,LastName FROM ';
                }
                else{
                    strQuery = 'Select id FROM ';
                }
               strQuery += objectName +' WHERE Identifier__c=\'' + sobToUpsert.get('Identifier__c') + '\'';
               list<SObject> lst = Database.query(strQuery);
                if(lst != NULL && lst.size()>0){
                   sobToUpsert.put('Id',lst[0].Id);
                   if(objectName == 'Contact' && lst[0].get('LastName') != NULL){
                   		sobToUpsert.put('LastName',lst[0].get('LastName'));
                   }
                }
                
            }
        } 
        }catch(Exception ex){
            System.debug('ERROR: '+ex.getMessage());
        }
        
    }
    
    public class OwnerAndDedupeWrapper{
        public Id ownerId;
        public map<string,string> mapOfFieldMapping;
        public Duplicacy_And_Ownership__mdt mdtVal;
    }
}