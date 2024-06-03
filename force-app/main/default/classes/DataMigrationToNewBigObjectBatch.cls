/*
* Name of the class : DataMigrationToNewBigObjectBatch
* Author's Name     : Manila Agnihotri  
* Created Date      : 5Th Jan, 2023
* Description       : Generic batch class to push the data to new big objects from Big Object
* Version.          : 1   
*/ 
public class DataMigrationToNewBigObjectBatch implements Database.Batchable<sObject> {
    /*********************************Member Variables**********************************/
    private String objectAPIName = '';
    private String labelName = '';
    private Map<String,Object_to_Big_Object_Mapping__mdt> mapObjectAPINameToCustomMetadataRecord = new Map<String,Object_to_Big_Object_Mapping__mdt>();
    private Map<String,Object> mapFieldMapping = new Map<String,Object>();
    private Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private Schema.SObjectType objectSchema;
    Map<String,Schema.SObjectField> fieldMap;
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
* objectAPIName : This parameter receive the API Name of the Object
*/ 
    public DataMigrationToNewBigObjectBatch(String objectAPIName,String labelName) {
        this.objectAPIName = objectAPIName;
        this.labelName = labelName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Developername,Object_API_Name__c,Big_Object_API_Name__c,Field_Mapping__c,
                                                                      Identifier_on_Object_To_track_the_status__c,Query_To_fetch_data_to_push_to_BO__c
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true and Developername=:labelName LIMIT 50000])
            mapObjectAPINameToCustomMetadataRecord.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord);    
        
        if(mapObjectAPINameToCustomMetadataRecord.containsKey(objectAPIName)) 
            mapFieldMapping = (Map<String,Object>)JSON.deserializeUntyped(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Field_Mapping__c); 
        
        objectSchema = schemaMap.get(objectAPIName);
        fieldMap = objectSchema.getDescribe().fields.getMap();
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public  Iterable<sObject> start(Database.BatchableContext BC) {
        String query = '';
        if(!Test.isRunningTest()){
            if(mapObjectAPINameToCustomMetadataRecord.containsKey(objectAPIName)) {
                query = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Query_To_fetch_data_to_push_to_BO__c;
            }
        }
        else{
            if(mapObjectAPINameToCustomMetadataRecord.containsKey('Payload_Log__c')) {
                query = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Query_To_fetch_data_to_push_to_BO__c;
            }  
        }
        return Database.query(query);
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listSobject) {
        try{
            List<Sobject> listBigOjbectToInsert = new List<Sobject>();
            Object_to_Big_Object_Mapping__mdt customMetadataRecord = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName);
            for(sObject dataRecord : listSobject) {
                sObject bigObjectRecord = Schema.getGlobalDescribe().get(customMetadataRecord.Big_Object_API_Name__c).newSObject();
                for(String objectFieldAPIName : mapFieldMapping.keySet()) {
                    //Schema.DisplayType fieldDataType = fieldMap.get(objectFieldAPIName).getDescribe().getType();
                    bigObjectRecord.put((String)mapFieldMapping.get(objectFieldAPIName),dataRecord.get(objectFieldAPIName));    
                }
                listBigOjbectToInsert.add(bigObjectRecord);
            }
            if(listBigOjbectToInsert.size() > 0 && !Test.isRunningTest()) {
                Database.insertImmediate(listBigOjbectToInsert);
            }
        }
        catch(Exception e) {
            //Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'DataMigrationToNewBigObjectBatch',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    
    public void finish(Database.BatchableContext BC) {} 
}