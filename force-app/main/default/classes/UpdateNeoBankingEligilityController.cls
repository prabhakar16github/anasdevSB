public class UpdateNeoBankingEligilityController {

    @AuraEnabled
    public static string updateData(string objectName, string recordId){
        try{
            sObject sObjectToUpsert = Database.query('SELECT Id,Re_Published__c,NB_Eligible__c from '+objectName+ ' Where Id=:recordId LIMIT 1');
            if(sObjectToUpsert != null){
                sObjectToUpsert.put('NB_Eligible__c',sObjectToUpsert.get('NB_Eligible__c') == true ? false : true);
                update sObjectToUpsert;
                return sObjectToUpsert.get('NB_Eligible__c') == true ? 'Neo-Banking activated successfully.' : 'Neo-Banking de-activated successfully.';
            }
        }catch(Exception ex){
            return 'Line No.-'+ex.getLineNumber() + ' Message-'+ex.getMessage();
        }
        return null;
    }
}