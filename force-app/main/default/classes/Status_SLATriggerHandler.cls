/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this class is handler for status sla trigger 
@history
<Date>                <Authors Name>              <Brief Description of Change>
18-May-19              Eitika Verma               created
**/

public class Status_SLATriggerHandler {
    public static boolean isTriggerExecuted = false; 
    
    public static void beforeInsertHandler(list<Status_SLA__c> triggerNew){}
    
    public static void afterInsertHandler(list<Status_SLA__c> triggerNew){}
    
    public static void beforeUpdateHandler(list<Status_SLA__c> triggerNew, map<Id,Status_SLA__c> TriggeroldMap){
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        //Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
         //Prashant
         Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        
        list<Status_SLA__c> StatusSlaList = new list<Status_SLA__c>();
        Map<id,Status_SLA__c> StatusSlaMap = new Map<id,Status_SLA__c>();
        list<Status_SLA__c> onecareSLA = new list<Status_Sla__c>();
        list<string> restrictedStatus = new list<string>{'Open','New'};
        
        //Onecare Report
        if(!isTriggerExecuted){
            for(Status_SLA__c newSLA : triggerNew){
                Status_SLA__c oldSLA = TriggeroldMap.get(newSLA.Id);
                if(oneCareRecIdVsRecTypeMap.containskey(newSLA.Parent_RecordtypeId__c) || etcRecIdVsRecTypeMap.containskey(newSLA.Parent_RecordtypeId__c) ){
                    onecareSLA.add(newSLA);
                }
                system.debug('newSLA.Parent_RecordtypeId__c '+newSLA.Parent_RecordtypeId__c);
                if(!restrictedStatus.contains(newSLA.Case__r.Status) && userInfo.getUserId() != label.IntegrationUserId
                  && (oneCareRecIdVsRecTypeMap.containskey(newSLA.Parent_RecordtypeId__c) || etcRecIdVsRecTypeMap.containskey(newSLA.Parent_RecordtypeId__c))){
                    newSLA.Onecare_Agent_Action_Time__c = System.now();
                }
                
                if((newSLA.Open_Pending_BH__c != oldSLA.Open_Pending_BH__c && newSLA.Open_Pending_BH__c != null) ||
                   (newSLA.Reopen_Pending_BH__c != oldSLA.Reopen_Pending_BH__c  && newSLA.Reopen_Pending_BH__c != null))
                {
                    StatusSlaList.add(newSLA);
                    StatusSlaMap.put(oldSLA.id,oldSLA);
                }
                else if((newSLA.Reopen_Response_Received_Time__c != oldSLA.Reopen_Response_Received_Time__c && newSLA.Reopen_Response_Received_Time__c != null) ||
                        (newSLA.Response_Received_Time__c != oldSLA.Response_Received_Time__c  && newSLA.Response_Received_Time__c != null))
                {
                    StatusSlaList.add(newSLA);
                    StatusSlaMap.put(oldSLA.id,oldSLA);
                }
                else if(newSLA.Reopen_Resolved_BH__c != oldSLA.Reopen_Resolved_BH__c && (newSLA.onecare_status__c == 'Resolved' || newSLA.onecare_status__c == 'Transferred from other teams')){
                    StatusSlaList.add(newSLA);
                    StatusSlaMap.put(oldSLA.id,oldSLA);
                }
            }
            
            if(onecareSLA != NULL && onecareSLA.size() > 0 && !isTriggerExecuted){
                isTriggerExecuted = true;
                if(StatusSlaList != NULL && StatusSlaList.size() > 0) oneCareUpdateBusinessHour(StatusSlaList,StatusSlaMap);
            }
            else {
                isTriggerExecuted = true;
                calculateBHOnStatusSLA(triggerNew,TriggeroldMap);
            }
        }
    }
    
    public static void afterUpdateHandler(list<Status_SLA__c> triggerNew, map<Id,Status_SLA__c> TriggeroldMap){}
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to calculate the Business hours on Status SLA record 
@history
<Date>                <Authors Name>              <Brief Description of Change>
18-May-19              Eitika Verma               created
**/
    public static void calculateBHOnStatusSLA(list<Status_SLA__c> triggerNew, map<Id,Status_SLA__c> TriggeroldMap){
        list<string> lstOfFieldAPINames = new list<string>();
        Map<String, String> mapOFBHFieldsVsDifferenceFields = new map<string,string>();
        map<string,list<string>> mapOftimeFieldVsListOfBHField = new map<string,list<string>>();
        
        //get the id of business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours where name = 'PayU'];
        
        //prepare Map Data
        prepareMapForBHCalculation(lstOfFieldAPINames,mapOFBHFieldsVsDifferenceFields,mapOftimeFieldVsListOfBHField);
        system.debug('lstOfFieldAPINames========'+lstOfFieldAPINames);
        system.debug('mapOFBHFieldsVsDifferenceFields========'+mapOFBHFieldsVsDifferenceFields);
        system.debug('mapOftimeFieldVsListOfBHField========'+mapOftimeFieldVsListOfBHField);
        for(Status_SLA__c eachSLA : triggerNew){
            for(string eachFieldAPI : lstOfFieldAPINames){
                if(eachSLA.get(eachFieldAPI) != TriggeroldMap.get(eachSLA.Id).get(eachFieldAPI)){
                    if(mapOftimeFieldVsListOfBHField != NULL && mapOftimeFieldVsListOfBHField.containsKey(eachFieldAPI)){
                        for(string eachBHFieldAPI : mapOftimeFieldVsListOfBHField.get(eachFieldAPI)){
                            string strDiff = mapOFBHFieldsVsDifferenceFields.get(eachBHFieldAPI);
                            Datetime startValue = Datetime.ValueOf(eachSLA.get(strDiff.substringAfter(';')));
                            Datetime EndValue = Datetime.ValueOf(eachSLA.get(strDiff.substringBefore(';')));
                            CalculateTimeInBusinessHours.calculateMinInBH(startValue,EndValue,eachBHFieldAPI,eachSLA,bh.Id);
                        }
                    }
                }
            }
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to prepare the map which us used in the calculation of business hours 
@history
<Date>                <Authors Name>              <Brief Description of Change>
18-May-19              Eitika Verma               created
**/
    private static void prepareMapForBHCalculation(list<string> lstOfFieldAPINames,Map<String, String> mapOFBHFieldsVsDifferenceFields,map<string,list<string>> mapOftimeFieldVsListOfBHField){
        //get the data from custom metadata
        list<Business_Hours__mdt> lstBHMtdt =[SELECT FieldsToQuery__c,
                                              FieldDifferenceMapping__c,
                                              FieldMapToBHField__c 
                                              FROM Business_Hours__mdt
                                              WHERE DeveloperName = 'LazyPay_Business_Hours']; 
        
        //fill values in map
        if(lstBHMtdt != NULL && lstBHMtdt.size()>0){
            Business_Hours__mdt objMtdtd = lstBHMtdt[0];
            
            //list of field which contains fields api names whose value is changing
            if(objMtdtd.FieldsToQuery__c != NULL && objMtdtd.FieldsToQuery__c.contains(','))
                lstOfFieldAPINames.addAll(objMtdtd.FieldsToQuery__c.split(','));
            
            //prepare map which contains field API name vs list of BH fields
            if(objMtdtd.FieldMapToBHField__c != NULL){
                Map<String, String> mapOFTimeFieldsVsBHFields = (Map<String, String>)JSON.deserialize(objMtdtd.FieldMapToBHField__c, Map<String, String>.class);  
                for(string eachKey : mapOFTimeFieldsVsBHFields.keyset()){
                    mapOftimeFieldVsListOfBHField.put(eachKey,new list<string>());
                    if(mapOFTimeFieldsVsBHFields.get(eachKey).contains(';'))
                        mapOftimeFieldVsListOfBHField.get(eachKey).addAll(mapOFTimeFieldsVsBHFields.get(eachKey).split(';'));
                    else
                        mapOftimeFieldVsListOfBHField.get(eachKey).add(mapOFTimeFieldsVsBHFields.get(eachKey)); 
                }
            }
            
            //prepare map which contains value of business hour field and the fields in which difference is calculated
            if(objMtdtd.FieldDifferenceMapping__c != NULL){
                mapOFBHFieldsVsDifferenceFields.putAll((Map<String, String>)JSON.deserialize(objMtdtd.FieldDifferenceMapping__c, Map<String, String>.class)); 
            }
        }
        
    }

/**
@author:            Sneha Sahi
@company:           PayU
@description:       this method is created to update the dependency on other team and reopen-resolve time in Business Hours
@history
<Date>                <Authors Name>              <Brief Description of Change>
22-Jun-20              Sneha Sahi                   created
**/    
    public static void oneCareUpdateBusinessHour(List<Status_SLA__c> StatusSlaList,Map<Id,Status_SLA__c> StatusSlaMap){
        
        List<string> subStatusValues = new list<string>{'Waiting On Merchant','Waiting On Buyer','Waiting On Bank(Bank Support)','Raised with Merchant'};
        List<string> RRStatusList = new list<string>{'Response received','Response received from buyer','Response received from merchant','Response Received from Other Teams','No Resolution From Other Teams'};
        Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
        String onecareBHId = businessHourNameIdmap.get('OneCare Business Hour'); //(Monday-Saturday)
        String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child'); //(Monday-Friday)
        list<string> onecareLobList = new list<string>{'PayU Money','PayU_Care','Key_Support','Biz_Airtel_Support','citrus_wallet','Bank_Support'};
            
        for(Status_SLA__c eachSLA : StatusSlaList){
            system.debug('eachSLA.onecare_status__c::'+eachSLA.onecare_status__c);
            if(eachSLA.onecare_status__c == 'Pending'){
                if(!subStatusValues.contains(eachSLA.onecare_sub_status__c) ){
                    if(eachSLA.Onecare_Dependency__c != null ){
                        eachSLA.Onecare_Dependency__c  = eachSLA.Onecare_Dependency__c  + ''+','+''+ eachSLA.onecare_sub_status__c; 
                        eachSLA.Onecare_Pending_On_Other_Teams__c = true;
                    }
                    else{
                        eachSLA.Onecare_Dependency__c  = eachSLA.onecare_sub_status__c;
                        eachSLA.Onecare_Pending_On_Other_Teams__c = true;
                    }
                    system.debug('Value @@@'+eachSLA.Onecare_Dependency__c);
                }
            }
            else if(RRStatusList.contains(eachSLA.onecare_status__c) ){
                if(eachSLA.Onecare_Pending_On_Other_Teams__c){
                    if((eachSLA.Reopen_Response_Received_Time__c != null && eachSLA.Reopen_Pending_Time__c != null) || test.isRunningTest() ){
                        eachSLA.Onecare_Pending_On_Other_Teams__c = false;
                        if(eachSLA.OneCare_LOB_Name__c != null && onecareLobList.contains(eachSLA.OneCare_LOB_Name__c)){
                            eachSLA.Onecare_Dependency_BH__c = eachSLA.Onecare_Dependency_BH__c != null ? 
                                (eachSLA.Onecare_Dependency_BH__c + OneCareReportHandler.getDurationbetween(eachSla.Reopen_Response_Received_Time__c, eachSla.Reopen_Pending_Time__c, onecareBHId))
                                : OneCareReportHandler.getDurationbetween(eachSla.Reopen_Response_Received_Time__c, eachSla.Reopen_Pending_Time__c, onecareBHId);
                        }
                        else{
                            eachSLA.Onecare_Dependency_BH__c = eachSLA.Onecare_Dependency_BH__c != null ? 
                                (eachSLA.Onecare_Dependency_BH__c + OneCareReportHandler.getDurationbetween(eachSla.Reopen_Response_Received_Time__c, eachSla.Reopen_Pending_Time__c, payuOnecareChildBHId))
                                : OneCareReportHandler.getDurationbetween(eachSla.Reopen_Response_Received_Time__c, eachSla.Reopen_Pending_Time__c, payuOnecareChildBHId);
                        }
                        
                    }
                    else if(eachSLA.Response_Received_Time__c != null && eachSLA.Pending_Time__c != null) {
                        eachSLA.Onecare_Pending_On_Other_Teams__c = false;
                        if(eachSLA.OneCare_LOB_Name__c != null && onecareLobList.contains(eachSLA.OneCare_LOB_Name__c)){
                        eachSLA.Onecare_Dependency_BH__c =  eachSLA.Onecare_Dependency_BH__c != null ? 
                            eachSLA.Onecare_Dependency_BH__c + OneCareReportHandler.getDurationbetween(eachSla.Response_Received_Time__c, eachSla.Pending_Time__c, onecareBHId) 
                            : OneCareReportHandler.getDurationbetween(eachSla.Response_Received_Time__c, eachSla.Pending_Time__c, onecareBHId);
                        }
                        else{
                            eachSLA.Onecare_Dependency_BH__c =  eachSLA.Onecare_Dependency_BH__c != null ? 
                            eachSLA.Onecare_Dependency_BH__c + OneCareReportHandler.getDurationbetween(eachSla.Response_Received_Time__c, eachSla.Pending_Time__c, payuOnecareChildBHId) 
                            : OneCareReportHandler.getDurationbetween(eachSla.Response_Received_Time__c, eachSla.Pending_Time__c, payuOnecareChildBHId);
                        }
                    } 
                }
                 system.debug('Value @@@'+eachSLA.Onecare_Dependency__c); 
            }
            else if(eachSLA.onecare_status__c == 'Resolved'){
                if(eachSLA.onecare_reopen_resolve_first_BH__c == null){
                    eachSLA.onecare_reopen_resolve_first_BH__c = eachSLA.Reopen_Resolved_BH__c;
                }
                else if(eachSLA.onecare_reopen_resolve_second_BH__c == null){
                    eachSLA.onecare_reopen_resolve_second_BH__c = eachSLA.Reopen_Resolved_BH__c;
                }
                else if(eachSLA.onecare_reopen_resolve_third_BH__c == null){
                    eachSLA.onecare_reopen_resolve_third_BH__c = eachSLA.Reopen_Resolved_BH__c;
                }
                else if(eachSLA.onecare_reopen_resolve_fourth_BH__c == null){
                    eachSLA.onecare_reopen_resolve_fourth_BH__c = eachSLA.Reopen_Resolved_BH__c;
                }
                
                eachSLA.Reopen_Resolved_BH__c = null;
            } 
            
            
        }
}
    
    
}