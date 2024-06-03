@isTest
public class Check_AgencyAllocationBatch_Tracker  {

    @isTest
    public static void unitTest(){
       Case obj = new Case();
       //obj.LP_AgencyAllocation_Flag__c = true;
       String collectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId(); 
       obj.RecordTypeId = collectionRecordTypeId;
       insert obj; 
       
       String schTime = '0 0 0 * * ?';
       System.schedule('check Agency', schTime, new Check_AgencyAllocationBatchSchedular());     
    }
}