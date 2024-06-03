/**************************************************************************************
Apex Class Name    : ChatBotUtility
Version            : 1.0
Created Date       : 08/21/2021
Function           : Utility class for Field metadata queries
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Sneha                  08/21/2021             Original Version
 *************************************************************************************/
public class ChatBotUtility {
    
    @AuraEnabled
    public static string setIssueSubIssue(String RoutableId, string selectedCntr, string selectedDept) {
        
        
        
        Bot__c IssueDispositions = new Bot__c();
        Boolean insertFailed = false;
        string issueSubissue = '';
        if(!String.isBlank(RoutableId) && RoutableId != null 
           && !string.isBlank(selectedCntr) && !string.isBlank(selectedDept)
           && selectedCntr != 'null' && selectedDept != null
          ){
            
            IssueDispositions.Issue__c = selectedCntr;
            IssueDispositions.Sub_Issue__c = selectedDept;
            IssueDispositions.Chat_Transcript_Id__c = RoutableId;
            
             
            issueSubissue = IssueDispositions.Issue__c + IssueDispositions.Sub_Issue__c;
            
        }
        
        if(IssueDispositions.Issue__c != null && IssueDispositions.Sub_Issue__c != null){
            Database.SaveResult[] insertResults = Database.insert(new List<Bot__c>{IssueDispositions},false);
        
        
            for(Integer i=0;i<insertResults.size();i++){
                if (!insertResults.get(i).isSuccess()){
                    Database.Error err = insertResults.get(i).getErrors().get(0);
                    //errorMessage.add('Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                    issueSubissue = 'Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields();
                    //insertFailed = true;
                }
            }
            
        }
        return issueSubissue;
        
        
        
    }

}