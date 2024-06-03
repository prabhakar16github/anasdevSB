/*
 * Name of the class : DataMigrationToBigObjectBatch
 * Author's Name     : Manila Agnihotri
 * Created Date      : 27th Jan, 2023
 * Description       : Generic batch class to push the data to big objects
 * Version.          : 1   
 */ 
public class DataMigrationToBigObjectBatchCaseNull implements Database.Batchable<sObject> {
	/*********************************Member Variables**********************************/
    private String objectAPIName = '';
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
    public DataMigrationToBigObjectBatchCaseNull(String objectAPIName) {
        this.objectAPIName = objectAPIName;
        for(Object_to_Big_Object_Mapping__mdt customMetadataRecord : [SELECT Object_API_Name__c,Big_Object_API_Name__c,Field_Mapping__c,
                                                                      Identifier_on_Object_To_track_the_status__c,Query_To_fetch_data_to_push_to_BO__c
                                                                      FROM Object_to_Big_Object_Mapping__mdt 
                                                                      WHERE isActive__c = true LIMIT 50000]) mapObjectAPINameToCustomMetadataRecord.put(customMetadataRecord.Object_API_Name__c,customMetadataRecord);    
                                                                      
        if(mapObjectAPINameToCustomMetadataRecord.containsKey(objectAPIName)) mapFieldMapping = (Map<String,Object>)JSON.deserializeUntyped(mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Field_Mapping__c); 
        
        objectSchema = schemaMap.get(objectAPIName);
        fieldMap = objectSchema.getDescribe().fields.getMap();
    } 
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(mapObjectAPINameToCustomMetadataRecord.containsKey(objectAPIName)) {
                query = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName).Query_To_fetch_data_to_push_to_BO__c;
           
        }
        if(String.isNotBlank(query)) return Database.getQueryLocator(query);
        else return NULL;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<sObject> listSobject) {
        //Savepoint sp = Database.setSavepoint();
        try {
            if(mapFieldMapping.keySet().size() > 0) {
                List<Sobject> listBigOjbectToInsert = new List<Sobject>();
            	Object_to_Big_Object_Mapping__mdt customMetadataRecord = mapObjectAPINameToCustomMetadataRecord.get(objectAPIName);
                //*****************Added for Email Message************************
                Set<String> setRecordId = new Set<String>();
                //*****************End for Email Message************************
                for(sObject dataRecord : listSobject) {
                    setRecordId.add(dataRecord.Id);
                    sObject bigObjectRecord = Schema.getGlobalDescribe().get(customMetadataRecord.Big_Object_API_Name__c).newSObject();
                    for(String objectFieldAPIName : mapFieldMapping.keySet()) {
                        Schema.DisplayType fieldDataType = fieldMap.get(objectFieldAPIName).getDescribe().getType();
                        if(fieldDataType == Schema.DisplayType.BOOLEAN) bigObjectRecord.put((String)mapFieldMapping.get(objectFieldAPIName),String.valueOf(dataRecord.get(objectFieldAPIName)));
                        else bigObjectRecord.put((String)mapFieldMapping.get(objectFieldAPIName),dataRecord.get(objectFieldAPIName));    
                    }
                    dataRecord.put(customMetadataRecord.Identifier_on_Object_To_track_the_status__c,true);
                    listBigOjbectToInsert.add(bigObjectRecord);
                }   
                
                /**********Added for Email Message*******************/
                if((objectAPIName == 'EmailMessage' || objectAPIName == 'Payload_Log__c') && listBigOjbectToInsert.size() > 0) {
                	Map<String,String> mapRecordIdToPublicNames = new Map<String,String>();
                    for(Intermediate_Object__c io : [SELECT Record_Id__c,Attachments_Files_name_in_the_one_drive__c 
                                                     FROM Intermediate_Object__c 
                                                     WHERE Record_Id__c IN :setRecordId]) {
                                                        mapRecordIdToPublicNames.put(io.Record_Id__c,io.Attachments_Files_name_in_the_one_drive__c);	    
                                                     }
                    
                    if(mapRecordIdToPublicNames != NULL && mapRecordIdToPublicNames.keySet().size() > 0) {
                        for(Sobject bigObjectRecord : listBigOjbectToInsert) {
                            if(mapRecordIdToPublicNames.containsKey((String)bigObjectRecord.get('RecordId__c'))) {
                            	bigObjectRecord.put('Public_Links_of_the_Attachments__c',mapRecordIdToPublicNames.get((String)bigObjectRecord.get('RecordId__c')));	    
                            } 
                        }    
                    }    
                }
                /*******************End*****************************/
                
                if(listBigOjbectToInsert.size() > 0 && !Test.isRunningTest()) {
                    Database.insertImmediate(listBigOjbectToInsert);
                    if(objectAPIName != 'EmailMessage') update listSobject;
                }
            }
        }
        catch(Exception e) {
        	//Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'DataMigrationToBigObjectBatch',Message__c = e.getMessage(),SF_Record_Name__c  = objectAPIName,Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
			insert errorDetails;
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC) {
        
    }
    /****************************Finish Method End ********************************/
}