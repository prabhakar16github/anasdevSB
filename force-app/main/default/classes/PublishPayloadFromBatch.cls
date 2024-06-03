public class PublishPayloadFromBatch implements Queueable, Database.AllowsCallouts {
    private Set<String> theFields = AWSConsumerBatch.getFieldSet('Opportunity');
    private Set<String> oppIds = new Set<String>();
    public PublishPayloadFromBatch(Set<String> oppIds){
        this.oppIds = oppIds;
    }
    public void execute(QueueableContext context) {
        if(oppIds.isEmpty()){
            return;
        }
        List<Payload_Log__c> payloadList = new List<Payload_Log__c>();
        
        for(Opportunity opp : Database.query('SELECT '+String.join(theFields,',')+' FROM Opportunity WHERE Id IN :oppIds')){
            payloadList.add(oldSendPayLoadData(opp, null, 'Opportunity', 'Lead',true));
        }
        if(!payloadList.isEmpty()){
            insert payloadList;
        }
    }
    
    public Payload_Log__c oldSendPayLoadData(Sobject newData, Sobject oldData, String sobName, String payLoadSobName,boolean multiproductEnabled){ 
        
        
        String action = 'update';
        
        PayloadActMap__mdt payloadActionMap;
        //queriedList = IntegrationUtility.getPayLoadMap(action, payLoadSobName, '');
        
        List<PayloadActMap__mdt> queriedList = IntegrationUtility.getPayLoadMap(action, payLoadSobName, '');
        System.debug('queriedList>>>>>>> '+queriedList);
        PayloadActMap__mdt merchantpayLoadMap;
        PayloadActMap__mdt productPayLoadMap;
        if(queriedList.size() > 0 && queriedList !=NULL){
            for(PayloadActMap__mdt payloadMeta : queriedList){
                if((payloadMeta.Business_Object__c == 'ProductAccount' && payloadMeta.Business_Object__c !=NULL) ){
                    productPayLoadMap = payloadMeta;
                }
                else if(payloadMeta.Business_Object__c == 'Merchant' ){
                    merchantpayLoadMap = payloadMeta;
                }else if (payloadMeta.Business_Object__c != 'Merchant' && payloadMeta.Business_Object__c != 'ProductAccount'){
                    payloadActionMap = payloadMeta;
                }
            }
            
            String thePayLoad = payLoadGenerator( newData,  oldData,payloadActionMap,theFields,payLoadSobName);
            //getAWSData(thePayLoad);
            HttpResponse response = new HttpResponse();
            if(!test.isRunningTest()){
                response = AWSUtility.getAWSData('SendMessage', null, Blob.valueOf(thePayLoad), '', null); 
            }else{
                response = new HttpResponse();
                response.setBody('');
                response.setStatusCode(200);// = 200;
            }
            Payload_Log__c theLog = new Payload_Log__c();
            theLog.Process__c = 'Salesforce Publisher - Bulk';
            theLog.Payload__c = thePayLoad; 
            theLog.Producer__c = 'Salesforce';
            
            if(response != null){
                theLog.Status__c = response.getStatusCode() == 200 ? 'SUCCESS' : 'ERROR';
                theLog.Exception__c = response.getStatusCode() + '\n\n' + response.getBody(); 
            }else{
                theLog.Status__c = null;
                theLog.Exception__c = null;
            }
            
            return insertPayloadLog(JSON.serialize(theLog));
            //payloadList.add());
            
        }
        return NULL;
    }
    
    public static String payLoadGenerator(Sobject newData, Sobject oldData, PayloadActMap__mdt thePayLoadMap, Set<String> theFields, string businessObjectName){        
        SYstem.debug('payloadName>>>>>>>>'+businessObjectName+'_'+thePayLoadMap.Action__c);
        
        Map<String, Object> payLoadMap = new Map<String, Object>();
        payLoadMap.put('producer', 'Salesforce');   
        
        payLoadMap.put('action', thePayLoadMap.Action__c);                              
        
        payLoadMap.put('current_data', IntegrationUtility.getObjectData(newData, thePayLoadMap, theFields));
        payLoadMap.put('old_data', IntegrationUtility.getObjectData(oldData, thePayLoadMap, theFields));
        payLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
        
        
        
        if(newData != null && theFields.contains('Payload_Header__c') && newData.get('Payload_Header__c') != null){   
            for(String each : String.valueOf(newData.get('Payload_Header__c')).split(',')){
                String theStr = each.subStringAfter(':'); 
                String headerAttrKey = each.subStringBefore(':');
                Object headerAttrValue = theStr.startsWith('static;') ? theStr.subStringAfter('static;'): newData.get(theStr);
                if(headerAttrKey == 'identifier' && businessObjectName =='Merchant'){
                    //   Do no Add identifier for Merchant Payloads. 
                }
                else{
                    payLoadMap.put(headerAttrKey, headerAttrValue);  
                }
                if(headerAttrKey =='business_object' && 
                   ((headerAttrValue =='Merchant' && businessObjectName =='ProductAccount') 
                    || (headerAttrValue =='ProductAccount' && businessObjectName =='Merchant'))){
                        payLoadMap.put(headerAttrKey, businessObjectName );
                    } 
                
            }
            if(businessObjectName =='ProductAccount'){
                //Do not publish MID information in ProductAccount Payload.
                if(payLoadMap.containskey('test_mid')){
                    payLoadMap.remove('test_mid');
                }
                if(payLoadMap.containskey('mid')) {
                    payLoadMap.remove('mid');
                } 
            }else if(businessObjectName =='Merchant'){ //|| businessObjectName =='Partner'){
                
                if(payLoadMap.containskey('merchant_account_identifier'))  payLoadMap.remove('merchant_account_identifier');
                if(!payLoadMap.containskey('test_mid'))  payLoadMap.put('test_mid',  newData.get('Merchant_Id__c'));
                if(!payLoadMap.containskey('mid'))  payLoadMap.put('mid', newData.get('Prod_Merchant_Id__c'));
            }
        }   
        return JSON.serialize(payLoadMap);                  
    }
    
    //@future
    public static Payload_Log__c insertPayloadLog(String theLogStr){  
        
        Payload_Log__c theLog = (Payload_Log__c)JSON.deserialize(theLogStr,Payload_Log__c.class);
        return theLog;
        //Database.insert(new List<Payload_Log__c>{theLog}, false);
    }
}