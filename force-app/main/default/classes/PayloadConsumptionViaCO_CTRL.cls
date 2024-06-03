/*
* Name of the class : PayloadConsumptionViaCO_CTRL
* Author's Name     : Rohit Gupta  
* Created Date      : July, 2023
* Description       : Consume the payload which has been sent by CO team.
* Version.          : 1   
*/ 
@RestResource(urlMapping='/PayloadConsumptionCO/*')
global class PayloadConsumptionViaCO_CTRL {
    static Map<String, Schema.SObjectType> globalDescribe;
    /*******Returning the custom metadata payload Info *******/
    public static List<PayloadActMap__mdt> getPayLoadMap(String action,String businessObjName){  
        String queryStr = 'SELECT Action__c, Delete_Action__c,Business_Object__c, JSONfieldMap__c, JSON_map_Comp_2__c,JsonMapComp__c, JSONMapkeyArray2__c,SecondaryCond__c, SecondaryObject__c, JSONMapkeyArray__c, Related_Object__c, ArrayNodes__c, JSONMapPub__c, FieldsCheck__c, ReadOnly__c, JsonMap__c, Sobject__c, LookUpField__c ,Secondary_Object_Query_Fields__c,JSON_Map_sub_key_complex__c FROM PayloadActMap__mdt WHERE ';        
        queryStr += 'Action__c = \'' + action + '\'';
        queryStr += String.isNotBlank(businessObjName) ? ' AND Business_Object__c ='+'\''+ businessObjName + '\'': '';
        List<PayloadActMap__mdt> payloadList = Database.query(queryStr);    
        payloadList = !payloadList.isEmpty() ? payloadList : Database.query(queryStr.replace('Action__c = \'' + action + '\'', 'Delete_Action__c = \'' + action + '\''));                
        return payloadList;                
    }
    @HttpPost
    global static PayloadConsumptionViaCO_CTRL.Response PayloadConsumptionViaCO() {
        PayloadConsumptionViaCO_CTRL.Response responsePayload = new PayloadConsumptionViaCO_CTRL.Response() ;
        if(RestContext.request != null) {
            String requestBody = RestContext.request.requestBody.toString();
            Map<String, Object> payloadObjDataMap;
            Map<String, Object> settlementPalnMap;
            Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
            String action = String.valueOf(jsonRootMap.get('action'));// getting the action
            String prodAccUuid = String.valueOf(jsonRootMap.get('product_account_uuid'));// getting the action
            List<PayloadActMap__mdt> payloadActList =getPayLoadMap(action,'ProductAccount');// calling this method to get payload custom metadata details
            Set<String> theFields =new Set<String>();
            String theSobject;
            Sobject sobToUpsert;
            if(String.isNotBlank(action) && String.isNotBlank(prodAccUuid) && payloadActList !=NULL && !payloadActList.isEmpty() ){
                PayloadActMap__mdt thePayLoadMap = payloadActList[0];
                theSobject = thePayLoadMap.Sobject__c;
                schema.SObjectType prodAccObj = schema.getGlobalDescribe().get(theSobject);
                System.debug('theSobject::::::'+theSobject);
                theFields= AwsConsumerAPI_CTRL.getFieldSet(theSobject);
                sobToUpsert = prodAccObj.newSObject();
                try{                    
                    Map<String, String> jsonFieldMap;
                    if(String.isNotBlank(thePayLoadMap.JsonMap__c)){
                        jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
                        payloadObjDataMap = (Map<String, Object>)jsonRootMap;  
                        if( jsonRootMap.containsKey('priority_settlement_plan') !=NULL && jsonRootMap.containsKey('priority_settlement_plan')){
                            settlementPalnMap = (Map<String, Object>)jsonRootMap.get('priority_settlement_plan'); 
                            system.debug('settlementPalnMap::::::'+settlementPalnMap.keySet());
                        }  
                        Map<String, String> lookUpNodeMap;
                        // Below if condition is to map Sf fields and the fields which we are getting from the payloads
                        if(String.isNotBlank(thePayLoadMap.LookUpField__c)){
                            lookUpNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);                    
                        }
                        System.debug('product_account_uuid:::::'+ payloadObjDataMap);
                        String lookUpQueryStr='';
                        String lookUpFieldAPI ='';
                        // below for loop is to map the lookup to the parent 
                        for(String each : lookUpNodeMap.get('product_account_uuid').split(';')){
                            lookUpQueryStr = each.subStringAfter(',');
                            lookUpFieldAPI = each.subStringBefore(',');  
                            if(String.isNotBlank(lookUpFieldAPI) && theFields.contains(lookUpFieldAPI)){
                                String queryStr = 'SELECT Id FROM ' +  lookUpQueryStr.subStringBefore(':') + ' WHERE ' + lookUpQueryStr.subStringAfter(':') + ' = \'' + payloadObjDataMap.get('product_account_uuid') + '\'';          
                                System.debug('queryStr:::::'+queryStr);
                                List<Sobject> queriedList = Database.query(queryStr);
                                if(!queriedList.isEmpty()){
                                    sobToUpsert.put(lookUpFieldAPI, queriedList[0].Id); 
                                    system.debug('sobToUpsert=='+sobToUpsert);
                                    break;                   
                                }
                            }
                        }
                        // below code is to map parant the payload fields details and SF fields
                        for(String each : payloadObjDataMap.keySet()){
                            System.debug('each:::::::'+each);
                            if( jsonFieldMap.get(each) !=NULL && jsonFieldMap.containsKey(each)){
                                system.debug('jsonFieldMap.get(each):::::'+jsonFieldMap.get(each));
                                for(String eachJsonStr : jsonFieldMap.get(each).split(';')){
                                    sobToUpsert.put(eachJsonStr.subStringbefore(','), payloadObjDataMap.get(each));
                                     system.debug('sobToUpsert:::::'+sobToUpsert);
                                }     
                            }
                        }
                       system.debug('sobToUpsert::83:::'+sobToUpsert);
                        // below code is to map priority_settlement_plan details to SF fields on Product Account details object
                        if(settlementPalnMap !=null){
                            for(String each : settlementPalnMap.keySet()){
                                System.debug('each::::92:::'+each);
                                if( jsonFieldMap.get(each) !=NULL && jsonFieldMap.containsKey(each)){
                                    for(String eachJsonStr : jsonFieldMap.get(each).split(';')){
                                        SYstem.debug('eachJsonStr::97:::'+eachJsonStr);
                                        sobToUpsert.put(eachJsonStr.subStringbefore(','), settlementPalnMap.get(each));
                                    }     
                                }
                            }
                       }
                        String identiferValue = (String)sobToUpsert.get('Identifier__c');// getting the identifer
                        Schema.SObjectType sObjectType = sobToUpsert.getSObjectType();
                        String objName = String.valueOf(sObjectType);// getting the Salesforce Object Api Name
                        Schema.SObjectField identiferField = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get('Identifier__c');
                        Database.UpsertResult saveResultList =  Database.upsert(sobToUpsert,identiferField,false); // upserting the Record in SF
                        if(saveResultList.isSuccess()) {
                            if(!saveResultList.isCreated()) {
                                responsePayload.isUpdated = true;
                                responsePayload.isSuccess = saveResultList.isSuccess();
                                responsePayload.isCreated = saveResultList.isCreated();
                                responsePayload.message = 'Request has been successfully processed';
                            }
                            else if(saveResultList.isCreated()) {
                                responsePayload.isUpdated = false;
                                responsePayload.isCreated = saveResultList.isCreated();
                                responsePayload.isSuccess = saveResultList.isSuccess();
                                responsePayload.message = 'Request has been successfully processed';
                            }
                        }
                    }
                }
                catch(exception ex){
                    system.debug('getMessage:::::'+ex.getMessage());
                    // responsePayload.message = 'ERROR MESSAGE: '+ ex.getMessage();
                    responsePayload.isUpdated = false;
                    responsePayload.isCreated = false;
                    responsePayload.isSuccess = false;
                    responsePayload.message = 'Request has not been processed, please check required fields are missing';
                    return responsePayload;
                }
            }
            else{
                responsePayload.isUpdated = false;
                responsePayload.isCreated = false;
                responsePayload.isSuccess = false;
                responsePayload.message = 'Request has not been processed, please check required fields are missing';
            }
        }
        return  responsePayload ;
    }
    global class Response{
        global Boolean isCreated ;
        global Boolean isSuccess ;
        global Boolean isUpdated ;
        global String message;
    }
}