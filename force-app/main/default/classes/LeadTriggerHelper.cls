public class LeadTriggerHelper{
    
    //static Map<String, String> objFldMap = new Map<String, String>{'Opportunity' => 'ProductLabel__c,Merchant_Id__c,IntegrationInfo__c,Prod_Merchant_Id__c,Name,First_Name__c,Last_Name__c,Email__c,Mobile__c,Identifier__c,Business_Entity_Identifier__c,Business_Category_Identifier__c,Sub_Category_Identifier__c,Website__c,Merchant_Trading_Name__c,Device_Account__c,Merchant_Business_Type__c,PAN_Holder_Name__c,PAN_Number__c,Android_URL__c,iOS_URL__c,GST_Number__c,Integration_Type__c,Delivery_Duration__c,Monthly_Expected_Sale__c,SAP_Id__c,LeadSource,Active__c,Campaign_Name__c,Campaign_Medium__c,Campaign_Source__c,Campaign_Term__c,Partner_UUID__c,Sub_Source__c', 'Lead' => 'ProductLabel__c,Merchant_Id__c,IntegrationInfo__c,Name,FirstName, LastName, Email,MobilePhone__c,Identifier__c,Business_Entity_Identifier__c,Business_Category_Identifier__c,Sub_Category_Identifier__c,Website__c,Merchant_Trading_Name__c,Device__c,Merchant_Business_Type__c,PAN_Holder_Name__c,PAN_Number__c,Android_URL__c,iOS_URL__c,GST_Number__c,Integration_Type__c,Delivery_Duration__c,Monthly_Expected_Sale__c,SAP_Id__c,LeadSource,Active__c,Campaign_Name__c,Campaign_Medium__c,Campaign_Source__c,Campaign_Term__c,Partner_UUID__c,Sub_Source__c'};
    
    static Map<String, String> objFldMap = new Map<String, String>{'Opportunity' => 'ProductLabel__c,Merchant_Id__c,IntegrationInfo__c,Prod_Merchant_Id__c,Name,First_Name__c,Last_Name__c,Email__c,Mobile__c,Identifier__c,Business_Entity_Identifier__c,Business_Category_Identifier__c,Sub_Category_Identifier__c,Website__c,Merchant_Trading_Name__c,Device_Account__c,Merchant_Business_Type_Account__c,PAN_Holder_Name_Account__c,PAN_Number_Account__c,Android_URL__c,iOS_URL__c,GST_Number__c,Integration_Type__c,Delivery_Duration_Account__c,Monthly_Expected_Sale_Account__c,SAP_Id__c,LeadSource,Active__c,Campaign_Name__c,Campaign_Medium__c,Campaign_Source__c,Campaign_Term__c,Partner_UUID__c,Sub_Source__c', 'Lead' => 'ProductLabel__c,Merchant_Id__c,IntegrationInfo__c,Name,FirstName, LastName, Email,MobilePhone__c,Identifier__c,Business_Entity_Identifier__c,Business_Category_Identifier__c,Sub_Category_Identifier__c,Website__c,Merchant_Trading_Name__c,Device__c,Merchant_Business_Type__c,PAN_Holder_Name__c,PAN_Number__c,Android_URL__c,iOS_URL__c,GST_Number__c,Integration_Type__c,Delivery_Duration__c,Monthly_Expected_Sale__c,SAP_Id__c,LeadSource,Active__c,Campaign_Name__c,Campaign_Medium__c,Campaign_Source__c,Campaign_Term__c,Partner_UUID__c,Sub_Source__c'};
        
    static Map<String, String> midMap = new Map<String, String>{'Opportunity' => 'Prod_Merchant_Id__c', 'Lead' => 'Merchant_Id__c'};
    
    public static void checkFetchMID(SObject theRec, String sobName){
        
        if(!System.isBatch() && !System.isFuture() && String.isNotBlank(String.valueOf(theRec.get('IntegrationInfo__c'))) && 'Merchant'.equals(String.valueOf(theRec.get('Lead_Type__c')))){
            if('Lead'.equals(sobName) || ('Opportunity'.equals(sobName) && 'NEW MID'.equals(String.valueOf(theRec.get('Maintenance_Status__c'))))){
                fetchMIdwithTrigger(theRec.Id, sobName, null); 
            }
        }
    }    
                    
    @future(callout=true)
    public static void fetchMIdwithTrigger(Id sobId, String SobjectName, List<String> urlParamsList){
        fetchMId(sobId, SobjectName, urlParamsList);
    }
    
    public static String fetchMIdwithButton(Id sobId, String SobjectName, List<String> urlParamsList){
        return fetchMId(sobId, SobjectName, urlParamsList);
    }
    
    public static String fetchMId(Id sobId, String SobjectName, List<String> urlParamsList){
        List<Sobject> leadList;
        try{
            String queryStr = 'SELECT Id,' + objFldMap.get(SobjectName) + ' FROM ' + SobjectName + ' WHERE Id =\'' + sobId + '\'';
                        
            leadList = Database.query(queryStr);
            
            if(!leadList.isEmpty() && leadList[0].get(midMap.get(SobjectName)) != null){
                return 'Merchant_Id_Exist';
            }
            
            if(!leadList.isEmpty()){
                
                String settingNameAuth = '';
                String settingNameMid = '';
                String resPath = '';
                String fieldAPI = '';
                String intInfo = String.valueOf(leadList[0].get('IntegrationInfo__c'));
                
                if(String.isNotBlank(intInfo)){
                    List<String> intData = intInfo.split(':');
                    settingNameAuth = intData[0];
                    settingNameMid = intData[1];
                    resPath = intData[2];
                    fieldAPI = intData[3];
                }           
                List<String> urlParams;
                
                if(urlParamsList != null && !urlParamsList.isEmpty()){
                    urlParams = new List<String>();
                    
                    for(String each : urlParamsList){
                        urlParams.add(String.valueOf(leadList[0].get(each)));
                    }
                }
                
                if(String.isNotBlank(settingNameAuth)){            
                    String authToken = IntegrationUtility.getAuthToken(settingNameAuth);
                    List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, SetCompressed__c, EndPointUrl__c, Headers__c, Method__c 
                                                              FROM Integration_Setting__mdt 
                                                              WHERE DeveloperName =: settingNameMid];        
                    
                    if(!insList.isEmpty() && String.isNotBlank(authToken)){
                        
                        HttpResponse response = IntegrationUtility.requestUtility(insList[0], false, authToken, leadList[0], urlParams, '');
                        String theRes = response.getBody();
                        System.debug(response.getStatusCode()+'theRes>>>>>>'+theRes);
                        //handling errors
                        if(response.getStatusCode() != 200){
                            system.debug('in error');
                            String strErrorRes = theRes;
                            
                            
                            Map<String, String> messages = new Map<String, String>();
                            messages.put('Severity__c', 'High');
                            messages.put('Identifier__c', String.valueOf(leadList[0].get('Identifier__c')));
                            messages.put('SF_Record_Name__c', String.valueOf(leadList[0].get('Name')));
                            messages.put('SF_ID__c', String.valueOf(leadList[0].get('Id')));
                            messages.put('Process__c', 'MID Generation');
                            messages.put('Message__c', strErrorRes);
                            SystemUtility.errorHandler(null, messages);                            
                            
                            return strErrorRes;
                        }else{
                            Sobject ld = leadList[0];
                            Object theValue = getMidValue(theRes, resPath, ld);
                            if(String.isNotBlank(fieldAPI) && theValue != null){ 
                                ld.put(fieldAPI, theValue);
                                update ld;
                                return 'SUCCESS';
                            }
                        }                       
                    }
                }
            }
        }catch(Exception ex){ 
            Map<String, String> messages = new Map<String, String>();
            messages.put('Severity__c', 'High');
            messages.put('Identifier__c', String.valueOf(leadList[0].get('Identifier__c')));
            messages.put('SF_Record_Name__c', String.valueOf(leadList[0].get('Name')));
            messages.put('SF_ID__c', String.valueOf(leadList[0].get('Id')));
            messages.put('Process__c', 'MID Generation');
            SystemUtility.errorHandler(ex, messages);
            return ex.getMessage();
        } 
        return null;
    }
    
    public static Object getMidValue(String resStr, String path, Sobject eachSob){
        
        Map<String, Object> theDataToProcess = (Map<String, Object>)JSON.deserializeUntyped(resStr);
        List<String> thePath = path.split(',');
        
        Integer i = 1;
        for(String each : thePath){
            if(theDataToProcess.containsKey(each) && theDataToProcess.get(each) != null){
                Object theTempData = theDataToProcess.get(each);
                if(i < thePath.size()){
                    theDataToProcess = (Map<String, Object>)theTempData;
                }else{
                    eachSob.put('Identifier__c', theDataToProcess.get('uuid'));
                    return theTempData;    
                }
            }
            i++;
        }
        
        return null;    
    }        
}