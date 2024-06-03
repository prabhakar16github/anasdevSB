public class LazyPayEmailTocase {
    
    public static Set<Id> caseIdSet = new Set<Id>();
    public static Set<Id> recordTypeIdSet = new Set<Id>();
    public static Map<String,Case> mapOfUniqueKeyVsCaseObj = new Map<String,Case>();
    public static void beforeInsertHandler(List<Case> newList){
    try{  
    System.debug('LazyPayEmailTocase.beforeInsertHandler Called >>' + newList[0]);    
    
    for(String recordType : label.LP_Subject_Duplicate_Check_in_E2C_for_RecordType.split(';')){
         Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
         recordTypeIdSet.add(devRecordTypeId); 
    }
    if(recordTypeIdSet.size() > 0){       
    for(Case caseObj  : [Select id , subject , SuppliedEmail , createddate, status  from  Case where recordTypeId in : recordTypeIdSet  and status != 'Closed'  order by createddate LIMIT 50000 ]){
        if(caseObj.SuppliedEmail != null && caseObj.Subject != null){
            String uniqueKeyForCase = String.valueOf(caseObj.SuppliedEmail).trim() + '_' + String.valueOf(caseObj.Subject).trim();
            System.debug('Case Unique Key >>' + uniqueKeyForCase);
            mapOfUniqueKeyVsCaseObj.put(uniqueKeyForCase , caseObj );
            System.debug('mapOfUniqueKeyVsCaseObj >> ' + mapOfUniqueKeyVsCaseObj); 
        }    
    }     
    
    for(Case caseObj : newList){
        String uniqueKeyForCase = String.valueOf(caseObj.SuppliedEmail).trim() + '_' + String.valueOf(caseObj.Subject).trim();
        System.debug('uniqueKeyForCase >> ' + uniqueKeyForCase);
        if(mapOfUniqueKeyVsCaseObj.containsKey(uniqueKeyForCase)  && mapOfUniqueKeyVsCaseObj.get(uniqueKeyForCase) != null){
           caseObj.Parent_Case__c =  mapOfUniqueKeyVsCaseObj.get(uniqueKeyForCase).Id; 
           caseObj.Status = 'Closed'; 
           caseObj.Is_Duplicate__c = true ; 
        }        
    }
    }    
    }catch(Exception ex){
            System.debug('exception e >> ' +  ex.getMessage());
            LazyPay_Exception__c exceptionRecord = new LazyPay_Exception__c();
            exceptionRecord.Error_Message__c = 'Error Messase >>'  + ex.getMessage() + '\n' + 'Stack Trace >>' + ex.getStackTraceString();
            exceptionRecord.LP_Process__c =  'Email To Case Duplicate Check'; 
           insert exceptionRecord;
        }      
   }  
}