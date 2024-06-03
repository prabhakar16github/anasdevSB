public class RollupSummaryController {

    static Map<String, Schema.SObjectType> globalDescribe;
    
    public static void getParentObjectIds(Set<Id> parentSobjectIds){
        //Schema.SObjectType sobjectType = myId.getSObjectType();
		//String sobjectName = sobjectType.getDescribe().getName();

		//List<SObject> record = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :myId');
    }
    
    public static void sumChildObjectData(){}
    
    public static void countTotalChildObjectData(Set<Id> sObjectIds,Schema.SObjectType parentObjectName,string parentRollupField,Schema.SObjectType childObjectName){
        Map<Id,sObject> sObjectMap = New Map<Id,sObject>();
        sObject sobToUpsert;
        String sobjectName;
            
        for(Id sObjId : sObjectIds) {
            Schema.SObjectType sobjectType = sObjId.getSObjectType();
			sobjectName = sobjectType.getDescribe().getName();
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
            sobToUpsert = globalDescribe.get(sobjectName).newSObject();
            //sobToUpsert.get('Id') = sObjId;
            sObjectMap.put(sObjId, sobToUpsert);
        }
        
        String query = 'SELECT COUNT(Id) total, Id FROM '+ childObjectName +' WHERE '+ parentRollupField +' IN: '+sObjectIds +' GROUP BY parentField';
    
        
       // for(AggregateResult result: Database.getQuerylocator(query)) {
           // sObjectMap.get((Id)result.get('Id')).Total_Merchant_Documents__c = (Decimal)result.get('total');
       // }
    }
    
    public static void averageChildObjectData(){}
}