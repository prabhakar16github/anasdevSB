/*
* Name of the class : BigObjectDataViewerController
* Author's Name     : Anas Yar Khan  
* Created Date      : 25th Aug, 2022
* Description       : Apex Controller fpr LWC - BigObjectDataViewer
* Version.          : 1   
*/ 
public class BigObjectDataViewerController {
    /*
* Name of the function : getDataOnLoad
* Author's Name        : Anas Yar Khan  
* Created Date         : 25th Aug, 2022
* Description          : This method will call on load of the component
* Version.             : 1  
* Parameters           : No parameters 
*/
    @AuraEnabled(cacheable=true)
    public static OnLoadWrapperClass getDataOnLoad() {
        OnLoadWrapperClass wrapperClass = new OnLoadWrapperClass();
        try {
            wrapperClass.possibleObjects = '[';
            for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_Label__c
                                                                          FROM Object_to_Big_Object_Mapping__mdt 
                                                                          WHERE isActive__c = true LIMIT 50000])  {
                                                                              wrapperClass.possibleObjects += '{"label":"'+customMetadataRecord.Object_Label__c+'","value":"'+customMetadataRecord.Object_Label__c+'"},';	     
                                                                          } 
            wrapperClass.possibleObjects = wrapperClass.possibleObjects.removeEnd(',');
            wrapperClass.possibleObjects += ']';
        }   
        catch(Exception e) {
            wrapperClass.message = e.getMessage();     
        }
        return wrapperClass;
    }
    
    /***************OnLoadWrapperClass**************************/
    public class OnLoadWrapperClass {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String possibleObjects = '';
    }
    
    /*
* Name of the function : getRecordsFromApex
* Author's Name        : Anas Yar Khan  
* Created Date         : 25th Aug, 2022
* Description          : This method will call on click of the button 'Get Records' from the LWC
* Version.             : 1  
* Parameters           : selectedObject, selectedFromCreatedDate, selectedToCreatedDate 
*/
    @AuraEnabled(cacheable=true)
    public static GetRecordsWrapperClass getRecordsFromApex(String selectedObject,String selectedFromCreatedDate,String selectedToCreatedDate) {
        GetRecordsWrapperClass wrapperClass = new GetRecordsWrapperClass();
        try{
            Map<String,Object_to_Big_Object_Mapping__mdt> mapObjectLabelToCustomMetadataRecord = new Map<String,Object_to_Big_Object_Mapping__mdt>(); 
            for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_Label__c,Big_Object_API_Name__c,
                                                                          Columns_To_be_shown_in_the_table__c
                                                                          FROM Object_to_Big_Object_Mapping__mdt 
                                                                          WHERE isActive__c = true LIMIT 50000]) {
                                                                              mapObjectLabelToCustomMetadataRecord.put(customMetadataRecord.Object_Label__c,customMetadataRecord);    
                                                                          }	
            
        	String sObjectType = mapObjectLabelToCustomMetadataRecord.get(selectedObject).Big_Object_API_Name__c;
            Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectSchema = schemaMap.get(sObjectType);
            Map<String,Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();
            
            wrapperClass.columnNames = '[';
            for(String fieldAPIName : mapObjectLabelToCustomMetadataRecord.get(selectedObject).Columns_To_be_shown_in_the_table__c.split(',')) {
                if(fieldMap.containsKey(fieldAPIName)) {
                	wrapperClass.columnNames += '{"label":"'+fieldMap.get(fieldAPIName).getDescribe().getLabel()+'","fieldName":"'+fieldAPIName+'","type" : "text"},';	    
                }
            }
            wrapperClass.columnNames = wrapperClass.columnNames.removeEnd(',');
            wrapperClass.columnNames += ']';
            selectedFromCreatedDate += 'T00:00:00Z';
            selectedToCreatedDate += 'T00:00:00Z';
            String query = 'SELECT '+mapObjectLabelToCustomMetadataRecord.get(selectedObject).Columns_To_be_shown_in_the_table__c+' FROM '+mapObjectLabelToCustomMetadataRecord.get(selectedObject).Big_Object_API_Name__c;
            query += ' WHERE CreatedDate__c >= '+selectedFromCreatedDate+' AND CreatedDate__c <= '+selectedToCreatedDate+' LIMIT 50000';
            wrapperClass.listData = Database.query(query);
        }
        catch(Exception e) {
            wrapperClass.message = e.getMessage();    
        }
        return wrapperClass;
    }
    
    /***************GetRecordsWrapperClass**************************/
    public class GetRecordsWrapperClass {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String columnNames = '';
        @AuraEnabled public List<Sobject> listData = new List<Sobject>();
    }
}