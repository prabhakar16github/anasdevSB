public class OwnerReassignment {
    
    @AuraEnabled
    public static wrapperObj getfieldofCase(string recordId){
       //Map<string,string> queueDevNameWithName = (Map<string,string>)JSON.deserialize(system.label.OneCare_Queue_Developer_Name_IQueue_Name_Management,Map<string,string>.class);
        
        //Commented Custom label and Replaced with Custom Metadata// Ended by Pooja//
        //
        Map<String, OneCare_Queue_Developer_Name_QueueName__mdt> queMap = OneCare_Queue_Developer_Name_QueueName__mdt.getAll();
        Map<string,string> queueDevNameWithName = new Map<String, String>();
        for(OneCare_Queue_Developer_Name_QueueName__mdt each : queMap.values()){
            queueDevNameWithName.put(each.DeveloperName, each.MasterLabel);
        }
        //Commented Custom label and Replaced with Custom Metadata// Ended by Pooja//
       
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        wrapperObj updwrapperObj = new wrapperObj();
        
        list<string> PlatformValues = SystemUtility.getPicklistValue('Case', 'Platform_e__c');
        list<string> LOBValues = queueDevNameWithName.values();
        case c = [select platform_e__c,LOB_Name__c,OwnerId,recordTypeId from case where id = :recordId];
        if(oneCareRecIdVsRecTypeMap.containsKey(c.recordTypeId)){
            updwrapperObj.picklistValue = PlatformValues;
            updwrapperObj.CaseObj = c;
            updwrapperObj.LOBPicklistValue = LOBValues;
            updwrapperObj.chatToCase = true;
        }
        else{
            updwrapperObj.picklistValue = PlatformValues;
            updwrapperObj.CaseObj = c;
            updwrapperObj.LOBPicklistValue = LOBValues;
            updwrapperObj.chatToCase = false;
        }
        
        return updwrapperObj;
    }
    
    @AuraEnabled
    public static string setCaseFields(string OwnerId,Id recordId,string Platform){
        system.debug('Platform='+Platform);
        Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
        
        List<string> userIdList = new list<string>();
        case c = [select platform_e__c,lob_name__c,OwnerId,recordTypeId from case where id = : recordId];
        if((string.valueOf(c.OwnerId).startsWith('00G') && OwnerId != null && !string.valueOf(OwnerId).startsWith('00G')) 
           || (!string.valueOf(c.OwnerId).startsWith('00G'))){
            if(OwnerId != null && oneCareRecIdVsRecTypeMap.containsKey(c.RecordTypeId)){
                String groupId = [Select id from group where type = 'queue' and name = :Platform order by id desc limit 1].id;
                if(groupId == OwnerId){
                    c.OwnerId = OwnerId;
                    c.LOB_Name__c =Platform;
                    update c;
                    return 'UpdateLOB';
                }
                else{
                    for(GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember where GroupId = :groupId]){
                        userIdList.add(grpMember.UserOrGroupId);
                    }
                    if(userIdList.contains(OwnerId)){
                        c.OwnerId = OwnerId;
                        c.LOB_Name__c =Platform;
                        update c;
                        return 'UpdateLOB';
                    }
                    else{
                        return 'UpdateLOBError';
                    }
                }
            }  
        else if(OwnerId != null && !oneCareRecIdVsRecTypeMap.containsKey(c.RecordTypeId)){
            String groupId = [Select id from group where type = 'queue' and developerName = :Platform limit 1].id;
            if(groupId == OwnerId){
                c.OwnerId = OwnerId;
                c.Platform_e__c =Platform;
                update c;
                return 'UpdatePlatform';
            }
            else{
                for(GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember where GroupId = :groupId]){
                    userIdList.add(grpMember.UserOrGroupId);
                }if(userIdList.contains(OwnerId)){
                    c.OwnerId = OwnerId;
                    c.Platform_e__c =Platform;
                    update c;
                    return 'UpdatePlatform';
                }
                else{
                    return 'UpdatePlatformError';
                }
            }  
        }
        else return 'UpdatePlatform';
    }
    else return 'QToQAssignmentError';
}

public class wrapperObj{
    @AuraEnabled public List<string> picklistValue;
    @AuraEnabled public Case CaseObj;
    @AuraEnabled public List<string> LOBPicklistValue;
    @AuraEnabled public Boolean chatToCase;
}

}