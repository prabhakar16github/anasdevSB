public without sharing class GuestUserUtilityHelper {

    public static void updateObject(sObject objectName){
        try{
            update objectName;
        }catch(Exception ex){}
    }
    
    public static void upsertSObjectList(List<sObject> objectListData){
        try{
            upsert objectListData;
            system.debug('object updated successfully');
        }catch(Exception ex){
            system.debug('exception occured== '+ ex.getMessage()+' on lione number=='+ ex.getLineNumber());
        }
    }
    
    
    public static List<sObject> querySobject(string objectName, string whereCondition){
        List<sObject> sObjList = new List<sObject>();
        try{
            String strQuery = '';
            strQuery = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet(objectName)), ',');
            strQuery += ' From '+objectName+' Where '+whereCondition;
            system.debug('strQuery=='+strQuery);
            sObjList = Database.query(strQuery);
        }catch(Exception ex){}
        return sObjList;
    }
    
}