public class DataUpdateBatch implements Database.Batchable<sObject>  {
    private String query;
    private String fieldToUpdate;
    //private String filter;
    private String valueToUpdate;
    private String fieldType;
    private Set<String> midFilterSet;
    public DataUpdateBatch(String query,String fieldToUpdate,String valueToUpdate,String fieldType,Set<String> midFilterSet){ //,String filter
        this.query = query; 
        this.fieldToUpdate = fieldToUpdate;
        //this.filter = filter;
        this.valueToUpdate = valueToUpdate;
        this.fieldType = fieldType;
        this.midFilterSet = midFilterSet;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = this.query;
        if(midFilterSet != NULL){
            query += ' WHERE Prod_MID__c IN :midFilterSet';
        }
        System.debug('>>>>query>>>>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> recordList){
        
        System.debug('>>>>recordList>>>>'+recordList.size());
        
        List<sObject> objList = new List<sObject>();
        for(sObject obj : recordList){
            if(fieldType == 'Decimal'){
                obj.put(fieldToUpdate,Decimal.valueOf(valueToUpdate));
            }else if(fieldType == 'Date'){
                obj.put(fieldToUpdate,Date.valueOf(valueToUpdate));
            }else if(fieldType == 'DateTime'){
                obj.put(fieldToUpdate,DateTime.valueOf(valueToUpdate));
            }else if(fieldType == 'Integer'){
                obj.put(fieldToUpdate,Integer.valueOf(valueToUpdate));
            }else if(fieldType == 'Boolean'){
                obj.put(fieldToUpdate,Boolean.valueOf(valueToUpdate));
            }else if(fieldType == 'String'){
                obj.put(fieldToUpdate,String.valueOf(valueToUpdate));
            }
            
            objList.add(obj);
        }
        System.debug('>>>>objList>>>>'+objList.size());
        if(!objList.isEmpty()){
            //update objList;
        }
    }
    public void finish(Database.BatchableContext BC){}
}