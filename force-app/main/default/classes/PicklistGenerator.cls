public class PicklistGenerator{
    
    static Map<String, Map<String, Schema.SObjectField>> sobFieldMap;
    static Map<String, Schema.SObjectType> globalDescribe;
    
    @auraEnabled
    public static String getPicklistValues(String objectApiName, String fieldApiName, String selectedValue, Boolean multiSelect){         
        
        if(sobFieldMap == null){
            sobFieldMap = new Map<String, Map<String, Schema.SObjectField>>();
        }
        List<String> selectedValues = String.isNotBlank(selectedValue) && multiSelect ? selectedValue.split(';') : new List<String>();
        
        Map<String, Schema.SObjectField> fieldMap;
        if(sobFieldMap.containsKey(objectApiName)){
            fieldMap = sobFieldMap.get(objectApiName);
        }
        else{
            Schema.SObjectType targetType = (globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe).get(objectApiName);            
            fieldMap = targetType.newSObject().getSObjectType().getDescribe().fields.getMap();
            sobFieldMap.put(objectApiName, fieldMap);
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
                
        List<Schema.PicklistEntry> pickValueList = fieldMap.get(fieldApiName).getDescribe().getPickListValues(); 
        
        if(fieldMap != null){                 
            gen.writeStartArray();                   
            for(Schema.PicklistEntry each : pickValueList){
                gen.writeStartObject();
                gen.writeStringField('value', each.getValue());  
                gen.writeStringField('label', each.getLabel());
                gen.writeBooleanField('selected', multiSelect && selectedValues.contains(each.getValue()) ? true : selectedValue == each.getValue());                    
                gen.writeEndObject();          
            }                
            gen.writeEndArray();  
        }                 
        return gen.getAsString();
    }
    
    @auraEnabled
    public static String getSobjectRecords(String queryStr, String selectedValue, Boolean multiSelect, String labelField){
        
        List<String> selectedValues = String.isNotBlank(selectedValue) && multiSelect ? selectedValue.split(';') : new List<String>();
        
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartArray();                    
        for(Sobject each : Database.query(queryStr)){
            gen.writeStartObject();
            gen.writeStringField('value', String.valueOf(each.get('Id')));  
            gen.writeStringField('label', String.valueOf(each.get(labelField)));
            gen.writeBooleanField('selected', multiSelect && selectedValues.contains(String.valueOf(each.get(labelField))) ? true : selectedValue == each.get(labelField));          
            gen.writeEndObject();
        }        
        gen.writeEndArray(); 
         
        return gen.getAsString();
    }
}