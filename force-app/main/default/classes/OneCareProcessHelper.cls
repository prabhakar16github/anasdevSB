public class OneCareProcessHelper {
    
    public static OwnerAndDedupeWrapper getDuplicacyAndOwnership(String merchantType,String issue,String subIssue,string businessVertical, string subVertical, String recordTypeId){
        OwnerAndDedupeWrapper objwrapper;
        String oneCareOwnerQueryStr = '';
        //Avoid special chars to avoid random issue 
        subIssue = removeSpecialChars(subIssue);
        
        /* Contains all the sub issue related to the perticular issue*/
        System.debug('### merchantType '+merchantType);
        System.debug('### issue '+issue);
        System.debug('### subIssue '+subIssue);
        System.debug('### businessVertical '+businessVertical);
        System.debug('### subVertical '+subVertical);
        System.debug('### recordTypeId '+recordTypeId);
        String subIssueStr = '';
        String queueName = '';
        Boolean isPotentialLead = false;
        OneCare_OwnerShip__mdt OneCareMtd = new OneCare_OwnerShip__mdt();
        Map<String, String> subissueVsLOBMapWithPL = new Map<String, String>();
        Map<String, String> subissueVsLOBMapWithoutPL = new Map<String, String>();
        if(merchantType == 'Potential Lead'){
            isPotentialLead = true;
        }
        //String recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        System.debug('recordTypeId::'+recordTypeId);
        
        oneCareOwnerQueryStr = 'SELECT Business_Vertical__c,Sub_Vertical__c ,JSON_Map_key_value_issueVsSubissue__c,JSON_Map_key_value_subIssueVsLOB__c,Record_Type_Name__c,Merchant_Type__c,Duplicate_Criteria__c FROM OneCare_OwnerShip__mdt WHERE ';
        oneCareOwnerQueryStr += 'Record_Type_Name__c =\'' + recordTypeId + '\'';
        oneCareOwnerQueryStr += ' and ';
        oneCareOwnerQueryStr += 'Business_Vertical__c =\'' + businessVertical + '\'';
        
        System.debug('QUERY: '+oneCareOwnerQueryStr);
        list<OneCare_OwnerShip__mdt> oneCareOwnerShipList = Database.query(oneCareOwnerQueryStr);
        System.debug('oneCareOwnerShipList SIZE::'+oneCareOwnerShipList.size());
        for(OneCare_OwnerShip__mdt mtd: oneCareOwnerShipList){
            System.debug('mtd.JSON_Map_key_value_issueVsSubissue__c>>>>'+mtd.JSON_Map_key_value_issueVsSubissue__c);
            if(mtd.JSON_Map_key_value_issueVsSubissue__c.substringBefore(':') == issue){
                System.debug('mtd.Merchant_Type__c>>>>'+mtd.Merchant_Type__c);
                if(mtd.Merchant_Type__c == 'Potential Lead' && isPotentialLead){
                    subIssueStr = mtd.JSON_Map_key_value_issueVsSubissue__c.substringAfter(':').trim();
                    /*System.debug('xsubIssueStr'+subIssueStr);
                    System.debug('Pooja xsubIssueStr'+subIssueStr.containsIgnoreCase(subIssue.trim()));
                    Map<String, String> test = new Map<String, String>();
                    for(String s : subIssueStr.split(',')){
                        test.put(s,s);
                    }
                    if(test.containsKey(subIssue)){ System.debug('test ************************');}
                    List<String> subIssueList = subIssueStr.split(',');
                    System.debug('xsubIssueStr subIssueList '+subIssueList.contains(subIssue));*/
                   
                    //if(subIssueStr.containsIgnoreCase(subIssue.trim())){
                    if(safelyPad(subIssueStr, subIssue, ',')){
                        OneCareMtd  = mtd;
                        subissueVsLOBMapWithPL = (Map<String, String>)JSON.deserialize(mtd.JSON_Map_key_value_subIssueVsLOB__c, Map<String, String>.class);
                    }
                    System.debug('subissueVsLOBMapWithPL>>>>'+subissueVsLOBMapWithPL);
                    
                }else if(mtd.Merchant_Type__c != 'Potential Lead' && !isPotentialLead){
                    //subIssue ='transaction status';
                    subIssueStr = mtd.JSON_Map_key_value_issueVsSubissue__c.substringAfter(':');
                    /*System.debug('xsubIssueStr'+subIssueStr);
                    System.debug('xsubIssueStr'+subIssue);
                    System.debug('xsubIssueStr contains'+subIssueStr.containsIgnoreCase(subIssue));
                    List<String> subIssueList = subIssueStr.split(',');
                    System.debug('xsubIssueStr subIssueList '+subIssueList.contains(subIssue));*/
                   
                    //if(subIssueStr.containsIgnoreCase(subIssue)){
                    if(safelyPad(subIssueStr, subIssue, ',')){
                        System.debug('isEmpty::'+subissueVsLOBMapWithoutPL.isEmpty());
                        if(subissueVsLOBMapWithoutPL.isEmpty() ){
                            OneCareMtd  = mtd;
                            subissueVsLOBMapWithoutPL = (Map<String, String>)JSON.deserialize(mtd.JSON_Map_key_value_subIssueVsLOB__c, Map<String, String>.class);
                        }                        
                    }
                    System.debug('subissueVsLOBMapWithoutPL>>>>'+subissueVsLOBMapWithoutPL);
                }
                
            }
        
        }
        System.debug('### subIssue '+subIssue);
        System.debug('### subIssueStr '+subIssueStr);
        System.debug('### issue '+issue);
        //System.debug('### subIssue ignore '+subIssueStr.containsIgnoreCase(subIssue));
        //System.debug('##### json meta isue '+OneCareMtd.JSON_Map_key_value_issueVsSubissue__c.substringBefore(':'));
        if((!subissueVsLOBMapWithPL.isEmpty() && subissueVsLOBMapWithPL != null) || (!subissueVsLOBMapWithoutPL.isEmpty() && subissueVsLOBMapWithoutPL!=null)){
            if(string.isNotBlank(subIssue) && string.isNotBlank(issue) 
               && safelyPad(subIssueStr, subIssue, ',') //subIssueStr.containsIgnoreCase(subIssue) 
               && OneCareMtd.JSON_Map_key_value_issueVsSubissue__c.substringBefore(':') == issue){
                if(!subissueVsLOBMapWithPL.isEmpty() && subissueVsLOBMapWithPL != null){
                    for(String s : subissueVsLOBMapWithPL.keySet()){
                        
                        String str = s.toUpperCase();
                        str = removeSpecialChars(str);
                        if(!str.equals(s)){
                            System.debug('#####INSIDE check case');
                            subissueVsLOBMapWithPL.put(str,subissueVsLOBMapWithPL.get(s));
                            subissueVsLOBMapWithPL.remove(s);
                        }
                    }
                }else{
                    for(String s : subissueVsLOBMapWithoutPL.keySet()){
                        
                        String str = s.toUpperCase();
                        str = removeSpecialChars(str);
                        if(!str.equals(s)){
                        subissueVsLOBMapWithoutPL.put(str,subissueVsLOBMapWithoutPL.get(s));
                        subissueVsLOBMapWithoutPL.remove(s);
                        }
                        
                    }
                }
                
                objwrapper = new OwnerAndDedupeWrapper();
                objwrapper.oneCareMtdVal = OneCareMtd;
                if(oneCareOwnerShipList[0].Duplicate_Criteria__c != NULL)
                    objwrapper.mapOfFieldMapping = (Map<String, String>)JSON.deserialize(oneCareOwnerShipList[0].Duplicate_Criteria__c, Map<String, String>.class);
                //System.debug('Check If::'+subissueVsLOBMapWithPL.get(subIssue.toUpperCase())); 
                //System.debug('Check If::'+subissueVsLOBMapWithPL.get(subIssue));
                System.debug('Check If::'+subissueVsLOBMapWithPL); 
                System.debug('Check If::'+subissueVsLOBMapWithoutPL);
                System.debug('Check If::'+subIssue.toUpperCase());
                //System.debug('Check If::'+subissueVsLOBMapWithPL.get(subIssue));
                if(subissueVsLOBMapWithPL.get(subIssue.toUpperCase()) != null){
                    queueName = subissueVsLOBMapWithPL.get(subIssue.toUpperCase());
                }else{
                    queueName = subissueVsLOBMapWithoutPL.get(subIssue.toUpperCase());
                }
                System.debug('Queue Name '+queueName);
                id bHId;
                List<Group> queueList = [select Id,DeveloperName from Group where Type = 'Queue' AND DeveloperName =: queueName];
                objwrapper.ownerId = queueList[0].Id;
                
            }
        }
        else{
            System.debug('#### duplicate start');
            String queryStr = 'SELECT Business_Vertical__c,QueueId__c, Duplicate_Criteria__c, Queue_Name__c,L2_Queue_Id__c,L3_Queue_Id__c, Sub_Vertical__c FROM Duplicacy_And_Ownership__mdt WHERE ';        
            queryStr += 'Business_Vertical__c =\'' + businessVertical + '\' and Sub_Vertical__c=\'' + subVertical + '\' and Record_Type_Name__c =\'' + recordTypeId + '\'';
            
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
        }
        System.debug('objwrapper>>>>'+objwrapper);
        return objwrapper;
    }
    
    public class OwnerAndDedupeWrapper{
        public Id ownerId;
        public map<string,string> mapOfFieldMapping;
        public Duplicacy_And_Ownership__mdt mdtVal;
        public OneCare_OwnerShip__mdt oneCareMtdVal;
    }
    
     //Added by Pooja || SFI-1375//
     
    public static Boolean safelyPad(String comparisonData, String searchData, String splitOperator){
        Boolean isExists = false;
		List<String> arrayString = comparisonData.split(splitOperator);
        //searchData = removeSpecialChars(searchData.trim());
        System.debug('SubIssue '+searchData);
        
        for(String s : arrayString){
            String subIss = removeSpecialChars(s.trim());
            System.debug('SubIssue each '+subIss);
            if(subIss.equalsIgnoreCase(searchData)){
                isExists = true;
            }
        }
        System.debug('isExists '+isExists);
        return isExists;
    }
    
    private static String removeSpecialChars(String data){
        data = data.replaceAll('[^a-zA-Z0-9\\s+]', '_');
        data = data.replaceAll(' ', '_');
        return data;
    }
    //Added by Pooja || SFI-1375//
}