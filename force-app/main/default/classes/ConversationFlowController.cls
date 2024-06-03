public with sharing class ConversationFlowController {
    @AuraEnabled(cacheable = true)
    public static List<CommentWrapper> getComments(String oppId){
        System.debug('>>>>oppId>>>.'+oppId);
        List<CommentWrapper> wrapList = new List<CommentWrapper>();
        for(Comments__c cm : [SELECT Id,Comment__c,Comment_By__c,Commentable_Type__c,Prod_Merchant_Id__c,Document_Link__c,CreatedBy.Name,CreatedDate 
                                FROM 
                                Comments__c 
                                WHERE 
                                Opportunity__c = :oppId 
                                AND Commentable_Type__c LIKE '%LOB%' 
                                AND Active__c = true
                                ORDER BY CreatedDate DESC]){
            CommentWrapper cw = new CommentWrapper();
            cw.cm = cm;
            if(String.isNotBlank(cm.Comment_By__c) && cm.Comment_By__c.equalsIgnoreCase('salesforce')){
                cw.isSalesforce = true;
            }
            if(String.isNotBlank(cm.Document_Link__c)){
                cw.hasAttachment = true;
            }
            wrapList.add(cw);
        }
        return wrapList;
    }

    public class CommentWrapper{
        @AuraEnabled public Comments__c cm = new Comments__c();
        @AuraEnabled public Boolean isSalesforce = false;
        @AuraEnabled public Boolean hasAttachment = false;

    }
}