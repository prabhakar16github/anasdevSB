public class RepublishedPayloadController {
    
    @AuraEnabled
    public static string republishedData(string objectName, string recordId){
        try{
            sObject sObjectToUpsert = Database.query('SELECT Id,Re_Published__c from '+objectName+ ' Where Id=:recordId LIMIT 1');
            if(sObjectToUpsert != null){
                sObjectToUpsert.put('Re_Published__c',sObjectToUpsert.get('Re_Published__c') == true ? false : true);
                update sObjectToUpsert;
                return 'Republished successfully.';
            }
        }catch(Exception ex){
            return 'Line No.-'+ex.getLineNumber() + ' Message-'+ex.getMessage();
        }
        return null;
    }
}