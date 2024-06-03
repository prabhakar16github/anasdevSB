/*
 * Name of the class : FieldTrackerBatch
 * Author's Name     : Prabhakar Joshi & Saksham Rohila 
 * Created Date      : 10th Feb, 2023
 * Description       : Generic batch class to create records that helps to identify the fields that need to be deleted
 * Version.          : 1   
 */ 
public class FieldTrackerBatch implements Database.Batchable<String> {
    /*********************************Member Variables**********************************/
    private String sObjectName;
    private List<String> customFields;
    private Integer totalCount ;
    /*********************************Member Variables End*****************************/
    
    /********************************Constructor***************************************/
    /*
     * objectAPIName : This parameter receive the API Name of the Object
     */
    public FieldTrackerBatch(String objApiName){
        this.sObjectName = objApiName;
        List<AggregateResult> listAgrOpp = Database.query('SELECT Count(Id) totalCount FROM '+objApiName);
        totalCount = (Integer)listAgrOpp[0].get('totalCount');
        Map<String,Schema.SObjectField> mapOfField = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        customFields = new List<String>();
        for(String fieldName : mapOfField.keySet()) {
            Schema.DescribeFieldResult f = mapOfField.get(fieldName).getDescribe();
            if(f.isCustom() && f.type != Schema.DisplayType.TEXTAREA){
                customFields.add(f.getName());
            }
        }
        
        List<Field_Tracker__c> listFieldTrackerToDelete = [SELECT Id FROM Field_Tracker__c WHERE Object_API_Name__c = :objApiName];
        if(listFieldTrackerToDelete != NULL && listFieldTrackerToDelete.size() > 0) delete listFieldTrackerToDelete;
    }
    /********************************Constructor End***********************************/
    
    /****************************Start Method*****************************************/
    public Iterable<String> start(Database.BatchableContext bc) {
        return customFields;
    }
    /****************************Start Method End*************************************/
    
    /****************************Execute Method***************************************/
    public void execute(Database.BatchableContext BC, List<String> listCustomFields){
        List<Field_Tracker__c> listFieldTrackerToInsert = new List<Field_Tracker__c>();
        for(String fieldApiName : listCustomFields) {
            if(!Test.isRunningTest()) {
            	List<AggregateResult> listAgr = DataBase.query('SELECT Count(Id) con FROM '+sObjectName +' WHERE '+fieldApiName +' = NULL');
            	listFieldTrackerToInsert.add(getFieldTrackerObject(fieldApiName,(Integer)listAgr[0].get('con')));    
            }
            else {
            	listFieldTrackerToInsert.add(getFieldTrackerObject(fieldApiName,0));     
            }
        }  
        if(listFieldTrackerToInsert.size() > 0) {
            Database.insert(listFieldTrackerToInsert,false);
        }
    }
    /****************************Execute Method End*********************************/
    
    /****************************Finish Method**************************************/
    public void finish(Database.BatchableContext BC){
    
    }
	/****************************Finish Method End ********************************/
    
    /****************************Method to get instance of Field_Tracker__c object for every field************************/
    private Field_Tracker__c getFieldTrackerObject(String field, Integer count){
        Field_Tracker__c tr = new Field_Tracker__c();
        tr.Field_API_Name__c = field;
        tr.Object_API_Name__c = sobjectName;
        tr.Total_Number_of_Records__c = totalCount;
        tr.Number_of_Blank_Records__c = count;
        return tr;
    }
	/****************************Method End************************************************/
}