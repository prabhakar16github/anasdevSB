/**
* @Class Name   :   McareDashboardBulkActionCtrl
* @Description  :   Controller class for mcareDashboardBulkAction LWC.
* @Auther       :   Prabhakar Joshi
* @Group        :   Mcare Dashboard Case 
*/
public with sharing class McareDashboardBulkActionCtrl {
    
    /** Private method to validate the user for bulk actions. */
    private static ValidateUserWrapper isValidUserForBulkAction(){
        ValidateUserWrapper wrap = new ValidateUserWrapper();
        Set<Id> permissionSetIds = new Set<Id>();
        for(PermissionSetGroup psg : [SELECT Id, developerName,
                                     (SELECT Id, PermissionSetID FROM PermissionSetGroupComponents)
                                      FROM PermissionSetGroup 
                                      WHERE developerName = 'Mcare_Permission_Group' LIMIT 1]){
                                        if(!psg.PermissionSetGroupComponents.isEmpty()){
                                            for(PermissionSetGroupComponent cmp : psg.PermissionSetGroupComponents){
                                                permissionSetIds.add(cmp.PermissionSetID);
                                            }
                                        }
        }
        for(PermissionSetAssignment pAssign : [SELECT AssigneeId, PermissionSet.Name, PermissionSetId 
                                                FROM PermissionSetAssignment 
                                                WHERE PermissionSetId IN :permissionSetIds
                                                AND AssigneeId = :UserInfo.getUserId()]){
                                                    
                                                    
                                                    if(pAssign.PermissionSet.Name == 'Mcare_Risk_Operation_Team_Manager_Access'){
                                                        wrap.isValidForBulkAction = true;
                                                    }else if(pAssign.PermissionSet.Name == 'MCare_Bulk_Update_Permission'){
                                                        wrap.isValidForBulkUpdate = true;
                                                    }else if(pAssign.PermissionSet.Name == 'MCare_Bulk_Delete_Permission'){
                                                        wrap.isValidForBulkDelete = true;
                                                    }
                                                }

        return wrap;
    }/** END */
    
    /** Method to get the details of seleted records to show in data table. */
    @AuraEnabled
    public static McareDataWrapper getMcareRecords(String selectedIdStr){
        
        McareDataWrapper wrap = new McareDataWrapper();
        wrap.userWrap = isValidUserForBulkAction();
        if(wrap.userWrap.isValidForBulkAction){
            if(String.isBlank(selectedIdStr)){
                return NULL;
            }
            Set<String> selectedIds = new Set<String>(selectedIdStr.split(','));
            wrap.mcareRecordList = [SELECT Id,Name,Status__c,Merchant_Id__c,Risk_Hold_Reason__c,Comments__c
                                    FROM MCare_Dashboard_Case__c 
                                    WHERE Id IN :selectedIds];
        }
        return wrap;
    }/** END */
    
    /** Method to update the selected records. */
    @AuraEnabled
    public static String updateMcareRecords(String selectedIdStr,String statusValue,String riskHoldReason,String commentValue){
        try{
            List<MCare_Dashboard_Case__c> mcareList = new List<MCare_Dashboard_Case__c>();
            for(Id mcareId : selectedIdStr.split(',')){
                MCare_Dashboard_Case__c mcare = new MCare_Dashboard_Case__c();
                mcare.Id = mcareId;
                mcare.Status__c = statusValue;
                if(String.isNotBlank(riskHoldReason) && statusValue == 'Risk Hold'){
                    mcare.Risk_Hold_Reason__c = riskHoldReason;
                }else{
                    mcare.Risk_Hold_Reason__c = NULL;
                }
                if(String.isNotBlank(commentValue)){
                    mcare.Data_Analyst_Comment__c = commentValue;
                }
                
                mcareList.add(mcare);
            }
            
            if(!mcareList.isEmpty()){
                update mcareList;
                return 'Success';
            }
        }catch(Exception e){
            return 'Error : '+e.getMessage();
        }
        return NULL;
    }/** END */
    
    /** Method to delete the selected records. */
    @AuraEnabled
    public static String deleteMcareRecords(String selectedIdStr){
        try{
            if(String.isBlank(selectedIdStr)){
                return 'Error : Issue with the selected record ids. Internal Salesforce Error.';
            }
            
            Set<String> mcareIds = new Set<String>(selectedIdStr.split(','));
            
            List<MCare_Dashboard_Case__c> mcareList = [SELECT Id FROM MCare_Dashboard_Case__c WHERE Id IN :mcareIds];
            if(!mcareList.isEmpty()){
                delete mcareList;
                return 'Success';
            }
            
        }catch(Exception e){
            return 'Error : '+e.getMessage();
        }
        return NULL;
    }/** END */
    
    /** Method to get the Map of picklist values. */
    @AuraEnabled(cacheable=true)
    public static Map<String,Map<String,String>> getPickListWrapper(){
        Map<String,Map<String,String>> picklistFieldMap = new Map<String,Map<String,String>>{'Status__c' => new Map<String,String>(),'Risk_Hold_Reason__c'=> new Map<String,String>()};
            for(String fieldName : picklistFieldMap.keySet()){
                picklistFieldMap.put(fieldName, getPicklistValueMap(fieldName));
            }
        return picklistFieldMap;
    }
    
    private static Map<String,String> getPicklistValueMap(String fieldName){
        Map<String,String> pickListMap = new Map<String,String>();
        pickListMap.put('--None--', '');
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('MCare_Dashboard_Case__c').newSObject().getSObjectType().getDescribe().fields.getMap(); 
        list<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : values){ 
            pickListMap.put(a.getLabel(), a.getValue());
        }
        return pickListMap;
    }/** END */
    
    public class McareDataWrapper{
        @AuraEnabled
        public ValidateUserWrapper userWrap = new ValidateUserWrapper();
        @AuraEnabled
        public List<MCare_Dashboard_Case__c> mcareRecordList = new List<MCare_Dashboard_Case__c>();
        
    }

    public class ValidateUserWrapper{
        @AuraEnabled 
        public Boolean isValidForBulkAction = false;
        @AuraEnabled 
        public Boolean isValidForBulkUpdate = false;
        @AuraEnabled 
        public Boolean isValidForBulkDelete = false;
        
    }
}