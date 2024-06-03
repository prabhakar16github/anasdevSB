/*
 * Name of the class : Scheduler To MigrationDataToBigObjectBatchCaseNull
 * Author's Name     : Manila Agnihotri  
 * Created Date      : 24th Nov, 2022
 * Description       : Scheduler class to delete the data
 * Version.          : 1   
 */ 

global class SchedulerToMigrateRecords implements Schedulable {
    public String objectName ;
    public SchedulerToMigrateRecords(String ObjectName){
	this.objectName = ObjectName;
    }
   global void execute(SchedulableContext sc) {
      DataMigrationToBigObjectBatchCaseNull b = new DataMigrationToBigObjectBatchCaseNull(objectName); 
      Database.executeBatch(b,50);
   }
}