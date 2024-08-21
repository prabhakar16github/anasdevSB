trigger PayloadTrigger on Payload_Log__c (before insert) {
    try{
        Map<String, String> keyFieldMap = new Map<String, String>{'action' => 'Action__c', 'business_object' => 'Business_Object__c', 'mid' => 'Prod_MID__c', 'producer' => 'Producer__c', 'test_mid' => 'Test_MID__c'};
        Map<String, String> currentDataFieldMap = new Map<String, String>{'uuid' => 'Payload_ID__c'};
        
        for(Payload_Log__c each : Trigger.new){
            System.debug('each:::::123::'+each);
            if(String.isNotBlank(each.Payload__c)){
                Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(each.Payload__c);
                System.debug('jsonRootMap::::::'+jsonRootMap);
                for(String eachKey : keyFieldMap.keyset()){
                    if(jsonRootMap.containsKey(eachKey) && each.get(keyFieldMap.get(eachKey)) == null){
                        System.debug('eachKey:::::'+eachKey+'keyFieldMap::::::'+keyFieldMap.get(eachKey) +'::::'+jsonRootMap.get(eachKey));
                          each.put(keyFieldMap.get(eachKey), jsonRootMap.get(eachKey));
                    }
                }
                
                if(!currentDataFieldMap.isEmpty() && jsonRootMap.containsKey('current_data')){
                    Map<String, Object> currentDataMap = (Map<String, Object>)jsonRootMap.get('current_data'); 
                    for(String eachKey : currentDataFieldMap.keyset()){
                        if(currentDataMap.containsKey(eachKey) && each.get(currentDataFieldMap.get(eachKey)) == null){
                            System.debug('eachKey:::12::'+eachKey+'keyFieldMap::22::::'+currentDataFieldMap.get(eachKey) +'::::'+currentDataMap.get(eachKey));
                            each.put(currentDataFieldMap.get(eachKey), currentDataMap.get(eachKey));
                        }
                    }
                    SYstem.debug('each::::25:'+each);
                }
            }
        }
    }catch(exception e){
        System.debug(e.getMessage() + '-----------------' + e.getLineNumber());
    }
}