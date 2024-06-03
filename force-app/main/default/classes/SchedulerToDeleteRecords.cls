/*
 * Name of the class : SchedulerToDeleteRecords
 * Author's Name     : Manila Agnihotri  
 * Created Date      : 24th Nov, 2022
 * Description       : Scheduler class to delete the data
 * Version.          : 1   
 */ 

global class SchedulerToDeleteRecords implements Schedulable {
    public String objectName ;
    public SchedulerToDeleteRecords(String ObjectName){
	this.objectName = ObjectName;
    }
   global void execute(SchedulableContext sc) {
      BatchClassToDeleteRecords b = new BatchClassToDeleteRecords(objectName); 
      Database.executeBatch(b,2000);
   }
}