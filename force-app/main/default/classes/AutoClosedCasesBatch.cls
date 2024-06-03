global class AutoClosedCasesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    public Map<string,string> panelRecordTypeIdNameMap = (Map<string,string>)JSON.deserialize(label.LP_Merchant_Care_Record_Type , Map<String,String>.class);
    public Batch_Setting__mdt batchSetting = Batch_Setting__mdt.getInstance('OneCareCaseAutoClose');
    public static FINAL List<String> statusList = new list<String> {'Pending','Resolved'};
        public static FINAL List<String> subStatusList = new list<String> {'Waiting On Buyer','Waiting On Merchant'}; 
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String fieldsForQuery = String.join(getFieldSet('Case'), ',');
        Set<String> recordTypeIds = panelRecordTypeIdNameMap.keySet();
        
        String query = 'SELECT '+fieldsForQuery+' FROM Case WHERE RecordTypeId IN :recordTypeIds ';
        query += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+batchSetting.Where_Clause__c : '';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        
        for(Case cs : caseList){
            if(validForReminder(cs)){
				                
            }
            
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    private static Boolean validForReminder(Case cs){
        Boolean isValid = FALSE;
        Integer daysCount = Date.valueOf(cs.LastModifiedDate).daysBetween(System.today());
        if(daysCount < 3 && cs.Status == 'Pending' && subStatusList.contains(cs.LP_Sub_Status__c)){
            isValid = TRUE;
        }
        return isValid;
    }
    
    private static Set<String> getFieldSet(String sobType){
        Set<String> setToReturn = new Set<String>();
        if(sobType !=null){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobType).getDescribe().fields.getMap();
            for(Schema.SObjectField each : fieldMap.Values()){
                schema.describefieldresult dfield = each.getDescribe();
                setToReturn.add(dfield.getName());
            }            
        }
        return setToReturn;
    } 
}