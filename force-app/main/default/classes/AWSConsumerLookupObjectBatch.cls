public class AWSConsumerLookupObjectBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful{

    public List<string> sObjectIds = new List<String>();
    public string sObjectName = '';
    public Map<String, String> complexJsonNodeMap;
    public Map<String, String> currentJsonDataMap;
    static Map<String, Schema.SObjectType> globalDescribe;
    
    public AWSConsumerLookupObjectBatch(Set<String> updatedSObjectIds, string objName, Map<String, String> complexNodeMap, Map<String, String> currentDataMap){
        this.sObjectIds = new List<String>(updatedSObjectIds);
        this.sObjectName = objName;
        this.complexJsonNodeMap = complexJsonNodeMap;
        this.currentJsonDataMap = currentDataMap;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
        return new List<String> {'1'};
            }
    
    public void execute(Database.BatchableContext info, List<String> strings){
        globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
        List<SObject> sObjectList = New List<SObject>();
        
        if(!sObjectIds.isEmpty() && sObjectIds.size()>0){
            if(sObjectName == 'Merchant_Assessment_Response__c' ){
                    if(!complexJsonNodeMap.isEmpty() && !currentJsonDataMap.isEmpty()){
                        for(String eachStr : currentJsonDataMap.keySet()){ 
                            if(complexJsonNodeMap != null && complexJsonNodeMap.containsKey(eachStr)){                                        
                                Object theCompNode = currentJsonDataMap.get(eachStr);
                                if(theCompNode != null){
                                    Map<String, Object> complexDataMap = (Map<String, Object>)theCompNode;
                                    Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                    Set<String> theFields = New Set<String>();
                                    SObject sobToUpsert;
                                    
                                    for(String eachChildStr : complexJsonNodeMap.get(eachStr).split(';')){
                                        string childObjName = '';
                    					
                                        if(eachChildStr.contains('-')){
                                            childObjName = eachChildStr.subStringBefore('-');
                                            theFields = AWSConsumerBatch.getFieldSet(childObjName);
                                            sobToUpsert = globalDescribe.get(childObjName).newSObject();
                                            string keySetStr = eachChildStr.subStringBefore(':').subStringAfter('-');
                                            complexKeyFieldMap.put(keySetStr, eachChildStr.subStringAfter(':'));
                                        }else{
                                            complexKeyFieldMap.put(eachChildStr.subStringBefore(':'), eachChildStr.subStringAfter(':'));
                                        }
                                    }
                                    for(Merchant_Assessment_Response__c each : Database.query('SELECT Id FROM Merchant_Assessment_Response__c WHERE Id IN (\'' + String.join(new List<String>(sObjectIds), '\',\'') + '\')')){                    
                                    	sobToUpsert.put('Merchant_Assessment_Response__c',each.Id);
                                    }
                                    if(!complexKeyFieldMap.isEmpty()){
                                        for(String eachCompStr : complexDataMap.keySet()){  
                                            AWSConsumerBatch.populateField(sobToUpsert, null, eachCompStr, complexDataMap.get(eachCompStr), complexKeyFieldMap.get(eachCompStr), null, theFields);                                 
                                        } 
                                    }
                                    if(sobToUpsert != null) sObjectList.add(sobToUpsert);
                                }
                            }
                        }
                    }
                if(!sObjectList.isEmpty()) upsert sObjectList;
            }
        }
    }
    
    public void finish(Database.BatchableContext info){
        
    }
}