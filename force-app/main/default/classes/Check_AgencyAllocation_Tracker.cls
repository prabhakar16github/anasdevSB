@isTest
public class Check_AgencyAllocation_Tracker {

    @isTest
    
    public static void unitTest(){
       Case obj = new Case();
       //obj.LP_AgencyAllocation_Flag__c = false;
       String collectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId(); 
       obj.RecordTypeId = collectionRecordTypeId;
       insert obj;
        
       database.executeBatch(new Check_AgencyAllocationBatch()); 
    }
}