Trigger CaseTrigger on Case (after update, after insert, Before Insert, Before Update){
    Trigger_Switch__c objTriggerSwitch = Trigger_Switch__c.getValues('Case'); 
    Map<string,string> oneCareRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.LP_Merchant_Care_Record_Type,map<string,string>.class);
    //Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
     //Prashant
     Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
     for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
            etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
     }
    
    List<Case> newOneCareCase = New List<Case>();
    List<Case> newETCCase = New List<Case>();
    List<Case> newCareCase = New List<Case>();
    
    if(objTriggerSwitch != null && objTriggerSwitch.Active__c){    
        if(Trigger.isAfter){            
            if(Trigger.isInsert){
                for(Case newCase : trigger.New){
                    system.debug('####### '+newCase.RecordTypeId);
                    if(oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newOneCareCase.add(newCase);
                    }
                    if(etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newETCCase.add(newCase);
                    }if(!oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId) && !etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newCareCase.add(newCase);
                    }
                   
                }
                if(newOneCareCase.size()>0){
                    oneCareProcessHandler.afterInsertHandler(Trigger.new);
                }
                if(newETCCase.size()>0){
                    oneCareEmailtocase.afterInsertHandler(Trigger.new);
                }
                if(newCareCase.size()>0){
                    CaseTriggerHandler.afterInsertHandler(Trigger.new);
                }
                //Pooja added email case duplicate
                CaseTriggerHandler.caseDuplicateMerge(trigger.new);
            }    
            if(Trigger.isUpdate) {
                for(Case newCase : trigger.New){
                    if(oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newOneCareCase.add(newCase);
                    }
                    if(etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newETCCase.add(newCase);
                    }if(!oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId) && !etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newCareCase.add(newCase);
                    }
                }
                if(newETCCase.size()>0){
                    oneCareEmailtocase.afterUpdateHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
                }
                System.debug('>>>>>>>>>>newOneCareCase>>>>>>>>>>'+newOneCareCase);
                if(newOneCareCase.size()>0){
                    oneCareProcessHandler.afterUpdateHandler(Trigger.new,Trigger.old, Trigger.newMap, Trigger.oldMap);
                }
                if(newCareCase.size()>0){
                    CaseTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap); 
                }
            }   
        }        
        else if(Trigger.isBefore){
            if(Trigger.isInsert){
                for(Case newCase : trigger.New){
                    if(oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newOneCareCase.add(newCase);
                    }
                    if(etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newETCCase.add(newCase);
                    }if(!oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId) && !etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newCareCase.add(newCase);
                    }
                }
                if(newETCCase.size()>0){
                    oneCareEmailtocase.beforeInsertHandler(trigger.New);
                }
                if(newOneCareCase.size()>0){
                    oneCareProcessHandler.beforeInsertHandler(trigger.New);
                }
                if(newCareCase.size()>0){
                    CaseTriggerHandler.beforeInsertHandler(Trigger.new); 
                }
                //SFI-965 // Assign Priority for all the sales season cases based on condition
                oneCareProcessHandler.assignHighPriority(trigger.new);
                //SFI-938 assignment logic for Post/Pre/OB hold  
                //SFI-1070 adding Amazon MID to the all cases which created from @amazon//
                oneCareProcessHandler.assignRiskObTeam(trigger.new);
                //SFI-1174 Queue Logic Updation & Routing// 
                oneCareProcessHandler.assignChatCaseOwner(trigger.new);
            }                
            if(Trigger.isUpdate){
                for(Case newCase : trigger.New){
                    if(oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newOneCareCase.add(newCase);
                    }
                    if(etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newETCCase.add(newCase);
                    }if(!oneCareRecIdVsRecTypeMap.containskey(newCase.RecordTypeId) && !etcRecIdVsRecTypeMap.containskey(newCase.RecordTypeId)){
                        newCareCase.add(newCase);
                    }
                }
                if(newETCCase.size()>0){
                    oneCareEmailtocase.beforeUpdateHandler(trigger.New, Trigger.oldMap);
                }
                if(newOneCareCase.size()>0){
                    oneCareProcessHandler.beforeUpdateHandlerForOneCare(Trigger.new, Trigger.oldMap);
                }
                if(newCareCase.size()>0){
                    CaseTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
                }
                // SFI-965 // Assign Priority for all the sales season cases based on condition
                oneCareProcessHandler.assignHighPriority(trigger.new);
                
            }    
        }
    }    
}